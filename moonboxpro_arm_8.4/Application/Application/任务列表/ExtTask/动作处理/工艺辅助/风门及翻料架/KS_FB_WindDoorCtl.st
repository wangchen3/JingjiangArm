(*@CES
Name=KS_FB_WindDoorCtl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=bb2160ee-041e-4be1-9f0b-a329974cf586
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_WindDoorCtl
VAR_INPUT
	i_xEn:BOOL;
	i_iGrpAxisNum_Pu: INT;(*色组轴的数量|*)
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT;(*系内所有轴的id列表,色组部分已经按照从小到大的顺序排序了，之后的是牵引|*)
	i_pstStSysParam  : POINTER TO StSysParam   ; (*系统参数*)
	i_PastStIOMap_Axis_Extra_FE:  POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_Extra_FE  ; 
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;
	
END_VAR
VAR
	iN: INT;
	iUnitId: INT;
	iTmp: INT;
	rTmp: REAL;
	
	abyAirInletWindDoorValue_FeedBack_Out :  ARRAY [1..MAX_UNIT_NUM] OF BYTE;
	abyAirInletWindDoorValue_In :  ARRAY [1..MAX_UNIT_NUM] OF BYTE;
	
	awInputAI_AirInletMotor :  ARRAY [1..MAX_UNIT_NUM] OF WORD;
	awOutputAO_AirInletMotor :  ARRAY [1..MAX_UNIT_NUM] OF WORD;
	
	pstStUnitParam_Save: POINTER TO  StUnitParam_Save;
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;
	pstStIOMap_Axis_Extra_FE:  POINTER TO  StIOMap_Axis_Extra_FE  ; 
END_VAR

{IMPLEMENTATION}

Action_Input();

Action_ActCtl() ;

Action_Output();