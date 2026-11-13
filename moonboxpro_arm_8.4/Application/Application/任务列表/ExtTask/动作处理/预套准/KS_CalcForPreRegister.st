(*@CES
Name=KS_CalcForPreRegister
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=6960c73a-5817-444f-97ca-275637423b82
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CalcForPreRegister : WORD(*高8位返回轴号,低8位返回错误*)
(*2023.11.27.104852 欧诺预套准结构同步*)
(*2024.7.11.160354 机组间料长增加翻料架@一般一台机器只有一个翻料架|不支持2个以上翻料架*)
(*那个翻料架应该在当前色和前一色之间*)
(*2024.8.2.173238 调整翻料架料长计算方式*)
VAR_INPUT
	i_iMechanicalType: INT; (*结构类型*)
	i_iGrpAxisNum_Pu: INT; (*色组轴数量*)
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT; (*系内所有轴的列表*)
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStMechanicalParamBuf: POINTER TO ARRAY [1..5] OF StMechanicalParamBuf; (*机械参数区域*)
	i_iGrpId:INT;(*2024.7.11.164625 输入系id*)
	i_xFilpSwitch:BOOL;(*翻转架开关*)
END_VAR
VAR
	iN: INT;
	iAxisId: INT;

	(*摆臂式机械结构*)
	pstStMechanicalParam_01: POINTER TO StMechanicalParam_01;
	pstStMechanicalParam_03: POINTER TO StMechanicalParam_03;
	pstStMechanicalParam_05: POINTER TO StMechanicalParam_05; (*欧诺直压式结构|2023.07.10.142011*)
	x2,y2: LREAL;
	x4,y4: LREAL;
	lrLCTD1,lrLCTD2,lrLCTD3: LREAL;
	lrVar1,lrVar2,lrVar3,lrVar4: LREAL;
	lrLCirDis_pt1pt3: LREAL; (*pt1到pt3的圆心距*)
	lrLCirDis_pt2pt4: LREAL;
	lrLCirDis_pt2pt5: LREAL;
	lrLCirDis_pt2pt6: LREAL;
	lrLCirDis_pt4pt5: LREAL;
	lrLCirDis_pt4pt6: LREAL;
	lrAng_theta1: LREAL;
	lrAng_q,lrAng_q0: LREAL;
	lrAng_q2: LREAL;
	lrArc_pt5,lrArc_pt4,lrArc_pt2,lrArc_pt6: LREAL;
	lrAng_alpha,lrAng_beta,lrAng_theta,lrAng_delta: LREAL;

	alrConstantLength:ARRAY [1..MAX_UNIT_NUM] OF  LREAL;(*可变料长数组*)
	(*直压式结构*)
	pstStMechanicalParam_02: POINTER TO StMechanicalParam_02; (*机械结构2*)
	lrTotalLength:LREAL;(*总料长*)
	wResult:WORD;
	//pstStAxisParam: POINTER TO StAxisParam;

	lrX_PressRoller: LREAL;
	lrY_PressRoller: LREAL;
	lrLCirDis_pt5ptR: LREAL;
	lrLCirDis_pt6ptR: LREAL;
	lrLCirDis_pt5pt6: LREAL;
	lrAng_65R: LREAL;
	lrAng_5R6: LREAL;
	lrAng_AlphaB: LREAL;
	lrAng_AlphaC: LREAL;
	lrAng_AlphaH: LREAL;
	lrAng_AlphaK: LREAL;
	lrAng_GammaA: LREAL;
	lrAng_GammaB: LREAL;
	lrArc_3: LREAL;
	lrArc_1: LREAL;
	lrArc_2: LREAL;
	X_OnRubberROller: BOOL;
	XH1_Flag: BOOL;		(*胶辊安装在孔H1*)
	XH2_Flag: BOOL;
	lrLCirDis_pt3pt5: LREAL;
	IrO3M: LREAL;
	lrLCirDis_pt2pt3: LREAL;
	IrAngle_O3O2U: LREAL;
	IrAngle_O4O2V: LREAL;
	IrAngle_O3O2O4: LREAL;
	IrAngle_O2O3O5: LREAL;
	IrAngle_O2O3I: LREAL;
	IrAngle_HO3M: LREAL;
	IrAngle_O2O4O6: LREAL;
	IrAngle_O2O4P: LREAL;
	IrAngle_O6O4N: LREAL;
	IrAngle_HO3I: LREAL;
	IrAngle_NO4Q: LREAL;
	IrAngle_WO5S: LREAL;
	IrAngle_ZO5W: LREAL;
	IrArc_UV: LREAL;
	IrArc_HI: LREAL;
	IrArc_NQ: LREAL;
	IrArc_WS: LREAL;
	IrIU: LREAL;
	IrQV: LREAL;
	IrHS: LREAL;
	IrNT: LREAL;
	lrAng_56R:LREAL;
	lrLCirDis_pt3pt6:LREAL;
	IrAngle_UO2V:LREAL;
	IrAngle_O4O3O5:LREAL;
	IrAngle_O3O4O6: LREAL;
	lrLCirDis_pt3pt4: LREAL;
	IrHM: LREAL;
(*2023.07.10.142055|欧诺直压式*)
	lrLCirDis_pt1pt2_LZY : LREAL;
	lrLCirDis_pt2pt3_LZY : LREAL;
	lrLCirDis_pt3pt4_LZY : LREAL;
	lrLCirDis_pt4pt5_LZY : LREAL;
	lrLCirDis_pt5pt6_LZY : LREAL;
	lrLCirDis_pt1pt3_LZY: LREAL;	(*  *)
	lrLCirDis_pt2pt4_LZY: LREAL;	(*  *)
	lrLCirDis_pt3pt5_LZY : LREAL;
	lrLCirDis_pt4pt6_LZY : LREAL;

	lrLCTD1_LZY : LREAL;
	lrLCTD2_LZY : LREAL;
	lrLCTD3_LZY : LREAL;
	lrLCTD4_LZY : LREAL;
	lrLCTD5_LZY : LREAL;
	lrWL1 :LREAL;
	lrWL2 :LREAL;
	lrWL3 :LREAL;
	lrWL4 :LREAL;

	lrWR1 :LREAL;
	lrWR2 :LREAL;
	lrWR3 :LREAL;
	lrWR4 :LREAL;

	lrWU1 :LREAL;
	lrWU2 :LREAL;
	lrWU3 :LREAL;
	lrWU4 :LREAL;
	lrArc1 : LREAL;(*弧长*)
	lrArc2 : LREAL;
	lrArc3 : LREAL;
	lrArc4 : LREAL;
(*2023.11.17.102855*)
	rY3_LD:REAL;

	iError:INT;
	rCentre1_2: REAL; (*棍1和棍2中心的距离*)
	rCentre2_3: REAL;
	rCentre3_4: REAL;
	rCentre1_3: REAL;
	rCentre1_4: REAL;
	rCentre2_4: REAL;
	rCentre3_6: REAL;
	rCentre4_6: REAL;
	rlength2_3: REAL; (*棍2和棍3中心之间的距离,固定不变的*)
	rArcLength2: REAL;  (*棍2上的料长、棍2的弧长*)
	rArcLength3: REAL;
	rArcLength4: REAL;
	rradian_a1: REAL; (*棍1中心和上切点相连的直线与棍1、2中心连线的夹角对应的弧度*)
	rradian_a2: REAL; (*棍1、2中心相连的直线与棍2、3中心相连的直线的夹角对应的弧度*)
	rradian_a3: REAL; (*棍2下切点与棍3左切点相连的直线与棍2、3中心相连的直线的夹角对应的弧度*)
	rradian_a4: REAL;
	rradian_b1: REAL; (*棍3中心与左切点相连的直线与棍2、3中心连线的夹角对应的弧度*)
	rradian_b2: REAL; (*棍2、3中心相连的直线与棍3、4中心相连的直线的夹角对应的弧度*)
	rradian_b3: REAL; (*棍3右切点与棍4下切点相连的直线与棍3、4中心相连的直线的夹角对应的弧度*)
	rradian_c1: REAL; (*棍3右切点与棍4下切点相连的直线与棍3、4中心连线的夹角对应的弧度*)
	rradian_c2: REAL; (*棍3、4中心相连的直线与棍4、6中心相连的直线的夹角对应的弧度*)
	rradian_c3: REAL; (*棍4上切点与棍6下切点相连的直线与棍4、6中心相连的直线的夹角对应的弧度*)
	rradian_c4: REAL;
	rlengthI: REAL;       (*棍1和2间的料长*)

	rlengthII: REAL;      (*棍2和3间的料长*)
	rlengthIII: REAL;	  (*棍3和4间的料长*)
	rLrength4_6: REAL; (*棍4和棍6之间的料长*)
	rTotallength: REAL;   (*总可变料长*)
	rlengthI1: REAL;

	rradian_d1: REAL; (*棍1、2中心相连的直线与棍1的Y1之间的夹角所对应的弧度------2022.10.25.155501*)
	rradian_d2: REAL; (*棍1、2中心相连的直线与棍1中心和下切点相连的直线夹角对应的弧度*)
	rlengthI2: REAL;  (*棍1下切点与棍2中心之间的距离-------2022.10.25.155433*)
	rArcLength1: REAL;  (*棍1上的料长、棍1的弧长--------2022.10.25.155406*)
	
	//2025.12.24.133817 | + | 秦华程序增加结构6
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;
	iUnitValid : INT;
	lrTemp_Qinhua : LREAL;
	lrPreReg_Len_V : LREAL;
	xUnitValid : BOOL;
	
	//品字形 2026.03.10.113914 Hou.N
	rPrRadius:REAL;
	rBrRadius:REAL;
	rHypotenuse:REAL;
	alrAngle_Br: ARRAY [1..MAX_UNIT_NUM] OF  REAL;//底辊压印点和水平的夹角,以水平为基准点
	alrArc_length_Br:ARRAY [1..MAX_UNIT_NUM] OF  REAL;
	lrTemp: LREAL;
	
	(*2026.08.27.095609*)
	(*欧诺预套准*)
	rPlateR:REAL;(*[AI修改20260827]版辊半径|由本轴rGirth_PrnRoller/π/2推算,替代已删除的rD0/2*)
	rY3:REAL;(*[AI修改20260829]辊3辊心高=动态|Y0+版半径+D3/2,随版径浮动*)
	rL2_3:REAL;(*[AI修改20260829]辊2-3垂直中心距=动态派生|rY2-rY3|原为静态结构体字段*)
	rd1:REAL;(*D1与D2的圆心距*)
	rd2:REAL;(*D2与D3的圆心距*)
	rd3:REAL;(*D3与D4的圆心距*)
	rd4:REAL;(*D1与D3的圆心距*)
	rd5:REAL;(*D2与D4的圆心距*)
	rCenter_To_tangent1:REAL;(*D1圆心与D2切点的距离*)
	rCenter_To_tangent2:REAL;(*D3圆心与D2切点的距离*)
	rCenter_To_tangent3:REAL;(*D2圆心与D3切点的距离*)
	rCenter_To_tangent4:REAL;(*D4圆心与D3切点的距离*)
	rLength1:REAL;(*D1与D2之间料长*)
	rArcLen1:REAL;(*D2辊上的料长-弧长*)
	rLength2:REAL;(*D2与D3之间料长*)
	rArcLen2:REAL;(*D3辊上的料长-弧长*)
	rLength3:REAL;(*D3与D4之间料长*)
	rArc1:REAL;(*角1对应的弧长1*)
	rArc2:REAL;(*角2对应的弧长2*)
	rArc3:REAL;(*角3对应的弧长3*)
	rArc5:REAL;(*角5对应的弧长5*)
	rArc6:REAL;(*角6对应的弧长6*)
	rArc7:REAL;(*角7对应的弧长7*)
	rAngle1:REAL;(*角1*)
	rAngle2:REAL;(*角2*)
	rAngle3:REAL;(*角3*)
	rAngle4:REAL;(*角4-D2所求弧面料长对应的角*)
	rAngle5:REAL;(*角5*)
	rAngle6:REAL;(*角6*)
	rAngle7:REAL;(*角7*)
	rAngle8:REAL;(*角8-D3所求弧面料长对应的角*)
	
END_VAR

{IMPLEMENTATION}
wResult:= 0;
IF i_pstStSysParam<>0 AND
	i_pastStMechanicalParamBuf<>0 AND
	(i_iGrpAxisNum_Pu>=1 AND i_iGrpAxisNum_Pu<=MAX_UNIT_NUM) AND
	(i_iGrpId=1 OR i_iGrpId=2 ) THEN
	CASE i_iMechanicalType OF
	1: (*摆臂机械结构*)
		pstStMechanicalParam_01:= ADR(i_pastStMechanicalParamBuf^[1].abyBuf);
		IF pstStMechanicalParam_01^.lrX1<0.1 OR pstStMechanicalParam_01^.lry1<0.1 OR  pstStMechanicalParam_01^.lrx3<0.1
			OR  pstStMechanicalParam_01^.lry3<0.1 OR  pstStMechanicalParam_01^.lrx5<0.1 OR  pstStMechanicalParam_01^.lry5<0.1
			OR  pstStMechanicalParam_01^.lrx6<0.1  OR  pstStMechanicalParam_01^.lry6<0.1 THEN
			wResult:=16#FF01;
			RETURN;
		END_IF
		
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iAxisId:= i_aiGrpAxisList[iN];
			lrVar1:= (pstStMechanicalParam_01^.lrX1 - pstStMechanicalParam_01^.lrX3);
			lrVar2:= (pstStMechanicalParam_01^.lrY1 - pstStMechanicalParam_01^.lrY3);
			lrLCirDis_pt1pt3:= SQRT(lrVar1*lrVar1 + lrVar2*lrVar2);
			lrVar1:= lrLCirDis_pt1pt3;
			lrVar2:= (pstStMechanicalParam_01^.lrL2);
			lrVar3:= ((i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller)/gc_lrPI + (pstStMechanicalParam_01^.lrDR))/2;

			IF lrVar1=0 OR lrVar2=0 OR lrLCirDis_pt1pt3=0 THEN
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0002;
				EXIT;
			END_IF

			lrVar4:= (lrVar1*lrVar1+lrVar2*lrVar2-lrVar3*lrVar3) / (2*lrVar1*lrVar2);
			IF  ABS(lrVar4)>1 THEN
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0003;
				EXIT;
			END_IF

			lrAng_q:= ACOS( (lrVar1*lrVar1+lrVar2*lrVar2-lrVar3*lrVar3) / (2*lrVar1*lrVar2) ); (*余弦定理*)

			lrVar4:=(pstStMechanicalParam_01^.lrY3-pstStMechanicalParam_01^.lrY1) / lrLCirDis_pt1pt3 ;
			IF  ABS(lrVar4)>1 THEN
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0004;
				EXIT;
			END_IF
			lrAng_q0:= ASIN( (pstStMechanicalParam_01^.lrY3-pstStMechanicalParam_01^.lrY1) / lrLCirDis_pt1pt3 );
			lrAng_theta1:= lrAng_q - lrAng_q0; (*如果pt3高过pt2,则包角相减<0，并不会影响到pt2的计算*)

			x2:= pstStMechanicalParam_01^.lrX3 + (pstStMechanicalParam_01^.lrL2)*COS(lrAng_theta1);
			y2:= pstStMechanicalParam_01^.lrY3 + (pstStMechanicalParam_01^.lrL2)*SIN(lrAng_theta1);

			lrAng_q2:= gc_lrPI - (pstStMechanicalParam_01^.lrA)*(gc_lrPI/180.0) - lrAng_theta1;

			x4:= pstStMechanicalParam_01^.lrX3-(pstStMechanicalParam_01^.lrL1)*COS(lrAng_q2);
			y4:= pstStMechanicalParam_01^.lrY3+(pstStMechanicalParam_01^.lrL1)*SIN(lrAng_q2);

	        (*切线段长度*)
			lrLCTD1:= KS_CalcCircleTangentDistance(
				pstStMechanicalParam_01^.lrX5, pstStMechanicalParam_01^.lrY5, pstStMechanicalParam_01^.lrD1,
				x4, y4, pstStMechanicalParam_01^.lrD2,
				FALSE);

			lrLCTD2:= KS_CalcCircleTangentDistance(
				x4, y4, pstStMechanicalParam_01^.lrD2,
				x2, y2, pstStMechanicalParam_01^.lrDR,
				TRUE);

			lrLCTD3:= KS_CalcCircleTangentDistance(
				x2, y2, pstStMechanicalParam_01^.lrDR,
				pstStMechanicalParam_01^.lrX6, pstStMechanicalParam_01^.lrY6, pstStMechanicalParam_01^.lrD3,
				TRUE);

	        (*临近的圆心距*)
			lrVar1:= x2-x4;
	        lrVar2:= y2-y4;
	        lrLCirDis_pt2pt4:= SQRT( lrVar1*lrVar1 + lrVar2*lrVar2 );

	        lrVar1:= x2 - (pstStMechanicalParam_01^.lrX5);
	        lrVar2:= y2 - (pstStMechanicalParam_01^.lrY5);
	        lrLCirDis_pt2pt5:= SQRT( lrVar1*lrVar1 + lrVar2*lrVar2 );

	        lrVar1:= x2 - (pstStMechanicalParam_01^.lrX6);
	        lrVar2:= y2 - (pstStMechanicalParam_01^.lrY6);
	        lrLCirDis_pt2pt6:= SQRT( lrVar1*lrVar1 + lrVar2*lrVar2 );

	        lrVar1:= x4 - (pstStMechanicalParam_01^.lrX6);
	        lrVar2:= y4 - (pstStMechanicalParam_01^.lrY6);
	        lrLCirDis_pt4pt6:= SQRT( lrVar1*lrVar1 + lrVar2*lrVar2 );

	        lrVar1:= x4 - (pstStMechanicalParam_01^.lrX5);
	        lrVar2:= y4 - (pstStMechanicalParam_01^.lrY5);
	        lrLCirDis_pt4pt5:= SQRT( lrVar1*lrVar1 + lrVar2*lrVar2 );

			IF lrLCirDis_pt4pt5=0 OR
				lrLCirDis_pt2pt4=0 OR
				lrLCirDis_pt2pt6=0 THEN (*2017-09-05 11:26:10|*)
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0005;
				EXIT;
			END_IF
	        lrVar1:= (pstStMechanicalParam_01^.lrX5)-x4;
	        lrVar2:= ((pstStMechanicalParam_01^.lrD1) + (pstStMechanicalParam_01^.lrD2))/2.0;
			lrVar4:=lrVar1/lrLCirDis_pt4pt5;
			IF  ABS(lrVar4)>1 THEN
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0006;
				EXIT;
			END_IF

			lrVar4:=lrVar2/lrLCirDis_pt4pt5;
			IF  ABS(lrVar4)>1 THEN
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0007;
				EXIT;
			END_IF
	        lrAng_alpha:= ASIN(lrVar1/lrLCirDis_pt4pt5) + ASIN(lrVar2/lrLCirDis_pt4pt5); (*pt5弧角*)

	        lrVar1:= ((pstStMechanicalParam_01^.lrDR) - (pstStMechanicalParam_01^.lrD2))/2.0;
	        lrVar2:= x2-x4;
			lrVar4:=lrVar1/lrLCirDis_pt2pt4;
			IF  ABS(lrVar4)>1 THEN
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0008;
				EXIT;
			END_IF

			lrVar4:=lrVar2/lrLCirDis_pt2pt4;
			IF  ABS(lrVar4)>1 THEN
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0009;
				EXIT;
			END_IF
	        lrAng_beta:= ACOS(lrVar1/lrLCirDis_pt2pt4) - ACOS(lrVar2/lrLCirDis_pt2pt4); (*与alpha合并构成pt4弧角*)

	        lrVar1:= ((pstStMechanicalParam_01^.lrDR) - (pstStMechanicalParam_01^.lrD3))/2.0;
	        lrVar2:= (pstStMechanicalParam_01^.lrX6) - x2;
			lrVar4:=lrVar1/lrLCirDis_pt2pt6;
			IF  ABS(lrVar4)>1 THEN
				wResult:=SHL(INT_TO_WORD(iN),8)+16#000A;
				EXIT;
			END_IF

			lrVar4:=lrVar2/lrLCirDis_pt2pt6;
			IF  ABS(lrVar4)>1 THEN
				wResult:=SHL(INT_TO_WORD(iN),8)+16#000B;
				EXIT;
			END_IF
	        lrAng_delta:= ACOS(lrVar1/lrLCirDis_pt2pt6) - ACOS(lrVar2/lrLCirDis_pt2pt6); (*pt6弧角*)

	        lrAng_theta:= gc_lrPI - lrAng_beta - lrAng_delta; (*压辊弧角*)

	        lrArc_pt5:= ((pstStMechanicalParam_01^.lrD1)/2)*lrAng_alpha;
	        lrArc_pt4:= ((pstStMechanicalParam_01^.lrD2)/2)*(lrAng_alpha+lrAng_beta);
	        lrArc_pt2:= ((pstStMechanicalParam_01^.lrDR)/2)*lrAng_theta;
	        lrArc_pt6:= ((pstStMechanicalParam_01^.lrD3)/2)*lrAng_delta;
			alrConstantLength[iN]:=lrArc_pt5+lrLCTD1+lrArc_pt4+lrLCTD2+lrArc_pt2+lrLCTD3+lrArc_pt6;
			lrTotalLength:=alrConstantLength[iN]+i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_ConstVal;
			(*2024.7.11.164906+*)
			
			IF i_xFilpSwitch THEN(*翻转架开关打开了|就把翻料架的料长加进去@一般一台机器只有一个翻料架*)
				IF i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byTurnOverAxisId=0 THEN(*=0|那个轴有翻料架值就直接累加*)
					lrTotalLength:=lrTotalLength+i_pstStSysParam^.astStUnitParam_Save[iAxisId].uiTurnOverFilmLenth;
				ELSE
					IF i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byTurnOverAxisId=iAxisId THEN(*就是输入的轴id@累加该轴的翻料架长度*)
						lrTotalLength:=lrTotalLength+i_pstStSysParam^.astStUnitParam_Save[iAxisId].uiTurnOverFilmLenth;
					END_IF
				END_IF
			END_IF

			IF iN=1 THEN
				lrTotalLength:=0;
				i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V:=0;
				i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrFilmLengthFromPrevUnit:=lrTotalLength;
			ELSE
				i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrFilmLengthFromPrevUnit:=lrTotalLength;
				i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V:= KS_LREAL_MOD(lrTotalLength, i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller); (* 当前色预套准计算的值 *)
				i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V:=
									(i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller-i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V) + (* 版向走料方向单方向运动的是余数部分 *)
									i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Adjust + (* 输入的修正值 *)
									i_pstStSysParam^.astStUnitParam_Save[i_aiGrpAxisList[iN-1]].lrPreReg_Length_V; (* 前一色已经运动过的量|相当于更新变化后的基准位置 *)

				(* 2020.9.11.152457|防止输入的修正值绝对值超出1个版周 *)
				WHILE i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V<0 DO
					i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V:= i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V+i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller;
				END_WHILE
				WHILE i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V>i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller DO
					i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V:= i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V-i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller;
				END_WHILE

			END_IF
		END_FOR
	2: (*直压式结构*)
		pstStMechanicalParam_02:= ADR(i_pastStMechanicalParamBuf^[2].abyBuf);
		IF pstStMechanicalParam_02^.lrX1<0.1 OR pstStMechanicalParam_02^.lry1<0.1 OR  pstStMechanicalParam_02^.lrx5<0.1
			OR  pstStMechanicalParam_02^.lry5<0.1 OR  pstStMechanicalParam_02^.lrx6<0.1  OR  pstStMechanicalParam_02^.lry6<0.1 THEN
			wResult:=16#FF01;
			RETURN;
		END_IF
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iAxisId:= i_aiGrpAxisList[iN];
			lrX_PressRoller:=pstStMechanicalParam_02^.lrX1;
			lrY_PressRoller:= pstStMechanicalParam_02^.lry1-((i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller)/gc_lrPI+pstStMechanicalParam_02^.lrDR)/2.0;
			(*算出左边导向辊和胶辊之间的圆心距离*)
			lrVar1:= (lrX_PressRoller-pstStMechanicalParam_02^.lrx5);
			lrVar2:= (lrY_PressRoller-pstStMechanicalParam_02^.lrY5);
			lrLCirDis_pt5ptR:= SQRT(lrVar1*lrVar1 + lrVar2*lrVar2);
			(*算出右边导向辊和胶辊之间的圆心距离*)
			lrVar1:= (pstStMechanicalParam_02^.lrx6-lrX_PressRoller);
			lrVar2:= (pstStMechanicalParam_02^.lry6-lrY_PressRoller);
			lrLCirDis_pt6ptR:= SQRT(lrVar1*lrVar1 + lrVar2*lrVar2);
			(*算出x5,y5和x6,y6之间的圆心距离*)
			lrVar1:= pstStMechanicalParam_02^.lrx6-pstStMechanicalParam_02^.lrx5;
			lrVar2:= pstStMechanicalParam_02^.lrY6-pstStMechanicalParam_02^.lrY5;
			lrLCirDis_pt5pt6:= SQRT(lrVar1*lrVar1 + lrVar2*lrVar2);
			IF NOT (lrLCirDis_pt5ptR<>0 AND lrLCirDis_pt6ptR<>0) THEN(*分母不能为0*)
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0002;
				EXIT;
			END_IF
			IF ABS((lrLCirDis_pt5ptR*lrLCirDis_pt5ptR + lrLCirDis_pt6ptR*lrLCirDis_pt6ptR - lrLCirDis_pt5pt6*lrLCirDis_pt5pt6) / (2*lrLCirDis_pt5ptR*lrLCirDis_pt6ptR)) > 1 THEN (*余弦值域必须有效*)
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0003;
				EXIT;
			END_IF
			(*算出x5,y5|胶辊|x6,y6的夹角*)
			(*余弦定理| cos(abc)=(a2+b2-c2)/2ab*)
			lrAng_5R6:= ACOS((lrLCirDis_pt5ptR*lrLCirDis_pt5ptR + lrLCirDis_pt6ptR*lrLCirDis_pt6ptR - lrLCirDis_pt5pt6*lrLCirDis_pt5pt6) / (2*lrLCirDis_pt5ptR*lrLCirDis_pt6ptR));
			(*两段切线|都是外切*)
			(*左边导向辊到压辊之间的外切线距离*)
			lrLCTD1:= KS_CalcCircleTangentDistance(
				pstStMechanicalParam_02^.lrx5, pstStMechanicalParam_02^.lrY5, pstStMechanicalParam_02^.lrD1,
				lrX_PressRoller, lrY_PressRoller, pstStMechanicalParam_02^.lrDR,
				FALSE);

			lrLCTD2:= KS_CalcCircleTangentDistance(
				pstStMechanicalParam_02^.lrX6, pstStMechanicalParam_02^.lrY6, pstStMechanicalParam_02^.lrD3,
				lrX_PressRoller, lrY_PressRoller, pstStMechanicalParam_02^.lrDR,
				FALSE);
			IF NOT (lrLCirDis_pt5pt6<>0 AND lrLCirDis_pt5ptR<>0) THEN(*分母不能0*)
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0004;
				EXIT;
			END_IF
			IF ABS((lrLCirDis_pt5ptR*lrLCirDis_pt5ptR + lrLCirDis_pt5pt6*lrLCirDis_pt5pt6 - lrLCirDis_pt6ptR*lrLCirDis_pt6ptR) / (2*lrLCirDis_pt5pt6*lrLCirDis_pt5ptR)) > 1 THEN(*余弦值域必须有效*)
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0005;
				EXIT;
			END_IF
			(*将来要用来计算弧长的几个角度*)
			lrAng_65R:= ACOS((lrLCirDis_pt5ptR*lrLCirDis_pt5ptR + lrLCirDis_pt5pt6*lrLCirDis_pt5pt6 - lrLCirDis_pt6ptR*lrLCirDis_pt6ptR) / (2*lrLCirDis_pt5pt6*lrLCirDis_pt5ptR));
			lrAng_56R:= gc_lrPI-lrAng_65R-lrAng_5R6;
			IF ABS((lrX_PressRoller-pstStMechanicalParam_02^.lrx5)/lrLCirDis_pt5ptR)>1 THEN(*asin()值域必须检查*)
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0006;
				EXIT;
			END_IF
			lrAng_AlphaB:= ASIN((lrX_PressRoller-pstStMechanicalParam_02^.lrx5)/lrLCirDis_pt5ptR);

			IF ABS(lrLCTD1/lrLCirDis_pt5ptR)>1 THEN(*acos()值域必须检查*)
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0007;
				EXIT;
			END_IF
			lrAng_AlphaC:= ACOS(lrLCTD1/lrLCirDis_pt5ptR);
			lrAng_GammaA:= lrAng_AlphaB-lrAng_AlphaC; (*A点开始的弧角*)
			IF ABS(lrLCTD2/lrLCirDis_pt6ptR)>1 THEN(*asin()值域必须有效*)
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0008;
				EXIT;
			END_IF
			lrAng_Beta:= 2*gc_lrPI - lrAng_5R6 - ASIN(lrLCTD1/lrLCirDis_pt5ptR) - ASIN(lrLCTD2/lrLCirDis_pt6ptR);
			IF ABS((pstStMechanicalParam_02^.lrX6-lrX_PressRoller)/lrLCirDis_pt6ptR)>1 THEN(*asin()值域检查*)
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0009;
				EXIT;
			END_IF
			lrAng_AlphaH:= ASIN((pstStMechanicalParam_02^.lrX6-lrX_PressRoller)/lrLCirDis_pt6ptR);

			IF ABS(lrLCTD2/lrLCirDis_pt6ptR)>1 THEN(*acos()值域检查*)
				wResult:=SHL(INT_TO_WORD(iN),8)+16#000A;
				EXIT;
			END_IF
			lrAng_AlphaK:= ACOS(lrLCTD2/lrLCirDis_pt6ptR);
			lrAng_GammaB:= lrAng_AlphaH-lrAng_AlphaK;
			(*弧长A点在x5,y5上的弧线长度*)
			lrArc_1:= (pstStMechanicalParam_02^.lrD1/2.0)*lrAng_GammaA;
			
			(*弧长在压辊上的长度*)
			lrArc_2:= (pstStMechanicalParam_02^.lrDR/2.0)*lrAng_Beta;
			
			(*弧长B点在x6,y6上的弧线长度*)
			lrArc_3:= (pstStMechanicalParam_02^.lrD3/2.0)*lrAng_GammaB;
			alrConstantLength[iN]:= lrArc_1+lrLCTD1+lrArc_2+lrLCTD2+lrArc_3;
			lrTotalLength:=alrConstantLength[iN]+i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_ConstVal;
			(*2024.7.11.164906+*)
			
			IF i_xFilpSwitch THEN(*翻转架开关打开了|就把翻料架的料长加进去@一般一台机器只有一个翻料架*)
				IF i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byTurnOverAxisId=0 THEN(*=0|那个轴有翻料架值就直接累加*)
					lrTotalLength:=lrTotalLength+i_pstStSysParam^.astStUnitParam_Save[iAxisId].uiTurnOverFilmLenth;
				ELSE
					IF i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byTurnOverAxisId=iAxisId THEN(*就是输入的轴id@累加该轴的翻料架长度*)
						lrTotalLength:=lrTotalLength+i_pstStSysParam^.astStUnitParam_Save[iAxisId].uiTurnOverFilmLenth;
					END_IF
				END_IF
			END_IF

			IF iN=1 THEN
				lrTotalLength:=0;
				i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V:=0;
				i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrFilmLengthFromPrevUnit:=lrTotalLength;
			ELSE
				i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrFilmLengthFromPrevUnit:=lrTotalLength;
				i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V:= KS_LREAL_MOD(lrTotalLength, i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller);(*当前色预套准计算的值*)
				i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V:=i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller-i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V
									+i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Adjust+i_pstStSysParam^.astStUnitParam_Save[i_aiGrpAxisList[iN-1]].lrPreReg_Length_V;

				(* 2020.9.11.152457|防止输入的修正值绝对值超出1个版周 *)
				WHILE i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V<0 DO
					i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V:= i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V+i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller;
				END_WHILE
				WHILE i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V>i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller DO
					i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V:= i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V-i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller;
				END_WHILE

			END_IF
		END_FOR
	3:(*欧泰直压式*)
		(*M点为圆3和圆5之间圆心距与切线的交点,
		IrHW为圆3和圆5的切线,H为圆3上的切点,W为圆5上的切点;
		IrNT为圆4和圆6的切线,N为圆4上的切点,T为圆6上的切点;
		IrIU为圆3和圆2的切线,I为圆3上的切点,U为圆5上的切点;
		IrQV为圆4和圆2的切线,Q为圆4上的切点,V为圆6上的切点;
		*)
		pstStMechanicalParam_03:= ADR(i_pastStMechanicalParamBuf^[3].abyBuf);
		IF pstStMechanicalParam_03^.lrX1<0.1 OR pstStMechanicalParam_03^.lry1<0.1 OR  pstStMechanicalParam_03^.lrx3<0.1
			OR  pstStMechanicalParam_03^.lrx4<0.1 OR  pstStMechanicalParam_03^.lrx5<0.1 OR  pstStMechanicalParam_03^.lrx6<0.1  OR  pstStMechanicalParam_03^.lry6<0.1 THEN
			wResult:=16#FF01;
			RETURN;
		END_IF
		pstStMechanicalParam_03^.lrX2:=pstStMechanicalParam_03^.lrX1;
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iAxisId:= i_aiGrpAxisList[iN];
			
			pstStMechanicalParam_03^.lrY2:=pstStMechanicalParam_03^.lrY1+0.5*((i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller)/gc_lrPI+pstStMechanicalParam_03^.lrD2);
			IF X_OnRubberROller THEN(*胶辊安装位置确定*)
				pstStMechanicalParam_03^.lrY3:=pstStMechanicalParam_03^.lrY2+pstStMechanicalParam_03^.lrn;
				pstStMechanicalParam_03^.lrY4:=pstStMechanicalParam_03^.lrY2+pstStMechanicalParam_03^.lrm;
				XH1_Flag:=TRUE;
				XH2_Flag:=FALSE;
			ELSE
				XH2_Flag:=TRUE;
				XH1_Flag:=FALSE;
				pstStMechanicalParam_03^.lrY3:=pstStMechanicalParam_03^.lrY2+pstStMechanicalParam_03^.lrn+pstStMechanicalParam_03^.lrH12;
				pstStMechanicalParam_03^.lrY4:=pstStMechanicalParam_03^.lrY2+pstStMechanicalParam_03^.lrm+pstStMechanicalParam_03^.lrH12;
			END_IF
			(*以下为每个圆心之间的距离*)
			lrLCirDis_pt2pt3:=SQRT((pstStMechanicalParam_03^.lrY3-pstStMechanicalParam_03^.lrY2)*(pstStMechanicalParam_03^.lrY3-pstStMechanicalParam_03^.lrY2)
									+(pstStMechanicalParam_03^.lrX3-pstStMechanicalParam_03^.lrX2)*(pstStMechanicalParam_03^.lrX3-pstStMechanicalParam_03^.lrX2));
			lrLCirDis_pt2pt4:=SQRT((pstStMechanicalParam_03^.lrY4-pstStMechanicalParam_03^.lrY2)*(pstStMechanicalParam_03^.lrY4-pstStMechanicalParam_03^.lrY2)
									+(pstStMechanicalParam_03^.lrX4-pstStMechanicalParam_03^.lrX2)*(pstStMechanicalParam_03^.lrX4-pstStMechanicalParam_03^.lrX2));
			lrLCirDis_pt3pt4:=SQRT((pstStMechanicalParam_03^.lrY4-pstStMechanicalParam_03^.lrY3)*(pstStMechanicalParam_03^.lrY4-pstStMechanicalParam_03^.lrY3)
									+(pstStMechanicalParam_03^.lrX4-pstStMechanicalParam_03^.lrX3)*(pstStMechanicalParam_03^.lrX4-pstStMechanicalParam_03^.lrX3));
			lrLCirDis_pt3pt5:=SQRT((pstStMechanicalParam_03^.lrY5-pstStMechanicalParam_03^.lrY3)*(pstStMechanicalParam_03^.lrY5-pstStMechanicalParam_03^.lrY3)
									+(pstStMechanicalParam_03^.lrX5-pstStMechanicalParam_03^.lrX3)*(pstStMechanicalParam_03^.lrX5-pstStMechanicalParam_03^.lrX3));
			lrLCirDis_pt4pt5:=SQRT((pstStMechanicalParam_03^.lrY5-pstStMechanicalParam_03^.lrY4)*(pstStMechanicalParam_03^.lrY5-pstStMechanicalParam_03^.lrY4)
									+(pstStMechanicalParam_03^.lrX5-pstStMechanicalParam_03^.lrX4)*(pstStMechanicalParam_03^.lrX5-pstStMechanicalParam_03^.lrX4));
			lrLCirDis_pt4pt6:=SQRT((pstStMechanicalParam_03^.lrY6-pstStMechanicalParam_03^.lrY4)*(pstStMechanicalParam_03^.lrY6-pstStMechanicalParam_03^.lrY4)
									+(pstStMechanicalParam_03^.lrX6-pstStMechanicalParam_03^.lrX4)*(pstStMechanicalParam_03^.lrX6-pstStMechanicalParam_03^.lrX4));
			lrLCirDis_pt3pt6:=SQRT((pstStMechanicalParam_03^.lrY6-pstStMechanicalParam_03^.lrY3)*(pstStMechanicalParam_03^.lrY6-pstStMechanicalParam_03^.lrY3)
									+(pstStMechanicalParam_03^.lrX6-pstStMechanicalParam_03^.lrX3)*(pstStMechanicalParam_03^.lrX6-pstStMechanicalParam_03^.lrX3));
			lrLCirDis_pt2pt6:=SQRT((pstStMechanicalParam_03^.lrY6-pstStMechanicalParam_03^.lrY2)*(pstStMechanicalParam_03^.lrY6-pstStMechanicalParam_03^.lrY2)
									+(pstStMechanicalParam_03^.lrX2-pstStMechanicalParam_03^.lrX6)*(pstStMechanicalParam_03^.lrX2-pstStMechanicalParam_03^.lrX6));
			lrLCirDis_pt2pt5:=SQRT((pstStMechanicalParam_03^.lrY5-pstStMechanicalParam_03^.lrY2)*(pstStMechanicalParam_03^.lrY5-pstStMechanicalParam_03^.lrY2)
									+(pstStMechanicalParam_03^.lrX2-pstStMechanicalParam_03^.lrX5)*(pstStMechanicalParam_03^.lrX2-pstStMechanicalParam_03^.lrX5));
			(*以下为图中需要用到的直线距离、按标识可找到*)
			IrO3M:=(pstStMechanicalParam_03^.lrD3*lrLCirDis_pt3pt5)/(pstStMechanicalParam_03^.lrD3+pstStMechanicalParam_03^.lrD5);
			IrHM:=SQRT(IrO3M*IrO3M-(pstStMechanicalParam_03^.lrD3*pstStMechanicalParam_03^.lrD3)/4);
			IF lrLCirDis_pt2pt5*IrO3M*lrLCirDis_pt2pt3 * lrLCirDis_pt2pt4 * lrLCirDis_pt3pt4 * lrLCirDis_pt3pt5 * lrLCirDis_pt4pt5 * lrLCirDis_pt4pt6 * lrLCirDis_pt3pt6 * lrLCirDis_pt2pt6=0 THEN(*分母不能为零*)
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0002;
				EXIT;
			END_IF
			(*以下为图中需要用到的角度，通过标注可找到*)
			IrAngle_O3O2U:=ACOS(ABS(pstStMechanicalParam_03^.lrD2-pstStMechanicalParam_03^.lrD3)*0.5/lrLCirDis_pt2pt3);
			IF ABS(ABS(pstStMechanicalParam_03^.lrD2-pstStMechanicalParam_03^.lrD3)*0.5/lrLCirDis_pt2pt3)>1 THEN(*正余弦值域的绝对值必须小于1*)
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0003;
				EXIT;
			END_IF
			IrAngle_O4O2V:=ACOS(ABS(pstStMechanicalParam_03^.lrD2-pstStMechanicalParam_03^.lrD4)*0.5/lrLCirDis_pt2pt4);
			IF ABS(ABS(pstStMechanicalParam_03^.lrD2-pstStMechanicalParam_03^.lrD4)*0.5/lrLCirDis_pt2pt4)>1 THEN
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0004;
				EXIT;
			END_IF
			IrAngle_O3O2O4:=ACOS((lrLCirDis_pt2pt3*lrLCirDis_pt2pt3+lrLCirDis_pt2pt4*lrLCirDis_pt2pt4
													-lrLCirDis_pt3pt4*lrLCirDis_pt3pt4)/(2*lrLCirDis_pt2pt3*lrLCirDis_pt2pt4));
			IF ABS((lrLCirDis_pt2pt3*lrLCirDis_pt2pt3+lrLCirDis_pt2pt4*lrLCirDis_pt2pt4
													-lrLCirDis_pt3pt4*lrLCirDis_pt3pt4)/(2*lrLCirDis_pt2pt3*lrLCirDis_pt2pt4))>1 THEN
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0005;
				EXIT;
			END_IF
			IrAngle_UO2V:=2*gc_lrPI-IrAngle_O3O2U-IrAngle_O4O2V-IrAngle_O3O2O4;(*圆2上需要计算的弧度*)

			IrAngle_O4O3O5:=ACOS((lrLCirDis_pt3pt5*lrLCirDis_pt3pt5+lrLCirDis_pt3pt4*lrLCirDis_pt3pt4-lrLCirDis_pt4pt5*lrLCirDis_pt4pt5)/(2*lrLCirDis_pt3pt4*lrLCirDis_pt3pt5));
			IF ABS((lrLCirDis_pt3pt5*lrLCirDis_pt3pt5+lrLCirDis_pt3pt4*lrLCirDis_pt3pt4-lrLCirDis_pt4pt5*lrLCirDis_pt4pt5)/(2*lrLCirDis_pt3pt4*lrLCirDis_pt3pt5))>1 THEN
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0006;
				EXIT;
			END_IF
			IrAngle_O2O3O5:=ACOS((lrLCirDis_pt2pt3*lrLCirDis_pt2pt3+lrLCirDis_pt3pt5*lrLCirDis_pt3pt5-lrLCirDis_pt2pt5*lrLCirDis_pt2pt5)/(2*lrLCirDis_pt2pt3*lrLCirDis_pt3pt5));
			IF ABS((lrLCirDis_pt2pt3*lrLCirDis_pt2pt3+lrLCirDis_pt3pt5*lrLCirDis_pt3pt5-lrLCirDis_pt2pt5*lrLCirDis_pt2pt5)/(2*lrLCirDis_pt2pt3*lrLCirDis_pt3pt5))>1 THEN
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0007;
				EXIT;
			END_IF
			IrAngle_HO3M:=ACOS(pstStMechanicalParam_03^.lrD3/(2*IrO3M));
			IF ABS(pstStMechanicalParam_03^.lrD3/(2*IrO3M))>1 THEN
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0008;
				EXIT;
			END_IF
			IrAngle_O2O3I:=gc_lrPI-IrAngle_O3O2U;
			IrAngle_HO3I:=2*gc_lrPI-IrAngle_O2O3O5-IrAngle_O2O3I-IrAngle_HO3M;(*圆3上需要计算的弧度*)

			IrAngle_O6O4N:=ACOS((ABS(pstStMechanicalParam_03^.lrD4-pstStMechanicalParam_03^.lrD6))/(2*lrLCirDis_pt4pt6));
			IF ABS((ABS(pstStMechanicalParam_03^.lrD4-pstStMechanicalParam_03^.lrD6))/(2*lrLCirDis_pt4pt6))>1 THEN
				wResult:=SHL(INT_TO_WORD(iN),8)+16#0009;
				EXIT;
			END_IF
			IrAngle_O3O4O6:=ACOS((lrLCirDis_pt3pt4*lrLCirDis_pt3pt4+lrLCirDis_pt4pt6*lrLCirDis_pt4pt6-lrLCirDis_pt3pt6*lrLCirDis_pt3pt6)/(2*lrLCirDis_pt3pt4*lrLCirDis_pt4pt6));
			IF ABS((lrLCirDis_pt3pt4*lrLCirDis_pt3pt4+lrLCirDis_pt4pt6*lrLCirDis_pt4pt6-lrLCirDis_pt3pt6*lrLCirDis_pt3pt6)/(2*lrLCirDis_pt3pt4*lrLCirDis_pt4pt6))>1 THEN
				wResult:=SHL(INT_TO_WORD(iN),8)+16#00010;
				EXIT;
			END_IF
			IrAngle_O2O4P:=ASIN((ABS(pstStMechanicalParam_03^.lrD2-pstStMechanicalParam_03^.lrD4))/(2*lrLCirDis_pt2pt4));
			IF ABS((ABS(pstStMechanicalParam_03^.lrD2-pstStMechanicalParam_03^.lrD4))/(2*lrLCirDis_pt2pt4))>1 THEN
				wResult:=SHL(INT_TO_WORD(iN),8)+16#00011;
				EXIT;
			END_IF
			IrAngle_O2O4O6:=ACOS((lrLCirDis_pt2pt4*lrLCirDis_pt2pt4+lrLCirDis_pt4pt6*lrLCirDis_pt4pt6-lrLCirDis_pt2pt6*lrLCirDis_pt2pt6)/(2*lrLCirDis_pt2pt4*lrLCirDis_pt4pt6));
			IF ABS((lrLCirDis_pt2pt4*lrLCirDis_pt2pt4+lrLCirDis_pt4pt6*lrLCirDis_pt4pt6-lrLCirDis_pt2pt6*lrLCirDis_pt2pt6)/(2*lrLCirDis_pt2pt4*lrLCirDis_pt4pt6))>1 THEN
				wResult:=SHL(INT_TO_WORD(iN),8)+16#00012;
				EXIT;
			END_IF
			IrAngle_NO4Q:=1.5*gc_lrPI-IrAngle_O6O4N-IrAngle_O2O4O6-IrAngle_O2O4P;(*圆4上需要计算的弧度*)
			IrAngle_ZO5W:=ATAN((pstStMechanicalParam_03^.lrY5-pstStMechanicalParam_03^.lrY3)/(pstStMechanicalParam_03^.lrX5-pstStMechanicalParam_03^.lrX3));
			IF pstStMechanicalParam_03^.lrx5=pstStMechanicalParam_03^.lrX3 THEN(*分母不能为零*)
				wResult:=SHL(INT_TO_WORD(iN),8)+16#00013;
				EXIT;
			END_IF
			IrAngle_WO5S:=gc_lrPI-IrAngle_ZO5W-IrAngle_HO3M;(*圆5上需要计算的弧度*)
			IrArc_UV:=IrAngle_UO2V*pstStMechanicalParam_03^.lrD2/2;(*圆2上需要计算的弧长*)
			IrArc_HI:=0.5*IrAngle_HO3I*pstStMechanicalParam_03^.lrD3;(*圆3上需要计算的弧长*)
			IrArc_NQ:=0.5*IrAngle_NO4Q*pstStMechanicalParam_03^.lrD4;(*圆4上需要计算的弧长*)
			IrArc_WS:=IrAngle_WO5S*(pstStMechanicalParam_03^.lrD5/2);(*圆5上需要进行的弧长*)
			IrIU:=SQRT(lrLCirDis_pt2pt3*lrLCirDis_pt2pt3-(((pstStMechanicalParam_03^.lrD2-pstStMechanicalParam_03^.lrD3)/2)*((pstStMechanicalParam_03^.lrD2-pstStMechanicalParam_03^.lrD3)/2)));
			IrQV:=SQRT(lrLCirDis_pt2pt4*lrLCirDis_pt2pt4-(((pstStMechanicalParam_03^.lrD2-pstStMechanicalParam_03^.lrD4)/2)*((pstStMechanicalParam_03^.lrD2-pstStMechanicalParam_03^.lrD4)/2)));
			IrHS:=((pstStMechanicalParam_03^.lrD3+pstStMechanicalParam_03^.lrD5)*IrHM)/pstStMechanicalParam_03^.lrD3;
			IrNT:=SQRT(lrLCirDis_pt4pt6*lrLCirDis_pt4pt6+(((pstStMechanicalParam_03^.lrD4-pstStMechanicalParam_03^.lrD6)/2)*((pstStMechanicalParam_03^.lrD4-pstStMechanicalParam_03^.lrD6)/2)));
			alrConstantLength[iN]:= IrArc_UV+IrArc_HI+IrArc_NQ+IrArc_WS+IrIU+IrQV+IrHS+IrNT;(*可变料长*)
			lrTotalLength:=alrConstantLength[iN]+i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_ConstVal;
			(*2024.7.11.164906+*)
			
			IF i_xFilpSwitch THEN(*翻转架开关打开了|就把翻料架的料长加进去@一般一台机器只有一个翻料架*)
				IF i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byTurnOverAxisId=0 THEN(*=0|那个轴有翻料架值就直接累加*)
					lrTotalLength:=lrTotalLength+i_pstStSysParam^.astStUnitParam_Save[iAxisId].uiTurnOverFilmLenth;
				ELSE
					IF i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byTurnOverAxisId=iAxisId THEN(*就是输入的轴id@累加该轴的翻料架长度*)
						lrTotalLength:=lrTotalLength+i_pstStSysParam^.astStUnitParam_Save[iAxisId].uiTurnOverFilmLenth;
					END_IF
				END_IF
			END_IF

			IF iN=1 THEN
				lrTotalLength:=0;
				i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V:=0;
				i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrFilmLengthFromPrevUnit:=lrTotalLength;
			ELSE
				i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrFilmLengthFromPrevUnit:=lrTotalLength;
				i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V:= KS_LREAL_MOD(lrTotalLength, i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller);(*当前色预套准计算的值*)
				i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V:=i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller-i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V
									+i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Adjust+i_pstStSysParam^.astStUnitParam_Save[i_aiGrpAxisList[iN-1]].lrPreReg_Length_V;

				(* 2020.9.11.152457|防止输入的修正值绝对值超出1个版周 *)
				WHILE i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V<0 DO
					i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V:= i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V+i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller;
				END_WHILE
				WHILE i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V>i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller DO
					i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V:= i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V-i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller;
				END_WHILE

			END_IF
		END_FOR
	4:(*定料长*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iAxisId:= i_aiGrpAxisList[iN];
			
			i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrFilmLengthFromPrevUnit:=i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_ConstVal;(*2022.6.24.110711 定料长=机组料长|还存在定料长变化的可能-未处理~~*)
			IF iN=1 THEN
				i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V:=0;
				i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrFilmLengthFromPrevUnit:=0;
			ELSE
				(*该值由界面提供，不该赋值|2020.9.8.174713|Liu.yt*)
				i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V:= KS_LREAL_MOD(i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrFilmLengthFromPrevUnit, i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller);(*当前色预套准计算的值*)
				(*没有增加修正量|2022.6.24.110718*)
				i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V:=i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller-i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V
									+i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Adjust+i_pstStSysParam^.astStUnitParam_Save[i_aiGrpAxisList[iN-1]].lrPreReg_Length_V;
				(* 2020.9.11.152457|防止输入的修正值绝对值超出1个版周 *)
				WHILE i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V<0 DO
					i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V:= i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V+i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller;
				END_WHILE
				WHILE i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V>i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller  DO
					i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V:= i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V-i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller;
				END_WHILE

			END_IF
		END_FOR

	(*2026.08.27.095631*)
	5: (*欧诺+力达直压式|2023.07.10.142323||2023.11.17.101158||2026.08.26 重构||[AI修改20260827]rD0改由本轴版周长推算+包角负值改报错*)
    pstStMechanicalParam_05 := ADR(i_pastStMechanicalParamBuf^[5].abyBuf);

    (* --- 1. 输入参数有效性检查（统一返回 16#FF01） --- *)
    IF pstStMechanicalParam_05^.rX1 < 0.1 OR pstStMechanicalParam_05^.rY1 < 0.1 OR
       pstStMechanicalParam_05^.rX2 < 0.1 OR pstStMechanicalParam_05^.rX3 < 0.1 OR
       pstStMechanicalParam_05^.rX4 < 0.1 OR pstStMechanicalParam_05^.rY4 < 0.1 OR
       pstStMechanicalParam_05^.rY0 < 0.1 OR pstStMechanicalParam_05^.rY2 < 0.1 OR(*[AI修改20260829]检查项rL2_3→rY2|前者转动态派生,不再作静态输入检查*)
       pstStMechanicalParam_05^.rD1 < 0.1 OR(*[AI修改20260827]移除rD0项|版辊直径不再作为静态输入*)
       pstStMechanicalParam_05^.rD2 < 0.1 OR pstStMechanicalParam_05^.rD3 < 0.1 OR
       pstStMechanicalParam_05^.rD4 < 0.1 THEN
        wResult := 16#FF01;  (* 全局参数无效 *)
        RETURN;
    END_IF

    FOR iN := 1 TO i_iGrpAxisNum_Pu BY 1 DO
        iAxisId := i_aiGrpAxisList[iN];
        rPlateR := i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller/gc_lrPi/2.0;(*[AI修改20260827]版辊半径=本轴版周长/π/2|替代原静态rD0/2,几何随轴变化*)
        rY3 := pstStMechanicalParam_05^.rY0 + rPlateR + pstStMechanicalParam_05^.rD3/2;(*[AI修改20260829]辊3(D3)辊心高=动态|Y0+版半径+D3半径,随版径浮动|同原版2023.11算法(原rY5项)*)
        rL2_3 := pstStMechanicalParam_05^.rY2 - rY3;(*[AI修改20260829]辊2-3垂直中心距=动态派生|修正:辊2高度rY2为固定安装尺寸,原静态字段rL2_3删除*)

        (* --- 2. 圆心距计算 --- *)
        rd1 := SQRT(EXPT(pstStMechanicalParam_05^.rX1 - pstStMechanicalParam_05^.rX2, 2) +
                    EXPT(pstStMechanicalParam_05^.rY1 - pstStMechanicalParam_05^.rY0 -
                         rPlateR - pstStMechanicalParam_05^.rD3/2 -
                         rL2_3, 2));
        rd2 := SQRT(EXPT(pstStMechanicalParam_05^.rX3 - pstStMechanicalParam_05^.rX2, 2) +
                    EXPT(rL2_3, 2));
        rd3 := SQRT(EXPT(pstStMechanicalParam_05^.rX4 - pstStMechanicalParam_05^.rX3, 2) +
                    EXPT(pstStMechanicalParam_05^.rY4 - pstStMechanicalParam_05^.rY0 -
                         rPlateR - pstStMechanicalParam_05^.rD3/2, 2));
        rd4 := SQRT(EXPT(pstStMechanicalParam_05^.rX3 - pstStMechanicalParam_05^.rX1, 2) +
                    EXPT(pstStMechanicalParam_05^.rY1 - pstStMechanicalParam_05^.rY0 -
                         rPlateR - pstStMechanicalParam_05^.rD3/2, 2));
        rd5 := SQRT(EXPT(pstStMechanicalParam_05^.rX4 - pstStMechanicalParam_05^.rX2, 2) +
                    EXPT(pstStMechanicalParam_05^.rY4 - pstStMechanicalParam_05^.rY0 -
                         rPlateR - pstStMechanicalParam_05^.rD3/2 -
                         rL2_3, 2));

        (* --- 3. 圆心距为零检查 --- *)
        IF rd1 = 0 OR rd2 = 0 OR rd3 = 0 OR rd4 = 0 OR rd5 = 0 THEN
            wResult := SHL(INT_TO_WORD(iN), 8) + 16#0001;  (* 圆心距为零 *)
            EXIT;
        END_IF

        (* --- 4. 切线长度计算（允许临界零切线） --- *)
        IF rd1 >= (pstStMechanicalParam_05^.rD1/2 + pstStMechanicalParam_05^.rD2/2) THEN
            rLength1 := SQRT(EXPT(rd1, 2) - EXPT(pstStMechanicalParam_05^.rD1/2 + pstStMechanicalParam_05^.rD2/2, 2));
        ELSE
            wResult := SHL(INT_TO_WORD(iN), 8) + 16#0002;  (* 外切条件不满足 *)
            EXIT;
        END_IF

        IF rd2 >= ABS(pstStMechanicalParam_05^.rD3/2 - pstStMechanicalParam_05^.rD2/2) THEN
            rLength2 := SQRT(EXPT(rd2, 2) - EXPT(pstStMechanicalParam_05^.rD3/2 - pstStMechanicalParam_05^.rD2/2, 2));
        ELSE
            wResult := SHL(INT_TO_WORD(iN), 8) + 16#0003;  (* 内切条件不满足（D2-D3） *)
            EXIT;
        END_IF

        IF rd3 >= ABS(pstStMechanicalParam_05^.rD3/2 - pstStMechanicalParam_05^.rD4/2) THEN
            rLength3 := SQRT(EXPT(rd3, 2) - EXPT(pstStMechanicalParam_05^.rD3/2 - pstStMechanicalParam_05^.rD4/2, 2));
        ELSE
            wResult := SHL(INT_TO_WORD(iN), 8) + 16#0004;  (* 内切条件不满足（D3-D4） *)
            EXIT;
        END_IF

        (* --- 5. 圆心到切点距离 --- *)
        rCenter_To_tangent1 := SQRT(EXPT(rLength1, 2) + EXPT(pstStMechanicalParam_05^.rD1/2, 2));
        rCenter_To_tangent2 := SQRT(EXPT(rLength2, 2) + EXPT(pstStMechanicalParam_05^.rD3/2, 2));
        rCenter_To_tangent3 := SQRT(EXPT(rLength2, 2) + EXPT(pstStMechanicalParam_05^.rD2/2, 2));
        rCenter_To_tangent4 := SQRT(EXPT(rLength3, 2) + EXPT(pstStMechanicalParam_05^.rD4/2, 2));

        (* --- 6. 角度与弧长计算（带余弦值域校验） --- *)
        lrTemp := (EXPT(rd1, 2) + EXPT(pstStMechanicalParam_05^.rD2/2, 2) - EXPT(rCenter_To_tangent1, 2)) /
                  (2 * rd1 * pstStMechanicalParam_05^.rD2/2);
        IF ABS(lrTemp) > 1.0 THEN
            wResult := SHL(INT_TO_WORD(iN), 8) + 16#0005;  (* 角度1余弦超限 *)
            EXIT;
        END_IF
        rArc1 := ACOS(lrTemp);
        rAngle1 := rArc1 * 180 / gc_lrPi;

        lrTemp := (EXPT(rd1, 2) + EXPT(rd2, 2) - EXPT(rd4, 2)) / (2 * rd1 * rd2);
        IF ABS(lrTemp) > 1.0 THEN
            wResult := SHL(INT_TO_WORD(iN), 8) + 16#0006;  (* 角度2余弦超限 *)
            EXIT;
        END_IF
        rArc2 := ACOS(lrTemp);
        rAngle2 := rArc2 * 180 / gc_lrPi;

        lrTemp := (EXPT(rd2, 2) + EXPT(pstStMechanicalParam_05^.rD2/2, 2) - EXPT(rCenter_To_tangent2, 2)) /
                  (2 * rd2 * pstStMechanicalParam_05^.rD2/2);
        IF ABS(lrTemp) > 1.0 THEN
            wResult := SHL(INT_TO_WORD(iN), 8) + 16#0007;  (* 角度3余弦超限 *)
            EXIT;
        END_IF
        rArc3 := ACOS(lrTemp);
        rAngle3 := rArc3 * 180 / gc_lrPi;

        rAngle4 := 360 - rAngle1 - rAngle2 - rAngle3;
        IF rAngle4 < 0 THEN(*[AI修改20260827]D2包角为负=几何参数不自洽|仿CASE1/2/3改报错,不再钳零*)
            wResult := SHL(INT_TO_WORD(iN), 8) + 16#000B;  (* D2包角为负 *)
            EXIT;
        END_IF
        rArcLen1 := (gc_lrPi * rAngle4 * pstStMechanicalParam_05^.rD2/2) / 180;

        lrTemp := (EXPT(rd2, 2) + EXPT(pstStMechanicalParam_05^.rD3/2, 2) - EXPT(rCenter_To_tangent3, 2)) /
                  (2 * rd2 * pstStMechanicalParam_05^.rD3/2);
        IF ABS(lrTemp) > 1.0 THEN
            wResult := SHL(INT_TO_WORD(iN), 8) + 16#0008;  (* 角度5余弦超限 *)
            EXIT;
        END_IF
        rArc5 := ACOS(lrTemp);
        rAngle5 := rArc5 * 180 / gc_lrPi;

        lrTemp := (EXPT(rd2, 2) + EXPT(rd3, 2) - EXPT(rd5, 2)) / (2 * rd2 * rd3);
        IF ABS(lrTemp) > 1.0 THEN
            wResult := SHL(INT_TO_WORD(iN), 8) + 16#0009;  (* 角度6余弦超限 *)
            EXIT;
        END_IF
        rArc6 := ACOS(lrTemp);
        rAngle6 := rArc6 * 180 / gc_lrPi;

        lrTemp := (EXPT(rd3, 2) + EXPT(pstStMechanicalParam_05^.rD3/2, 2) - EXPT(rCenter_To_tangent4, 2)) /
                  (2 * rd3 * pstStMechanicalParam_05^.rD3/2);
        IF ABS(lrTemp) > 1.0 THEN
            wResult := SHL(INT_TO_WORD(iN), 8) + 16#000A;  (* 角度7余弦超限 *)
            EXIT;
        END_IF
        rArc7 := ACOS(lrTemp);
        rAngle7 := rArc7 * 180 / gc_lrPi;

        rAngle8 := 360 - rAngle5 - rAngle6 - rAngle7;
        IF rAngle8 < 0 THEN(*[AI修改20260827]D3包角为负=几何参数不自洽|仿CASE1/2/3改报错,不再钳零*)
            wResult := SHL(INT_TO_WORD(iN), 8) + 16#000C;  (* D3包角为负 *)
            EXIT;
        END_IF
        rArcLen2 := (gc_lrPi * rAngle8 * pstStMechanicalParam_05^.rD3/2) / 180;

        (* --- 7. 累加可变料长 --- *)
        alrConstantLength[iN] := rLength1 + rArcLen1 + rLength2 + rArcLen2 + rLength3;
        lrTotalLength := alrConstantLength[iN] + i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_ConstVal;

        (* --- 8. 翻转架逻辑（与CASE 1完全一致） --- *)
        IF i_xFilpSwitch THEN
            IF i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byTurnOverAxisId = 0 THEN
                lrTotalLength := lrTotalLength + i_pstStSysParam^.astStUnitParam_Save[iAxisId].uiTurnOverFilmLenth;
            ELSE
                IF i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byTurnOverAxisId = iAxisId THEN
                    lrTotalLength := lrTotalLength + i_pstStSysParam^.astStUnitParam_Save[iAxisId].uiTurnOverFilmLenth;
                END_IF
            END_IF
        END_IF

        (* --- 9. 预套准值计算（与其它CASE完全一致） --- *)
        IF iN = 1 THEN
            lrTotalLength := 0;
            i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V := 0;
            i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrFilmLengthFromPrevUnit := lrTotalLength;
        ELSE
            i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrFilmLengthFromPrevUnit := lrTotalLength;
            i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V :=
                KS_LREAL_MOD(lrTotalLength, i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller);
            i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V :=
                (i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller -
                 i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V) +
                i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Adjust +
                i_pstStSysParam^.astStUnitParam_Save[i_aiGrpAxisList[iN-1]].lrPreReg_Length_V;

            WHILE i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V < 0 DO
                i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V :=
                    i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V +
                    i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller;
            END_WHILE
            WHILE i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V >
                  i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller DO
                i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V :=
                    i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Length_V -
                    i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller;
            END_WHILE
        END_IF
    END_FOR
	6:(*2024.12.03.104056//秦华履带式柔印//Hou.N*)
		iUnitValid := 0;
		lrTemp_Qinhua := 0;
		lrPreReg_Len_V := 0;
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iAxisId:= iN;
			pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iAxisId]);
			pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iAxisId]);
			pstStUnitParam_Save^.lrFilmLengthFromPrevUnit:= pstStUnitParam_Save^.lrPreReg_ConstVal;
			IF pstStUnitParam_Save^.xLinkage THEN
				IF iN=1 THEN//首色
					lrTotalLength:= 0;
					pstStUnitParam_Save^.lrPreReg_Length_V:= 0;
					pstStUnitParam_Save^.lrFilmLengthFromPrevUnit:= 0;
				ELSE
					IF NOT xUnitValid THEN
						pstStUnitParam_Save^.lrFilmLengthFromPrevUnit := pstStUnitParam_Save^.lrFilmLengthFromPrevUnit + lrTemp_Qinhua;
						lrTemp_Qinhua := 0;
					END_IF
					pstStUnitParam_Save^.lrPreReg_Length_V:= KS_LREAL_MOD(pstStUnitParam_Save^.lrFilmLengthFromPrevUnit,pstStUnitParam_Save^.rGirth_PrnRoller);
					pstStUnitParam_Save^.lrPreReg_Length_V:= (pstStUnitParam_Save^.rGirth_PrnRoller-pstStUnitParam_Save^.lrPreReg_Length_V) + (* 版向走料方向单方向运动的是余数部分 *)
									pstStUnitParam_Save^.lrPreReg_Adjust + (* 输入的修正值 *)
									i_pstStSysParam^.astStUnitParam_Save[iAxisId-1].lrPreReg_Length_V; (* 前一色已经运动过的量|相当于更新变化后的基准位置 *)

													(* 2020.9.11.152457|防止输入的修正值绝对值超出1个版周 *)
					WHILE pstStUnitParam_Save^.lrPreReg_Length_V<0 DO
						pstStUnitParam_Save^.lrPreReg_Length_V:= pstStUnitParam_Save^.lrPreReg_Length_V+pstStUnitParam_Save^.rGirth_PrnRoller;
					END_WHILE
					WHILE pstStUnitParam_Save^.lrPreReg_Length_V>pstStUnitParam_Save^.rGirth_PrnRoller DO
						pstStUnitParam_Save^.lrPreReg_Length_V:= pstStUnitParam_Save^.lrPreReg_Length_V-pstStUnitParam_Save^.rGirth_PrnRoller;
					END_WHILE

				END_IF
				
				xUnitValid := TRUE;
			ELSE
				xUnitValid := FALSE;
				lrTemp_Qinhua := pstStUnitParam_Save^.lrPreReg_ConstVal + lrTemp_Qinhua;
				IF iAxisId > 1 THEN
					pstStUnitParam_Save^.lrPreReg_Length_V := i_pstStSysParam^.astStUnitParam_Save[iAxisId-1].lrPreReg_Length_V;
				ELSE
					pstStUnitParam_Save^.lrPreReg_Length_V := 0;
				END_IF
			END_IF
		END_FOR	
		
	7: (*2026.01.15.84747//增加机组式-品字型//Hou.N*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iAxisId:= iN;
			pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iAxisId]);
			pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iAxisId]);
			IF iN=1 THEN//首色
				lrTotalLength:= 0;
				pstStUnitParam_Save^.lrPreReg_Length_V:= 0;
				pstStUnitParam_Save^.lrFilmLengthFromPrevUnit:= 0;
			ELSE
				pstStUnitParam_Save^.lrFilmLengthFromPrevUnit:=  pstStUnitParam_Save^.lrPreReg_ConstVal;
// 				rPrRadius:=i_pstStSysParam^.astStGrpParam_Save[1].rGirth_PrnRoller/2/gc_lrPI;
// 				rBrRadius:=i_pstStSysParam^.astStGrpParam_Save[1].rGirth_BottomRoller/2/gc_lrPI;
// 				rHypotenuse:=rPrRadius+rBrRadius;
// 				alrAngle_Br[iAxisId]:=ACOS(ABS(g_arFix_RightEdge[iAxisId]/rHypotenuse));
// 				alrArc_length_Br[iAxisId]:=rBrRadius*alrAngle_Br[iAxisId];
//				pstStUnitParam_Save^.lrFilmLengthFromPrevUnit := pstStUnitParam_Save^.lrFilmLengthFromPrevUnit+alrArc_length_Br[iAxisId];
				
				pstStUnitParam_Save^.lrPreReg_Length_V:= KS_LREAL_MOD(pstStUnitParam_Save^.lrFilmLengthFromPrevUnit,pstStUnitParam_Save^.rGirth_PrnRoller);
				pstStUnitParam_Save^.lrPreReg_Length_V:= (pstStUnitParam_Save^.rGirth_PrnRoller-pstStUnitParam_Save^.lrPreReg_Length_V) + (* 版向走料方向单方向运动的是余数部分 *)
								pstStUnitParam_Save^.lrPreReg_Adjust + (* 输入的修正值 *)
								i_pstStSysParam^.astStUnitParam_Save[iAxisId-1].lrPreReg_Length_V; (* 前一色已经运动过的量|相当于更新变化后的基准位置 *)

												(* 2020.9.11.152457|防止输入的修正值绝对值超出1个版周 *)
				WHILE pstStUnitParam_Save^.lrPreReg_Length_V<0 DO
					pstStUnitParam_Save^.lrPreReg_Length_V:=pstStUnitParam_Save^.lrPreReg_Length_V+pstStUnitParam_Save^.rGirth_PrnRoller;
				END_WHILE
				WHILE pstStUnitParam_Save^.lrPreReg_Length_V>pstStUnitParam_Save^.rGirth_PrnRoller DO
					pstStUnitParam_Save^.lrPreReg_Length_V:= pstStUnitParam_Save^.lrPreReg_Length_V-pstStUnitParam_Save^.rGirth_PrnRoller;
				END_WHILE

			END_IF
		END_FOR			
	ELSE;
	END_CASE
ELSE
	wResult:=16#FFFF;
END_IF

KS_CalcForPreRegister:= wResult;
