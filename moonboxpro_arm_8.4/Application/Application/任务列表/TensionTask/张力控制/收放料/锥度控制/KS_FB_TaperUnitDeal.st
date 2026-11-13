(*@CES
Name=KS_FB_TaperUnitDeal
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=440da615-589b-45d5-ab61-0644875fc808
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_TaperUnitDeal(*锥度单位处理*)
(*调整不同单位张力最大值的切换代码执行位置|2022.10.16.105041*)
(*2025.1.15.152035 计算收料停机锥度显示值*)
VAR_INPUT
	i_xEn: BOOL;
END_VAR
VAR_OUTPUT
END_VAR
VAR_IN_OUT
	io_byTaperUnitType:BYTE;(*张力单位切换标志|.0 放牵\.1收牵\.2放料\.3收料*)
	io_byTaperUnit_If: BYTE;
	io_byTaperUnit_Of: BYTE;
	io_byTaperUnit_Uw: BYTE;
	io_byTaperUnit_Rw: BYTE;
	io_byTaperUnitConfirm_Uw : BYTE;
	
END_VAR
VAR
	byLastUnit_Uw: BYTE:=3;(*初始化给一个不一样的值|用于触发开机取初值*)
	byLastUnit_Rw: BYTE:=3;(*初始化给一个不一样的值|用于触发开机取初值*)
	byLastUnit_If: BYTE:=3;(*初始化给一个不一样的值|用于触发开机取初值*)
	byLastUnit_Of: BYTE:=3;(*初始化给一个不一样的值|用于触发开机取初值*)
END_VAR
{IMPLEMENTATION}
IF i_xEn THEN;
ELSE
	RETURN;
END_IF

(**处理单位切换标志*)
IF io_byTaperUnitType<>0 THEN
	IF io_byTaperUnitType.0 THEN(*放牵切换*)
		io_byTaperUnit_If:=io_byTaperUnit_If+1;
		IF io_byTaperUnit_If>2 THEN
			io_byTaperUnit_If:=0;
		END_IF
	ELSIF io_byTaperUnitType.1 THEN(*收牵切换*)
		io_byTaperUnit_Of:=io_byTaperUnit_Of+1;
		IF io_byTaperUnit_Of>2 THEN
			io_byTaperUnit_Of:=0;
		END_IF
	ELSIF io_byTaperUnitType.2 THEN(*放料切换*)
		io_byTaperUnit_Uw:=io_byTaperUnit_Uw+1;
		IF io_byTaperUnit_Uw>2 THEN
			io_byTaperUnit_Uw:=0;
		END_IF
	ELSIF io_byTaperUnitType.3 THEN(*收料切换*)
		io_byTaperUnit_Rw:=io_byTaperUnit_Rw+1;
		IF io_byTaperUnit_Rw>2 THEN
			io_byTaperUnit_Rw:=0;
		END_IF
	ELSE;
	END_IF
	(*清除单位切换按钮*)
	io_byTaperUnitType:=0;
END_IF


(*放料处理*)
(*
g_rTaperMax_Uw:=100;
IF io_byTaperUnit_Uw=1 THEN(*放料单位|N*)
	g_rTaperMax_Uw:=500;
ELSIF io_byTaperUnit_Uw=2 THEN(*放料单位|Mpa*)
	g_rTaperMax_Uw:=1;
END_IF
*)
KS_CovertUnit_Taper(
	ADR(io_byTaperUnit_Uw)(*i_pbyUnit*),
	i_pstStGrpParam^.byTaperUnitConfirm_Uw.0(*i_xConfirmN*),
	i_pstStGrpParam^.byTaperUnitConfirm_Uw.1(*i_xConfirmMpa*),
	ADR(i_pstStGrpParam^.rPercentMatchN_Uw)(*i_prConfirmTaperPercentMatchN*),
	ADR(i_pstStGrpParam^.rPercentMatchMpa_Uw)(*i_prConfirmTaperPercentMatchMpa*),
	i_pstStGrpParam^.rN_Uw(*i_rConfirmTaperN*),
	i_pstStGrpParam^.rMpa_Uw(*i_rConfirmTaperMpa*),
	ADR(i_pstStGrpParam^.rTaperValueBegin_Hmi_Uw)(*i_prTaperValueBegin_Hmi*),
	ADR(i_pstStGrpParam^.rTaperValueEnd_Hmi_Uw)(*i_prTaperValueEnd_Hmi*),
	ADR(i_pstStGrpParam^.rTaperValueCur_Hmi_Uw)(*i_prTaperValueCur_Hmi*),

	ADR(byLastUnit_Uw)(*i_pbyLastUnit*),
	ADR(i_pstStGrpParam^.lrTaper_Begin_Uw)(*i_plrTaperPencent_Begin*),
	ADR(i_pstStGrpParam^.lrTaper_End_Uw)(*i_plrTaperPencent_End*),
	i_pstStGrpParam^.lrTaper_Cur_Uw(*i_lrTaperPencent_Cur*),
	(*2025.1.15.153326+*)
	0(*i_pbyInitTaper*),
	0(*i_prInitTaper_Hmi*));
(*2022.10.16.104937*)
g_rTaperMax_Uw:=100;
IF io_byTaperUnit_Uw=1 THEN(*放料单位|N*)
	g_rTaperMax_Uw:=500;
ELSIF io_byTaperUnit_Uw=2 THEN(*放料单位|Mpa*)
	g_rTaperMax_Uw:=1;
END_IF
(*清除确认按钮*)
i_pstStGrpParam^.byTaperUnitConfirm_Uw:=0;


(*收料处理*)
(*
g_rTaperMax_Rw:=100;
IF io_byTaperUnit_Rw=1 THEN(*放料单位|N*)
	g_rTaperMax_Rw:=500;
ELSIF io_byTaperUnit_Rw=2 THEN(*放料单位|Mpa*)
	g_rTaperMax_Rw:=1;
END_IF
*)
KS_CovertUnit_Taper(
	ADR(io_byTaperUnit_Rw)(*i_pbyUnit*),
	i_pstStGrpParam^.byTaperUnitConfirm_Rw.0(*i_xConfirmN*),
	i_pstStGrpParam^.byTaperUnitConfirm_Rw.1(*i_xConfirmMpa*),
	ADR(i_pstStGrpParam^.rPercentMatchN_Rw)(*i_prConfirmTaperPercentMatchN*),
	ADR(i_pstStGrpParam^.rPercentMatchMpa_Rw)(*i_prConfirmTaperPercentMatchMpa*),
	i_pstStGrpParam^.rN_Rw(*i_rConfirmTaperN*),
	i_pstStGrpParam^.rMpa_Rw(*i_rConfirmTaperMpa*),
	ADR(i_pstStGrpParam^.rTaperValueBegin_Hmi_Rw)(*i_prTaperValueBegin_Hmi*),
	ADR(i_pstStGrpParam^.rTaperValueEnd_Hmi_Rw)(*i_prTaperValueEnd_Hmi*),
	ADR(i_pstStGrpParam^.rTaperValueCur_Hmi_Rw)(*i_prTaperValueCur_Hmi*),
	ADR(byLastUnit_Rw)(*i_pbyLastUnit*),
	ADR(i_pstStGrpParam^.lrTaper_Begin_Rw)(*i_plrTaperPencent_Begin*),
	ADR(i_pstStGrpParam^.lrTaper_End_Rw)(*i_plrTaperPencent_End*),
	i_pstStGrpParam^.lrTaper_Cur_Rw(*i_lrTaperPencent_Cur*),
	(*2025.1.15.153326+*)
	ADR(i_pstStGrpParam^.byInitTaper_Rw)(*i_pbyInitTaper*),
	ADR(i_pstStGrpParam^.rInitTaper_Hmi_Rw)(*i_prInitTaper_Hmi*));
(*2022.10.16.104955*)
g_rTaperMax_Rw:=100;
IF io_byTaperUnit_Rw=1 THEN(*放料单位|N*)
	g_rTaperMax_Rw:=500;
ELSIF io_byTaperUnit_Rw=2 THEN(*放料单位|Mpa*)
	g_rTaperMax_Rw:=1;
END_IF
(*清除确认按钮*)
i_pstStGrpParam^.byTaperUnitConfirm_Rw:=0;


(*放牵处理*)
(*
g_rTaperMax_If:=100;
IF io_byTaperUnit_If=1 THEN(*放料单位|N*)
	g_rTaperMax_If:=500;
ELSIF io_byTaperUnit_If=2 THEN(*放料单位|Mpa*)
	g_rTaperMax_If:=1;
END_IF
*)
KS_CovertUnit_Taper(
	ADR(io_byTaperUnit_If)(*i_pbyUnit*),
	i_pstStGrpParam^.byTaperUnitConfirm_If.0(*i_xConfirmN*),
	i_pstStGrpParam^.byTaperUnitConfirm_If.1(*i_xConfirmMpa*),
	ADR(i_pstStGrpParam^.rPercentMatchN_If)(*i_prConfirmTaperPercentMatchN*),
	ADR(i_pstStGrpParam^.rPercentMatchMpa_If)(*i_prConfirmTaperPercentMatchMpa*),
	i_pstStGrpParam^.rN_If(*i_rConfirmTaperN*),
	i_pstStGrpParam^.rMpa_If(*i_rConfirmTaperMpa*),
	ADR(i_pstStGrpParam^.rTaperValueBegin_Hmi_If)(*i_prTaperValueBegin_Hmi*),
	ADR(i_pstStGrpParam^.rTaperValueEnd_Hmi_If)(*i_prTaperValueEnd_Hmi*),
	ADR(i_pstStGrpParam^.rTaperValueCur_Hmi_If)(*i_prTaperValueCur_Hmi*),
	ADR(byLastUnit_If)(*i_pbyLastUnit*),
	ADR(i_pstStGrpParam^.lrTaper_Begin_If)(*i_plrTaperPencent_Begin*),
	ADR(i_pstStGrpParam^.lrTaper_End_If)(*i_plrTaperPencent_End*),
	i_pstStGrpParam^.lrTaper_Cur_If(*i_lrTaperPencent_Cur*),
	(*2025.1.15.153326+*)
	0(*i_pbyInitTaper*),
	0(*i_prInitTaper_Hmi*));
(*2022.10.16.105013*)
g_rTaperMax_If:=100;
IF io_byTaperUnit_If=1 THEN(*放料单位|N*)
	g_rTaperMax_If:=500;
ELSIF io_byTaperUnit_If=2 THEN(*放料单位|Mpa*)
	g_rTaperMax_If:=1;
END_IF
(*清除确认按钮*)
i_pstStGrpParam^.byTaperUnitConfirm_If:=0;


(*收牵处理*)
(*
g_rTaperMax_of:=100;
IF io_byTaperUnit_Of=1 THEN(*放料单位|N*)
	g_rTaperMax_of:=500;
ELSIF io_byTaperUnit_Of=2 THEN(*放料单位|Mpa*)
	g_rTaperMax_of:=1;
END_IF
*)
KS_CovertUnit_Taper(
	ADR(io_byTaperUnit_Of)(*i_pbyUnit*),
	i_pstStGrpParam^.byTaperUnitConfirm_Of.0(*i_xConfirmN*),
	i_pstStGrpParam^.byTaperUnitConfirm_Of.1(*i_xConfirmMpa*),
	ADR(i_pstStGrpParam^.rPercentMatchN_Of)(*i_prConfirmTaperPercentMatchN*),
	ADR(i_pstStGrpParam^.rPercentMatchMpa_Of)(*i_prConfirmTaperPercentMatchMpa*),
	i_pstStGrpParam^.rN_Of(*i_rConfirmTaperN*),
	i_pstStGrpParam^.rMpa_Of(*i_rConfirmTaperMpa*),
	ADR(i_pstStGrpParam^.rTaperValueBegin_Hmi_Of)(*i_prTaperValueBegin_Hmi*),
	ADR(i_pstStGrpParam^.rTaperValueEnd_Hmi_Of)(*i_prTaperValueEnd_Hmi*),
	ADR(i_pstStGrpParam^.rTaperValueCur_Hmi_Of)(*i_prTaperValueCur_Hmi*),
	ADR(byLastUnit_Of)(*i_pbyLastUnit*),
	ADR(i_pstStGrpParam^.lrTaper_Begin_Of)(*i_plrTaperPencent_Begin*),
	ADR(i_pstStGrpParam^.lrTaper_End_Of)(*i_plrTaperPencent_End*),
	i_pstStGrpParam^.lrTaper_Cur_Of(*i_lrTaperPencent_Cur*),
	(*2025.1.15.153326+*)
	0(*i_pbyInitTaper*),
	0(*i_prInitTaper_Hmi*));
(*2022.10.16.105028*)
g_rTaperMax_of:=100;
IF io_byTaperUnit_Of=1 THEN(*放料单位|N*)
	g_rTaperMax_of:=500;
ELSIF io_byTaperUnit_Of=2 THEN(*放料单位|Mpa*)
	g_rTaperMax_of:=1;
END_IF
(*清除确认按钮*)
i_pstStGrpParam^.byTaperUnitConfirm_Of:=0;