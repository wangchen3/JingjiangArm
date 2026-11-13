(*@CES
Name=KS_FB_HandWheelRd_Wr
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=44523763-61a9-4779-9c1b-89e0f1500c64
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_HandWheelRd_Wr
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
	iRtn := GT_RN_UsbInit();
	IF iRtn = 0 THEN
		xInit := TRUE;
	ELSE
		;
	END_IF
END_IF

FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
	IF iN = 1 THEN	
		sDisplay_HardWheel_HMI1 := i_pastStHandWheel^[iN].asDisplay_HardWheel_HMI[1];
		sDisplay_HardWheel_HMI2 := i_pastStHandWheel^[iN].asDisplay_HardWheel_HMI[2];
		sDisplay_HardWheel_HMI3 := i_pastStHandWheel^[iN].asDisplay_HardWheel_HMI[3];
		sDisplay_HardWheel_HMI4 := i_pastStHandWheel^[iN].asDisplay_HardWheel_HMI[4];
		iLenDisplay_HardWheel_HMI1 := LEN(sDisplay_HardWheel_HMI1);
		iLenDisplay_HardWheel_HMI2 := LEN(sDisplay_HardWheel_HMI2);
		iLenDisplay_HardWheel_HMI3 := LEN(sDisplay_HardWheel_HMI3);
		iLenDisplay_HardWheel_HMI4 := LEN(sDisplay_HardWheel_HMI4);
		iBlankNum1 := 11 - iLenDisplay_HardWheel_HMI1;
		iBlankNum2 := 16 - iLenDisplay_HardWheel_HMI2;
		iBlankNum3 := 16 - iLenDisplay_HardWheel_HMI3;
		iBlankNum4 := 16 - iLenDisplay_HardWheel_HMI4;
		FOR iCountAddBlankNum := 1 TO iBlankNum1 BY 1 DO
			sDisplay_HardWheel_HMI1 := CONCAT(sDisplay_HardWheel_HMI1,' ');
		END_FOR
		FOR iCountAddBlankNum := 1 TO iBlankNum2 BY 1 DO
			sDisplay_HardWheel_HMI2 := CONCAT(sDisplay_HardWheel_HMI2,' ');
		END_FOR
		FOR iCountAddBlankNum := 1 TO iBlankNum3 BY 1 DO
			sDisplay_HardWheel_HMI3 := CONCAT(sDisplay_HardWheel_HMI3,' ');
		END_FOR
		FOR iCountAddBlankNum := 1 TO iBlankNum4 BY 1 DO
			sDisplay_HardWheel_HMI4 := CONCAT(sDisplay_HardWheel_HMI4,' ');
		END_FOR
		sDisplay_HardWheel_HMIAll := sDisplay_HardWheel_HMI1;
		sDisplay_HardWheel_HMIAll := CONCAT(sDisplay_HardWheel_HMIAll,sDisplay_HardWheel_HMI2);
		sDisplay_HardWheel_HMIAll := CONCAT(sDisplay_HardWheel_HMIAll,sDisplay_HardWheel_HMI3);
		sDisplay_HardWheel_HMIAll := CONCAT(sDisplay_HardWheel_HMIAll,sDisplay_HardWheel_HMI4);
		iRtn:= GT_RN_Display(ADR(sDisplay_HardWheel_HMIAll));
	END_IF
END_FOR



