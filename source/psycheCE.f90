program psycheCE
!
!-----------------------------------------------------------------------------------------------------------------------------------
! Purpose: Compare basic average resonance parameters produced by PSYCHE with experimental data
!
! Revision    Date      Author      Quality  Description
! ======================================================
!    1     2025-08-21   A.J. Koning    A     Original code
!-----------------------------------------------------------------------------------------------------------------------------------
!
!
! Usage: psycheCE < psyche.file > CE.out
!
! where 'psyche.file' can have any name as long as it is the output file of the PSYCHE code
!       'CE.out' can have any name and contains the C/E and chi2 values of PSYCHE results vs experiment
!
  implicit none
  integer, parameter                :: numtype=6
  logical                           :: lexist
  character(len=132)                :: string
  character(len=8), dimension(numtype) :: stringval
  character(len=132)                :: valdir
  character(len=132)                :: datafile
  integer                           :: istat
  integer                           :: Z
  integer                           :: A
  integer                           :: Liso
  integer                           :: k
  integer                           :: iz
  integer                           :: ia
  integer                           :: iL
  integer                           :: ix
  integer                           :: ix2
  integer                           :: ix3
  integer                           :: type
  integer                           :: MT
  integer                           :: Riso
  real, dimension(numtype)          :: val
  real                              :: D0
  real                              :: D1
  real                              :: S0
  real                              :: S1
  real                              :: gamgam0
  real                              :: gamgam1
  real                              :: xs
  real                              :: pp
  real                              :: xx
  real                              :: dxs
  real                              :: CE
  real                              :: chi2
  real                              :: sig
  real                              :: Ri
!
! Initialization
!
! Thome="${AUTOENDF_HOME:-$HOME}"
! Thome="${Thome%/}"     # remove final slash if present
! valdir=$Thome'/resonancetables/'
  valdir = '/Users/koning/resonancetables/'
  Liso = 0
  D0 = 0.
  gamgam0 = 0.
  S0 = 0.
  D1 = 0.
  gamgam1 = 0.
  S1 = 0.
  stringval(1) = 'D0'
  stringval(2) = 'gamgam'
  stringval(3) = 'S0'
  stringval(4) = 'D1'
  stringval(5) = 'gamgam1'
  stringval(6) = 'S1'
!
! Read PSYCHE output file
!
k = 0
Loop1:  do
    read(*,'(a)', iostat = istat) string
    if (istat == -1) exit
    k = k + 1
    if (k > 1000) exit Loop1
    ix2 = index(string,'Done PSYCHE')
    if (ix2 > 0) exit
    ix2 = index(string,'STOP PSYCHE')
    if (ix2 > 0) exit
    ix = index(string,'SECTION 451')
    if (ix > 0) then
      read(*,'(a)', iostat = istat) string
      if (istat == -1) exit
      k = k + 1
      if (k > 1000) exit Loop1
      read(string(6:8),'(i3)') Z
      read(string(13:15),'(i3)') A
    endif
    ix = index(string,'L =  0')
    if (ix > 0) then
      do
        read(*,'(a)', iostat = istat) string
        if (istat == -1) exit
        k = k + 1
        if (k > 1000) exit Loop1
        ix2 = index(string,'Done PSYCHE')
        if (ix2 > 0) exit
        ix2 = index(string,'AVERAGE GAMMA WIDTH IS')
        if (ix2 > 0) read(string(ix2+23:ix2+80),*) gamgam0
        ix2 = index(string,'AVERAGE LEVEL SPACING IS')
        if (ix2 > 0) read(string(ix2+25:ix2+80),*) D0
        ix2 = index(string,'STRENGTH FUNCTION IS  ')
        if (ix2 > 0) read(string(ix2+21:ix2+80),*) S0
        ix3 = index(string,'L =  1')
        if (ix3 > 0) then
          do
            read(*,'(a)', iostat = istat) string
            if (istat == -1) exit
            k = k + 1
            if (k > 1000) exit Loop1
            ix2 = index(string,'Done PSYCHE')
            if (ix2 > 0) exit
            ix2 = index(string,'AVERAGE GAMMA WIDTH IS')
            if (ix2 > 0) read(string(ix2+23:ix2+80),*) gamgam1
            ix2 = index(string,'AVERAGE LEVEL SPACING IS')
            if (ix2 > 0) read(string(ix2+25:ix2+80),*) D1
            ix2 = index(string,'STRENGTH FUNCTION IS  ')
            if (ix2 > 0) read(string(ix2+21:ix2+80),*) S1
            if (ix2 > 0) exit Loop1
          enddo
        endif
      enddo
    endif
  enddo Loop1
  val(1) = D0
  val(2) = gamgam0
  val(3) = S0*1.e4
  val(4) = D1
  val(5) = gamgam1
  val(6) = S1*1.e4
  MT = 0
  Riso = -1
  write(*,'(a)') "#      Quantity        Z   A  Liso MT Riso        F            chi2          File            Exp            dExp"
  do type = 1, 6
    if (val(type) > 0.) then
      sig = val(type)
      CE = 0.
      Ri = 0.
      chi2 = 0.
      datafile = trim(valdir)//'resonance/'//trim(stringval(type))//'/all/selected_'//trim(stringval(type))//'.txt'
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
            write(*,'(a,t22,5i4,5es15.5)')  trim(stringval(type)), Z, A, Liso, MT, Riso, Ri, chi2, sig, xs, dxs
            exit
          endif
        enddo
        close(1)
      endif
    endif
  enddo
end program psycheCE
