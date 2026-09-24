  program naturaltables
!
!-----------------------------------------------------------------------------------------------------------------------------------
! Purpose: Reconstructs natural cross sections from isotopic data libraries
!
! Revision    Date      Author      Quality  Description
! ======================================================
!    1     2023-12-29   A.J. Koning    A     Original code
!-----------------------------------------------------------------------------------------------------------------------------------
!
!
! Usage: naturaltables < input    
!
! where the file input contains , e.g.
! n
! Mn
! jendl4.0
!
! Output: E-xs tables per MT number in separate files
!
  implicit none
  integer, parameter                :: numZ=124
  integer, parameter                :: nummt=851
  integer, parameter                :: numen=400000
  integer, parameter                :: numab=10
  logical                           :: lexist
  logical                           :: flagunc
  character(len=132)                :: basedir
  character(len=132)                :: abdir
  character(len=132)                :: abfile
  character(len=132)                :: nucfile
  character(len=132)                :: key
  character(len=132)                :: libdir
  character(len=132)                :: natfile
  character(len=132)                :: headdir
  character(len=132)                :: line(100)
  character(len=30)                 :: MTfile,headfile
  character(len=20)                 :: lib     
  character(len=7)                  :: rpstring
  character(len=3)                  :: mass
  character(len=4)                  :: MTstring
  character(len=2)                  :: el
  character(len=2), dimension(numZ) :: nuc
  character(len=1)                  :: proj
  character(len=1),dimension(-1:2)  :: isochar
  integer                           :: iz
  integer                           :: i
  integer                           :: istat
  integer                           :: j
  integer                           :: jheader
  integer                           :: keyix
  integer                           :: Ncol
  integer                           :: iso
  integer                           :: k
  integer                           :: paren
  integer, dimension(numZ)          :: A(numZ)
  integer                           :: Nab
  integer                           :: kmax
  integer, dimension(numab)         :: Nen
  integer                           :: Nen0
  integer                           :: Z
  integer                           :: ia
  integer                           :: Zbeg
  integer                           :: Zend
  integer                           :: Aend
  integer                           :: Abeg
  integer                           :: MT
  real, dimension(numen,numab)      :: e
  real, dimension(numen,numab)      :: xs
  real, dimension(numen,numab)      :: xslow
  real, dimension(numen,numab)      :: xsup
  real, dimension(numen)            :: enat
  real, dimension(numen)            :: xsnat
  real, dimension(numen)            :: xsnatlow
  real, dimension(numen)            :: xsnatup
  real                              :: efac
  real                              :: EE
  real, dimension(numab)            :: ab
  real                              :: xs1
  real                              :: xs1low
  real                              :: xs1up
  real                              :: ab0
  real                              :: abtot
  real                              :: abnew
  real                              :: Emin
!
! Initialization
!
  nuc =  (/ 'H ', 'He', 'Li', 'Be', 'B ', 'C ', 'N ', 'O ', 'F ', 'Ne', &
    'Na', 'Mg', 'Al', 'Si', 'P ', 'S ', 'Cl', 'Ar', 'K ', 'Ca', 'Sc', 'Ti', 'V ', 'Cr', 'Mn', 'Fe', 'Co', 'Ni', 'Cu', 'Zn', &
    'Ga', 'Ge', 'As', 'Se', 'Br', 'Kr', 'Rb', 'Sr', 'Y ', 'Zr', 'Nb', 'Mo', 'Tc', 'Ru', 'Rh', 'Pd', 'Ag', 'Cd', 'In', 'Sn', &
    'Sb', 'Te', 'I ', 'Xe', 'Cs', 'Ba', 'La', 'Ce', 'Pr', 'Nd', 'Pm', 'Sm', 'Eu', 'Gd', 'Tb', 'Dy', 'Ho', 'Er', 'Tm', 'Yb', &
    'Lu', 'Hf', 'Ta', 'W ', 'Re', 'Os', 'Ir', 'Pt', 'Au', 'Hg', 'Tl', 'Pb', 'Bi', 'Po', 'At', 'Rn', 'Fr', 'Ra', 'Ac', 'Th', &
    'Pa', 'U ', 'Np', 'Pu', 'Am', 'Cm', 'Bk', 'Cf', 'Es', 'Fm', 'Md', 'No', 'Lr', 'Rf', 'Db', 'Sg', 'Bh', 'Hs', 'Mt', 'Ds', &
    'Rg', 'Cn', 'Nh', 'Fl', 'Mc', 'Lv', 'Ts', 'Og', 'B9', 'C0', 'C1', 'C2', 'C3', 'C4'/)
! Thome="${AUTOENDF_HOME:-$HOME}"
! Thome="${Thome%/}"     # remove final slash if present
! basedir=$Thome'/tools/autotalys/'
  basedir = '/Users/koning/tools/autotalys/'
!
! Read element
!
  read(*,'(a1)') proj
  read(*,'(a2)') el
  read(*,'(a20)') lib
  libdir=trim(basedir)//'../../libraries/'
  do iz=1,numZ
    if (el(1:2) == nuc(iz)(1:2)) then
      Z = iz
      exit
    endif
  enddo
  abdir = trim(basedir)//'../../talys/structure/abundance/'
  abfile = trim(abdir)//trim(nuc(Z))//'.abun'
  inquire (file=abfile,exist=lexist)
  if (.not.lexist) stop
  open (unit=1,status='old',file=abfile)
  ab = 0.
  Nab=0
  k=1
  do
    read(1,'(4x,i4,f11.6)', iostat = istat) A(k), ab0
    if (istat == -1) exit
    ab(k) = 0.01*ab0
    k=k+1
  enddo
  close(1)
  Nab=k-1
  Zend=Z+2
  Aend=A(Nab)+4
  isochar(-1) = ''
  isochar(0) = 'g'
  isochar(1) = 'm'
  isochar(2) = 'n'
  do MT=1,nummt
    if (MT > 51 .and. MT <= 91) cycle
    if (MT > 600 .and. MT <= 849) cycle
    if (MT == 851) then
      Zbeg = Zend-20
      Abeg = Aend-50
    else
      Zbeg = Zend
      Abeg = Aend
    endif
    do iz = Zbeg, Zend
      do ia = Abeg, Aend
        do iso = -1, 2
          if (MT.lt.851.and.iso.gt.-1) cycle
          e = 0.
          xs = 0.
          xslow = 0.
          xsup = 0.
          xsnat = 0.
          xsnatlow = 0.
          xsnatup = 0.
          Nen0=0
          kmax=1
          abtot=0.
          Emin=1.e9
          line=''
          flagunc=.false.
          do k=1,Nab
            mass='000'
            write(mass(1:3),'(i3.3)') A(k)
            headdir=proj//'/'//trim(nuc(Z))//mass//'/'//trim(lib)//'/tables/'
            headfile=proj//'-'//trim(nuc(Z))//mass
            if (MT.eq.851) then
              rpstring='000000 '
              write(rpstring(1:7),'(2i3.3,a1)') iz,ia,isochar(iso)
              MTfile=trim(headfile)//'-rp'//rpstring
              headdir=trim(headdir)//'residual/'
            else
              MTstring='000 '
              write(MTstring(1:4),'(i3.3,a1)') MT,isochar(iso)
              MTfile=trim(headfile)//'-MT'//MTstring
              headdir=trim(headdir)//'xs/'
              if (MT.ge.301.and.MT.le.449) headdir=trim(headdir)//'damage/'
              if (MT.ge.450.and.MT.le.460)  headdir=trim(headdir)//'fission/'
            endif
            MTfile=trim(MTfile)//'.'//trim(lib)
            nucfile=trim(libdir)//trim(headdir)//MTfile
            inquire (file=nucfile,exist=lexist)
            abtot=abtot+ab(k)
            if (.not.lexist) cycle
            open (unit=2,status='old',file=nucfile)
            jheader = 0  
            j = 1        
            do           
              read(2, '(a)', iostat = istat) line(j) 
              if (istat == -1) exit            
              key='title' 
              keyix=index(line(j),trim(key)) 
              if (keyix > 0) then              
                paren=index(line(j),'(') 
                if (paren > 0) line(j)='#   title: '//trim(nuc(Z))//'0'//trim(line(j)(paren:132))
              endif
              if (j > 4) then
                key='# target' 
                keyix=index(line(j-4),trim(key)) 
                if (keyix > 0) then              
                  line(j-2)='#   A: 0'
                  line(j-1)='#   nuclide: '//trim(nuc(Z))//'0'
                endif
              endif
              key='columns' 
              keyix=index(line(j),trim(key)) 
              if (keyix > 0) read(line(j)(keyix+len_trim(key)+2:80), *) Ncol
              key='entries' 
              keyix=index(line(j),trim(key)) 
              if (keyix > 0) then              
                read(line(j)(keyix+len_trim(key)+2:80), *) Nen(k)
                jheader = j + 2
                read(2, '(a)', iostat = istat) line(j+1) 
                read(2, '(a)', iostat = istat) line(j+2) 
                exit
              endif      
              j = j + 1  
            enddo        
            if (Ncol == 4) then
              do i=1,Nen(k)
                read(2,*, iostat = istat) e(i,k),xs(i,k),xslow(i,k),xsup(i,k)
                if (istat == -1) exit
              enddo
            else
              do i=1,Nen(k)
                read(2,*, iostat = istat) e(i,k),xs(i,k)
                xslow(i,k)=xs(i,k)
                xsup(i,k)=xs(i,k)
                if (istat == -1) exit
              enddo
            endif
            close(2)
            Nen(k)=i-1
            if (nen(k) > Nen0) then
              kmax=k
              Nen0=nen(k)
            endif
          enddo
          if (Nen0 == 0) cycle
          do i=1,Nen(kmax)
            enat(i)=e(i,kmax)
            EE=enat(i)
            do k=1,Nab
              abnew=ab(k)/abtot
              xs1=0.
              xs1low=0.
              xs1up=0.
              do j=1,Nen(k)-1
                if (EE.eq.e(j,k)) then
                  xs1=xs(j,k)
                  xs1low=xslow(j,k)
                  xs1up=xsup(j,k)
                  exit
                endif
                if (EE.ge.e(j,k).and.EE.le.e(j+1,k)) then
                  efac=(EE-e(j,k))/(e(j+1,k)-e(j,k))
                  xs1=xs(j,k)+efac*(xs(j+1,k)-xs(j,k))
                  xs1low=xslow(j,k)+efac*(xslow(j+1,k)-xslow(j,k))
                  xs1up=xsup(j,k)+efac*(xsup(j+1,k)-xsup(j,k))
                  exit
                endif
              enddo
              xsnat(i)=xsnat(i)+max(xs1,0.)*abnew
              xsnatlow(i)=xsnatlow(i)+max(xs1low,0.)*abnew
              xsnatup(i)=xsnatup(i)+max(xs1up,0.)*abnew
            enddo
          enddo     
          headfile=proj//'-'//trim(nuc(Z))//'000'
          if (MT.eq.851) then
            natfile=trim(headfile)//'-rp'//rpstring
          else
            natfile=trim(headfile)//'-MT'//MTstring
          endif
          natfile=trim(natfile)//'.'//trim(lib)
          open (unit=3,status='unknown',file=natfile)
          write(line(jheader-2)(14:20),'(i7)') Nen(kmax)
          do j=1,jheader
            write(3,'(a)') trim(line(j))
          enddo
          if (Ncol == 4) then
            do i=1,Nen(kmax)
              write(3,'(4es15.6)') enat(i),xsnat(i),xsnatlow(i),xsnatup(i)
            enddo
          else
            do i=1,Nen(kmax)
              write(3,'(2es15.6)') enat(i),xsnat(i)
            enddo
          endif
          close(3)
        enddo
      enddo
    enddo
  enddo
end program naturaltables
