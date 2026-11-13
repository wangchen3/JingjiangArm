(*@CES
Name=KS_FB_TowerRadCompensate
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=99248248-9d66-40a1-9b64-687b8d387c7e
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_TowerRadCompensate(*2021.7.26.090725 修改名 增加接口*)
(*2023.6.13.164301 对转速输出增加了10次滤波处理@防止开始时候输出速度抖动*)
(*2023.07.18.094631 翻转架补偿处理最大变化量逻辑中未对过圈问题处理
将滤波次数减小到5次*)
VAR_INPUT
	i_xEn:BOOL;
	i_xAxis_Cur:BOOL;(*当前轴|有效为A轴*)
	i_xConfirmRad:BOOL;
	i_rDiam_CurAxis:REAL;
	i_dwAbsPos_Cur:DWORD;(*当前绝对值位置*)
	i_dwAbsEnCodeResolution:DWORD;(*位置分辨率|131072*)
	(*需要的参数|2021.7.26.090721*)
	I_xTowerDir_Uw:BOOL;(*翻转架和绝对值编码器的方向对应*)
	i_rDiam_Tower:REAL;(*翻转架直径mm*)
	i_rDiam_NextRoller:REAL;(*翻转架后第一个导辊直径mm*)
	i_rXPos_NextRoller:REAL;(*mm*)
	i_rYPos_NextRoller:REAL;(*mm*)
	i_pdwAbsPos_0Rad_AxisA:POINTER TO DWORD;(*A轴0度位置*)
	i_pdwAbsPos_0Rad_AxisB:POINTER TO DWORD;(*B轴0度位置*)
	i_xOnTop:BOOL;(*上下裁刀标志*)
	i_rDiam_DeflectorRollPos:REAL;(*翻料架的导向辊圆心运动直径|距离翻转架圆心=该值/2|mm*)
	i_rDiam_DeflectorRoller:REAL;(*翻料架上导向辊的直径|mm*)
	i_iCycleTime_Plc: INT;
END_VAR
VAR_OUTPUT
	o_rDeltaW_RPMIN: REAL;(*为了不修改外部接口这个变量冲洗定义为了滤波后的值@2023.6.13.163911*)
	o_rTheta_Cur:REAL;(*当前角度*)
	o_rFilmToTowerRollerDis:REAL;(*料膜距离导向辊距离|mm*)
	o_xFilmTouchRoller:BOOL;(*料膜接触到了辊子标志*)
	o_rActDeltaW_RPMIN: REAL;(*当前计算出来的值@2023.6.13.163905*)
END_VAR
VAR
	dwAbsPos_0Rad:DWORD;
	dwAbsPos_Cur:DWORD;
	lrLastTheta:LREAL;
	xInitLastRad:BOOL:=TRUE;
	lrDeltaW_RPMIN:LREAL;(*单个周期的补偿转速*)
	rDiam_CurAxis:REAL;(*放料当前卷径*)
	fbConfirmAbsPos_0Rad: R_TRIG;
	lrTheta_Cur: LREAL;
	lrDeltaTheta_Max: LREAL;
	xCutOnDown: BOOL;(*有效了代表下裁刀*)
	fbKS_FB_FiltByAver: KS_FB_FiltByAver;(*2023.6.13.161714 对当前弧度值进行滤波处理@10次*)
	rDeltaTheta: REAL;		(*2023.07.18.094748*)
END_VAR
{IMPLEMENTATION}
dwAbsPos_Cur:=i_dwAbsPos_Cur;

IF i_xAxis_Cur THEN(*A轴*)
	IF i_pdwAbsPos_0Rad_AxisA<>0 THEN
		dwAbsPos_0Rad:=i_pdwAbsPos_0Rad_AxisA^;
	END_IF
ELSE(*当前轴为B轴*)
	IF i_pdwAbsPos_0Rad_AxisB<>0 THEN
		dwAbsPos_0Rad:=i_pdwAbsPos_0Rad_AxisB^;
	END_IF
END_IF

(*确认0弧度对应的绝对值位置*)
fbConfirmAbsPos_0Rad(CLK:=i_xConfirmRad);
KS_GetAbsPos_0Rad(fbConfirmAbsPos_0Rad.Q, dwAbsPos_Cur, ADR(dwAbsPos_0Rad));
(*当前弧度计算*)
lrTheta_Cur:=KS_CalcRadByAbsEnc(I_xTowerDir_Uw, dwAbsPos_0Rad, dwAbsPos_Cur,i_dwAbsEnCodeResolution );


(*将下面使用的弧度值全部替换为了滤波后的弧度值@2023.6.13.162642*)
(*上个周期弧度值初始化*)
IF i_xConfirmRad OR xInitLastRad THEN(*确认弧度和绝对位置的关系时，重新初始化弧度备份值*)
	fbKS_FB_FiltByAver(i_xEn:= FALSE);(*复位滤波函数*)
	lrLastTheta:=lrTheta_Cur;
END_IF
o_rTheta_Cur:=LREAL_TO_REAL(lrTheta_Cur);
xInitLastRad:=FALSE;

xCutOnDown:=NOT i_xOnTop;

IF i_xEn THEN
	(*2022.5.17.114502 判断是否接触到到导向辊*)
	KS_FilmToTowerRollerDis(
		BOOL_TO_BYTE(xCutOnDown)(*i_byMaterialPath*),
		i_rDiam_DeflectorRollPos(*i_rDiam_DeflectorRollPos*),
		i_rDiam_DeflectorRoller(*i_rDiam_DeflectorRoller*),
		rDiam_CurAxis(*i_rDiam_CurAxis*),
		i_rDiam_Tower(*i_rDiam_Tower*),
		i_rDiam_NextRoller(*i_rDiam_NextRoller*),
		i_rXPos_NextRoller(*i_rXPos_NextRoller*),
		i_rYPos_NextRoller(*i_rYPos_NextRoller*),
		lrTheta_Cur(*i_rTheta_Cur*),
		ADR(o_rFilmToTowerRollerDis)(*i_prFilmToTowerRollerDis*),
		ADR(o_xFilmTouchRoller)(*i_pxFilmTouchRoller*));

	KS_CalcFilmLenth_TowerToNextRoller(
(*		I_xTowerDir_Uw,*)
		dwAbsPos_0Rad,
		dwAbsPos_Cur,
		i_iCycleTime_Plc,
		rDiam_CurAxis,
		i_rDiam_Tower,
		i_rDiam_NextRoller,
		i_rXPos_NextRoller,
		i_rYPos_NextRoller,
		lrTheta_Cur,
		lrLastTheta,
		ADR(lrDeltaW_RPMIN),
		i_rDiam_DeflectorRollPos(*i_rDiam_DeflectorRollPos*),
		i_rDiam_DeflectorRoller(*i_rDiam_DeflectorRoller*),
		o_xFilmTouchRoller(*i_xFilmTouchRoller*),
		BOOL_TO_BYTE(xCutOnDown)(*i_byMaterialPath*));

	(*使能的时候翻转架是在转动的|由于电位器方式时，会有一定时间的死区，该部分
	的处理方式是保持之前的输出转速不变|2021.7.12.174454*)
	(*检查弧度在运动过程中最大的变化量|*)

	(*2023.07.18.094717@过圈问题处理*)
	rDeltaTheta:= LREAL_TO_REAL(ABS(lrTheta_Cur-lrLastTheta));
	IF rDeltaTheta>lrDeltaTheta_Max AND
		rDeltaTheta<gc_lrPI THEN(*2023.07.18.094910  判断过圈*)
		lrDeltaTheta_Max:=rDeltaTheta;
	END_IF
	IF ABS(lrLastTheta-lrTheta_Cur)<lrDeltaTheta_Max/100 THEN(*变化量小于最大的1/100-我们认为进入了电位器电压死区。*)
		(*保持之前的输出量*)
		;(*不更新输出值*)
	ELSE(*正常运动|输出计算值*)
		(*2023.6.13.164033 屏蔽*)
(*		o_lrDeltaW_RPMIN:=lrDeltaW_RPMIN;*)
		o_rActDeltaW_RPMIN:=LREAL_TO_REAL(lrDeltaW_RPMIN);(*修改了变量定义@2023.6.13.164026*)
	END_IF

	(*2023.6.13.163439 对输出的转速进行滤波@不能对输入的角度滤波，过圈会麻烦了*)
	fbKS_FB_FiltByAver(
		i_xEn:= TRUE,
		i_iFiltTimes:=5(*10*),(*滤波时间减小到5个周期*)
		i_dwDataAdr:= ADR(o_rActDeltaW_RPMIN),
		i_byDataType:= TYPE_LREAL,
		i_xFrom0Average:=FALSE,(*2024.05.21.163449*)
		o_xEn=> ,
		o_alrArrData=> ,
		o_rFiltData=> o_rDeltaW_RPMIN,
		o_iCode=> );


	lrLastTheta:=lrTheta_Cur;
ELSE
	xInitLastRad:=TRUE;
	rDiam_CurAxis:=i_rDiam_CurAxis;(*取当前卷径值|在补偿过程中不变化*)
	lrDeltaTheta_Max:=0;
	o_rDeltaW_RPMIN:=0;
	o_rActDeltaW_RPMIN:=0;(*2023.6.13.164229*)
	o_xFilmTouchRoller:=FALSE;
	o_rFilmToTowerRollerDis:=0;
	(*2023.6.13.163637@复位滤波函数*)
	fbKS_FB_FiltByAver(i_xEn:= FALSE);
END_IF



IF i_pdwAbsPos_0Rad_AxisA<>0 AND i_pdwAbsPos_0Rad_AxisB<>0 THEN
	IF i_xAxis_Cur THEN(*A轴*)
		i_pdwAbsPos_0Rad_AxisA^:=dwAbsPos_0Rad;
		IF fbConfirmAbsPos_0Rad.Q THEN(*确认0度值|更新2个轴*)
			(*2个对称*)
			i_pdwAbsPos_0Rad_AxisB^:=(i_dwAbsEnCodeResolution/2+dwAbsPos_0Rad) MOD i_dwAbsEnCodeResolution;
		END_IF
	ELSE(*当前轴为B轴*)
		i_pdwAbsPos_0Rad_AxisB^:=dwAbsPos_0Rad;
		IF fbConfirmAbsPos_0Rad.Q THEN(*确认0度值|更新2个轴*)
			i_pdwAbsPos_0Rad_AxisA^:=(i_dwAbsEnCodeResolution/2+dwAbsPos_0Rad) MOD i_dwAbsEnCodeResolution;
		END_IF
	END_IF
END_IF