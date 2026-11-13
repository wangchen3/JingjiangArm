(*@CES
Name=KS_CalcFilmLenth_TowerToNextRoller
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=4de748ae-c124-4dda-9073-dd74e9313ddf
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CalcFilmLenth_TowerToNextRoller : INT(*计算放料架到第一个辊之间的料长*)
VAR_INPUT
(*	i_xDir_Rev:BOOL;(*方向取反|默认翻转架运动和绝对值位置变化方向一致|逆时针转动为正方向。*)*)
	i_dwAbsPos_0Rad:DWORD;(*写入0弧度对应的绝对值位置*)
	i_dwAbsPos_Cur:DWORD;(*当前绝对位置*)

	i_iTime_PlcCycle:INT:=20;
	i_rDiam_CurAxis:REAL;(*当前卷径|直径mm*)
	i_rDiam_Tower:REAL;(*翻转架直径mm*)
	i_rDiam_NextRoller:REAL;(*翻转架后第一个导辊直径mm*)

	i_rXPos_NextRoller:REAL;(*mm*)
	i_rYPos_NextRoller:REAL;(*mm*)
	i_lrTheta_Cur:LREAL;(*当前弧度值*)
	i_lrLastTheta:LREAL;(*上个周期的弧度值*)
	i_plrDeltaW_RPMIN:POINTER TO LREAL;
	(*2022.5.17.101635*)
	i_rDiam_DeflectorRollPos:REAL;(*翻料架的导向辊圆心运动直径|距离翻转架圆心=该值/2|mm*)
	i_rDiam_DeflectorRoller:REAL;(*翻料架上导向辊的直径|mm*)
	i_xFilmTouchRoller:BOOL;(*料膜接触到导向辊标志*)
	i_byMaterialPath:BYTE;(*材料行走路径|0:料膜和下个辊外公切线走料
										 1:料膜和下个辊内公切线走料
							PS:放料上裁刀i_byMaterialPath=0
							   放料下裁刀i_byMaterialPath=1
							   收料上裁刀i_byMaterialPath=0
							   收料下裁刀i_byMaterialPath=1*)
END_VAR
VAR
	lrTemp:LREAL;
	lrTemp1:LREAL;
	lrC: LREAL;
	lrts: LREAL;(*采样周期|s*)
	lrRadius_CurAxis:LREAL;(*当前轴半径|m*)
	lrRadius_Tower: LREAL;(*翻转架半径|M*)
	lrRadius_NextRoller: LREAL;(*下个导辊的半径|M*)
	lrX_NextRoller: LREAL;(*下个辊的x位置|m*)
	lrY_NextRoller: LREAL;(*下个辊的Y位置|m*)
	lrRadius_DeflectorRollPos:LREAL;(*翻料架的导向辊圆心运动半径|距离翻转架圆心=该值/2|m*)
	lrRadius_DeflectorRoller:LREAL;(*翻料架上导向辊的半径|m*)
	dwAbsPos_0Rad: DWORD;(*写入0弧度对应的绝对值位置*)
	lrTheta_Cur: LREAL;(*当前弧度*)
	lrPi:LREAL:=3.1415926;
(*	dwAbsPos_Cycle:DWORD:=131072;*)
	iErr: INT;
	lrDeltFilmLen: LREAL;
	lrLastTheta_Cur: LREAL;
	lrDeltW: LREAL;
	lrDeltW_RPMIN: LREAL;
END_VAR
{IMPLEMENTATION}
dwAbsPos_0Rad:=i_dwAbsPos_0Rad;
lrLastTheta_Cur:=i_lrLastTheta;
lrTheta_Cur:=i_lrTheta_Cur;



(*根据手册公式实现*)
(*根据手册单位进行对应转换*)
lrts:=INT_TO_LREAL(i_iTime_PlcCycle)/1000;
lrRadius_CurAxis:=i_rDiam_CurAxis/1000/2;
lrRadius_Tower:=i_rDiam_Tower/1000/2;
lrRadius_NextRoller:=i_rDiam_NextRoller/1000/2;
lrX_NextRoller:=i_rXPos_NextRoller/1000;
lrY_NextRoller:=i_rYPos_NextRoller/1000;
lrRadius_DeflectorRollPos:=i_rDiam_DeflectorRollPos/1000/2;
lrRadius_DeflectorRoller:=i_rDiam_DeflectorRoller/1000/2;

(*lrC的计算不考虑内切还是外切都是按照外切计算长度|两种的变化率保持一致*)
IF NOT i_xFilmTouchRoller THEN(*未接触到导向辊|*)
	lrC:=lrX_NextRoller*lrX_NextRoller+lrY_NextRoller*lrY_NextRoller+
		lrRadius_Tower*lrRadius_Tower-
		lrRadius_NextRoller*lrRadius_NextRoller-
		lrRadius_CurAxis*lrRadius_CurAxis+
		2*lrRadius_NextRoller*lrRadius_CurAxis;
ELSE(*接触到导向辊*)
	lrC:=lrX_NextRoller*lrX_NextRoller+lrY_NextRoller*lrY_NextRoller+
		lrRadius_DeflectorRollPos*lrRadius_DeflectorRollPos+
		2*lrRadius_DeflectorRoller*lrRadius_NextRoller-
		lrRadius_DeflectorRoller*lrRadius_DeflectorRoller-
		lrRadius_NextRoller*lrRadius_NextRoller;
END_IF
IF lrC<=0 THEN
	iErr:=-1;
END_IF


IF iErr=0 THEN
	CASE i_byMaterialPath OF
		1:(*内公切线走料|下裁刀方式*)
			IF NOT i_xFilmTouchRoller THEN(*未接触到导向辊|公式和外公切线使用同样的公式*)
				lrTemp:=lrC-2*lrRadius_Tower*(lrX_NextRoller*COS(lrTheta_Cur)+lrY_NextRoller*SIN(lrTheta_Cur));
				lrTemp1:=lrC-2*lrRadius_Tower*(lrX_NextRoller*COS(lrLastTheta_Cur)+lrY_NextRoller*SIN(lrLastTheta_Cur));
			ELSE(*接触到导向辊*)
				lrTemp:=lrC+2*lrRadius_DeflectorRollPos*(lrX_NextRoller*SIN(lrTheta_Cur)-lrY_NextRoller*COS(lrTheta_Cur));
				lrTemp1:=lrC+2*lrRadius_DeflectorRollPos*(lrX_NextRoller*SIN(lrLastTheta_Cur)-lrY_NextRoller*COS(lrLastTheta_Cur));
			END_IF
	ELSE(*外公切线走料|上裁刀方式*)
		IF NOT i_xFilmTouchRoller THEN(*未接触到导向辊|*)
			lrTemp:=lrC-2*lrRadius_Tower*(lrX_NextRoller*COS(lrTheta_Cur)+lrY_NextRoller*SIN(lrTheta_Cur));
			lrTemp1:=lrC-2*lrRadius_Tower*(lrX_NextRoller*COS(lrLastTheta_Cur)+lrY_NextRoller*SIN(lrLastTheta_Cur));
		ELSE(*接触到导向辊*)
			lrTemp:=lrC-2*lrRadius_DeflectorRollPos*(lrX_NextRoller*SIN(lrTheta_Cur)-lrY_NextRoller*COS(lrTheta_Cur));
			lrTemp1:=lrC-2*lrRadius_DeflectorRollPos*(lrX_NextRoller*SIN(lrLastTheta_Cur)-lrY_NextRoller*COS(lrLastTheta_Cur));
		END_IF
	END_CASE

	IF lrTemp>=0 THEN
		lrTemp:=SQRT(lrTemp);
	ELSE
		iErr:=-2;
	END_IF

	IF lrTemp1>=0 THEN
		lrTemp1:=SQRT(lrTemp1);
	ELSE
		iErr:=-3;
	END_IF

	IF iErr=0 THEN
		lrDeltFilmLen:=lrTemp-lrTemp1;
	END_IF

	IF lrRadius_CurAxis<>0 THEN
		lrDeltW:=lrDeltFilmLen/lrts/lrRadius_CurAxis;
	END_IF

	lrDeltW_RPMIN:=lrDeltW*60/2/lrPi;
END_IF


IF i_plrDeltaW_RPMIN<>0 THEN
	i_plrDeltaW_RPMIN^:=lrDeltW_RPMIN;
END_IF

KS_CalcFilmLenth_TowerToNextRoller:=iErr;