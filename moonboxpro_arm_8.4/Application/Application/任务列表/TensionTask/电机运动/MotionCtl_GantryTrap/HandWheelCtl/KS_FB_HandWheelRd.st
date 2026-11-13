(*@CES
Name=KS_FB_HandWheelRd
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=56e9b8aa-8bae-4116-9277-461cb8a3efcc
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_HandWheelRd
VAR_INPUT
	i_xEn: BOOL;
	i_pastStHandWheel: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StHandWheel;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	iN: INT;
	iM : INT;
	iCountAddBlankNum : INT;
	iRtn : INT;
	iRtn_Read: INT;
	iRtn_Write: INT;
	stStHandPrm: StHandWheelPrm;
	iRtn_UnitId : INT;
	asDisplay_HardWheel_HMI: ARRAY [1..MAX_UNIT_NUM,1..4] OF STRING(16);(*手轮HMI显示-*)
	axRtnCmp_HMI : ARRAY[1..MAX_UNIT_NUM,1..4] OF BOOL;
	xInit : BOOL;
	sDisplay_HardWheel_HMI1: STRING(11);
	sDisplay_HardWheel_HMI2: STRING(16);
	sDisplay_HardWheel_HMI3: STRING(16);
	sDisplay_HardWheel_HMI4: STRING(16);
	sDisplay_HardWheel_HMIAll : STRING(59);
	iLenDisplay_HardWheel_HMI1 : INT;
	iLenDisplay_HardWheel_HMI2 : INT;
	iLenDisplay_HardWheel_HMI3 : INT;
	iLenDisplay_HardWheel_HMI4 : INT;
	iBlankNum1 : INT;
	iBlankNum2 : INT;
	iBlankNum3 : INT;
	iBlankNum4 : INT;
	
	
	tTimeError : TIME;
	tTimeError1 : TIME;
	mtargetPos : LREAL;
	tTempPos : TIME; 
	tTempPos2 : TIME; 
	
	
	enc1 : REAL;
	lrlastenc : REAL;
	tTemp : TIME;
	tTemp2 : TIME;
	tDelta1 : TIME;
	
	tTemp1:TIME;
	tDelta:TIME;
	xMoving,xStopping:BOOL;
	prfPos : LREAL;
	targetPos1 : DINT;
	lrlastpos:LREAL;
	a:BOOL:= FALSE;
	b: BOOL;
	delta11 : TIME;
	m_TarPos: REAL;
	prfvalue:LREAL;
	targetpos:LREAL;
	rtn : INT;
	rtn_Stop : INT;
	timeStart : TIME;
	timeEnd : TIME;
	arTarPos : ARRAY[1..10000] OF REAL;
	stimeDelta : ARRAY [1..10000] OF TIME;
	count : DINT;
	m_TarPos222 : LREAL;
	m_vel : LREAL;
	rtn_Update : INT;
	rtn_Vel : INT;
	abykeyNum_A : ARRAY[1..1000] OF BYTE;
	countKeyNum : INT;
	
	
	timeNow : TIME;
	udiRtn : UDINT;
	stTimestamp: SYSTIME;
	stSysTimedate: RTS_SYSTIMEDATE;(* RTS_SYSTIMEDATE *)
	nowtime:STRING;
	iKK : INT;
END_VAR

{IMPLEMENTATION}
IF NOT xInit THEN
	IF iRtn = 0 THEN
		xInit := TRUE;
	ELSE
		;
	END_IF
END_IF

FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
	IF iN = 1 THEN
		iRtn_Read:= GT_RN_GetHandPrm(ADR(stStHandPrm));
		IF iRtn_Read<>0 THEN(*读取失败-继续读取*)
			;
		ELSE(*处理读取的数据*)
			i_pastStHandWheel^[iN].wButton_HardWheel:= 0;
			IF stStHandPrm.keyNum_A<>0 THEN
				i_pastStHandWheel^[iN].wButton_HardWheel:=i_pastStHandWheel^[iN].wButton_HardWheel OR SHL(1,(stStHandPrm.keyNum_A-1));
			END_IF
			
			IF stStHandPrm.keyNum_B<>0 THEN
				i_pastStHandWheel^[iN].wButton_HardWheel:=i_pastStHandWheel^[iN].wButton_HardWheel OR SHL(1,(stStHandPrm.keyNum_B-1));
			END_IF
			i_pastStHandWheel^[iN].byKnob_Right:= stStHandPrm.rate;
			i_pastStHandWheel^[iN].byKnob_Left:= stStHandPrm.axisId;
			i_pastStHandWheel^[iN].lrTargetPos_HardWheel:=stStHandPrm.targetPos;
		END_IF
	END_IF
END_FOR

// 
// //2023.8.21.152152
// IF count > 5000-1 THEN
// 	count := 1;
// END_IF
// 
// IF g_astStHandWheel[1].lrTargetPos_HardWheel <> m_TarPos222 THEN
// 	timeStart := TIME();
// 	count := count + 1;
// 	arTarPos[count] := g_astStHandWheel[1].lrTargetPos_HardWheel - m_TarPos222;
// 	m_TarPos222 := g_astStHandWheel[1].lrTargetPos_HardWheel; 
// 	stimeDelta [count] := timeStart-timeEnd;
// 	timeEnd := timeStart;
// END_IF
// 
// 
// IF countKeyNum > 1000-1 THEN
// 	countKeyNum := 1000-2;
// END_IF
// IF stStHandPrm.axisId = 6 THEN
// 	abykeyNum_A[countKeyNum] := stStHandPrm.keyNum_A;
// 	countKeyNum := countKeyNum +1;
// END_IF
//2023.8.21.152148*)
//m_vel := arTarPos[count] * 8388/200;
// 2023.07.20.234031
// IF g_xSetVelTemp THEN
// 	g_xSetVelTemp := FALSE;
// 	//rtn_Vel := GT_SetVel(profile:= 4, vel:= g_VelTemp, station_id:= 0);
// 	//rtn_Vel := GT_SetVel(profile:= 12, vel:= g_VelTemp, station_id:= 0);
// 	rtn_Vel := GT_SetVel(profile:= 20, vel:= g_VelTemp, station_id:= 0);
// 	//rtn_Update := GT_Update(mask:= SHL(WORD#1, 4-1),0);
// 	//rtn_Update := GT_Update(mask:= SHL(WORD#1, 12-1),0);
// 	//rtn_Update := GT_Update(mask:= SHL(DWORD#1, 20-1),0);
// END_IF
//2023.07.20.234033
(*
(*手轮显示，测试使用*)
		g_astStHandWheel[1].asDisplay_HardWheel_HMI[1] := '   KESAI';
		g_astStHandWheel[1].asDisplay_HardWheel_HMI[2] := BYTE_TO_STRING(g_astStHandWheel[1].byRate_HardWheel);
		g_astStHandWheel[1].asDisplay_HardWheel_HMI[3] := BYTE_TO_STRING(g_astStHandWheel[1].byAxisId_HardWheelCtl);
		g_astStHandWheel[1].asDisplay_HardWheel_HMI[4] := DINT_TO_STRING(g_astStHandWheel[1].diTargetPos_HardWheel);
*)
(*
//2023.8.21.151901
enc1 := g_astStWatch_Sts_display[10].rPos_Prf;
IF ABS(enc1-lrlastenc)<168 AND tTemp1 <> T#0MS THEN
	IF tTemp2=T#0MS THEN
		tTemp2:=TIME();
		tDelta1:=tTemp2-tTemp1;
		a := false;
	END_IF
ELSE
	tTemp2:=T#0MS;
END_IF
lrlastenc:=enc1;

prfPos := stStHandPrm.targetPos;//[1].lrTargetPos_HardWheel;//.targetPos;
IF ABS(prfPos-lrlastpos) < 3  AND  a = TRUE THEN
	IF tTemp1=T#0MS THEN
		tTemp1:=TIME();
		rtn := GT_GetPrfPos(
		profile:= 1, 
		pValue:= ADR(prfvalue), 
		count:= 1, 
		pClock:= 0, 
		station_id:= 51);
		targetpos := prfPos;
		//rtn_Vel := GT_SetVel(profile:= 5, vel:= 0, station_id:= 0);
		//rtn_Stop := GT_Stop(mask:= 24, option:= 24, station_id:= 0);
		IF b THEN
			b := FALSE;
			tTimeError1 := TIME();
			delta11 := tTimeError1-tTimeError;
		END_IF
	END_IF
ELSE
	tTemp1:=T#0MS;
END_IF

IF ABS(prfPos-lrlastpos) > 3 THEN
	a:= TRUE;
	IF NOT b THEN
		b := TRUE;
		tTimeError := TIME();
		m_TarPos := prfPos;
	END_IF
	
END_IF

lrlastpos:=prfPos;
*)