(*@CES
Name=Action_VelToVol
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=7ac6155c-28d5-4ced-b6e4-c430826dbf24
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
fbKS_FB_VelocityToVoltage_IfOf(
	i_xEn:= TRUE, 
	i_rVel:= rVel_Cur_Out, 
	i_rVel_Film:= i_rVel_Film, 
	i_xMachineRev:= i_xMachineRev, 
	i_rUsingGirth:= rUsingGirth_Out, 
	i_rGirth:= rActualGirth_In, 
	i_xInchEn:= xInchEn, 
	i_xInchBtn:= xInch, 
	i_xInchDir:= xInchDir, 
	i_iInchVel:= iInchVel, 
	i_iRatedRpm:= iRatedRpm_In, 
	i_iRatedFrq:= iRatedFrq_In, 
	i_iUpperFrq:= iUpperFrq_In, 
	i_uiNum:= uiNum_In, 
	i_uiDen:= uiDen_In, 
	o_xEn=> , 
	o_rVolt=> rAO_Inverter_Out, 
	o_rVolt_Film=> rAO_VelFilm_Out);