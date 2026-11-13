(*@CES
Name=KS_GetUnitIdAndTypeByStationId
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=562049e6-f238-457e-b203-3358a7713818
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetUnitIdAndTypeByStationId : bool
VAR_INPUT
	i_StationId: INT;
	i_piUnitId: POINTER TO INT;
	i_piTypeId: POINTER TO INT;
	i_pstStSysCfgStruct: POINTER TO StSysCfgStruct;	
END_VAR
VAR
	iUnitId:INT;
	iTypeId:INT;
	iN:INT;
	xResult: BOOL;	
END_VAR

{IMPLEMENTATION}
(*	OBJ_IS_UNDEFINED,
	OBJ_IS_UNWIND_A,(* 放卷A *)
	OBJ_IS_UNWIND_B,(* 放卷B *)
	OBJ_IS_REWIND_A,(* 收卷A *)
	OBJ_IS_REWIND_B,(* 收卷B *)
	OBJ_IS_INFEED,(* 放牵 *)
	OBJ_IS_OUTFEED,(* 收牵 *)
	OBJ_IS_BOTTOM_ROLLER,(* 色组底辊 *)
	OBJ_IS_PRN_ROLLER,(* 色组版辊 *)
	OBJ_IS_NET_ROLLER,(* 色组网辊 *)
	OBJ_IS_PRN_ROLLER_PRESSURE_M,(* 色组版辊压力M侧 *)
////OBJ_IS_PRN_ROLLER_PRESSURE_G,(* 色组版辊压力G侧 *)
////OBJ_IS_NET_ROLLER_PRESSURE_M,(* 色组网辊压力M侧 *)
////OBJ_IS_NET_ROLLER_PRESSURE_G,(* 色组网辊压力G侧 *)
////OBJ_IS_HORIZ_MOTION,(* 横向运动电机/2022.6.8.142000 *)
////OBJ_IS_CENTRAL_DRUM(* 中心滚筒/2022.6.8.135513 *)*)
xResult:= FALSE;
IF i_StationId>=0 AND i_StationId<= MAX_STATION_NUM AND
	i_pstStSysCfgStruct<>0 THEN
	IF i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_I.iSid=i_StationId AND i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_I.dwAxisProf.0 THEN
		iUnitId:= 31;
		iTypeId:= OBJ_IS_INFEED;
	ELSIF i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_I.iSid=i_StationId AND i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_I.dwAxisProf.0 THEN
		iUnitId:= 32;
		iTypeId:= OBJ_IS_OUTFEED;	
	ELSIF i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[1].iSid=i_StationId AND i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[1].dwAxisProf.0 THEN
		iUnitId:= 25;
		iTypeId:= OBJ_IS_UNWIND_A;		
	ELSIF i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[2].iSid=i_StationId AND i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[2].dwAxisProf.0 THEN
		iUnitId:= 26;
		iTypeId:= OBJ_IS_UNWIND_B;			
	ELSIF i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[1].iSid=i_StationId AND i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[1].dwAxisProf.0 THEN
		iUnitId:= 27;
		iTypeId:= OBJ_IS_REWIND_A;		
	ELSIF i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[2].iSid=i_StationId AND i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[2].dwAxisProf.0 THEN
		iUnitId:= 28;
		iTypeId:= OBJ_IS_REWIND_B;
	ELSIF i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_i[1].iSid=i_StationId AND i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[1].dwAxisProf.0 THEN
		iUnitId:= 20;(*中心辊增加一个|2024.04.01.094732*)
		iTypeId:= OBJ_IS_CENTRAL_DRUM;
	ELSIF i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_i[2].iSid=i_StationId AND i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[2].dwAxisProf.0 THEN
		iUnitId:= 21;(*中心辊增加一个|2024.04.01.094732*)
		iTypeId:= OBJ_IS_CENTRAL_DRUM;
	ELSE
		FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
			IF i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_[iN].iSid= i_StationId AND i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_[iN].dwAxisProf.0 THEN
				iUnitId:= iN;
				iTypeId:= OBJ_IS_PRN_ROLLER;				
			ELSIF i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_[iN].iSid= i_StationId AND i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_[iN].dwAxisProf.0 THEN
				iUnitId:= iN;
				iTypeId:= OBJ_IS_NET_ROLLER;	
			ELSIF i_pstStSysCfgStruct^.astStAxisCfgStruct_BR_[iN].iSid= i_StationId AND i_pstStSysCfgStruct^.astStAxisCfgStruct_BR_[iN].dwAxisProf.0 THEN
				iUnitId:= iN;
				iTypeId:= OBJ_IS_BOTTOM_ROLLER;	
			ELSIF i_pstStSysCfgStruct^.astStAxisCfgStruct_HORIZ_[iN].iSid= i_StationId AND i_pstStSysCfgStruct^.astStAxisCfgStruct_HORIZ_[iN].dwAxisProf.0 THEN
				iUnitId:= iN;
				iTypeId:= OBJ_IS_HORIZ_MOTION;	
			ELSIF i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_M_[iN].iSid= i_StationId AND i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_M_[iN].dwAxisProf.0 THEN
				iUnitId:= iN;
				iTypeId:= OBJ_IS_PRN_ROLLER_PRESSURE_M;			
			ELSIF i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_G_[iN].iSid= i_StationId AND i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_G_[iN].dwAxisProf.0 THEN
				iUnitId:= iN;
				iTypeId:= OBJ_IS_PRN_ROLLER_PRESSURE_G;		
			ELSIF i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_M_[iN].iSid= i_StationId AND i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_M_[iN].dwAxisProf.0 THEN
				iUnitId:= iN;
				iTypeId:= OBJ_IS_NET_ROLLER_PRESSURE_M;		
			ELSIF i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_G_[iN].iSid= i_StationId AND i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_G_[iN].dwAxisProf.0 THEN
				iUnitId:= iN;
				iTypeId:= OBJ_IS_NET_ROLLER_PRESSURE_G;	
			ELSIF i_pstStSysCfgStruct^.astStAxisCfgStruct_PC_[iN].iSid=i_StationId AND i_pstStSysCfgStruct^.astStAxisCfgStruct_PC_[iN].dwAxisProf.0 THEN
				iUnitId:= iN;(*光电眼行走机构 | 2024.04.01.092649*)
				iTypeId:= OBJ_IS_PHOTOCELL;	
			ELSIF i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_M_[iN].iSid= i_StationId AND i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_M_[iN].dwAxisProf.0 THEN
				iUnitId:= iN;
				iTypeId:= OBJ_IS_STR_ROLLER_PRESSURE_M;		
			ELSIF i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_G_[iN].iSid= i_StationId AND i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_G_[iN].dwAxisProf.0 THEN
				iUnitId:= iN;
				iTypeId:= OBJ_IS_STR_ROLLER_PRESSURE_G;	
			END_IF
		END_FOR				
	END_IF
	
	IF i_piUnitId<>0 THEN
		i_piUnitId^:= iUnitId;
	END_IF
	IF i_piTypeId<>0 THEN
		i_piTypeId^:= iTypeId;
	END_IF	
END_IF

KS_GetUnitIdAndTypeByStationId:= xResult;