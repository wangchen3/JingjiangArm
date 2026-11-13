(*@CES
Name=StVirtualParam
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=f05dc274-c0f1-4a79-ac21-bdede0ef0ae5
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StVirtualParam :
STRUCT
	srcPfrMotorPulse:			UDINT;(*不调整的电机，或者原计划出虚拟码盘站的电机规划脉冲，现在默认为2^21;*)
	srcPfrPrinterN:			UDINT;(*不调整的电机，或者原计划出虚拟码盘站的齿轮比;*)
	srcPfrMotorM:				UDINT;(*不调整的电机，或者原计划出虚拟码盘站的齿轮比;*)
	srcPfrId:					UDINT;(*不调整的电机，或者原计划出虚拟码盘的站站的站号;*)
	srcVirtualId:				UDINT;(*可以出虚拟码盘的站点，参考该站点的虚拟码盘值为绝对值。
											理论上该值等于src_pfr_id，但如果src_pfr_id不带虚拟码盘，则可以选择其他。
											如果该值为0xf0.则表示不需要绝对位置。那么最后输出的值则以每一次配置的时刻为零点。*)
	srcVirtualPanPoint:		UDINT;(*参考站点输出虚拟码盘的点数*)
	desVirtualPanPoint:		UDINT;(*目标站点输出虚拟码盘的点数*)
	desId:						UDINT;(*目标站点ID*)
	desDircReverse:			UDINT;(*输出AB脉冲是否需要取反.
											bit0 表示AB输出脉冲是否需要取反; 
											bit8 表示原计划出虚拟码盘站的电机规划脉冲方向为负的*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
