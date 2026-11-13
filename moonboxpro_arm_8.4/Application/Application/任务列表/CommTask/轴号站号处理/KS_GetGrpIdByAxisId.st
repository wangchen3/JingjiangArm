(*@CES
Name=KS_GetGrpIdByAxisId
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=12f92d96-019f-4162-be83-866401d8db4e
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetGrpIdByAxisId : INT(*-1:参数错误或无效; 1=A系; 2=B系;|*)
VAR_INPUT
	i_iAxisId: INT; (* 轴id *)
	i_pstStSysParam: POINTER TO StSysParam; (* 参数 *)
	i_piAxisTypeId: POINTER TO INT := 0; (* 轴类型/0色组/1放牵/2收牵/3放料/4收料 *)
END_VAR
VAR
	iResult: INT;
	iUMax: INT;
	xDualUwRw: BOOL;
	xAsOneMachine: BOOL;
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;
	xUwRwByServo: BOOL; (* 2021.1.14.222029/收放料采用伺服控制 *)
END_VAR
{IMPLEMENTATION}
iResult:= -1;
IF i_piAxisTypeId<>0 THEN
	i_piAxisTypeId^:= 0;
END_IF
IF (i_iAxisId>=1 AND i_iAxisId<=MAX_STATION_NUM) AND
	i_pstStSysParam<>0 THEN
	(*the parameters are valid|*)

	pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[i_iAxisId]);(*轴入口地址|*)

	iUMax:= i_pstStSysParam^.stStSysParam_Save.iUnitMaxNum;(*最大机组数|*)
	xDualUwRw:= i_pstStSysParam^.stStSysParam_Save.dwEquipmentProf.20;(*双收双放|*)
	xAsOneMachine:= i_pstStSysParam^.stStSysParam_Save.dwEquipmentProf.21;(*A放B收|*)
	xUwRwByServo:= i_pstStSysParam^.stStSysParam_Save.dwEquipmentProf.22; (* 2021.1.14.222103|收放料伺服控制 *)

	IF i_iAxisId>iUMax THEN
		(*牵引*)
		(*或者收放料|2021.1.14.222215 *)
		IF xDualUwRw THEN(*双收双放|*)
			IF xAsOneMachine THEN(*当整台开|*)
				CASE i_iAxisId OF
				31,32:
					iResult:= 1;(*只有A系|*)
					IF i_piAxisTypeId<>0 AND i_iAxisId=31 THEN
						i_piAxisTypeId^:= 1;(*放牵|*)
					ELSIF i_piAxisTypeId<>0 AND i_iAxisId=32 THEN
						i_piAxisTypeId^:= 2;(*收牵|*)
					END_IF
				25,26,27,28: (* 2021.1.14.223803/扩展的类型 *)
					IF xUwRwByServo THEN
						iResult:= 1; (* 只有A系 *)
						IF i_piAxisTypeId<>0 AND (i_iAxisId=25 OR i_iAxisId=26) THEN (* 放料 *)
							i_piAxisTypeId^:= 3; (* 放料 *)
						ELSIF i_piAxisTypeId<>0 AND (i_iAxisId=27 OR i_iAxisId=28) THEN (* 收料 *)
							i_piAxisTypeId^:= 4; (* 收料 *)
						END_IF
					END_IF
				ELSE;
				END_CASE
			ELSE
				(*分A/B系*)
				CASE i_iAxisId OF
				30,31:
					iResult:= 1;(*A系|*)
					IF i_piAxisTypeId<>0 AND i_iAxisId=31 THEN
						i_piAxisTypeId^:= 1;(*放牵|*)
					ELSIF i_piAxisTypeId<>0 AND i_iAxisId=30 THEN
						i_piAxisTypeId^:= 2;(*收牵|*)
					END_IF
				29,32:
					iResult:= 2;(*B系|*)
					IF i_piAxisTypeId<>0 AND i_iAxisId=29 THEN
						i_piAxisTypeId^:= 1;(*放牵|*)
					ELSIF i_piAxisTypeId<>0 AND i_iAxisId=32 THEN
						i_piAxisTypeId^:= 2;(*收牵|*)
					END_IF
				23,24,25,26: (* 2021.1.14.222755/扩展 *)
					IF xUwRwByServo THEN
						iResult:= 1; (* A系 *)
						IF i_piAxisTypeId<>0 AND (i_iAxisId=25 OR i_iAxisId=26) THEN (* 放料 *)
							i_piAxisTypeId^:= 3; (* 放料 *)
						ELSIF i_piAxisTypeId<>0 AND (i_iAxisId=23 OR i_iAxisId=24) THEN (* 收料 *)
							i_piAxisTypeId^:= 4; (* 收料 *)
						END_IF
					END_IF
				21,22,27,28: (* 2021.1.14.222755/扩展 *)
					IF xUwRwByServo THEN
						iResult:= 2; (* B系 *)
						IF i_piAxisTypeId<>0 AND (i_iAxisId=21 OR i_iAxisId=22) THEN (* 放料 *)
							i_piAxisTypeId^:= 3; (* 放料 *)
						ELSIF i_piAxisTypeId<>0 AND (i_iAxisId=27 OR i_iAxisId=28) THEN (* 收料 *)
							i_piAxisTypeId^:= 4; (* 收料 *)
						END_IF
					END_IF
				ELSE;
				END_CASE
			END_IF
		ELSE(*标准机型*)
			iResult:= 1;(*只有A系|*)
			IF i_piAxisTypeId<>0 AND i_iAxisId=31 THEN
				i_piAxisTypeId^:= 1;(*放牵|*)
			ELSIF i_piAxisTypeId<>0 AND i_iAxisId=32 THEN
				i_piAxisTypeId^:= 2;(*收牵|*)
			ELSIF i_piAxisTypeId<>0 AND xUwRwByServo AND (i_iAxisId=25 OR i_iAxisId=26) THEN (* 2021.1.14.222755/放料 *)
				i_piAxisTypeId^:= 3; (* 放料 *)
			ELSIF i_piAxisTypeId<>0 AND xUwRwByServo AND (i_iAxisId=27 OR i_iAxisId=28) THEN (* 2021.1.14.222755/收料 *)
				i_piAxisTypeId^:= 4; (* 收料 *)
			END_IF
		END_IF
	ELSE
		(*色组*)
		IF xDualUwRw AND (NOT xAsOneMachine) THEN(*双收双放且不作为单台印刷机开*)
			IF pstStUnitParam_Save^.byGrpId=1 OR pstStUnitParam_Save^.byGrpId=2 THEN
				;
			ELSE(*如果系id有问题就都分配到A系|*)
				pstStUnitParam_Save^.byGrpId:= 1;
			END_IF
		ELSE
			pstStUnitParam_Save^.byGrpId:= 1;
		END_IF
		iResult:= BYTE_TO_INT(pstStUnitParam_Save^.byGrpId);
	END_IF
END_IF

KS_GetGrpIdByAxisId:= iResult;