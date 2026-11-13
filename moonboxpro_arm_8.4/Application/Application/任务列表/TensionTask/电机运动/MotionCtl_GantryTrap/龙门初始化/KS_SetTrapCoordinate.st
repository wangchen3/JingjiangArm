(*@CES
Name=KS_SetTrapCoordinate
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=85d53ab4-0f75-440b-8ca0-1f3db38cc721
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_SetTrapCoordinate : INT
VAR_INPUT
	i_xEn : BOOL;
	i_iTarget_Num : INT;
	i_paiTargetStationList : POINTER TO ARRAY [1..MAX_STATION_NUM] OF INT;
	i_paliABSEncPos: POINTER TO ARRAY [1..MAX_STATION_NUM] OF LINT;//零位绝对编码器位置
	i_paxAxisRev : POINTER TO ARRAY [1..MAX_STATION_NUM] OF BOOL;
	i_pastStAxisIdListInf :POINTER TO ARRAY [1..128] OF StAxisIdListInf;
	i_pastStGetMotionSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StGetMotionSts;	
	i_pstStSysStationInf			:POINTER TO StSysStationInf;
	i_pstStSysGantryAxisInf : POINTER TO StSysGantryAxisInf;
	i_palrCurrentAbsPos: POINTER TO ARRAY [1..MAX_STATION_NUM] OF LREAL;
END_VAR
VAR
	iN : INT;
	iRtn : INT;
	iResult : INT;
	//iStationId : INT;
	iAxisId : INT;
	iTypeId : INT;
	iUnitId : INT;
	iCoreId : INT;
	iGroupId : INT;
	iAdjAxisId : INT;
	
	
	//liGantryCurrentAbsPos : LINT;
	
	alrCurrentAbsPos : ARRAY [1..MAX_STATION_NUM] of LREAL;

END_VAR

{IMPLEMENTATION}
iResult := 0;
IF i_xEn THEN
	IF i_paiTargetStationList <> 0 AND i_paliABSEncPos <> 0 AND i_pastStAxisIdListInf <> 0 AND i_pastStGetMotionSts <> 0  THEN
		FOR iN := 1 TO i_iTarget_Num BY 1 DO
// 			KS_HY_GetAxisIdForMotByStation(
// 				i_paiTargetStationList^[iN],
// 				ADR(iAxisId),
// 				ADR(iTypeId),
// 				ADR(iUnitId),
// 				ADR(iCoreId),
// 				ADR(iGroupId),
// 				ADR(iAdjAxisId),
// 				i_pastStAxisIdListInf);
				
			KS_GetAxisIdForMotByStation_Gantry(
				i_iStationId:=i_paiTargetStationList^[iN],
				i_piAxisId:= ADR(iAxisId), 
				i_piTypeId:= ADR(iTypeId), 
				i_piUnitId:= ADR(iUnitId), 
				i_piCoreId:= ADR(iCoreId), 
				i_piGroupId:= ADR(iGroupId), 
				i_piAdjAxisId:= ADR(iAdjAxisId), 
				i_pstStSysStationInf:= i_pstStSysStationInf,
				i_pstStSysGantryAxisInf := i_pstStSysGantryAxisInf);	
			
			g_aliTrapAbsPos[(iCoreId-1) * gc_ResCount_Profile + iAxisId] := i_paliABSEncPos^[iN];
			
			//iRtn := GTN_RN_GetAbsEncPosEx(core:= iCoreId, encoder:= iAxisId, pEncPos:= ADR(liGantryCurrentAbsPos));
			iRtn := GTN_RN_ReadAbsEncPos(cardIndex:= 1, stationPhyId:= i_paiTargetStationList^[iN], encoder:= 1, pPos:= ADR(alrCurrentAbsPos[iN]));
			SysMemCpy(i_palrCurrentAbsPos,ADR(alrCurrentAbsPos),SIZEOF(alrCurrentAbsPos));	
			IF iRtn<>0 THEN
				iResult := iRtn;
				
			//2026.02.04.165726 | + | 增加获取编码器成功后将编码器值清零，规划位置也清零了
			ELSE
				iRtn := GTN_ZeroPos(iCoreId,iAxisId,1);
			//2026.02.04.165726 | + | 增加获取编码器成功后将编码器值清零，规划位置也清零了
			END_IF
			iRtn := GTN_ZeroPos(iCoreId,iAxisId,1);
			//2026.02.04.171335 | + | 下面这里只需要用当前绝编值减掉标定值就行了
// 			IF i_paxAxisRev^[iN] THEN
// 				g_aliTrapAbsPos[(iCoreId-1) * gc_ResCount_Profile + iAxisId] := g_aliTrapAbsPos[(iCoreId-1) * gc_ResCount_Profile + iAxisId] - LREAL_TO_LINT(alrCurrentAbsPos[iN]) - g_aliM_EncPos[(iCoreId-1) * gc_ResCount_Profile + iAxisId];//aliM_EncPos是什么，从哪里来？？？
// 			ELSE
				g_aliTrapAbsPos[(iCoreId-1) * gc_ResCount_Profile + iAxisId] := LREAL_TO_LINT(alrCurrentAbsPos[iN]) - g_aliTrapAbsPos[(iCoreId-1) * gc_ResCount_Profile + iAxisId] (*- g_aliM_EncPos[(iCoreId-1) * gc_ResCount_Profile + iAxisId]*);
//			END_IF
		END_FOR
	ELSE
		iResult := -1;
	END_IF
END_IF
KS_SetTrapCoordinate := iResult;