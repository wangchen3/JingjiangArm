(*@CES
Name=KS_ChangeRoller_ValveCTL
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=797ebb41-ab76-4fe9-bfcb-d612c34cdc40
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_ChangeRoller_ValveCTL : BOOL(*换版阀控制*)(* 辊子套筒逻辑处理 || 2023.08.01.114908 || bai.zy*)
VAR_INPUT
	i_pastStIOMap_Axis_FE	: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|`````````````````````````````````````````````*)
	i_pstStSysParam:POINTER TO StSysParam := 0;(* 整机参数 *)
END_VAR
VAR
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;(* 色组参数 *)
	pstStIOMap_Axis_FE:POINTER TO StIOMap_Axis_FE;(*轴io数据区域|*)
	iN: INT;
END_VAR
{IMPLEMENTATION}
IF i_pastStIOMap_Axis_FE<>0 AND
	i_pstStSysParam<>0 THEN
	FOR iN:=1 TO i_pstStSysParam^.stStSysParam_Save.iUnitMaxNum BY 1 DO
		pstStUnitParam_UnSave:=ADR(i_pstStSysParam^.astStUnitParam_UnSave[iN]);
		pstStIOMap_Axis_FE:=ADR(i_pastStIOMap_Axis_FE^[iN]);
		(*版辊套筒*)
		pstStIOMap_Axis_FE^.o_xRel_Sleeve_Prn:=FALSE;
		IF pstStUnitParam_UnSave^.rAxisVel_PrnRoller = 0 THEN(*版辊运动了|*)(*版辊不运动时可进行装版 || 2023.08.01.163402 || bai.zy*)
			pstStIOMap_Axis_FE^.o_xRel_Sleeve_Prn:=
						pstStIOMap_Axis_FE^.i_xSleeve_Prn;
		END_IF
		(*网辊套筒*)
		pstStIOMap_Axis_FE^.o_xRel_Sleeve_Net:=FALSE;
		IF pstStUnitParam_UnSave^.rAxisVel_NetRoller = 0 THEN(*网辊运动了|*)(*网辊不运动时可进行装版 || 2023.08.01.163402 || bai.zy*)
			pstStIOMap_Axis_FE^.o_xRel_Sleeve_Net:=
						pstStIOMap_Axis_FE^.i_xSleeve_Net;
		END_IF

	END_FOR
END_IF