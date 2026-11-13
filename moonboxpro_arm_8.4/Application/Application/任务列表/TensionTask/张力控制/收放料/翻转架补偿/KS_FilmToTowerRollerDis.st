(*@CES
Name=KS_FilmToTowerRollerDis
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=026cf6eb-c0d8-494e-aced-39e104fa3684
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_FilmToTowerRollerDis : INT(*计算料膜到翻料架导向辊的距离|负值代表错误*)
VAR_INPUT
	i_byMaterialPath:BYTE;(*材料行走路径|0:料膜和下个辊外公切线走料
										 1:料膜和下个辊内公切线走料
							PS:放料上裁刀i_byMaterialPath=0
							   放料下裁刀i_byMaterialPath=1
							   收料上裁刀i_byMaterialPath=0
							   收料下裁刀i_byMaterialPath=1*)
	i_rDiam_DeflectorRollPos:REAL;(*翻料架的导向辊圆心运动直径|距离翻转架圆心=该值/2|mm*)
	i_rDiam_DeflectorRoller:REAL;(*翻料架上导向辊的直径|mm*)
	i_rDiam_CurAxis:REAL;(*当前卷径|直径mm*)
	i_rDiam_Tower:REAL;(*翻转架直径mm*)
	i_rDiam_NextRoller:REAL;(*翻转架后第一个导辊直径mm*)
	i_rXPos_NextRoller:REAL;(*mm*)
	i_rYPos_NextRoller:REAL;(*mm*)
	i_lrTheta_Cur:LREAL;(*当前弧度值*)
	i_prFilmToTowerRollerDis:POINTER TO REAL;(*mm*)
	i_pxFilmTouchRoller:POINTER TO BOOL;(**)
END_VAR
VAR
	iRtn: INT;
	lrRadius_DeflectorRollPos:LREAL;(*翻料架的导向辊圆心运动半径|距离翻转架圆心=该值/2|m*)
	lrRadius_DeflectorRoller:LREAL;(*翻料架上导向辊的直径|m*)
	lrRadius_CurAxis:LREAL;(*当前轴半径|m*)
	lrRadius_Tower: LREAL;(*翻转架半径|M*)
	lrRadius_NextRoller: LREAL;(*下个导辊的半径|M*)
	lrX_NextRoller: LREAL;(*下个辊的x位置|m*)
	lrY_NextRoller: LREAL;(*下个辊的Y位置|m*)
	lrTheta_Cur: LREAL;(*当前弧度*)
	lrFilmToTowerRollerDis:LREAL;
	lrIy: LREAL;
	lrIx: LREAL;
	lrUx: LREAL;
	lrUy: LREAL;
	lrDelta: LREAL;
	lrp1: LREAL;
	lrp2: LREAL;
	lrq: LREAL;
	lrA: LREAL;
	lrB: LREAL;
	lrC: LREAL;
	lrD: LREAL;
	lrD0: LREAL;
	lrD1: LREAL;
	xFilmTouchRoller: BOOL;(*料膜接触到了辊子*)
END_VAR
{IMPLEMENTATION}
(*计算公式:
Ix、Iy-导向辊的坐标 Ix=i_rDiam_DeflectorRollPos/2*SIN(i_rTheta_Cur)；
				    Iy=-i_rDiam_DeflectorRollPos/2*Cos(i_rTheta_Cur);
Ux、Uy当前轴的坐标 Ux=i_rDiam_Tower/2*Cos(i_rTheta_Cur);
				   Uy=i_rDiam_Tower/2*Sin(i_rTheta_Cur);
计算启动启动的条件为Ux<Ix;
Delta=(Ux-i_rXPos_NextRoller)^2+(Uy-i_rYPos_NextRoller)^2-(i_rDiam_CurAxis-i_rDiam_NextRoller)^2/4;
P1=i_rDiam_CurAxis/2*(i_rXPos_NextRoller^2+i_rYPos_NextRoller^2-i_rXPos_NextRoller*Ux-i_rYPos_NextRoller*Uy);
P2=i_rDiam_NextRoller/2*(Ux^2+Uy^2-i_rXPos_NextRoller*Ux-i_rYPos_NextRoller*Uy);
q=Ux*i_rYPos_NextRoller-Uy*i_rXPos_NextRoller;
A=(i_rXPos_NextRoller-Ux)*(i_rDiam_CurAxis-i_rDiam_NextRoller)/2+(Uy-i_rYPos_NextRoller)*SQRT(Delta);
B=(i_rYPos_NextRoller-Uy)*(i_rDiam_CurAxis-i_rDiam_NextRoller)/2+(i_rXPos_NextRoller-Ux)*SQRT(Delta);
C=-P1-P2+q*SQRT(Delta);
D0=A*Ix+B*Iy+C;
D=D0/SQRT(A^2+B^2);
*)
IF i_pxFilmTouchRoller<>0 THEN
	xFilmTouchRoller:=i_pxFilmTouchRoller^;
END_IF

lrRadius_CurAxis:=i_rDiam_CurAxis/1000/2;
lrRadius_Tower:=i_rDiam_Tower/1000/2;
lrRadius_NextRoller:=i_rDiam_NextRoller/1000/2;
lrX_NextRoller:=i_rXPos_NextRoller/1000;
lrY_NextRoller:=i_rYPos_NextRoller/1000;
lrRadius_DeflectorRollPos:=i_rDiam_DeflectorRollPos/1000/2;
lrRadius_DeflectorRoller:=i_rDiam_DeflectorRoller/1000/2;
lrTheta_Cur:=i_lrTheta_Cur;
lrFilmToTowerRollerDis:=0;

CASE i_byMaterialPath OF
	1:(*内公切线|D是正值代表远离-下裁刀方式*)
		(*计算导向辊的坐标*)
		lrIx:=-lrRadius_DeflectorRollPos*SIN(lrTheta_Cur);
		lrIy:=lrRadius_DeflectorRollPos*COS(lrTheta_Cur);
		(*计算当前轴的坐标*)
		lrUx:=lrRadius_Tower*COS(lrTheta_Cur);
		lrUy:=lrRadius_Tower*SIN(lrTheta_Cur);
		IF lrUx < lrIx THEN(*启动计算*)
			lrDelta:=EXPT((lrUx-lrX_NextRoller),2)+EXPT((lrUy-lrY_NextRoller),2)-EXPT((lrRadius_CurAxis+lrRadius_NextRoller),2);
			IF lrDelta>=0 THEN
				lrp1:=lrRadius_CurAxis*(EXPT(lrX_NextRoller,2)+EXPT(lrY_NextRoller,2)-lrX_NextRoller*lrUx-lrY_NextRoller*lrUy);
				lrp2:=lrRadius_NextRoller*(EXPT(lrUx,2)+EXPT(lrUy,2)-lrX_NextRoller*lrUx-lrY_NextRoller*lrUy);
				lrq:=lrUx*lrY_NextRoller-lrUy*lrX_NextRoller;
				lrA:=(lrX_NextRoller-lrUx)*(lrRadius_CurAxis+lrRadius_NextRoller)-(lrUy-lrY_NextRoller)*SQRT(lrDelta);
				lrB:=(lrY_NextRoller-lrUy)*(lrRadius_CurAxis+lrRadius_NextRoller)-(lrX_NextRoller-lrUx)*SQRT(lrDelta);
				lrC:=-lrp1+lrp2-lrq*SQRT(lrDelta);
				lrD0:=lrA*lrIx+lrB*lrIy+lrC;
				lrD1:=EXPT(lrA,2)+EXPT(lrB,2);
				IF lrD1>0 THEN
					lrD:=(lrD0)/SQRT(lrD1);(*m*)
				ELSE
					iRtn:=-3;
				END_IF
			ELSE
				iRtn:=-2;
			END_IF
		ELSE
			iRtn:=-1;
		END_IF
ELSE(*外公切线|D是负值代表远离-上裁刀方式*)
		(*计算导向辊的坐标*)
		lrIx:=lrRadius_DeflectorRollPos*SIN(lrTheta_Cur);
		lrIy:=-lrRadius_DeflectorRollPos*COS(lrTheta_Cur);
		(*计算当前轴的坐标*)
		lrUx:=lrRadius_Tower*COS(lrTheta_Cur);
		lrUy:=lrRadius_Tower*SIN(lrTheta_Cur);
		IF lrUx < lrIx THEN(*启动计算*)
			lrDelta:=EXPT((lrUx-lrX_NextRoller),2)+EXPT((lrUy-lrY_NextRoller),2)-EXPT((lrRadius_CurAxis-lrRadius_NextRoller),2);
			IF lrDelta>=0 THEN
				lrp1:=lrRadius_CurAxis*(EXPT(lrX_NextRoller,2)+EXPT(lrY_NextRoller,2)-lrX_NextRoller*lrUx-lrY_NextRoller*lrUy);
				lrp2:=lrRadius_NextRoller*(EXPT(lrUx,2)+EXPT(lrUy,2)-lrX_NextRoller*lrUx-lrY_NextRoller*lrUy);
				lrq:=lrUx*lrY_NextRoller-lrUy*lrX_NextRoller;
				lrA:=(lrX_NextRoller-lrUx)*(lrRadius_CurAxis-lrRadius_NextRoller)+(lrUy-lrY_NextRoller)*SQRT(lrDelta);
				lrB:=(lrY_NextRoller-lrUy)*(lrRadius_CurAxis-lrRadius_NextRoller)+(lrX_NextRoller-lrUx)*SQRT(lrDelta);
				lrC:=-lrp1-lrp2+lrq*SQRT(lrDelta);
				lrD0:=lrA*lrIx+lrB*lrIy+lrC;
				lrD1:=EXPT(lrA,2)+EXPT(lrB,2);
				IF lrD1>0 THEN
					lrD:=(lrD0)/SQRT(lrD1);(*m*)
				ELSE
					iRtn:=-3;
				END_IF
			ELSE
				iRtn:=-2;
			END_IF
		ELSE
			iRtn:=-1;
		END_IF
END_CASE


IF iRtn=0 THEN(*算出来了*)
	(*增加了0.01M的回差*)
	IF NOT xFilmTouchRoller THEN
		IF lrD+lrRadius_DeflectorRoller>=0 THEN
			xFilmTouchRoller:=TRUE;
		END_IF
	ELSIF lrD+lrRadius_DeflectorRoller<-0.01 THEN
		xFilmTouchRoller:=FALSE;
	END_IF
ELSE
	xFilmTouchRoller:=FALSE;
END_IF


IF i_pxFilmTouchRoller<>0 THEN
	i_pxFilmTouchRoller^:=xFilmTouchRoller;
END_IF

IF i_prFilmToTowerRollerDis<>0 THEN
	i_prFilmToTowerRollerDis^:=LREAL_TO_REAL(lrD*1000.0);
END_IF
KS_FilmToTowerRollerDis:=iRtn;