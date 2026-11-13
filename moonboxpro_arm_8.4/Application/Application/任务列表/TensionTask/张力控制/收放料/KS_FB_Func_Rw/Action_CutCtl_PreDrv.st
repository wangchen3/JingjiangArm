(*@CES
Name=Action_CutCtl_PreDrv
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=94f2aeed-6b29-4361-a9ac-1699161f5862
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}


fbKS_FB_PreDrv_CTL(
	i_xEn:= xSts_ArmFall_end AND o_xSts_PreCutting, (*预备接料且大臂落下*)
	i_lrVel_Film:= i_rVel_Film,
	i_diTime_Acc_PreDrv:= iTime_PreDrvAcc_In,
	i_iTime_Cycle:= i_iCycleTime_Plc,
	i_lrVel_Max:= i_rVel_Max,
	i_lrCoef_PreDrv:= 1,
	i_uiMaxVel_UseCalcAcc:=REAL_TO_UINT(i_rVel_Max),(*2024.04.12.183151+@预取部分还是按照系统最大速度处理*)
	io_rVel_PreDrv:= rVel_Predrv_Out,
	o_xEno=> ,
	o_xIng_PreDrv=> xFlag_PreDrv_ing_Out,
	o_xDone_PreDrv=> xFlag_PreDrv_end_Out,
	o_xPreDrvAxis_Releasing=> xPreDrvAxis_Releasing_Out);