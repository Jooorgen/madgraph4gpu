      DOUBLE PRECISION FUNCTION DSIG1(PP,WGT,IMODE)
C     ****************************************************
C     
C     Generated by MadGraph5_aMC@NLO v. 3.5.1_lo_vect, 2023-08-08
C     By the MadGraph5_aMC@NLO Development Team
C     Visit launchpad.net/madgraph5 and amcatnlo.web.cern.ch
C     
C     Process: u~ u~ > t t~ u~ u~ WEIGHTED<=4 @2
C     Process: c~ c~ > t t~ c~ c~ WEIGHTED<=4 @2
C     Process: d~ d~ > t t~ d~ d~ WEIGHTED<=4 @2
C     Process: s~ s~ > t t~ s~ s~ WEIGHTED<=4 @2
C     
C     RETURNS DIFFERENTIAL CROSS SECTION
C     Input:
C     pp    4 momentum of external particles
C     wgt   weight from Monte Carlo
C     imode 0 run, 1 init, 2 reweight, 
C     3 finalize, 4 only PDFs,
C     5 squared amplitude only (never
C     generate events)
C     Output:
C     Amplitude squared and summed
C     ****************************************************
      IMPLICIT NONE
C     
C     CONSTANTS
C     
      INCLUDE 'genps.inc'
      INCLUDE 'nexternal.inc'
      INCLUDE 'maxconfigs.inc'
      INCLUDE 'maxamps.inc'
      DOUBLE PRECISION       CONV
      PARAMETER (CONV=389379.66*1000)  !CONV TO PICOBARNS
      REAL*8     PI
      PARAMETER (PI=3.1415926D0)
C     
C     ARGUMENTS 
C     
      DOUBLE PRECISION PP(0:3,NEXTERNAL), WGT
      INTEGER IMODE
C     
C     LOCAL VARIABLES 
C     
      INTEGER I,ITYPE,LP,IPROC
      DOUBLE PRECISION CX1,SX1,UX1,DX1
      DOUBLE PRECISION CX2,SX2,UX2,DX2
      DOUBLE PRECISION XPQ(-7:7),PD(0:MAXPROC)
      DOUBLE PRECISION DSIGUU,R,RCONF

      INTEGER LUN,ICONF,IFACT,NFACT
      DATA NFACT/1/
      SAVE NFACT
C     
C     STUFF FOR DRESSED EE COLLISIONS
C     
      INCLUDE '../../Source/PDF/eepdf.inc'
      DOUBLE PRECISION EE_COMP_PROD

      INTEGER I_EE
C     
C     STUFF FOR UPC
C     
      DOUBLE PRECISION PHOTONPDFSQUARE
C     
C     EXTERNAL FUNCTIONS
C     
      LOGICAL PASSCUTS
      DOUBLE PRECISION ALPHAS2,REWGT,PDG2PDF,CUSTOM_BIAS
      INTEGER NEXTUNOPEN
C     
C     GLOBAL VARIABLES
C     
      INTEGER          IPSEL
      COMMON /SUBPROC/ IPSEL
C     MINCFIG has this config number
      INTEGER           MINCFIG, MAXCFIG
      COMMON/TO_CONFIGS/MINCFIG, MAXCFIG
      INTEGER MAPCONFIG(0:LMAXCONFIGS), ICONFIG
      COMMON/TO_MCONFIGS/MAPCONFIG, ICONFIG
C     Keep track of whether cuts already calculated for this event
      LOGICAL CUTSDONE,CUTSPASSED
      COMMON/TO_CUTSDONE/CUTSDONE,CUTSPASSED

      INTEGER SUBDIAG(MAXSPROC),IB(2)
      COMMON/TO_SUB_DIAG/SUBDIAG,IB
      INCLUDE '../../Source/vector.inc'  ! defines VECSIZE_MEMMAX
      INCLUDE 'run.inc'
      INCLUDE '../../Source/PDF/pdf.inc'
C     Common blocks
      DOUBLE PRECISION RHEL, RCOL
      INTEGER SELECTED_HEL(VECSIZE_MEMMAX)
      INTEGER SELECTED_COL(VECSIZE_MEMMAX)
C     
C     local
C     
      DOUBLE PRECISION P1(0:3, NEXTERNAL)
      INTEGER CHANNEL
C     
C     DATA
C     
      DATA CX1,SX1,UX1,DX1/4*1D0/
      DATA CX2,SX2,UX2,DX2/4*1D0/
C     ----------
C     BEGIN CODE
C     ----------
      DSIG1=0D0

      IF(IMODE.EQ.1)THEN
C       Set up process information from file symfact
        LUN=NEXTUNOPEN()
        NFACT=1
        OPEN(UNIT=LUN,FILE='../symfact.dat',STATUS='OLD',ERR=20)
        DO WHILE(.TRUE.)
          READ(LUN,*,ERR=10,END=10) RCONF, IFACT
          ICONF=INT(RCONF)
          IF(ICONF.EQ.MAPCONFIG(MINCFIG))THEN
            NFACT=IFACT
          ENDIF
        ENDDO
        DSIG1 = NFACT
 10     CLOSE(LUN)
        RETURN
 20     WRITE(*,*)'Error opening symfact.dat. No symmetry factor used.'
        RETURN
      ENDIF
C     Continue only if IMODE is 0, 4 or 5
      IF(IMODE.NE.0.AND.IMODE.NE.4.AND.IMODE.NE.5) RETURN


      IF (ABS(LPP(IB(1))).GE.1) THEN
          !LP=SIGN(1,LPP(IB(1)))
        CX1=PDG2PDF(LPP(IB(1)),-4, IB(1),XBK(IB(1)),DSQRT(Q2FACT(IB(1))
     $   ))
        SX1=PDG2PDF(LPP(IB(1)),-3, IB(1),XBK(IB(1)),DSQRT(Q2FACT(IB(1))
     $   ))
        UX1=PDG2PDF(LPP(IB(1)),-2, IB(1),XBK(IB(1)),DSQRT(Q2FACT(IB(1))
     $   ))
        DX1=PDG2PDF(LPP(IB(1)),-1, IB(1),XBK(IB(1)),DSQRT(Q2FACT(IB(1))
     $   ))
      ENDIF
      IF (ABS(LPP(IB(2))).GE.1) THEN
          !LP=SIGN(1,LPP(IB(2)))
        CX2=PDG2PDF(LPP(IB(2)),-4, IB(2),XBK(IB(2)),DSQRT(Q2FACT(IB(2))
     $   ))
        SX2=PDG2PDF(LPP(IB(2)),-3, IB(2),XBK(IB(2)),DSQRT(Q2FACT(IB(2))
     $   ))
        UX2=PDG2PDF(LPP(IB(2)),-2, IB(2),XBK(IB(2)),DSQRT(Q2FACT(IB(2))
     $   ))
        DX2=PDG2PDF(LPP(IB(2)),-1, IB(2),XBK(IB(2)),DSQRT(Q2FACT(IB(2))
     $   ))
      ENDIF
      PD(0) = 0D0
      IPROC = 0
      IPROC=IPROC+1  ! u~ u~ > t t~ u~ u~
      PD(IPROC)=UX1*UX2
      PD(0)=PD(0)+DABS(PD(IPROC))
      IPROC=IPROC+1  ! c~ c~ > t t~ c~ c~
      PD(IPROC)=CX1*CX2
      PD(0)=PD(0)+DABS(PD(IPROC))
      IPROC=IPROC+1  ! d~ d~ > t t~ d~ d~
      PD(IPROC)=DX1*DX2
      PD(0)=PD(0)+DABS(PD(IPROC))
      IPROC=IPROC+1  ! s~ s~ > t t~ s~ s~
      PD(IPROC)=SX1*SX2
      PD(0)=PD(0)+DABS(PD(IPROC))
      IF (IMODE.EQ.4)THEN
        DSIG1 = PD(0)
        RETURN
      ENDIF
      IF(FRAME_ID.NE.6)THEN
        CALL BOOST_TO_FRAME(PP, FRAME_ID, P1)
      ELSE
        P1 = PP
      ENDIF

      CHANNEL = SUBDIAG(1)
      CALL RANMAR(RHEL)
      CALL RANMAR(RCOL)
      CALL SMATRIX1(P1,RHEL, RCOL,CHANNEL,1, DSIGUU, SELECTED_HEL(1),
     $  SELECTED_COL(1))


      IF (IMODE.EQ.5) THEN
        IF (DSIGUU.LT.1D199) THEN
          DSIG1 = DSIGUU*CONV
        ELSE
          DSIG1 = 0.0D0
        ENDIF
        RETURN
      ENDIF
C     Select a flavor combination (need to do here for right sign)
      CALL RANMAR(R)
      IPSEL=0
      DO WHILE (R.GE.0D0 .AND. IPSEL.LT.IPROC)
        IPSEL=IPSEL+1
        R=R-DABS(PD(IPSEL))/PD(0)
      ENDDO

      DSIGUU=DSIGUU*REWGT(PP,1)

C     Apply the bias weight specified in the run card (default is 1.0)
      DSIGUU=DSIGUU*CUSTOM_BIAS(PP,DSIGUU,1,1)

      DSIGUU=DSIGUU*NFACT

      IF (DSIGUU.LT.1D199) THEN
C       Set sign of dsig based on sign of PDF and matrix element
        DSIG1=DSIGN(CONV*PD(0)*DSIGUU,DSIGUU*PD(IPSEL))
      ELSE
        WRITE(*,*) 'Error in matrix element'
        DSIGUU=0D0
        DSIG1=0D0
      ENDIF
C     Generate events only if IMODE is 0.
      IF(IMODE.EQ.0.AND.DABS(DSIG1).GT.0D0)THEN
C       Call UNWGT to unweight and store events
        CALL UNWGT(PP,DSIG1*WGT,1,SELECTED_HEL(1), SELECTED_COL(1), 1)
      ENDIF

      END
C     
C     Functionality to handling grid
C     



      DOUBLE PRECISION FUNCTION DSIG1_VEC(ALL_PP, ALL_XBK, ALL_Q2FACT,
     $  ALL_CM_RAP, ALL_WGT, IMODE, ALL_OUT, VECSIZE_USED)
C     ****************************************************
C     
C     Generated by MadGraph5_aMC@NLO v. 3.5.1_lo_vect, 2023-08-08
C     By the MadGraph5_aMC@NLO Development Team
C     Visit launchpad.net/madgraph5 and amcatnlo.web.cern.ch
C     
C     Process: u~ u~ > t t~ u~ u~ WEIGHTED<=4 @2
C     Process: c~ c~ > t t~ c~ c~ WEIGHTED<=4 @2
C     Process: d~ d~ > t t~ d~ d~ WEIGHTED<=4 @2
C     Process: s~ s~ > t t~ s~ s~ WEIGHTED<=4 @2
C     
C     RETURNS DIFFERENTIAL CROSS SECTION
C     Input:
C     pp    4 momentum of external particles
C     wgt   weight from Monte Carlo
C     imode 0 run, 1 init, 2 reweight, 
C     3 finalize, 4 only PDFs,
C     5 squared amplitude only (never
C     generate events)
C     Output:
C     Amplitude squared and summed
C     ****************************************************
      IMPLICIT NONE
C     
C     CONSTANTS
C     
      INCLUDE '../../Source/vector.inc'  ! defines VECSIZE_MEMMAX
      INCLUDE 'genps.inc'
      INCLUDE 'nexternal.inc'
      INCLUDE 'maxconfigs.inc'
      INCLUDE 'maxamps.inc'
      DOUBLE PRECISION       CONV
      PARAMETER (CONV=389379.66*1000)  !CONV TO PICOBARNS
      REAL*8     PI
      PARAMETER (PI=3.1415926D0)
C     
C     ARGUMENTS 
C     
      DOUBLE PRECISION ALL_PP(0:3,NEXTERNAL,VECSIZE_MEMMAX)
      DOUBLE PRECISION ALL_WGT(VECSIZE_MEMMAX)
      DOUBLE PRECISION ALL_XBK(2,VECSIZE_MEMMAX)
      DOUBLE PRECISION ALL_Q2FACT(2,VECSIZE_MEMMAX)
      DOUBLE PRECISION ALL_CM_RAP(VECSIZE_MEMMAX)
      INTEGER IMODE
      DOUBLE PRECISION ALL_OUT(VECSIZE_MEMMAX)
      INTEGER VECSIZE_USED
C     ----------
C     BEGIN CODE
C     ----------
C     
C     LOCAL VARIABLES 
C     
      INTEGER I,ITYPE,LP,IPROC
      DOUBLE PRECISION CX1(VECSIZE_MEMMAX),SX1(VECSIZE_MEMMAX)
     $ ,UX1(VECSIZE_MEMMAX),DX1(VECSIZE_MEMMAX)
      DOUBLE PRECISION CX2(VECSIZE_MEMMAX),SX2(VECSIZE_MEMMAX)
     $ ,UX2(VECSIZE_MEMMAX),DX2(VECSIZE_MEMMAX)
      DOUBLE PRECISION XPQ(-7:7),PD(0:MAXPROC)
      DOUBLE PRECISION ALL_PD(0:MAXPROC, VECSIZE_MEMMAX)
      DOUBLE PRECISION DSIGUU,R,RCONF
      INTEGER LUN,ICONF,IFACT,NFACT
      DATA NFACT/1/
      SAVE NFACT
      DOUBLE PRECISION RHEL  ! random number
      INTEGER CHANNEL
C     
C     STUFF FOR DRESSED EE COLLISIONS --even if not supported for now--
C     
      INCLUDE '../../Source/PDF/eepdf.inc'
      DOUBLE PRECISION EE_COMP_PROD

      INTEGER I_EE
C     
C     EXTERNAL FUNCTIONS
C     
      LOGICAL PASSCUTS
      DOUBLE PRECISION ALPHAS2,REWGT,PDG2PDF,CUSTOM_BIAS
      INTEGER NEXTUNOPEN
      DOUBLE PRECISION DSIG1
C     
C     GLOBAL VARIABLES
C     
      INTEGER          IPSEL
      COMMON /SUBPROC/ IPSEL
C     MINCFIG has this config number
      INTEGER           MINCFIG, MAXCFIG
      COMMON/TO_CONFIGS/MINCFIG, MAXCFIG
      INTEGER MAPCONFIG(0:LMAXCONFIGS), ICONFIG
      COMMON/TO_MCONFIGS/MAPCONFIG, ICONFIG
C     Keep track of whether cuts already calculated for this event
      LOGICAL CUTSDONE,CUTSPASSED
      COMMON/TO_CUTSDONE/CUTSDONE,CUTSPASSED

      INTEGER SUBDIAG(MAXSPROC),IB(2)
      COMMON/TO_SUB_DIAG/SUBDIAG,IB
      INCLUDE 'run.inc'

      DOUBLE PRECISION P_MULTI(0:3, NEXTERNAL, VECSIZE_MEMMAX)
      DOUBLE PRECISION HEL_RAND(VECSIZE_MEMMAX)
      DOUBLE PRECISION COL_RAND(VECSIZE_MEMMAX)
      INTEGER SELECTED_HEL(VECSIZE_MEMMAX)
      INTEGER SELECTED_COL(VECSIZE_MEMMAX)
      DOUBLE PRECISION ALL_RWGT(VECSIZE_MEMMAX)

C     Common blocks
      CHARACTER*7         PDLABEL,EPA_LABEL
      INTEGER       LHAID
      COMMON/TO_PDF/LHAID,PDLABEL,EPA_LABEL

C     
C     local
C     
      DOUBLE PRECISION P1(0:3, NEXTERNAL)
      INTEGER IVEC

C     
C     DATA
C     
      DATA CX1,SX1,UX1,DX1/VECSIZE_MEMMAX*1D0,VECSIZE_MEMMAX*1D0
     $ ,VECSIZE_MEMMAX*1D0,VECSIZE_MEMMAX*1D0/
      DATA CX2,SX2,UX2,DX2/VECSIZE_MEMMAX*1D0,VECSIZE_MEMMAX*1D0
     $ ,VECSIZE_MEMMAX*1D0,VECSIZE_MEMMAX*1D0/
C     ----------
C     BEGIN CODE
C     ----------

      IF(IMODE.EQ.1)THEN
        NFACT = DSIG1(ALL_PP(0,1,1), ALL_WGT(1), IMODE)
        RETURN
      ENDIF

C     Continue only if IMODE is 0, 4 or 5
      IF(IMODE.NE.0.AND.IMODE.NE.4.AND.IMODE.NE.5) RETURN


      DO IVEC=1,VECSIZE_USED
        IF (ABS(LPP(IB(1))).GE.1) THEN
            !LP=SIGN(1,LPP(IB(1)))
          CX1(IVEC)=PDG2PDF(LPP(IB(1)),-4, IB(1),ALL_XBK(IB(1),IVEC)
     $     ,DSQRT(ALL_Q2FACT(IB(1), IVEC)))
          SX1(IVEC)=PDG2PDF(LPP(IB(1)),-3, IB(1),ALL_XBK(IB(1),IVEC)
     $     ,DSQRT(ALL_Q2FACT(IB(1), IVEC)))
          UX1(IVEC)=PDG2PDF(LPP(IB(1)),-2, IB(1),ALL_XBK(IB(1),IVEC)
     $     ,DSQRT(ALL_Q2FACT(IB(1), IVEC)))
          DX1(IVEC)=PDG2PDF(LPP(IB(1)),-1, IB(1),ALL_XBK(IB(1),IVEC)
     $     ,DSQRT(ALL_Q2FACT(IB(1), IVEC)))
        ENDIF
        IF (ABS(LPP(IB(2))).GE.1) THEN
            !LP=SIGN(1,LPP(IB(2)))
          CX2(IVEC)=PDG2PDF(LPP(IB(2)),-4, IB(2),ALL_XBK(IB(2),IVEC)
     $     ,DSQRT(ALL_Q2FACT(IB(2), IVEC)))
          SX2(IVEC)=PDG2PDF(LPP(IB(2)),-3, IB(2),ALL_XBK(IB(2),IVEC)
     $     ,DSQRT(ALL_Q2FACT(IB(2), IVEC)))
          UX2(IVEC)=PDG2PDF(LPP(IB(2)),-2, IB(2),ALL_XBK(IB(2),IVEC)
     $     ,DSQRT(ALL_Q2FACT(IB(2), IVEC)))
          DX2(IVEC)=PDG2PDF(LPP(IB(2)),-1, IB(2),ALL_XBK(IB(2),IVEC)
     $     ,DSQRT(ALL_Q2FACT(IB(2), IVEC)))
        ENDIF
      ENDDO
      ALL_PD(0,:) = 0D0
      IPROC = 0
      IPROC=IPROC+1  ! u~ u~ > t t~ u~ u~
      DO IVEC=1, VECSIZE_USED
        ALL_PD(IPROC,IVEC)=UX1(IVEC)*UX2(IVEC)
        ALL_PD(0,IVEC)=ALL_PD(0,IVEC)+DABS(ALL_PD(IPROC,IVEC))

      ENDDO
      IPROC=IPROC+1  ! c~ c~ > t t~ c~ c~
      DO IVEC=1, VECSIZE_USED
        ALL_PD(IPROC,IVEC)=CX1(IVEC)*CX2(IVEC)
        ALL_PD(0,IVEC)=ALL_PD(0,IVEC)+DABS(ALL_PD(IPROC,IVEC))

      ENDDO
      IPROC=IPROC+1  ! d~ d~ > t t~ d~ d~
      DO IVEC=1, VECSIZE_USED
        ALL_PD(IPROC,IVEC)=DX1(IVEC)*DX2(IVEC)
        ALL_PD(0,IVEC)=ALL_PD(0,IVEC)+DABS(ALL_PD(IPROC,IVEC))

      ENDDO
      IPROC=IPROC+1  ! s~ s~ > t t~ s~ s~
      DO IVEC=1, VECSIZE_USED
        ALL_PD(IPROC,IVEC)=SX1(IVEC)*SX2(IVEC)
        ALL_PD(0,IVEC)=ALL_PD(0,IVEC)+DABS(ALL_PD(IPROC,IVEC))

      ENDDO


      IF (IMODE.EQ.4)THEN
        ALL_OUT(:) = ALL_PD(0,:)
        RETURN
      ENDIF

      DO IVEC=1,VECSIZE_USED
C       Do not need those three here do I?	 
        XBK(:) = ALL_XBK(:,IVEC)
C       CM_RAP = ALL_CM_RAP(IVEC)
        Q2FACT(:) = ALL_Q2FACT(:, IVEC)

C       Select a flavor combination (need to do here for right sign)
        CALL RANMAR(R)
        IPSEL=0
        DO WHILE (R.GE.0D0 .AND. IPSEL.LT.IPROC)
          IPSEL=IPSEL+1
          R=R-DABS(ALL_PD(IPSEL,IVEC))/ALL_PD(0,IVEC)
        ENDDO
        CHANNEL = SUBDIAG(1)


        ALL_RWGT(IVEC) = REWGT(ALL_PP(0,1,IVEC), IVEC)

        IF(FRAME_ID.NE.6)THEN
          CALL BOOST_TO_FRAME(ALL_PP(0,1,IVEC), FRAME_ID, P_MULTI(0,1
     $     ,IVEC))
        ELSE
          P_MULTI(:,:,IVEC) = ALL_PP(:,:,IVEC)
        ENDIF
        CALL RANMAR(HEL_RAND(IVEC))
        CALL RANMAR(COL_RAND(IVEC))
      ENDDO
      CALL SMATRIX1_MULTI(P_MULTI, HEL_RAND, COL_RAND, CHANNEL,
     $  ALL_OUT , SELECTED_HEL, SELECTED_COL, VECSIZE_USED)


      DO IVEC=1,VECSIZE_USED
        DSIGUU = ALL_OUT(IVEC)
        IF (IMODE.EQ.5) THEN
          IF (DSIGUU.LT.1D199) THEN
            ALL_OUT(IVEC) = DSIGUU*CONV
          ELSE
            ALL_OUT(IVEC) = 0.0D0
          ENDIF
          RETURN
        ENDIF

        XBK(:) = ALL_XBK(:,IVEC)
C       CM_RAP = ALL_CM_RAP(IVEC)
        Q2FACT(:) = ALL_Q2FACT(:, IVEC)

        IF(FRAME_ID.NE.6)THEN
          CALL BOOST_TO_FRAME(ALL_PP(0,1,IVEC), FRAME_ID, P1)
        ELSE
          P1 = ALL_PP(:,:,IVEC)
        ENDIF
C       call restore_cl_val_to(ivec)
C       DSIGUU=DSIGUU*REWGT(P1,ivec)
        DSIGUU=DSIGUU*ALL_RWGT(IVEC)

C       Apply the bias weight specified in the run card (default is
C        1.0)
        DSIGUU=DSIGUU*CUSTOM_BIAS(P1,DSIGUU,1, IVEC)

        DSIGUU=DSIGUU*NFACT

        IF (DSIGUU.LT.1D199) THEN
C         Set sign of dsig based on sign of PDF and matrix element
          ALL_OUT(IVEC)=DSIGN(CONV*ALL_PD(0,IVEC)*DSIGUU,DSIGUU
     $     *ALL_PD(IPSEL,IVEC))
        ELSE
          WRITE(*,*) 'Error in matrix element'
          DSIGUU=0D0
          ALL_OUT(IVEC)=0D0
        ENDIF
C       Generate events only if IMODE is 0.
        IF(IMODE.EQ.0.AND.DABS(ALL_OUT(IVEC)).GT.0D0)THEN
C         Call UNWGT to unweight and store events
          CALL UNWGT(ALL_PP(0,1,IVEC), ALL_OUT(IVEC)*ALL_WGT(IVEC),1,
     $      SELECTED_HEL(IVEC), SELECTED_COL(IVEC), IVEC)
        ENDIF
      ENDDO

      END
C     
C     Functionality to handling grid
C     






      SUBROUTINE PRINT_ZERO_AMP1()

      RETURN
      END


      SUBROUTINE SMATRIX1_MULTI(P_MULTI, HEL_RAND, COL_RAND, CHANNEL,
     $  OUT, SELECTED_HEL, SELECTED_COL, VECSIZE_USED)
      USE OMP_LIB
      IMPLICIT NONE

      INCLUDE 'nexternal.inc'
      INCLUDE '../../Source/vector.inc'  ! defines VECSIZE_MEMMAX
      INCLUDE 'maxamps.inc'
      INTEGER                 NCOMB
      PARAMETER (             NCOMB=64)
      DOUBLE PRECISION P_MULTI(0:3, NEXTERNAL, VECSIZE_MEMMAX)
      DOUBLE PRECISION HEL_RAND(VECSIZE_MEMMAX)
      DOUBLE PRECISION COL_RAND(VECSIZE_MEMMAX)
      INTEGER CHANNEL
      DOUBLE PRECISION OUT(VECSIZE_MEMMAX)
      INTEGER SELECTED_HEL(VECSIZE_MEMMAX)
      INTEGER SELECTED_COL(VECSIZE_MEMMAX)
      INTEGER VECSIZE_USED

      INTEGER IVEC
      INTEGER IEXT

      INTEGER                    ISUM_HEL
      LOGICAL                    MULTI_CHANNEL
      COMMON/TO_MATRIX/ISUM_HEL, MULTI_CHANNEL

      LOGICAL FIRST_CHID
      SAVE FIRST_CHID
      DATA FIRST_CHID/.TRUE./
      
#ifdef MG5AMC_MEEXPORTER_CUDACPP
      INCLUDE 'coupl.inc' ! for ALL_G
      INCLUDE 'fbridge.inc'
      INCLUDE 'fbridge_common.inc'
      INCLUDE 'genps.inc'
      INCLUDE 'run.inc'
      DOUBLE PRECISION OUT2(VECSIZE_MEMMAX)
      INTEGER SELECTED_HEL2(VECSIZE_MEMMAX)
      INTEGER SELECTED_COL2(VECSIZE_MEMMAX)
      DOUBLE PRECISION CBYF1
      INTEGER*4 NGOODHEL, NTOTHEL

      INTEGER*4 NWARNINGS
      SAVE NWARNINGS
      DATA NWARNINGS/0/
      
      LOGICAL FIRST
      SAVE FIRST
      DATA FIRST/.TRUE./
      
      IF( FBRIDGE_MODE .LE. 0 ) THEN ! (FortranOnly=0 or BothQuiet=-1 or BothDebug=-2)
#endif
        call counters_smatrix1multi_start( -1, VECSIZE_USED ) ! fortran=-1
!$OMP PARALLEL
!$OMP DO
        DO IVEC=1, VECSIZE_USED
          CALL SMATRIX1(P_MULTI(0,1,IVEC),
     &      hel_rand(IVEC),
     &      col_rand(IVEC),
     &      channel,
     &      IVEC,
     &      out(IVEC),
     &      selected_hel(IVEC),
     &      selected_col(IVEC)
     &      )
        ENDDO
!$OMP END DO
!$OMP END PARALLEL
        call counters_smatrix1multi_stop( -1 ) ! fortran=-1
#ifdef MG5AMC_MEEXPORTER_CUDACPP
      ENDIF

      IF( FBRIDGE_MODE .EQ. 1 .OR. FBRIDGE_MODE .LT. 0 ) THEN ! (CppOnly=1 or BothQuiet=-1 or BothDebug=-2)
        IF( LIMHEL.NE.0 ) THEN
          WRITE(6,*) 'ERROR! The cudacpp bridge only supports LIMHEL=0'
          STOP
        ENDIF
        IF ( FIRST ) THEN ! exclude first pass (helicity filtering) from timers (#461)
          CALL FBRIDGESEQUENCE(FBRIDGE_PBRIDGE, P_MULTI, ALL_G,
     &      HEL_RAND, COL_RAND, 0, OUT2,
     &      SELECTED_HEL2, SELECTED_COL2 ) ! 0: multi channel disabled for helicity filtering
          FIRST = .FALSE.
c         ! This is a workaround for https://github.com/oliviermattelaer/mg5amc_test/issues/22 (see PR #486)
          IF( FBRIDGE_MODE .EQ. 1 ) THEN ! (CppOnly=1 : SMATRIX1 is not called at all)
            CALL RESET_CUMULATIVE_VARIABLE() ! mimic 'avoid bias of the initialization' within SMATRIX1
          ENDIF
          CALL FBRIDGEGETNGOODHEL(FBRIDGE_PBRIDGE,NGOODHEL,NTOTHEL)
          IF( NTOTHEL .NE. NCOMB ) THEN
            WRITE(6,*) 'ERROR! Cudacpp/Fortran mismatch',
     &        ' in total number of helicities', NTOTHEL, NCOMB
            STOP
          ENDIF
          WRITE (6,*) 'NGOODHEL =', NGOODHEL
          WRITE (6,*) 'NCOMB =', NCOMB
        ENDIF
        call counters_smatrix1multi_start( 0, VECSIZE_USED ) ! cudacpp=0
        IF ( .NOT. MULTI_CHANNEL ) THEN
          CALL FBRIDGESEQUENCE(FBRIDGE_PBRIDGE, P_MULTI, ALL_G,
     &      HEL_RAND, COL_RAND, 0, OUT2,
     &      SELECTED_HEL2, SELECTED_COL2 ) ! 0: multi channel disabled
        ELSE
          IF( SDE_STRAT.NE.1 ) THEN
            WRITE(6,*) 'ERROR! The cudacpp bridge requires SDE=1' ! multi channel single-diagram enhancement strategy
            STOP
          ENDIF
          CALL FBRIDGESEQUENCE(FBRIDGE_PBRIDGE, P_MULTI, ALL_G,
     &      HEL_RAND, COL_RAND, CHANNEL, OUT2,
     &      SELECTED_HEL2, SELECTED_COL2 ) ! 1-N: multi channel enabled
        ENDIF
        call counters_smatrix1multi_stop( 0 ) ! cudacpp=0
      ENDIF

      IF( FBRIDGE_MODE .LT. 0 ) THEN ! (BothQuiet=-1 or BothDebug=-2)
        DO IVEC=1, VECSIZE_USED
          CBYF1 = OUT2(IVEC)/OUT(IVEC) - 1
          FBRIDGE_NCBYF1 = FBRIDGE_NCBYF1 + 1
          FBRIDGE_CBYF1SUM = FBRIDGE_CBYF1SUM + CBYF1
          FBRIDGE_CBYF1SUM2 = FBRIDGE_CBYF1SUM2 + CBYF1 * CBYF1
          IF( CBYF1 .GT. FBRIDGE_CBYF1MAX ) FBRIDGE_CBYF1MAX = CBYF1
          IF( CBYF1 .LT. FBRIDGE_CBYF1MIN ) FBRIDGE_CBYF1MIN = CBYF1
          IF( FBRIDGE_MODE .EQ. -2 ) THEN ! (BothDebug=-2)
            WRITE (*,'(I4,2E16.8,F23.11,I3,I3,I4,I4)')
     &        IVEC, OUT(IVEC), OUT2(IVEC), 1+CBYF1,
     &        SELECTED_HEL(IVEC), SELECTED_HEL2(IVEC),
     &        SELECTED_COL(IVEC), SELECTED_COL2(IVEC)
          ENDIF
          IF( ABS(CBYF1).GT.5E-5 .AND. NWARNINGS.LT.20 ) THEN
            NWARNINGS = NWARNINGS + 1
            WRITE (*,'(A,I4,A,I4,2E16.8,F23.11)')
     &        'WARNING! (', NWARNINGS, '/20) Deviation more than 5E-5',
     &        IVEC, OUT(IVEC), OUT2(IVEC), 1+CBYF1
          ENDIF
        END DO
      ENDIF

      IF( FBRIDGE_MODE .EQ. 1 .OR. FBRIDGE_MODE .LT. 0 ) THEN ! (CppOnly=1 or BothQuiet=-1 or BothDebug=-2)
        DO IVEC=1, VECSIZE_USED
          OUT(IVEC) = OUT2(IVEC) ! use the cudacpp ME instead of the fortran ME!
          SELECTED_HEL(IVEC) = SELECTED_HEL2(IVEC) ! use the cudacpp helicity instead of the fortran helicity!
          SELECTED_COL(IVEC) = SELECTED_COL2(IVEC) ! use the cudacpp color instead of the fortran color!
        END DO
      ENDIF
#endif

      IF ( FIRST_CHID ) THEN
        IF ( MULTI_CHANNEL ) THEN
          WRITE (*,*) 'MULTI_CHANNEL = TRUE'
        ELSE
          WRITE (*,*) 'MULTI_CHANNEL = FALSE'
        ENDIF
        WRITE (*,*) 'CHANNEL_ID =', CHANNEL
        FIRST_CHID = .FALSE.
      ENDIF

      RETURN
      END

      INTEGER FUNCTION GET_NHEL1(HEL, IPART)
C     if hel>0 return the helicity of particule ipart for the selected
C      helicity configuration
C     if hel=0 return the number of helicity state possible for that
C      particle 
      IMPLICIT NONE
      INTEGER HEL,I, IPART
      INCLUDE 'nexternal.inc'
      INTEGER ONE_NHEL(NEXTERNAL)
      INTEGER                 NCOMB
      PARAMETER (             NCOMB=64)
      INTEGER NHEL(NEXTERNAL,0:NCOMB)
      DATA (NHEL(I,0),I=1,6) / 2, 2, 2, 2, 2, 2/
      DATA (NHEL(I,   1),I=1,6) /-1,-1,-1, 1, 1, 1/
      DATA (NHEL(I,   2),I=1,6) /-1,-1,-1, 1, 1,-1/
      DATA (NHEL(I,   3),I=1,6) /-1,-1,-1, 1,-1, 1/
      DATA (NHEL(I,   4),I=1,6) /-1,-1,-1, 1,-1,-1/
      DATA (NHEL(I,   5),I=1,6) /-1,-1,-1,-1, 1, 1/
      DATA (NHEL(I,   6),I=1,6) /-1,-1,-1,-1, 1,-1/
      DATA (NHEL(I,   7),I=1,6) /-1,-1,-1,-1,-1, 1/
      DATA (NHEL(I,   8),I=1,6) /-1,-1,-1,-1,-1,-1/
      DATA (NHEL(I,   9),I=1,6) /-1,-1, 1, 1, 1, 1/
      DATA (NHEL(I,  10),I=1,6) /-1,-1, 1, 1, 1,-1/
      DATA (NHEL(I,  11),I=1,6) /-1,-1, 1, 1,-1, 1/
      DATA (NHEL(I,  12),I=1,6) /-1,-1, 1, 1,-1,-1/
      DATA (NHEL(I,  13),I=1,6) /-1,-1, 1,-1, 1, 1/
      DATA (NHEL(I,  14),I=1,6) /-1,-1, 1,-1, 1,-1/
      DATA (NHEL(I,  15),I=1,6) /-1,-1, 1,-1,-1, 1/
      DATA (NHEL(I,  16),I=1,6) /-1,-1, 1,-1,-1,-1/
      DATA (NHEL(I,  17),I=1,6) /-1, 1,-1, 1, 1, 1/
      DATA (NHEL(I,  18),I=1,6) /-1, 1,-1, 1, 1,-1/
      DATA (NHEL(I,  19),I=1,6) /-1, 1,-1, 1,-1, 1/
      DATA (NHEL(I,  20),I=1,6) /-1, 1,-1, 1,-1,-1/
      DATA (NHEL(I,  21),I=1,6) /-1, 1,-1,-1, 1, 1/
      DATA (NHEL(I,  22),I=1,6) /-1, 1,-1,-1, 1,-1/
      DATA (NHEL(I,  23),I=1,6) /-1, 1,-1,-1,-1, 1/
      DATA (NHEL(I,  24),I=1,6) /-1, 1,-1,-1,-1,-1/
      DATA (NHEL(I,  25),I=1,6) /-1, 1, 1, 1, 1, 1/
      DATA (NHEL(I,  26),I=1,6) /-1, 1, 1, 1, 1,-1/
      DATA (NHEL(I,  27),I=1,6) /-1, 1, 1, 1,-1, 1/
      DATA (NHEL(I,  28),I=1,6) /-1, 1, 1, 1,-1,-1/
      DATA (NHEL(I,  29),I=1,6) /-1, 1, 1,-1, 1, 1/
      DATA (NHEL(I,  30),I=1,6) /-1, 1, 1,-1, 1,-1/
      DATA (NHEL(I,  31),I=1,6) /-1, 1, 1,-1,-1, 1/
      DATA (NHEL(I,  32),I=1,6) /-1, 1, 1,-1,-1,-1/
      DATA (NHEL(I,  33),I=1,6) / 1,-1,-1, 1, 1, 1/
      DATA (NHEL(I,  34),I=1,6) / 1,-1,-1, 1, 1,-1/
      DATA (NHEL(I,  35),I=1,6) / 1,-1,-1, 1,-1, 1/
      DATA (NHEL(I,  36),I=1,6) / 1,-1,-1, 1,-1,-1/
      DATA (NHEL(I,  37),I=1,6) / 1,-1,-1,-1, 1, 1/
      DATA (NHEL(I,  38),I=1,6) / 1,-1,-1,-1, 1,-1/
      DATA (NHEL(I,  39),I=1,6) / 1,-1,-1,-1,-1, 1/
      DATA (NHEL(I,  40),I=1,6) / 1,-1,-1,-1,-1,-1/
      DATA (NHEL(I,  41),I=1,6) / 1,-1, 1, 1, 1, 1/
      DATA (NHEL(I,  42),I=1,6) / 1,-1, 1, 1, 1,-1/
      DATA (NHEL(I,  43),I=1,6) / 1,-1, 1, 1,-1, 1/
      DATA (NHEL(I,  44),I=1,6) / 1,-1, 1, 1,-1,-1/
      DATA (NHEL(I,  45),I=1,6) / 1,-1, 1,-1, 1, 1/
      DATA (NHEL(I,  46),I=1,6) / 1,-1, 1,-1, 1,-1/
      DATA (NHEL(I,  47),I=1,6) / 1,-1, 1,-1,-1, 1/
      DATA (NHEL(I,  48),I=1,6) / 1,-1, 1,-1,-1,-1/
      DATA (NHEL(I,  49),I=1,6) / 1, 1,-1, 1, 1, 1/
      DATA (NHEL(I,  50),I=1,6) / 1, 1,-1, 1, 1,-1/
      DATA (NHEL(I,  51),I=1,6) / 1, 1,-1, 1,-1, 1/
      DATA (NHEL(I,  52),I=1,6) / 1, 1,-1, 1,-1,-1/
      DATA (NHEL(I,  53),I=1,6) / 1, 1,-1,-1, 1, 1/
      DATA (NHEL(I,  54),I=1,6) / 1, 1,-1,-1, 1,-1/
      DATA (NHEL(I,  55),I=1,6) / 1, 1,-1,-1,-1, 1/
      DATA (NHEL(I,  56),I=1,6) / 1, 1,-1,-1,-1,-1/
      DATA (NHEL(I,  57),I=1,6) / 1, 1, 1, 1, 1, 1/
      DATA (NHEL(I,  58),I=1,6) / 1, 1, 1, 1, 1,-1/
      DATA (NHEL(I,  59),I=1,6) / 1, 1, 1, 1,-1, 1/
      DATA (NHEL(I,  60),I=1,6) / 1, 1, 1, 1,-1,-1/
      DATA (NHEL(I,  61),I=1,6) / 1, 1, 1,-1, 1, 1/
      DATA (NHEL(I,  62),I=1,6) / 1, 1, 1,-1, 1,-1/
      DATA (NHEL(I,  63),I=1,6) / 1, 1, 1,-1,-1, 1/
      DATA (NHEL(I,  64),I=1,6) / 1, 1, 1,-1,-1,-1/

      GET_NHEL1 = NHEL(IPART, IABS(HEL))
      RETURN
      END


