(*@CES
Name=KS_GetAxisInfByStationIdForMap
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=05eda7a9-c666-455e-82aa-6ccc3756d356
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetAxisInfByStationIdForMap : stEnumAxisId
(*通过站号id获取轴信息@依赖定义的站号配置表(一般不会变化)*)
(*不处理0号站*)
VAR_INPUT
	i_iStationId:INT;(*站号*)
	i_piFuncId:POINTER TO stEnumFuncId;(*只针对色组轴*)
	i_piMoveType:POINTER TO stEnumMoveType;(*运动的类型也可以获取*)
END_VAR
VAR
	iAxisId		: stEnumAxisId		:=AXISID_INVALID;
	iFuncId		: stEnumFuncId		:=FUNCID_NULL;(*只针对色组轴*)
	iMoveType	: stEnumMoveType	:=MOVETYPE_NULL;(*运动的类型也可以获取*)
	byStationId	: BYTE;
	byTmpL4		: BYTE;(*低4bit*)
	byTmpH4		: BYTE;(*高4bit*)
	//ilen:int;
END_VAR
{IMPLEMENTATION}
IF i_iStationId>0 AND i_iStationId<=255 THEN
	byStationId:=INT_TO_BYTE(i_iStationId);
	byTmpL4:= byStationId AND 16#0F;
	byTmpH4:= SHR(byStationId,4);
	(*检查是不是色组@按照规则低4位为色组id号*)
	IF byTmpL4>0 AND byTmpL4<=16#0F THEN
		//iAxisId := iTmpL4;(*和枚举定义对应*)
		//ilen := SIZEOF(iAxisId);
		KS_Int2Enum(ADR(iAxisId),BYTE_TO_INT(byTmpL4)(*iTmpL4*));
		(*高bit代表功能*)
		CASE byTmpH4 OF
			0:iFuncId:=FUNCID_CONTROL;					iMoveType:=MOVETYPE_NULL;
			1:iFuncId:=FUNCID_PRNROLLER;				iMoveType:=MOVETYPE_ROTARY_SUPERPOS;
			2:iFuncId:=FUNCID_NETROLLER;				iMoveType:=MOVETYPE_ROTARY;
			3:iFuncId:=FUNCID_BOTTOMROLLER;				iMoveType:=MOVETYPE_ROTARY;
			4:iFuncId:=FUNCID_HORZ;						iMoveType:=MOVETYPE_TRAP;
			5:(*不是色组轴*)iAxisId:=AXISID_INVALID;
			6:(*不是色组轴*)iAxisId:=AXISID_INVALID;
			7:iFuncId:=FUNCID_PRNROLLER_PRESSURE_M;		iMoveType:=MOVETYPE_GANTRY;
			8:iFuncId:=FUNCID_PRNROLLER_PRESSURE_G;		iMoveType:=MOVETYPE_GANTRY;
			9:iFuncId:=FUNCID_NETROLLER_PRESSURE_M;		iMoveType:=MOVETYPE_GANTRY;
			10:iFuncId:=FUNCID_NETROLLER_PRESSURE_G;	iMoveType:=MOVETYPE_GANTRY;
		ELSE;
		END_CASE
	ELSIF byTmpL4=0 THEN(*低位为0|主要收放牵和收放料*)
		CASE byTmpH4 OF
			1:(*放A*)	iAxisId:=AXISID_UWA;				iMoveType:=MOVETYPE_ROTARY;
			2:(*放B*)	iAxisId:=AXISID_UWB;				iMoveType:=MOVETYPE_ROTARY;
			3:(*收A*)	iAxisId:=AXISID_RWA;				iMoveType:=MOVETYPE_ROTARY;
			4:(*收B*)	iAxisId:=AXISID_RWB;				iMoveType:=MOVETYPE_ROTARY;
			5:(*放牵*)	iAxisId:=AXISID_IF;					iMoveType:=MOVETYPE_ROTARY;
			6:(*收牵*)	iAxisId:=AXISID_OF;					iMoveType:=MOVETYPE_ROTARY;
		ELSE;
		END_CASE
	ELSE;
	END_IF

	(*还有剩余的双收双放应用到的站处理|这部分就单独处理吧*)
	IF iAxisId = AXISID_INVALID THEN(*未找到就再找找*)
		CASE byStationId OF
			92:(*放A@II*)iAxisId:=AXISID_UWA_II;				iMoveType:=MOVETYPE_ROTARY;
			93:(*放B@II*)iAxisId:=AXISID_UWB_II;				iMoveType:=MOVETYPE_ROTARY;
			94:(*收A@II*)iAxisId:=AXISID_RWA_II;				iMoveType:=MOVETYPE_ROTARY;
			95:(*收B@II*)iAxisId:=AXISID_RWB_II;				iMoveType:=MOVETYPE_ROTARY;
			96:(*收牵*);
			97:(*放牵@II*)iAxisId:=AXISID_IF_II;				iMoveType:=MOVETYPE_ROTARY;
			98:(*收牵@II*)iAxisId:=AXISID_OF_II;				iMoveType:=MOVETYPE_ROTARY;
			99:(*中心辊*)iAxisId:=AXISID_CENTER;				iMoveType:=MOVETYPE_ROTARY;
		ELSE;
		END_CASE
	END_IF
END_IF
IF i_piFuncId<>0 THEN
	i_piFuncId^:=iFuncId;
END_IF
IF i_piMoveType<>0 THEN
	i_piMoveType^:=iMoveType;
END_IF

KS_GetAxisInfByStationIdForMap:=iAxisId;

