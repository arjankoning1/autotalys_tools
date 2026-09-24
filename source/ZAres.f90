program ZAres
! 
!-----------------------------------------------------------------------------------------------------------------------------------
! Purpose   : Determine the correspondence between an MT number and a residual
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
  character(len=1)   :: proj
  character(len=2)   :: nuc(numZ)
  character(len=2)   :: nuclide
  integer            :: i
  integer            :: A
  integer            :: Z
  integer            :: MT
  integer            :: ZCN
  integer            :: ACN
  integer            :: Zres
  integer            :: Ares
  integer            :: parZ(0:6)
  integer            :: parN(0:6)
  integer            :: parA(0:6)
  integer            :: k0
  integer            :: ires
  integer            :: ZAr
  integer            :: delp
  integer            :: dela
!
! The translation works both ways, i.e. ZA --> MT and MT --> ZA.
!
  data (parZ(i),i=0,6)    /0,0,1,1,1,2,2/
  data (parN(i),i=0,6)    /0,1,0,1,2,1,2/
  data (parA(i),i=0,6)    /0,1,1,2,3,3,4/
  data (nuc(i),i=1,124) / &
    'H ','He','Li','Be','B ','C ','N ','O ','F ','Ne', &
    'Na','Mg','Al','Si','P ','S ','Cl','Ar','K ','Ca', &
    'Sc','Ti','V ','Cr','Mn','Fe','Co','Ni','Cu','Zn', &
    'Ga','Ge','As','Se','Br','Kr','Rb','Sr','Y ','Zr', &
    'Nb','Mo','Tc','Ru','Rh','Pd','Ag','Cd','In','Sn', &
    'Sb','Te','I ','Xe','Cs','Ba','La','Ce','Pr','Nd', &
    'Pm','Sm','Eu','Gd','Tb','Dy','Ho','Er','Tm','Yb', &
    'Lu','Hf','Ta','W ','Re','Os','Ir','Pt','Au','Hg', &
    'Tl','Pb','Bi','Po','At','Rn','Fr','Ra','Ac','Th', &
    'Pa','U ','Np','Pu','Am','Cm','Bk','Cf','Es','Fm', &
    'Md','No','Lr','Rf','Db','Sg','Bh','Hs','Mt','Ds', &
    'Rg','Cn','Nh','Fl','Mc','Lv','Ts','Og','B9','C0', &
    'C1','C2','C3','C4'/
  nuclide='  '
  MT=0
  ZAr=0
!
! Read input
!
  read(*,'(a2)') nuclide
  read(*,'(i3)') A
  read(*,'(a1)') proj
  read(*,*) ires
!
! Determine element
!
  do i=1,124
    if (nuclide(1:2).eq.nuc(i)(1:2)) then
      Z=i
      exit
    endif
  enddo
!
! Determine projectile
!
  if (proj.eq.'g') k0=0
  if (proj.eq.'n') k0=1
  if (proj.eq.'p') k0=2
  if (proj.eq.'d') k0=3
  if (proj.eq.'t') k0=4
  if (proj.eq.'h') k0=5
  if (proj.eq.'a') k0=6
!
! Determine compound nucleus
!
  ZCN=Z+parZ(k0)
  ACN=A+parA(k0)
!
! Test if MT --> ZAr or ZAr --> MT
!
  if (ires.lt.1000) then
    MT=ires
  else
    ZAr=ires
  endif
!
! MT --> ZAr
!
  if (MT.gt.0) then
    Zres=0
    Ares=0
    if (MT.eq.4) then
      Zres=ZCN
      Ares=ACN-1
    endif
    if (MT.eq.16) then
      Zres=ZCN
      Ares=ACN-2
    endif
    if (MT.eq.17) then
      Zres=ZCN
      Ares=ACN-3
    endif
    if (MT.eq.22) then
      Zres=ZCN-2
      Ares=ACN-5
    endif
    if (MT.eq.28) then
      Zres=ZCN-1
      Ares=ACN-2
    endif
    if (MT.eq.37) then
      Zres=ZCN
      Ares=ACN-4
    endif
    if (MT.eq.102) then
      Zres=ZCN
      Ares=ACN
    endif
    if (MT.eq.103) then
      Zres=ZCN-1
      Ares=ACN-1
    endif
    ZAr=1000*Zres+Ares
    write(*,'(i6.6)') ZAr
  else
!
! ZAr --> MT
!
    Zres=ZAr/1000
    Ares=mod(ZAr,1000)
    delp=ZCN-Zres
    dela=ACN-Ares
    if (delp.eq.0.and.dela.eq.1) MT=4
    if (delp.eq.0.and.dela.eq.2) MT=16
    if (delp.eq.0.and.dela.eq.3) MT=17
    if (delp.eq.0.and.dela.eq.4) MT=37
    if (delp.eq.0.and.dela.eq.0) MT=102
    if (delp.eq.1.and.dela.eq.1) MT=103
    write(*,'(i3.3)') MT
  endif
end program ZAres
