c **********************************************************************
c *                                                                    *
c *                             njoycovx                               *
c *                             --------                               *
c *      This program produces the coverx format file of covariance    *
c *  data from the output covariance file of errorr module in the      *
c *  njoy94 code.                                                      *
c *      It is used the coverx format with date of nov. 1, 1996.       *
c *                                                                    *
c **********************************************************************
c *  history                                                           *
c *    12/03/96 ..... create the njoycovx program by K.Kosako (SAEI).  *
c *    10/05/97 ..... automatic execution version following to the     *
c *                   errorj code by K.Kosako (SAEI).                  *
c **********************************************************************
c
      common /unit/   iui,iuo,iua,iub,iuc,iud,iue,iuf,iug
      common /inputd/ jbmode,icorrm
      common /inputh/ hf1,hf2,htitle
      common /inputz/ mrelat
c
      character hf1*80,hf2*80,htitle*120,hf3*80
      data mrelat / 1 /
c
c               mrelat = 0 : no output relative data (iug+3 unit)
c                        1 : output relative standard deviation
c                        2 : output relative covariance matrix
c                        3 : output both relative data
c
c ----------------------------------------------------------------------
c
c                                                          initial data
c             logical unit          description
c                 iui : i  : input data
c                 iuo : o  : output list file
c                 iua : io : coverx format file
c                            if jbmode=1, it is a new file.
c                            if jbmode=2 or 3, it is an existing file.
c                 iub : i  : covfil (formatted) file from njoy-errorr
c                 iuc : io : scratch file for cross sections
c                 iud : io : scratch file for covariance matrix
c                 iue : o  : new coverx format file, if jbmode=2 or 3
c                 iuf : o  : correlation matrix file with puff-2 format
c                 iug : o  : correlation matrix file for microsoft excel
cc              iug+1 : o  : relative covariance matrix file for
cc                           microsoft excel
c               iug+2 : o  : correlation matrix file by reaction for
c                            microsoft excel in the exc-d directory
c               iug+3 : o  : relative standard deviation file and/or
c                            relative covariance matrix file (in the
c                            exr-d directory) for microsoft excel
c                            {refere 'mrelat' parameter}
      iui=5
      iuo=6
      iua=10
      iub=11
      iuc=12
      iud=13
      iue=14
      iuf=15
      iug=16
c
c     write(iuo,10)
c  10 format(' please enter the job mode.'
c    &/'   1 = produce a new coverx format file from an errorr output',
c    &        ' file'
c    &/'   2 = add an errorr output file to the coverx format file'
c    &/'   3 = delete a nuclide in the coverx format file' )
c     read(iui,*) jbmode
c     if(jbmode.le.0.or.jbmode.ge.4) then
c        write(iuo,*) ' *** illegal job mode was detected ... ',jbmode
c        go to 990
c     endif
      jbmode=1
c
c     write(iuo,20)
c  20 format(' please enter the name of coverx format file.'
c    &/'   for example: coverx.u235'
c    &/'   if -, it means "coverx".' )
c     hf1=' '
c     read(iui,'(a)') hf1
c     if(hf1(1:1).eq.'-') then
c        hf1(1:6)='coverx'
c        ihf1=6
c     else
c        do 110 ihf1=80,1,-1
c 110    if(hf1(ihf1:ihf1).ne.' ') go to 111
c 111    continue
c     endif
c     open(iua,file=hf1(1:ihf1),form='formatted')
      hf1=' '
      call getarg(1,hf1)
      do ihf1=80,1,-1
         if (hf1(ihf1:ihf1).ne.' ') go to 111
      enddo
  111 continue
      open(iua,file='cvx.'//hf1(1:ihf1),form='formatted')
c
c     if(jbmode.eq.3) go to 130
c     write(iuo,30)
c  30 format(' please enter the name of njoy-errorr output file.'
c    &/'   for example: rcov.u235'
c    &/'   if %b6,  it means the directory name processed endf/b-vi.'
c    &/'   if %b4,  it means the directory name processed endf/b-iv.'
c    &/'   if %jef, it means the directory name processed jef-2.2.')
c     hf2=' '
c     read(iui,'(a)') hf2
c     if(hf2(1:3).eq.'%b6') then
c        hf2(1:32)='/user1/kosako/njoy/njoy94/b6-cv/'
c        ihf2=32
c     elseif(hf2(1:3).eq.'%b4') then
c        hf2(1:32)='/user1/kosako/njoy/njoy94/b4-cv/'
c        ihf2=32
c     elseif(hf2(1:4).eq.'%jef') then
c        hf2(1:33)='/user1/kosako/njoy/njoy94/jef-cv/'
c        ihf2=33
c     else
c        go to 120
c     endif
c     write(iuo,31)
c  31 format(' please enter the file name.')
c     hf3=' '
c     read(iui,'(a)') hf3
c     do 112 i=80,1,-1
c 112 if(hf3(i:i).ne.' ') go to 113
c 113 hf2(ihf2+1:ihf2+i)=hf3(1:i)
c     ihf2=ihf2+i
c     go to 122
c 120 do 121 ihf2=80,1,-1
c 121 if(hf2(ihf2:ihf2).ne.' ') go to 122
c 122 continue
c     open(iub,file=hf2(1:ihf2),form='formatted')
cc    open(iub,file='tape23',form='formatted')
      open(iub,file='cvf.'//hf1(1:ihf1),form='formatted')
      hf3=' '
c
c     write(iuo,40)
c  40 format(' please enter title of this nuclide.'
c    &/'   for example: coverx data for u-235 in endf/b-vi'
c    &/'   (the number of maximum character is 120.)' )
c     htitle=' '
c     read(iui,'(a)') htitle
c 130 continue
      htitle=' coverx file of '//hf1(1:ihf1)
c
c     if(jbmode.eq.1) go to 150
c     write(iuo,50)
c  50 format(' please enter the name of new coverx format file.'
c    &/'   for example: coverx.new' )
c     hf3=' '
c     read(iui,'(a)') hf3
c     do 140 ihf3=80,1,-1
c 140 if(hf3(ihf3:ihf3).ne.' ') go to 141
c 141 continue
c     open(iue,file=hf3(1:ihf3),form='formatted')
c 150 continue
c
c     icorrm=0
c     if(jbmode.eq.3) go to 170
c     write(iuo,60)
c  60 format(' please enter the option for correlation matrix table.'
c    &/'   0 = no process'
c    &/'   1 = print correlation matrix table'
c    &/'   2 = output correlation matrix table to "corr.matrix"')
c     read(iui,*) icorrm
c     if(icorrm.lt.0.or.icorrm.gt.2) icorrm=0
c 170 continue
      icorrm=2
      open(iug,file='exc.'//hf1(1:ihf1),form='formatted')
cc    open(iug+1,file='exr.'//hf1(1:ihf1),form='formatted')
      if (mrelat.eq.1.or.mrelat.eq.3) then
         open(iug+3,file='rsd.'//hf1(1:ihf1),form='formatted')
         open(iug+4,file='rsx.'//hf1(1:ihf1),form='formatted')
      endif
c
      if(jbmode.eq.1) then
         call rderrr
         call newcov
      elseif(jbmode.eq.2) then
         call rderrr
         call addcov
      elseif(jbmode.eq.3) then
         call delcov
      endif
c
  990 continue
      stop
      end
c%%
c%%
      subroutine rderrr
c ----------------------------------------------------------------------
c     read the errorr output file (covfil format) of njoy
c ----------------------------------------------------------------------
c
c     parameter (maxdas=2500000, maxgrp=300, maxmt=100, maxmtx=150)
      parameter (maxdas=5000000, maxgrp=600, maxmt=200, maxmtx=300)
c
      common /unit/   iui,iuo,iua,iub,iuc,iud,iue,iuf,iug
      common /inputd/ jbmode,icorrm
      common /errorr/ nnmmp,mmtrix
      common das(maxdas)
      common idas(maxdas)
c
      dimension gpb(maxgrp),mattb(maxmt),mttb(maxmt),mwgtb(maxmt),
     &          jbd(maxgrp),jjj(maxgrp),mat1n(maxmtx),mt1n(maxmtx),
     &          mat2n(maxmtx),mt2n(maxmtx),rsd(maxgrp*maxmt)
c
      character hh*66
c
c ----------------------------------------------------------------------
c
      open(iuc,form='unformatted',status='scratch')
      open(iud,form='unformatted',status='scratch')
c
c     ***read energy group structure (mf=1)
      do 90 i=1,maxgrp*maxmt
   90 rsd(i)=0.0
  100 read(iub,110) hh,math,mfh,mth
  110 format(a66,i4,i2,i3)
      if(math.lt.100) go to 100
      read(hh(1:11),'(e11.0)') zaid
      read(hh(12:22),'(e11.0)') awr
      read(iub,120) c1h,c2h,ngrp,l2h,n1h,n2h
  120 format(2e11.0,4i11,i4,i2,i3)
      read(iub,130) (gpb(i),i=1,ngrp+1)
  130 format(6e11.0)
      read(iub,110) hh,math,mfh,mth
      read(iub,110) hh,math,mfh,mth
      nnmmp=0
      mmtrix=0
      l01=1
c
c     ***read/write cross sections (mf=3,5,8)
  140 read(iub,120) c1h,c2h,l1h,l2h,n1h,n2h,math,mfh,mth
      if(mfh.eq.0) go to 180
      nnmmp=nnmmp+1
      if(n1h.ne.ngrp) then
         write(iuo,*) ' *** number of cross section groups differed ',
     &                'as ng=',n1h,' in newcov'
         go to 990
      endif
      l00=(nnmmp-1)*ngrp+l01
      read(iub,130) (das(l00+i-1),i=1,ngrp)
      do 150 i=1,ngrp
  150 if(das(l00+i-1).gt.0.0) go to 160
      nnmmp=nnmmp-1
      read(iub,110) hh,math,mfh,mth
      go to 140
  160 mattb(nnmmp)=math
      mttb(nnmmp)=mth
      mwgtb(nnmmp)=2
      if(mfh.eq.5.and.mth.eq.18) mttb(nnmmp)=181
      read(iub,110) hh,math,mfh,mth
      go to 140
  180 read(iub,120) c1h,c2h,l1h,l2h,n1h,n2h,math,mfh,mth
      if(mfh.eq.5.and.mth.eq.18) then
         nnmmp=nnmmp+1
         l00=(nnmmp-1)*ngrp+l01
         read(iub,130) (das(l00+i-1),i=1,ngrp)
         do i=1,ngrp
            if(das(l00+i-1).gt.0.0) go to 182
         enddo
         nnmmp=nnmmp-1
         go to 183
  182    mattb(nnmmp)=math
         mttb(nnmmp)=181
         mwgtb(nnmmp)=2
  183    read(iub,110) hh,math,mfh,mth
         read(iub,110) hh,math,mfh,mth
      elseif(mfh.eq.8.and.mth.eq.5) then
         backspace iub
  191    read(iub,120) c1h,c2h,l1h,l2h,n1h,n2h,math,mfh,mth
         if(mth.eq.0) then
            read(iub,110) hh,math,mfh,mth
            go to 200
         endif
         nnmmp=nnmmp+1
         l00=(nnmmp-1)*ngrp+l01
         read(iub,130) (das(l00+i-1),i=1,ngrp)
         do i=1,ngrp
            if(das(l00+i-1).gt.0.0) go to 192
         enddo
         nnmmp=nnmmp-1
         go to 191
  192    mattb(nnmmp)=l1h
         mttb(nnmmp)=l2h
         mwgtb(nnmmp)=2
         go to 191
      else
         backspace iub
      endif
  200 if(nnmmp.le.0) then
         write(iuo,*) ' *** all cross section data were zero'
         go to 990
      endif
      write(iuc) nnmmp,ngrp,(mattb(i),mttb(i),mwgtb(i),i=1,nnmmp),
     &           (gpb(i),i=1,ngrp+1),(das(i),i=1,nnmmp*ngrp)
c
c     ***read/write relative covariances (mf=33,34,35)
      l02=l01+nnmmp*ngrp
  210 read(iub,120) c1h,c2h,l1h,l2h,n1h,nm,math,mfh,mth
      if(mfh.ne.33.and.mfh.ne.34.and.mfh.ne.35.and.mfh.ne.0) then
         write(iuo,*) ' *** illegal rel.covariance format, mf=',mfh
         write(iuo,*) ' *** accepted mf is 33, 34 and 35.'
         go to 990
      endif
      if(mfh.eq.0) go to 260
C SUGINO 2000/12/4
c     do 250 n=1,nm
      do 255 n=1,nm
C SUGINO 2000/12/4
      read(iub,120) c1h,c2h,mati,mti,n1h,ng,math,mfh,mth
      if (mfh.eq.34) then
         ld1=mti
         ld2=n1h
         mti=mati
         mati=math
      elseif(mati.eq.0) then
         mati=math
      endif
      l00=l02
      ngsum=0
      do 215 i=1,ngrp
      jbd(i)=0
  215 jjj(i)=0
      ig=0
  220 ig=ig+1
      read(iub,120) c1h,c2h,l1h,ng1,ng2,ng3,math,mfh,mth
      read(iub,130) (das(l00+i-1),i=1,ng2)
      if(ig.eq.1.and.ng1.eq.ngrp.and.ng3.eq.ngrp.and.ng2.eq.1.and.
     &   das(l00).eq.0.0) go to 250
      if(ng1.eq.ngrp.and.ng3.eq.ngrp.and.ng2.eq.1.and.das(l00).eq.0.0)
     &   go to 230
      jbd(ng3)=ng2
      jjj(ng3)=ng1
      l00=l00+ng2
      ngsum=ngsum+ng2
      if(ng3.eq.ngrp) go to 230
      go to 220
  230 mmtrix=mmtrix+1
      if(mfh.eq.35) then
         if(mth.eq.18) mth=181
         if(mti.eq.18) mti=181
      endif
      mat1n(mmtrix)=math
      mt1n(mmtrix)=mth
      mat2n(mmtrix)=mati
      mt2n(mmtrix)=mti
      write(iud) math,mth,mati,mti,ngrp,(jbd(i),jjj(i),i=1,ngrp),
     &           ngsum,(das(i),i=l02,l02+ngsum-1)
      if(math.eq.mati.and.mth.eq.mti) then
         do 240 im=1,nnmmp
  240    if(mth.eq.mttb(im)) go to 241
         go to 250
  241    ns=l02
         nq=(im-1)*ngrp
         do 242 jg=1,ngrp
         if(jbd(jg).eq.0) go to 242
         if(jjj(jg).gt.jg.or.jjj(jg)+jbd(jg)-1.lt.jg) go to 242
         loc=ns+jg-jjj(jg)
         rsd(nq+jg)=sqrt(abs(das(loc)))
         ns=ns+jbd(jg)
  242    continue
      endif
  250 continue
C SUGINO 2000/12/4
      if(math.ne.mati) then
         do 251 im=1,nnmmp
  251    if(mati.eq.mattb(im).and.mti.eq.mttb(im)) go to 252
         go to 255
  252    continue
         ns=l02
         nq=(im-1)*ngrp
         do 253 jg=1,ngrp
         if(jbd(jg).eq.0) go to 253
         if(jjj(jg).gt.jg.or.jjj(jg)+jbd(jg)-1.lt.jg) go to 253
         loc=ns+jg-jjj(jg)
         rsd(nq+jg)=sqrt(abs(das(loc)))
         ns=ns+jbd(jg)
  253    continue
      endif
  255 continue
C SUGINO 2000/12/4
      read(iub,110) hh,math,mfh,mth
      go to 210
  260 matold=math
      read(iub,110) hh,math,mfh,mth
      read(iub,110) hh,math,mfh,mth
      if(math.eq.matold) then
         read(iub,120) c1h,c2h,l1h,l2h,n1h,n2h,math,mfh,mth
         read(iub,130) (dum,i=1,n1h)
         read(iub,110) hh,math,mfh,mth
         read(iub,110) hh,math,mfh,mth
         rewind iuc
         go to 140
      endif
      write(iuc) (rsd(i),i=1,nnmmp*ngrp)
      rewind iuc
      rewind iud
      write(iuo,300) nnmmp,mmtrix
c 300 format(' the number of reaction cross section sets =',i4
c    &      /' the number of covariance matrices         =',i4)
  300 format(' running njoycovx...'
     &      /' the number of reaction cross section sets =',i4
     &      /' the number of covariance matrices         =',i4)
c
      l03=l02+ngrp**2
      l04=l03+ngrp**2
      l05=l04+ngrp**2
      if (l05.gt.maxdas) then
         write(iuo,91) l05
   91    format(/' ***** error message from rderrr ***'
     &   /' lack the memory size .... ',i10)
         go to 990
      endif
      if(icorrm.eq.1.or.icorrm.eq.2) call corrmx(nnmmp,mmtrix,ngrp,
c    &   das(1),rsd,mattb,mttb,das(l02),das(l03),das(l04),jbd,jjj,gpb,
     &   das(1),rsd,mattb,mttb,das(l02),idas(l03),das(l04),jbd,jjj,gpb,
     &   icorrm)
c
      return
  990 stop 441
      end
c%%
c%%
      subroutine newcov
c ----------------------------------------------------------------------
c     output the new coverx format file
c ----------------------------------------------------------------------
c
      parameter (maxdas=2500000, maxgrp=300, maxmt=100, maxmtx=150)
c
      common /unit/   iui,iuo,iua,iub,iuc,iud,iue,iuf,iug
      common /errorr/ nnmmp,mmtrix
      common /inputh/ hf1,hf2,htitle
      common das(maxdas)
      dimension gpb(maxgrp),mattb(maxmt),mttb(maxmt),mwgtb(maxmt),
     &          jbd(maxgrp),jjj(maxgrp),mat1n(maxmtx),mt1n(maxmtx),
     &          mat2n(maxmtx),mt2n(maxmtx),rsd(maxgrp*maxmt),
     &          jjj1(maxgrp)
c
      character hf1*80,hf2*80,htitle*120,hht(20)*6
      character hname*6,huse*12
      equivalence (htitle,hht)
      data hname / 'coverx' /
     &     huse  / 'jnc errorj  ' /
     &     ivers / 1 /
     &     ntype / 2 /
     &     nblok / 1 /
c
c ----------------------------------------------------------------------
c
      write(iua,800) hname,huse,ivers
  800 format(' 0v coverx ',a6,'*',a12,'*',i6)
      do 110 i=120,1,-1
  110 if(htitle(i:i).ne.' ') go to 111
  111 nholl=(i+5)/6
      read(iuc) nn,ngrp,(mattb(i),mttb(i),mwgtb(i),i=1,nnmmp),
     &          (gpb(i),i=1,ngrp+1),(das(i),i=1,nnmmp*ngrp)
      write(iua,810) ngrp,ngrp,0,ntype,nnmmp,mmtrix,nholl
  810 format(' 1d ',7i6)
      if(nholl.gt.0) write(iua,820) (hht(i),i=1,nholl)
  820 format(' 2d *',11a6/(12a6))
      write(iua,830) (gpb(i),i=ngrp+1,1,-1)
  830 format(' 3d ',1p5e12.4/(6e12.4))
c     write(iua,840) (gpbg(i),i=nggrup+1,1,-1)
c 840 format(' 4d ',1p5e12.4/(6e12.4))
      write(iua,850) (mattb(i),mttb(i),mwgtb(i),i=1,nnmmp)
  850 format(' 5d ',11i6/(12i6))
      read(iuc) (rsd(i),i=1,nnmmp*ngrp)
      do 120 m=1,nnmmp
      l00=(m-1)*ngrp
  120 write(iua,860) (das(l00+i),i=ngrp,1,-1),(rsd(l00+i),i=ngrp,1,-1)
  860 format(' 6d ',1p5e12.4/(6e12.4))
      do 130 m=1,mmtrix
      read(iud) mat1n(m),mt1n(m),mat2n(m),mt2n(m),ngrptm,
     &          (jbd(i),jjj(i),i=1,ngrptm),ngsum,(das(i),i=1,ngsum)
      write(iua,870) mat1n(m),mt1n(m),mat2n(m),mt2n(m),nblok
  870 format(' 7d ',5i6)
      do 140 i=1,ngrp
      if(jbd(i).eq.0) then
         jjj1(i)=0
      else
         jjj1(i)=jjj(i)-i+jbd(i)
      endif
  140 continue
      write(iua,880) (jbd(i),jjj1(i),i=ngrp,1,-1),ngrp
  880 format(' 8d ',11i6/(12i6))
      write(iua,890) (das(i),i=ngsum,1,-1)
  890 format(' 9d ',1p5e12.4/(6e12.4))
  130 continue
c
      return
      end
c%%
c%%
      subroutine addcov
c ----------------------------------------------------------------------
c     add a nuclide to the coverx format file
c ----------------------------------------------------------------------
c
      parameter (maxdas=2500000, maxgrp=300, maxmt=100, maxmtx=150)
c
      common /unit/   iui,iuo,iua,iub,iuc,iud,iue,iuf,iug
      common /errorr/ nnmmp,mmtrix
      common /inputh/ hf1,hf2,htitle
      common das(maxdas)
      dimension gpb(maxgrp),mattb(maxmt),mttb(maxmt),mwgtb(maxmt),
     &          jbd(maxgrp),jjj(maxgrp),mat1n(maxmtx),mt1n(maxmtx),
     &          mat2n(maxmtx),mt2n(maxmtx),rsd(maxgrp*maxmt),
     &          jjj1(maxgrp),
     &          gpbn(maxgrp),gpbg(maxgrp),matid(maxmt),mtid(maxmt),
     &          mwgt(maxmt),jband(maxgrp),ijj(maxgrp),mat1(maxmtx),
     &          mt1(maxmtx),mat2(maxmtx),mt2(maxmtx),lgrp(maxgrp)
c
      character hf1*80,hf2*80,htitle*120,hhtitl*240,hht(40)*6
      character hname*6,huse*12
      equivalence (hhtitl,hht)
c
c ----------------------------------------------------------------------
c
      read(iua,700) hname,huse,ivers
  700 format(11x,a6,1x,a12,1x,i6)
      ivers=ivers+1
      write(iue,800) hname,huse,ivers
  800 format(' 0v coverx ',a6,'*',a12,'*',i6)
      do 110 i=120,1,-1
  110 if(htitle(i:i).ne.' ') go to 111
  111 i1=i
      read(iuc) nn,ngrp,(mattb(i),mttb(i),mwgtb(i),i=1,nnmmp),
     &          (gpb(i),i=1,ngrp+1),(das(i),i=1,nnmmp*ngrp)
      read(iua,710) ngroup,nngrup,nggrup,ntype,nmmp,nmtrix,nholl
  710 format(4x,7i6)
      if(ngrp.ne.ngroup) then
         write(iuo,*) ' *** number of groups differs.'
         go to 990
      endif
      hhtitl=' '
      read(iua,720) (hht(i),i=1,nholl)
  720 format(5x,11a6/(12a6))
      read(iua,730) (gpbn(i),i=1,nngrup+1)
  730 format(4x,5e12.4/(6e12.4))
      if(nggrup.gt.0) read(iua,730) (gpbg(i),i=1,nggrup+1)
      read(iua,740) (matid(i),mtid(i),mwgt(i),i=1,nmmp)
  740 format(4x,11i6/(12i6))
      do 120 i=240,1,-1
  120 if(hhtitl(i:i).ne.' ') go to 121
  121 i2=i
      hhtitl(i2+2:i2+i1+1)=htitle(1:i1)
  122 nholl=(i1+i2+6)/6
      k=nmmp
      do 123 i=1,nnmmp
      do 124 j=1,nmmp
  124 if(matid(j).eq.mattb(i).and.mtid(j).eq.mttb(i)) go to 123
      k=k+1
      matid(k)=mattb(i)
      mtid(k)=mttb(i)
      mwgt(k)=mwgtb(i)
  123 continue
      kmmp=k
      kmtrix=nmtrix+mmtrix
      write(iue,810) ngroup,ngroup,0,ntype,kmmp,kmtrix,nholl
  810 format(' 1d ',7i6)
      if(nholl.gt.0) write(iue,820) (hht(i),i=1,nholl)
  820 format(' 2d *',11a6/(12a6))
      write(iue,830) (gpbn(i),i=1,ngroup+1)
  830 format(' 3d ',1p5e12.4/(6e12.4))
c     write(iue,840) (gpbg(i),i=1,nggrup+1)
c 840 format(' 4d ',1p5e12.4/(6e12.4))
      write(iue,850) (matid(i),mtid(i),mwgt(i),i=1,kmmp)
  850 format(' 5d ',11i6/(12i6))
      l01=nnmmp*ngroup+1
      do 130 m=1,nmmp
      read(iua,730) (das(l01+i-1),i=1,ngroup*2)
  130 write(iue,860) (das(l01+i-1),i=1,ngroup*2)
      read(iuc) (rsd(i),i=1,nnmmp*ngrp)
      do 131 m=1,nnmmp
      l00=(m-1)*ngrp
  131 write(iue,860) (das(l00+i),i=ngrp,1,-1),(rsd(l00+i),i=ngrp,1,-1)
  860 format(' 6d ',1p5e12.4/(6e12.4))
      do 140 m=1,nmtrix
      read(iua,710) mat1(m),mt1(m),mat2(m),mt2(m),nblok
      write(iue,870) mat1(m),mt1(m),mat2(m),mt2(m),nblok
      read(iua,740) (jband(i),ijj(i),i=1,ngroup),(lgrp(i),i=1,nblok)
      write(iue,880) (jband(i),ijj(i),i=1,ngroup),(lgrp(i),i=1,nblok)
      ngsum=0
      do 150 i=1,ngroup
  150 ngsum=ngsum+jband(i)
      read(iua,730) (das(i),i=1,ngsum)
      write(iue,890) (das(i),i=1,ngsum)
  140 continue
      do 160 m=1,mmtrix
      read(iud) mat1n(m),mt1n(m),mat2n(m),mt2n(m),ngrptm,
     &          (jbd(i),jjj(i),i=1,ngrptm),ngsum,(das(i),i=1,ngsum)
      write(iue,870) mat1n(m),mt1n(m),mat2n(m),mt2n(m),1
  870 format(' 7d ',5i6)
      do 170 i=1,ngrp
      if(jbd(i).eq.0) then
         jjj1(i)=0
      else
         jjj1(i)=jjj(i)-i+jbd(i)
      endif
  170 continue
      write(iue,880) (jbd(i),jjj1(i),i=ngrp,1,-1),ngrp
  880 format(' 8d ',11i6/(12i6))
      write(iue,890) (das(i),i=ngsum,1,-1)
  890 format(' 9d ',1p5e12.4/(6e12.4))
  160 continue
c
      return
  990 stop 442
      end
c%%
c%%
      subroutine corrmx(nnmmp,mmtrix,ngrp,das,rsd,mattb,mttb,das2,idas2,
     &                  das3,jbd,jjj,gpb,icorrm)
c ----------------------------------------------------------------------
c     print or output the correlation matrix table
c ----------------------------------------------------------------------
c
      common /unit/   iui,iuo,iua,iub,iuc,iud,iue,iuf,iug
      common /inputz/ mrelat
      dimension das(ngrp,1),rsd(ngrp,1),mattb(1),mttb(1),das2(1),
     &          idas2(ngrp,1),jbd(1),jjj(1),gpb(1),das3(ngrp,ngrp)
      character hmt*9
      data hmt / 'mt   -   ' /
c
c ----------------------------------------------------------------------
c
      if(icorrm.eq.1) then
         iu1=iuo
      elseif(icorrm.eq.2) then
         open(iuf,file='corr.matrix',form='formatted')
         iu1=iuf
      endif
c     open(iug,file='exc.'//hf1(1:ihf1),form='formatted')
      ngrp2=ngrp**2
c
      if (mrelat.eq.1.or.mrelat.eq.3) then
CSUGI    write(iug+3,'(10h energy:mt,100i10)') (mttb(n),n=1,nnmmp)
         write(iug+3,'(11h energy:mat,100i10)') (mattb(n),n=1,nnmmp)
         write(iug+3,'(11h energy:mt ,100i10)') (mttb(n),n=1,nnmmp)
         do 410 i=1,ngrp
         write(iug+3,'(1p101e10.3)') gpb(ngrp+2-i),
     &      (rsd(ngrp+1-i,n),n=1,nnmmp)
         write(iug+3,'(1p101e10.3)') gpb(ngrp+1-i),
     &      (rsd(ngrp+1-i,n),n=1,nnmmp)
  410    continue
         close(iug+3,status='keep')
         do 430 n=1,nnmmp
         if (n.gt.1) write(iug+4,'(1h )')
         write(iug+4,600) mattb(n),mttb(n)
         do 420 i=ngrp,1,-1
  420    if (das(ngrp+1-i,n).gt.0.0) go to 421
         go to 430
  421    ngrp9=i
         do 422 i=1,ngrp9
  422    write(iug+4,620) i,gpb(ngrp+2-i),das(ngrp+1-i,n),
     &                    rsd(ngrp+1-i,n),
     &                    rsd(ngrp+1-i,n)*das(ngrp+1-i,n)
  430    continue
         close(iug+4,status='keep')
      endif
c
      do 200 m=1,mmtrix
      read(iud) mat1n,mt1n,mat2n,mt2n,ngrptm,
     &          (jbd(i),jjj(i),i=1,ngrptm),ngsum,(das2(i),i=1,ngsum)
      do 110 i=1,nnmmp
  110 if(mat1n.eq.mattb(i).and.mt1n.eq.mttb(i)) go to 120
      go to 200
  120 id1=i
      do 130 i=1,nnmmp
  130 if(mat2n.eq.mattb(i).and.mt2n.eq.mttb(i)) go to 140
      go to 200
  140 id2=i
      if(id1.eq.id2) then
         write(iu1,600) mat1n,mt1n
         do 150 i=1,ngrp
  150    write(iu1,620) i,gpb(ngrp+2-i),das(ngrp+1-i,id1),
     &                  rsd(ngrp+1-i,id1),
     &                  rsd(ngrp+1-i,id1)*das(ngrp+1-i,id1)
      else
         do i=1,ngrp
            if(rsd(ngrp+1-i,id2).gt.0.) go to 155
         enddo
         go to 200
  155    continue
         write(iu1,610) mat1n,mt1n,mat2n,mt2n
         do 160 i=1,ngrp
  160    write(iu1,620) i,gpb(ngrp+2-i),das(ngrp+1-i,id1),
     &                  das(ngrp+1-i,id2),rsd(ngrp+1-i,id1),
     &                  rsd(ngrp+1-i,id2)
      endif
  600 format(' material mat-mt=(',i4,',',i3,')'
     &/' grp      energy      x-sec.    rel.s.d.    std.dev.')
  610 format(' 1st material mat-mt=(',i4,',',i3,')  vs  2nd material ',
     &       'mat-mt=(',i4,',',i3,')'
     &/' grp      energy  1st x-sec.  2nd x-sec.  1st r.s.d.  ',
     & '2nd r.s.d.')
  620 format(1x,i3,1p5e12.4)
c
      do 170 i=1,ngrp
      do 170 j=1,ngrp
      idas2(j,i)=0
  170 das3(j,i)=0.0
      k=0
      do 190 i=1,ngrp
      if(jbd(i).le.0) go to 190
      do 180 j=jjj(i),jjj(i)+jbd(i)-1
      k=k+1
      if(das2(k).eq.0.0.or.rsd(i,id1).eq.0.0.or.rsd(j,id2).eq.0.0)
     &   go to 180
      idas2(j,i)=nint(das2(k)*1000.0/rsd(i,id1)/rsd(j,id2))
      das3(j,i)=das2(k)
  180 continue
  190 continue
      do 230 i=1,ngrp
      do 230 j=1,ngrp
  230 if(idas2(j,i).ne.0) go to 240
      go to 200
  240 iw1=i-1
      do 250 j=1,ngrp
      do 250 i=1,ngrp
  250 if(idas2(j,i).ne.0) go to 260
  260 iw2=j-1
      ngrpx=min(iw1,iw2)
      if(ngrpx.lt.0) ngrpx=0
      ngrpx=ngrp-ngrpx
      do 270 i=ngrp,1,-1
      do 270 j=1,ngrp
  270 if(idas2(j,i).ne.0) go to 280
  280 jw1=i
      do 290 j=ngrp,1,-1
      do 290 i=1,ngrp
  290 if(idas2(j,i).ne.0) go to 300
  300 jw2=j
      ngrpy=max(jw1,jw2)
      if(ngrpy.gt.ngrp) ngrpy=ngrp
      ngrpy=ngrp+1-ngrpy
      ngrpz=ngrpx+1-ngrpy
      write(iu1,630) mat1n,mt1n,mat2n,mt2n
      lp=(ngrpz+24)/25
      do 220 i=1,lp
      i1=(i-1)*25+ngrpy
      i2=min(i1+24,ngrpx)
      write(iu1,640) (j,j=i1,i2)
      write(iu1,645) ('-----',j=i1,i2)
      do 210 j=ngrpy,ngrpx
      write(iu1,650) j,(idas2(ngrp+1-k,ngrp+1-j),k=i1,i2)
  210 continue
  220 continue
      write(hmt(3:5),'(i3.3)') mt1n
      write(hmt(7:9),'(i3.3)') mt2n
      open(iug+2,file='exc-d/'//hmt,form='formatted')
      if (mrelat.eq.2.or.mrelat.eq.3)
     &   open(iug+3,file='exr-d/'//hmt,form='formatted')
      write(iug,661) mat1n,mt1n,mat2n,mt2n
cc    write(iug+1,661) mat1n,mt1n,mat2n,mt2n
      if(ngrp.le.30) then
         write(iug,662) (j,j=1,ngrp)
         write(iug+2,666) 0,(j,j=1,ngrp)
         do 310 i=1,ngrp
         write(iug,663) i,(idas2(ngrp+1-j,ngrp+1-i),j=1,ngrp)
  310    write(iug+2,663) i,(idas2(ngrp+1-j,ngrp+1-i),j=1,ngrp)
cc       write(iug+1,664) (j,j=1,ngrp)
         if (mrelat.eq.2.or.mrelat.eq.3)
     &      write(iug+3,664) (j,j=1,ngrp)
         do 311 i=1,ngrp
cc       write(iug+1,665) i,(das3(ngrp+1-j,ngrp+1-i),j=1,ngrp)
         if (mrelat.eq.2.or.mrelat.eq.3)
     &      write(iug+3,665) i,(das3(ngrp+1-j,ngrp+1-i),j=1,ngrp)
  311    continue
      else
         lp=(ngrp+29)/30
         do 330 k=1,lp
         i1=(k-1)*30+1
         i2=min(i1+29,ngrp)
         write(iug,662) (j,j=i1,i2)
         write(iug+2,666) 0,(j,j=i1,i2)
         do 320 i=1,ngrp
         write(iug,663) i,(idas2(ngrp+1-j,ngrp+1-i),j=i1,i2)
  320    write(iug+2,663) i,(idas2(ngrp+1-j,ngrp+1-i),j=i1,i2)
cc       write(iug+1,664) (j,j=i1,i2)
         if (mrelat.eq.2.or.mrelat.eq.3)
     &      write(iug+3,664) (j,j=i1,i2)
         do 321 i=1,ngrp
cc       write(iug+1,665) i,(das3(ngrp+1-j,ngrp+1-i),j=i1,i2)
         if (mrelat.eq.2.or.mrelat.eq.3)
     &      write(iug+3,665) i,(das3(ngrp+1-j,ngrp+1-i),j=i1,i2)
  321    continue
  330    continue
      endif
      close(iug+2,status='keep')
      if (mrelat.eq.2.or.mrelat.eq.3) close(iug+3,status='keep')
c
  200 continue
  630 format(' <<< correlation matrix >>>'
     &/' column material mat-mt=(',i4,',',i3,')  vs  row material ',
     & 'mat-mt=(',i4,',',i3,')')
  640 format('    row',i4,24i5)
  645 format(' column',a4,24a5)
  650 format(1x,i4,1x,25i5)
  661 format(5x,2i5,5x,2i5)
  662 format(5x,30i6)
  663 format(31i6)
  664 format(5x,30i10)
  665 format(i5,1p30e10.2)
  666 format(31i6)
      if(icorrm.eq.2) close(iuf,status='keep')
      close(iug,status='keep')
cc    close(iug+1,status='keep')
      rewind iud
c
      return
      end
c%%
c%%
      subroutine delcov
c ----------------------------------------------------------------------
c     delete nuclide in the coverx format file
c ----------------------------------------------------------------------
c
      parameter (maxdas=2500000, maxgrp=300, maxmt=100, maxmtx=150)
c
      common /unit/   iui,iuo,iua,iub,iuc,iud,iue,iuf,iug
      common /inputh/ hf1,hf2,htitle
      common das(maxdas)
      dimension gpbn(maxgrp),gpbg(maxgrp),matid(maxmt),mtid(maxmt),
     &          mwgt(maxmt),jband(maxgrp),ijj(maxgrp),mat1(maxmtx),
     &          mt1(maxmtx),mat2(maxmtx),mt2(maxmtx),lgrp(maxgrp)
      dimension matdel(100),mattbl(maxmt,3)
c
      character hf1*80,hf2*80,htitle*120,hhtitl*240,hht(40)*6
      character hname*6,huse*12
      equivalence (hhtitl,hht)
c
c ----------------------------------------------------------------------
c
      write(iuo,110)
  110 format(' please enter the mat-number to delete.'
     &/'  (for example: 9228  (for u-235))'
     &/'  if negative, it is the number of some nuclides.')
      read(iui,*) matdel(1)
      if(matdel(1).lt.0) then
         matdnn=abs(matdel(1))
         if(matdnn.gt.100) matdnn=100
         write(iuo,120)
         read(iui,*) (matdel(i),i=1,matdnn)
      elseif(matdel(1).eq.0) then
         go to 990
      else
         matdnn=1
      endif
  120 format(' please enter the list of mat-number.')
c
      open(iuc,form='unformatted',status='scratch')
      open(iud,form='unformatted',status='scratch')
c
      read(iua,10) hname,huse,ivers
   10 format(11x,a6,1x,a12,1x,i6)
      read(iua,20) ngroup,nngrup,nggrup,ntype,nmmp,nmtrix,nholl
   20 format(4x,7i6)
      read(iua,30) (hht(i),i=1,nholl)
   30 format(5x,11a6/(12a6))
      if(nngrup.gt.0) read(iua,40) (gpbn(i),i=1,nngrup+1)
      if(nggrup.gt.0) read(iua,40) (gpbg(i),i=1,nggrup+1)
   40 format(4x,5e12.0/(6e12.0))
      read(iua,50) (matid(i),mtid(i),mwgt(i),i=1,nmmp)
   50 format(4x,11i6/(12i6))
      do 130 n=1,nmmp
      read(iua,40) (das(i),i=1,ngroup*2)
  130 write(iuc) matid(n),mtid(n),(das(i),i=1,ngroup*2)
      do 150 n=1,nmtrix
      read(iua,20) mat1(n),mt1(n),mat2(n),mt2(n),nblok
      read(iua,50) (jband(i),ijj(i),i=1,ngroup),(lgrp(i),i=1,nblok)
      nsum=0
      do 140 i=1,ngroup
  140 nsum=nsum+jband(i)
      read(iua,40) (das(i),i=1,nsum)
  150 write(iud) mat1(n),mt1(n),mat2(n),mt2(n),(jband(i),ijj(i),
     &           i=1,ngroup),nsum,(das(i),i=1,nsum)
      rewind iuc
      rewind iud
      kmtrix=0
      do 200 n=1,nmtrix
      do 160 i=1,matdnn
  160 if(matdel(i).eq.mat1(n)) go to 170
      go to 200
  170 if(mat2(n).eq.0.or.mat2(n).eq.mat1(n)) go to 190
      do 180 i=1,matdnn
  180 if(matdel(i).eq.mat2(n)) go to 190
      go to 200
  190 mat1(n)=0
      mat2(n)=0
      mt1(n)=0
      mt2(n)=0
      kmtrix=kmtrix+1
  200 continue
      immp=0
      kmmp=0
      do 240 n=1,nmmp
      do 210 i=1,nmtrix
  210 if(mat1(i).eq.matid(n).and.mt1(i).eq.mtid(n)) go to 230
      do 220 i=1,nmtrix
  220 if(mat2(i).eq.matid(n).and.mt2(i).eq.mtid(n)) go to 230
      matid(n)=0
      mtid(n)=0
      kmmp=kmmp+1
      go to 240
  230 immp=immp+1
      mattbl(immp,1)=matid(n)
      mattbl(immp,2)=mtid(n)
      mattbl(immp,3)=mwgt(n)
  240 continue
c
      write(iue,810) hname,huse,ivers+1
  810 format(' 0v coverx ',a6,1h*,a12,1h*,i6)
      write(iue,820) ngroup,nngrup,nggrup,ntype,nmmp-kmmp,nmtrix-kmtrix,
     &               nholl
  820 format(' 1d ',7i6)
      write(iue,830) (hht(i),i=1,nholl)
  830 format(' 2d *',11a6/(12a6))
      if(nngrup.gt.0) write(iue,840) (gpbn(i),i=1,nngrup+1)
      if(nggrup.gt.0) write(iue,850) (gpbg(i),i=1,nggrup+1)
  840 format(' 3d ',1p5e12.0/(6e12.0))
  850 format(' 4d ',1p5e12.0/(6e12.0))
      write(iue,860) ((mattbl(i,j),j=1,3),i=1,immp)
  860 format(' 5d ',11i6/(12i6))
      do 310 n=1,nmmp
      read(iuc) matrd,mtrd,(das(i),i=1,ngroup*2)
      if(matid(n).gt.0.and.mtid(n).gt.0)
     &   write(iue,870) (das(i),i=1,ngroup*2)
  310 continue
  870 format(' 6d ',1p5e12.4/(6e12.4))
      do 320 n=1,nmtrix
      read(iud) mat8,mt8,mat9,mt9,(jband(i),ijj(i),i=1,ngroup),nsum,
     &          (das(i),i=1,nsum)
      if(mat1(n).gt.0.and.mt1(n).gt.0) then
         write(iue,880) mat8,mt8,mat9,mt9,1
         write(iue,890) (jband(i),ijj(i),i=1,ngroup),ngroup
         write(iue,895) (das(i),i=1,nsum)
      endif
  320 continue
  880 format(' 7d ',5i6)
  890 format(' 8d ',11i6/(12i6))
  895 format(' 9d ',1p5e12.4/(6e12.4))
c
      close(iuc)
      close(iud)
      close(iue,status='keep')
c
  990 continue
      return
      end
c%%
c%%
