(*@CES
Name=StStationInf
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=1a71ed59-c8a1-4603-acdd-62b44f38ce61
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StStationInf :(*站的信息@50BYTES*)
STRUCT
	xValid				:BOOL;(*信息有效标志*)
	iAxisId				:stEnumAxisId;(*轴号|-1 是非法值@色组轴id*)
	iStationId			:INT;(*站号|-1 是非法值*)
	(*FUNCID_CONTROL-->FUNCID_HORZ*)
	iFuncId				:stEnumFuncId;(*色组轴功能id@底辊、版辊、网辊、版辊压力M、版辊压力G、网辊压力M、网辊压力G、横向*)
	iMoveType			:stEnumMoveType;(*运动类型@点位运动、龙门运动、旋转运动、带位置叠加的旋转运动*)
	udiStationType		:UDINT;(*站类型*)
	(*运控*************************************************)
	(*CoreId*)
	iCoreId_LogicAxis				:INT;(*核id@逻辑轴|-1 是非法值*)
	iCoreId_LogicAxisSuperPos		:INT;(*核id@叠加轴|-1 是非法值*)
	(*规划器id*)
	iLogicAxisId					:INT;(*逻辑轴id|-1 是非法值*)
	iLogicAxisIdSuperPos			:INT;(*叠加轴id|-1 是非法值*)
	(*end*************************************************)


	(*异站*************************************************)
	xRemoteEncValid		:BOOL;(*异站有效*)
	iRemoteSrcId		:INT;(*异站源站id*)

	(*end*************************************************)

	(*冗余*)
	abyRsved			:ARRAY [1..26] OF BYTE;
END_STRUCT
END_TYPE
{IMPLEMENTATION}
