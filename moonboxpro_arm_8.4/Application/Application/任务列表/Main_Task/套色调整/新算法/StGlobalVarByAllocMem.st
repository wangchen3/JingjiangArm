(*@CES
Name=StGlobalVarByAllocMem
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=28328b9b-d8c6-4a58-bdec-f247c42fe528
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StGlobalVarByAllocMem :(*通过内存申请获取到的一些变量@主要用于一些较大内存消耗的功能变量*)
STRUCT
	(*申请套色加减速时加速度变化量的滤波器*)
	//afbDeltaAccelerationFilter: ARRAY [2..16] OF KS_FB_FiltByAver;
	(*套色误差的滤波器*)
	//afbArcErrFilter: ARRAY [2..16] OF KS_FB_FiltByAver;(*空间不够了 不敢申请太多*)


	(*系的|*)
	(*按照套色圈周期*)
	astStArcCoupleRegister:ARRAY [1..2] OF StArcCoupleRegister;(*寄存器参数|索引为系索引*)
	astStArcCoupleRegister_Follow1: ARRAY [1..2] OF StArcCoupleRegister_Follow1;

	(*按照套色20ms周期*)
(*	astStArcCoupleRegister_20MS:ARRAY [1..2] OF StArcCoupleRegister_20MS;(*寄存器参数|索引为系索引*)*)
	astStArcCoupleRegister_Follow1_20MS: ARRAY [1..2] OF StArcCoupleRegister_Follow1;

	(*2024.7.31.063137|隔色解耦@wxy*)
	astStDecoupleDDPD:ARRAY [1..DECOUPLD_DDPD_MAX] OF StDecoupleDDPD;


	arArcAccOrDecCompensateDelayArr:ARRAY [2..16,1..200] OF REAL;(*套色加减速补偿时延数组*)

	(*套色解耦的系数解耦体@目前只处理的跟踪第一色*)
	stStDeCoupleCoeff: StDeCoupleCoeff;(*2024.9.10.134022  耦合系数*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
