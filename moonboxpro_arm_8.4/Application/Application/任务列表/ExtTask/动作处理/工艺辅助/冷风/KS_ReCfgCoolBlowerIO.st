(*@CES
Name=KS_ReCfgCoolBlowerIO
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=0f7b114d-d936-480a-be34-fd41a916f68a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_ReCfgCoolBlowerIO : bool
VAR_INPUT
	i_xInput				: BOOL;(*输入重新分配*)
	i_xOutput				: BOOL;(*输出重新分配*)
	i_xCoolBlowerFlag		: BOOL;(*全体冷风启动标志*)
	i_iGrpAxisNum_Pu		:INT ; 
	i_aiGrpAxisList			: ARRAY [1..MAX_UNIT_NUM] OF INT;(*系的轴列表*)
	i_paxAxisStartEn		: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*轴启动使能|有效后按钮开关才能起作用*)
	i_paxStartKnob			: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*全体启动,每个轴旋钮输入*)
	i_paxStartOrStopBtn		: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*单轴的启动停止按钮*)
	i_paxNeedStop			: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*单轴需要停止标志*)
	i_paxAxisStarted		: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*单个轴的启动输出标志|实际处于启动状态，																		可以根据i_paxNeedStop这个变量控制实际输出*)
	i_axCoolBlower			:ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	i_axCoolBlower_Button			:ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	i_paxLamp_CoolBlower			:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	i_paxRel_CoolBlower			:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	i_paxLamp_AllCoolBlower		:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	i_pxLamp_AllCoolBlower		: POINTER TO BOOL;	
													
END_VAR
VAR_OUTPUT

END_VAR
VAR
	iUnitId: INT;
	iN: INT;
END_VAR

{IMPLEMENTATION}
IF i_paxAxisStartEn<>0 AND
	i_paxStartKnob<>0 AND
	i_paxNeedStop<>0 AND
 	i_paxStartOrStopBtn<>0 AND
	i_paxAxisStarted<>0  THEN
	IF i_xInput THEN
		FOR iN:=1 TO MAX_UNIT_NUM  BY 1 DO
			i_paxStartKnob^[iN]:=FALSE;
			i_paxStartOrStopBtn^[iN]:=FALSE;
			i_paxNeedStop^[iN]:=FALSE;
			i_paxAxisStartEn^[iN]:=FALSE;
		END_FOR

		FOR iN:=1 TO i_iGrpAxisNum_Pu  BY 1 DO
			iUnitId:=i_aiGrpAxisList[iN];
			IF iUnitId>0 AND iUnitId<= MAX_UNIT_NUM THEN
			i_paxStartKnob^[iUnitId]:=i_axCoolBlower[iUnitId];
			i_paxStartOrStopBtn^[iUnitId]:=i_axCoolBlower_Button[iUnitId];
			i_paxNeedStop^[iUnitId]:=FALSE;
			i_paxAxisStartEn^[iUnitId]:=TRUE; (*2024.3.14.165139*)
			END_IF
		END_FOR
	ELSIF i_xOutput THEN
		FOR iN:=1 TO i_iGrpAxisNum_Pu  BY 1 DO
			(*输出到牵引，*)
			
				iUnitId:=i_aiGrpAxisList[iN];
				IF iUnitId>0 AND iUnitId <= MAX_UNIT_NUM THEN(*输出循环到收牵，这样热风输出灯就可以配到收牵上了|2020.1.9.094955*)
					i_paxLamp_CoolBlower^[iUnitId]:=i_paxAxisStarted^[iUnitId];
					i_paxRel_CoolBlower^[iUnitId]:=i_paxAxisStarted^[iUnitId];
					i_paxLamp_AllCoolBlower^[iUnitId]:=i_xCoolBlowerFlag;
				END_IF
			
		END_FOR
		
	END_IF
END_IF