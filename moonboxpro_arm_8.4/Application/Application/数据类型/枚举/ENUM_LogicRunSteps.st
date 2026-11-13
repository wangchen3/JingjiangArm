(*@CES
Name=ENUM_LogicRunSteps
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=7d453960-5c1c-45de-90db-0b154bc5d5ec
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE ENUM_LogicRunSteps :
(
	RUNSTEP_STARTUP					,(*初始化内容*)
	RUNSTEP_RdRingNetStationDetails	,(* 读取驱动器所有的相关信息 *)
	RUNSTEP_LoadSysParam			,(* 装载系统参数 *)
	RUNSTEP_LoadSysCfg				,(* 加载系统配置/2021.11.29.181715/hdp *)
	RUNSTEP_UpdateSysCfg			,(* 更新系统配置/2021.11.29.181715/hdp *)
	RUNSTEP_LoadCfg_Motor			,(* 过渡状态 *)
	RUNSTEP_NormalWork				,(* 正常工作状态 *)
(*deprecated@2021.12.21.163944/hdp
	RUNSTEP_Enter_Cfg_Wizard		,(* 进入系统配置的向导页/2021.11.29.174122/hdp *)
*)
(*deprecated@2021.12.21.161925/hdp
	RUNSTEP_Enter_Param_Wizard		,(* 进入系统参数的向导页/2021.11.29.174122/hdp *)
*)
	RUNSTEP_SETMODAL				,(*2024.10.25.083548设置模态*)
	RUNSTEP_RESERVED				 (* 保留 *)
);
END_TYPE

{IMPLEMENTATION}
