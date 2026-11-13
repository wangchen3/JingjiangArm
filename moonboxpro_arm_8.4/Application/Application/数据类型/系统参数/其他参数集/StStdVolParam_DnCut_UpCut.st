(*@CES
Name=StStdVolParam_DnCut_UpCut
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=0efb4f92-3457-447a-bc79-dd669d3876a7
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StStdVolParam_DnCut_UpCut :
STRUCT
	alrStdVol_Diam		: ARRAY [1..4] OF LREAL;(* 标准卷径值 *)
	alrStdVol_Volt_AxisA: ARRAY [1..4] OF LREAL; (* 标准卷径对应的电压值|2019.1.25.142552|更名A轴 *)
	alrStdVol_Coef_AxisA: ARRAY [0..4] OF LREAL; (* 分段系数|2019.1.25.142601|更名A轴|[0]表<=1,[1]表>1&& <=2,[2]表>2&& <=3,[3]表>3&& <=4,[4]表>4 *)
	alrStdVol_Volt_AxisB: ARRAY [1..4] OF LREAL; (* 标准卷径对应的电压值|2019.1.25.142524|新增B轴 *)
	alrStdVol_Coef_AxisB: ARRAY [0..4] OF LREAL; (* 分段系数|2019.1.25.142542|新增B轴|[0]表<=1,[1]表>1&& <=2,[2]表>2&& <=3,[3]表>3&& <=4,[4]表>4 *)
	abyReserved: ARRAY [1..50] OF BYTE; (* 保留区域 *)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
