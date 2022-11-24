C     This File is Automatically generated by ALOHA 
C     The process calculated in this file is: 
C     Metric(1,4)*Metric(2,3) - Metric(1,3)*Metric(2,4)
C     
      SUBROUTINE VVVV1P0_1(V2, V3, V4, COUP, M1, W1,V1)
      IMPLICIT NONE
      COMPLEX*16 CI
      PARAMETER (CI=(0D0,1D0))
      COMPLEX*16 COUP
      REAL*8 M1
      REAL*8 P1(0:3)
      COMPLEX*16 TMP10
      COMPLEX*16 TMP6
      COMPLEX*16 V1(6)
      COMPLEX*16 V2(*)
      COMPLEX*16 V3(*)
      COMPLEX*16 V4(*)
      REAL*8 W1
      COMPLEX*16 DENOM
      V1(1) = +V2(1)+V3(1)+V4(1)
      V1(2) = +V2(2)+V3(2)+V4(2)
      P1(0) = -DBLE(V1(1))
      P1(1) = -DBLE(V1(2))
      P1(2) = -DIMAG(V1(2))
      P1(3) = -DIMAG(V1(1))
      TMP10 = (V2(3)*V4(3)-V2(4)*V4(4)-V2(5)*V4(5)-V2(6)*V4(6))
      TMP6 = (V3(3)*V2(3)-V3(4)*V2(4)-V3(5)*V2(5)-V3(6)*V2(6))
      DENOM = COUP/(P1(0)**2-P1(1)**2-P1(2)**2-P1(3)**2 - M1 * (M1 -CI
     $ * W1))
      V1(3)= DENOM*(-CI*(TMP6*V4(3))+CI*(V3(3)*TMP10))
      V1(4)= DENOM*(-CI*(TMP6*V4(4))+CI*(V3(4)*TMP10))
      V1(5)= DENOM*(-CI*(TMP6*V4(5))+CI*(V3(5)*TMP10))
      V1(6)= DENOM*(-CI*(TMP6*V4(6))+CI*(V3(6)*TMP10))
      END


