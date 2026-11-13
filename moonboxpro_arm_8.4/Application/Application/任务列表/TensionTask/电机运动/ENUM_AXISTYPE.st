(*@CES
Name=ENUM_AXISTYPE
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=3491d2c6-312e-4e3b-a260-e28b79963db4
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE ENUM_AXISTYPE :
(
	TYPE_MASTER_I,(*虚拟主轴/A系*)
	TYPE_MASTER_II,(*虚拟主轴/A系*)
	TYPE_CENTRAL_I,(*中心辊A*)
	TYPE_CENTRAL_II,(*中心辊B*)
	TYPE_UNWIND_A_I,(*放料A-A系*)
	TYPE_UNWIND_A_II,(*放料A-B系*)
	TYPE_UNWIND_B_I,(*放料B-A系*)
	TYPE_UNWIND_B_II,(*放料B-B系*)
	TYPE_REWIND_A_I,(*收料A-A系*)
	TYPE_REWIND_A_II,(*收料A-B系*)
	TYPE_REWIND_B_I,(*收料B-A系*)
	TYPE_REWIND_B_II,(*收料B-B系*)
	TYPE_INFEED_I,(*放牵A系*)
	TYPE_INFEED_II,(*放牵B系*)
	TYPE_OUTFEED_I,(*收牵A系*)
	TYPE_OUTFEED_II,(*收牵B系*)
	//TYPE_UNIT_CTL,(*色组控制轴@2026.5.20.135909 by liu.yt*)
	TYPE_UNIT_PRN,(*色组版辊*)
	TYPE_UNIT_ADJ,(*色组调整轴*)
	TYPE_UNIT_BOTTOM,(*色组底辊*)
	TYPE_UNIT_NET,(*色组网辊*)
	TYPE_UNIT_PRN_PRESS_MASTER,(*色组版辊龙门主轴*)
	TYPE_UNIT_PRN_PRESS_M,(*色组版辊龙门从轴M侧*)
	TYPE_UNIT_PRN_PRESS_G,(*色组版辊龙门从轴G侧*)
	TYPE_UNIT_NET_PRESS_MASTER,(*色组网辊龙门主轴*)
	TYPE_UNIT_NET_PRESS_M,(*色组网辊龙门从轴M侧*)
	TYPE_UNIT_NET_PRESS_G,(*色组网辊龙门从轴G侧*)
	TYPE_UNIT_STR_PRESS_MASTER,(*色组张带辊龙门主轴*)
	TYPE_UNIT_STR_PRESS_M,(*色组张带龙门从轴M侧*)
	TYPE_UNIT_STR_PRESS_G,(*色组张带龙门从轴G侧*)
	TYPE_UNIT_HORIZ,(*色组横向电机*)
	TYPE_UNIT_CTL,(*色组控制轴@2026.5.20.135909 by liu.yt*)
	TYPE_NULL(*未知*)
);
END_TYPE


{IMPLEMENTATION}
