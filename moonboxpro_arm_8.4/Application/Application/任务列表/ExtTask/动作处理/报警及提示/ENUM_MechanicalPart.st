(*@CES
Name=ENUM_MechanicalPart
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=15e29af9-ac32-46fe-9cbd-84b481b11a74
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
// {attribute 'qualified_only'}
// {attribute 'strict'}
TYPE ENUM_MechanicalPart :
(
	enum_member := 0,
	MECHANICALPART_PRNROLLER 	:= 3001,
	MECHANICALPART_NETROLLER 	:= 3002,
	MECHANICALPART_BOTTOMROLLER := 3003,
	MECHANICALPART_IF 			:= 3004,
	MECHANICALPART_OF 			:= 3005,
	MECHANICALPART_UW_A 		:= 3006,
	MECHANICALPART_UW_B 		:= 3007,
	MECHANICALPART_RW_A 		:= 3008,
	MECHANICALPART_RW_B 		:= 3009,
	MECHANICALPART_CENTERROLLER := 3010,
	MECHANICALPART_PRN_PRESS_M	:= 3011,
	MECHANICALPART_PRN_PRESS_G  := 3012,
	MECHANICALPART_NET_PRESS_M	:= 3013,
	MECHANICALPART_NET_PRESS_G  := 3014,
	MECHANICALPART_STR_PRESS_M	:= 3015,
	MECHANICALPART_STR_PRESS_G  := 3016,
	MECHANICALPART_INK_ROLLER	:= 3017,
	MECHANICALPART_SCRAPER		:= 3018,
	MECHANICALPART_HORZ			:= 3019,
	MECHANICALPART_PHOTOCELL	:= 3020
	
);
END_TYPE

	(*机械位置信息*)
(*
3001-----------------版辊
3002-----------------网辊
3003-----------------底辊
3004-----------------放牵
3005-----------------收牵
3006-----------------放料A
3007-----------------放料B
3008-----------------收料A
3009-----------------收料B
3010-----------------中心辊
3011-----------------版辊压力操作侧
3012-----------------版辊压力传动侧
3013-----------------网辊压力操作侧
3014-----------------网辊压力传动侧
3015-----------------张带压力操作侧
3016-----------------张带压力传动侧
3017-----------------递墨辊变频
3018-----------------刮刀变频
3019-----------------横向
3020-----------------光电眼
*)
{IMPLEMENTATION}
