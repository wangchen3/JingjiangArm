(*@CES
Name=ENUMS_STEP_RDRINGNET
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=ae3e14f3-c75e-4491-bf67-9f081b73171a
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE ENUMS_STEP_RDRINGNET :
(
	CASE_STANDBY				:= -1,(* 默认就绪状态 *)
	CASE_GET_RINGNET_INF		:= 1,(* 读取等环网网络信息 *)
	CASE_GET_DRV_TYPE			:= 2,(* 读取驱动器的型号 *)
	CASE_GET_DRV_PWR_LEVEL		:= 3,(* 读取驱动器的功率等级 *)
	CASE_GET_DRV_FW_VERSION		:= 4,(* 读取驱动器的固件版本 *)
	CASE_GET_DRV_PARAM_NRS		:= 5,(* 读取电机的额定转速 *)
	CASE_GET_DRV_PARAM_NOS		:= 6,(* 读取电机的过速转速 *)
	CASE_GET_DRV_PARAM_IMAX		:= 7,(* 读取电机的最大电流 *)
	CASE_GET_DRV_PARAM_POSOFST	:= 8,(* 读取位置偏移 *)
	CASE_GEN_SUMMARY_OF_STATION	:= 9,(* 生成有关站号的摘要信息 *)
	CASE_GET_DRV_PARAM_TORQUE	:= 10(* 读取扭矩系数 *)
);
END_TYPE

{IMPLEMENTATION}
