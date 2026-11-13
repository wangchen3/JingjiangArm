(*@CES
Name=Action_Taper
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=5929bc10-9bab-4944-9bc7-121a1ee90a0f
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
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

(*处理4个锥度|放料、放牵、收料、收牵*)
(*需要确定是否需要进行单位转换|目前是%*)
(*使用起始锥度作为界面显示|当前锥度做规划*)
(*放料*)
(*由于当前锥度是保持型的|在这里做开机初始复位处理|*)
IF NOT xInit_Taper_Cur THEN
	xInit_Taper_Cur:=TRUE;
	rTaper_Cur_In_Out:=0;

END_IF

rTaperTar:= rTaper_Begin_In_Out;
rTaperCur:= rTaper_End_In_Out;
rDeltTaper:=rTaperMax_In_Out/iTimeTaperChange*i_iCycleTime_Plc;
IF rTaperCur<rTaperTar THEN
	rTaperCur:=rTaperCur+rDeltTaper;
	IF rTaperCur>=rTaperTar THEN
		rTaperCur:=rTaperTar;
	END_IF
ELSIF rTaperCur>rTaperTar THEN
	rTaperCur:=rTaperCur-rDeltTaper;
	IF rTaperCur<=rTaperTar THEN
		rTaperCur:=rTaperTar;
	END_IF
ELSE;
END_IF
rTaper_Cur_In_Out:=rTaperCur;