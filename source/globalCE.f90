program globalCE
!
!-----------------------------------------------------------------------------------------------------------------------------------
! Purpose: Statistics of basic cross sections for whole library, file vs. experimental data
!
! Revision    Date      Author      Quality  Description
! ======================================================
!    1     2025-09-06   A.J. Koning    A     Original code
!-----------------------------------------------------------------------------------------------------------------------------------
!
!
! Usage: globalCE < CEfile 
!
! where 'CEfile' is the concatenated output of all '.CE files' (e.g. n-Fe056.endfb8.0.CE)  in the check/ subdirectories.
!          hence e.g. the endfB8.1.CE files for all isotopes are concatenated into one file 'CEfile'
! CE and chi2 statistics will be collected in various output files with suggestive names
!
  implicit none
  integer, parameter                        :: numZ=124
  integer, parameter                        :: numA=340
  integer, parameter                        :: numbin=100
  integer, parameter                        :: numtype=15
  logical, dimension(-1:2)                  :: isoexist
  character(len=2), dimension(-1:2)         :: iso
  character(len=10), dimension(numtype)     :: ext
  character(len=20), dimension(numtype)     :: reac
  character(len=132)                        :: string
  character(len=132)                        :: outfile
  integer                                   :: istat
  integer                                   :: Z
  integer                                   :: A
  integer                                   :: Liso
  integer                                   :: Riso
  integer                                   :: MT
  integer                                   :: N
  integer                                   :: type
  integer                                   :: N5
  integer                                   :: N20
  integer                                   :: N50
  integer                                   :: i
  integer                                   :: Nbin
  real, dimension(0:numbin)                 :: bin
  integer, dimension(0:numbin)              :: CEbin
  real, dimension(numZ, 0:numA, -1:2, -1:2) :: CEfile
  real, dimension(numZ, 0:numA, -1:2, -1:2) :: chi2file
  real, dimension(numZ, 0:numA, -1:2, -1:2) :: xsTfile
  real, dimension(numZ, 0:numA, -1:2, -1:2) :: xsEfile
  real, dimension(numZ, 0:numA, -1:2, -1:2) :: dxsEfile
  real, dimension(numZ, 0:numA, -1:2, -1:2) :: Gfile
  real                                      :: xsT
  real                                      :: xsE
  real                                      :: dxsE
  real                                      :: CE
  real                                      :: chi2
  real                                      :: relerr
  real                                      :: sumchi2
  real                                      :: sumCE
  real                                      :: G
  real                                      :: F
  real                                      :: F5
  real                                      :: F20
  real                                      :: F50
!
! Initialization
!
  do i = 0, numbin
    bin(i) = i * 0.02
  enddo
  iso(-1) = '  '
  iso(0) = '_g'
  iso(1) = '_m'
  iso(2) = '_n'
  ext(1) = 'therm_tot'
  ext(2) = 'therm_el'
  ext(3) = 'therm_ng'
  ext(4) = 'therm_nf'
  ext(5) = 'therm_np'
  ext(6) = 'therm_na'
  ext(7) = 'MACS'
  ext(8) = 'Ig'
  ext(9) = 'If'
  ext(10) = 'D0'
  ext(11) = 'gamgam'
  ext(12) = 'S0'
  ext(13) = 'D1'
  ext(14) = 'gamgam1'
  ext(15) = 'S1'
  reac(1) = 'Thermal (n,tot)'
  reac(2) = 'Thermal (n,el)'
  reac(3) = 'Thermal (n,g)'
  reac(4) = 'Thermal (n,f)'
  reac(5) = 'Thermal (n,p)'
  reac(6) = 'Thermal (n,a)'
  reac(7) = 'MACS    (n,g)'
  reac(8) = 'Res Int (n,g)'
  reac(9) = 'Res Int (n,f)'
  reac(10) = 'D0'
  reac(11) = 'gamgam'
  reac(12) = 'S0'
  reac(13) = 'D1'
  reac(14) = 'gamgam1'
  reac(15) = 'S1'
!
! Read concatenated CE file
!
  do type = 1, numtype
    CEfile = 0.
    chi2file = 0.
    xsTfile = 0.
    xsEfile = 0.
    dxsEfile = 0.
    Gfile = 0.
    isoexist = .false.
    do
      read(*,'(a)', iostat = istat) string
      if (istat == -1) exit
      if (string(1:1) == '#') cycle
      G = 1.
      if (type <= 7) then
        read(string(22:132),*, iostat = istat) Z, A, Liso, MT, Riso, CE, chi2, xsT, xsE, dxsE, G
      else
        read(string(22:132),*, iostat = istat) Z, A, Liso, MT, Riso, CE, chi2, xsT, xsE, dxsE
      endif
      if (trim(string(1:15)) == trim(reac(type))) then
!       if (MT == 0 .or. MT == 18 .or. MT == 102) then
          CEfile(Z, A, Liso, Riso) = CE
          chi2file(Z, A, Liso, Riso) = chi2
          xsTfile(Z, A, Liso, Riso) = xsT
          xsEfile(Z, A, Liso, Riso) = xsE
          dxsEfile(Z, A, Liso, Riso) = dxsE
          Gfile(Z, A, Liso, Riso) = G
          isoexist(Riso) = .true.
!       endif
      endif
    enddo
    rewind 5
!
! Histograms, Frms and output
!
    do Riso = -1, 2
      if (.not. isoexist(Riso)) cycle
      outfile='global.'//trim(ext(type))//trim(iso(Riso))
      write(6,'(" Global file: ",a)') trim(outfile)
      open (unit=1,status='unknown',file=outfile)
      if (type <= 7) then
        write(1,'(a)') &
 &  "#  Z   A Liso       CE            chi2          File            Exp             dExp   Relative error (%)   G-factor"
      else
        write(1,'(a)') "#  Z   A Liso       CE            chi2          File            Exp             dExp   Relative error (%)"
      endif
      sumCE = 0.
      sumchi2 = 0.
      N = 0
      N5 = 0
      N20 = 0
      N50 = 0
      CEbin = 0
      do Z = 1, numZ
        do A = 1, numA
          do Liso = 0, 2
            if (CEfile(Z, A, Liso, Riso) > 0.) then
              CE = CEfile(Z, A, Liso, Riso)
              chi2 = chi2file(Z, A, Liso, Riso)
              xsT = xsTfile(Z, A, Liso, Riso)
              xsE = xsEfile(Z, A, Liso, Riso)
              dxsE = dxsEfile(Z, A, Liso, Riso)
              G = Gfile(Z, A, Liso, Riso)
              if (xse > 0.) then
                relerr = 100. * dxsE / xsE
              else
                relerr = 0.
              endif
              if (type <= 7) then
                write(1, '(3i4,5es15.5,f15.5,es15.5)') Z, A, Liso, CE, chi2, xsT, xsE, dxsE, relerr, G
              else
                write(1, '(3i4,5es15.5,f15.5)') Z, A, Liso, CE, chi2, xsT, xsE, dxsE, relerr
              endif
              if (CE >= 1.) then
                f = CE
              else
                f = 1. / CE
              endif
              if (f <= 1.2) then
                sumCE = sumCE + f
                sumchi2 = sumchi2 + chi2
                N20 = N20 + 1
              endif
              if (f <= 1.05) N5 = N5 + 1
              if (f <= 1.50) N50 = N50 + 1
              N = N + 1
              if (CE >= bin(numbin)) then
                CEbin(numbin) = CEbin(numbin) + 1
              else
                call locate(bin, 0, numbin, CE, Nbin)
                CEbin(Nbin) = CEbin(Nbin) + 1
              endif
            endif
          enddo
        enddo
      enddo
      close(1)
      F = sumCE / N20
      chi2 = sumchi2 / N20
      F5 = real(N5) / N
      F20 = real(N20) / N
      F50 = real(N50) / N
      outfile='bin.'//trim(ext(type))//trim(iso(Riso))
      write(6,'(" bin file: ",a)') trim(outfile)
      open (unit=2,status='unknown',file=outfile)
      write(2, '("# F (< 20%) N    N < 5%       N < 20%      N < 50%      Chi-2 (< 20%)")') 
      write(2, '("#",f8.3,i5,3(i5,"(",f5.3,") "),f8.3)') F, N, N5, F5, N20, F20, N50, F50, chi2
      write(2,'("#  bin    N")')
      do i = 0, numbin
        write(2,'(f7.2, i4)') bin(i), CEbin(i)
      enddo
      close(2)
    enddo
  enddo
end program globalCE
subroutine locate(xx, ib, ie, x, j)
!
!-----------------------------------------------------------------------------------------------------------------------------------
! Purpose: Find value in ordered table
!
! Revision    Date      Author      Quality  Description
! ======================================================
!    1     01-01-2019   A.J. Koning    A     Original code
!-----------------------------------------------------------------------------------------------------------------------------------
!
! *** Declaration of local data
!
  implicit none
  logical   :: ascend              ! logical for ascending values
  integer   :: ib                  ! counter
  integer   :: ie                  ! counter
  integer   :: j                   ! counter
  integer   :: jl                  ! lower value
  integer   :: jm                  ! middle value
  integer   :: ju                  ! higher value
  real      :: x                   ! help variable
  real      :: xx(0:ie)            ! x value
!
! ******************************* Search *******************************
!
! Find j such that xx(j) <= x < xx(j+1) or xx(j) > x >= xx(j+1)
!
  j = 0
  if (ib > ie) return
  jl = ib - 1
  ju = ie + 1
  ascend = xx(ie) >= xx(ib)
  10  if (ju - jl > 1) then
    jm = (ju + jl) / 2
    if (ascend.eqv.(x >= xx(jm))) then
      jl = jm
    else
      ju = jm
    endif
    goto 10
  endif
  if (x == xx(ib)) then
    j = ib
  else if (x == xx(ie)) then
    j = ie - 1
  else
    j = jl
  endif
  return
end subroutine locate
! Copyright A.J. Koning 2019
