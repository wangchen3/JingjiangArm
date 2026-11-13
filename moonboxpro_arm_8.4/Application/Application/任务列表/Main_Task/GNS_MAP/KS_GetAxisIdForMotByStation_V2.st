(*@CES
Name=KS_GetAxisIdForMotByStation_V2
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=c5880d4f-2cd9-4162-8439-8609b06a0444
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetAxisIdForMotByStation_V2 : BOOL
(*转换为火眼原来设计的数据项，并输出。方便程序移植*)
VAR_INPUT
	i_iStationId			: INT;
	i_piAxisId				: POINTER TO INT;(*逻辑轴id*)
	i_piTypeId				: POINTER TO ENUM_AXISTYPE;(*类型id*)
	i_piUnitId				: POINTER TO INT;(*色组id*)
	i_piCoreId				: POINTER TO INT;(*核id*)
	i_piGroupId			 	: POINTER TO INT;(*组id*)
	i_piAdjAxisId			: POINTER TO INT;(*调整轴id*)
	(*系统列表*)
	i_pstStSysStationInf	: POINTER TO StSysStationInf;
END_VAR
VAR
	iN					:  INT;
	xResult				:  BOOL:=FALSE;
	iAxisId				:  INT:=-1;(*逻辑轴id*)
	iTypeId				:  ENUM_AXISTYPE:=TYPE_NULL;(*类型id*)
	iUnitId				:  INT:=-1;(*色组id*)
	iCoreId				:  INT:=-1;(*核id*)
	iGroupId			:  INT:=-1;(*组id*)
	iAdjAxisId			:  INT:=-1;(*调整轴id*)
	pstStStationInf		:  POINTER TO StStationInf;
END_VAR
{IMPLEMENTATION}
IF i_pstStSysStationInf <>0 THEN
	IF i_iStationId>0 AND i_iStationId<255 THEN(*站号合法性判断*)
		FOR iN:=1 TO i_pstStSysStationInf^.byStationNum BY 1 DO
			pstStStationInf:=ADR(i_pstStSysStationInf^.astStationInf[iN]);
			IF pstStStationInf^.xValid THEN
				IF i_iStationId = pstStStationInf^.iStationId THEN(*找到了*)
					xResult:=TRUE;
					iAxisId:=pstStStationInf^.iLogicAxisId;(*逻辑轴id*)
					IF KS_IsUnitAxisId(pstStStationInf^.iAxisId) THEN(*检查是不是色组的枚举*)
						iUnitId:=pstStStationInf^.iAxisId;
					END_IF
					iCoreId:=pstStStationInf^.iCoreId_LogicAxis;(*核id*)
					iAdjAxisId:=pstStStationInf^.iLogicAxisIdSuperPos;(*叠加轴id*)
					EXIT;
				END_IF
			END_IF
		END_FOR
	END_IF

	(*type处理*)
	iTypeId:=TYPE_NULL;
	IF xResult THEN
		CASE pstStStationInf^.iAxisId OF
			AXISID_UWA:		iTypeId:=TYPE_UNWIND_A_I;
			AXISID_UWB:		iTypeId:=TYPE_UNWIND_B_I;
			AXISID_RWA:		iTypeId:=TYPE_REWIND_A_I;
			AXISID_RWB:		iTypeId:=TYPE_REWIND_B_I;
			AXISID_IF:		iTypeId:=TYPE_INFEED_I;
			AXISID_OF:		iTypeId:=TYPE_OUTFEED_I;
			AXISID_UWA_II:	iTypeId:=TYPE_UNWIND_A_II;
			AXISID_UWB_II:	iTypeId:=TYPE_UNWIND_B_II;
			AXISID_RWA_II:	iTypeId:=TYPE_REWIND_A_II;
			AXISID_RWB_II:	iTypeId:=TYPE_REWIND_B_II;
			AXISID_IF_II:	iTypeId:=TYPE_INFEED_II;
			AXISID_OF_II:	iTypeId:=TYPE_OUTFEED_II;
			AXISID_CENTER:  iTypeId:=TYPE_CENTRAL_I;(*只处理单系中心辊*)
		ELSE
			(*色组*)
			IF  KS_IsUnitAxisId(pstStStationInf^.iAxisId) THEN
				CASE pstStStationInf^.iFuncId OF
					FUNCID_CONTROL:					iTypeId:=TYPE_UNIT_CTL;(*2026.5.20.135932 by liu.yt*)
					FUNCID_PRNROLLER: 				iTypeId:=TYPE_UNIT_PRN;
					FUNCID_NETROLLER: 				iTypeId:=TYPE_UNIT_NET;
					FUNCID_BOTTOMROLLER: 			iTypeId:=TYPE_UNIT_BOTTOM;
					FUNCID_PRNROLLER_PRESSURE_M: 	iTypeId:=TYPE_UNIT_PRN_PRESS_MASTER;
					FUNCID_PRNROLLER_PRESSURE_G: 	iTypeId:=TYPE_UNIT_PRN_PRESS_G;
					FUNCID_NETROLLER_PRESSURE_M: 	iTypeId:=TYPE_UNIT_NET_PRESS_MASTER;
					FUNCID_NETROLLER_PRESSURE_G: 	iTypeId:=TYPE_UNIT_NET_PRESS_G;
					FUNCID_HORZ: 					iTypeId:=TYPE_UNIT_HORIZ;
				ELSE;
				END_CASE
			END_IF
		END_CASE
	END_IF
END_IF

IF i_piAxisId<>0 THEN
	i_piAxisId^:=iAxisId;
END_IF
IF i_piTypeId<>0 THEN
	i_piTypeId^:=iTypeId;
END_IF
IF i_piUnitId<>0 THEN
	i_piUnitId^:=iUnitId;
END_IF
IF i_piCoreId<>0 THEN
	i_piCoreId^:=iCoreId;
END_IF
IF i_piGroupId<>0 THEN
	i_piGroupId^:=iGroupId;
END_IF
IF i_piAdjAxisId<>0 THEN
	i_piAdjAxisId^:=iAdjAxisId;
END_IF
KS_GetAxisIdForMotByStation_V2:=xResult;