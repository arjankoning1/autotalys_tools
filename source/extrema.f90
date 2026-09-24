program extrema
! 
!-----------------------------------------------------------------------------------------------------------------------------------
! Purpose   :  For a cross section table, determine the minimum and maximum energy
!              and the minimum and maximum cross section, to set plotting ranges.
!
! Author    : Arjan Koning
!
! 2022-02-23: Original code
! 2023-07-20: Original code
!-----------------------------------------------------------------------------------------------------------------------------------
!
  logical flaglib
  character*160 string
  emax=1.e-11
  emin=1000000. 
  xsmax0=0.1
  xsmax=0.1
  xsmin=5000.
  xsmin=1.e10
  flaglib=.false.
  do
    read(*,'(a160)',iostat=istat) string
    if (istat /= 0) exit
    ix=index(string,' E             xs')
    if (ix > 0) flaglib=.true.
    if (string(1:1).eq.'#') cycle
    if (flaglib) then
      read(string,*,iostat=istat) e,xs
    else
      read(string,*,iostat=istat) e,de,xs
    endif
    if (istat /= 0) cycle
    if (e.gt.0..and.xs.gt.0.) then
      xsmax=max(xsmax,xs)
      xsmin=min(xsmin,xs)
      emax=max(emax,e)
      emin=min(emin,e)
      if (e.gt.0.1) xsmax0=max(xsmax0,xs)
    endif
  enddo
  emin0=emin
  emin=min(emin,emax)
  emax=max(emin,emax)
  xsmin=min(xsmin,xsmax)
  xsmax=max(xsmin,xsmax)
  emin=emin0*0.80
  xsmin=xsmin*0.80
  xsmax=xsmax*1.50
  xsmax0=xsmax0*1.50
  write(*,'(6es12.5)') emin,emax,xsmin,xsmax,emin0,xsmax0
end program extrema
