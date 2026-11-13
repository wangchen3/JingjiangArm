(*@CES
Name=Action_Taper
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=054e6dfa-cc91-4642-883a-6bb1f59127a3
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}

(*2019.4.11.180111  将锥度写入功能块中by liu.yt*)
fbKS_FB_Taper(
	i_iGrpId:= i_iGrpId, 
	i_xTaperCurCTLEn:= i_xFlag_Print AND (xFlag_RollerPressAtLeast1_In OR xRollerSts_IfOf_In), 
	i_xTaperAdd:= i_pstStEvtReq^.xReq_Taper_Incr, 
	i_xTaperDec:= i_pstStEvtReq^.xReq_Taper_Decr, 
	i_rTaperMax:= rTaperMax_In_Out, 
	i_rTaperValue_Stop:= BYTE_TO_REAL(byInitTaper_In), 
	i_byTaperAdjMode:= byTaperAdjMode_In, 
	i_rDiamCurAxis:= io_rDiamCurAxis, 
	i_rTaper_Begin_Rw:= rTaper_Begin_In_Out, 
	i_rTaper_End_Rw:= rTaper_End_In_Out, 
	i_rDiamTaper_Begin_Rw:= rDiamTaper_Begin_Rw_In, 
	i_rDiamTaper_End_Rw:= rDiamTaper_End_Rw_In, 
	o_rTaper_Cur=> rTaper_Cur_In_Out, 
	iO_byTaperUnit:= byTaperUnit_In_Out, 
	io_rTaperValueBegin_Hmi:= rTaperValueBegin_Hmi_In_Out, 
	io_rTaperValueEnd_Hmi:= rTaperValueEnd_Hmi_In_Out, 
	io_astTaperPoint:= astTaperPoint_In
);



(*2021.10.23.154136*)
//fbKS_FB_Taper_UwRw_IfOf(i_pstStGrpParam:= pstStGrpParam);

(*2021.7.29.094016 张力单位切换控制逻辑|以及标定逻辑*)
fbKS_FB_TaperUnitDeal(
	i_xEn:= TRUE, 
	i_rN:= rN_In, 
	i_rMpa:= rMpa_In, 
	i_pbyInitTaper:= ADR(byInitTaper_In_Out),(*: POINTER TO BYTE;*)
	i_prInitTaper_Hmi:= ADR(rInitTaper_Hmi_In_Out),(*: POINTER TO REAL;*)
	io_xTaperUnitType:= xTaperUnitType_In_Out, 
	io_byTaperUnit:= byTaperUnit_In_Out, 
	io_byTaperUnitConfirm:= byTaperUnitConfirm_In_Out, 
	io_rPercentMatchN:= rPercentMatchN_In_Out, 
	io_rPercentMatchMpa:= rPercentMatchMpa_In_Out, 
	io_rTaperValueBegin_Hmi:= rTaperValueBegin_Hmi_In_Out, 
	io_rTaperValueEnd_Hmi:= rTaperValueEnd_Hmi_In_Out, 
	io_rTaperValueCur_Hmi:= rTaperValueCur_Hmi_In_Out, 
	io_rTaper_Begin:= rTaper_Begin_In_Out, 
	io_rTaper_End:= rTaper_End_In_Out, 
	io_rTaper_Cur:= rTaper_Cur_In_Out, 
	io_rTaperMax:= rTaperMax_In_Out
);
