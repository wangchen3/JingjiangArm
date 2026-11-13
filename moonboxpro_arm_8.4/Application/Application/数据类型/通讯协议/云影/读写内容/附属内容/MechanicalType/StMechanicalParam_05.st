(*@CES
Name=StMechanicalParam_05
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=b33b6712-01bf-4f1b-8580-04159c6363c6
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StMechanicalParam_05 :(*欧诺直压结构+力达直压结构*)
(*2026.08.27.095501*)
(*2023.11.27.104910 同步更新*)
STRUCT
	rX1:REAL;(**)
	rX2:REAL;(**)
	rX3:REAL;(**)
	rX4:REAL;(**)


	rY0:REAL;(**)
	rY1:REAL;(**)
	(*[AI修改20260829]rL2_3已移除|辊2-3垂直中心距为动态值(rY2-rY3,rY3=Y0+版半径+D3半径,随版径浮动),非静态尺寸;槽位改为rY2=辊2安装高度(固定图纸值)*)
	rY2:REAL;
	rY4:REAL;(**)

	(*[AI修改20260827]rD0已移除|版辊直径由本轴版周长rGirth_PrnRoller/π/2推算,不作静态机械参数*)
	rD1:REAL;(**)
	rD2:REAL;(**)
	rD3:REAL;(**)
	rD4:REAL;(**)


END_STRUCT
END_TYPE
{IMPLEMENTATION}
