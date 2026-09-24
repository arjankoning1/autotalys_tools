program interCE
!
!-----------------------------------------------------------------------------------------------------------------------------------
! Purpose: Compare basic cross sections produced by INTER with experimental data
!
! Revision    Date      Author      Quality  Description
! ======================================================
!    1     11-07-2025   A.J. Koning    A     Original code
!-----------------------------------------------------------------------------------------------------------------------------------
!
!
! Usage: interCE < inter.file > CE.out
!
! where 'inter.file' can have any name as long as it is the output file of the INTER code
!       'CE.out' can have any name and contains the C/E and chi2 values of INTER results vs experiment
!
  implicit none
  integer, parameter                :: nummt=107
  logical                           :: lexist
  character(len=1)                  :: LFS
  character(len=1)                  :: iso
  character(len=1), dimension(-1:2) :: extiso
  character(len=2), dimension(-1:2) :: expiso
  character(len=3), dimension(nummt):: ext
  character(len=7), dimension(nummt):: reac
  character(len=132)                :: string
  character(len=132)                :: valdir
  character(len=132)                :: datafile
  character(len=132)                :: reaction
  integer                           :: istat
  integer                           :: Z
  integer                           :: A
  integer                           :: Liso
  integer                           :: Riso
  integer                           :: iz
  integer                           :: ia
  integer                           :: i
  integer                           :: iL
  integer                           :: iR
  integer                           :: MT
  real, dimension(nummt, -1:2)      :: sig2200
  real, dimension(nummt, -1:2)      :: sigEzero
  real, dimension(nummt, -1:2)      :: avsigma
  real, dimension(nummt, -1:2)      :: Gfact
  real, dimension(nummt, -1:2)      :: Resint
  real, dimension(nummt, -1:2)      :: sigfis
  real, dimension(nummt, -1:2)      :: sigE14
  real, dimension(7)                :: x
  real                              :: xs
  real                              :: pp
  real                              :: xx
  real                              :: dxs
  real                              :: CE
  real                              :: chi2
  real                              :: sig
  real                              :: sig0
  real                              :: Ri
  real                              :: G
!
! Initialization
!
! Thome="${AUTOENDF_HOME:-$HOME}"
! Thome="${Thome%/}"     # remove final slash if present
! valdir=$Thome'/resonancetables/'
  valdir = '/Users/koning/resonancetables/'
  ext='   '
  ext(1)='tot'
  ext(2)='el'
  ext(18)='nf'
  ext(102)='ng'
  ext(103)='np'
  ext(107)='na'
  extiso(-1)=' '
  extiso(0)='g'
  extiso(1)='m'
  extiso(2)='n'
  expiso(-1)='  '
  expiso(0)='-g'
  expiso(1)='-m'
  expiso(2)='-n'
  reac='   '
  reac(1)='(n,tot)'
  reac(2)='(n,el)'
  reac(18)='(n,f)'
  reac(102)='(n,g)'
  reac(103)='(n,p)'
  reac(107)='(n,a)'
  sig2200 = 0.
  sigEzero = 0.
  avsigma = 0.
  Gfact = 0.
  Resint = 0.
  sigfis = 0.
  sigE14 = 0.
!
! Read INTER output file
!
  do
    read(*,'(a)', iostat = istat) string
    if (istat == -1) exit
    if (string(1:8) == '   Z   A') exit
  enddo
  read(*,'(a)') string
  do
    read(*,'(2i4,1x,a1,6x,a1,1x,i4,12x,2e12.5,e11.4,f8.5,1x,3e12.5)', iostat = istat) Z, A, iso, LFS, MT, (x(i), i = 1,7)
    if (istat == -1) exit
    Liso = 0
    if (iso == 'g') Liso = 0
    if (iso == 'm') Liso = 1
    if (iso == 'n') Liso = 2
    Riso = -1
    if (LFS == 'g') Riso = 0
    if (LFS == 'm') Riso = 1
    if (LFS == 'n') Riso = 2
    if (LFS == '*') cycle
    sig2200(MT, Riso) = x(1)
    sigEzero(MT, Riso) = x(2)
    avsigma(MT, Riso) = x(3)
    Gfact(MT, Riso) = x(4)
    Resint(MT, Riso) = x(5)
    sigfis(MT, Riso) = x(6)
    sigE14(MT, Riso) = x(7)
    if (Riso == 0) then
      sig2200(MT, 1) = max(sig2200(MT, -1) - sig2200(MT, 0), 0.)
      sigEzero(MT, 1) = max(sigEzero(MT, -1) - sigEzero(MT, 0), 0.)
      avsigma(MT, 1) = max(avsigma(MT, -1) - avsigma(MT, 0), 0.)
      Gfact(MT, 1) = max(Gfact(MT, -1) -Gfact(MT, 0), 0.)
      Resint(MT, 1) = max(Resint(MT, -1) - Resint(MT, 0), 0.)
      sigfis(MT, 1) = max(sigfis(MT, -1) - sigfis(MT, 0), 0.)
      sigE14(MT, 1) = max(sigE14(MT, -1) - sigE14(MT, 0), 0.)
    endif
  enddo
  write(*,'(a)') &
&"#      Quantity        Z   A  Liso MT Riso        F            chi2          File            Exp            dExp         G-factor"
  do MT = 1, 107
    if (MT == 1 .or. MT == 2 .or. MT == 18 .or. MT == 102 .or. MT== 103 .or. MT ==107) then
      do Riso = -1, 2
        if (sig2200(MT, Riso) > 0.) then
          sig = sig2200(MT, Riso)
          G = Gfact(MT, Riso)
          CE = 0.
          Ri = 0.
          chi2 = 0.
          reaction = trim(ext(MT))//trim(expiso(Riso))
          datafile = trim(valdir)//'thermal/'//trim(reaction)//'/all/selected_'//trim(reaction)//'.txt'
          inquire (file=datafile,exist=lexist)
          if (lexist) then
            open (unit=1,status='old',file=datafile)
            do
              read(1,'(a)', iostat = istat) string
              if (istat == -1) exit
              if (string(1:1) == '#') cycle
              read(string,*) iz, ia, iL, xs, dxs
              if (iz == Z .and. ia == A .and. iL == Liso) then
                if (xs > 0.) then
                  CE = sig / xs
                  if (dxs > 0.) then
                    chi2 = ( (sig - xs) / dxs ) ** 2.
                    xx = (sig - xs)/(dxs*sqrt(2.))
                    if (sig > xs) then
                      pp = erf(xx)
                    else  
                      pp = -erf(xx)
                    endif 
                    Ri = 1. + (CE-1.)*pp
                  else    
                    Ri = CE 
                  endif
                endif
                write(*,'("Thermal ",a7,a1," c.s.",5i4,6es15.5)') &
 &                reac(MT), extiso(Riso), Z, A, Liso, MT, Riso, Ri, chi2, sig, xs, dxs, G
                exit
              endif
            enddo
            close(1)
          endif
        endif
      enddo
    endif
  enddo
  do MT = 1, 107
    if (MT == 18 .or. MT == 102) then
      do Riso = -1, 2
        if (Resint(MT, Riso) > 0.) then
          sig = Resint(MT, Riso)
          G = Gfact(MT, Riso)
          CE = 0.
          Ri = 0.
          chi2 = 0.
          if (MT == 18) then
            datafile = trim(valdir)//'resonance/If/all/selected_If.txt'
          else
            datafile = trim(valdir)//'resonance/Ig'//trim(expiso(Riso))//'/all/selected_Ig'//trim(expiso(Riso))//'.txt'
          endif
          inquire (file=datafile,exist=lexist)
          if (lexist) then
            open (unit=1,status='old',file=datafile)
            do
              read(1,'(a)', iostat = istat) string
              if (istat == -1) exit
              if (string(1:1) == '#') cycle
              read(string,*) iz, ia, iL, xs, dxs
              if (iz == Z .and. ia == A) then
                if (xs > 0.) then
                  CE = sig / xs
                  if (dxs > 0.) then
                    chi2 = ( (sig - xs) / dxs ) ** 2.
                    xx = (sig - xs)/(dxs*sqrt(2.))
                    if (sig > xs) then
                      pp = erf(xx)
                    else  
                      pp = -erf(xx)
                    endif 
                    Ri = 1. + (CE-1.)*pp
                  else    
                    Ri = CE 
                  endif
                endif
                write(*,'("Res Int ",a7,a1,5x,5i4,6es15.5)')  reac(MT), extiso(Riso), Z, A, Liso, MT, Riso, Ri, chi2, sig, xs, &
 &                dxs, G
                exit
              endif
            enddo
            close(1)
          endif
        endif
      enddo
    endif
  enddo
  MT = 102
  do Riso = -1, 2
    if (sigEzero(MT, Riso) > 0.) then
      sig = avsigma(MT, Riso)
      sig0 = sigEzero(MT, Riso)
      if (sig0 > 0.) then
        G = sig / sig0
      else
        G = 0.
      endif
      CE = 0.
      Ri = 0.
      chi2 = 0.
      datafile = trim(valdir)//'macs/ng'//trim(expiso(Riso))//'/all/selected_macs'//trim(expiso(Riso))//'.txt'
      inquire (file=datafile,exist=lexist)
      if (lexist) then
        open (unit=1,status='old',file=datafile)
        do
          read(1,'(a)', iostat = istat) string
          if (istat == -1) exit
          if (string(1:1) == '#') cycle
          read(string,*) iz, ia, iL, xs, dxs
          if (iz == Z .and. ia == A .and. iL == Liso) then
            if (xs > 0.) then
              CE = sig / xs
              if (dxs > 0.) then
                chi2 = ( (sig - xs) / dxs ) ** 2.
                xx = (sig - xs)/(dxs*sqrt(2.))
                if (sig > xs) then
                  pp = erf(xx)
                else  
                  pp = -erf(xx)
                endif 
                Ri = 1. + (CE-1.)*pp
              else    
                Ri = CE 
              endif
            endif
            write(*,'("MACS    ",a7,a1," c.s.",5i4,6es15.5)') reac(MT), extiso(Riso), Z, A, Liso, MT, Riso, Ri, chi2, sig, xs, &
 &            dxs, G
            exit
          endif
        enddo
        close(1)
      endif
    endif
  enddo
end program interCE
