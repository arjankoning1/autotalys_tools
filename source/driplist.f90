program driplist
! 
!-----------------------------------------------------------------------------------------------------------------------------------
! Purpose   : Makes nuclide list from dripline to dripline
!
! Author    : Arjan Koning
!
! 2022-02-23: Original code
!-----------------------------------------------------------------------------------------------------------------------------------
!
!-----------------------------------------------------------------------------------------------------------------------------------
! Definition of single and double precision variables
!-----------------------------------------------------------------------------------------------------------------------------------
!
  implicit none
  integer, parameter :: sgl = selected_real_kind(6,37)   ! single precision kind
!
! *** Declaration of local data
!
  integer, parameter :: numZ=124                 ! maximal number of protons
  integer, parameter :: numA=414                 ! maximal number of nucleons
  integer, parameter :: numnuc=40000             ! maximum number of nuclides
  logical            :: lexist                   ! logical to determine existence
  logical            :: ZAexist(numZ, 0:numA)    ! logical for Z, A nucleus
  character(len=1)   :: isochar(numnuc)          ! symbol of isomer
  character(len=2)   :: nuc(numZ)                ! symbol of nucleus
  character(len=2)   :: nuclide(numnuc)          ! nuclide symbol
  character(len=2)   :: nuctemp                  !
  character(len=2)   :: expchar(numnuc)          !
  character(len=3)   :: Achar                    !
  character(len=7)   :: abchar                   ! help variable
  character(len=7)   :: levelchar                ! help variable
  character(len=132) :: abfile                   ! isotopic abundance file
  character(len=132) :: levelfile                ! discrete level file
  character(len=132) :: exphome                  !
  character(len=132) :: basedir                  ! home directory
  character(len=132) :: nucdir                   !
  integer            :: A(numnuc)                ! mass number of target nucleus
  integer            :: AA                       ! mass number of residual nucleus
  integer            :: Atemp                    !
  integer            :: heavy(numZ)              ! heaviest isotope per element
  integer            :: i                        ! level
  integer            :: ia                       ! mass number from abundance table
  integer            :: iso                      ! counter for isotope
  integer            :: isoend                   !
  integer            :: isojump                  !
  integer            :: istat                    !
  integer            :: itau                     !
  integer            :: iz                       ! charge number of residual nucleus
  integer            :: izbeg                    ! first Z number
  integer            :: izend                    ! last Z number
  integer            :: j                        ! counter
  integer            :: k                        ! designator for particle
  integer            :: Krand                    !
  integer            :: L                        ! counter for Legendre coefficients
  integer            :: levmax                   ! maximum number of discrete levels for isomer
  integer            :: light(numZ)              ! mass number of lightest stable isotope
  integer            :: Lis                      ! isomer number
  integer            :: Liso(numnuc)             ! isomeric number of target
  integer            :: Lisotemp                 !
  integer            :: Ltarget(numnuc)          ! excited level of target
  integer            :: Ltargettemp              !
  integer            :: mainis(numZ)             ! main isotope per element
  integer            :: nbranch                  ! number of branching levels
  integer            :: nlev                     ! number of levels for nucleus
  integer            :: nlevels                  !
  integer            :: Nmaxrand                 !
  integer            :: nnn                      ! number of levels in discrete level file
  integer            :: Nrand(numnuc)            !
  integer            :: numiso                   ! maximum number of isotopes per element
  integer            :: numstab                  !
  integer            :: Z(numnuc)                ! charge number of target nucleus
  integer            :: Ztemp                    !
  real(sgl)          :: ab(numnuc)               ! isotopic abundance
  real(sgl)          :: ab0                      !
  real(sgl)          :: abskip                   ! abundance (in %) above which calculations are skipped
!                                                  (helpful to restart a calculation from where it stopped)
  real(sgl)          :: abtemp                   !
  real(sgl)          :: abun                     ! abundance (in %) above which calculations are performed
  real(sgl)          :: isomer                   ! definition of isomer in seconds
  real(sgl)          :: lifetime                 ! life time above which calculations are performed
!                                         e.g.     lifetime=1.e35 (only stable nuclides)
!                                                  lifetime=3.1536e9 (100 years)
!                                                  lifetime=1000.    (1000 seconds)
!                                                  lifetime=1.e-6    (basically every bound nucleus)
!                                                  lifetime=0.       (everything in the mass table)
  real(sgl)          :: tau(numnuc)              ! lifetime of state in seconds
  real(sgl)          :: tau0                     !
  real(sgl)          :: tautemp                  !
  real(sgl)          :: timeskip                 ! life time above which calculations are skipped
!                                                  (helpful to restart a calculation from where it stopped)
!
! ********************** Initializations *******************************
!
  nuc =                       (/ 'H ', 'He', 'Li', 'Be', 'B ', 'C ', 'N ', 'O ', 'F ', 'Ne', &
 &  'Na', 'Mg', 'Al', 'Si', 'P ', 'S ', 'Cl', 'Ar', 'K ', 'Ca', 'Sc', 'Ti', 'V ', 'Cr', 'Mn', 'Fe', 'Co', 'Ni', 'Cu', 'Zn', &
 &  'Ga', 'Ge', 'As', 'Se', 'Br', 'Kr', 'Rb', 'Sr', 'Y ', 'Zr', 'Nb', 'Mo', 'Tc', 'Ru', 'Rh', 'Pd', 'Ag', 'Cd', 'In', 'Sn', &
 &  'Sb', 'Te', 'I ', 'Xe', 'Cs', 'Ba', 'La', 'Ce', 'Pr', 'Nd', 'Pm', 'Sm', 'Eu', 'Gd', 'Tb', 'Dy', 'Ho', 'Er', 'Tm', 'Yb', &
 &  'Lu', 'Hf', 'Ta', 'W ', 'Re', 'Os', 'Ir', 'Pt', 'Au', 'Hg', 'Tl', 'Pb', 'Bi', 'Po', 'At', 'Rn', 'Fr', 'Ra', 'Ac', 'Th', &
 &  'Pa', 'U ', 'Np', 'Pu', 'Am', 'Cm', 'Bk', 'Cf', 'Es', 'Fm', 'Md', 'No', 'Lr', 'Rf', 'Db', 'Sg', 'Bh', 'Hs', 'Mt', 'Ds', &
 &  'Rg', 'Cn', 'Nh', 'Fl', 'Mc', 'Lv', 'Ts', 'Og', 'B9', 'C0', 'C1', 'C2', 'C3', 'C4'/)
  mainis =                       (/ 1,  4,  7,  9, 11, 12, 14, 16, 19, 20, &
 &   23, 24, 27, 28, 31, 32, 35, 40, 39, 40, 45, 48, 51, 52, 55, 56, 59, 58, 63, 64, &
 &   69, 74, 75, 80, 81, 84, 85, 88, 89, 90, 93, 98, 99, 102, 103, 108, 107, 114, 115, 120, &
 &  121, 130, 127, 132, 133, 138, 139, 140, 141, 142, 145, 152, 153, 158, 159, 164, 165, 166, 169, 174, &
 &  175, 180, 181, 184, 187, 192, 193, 195, 197, 202, 205, 208, 209, 209, 210, 222, 223, 226, 227, 232, &
 &  231, 238, 238, 242, 242, 247, 247, 250, 254, 257, 258, 260, 262, 264, 266, 268, 270, 272, 274, 273, &
 &  293, 294, 295, 306, 307, 308, 331, 334, 336, 343, 346, 347, 348, 349 /)
  light =                       (/ 1,   3,   4,   5,   7,   8,  10,  12,  14,  16, &
 &   18,  20,  21,  22,  23,  24,  25,  27,  29,  30, 32,  34,  36,  38,  40,  42,  44,  46,  48,  51, &
 &   53,  55,  57,  59,  61,  63,  66,  68,  70,  72, 74,  77,  79,  81,  83,  86,  88,  90,  92,  94, &
 &   97,  99, 101, 103, 106, 108, 110, 113, 115, 118, 120, 123, 125, 128, 130, 133, 136, 138, 141, 143, &
 &  146, 149, 151, 154, 156, 159, 162, 165, 167, 170, 173, 175, 178, 181, 184, 186, 189, 192, 195, 198, &
 &  200, 203, 206, 209, 212, 215, 218, 221, 224, 226, 229, 232, 235, 238, 241, 244, 247, 250, 253, 256, &
 &  253, 254, 256, 274, 276, 278, 280, 282, 284, 286, 287, 288, 289, 290 /)
  heavy =                       (/ 6,  10,  12,  14,  19,  22,  24,  34,  38,  41, &
 &   44,  47,  51,  54,  57,  60,  63,  67,  70,  73, 76,  80,  83,  86,  89,  92,  96,  99, 102, 105, &
 &  108, 112, 115, 118, 121, 124, 128, 131, 134, 137, 140, 144, 147, 150, 153, 156, 160, 163, 166, 169, &
 &  172, 176, 179, 182, 185, 189, 192, 195, 198, 201, 205, 208, 211, 214, 218, 221, 224, 227, 230, 234, &
 &  237, 240, 243, 247, 250, 253, 256, 260, 263, 266, 269, 273, 276, 279, 282, 286, 289, 292, 295, 299, &
 &  302, 305, 308, 312, 315, 318, 321, 325, 328, 331, 334, 337, 340, 343, 346, 349, 352, 355, 358, 360, &
 &  381, 382, 383, 384, 385, 386, 387, 388, 409, 410, 411, 412, 413, 414 /)
!
! Input
!
  izbeg = 12
  izend = 84
  lifetime = 1.e35
  abun = 0.
  abskip = 101.
  timeskip = 1.e38
  read(*, '(i3)') izbeg
  read(*, '(i3)') izend
  read(*, '(i3)') levmax
  read(*, '(e20.10)') abun
  read(*, '(e20.10)') lifetime
  read(*, '(e20.10)') abskip
  read(*, '(e20.10)') timeskip
  if (abskip == 0.) abskip = 101.
  if (timeskip == 0.) timeskip = 1.e38
  ZAexist = .false.
  ab = 0.
  tau = 0.
  Nrand = 10
! Thome="${AUTOENDF_HOME:-$HOME}"
! Thome="${Thome%/}"     # remove final slash if present
! basedir=$Thome'/tools/autotalys/'
  basedir = '/Users/koning/tools/autotalys/'
!
! ******************* Set order of isotopes ****************************
!
! A. Start with natural isotopes in order of descending abundance
!
  isomer = min(lifetime, 1.)
  i = 0
  do iz = izbeg, izend
!
! Natural nuclides
!
    if (abun == 100.) then
      i = i + 1
      Z(i) = iz
      ia = 0
      A(i) = 0
      Ltarget(i) = 0
      Liso(i) = 0
      Nrand(i) = 0
      ab(i) = abun
      nuclide(i) = nuc(iz)
      ZAexist(iz, ia) = .true.
    else
!
! Get the isotopes from the abundance table
!
      abchar = trim(nuc(iz))//'.abun'
      abfile = trim(basedir)//'../../talys/structure/abundance/'//abchar
      inquire (file = abfile, exist = lexist)
      if ( .not. lexist) cycle
      open (unit = 1, status = 'old', file = abfile)
      do
        read(1, '(4x, i4, f11.6)', iostat = istat) ia, ab0
        if (istat == -1) exit
        i = i + 1
        Z(i) = iz
        A(i) = ia
        ZAexist(iz, ia) = .true.
        if (iz == 73 .and. ia == 180) then
          Ltarget(i) = 2
          Liso(i) = 1
          ZAexist(iz, ia) = .false.
        else
          Ltarget(i) = 0
          Liso(i) = 0
        endif
        ab(i) = ab0
        nuclide(i) = nuc(iz)
      enddo
      close (unit = 1)
    endif
  enddo
  numiso = i
!
! Sort abundances in descending order
!
  do i = 1, numiso
    do j = i, numiso
      if (ab(i) >= ab(j)) cycle
      Ztemp = Z(i)
      Atemp = A(i)
      abtemp = ab(i)
      Ltargettemp = Ltarget(i)
      Lisotemp = Liso(i)
      nuctemp = nuclide(i)
      Z(i) = Z(j)
      A(i) = A(j)
      ab(i) = ab(j)
      Ltarget(i) = Ltarget(j)
      Liso(i) = Liso(j)
      nuclide(i) = nuclide(j)
      Z(j) = Ztemp
      A(j) = Atemp
      ab(j) = abtemp
      Ltarget(j) = Ltargettemp
      Liso(j) = Lisotemp
      nuclide(j) = nuctemp
    enddo
  enddo
  numstab = numiso
!
! B. Unstable nuclides.
!    Start at main isotope and hop from left to right until the drip
!    line is reached.
!
  i = numiso
  if (lifetime < 1.e35) then
    isoend = 100
    do iso = 0, isoend
      isojump = max(2 * iso, 1)
      do j = - iso, iso, isojump
        do iz = izbeg, izend
          ia = mainis(iz) + j
          if (ia < 1) cycle
!
! Check whether the nuclide exists in the masstable
!
          if (ia < light(iz) .or. ia > heavy(iz)) cycle
!
! Include targets with a lifetime that exceeds lifetime seconds. Search the discrete level database for these targets.
! Skip natural isotopes, they have been stored already.
!
          levelchar = trim(nuc(iz))//'.lev '
          levelfile = trim(basedir)//'../../talys/structure/levels/exp/'// levelchar
          inquire (file = levelfile, exist = lexist)
          if  (.not. lexist) cycle
          open (unit = 3, status = 'old', file = levelfile)
          do
            read(3, '(4x, i4, 2i5)', iostat = istat) AA, nlevels, nnn
            if (istat /= 0) exit
            if (AA /= ia) then
              do l = 1, nlevels
                read(3, '()')
              enddo
              cycle
            endif
            nlev = min(nnn, levmax)
            Lis = 0
            do l = 0, nlev
              read(3, '(26x, i3, 19x, e9.3)') nbranch, tau0
              do k = 1, nbranch
                read(3, '()')
              enddo
              if (tau0 < isomer) cycle
              if (l > 0. .and. tau0 == 0.) cycle
              if (iz == 73 .and. ia == 180 .and. l == 2) cycle
              if (l == 0 .and. ZAexist(iz, ia)) cycle
              if (l > 0) Lis = Lis + 1
              if (tau0 < lifetime) cycle
!
! Increase number of isotope
!
              ZAexist(iz, ia) = .true.
              i = i + 1
              Z(i) = iz
              A(i) = ia
              Ltarget(i) = l
              Liso(i) = Lis
              tau(i) = tau0
              nuclide(i) = nuc(iz)
            enddo
          enddo
          close (unit = 3)
          if ( .not. ZAexist(iz, ia) .and. lifetime == 0.) then
            i = i + 1
            Z(i) = iz
            A(i) = ia
            Ltarget(i) = 0
            Liso(i) = 0
            tau(i) = 0.
            nuclide(i) = nuc(iz)
          endif
        enddo
      enddo
    enddo
    numiso = i
!
! Sort lifetimes in descending order
!
    do i = numstab + 1, numiso
      do j = i, numiso
        if (tau(i) >= tau(j)) cycle
        Ztemp = Z(i)
        Atemp = A(i)
        tautemp = tau(i)
        Ltargettemp = Ltarget(i)
        Lisotemp = Liso(i)
        nuctemp = nuclide(i)
        Z(i) = Z(j)
        A(i) = A(j)
        tau(i) = tau(j)
        Ltarget(i) = Ltarget(j)
        Liso(i) = Liso(j)
        nuclide(i) = nuclide(j)
        Z(j) = Ztemp
        A(j) = Atemp
        tau(j) = tautemp
        Ltarget(j) = Ltargettemp
        Liso(j) = Lisotemp
        nuclide(j) = nuctemp
      enddo
    enddo
  endif
!
! Set character for isomer
!
  do i = 1, numiso
    isochar(i) = ' '
    if (Liso(i) == 1) isochar(i) = 'm'
    if (Liso(i) == 2) isochar(i) = 'n'
    if (Liso(i) == 3) isochar(i) = 'o'
    if (Liso(i) == 4) isochar(i) = 'p'
    if (Liso(i) == 5) isochar(i) = 'q'
    if (Liso(i) == 6) isochar(i) = 'r'
    if (Liso(i) == 7) isochar(i) = 's'
    if (Liso(i) == 8) isochar(i) = 't'
    if (Liso(i) == 9) isochar(i) = 'u'
    if (Liso(i) == 10) isochar(i) = 'v'
  enddo
!
! Check existence of experimental data
!
  exphome = trim(basedir)//'../../libraries/n/'
  do i = 1, numiso
    write(Achar(1:3), '(i3.3)') A(i)
    nucdir = trim(exphome) //trim(nuclide(i)) //Achar // trim(isochar(i))//'/'//'exfor/xs/xslist'
    inquire (file = nucdir, exist = lexist)
    if (lexist) then
      expchar(i) = '_E'
    else
      expchar(i) = '  '
    endif
  enddo
!
! ************ Set number of random runs *******************************
!
! Number of random runs decreases for decreasing abundance or lifetime.
!
  do i = 1, numstab
    if (ab(i) >= 80.) Nrand(i) = 50
    if (ab(i) >= 50. .and. ab(i) < 80.) Nrand(i) = 50
    if (ab(i) >= 20. .and. ab(i) < 50.) Nrand(i) = 30
    if (ab(i) >= 10. .and. ab(i) < 20.) Nrand(i) = 20
    if (ab(i) < 10.) Nrand(i) = 10
  enddo
  do i = numstab + 1, numiso
    if (tau(i) >= 3.1536e7) Nrand(i) = 10
    if (tau(i) >= 1000. .and. tau(i) < 3.1536e7) Nrand(i) = 5
    if (tau(i) < 1000.) Nrand(i) = 3
  enddo
!
! Global multiplier depending on available computer power
!
  Krand = 2
  do i = 1, numiso
    Nrand(i) = Krand * Nrand(i)
  enddo
!
! Number of random runs for specific nuclides can be set individually. 
! The calculation time for a single run of U235,238 and Pu239 is rather long. 
! Important nuclides (which do not require a long calculation time) may deserve the maximum number of random runs.
!
  Nmaxrand = 300
  do i = 1, numstab
    if (Z(i) <= 42) Nrand(i) = Nmaxrand
    if (Z(i) == 74) Nrand(i) = Nmaxrand
    if (Z(i) == 82) Nrand(i) = Nmaxrand
    if (Z(i) == 83) Nrand(i) = Nmaxrand
    if (Z(i) == 92 .and. A(i) == 235) Nrand(i) = 20
    if (Z(i) == 92 .and. A(i) == 238) Nrand(i) = 20
    if (Z(i) == 94 .and. A(i) == 239) Nrand(i) = 20
  enddo
!
! ******************* Make isotope list ********************************
!
  open (unit = 8, status = 'unknown', file = 'nuclides')
  open (unit = 9, status = 'unknown', file = 'nuc.list')
  open (unit = 10, status = 'unknown', file = 'nuclides.sort')
  write(10, '("#Rank   Z   A   L El  A  L   Abundance", " Half-life(sec.)")')
  do i = 1, numstab
    if (abun < 100. .and. ab(i) <= abun) cycle
    if (ab(i) > abskip) cycle
    write(*, '(a2, 3i4, f12.5)') nuclide(i), A(i), Ltarget(i), Liso(i), ab(i)
    if (nuclide(i)(2:2) == " ") then
      write(8, '(a1, "_", i3.3, "_", i3.3, "_", i3.3, "_1_", i3.3, "_", i3.3, a2)') &
 &      nuclide(i)(1:1), A(i), Ltarget(i), Liso(i), int(ab(i)), Nrand(i), expchar(i)
    else
      write(8, '(a2, "_", i3.3, "_", i3.3, "_", i3.3, "_1_", i3.3, "_", i3.3, a2)') nuclide(i), A(i), Ltarget(i), Liso(i), &
 &      int(ab(i)), Nrand(i), expchar(i)
    endif
    write(9, '(a2, 1x, i3.3, 1x, a1)') nuclide(i), A(i), isochar(i)
    write(10, '(i5, 3i4, 1x, a2, 1x, i3.3, 1x, a1, f12.6)') i, Z(i), A(i), Liso(i), nuclide(i), A(i), isochar(i), ab(i)
  enddo
  do i = numstab + 1, numiso
    if (tau(i) > timeskip) cycle
    write(*, '(a2, 3i4, 1p, e12.5)') nuclide(i), A(i), Ltarget(i), Liso(i), tau(i)
    itau = int(min(tau(i), 99999990.))
    if (nuclide(i)(2:2) == " ") then
      write(8, '(a1, "_", i3.3, "_", i3.3, "_", i3.3, "_0_", i8.8, "_", i3.3, a2)') &
 &      nuclide(i)(1:1), A(i), Ltarget(i), Liso(i), itau, Nrand(i), expchar(i)
    else
     write(8, '(a2, "_", i3.3, "_", i3.3, "_", i3.3, "_0_", i8.8, "_", i3.3, a2)') &
 &     nuclide(i), A(i), Ltarget(i), Liso(i), itau, Nrand(i), expchar(i)
    endif
    write(9, '(a2, 1x, i3.3, 1x, a1)') nuclide(i), A(i), isochar(i)
    write(10, '(i5, 3i4, 1x, a2, 1x, i3.3, 1x, a1, 12x, 1p, e12.5)') &
 &    i, Z(i), A(i), Liso(i), nuclide(i), A(i), isochar(i), tau(i)
  enddo
  close (8)
  close (9)
  close (10)
end program driplist
! Copyright A.J. Koning 2022
