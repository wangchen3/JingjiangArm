(*@CES
Name=StRSV_GrpParam_Save
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=7706bcd4-408a-4d0b-87f9-19332368a3fa
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StRSV_GrpParam_Save :
STRUCT
	rVel_UVstartVel: REAL;
	
	rWidth_Mark_Max						: REAL;(*单个色标最大宽度 mm*)
	rWidth_Mark_Min						: REAL;(*单个色标最xiao宽度 mm*)
	rKcode_Mark_Interval					: REAL;(*1色Kcode标与色标间隔-1mm*)
	rTaps_Mark_Interval					: REAL;(*2色Taps标与色标间隔-1mm*)

	rMaxGap								: REAL;(*最大间隙，mm*)
	bySimilarityThreshold					: BYTE;(*相似度阈值*)
	bySignalType							: BYTE;(*信号类型，1北人标，暂不支持其他标*)
	xSpecialMarkEn						:BOOL;(*特殊标有效*)
	byMeanOffset							:BYTE; (*均值偏移 越大越找不到小色标，太小会出现较多信号导致直接失败*)
	
	//xi.hy
	iFiberMoveVel:INT;(*光纤行走速度*)
	iFiberMoveVel_Fast:INT;(*光纤行走速度_快速*)
	xUseOnline_FiberMove:BOOL;(*使用在线检测*)
	
	xFiberMove_Negative_AdjustByUnit:BOOL;(*色组修正取反*)
	xFiberMove_Negative_AdjustByOnline:BOOL;(*在线修正取反*)
	
//2026.4.6.130016增加全自动套印一些变量一个字节|965-1=964
	xSwitch_EnFastPress							: BOOL;//当前色找到就合压开关使能
	
//2026.4.6.132159增加几个变量2026.4.6.132210||总共76字节||964-76=
	rOuterCoff								: REAL;//=1.2;     //外滑窗系数 real 0.5~2
    rInnerCoff								: REAL;//=0.3;		//内滑窗系数 real 0.2~byOuterCoff
	arFiberMove								: ARRAY [1..2] OF REAL;//:= [-3,6];//光纤粗调移动距离 两个限制-10,10
	arModeMsg								: ARRAY [1..15] OF REAL;	//模版信息 0.1mm
	
	//2026.05.07.145638 xi.hy新增@七号以后
	byFiberMove_MicroMoveStep:BYTE;(*光纤行走微调步进量@mm*)
//2026.5.7.161608增加波形美化标志|887-1=886	
	xRsMorphFilter 								: BOOL;//美化标志

//合并一下最新修改
	rSpotwidth									:REAL;//=1.2://光斑克度1.5
	
//	abyRSV_StGrpParam_Save: ARRAY [1..886] OF BYTE;	
//2026.5.9.102848到这里是合并了凹印程序的内容|总共到886
	rVel_CoronaVel: REAL;//2026.5.9.103026重新上电后超旭程序可能电晕速度不对
//2026.05.14.112350 输入剩余卷径自动停机
	xIsAutoStop 	:BIT;
	xSwitch_Unit_bit1: BIT;
	xSwitch_Unit_bit2: BIT;
	xSwitch_Unit_bit3: BIT;
	xSwitch_Unit_bit4: BIT;
	xSwitch_Unit_bit5: BIT;
	xSwitch_Unit_bit6: BIT;
	xSwitch_Unit_bit7: BIT;
	rRemainDia_stop	:REAL;	//自动停机卷径
	rMaxErr_GantryTrap:REAL;
	//2026.05.20.85249 新增自动减速速度
	rVel_AutoDec:REAL;
	abyRSV_StGrpParam_Save: ARRAY [1..865] OF BYTE;	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
