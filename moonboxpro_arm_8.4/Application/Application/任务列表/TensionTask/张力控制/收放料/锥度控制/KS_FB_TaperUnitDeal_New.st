(*@CES
Name=KS_FB_TaperUnitDeal_New
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=029751e0-fe3d-4f68-a3f4-ab7fe94fc43b
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_TaperUnitDeal_New(*锥度单位处理*)
(*调整不同单位张力最大值的切换代码执行位置|2022.10.16.105041*)
(*2025.1.15.152035 计算收料停机锥度显示值*)
VAR_INPUT
	i_xEn: BOOL;
	i_rN: REAL;
	i_rMpa: REAL;
	i_pbyInitTaper: POINTER TO BYTE;
	i_prInitTaper_Hmi: POINTER TO REAL;
END_VAR
VAR_OUTPUT
END_VAR
VAR_IN_OUT
	io_xTaperUnitType:BOOL;(*张力单位切换标志|.0 放牵\.1收牵\.2放料\.3收料*)
	io_byTaperUnit: BYTE;
	io_byTaperUnitConfirm : BYTE;
	io_rPercentMatchN: REAL;
	io_rPercentMatchMpa: REAL;
	io_rTaperValueBegin_Hmi: REAL;
	io_rTaperValueEnd_Hmi: REAL;
	io_rTaperValueCur_Hmi: REAL;
	io_rTaper_Begin: REAL;
	io_rTaper_End: REAL;
	io_rTaper_Cur: REAL;
	io_rTaperMax: REAL;
	
END_VAR
VAR
	byLastUnit: BYTE:=3;(*初始化给一个不一样的值|用于触发开机取初值*)
END_VAR
{IMPLEMENTATION}
IF i_xEn THEN;
ELSE
	RETURN;
END_IF

(**处理单位切换标志*)
IF io_xTaperUnitType THEN(*放牵切换*)
	io_byTaperUnit:=io_byTaperUnit+1;
	IF io_byTaperUnit>2 THEN
		io_byTaperUnit:=0;
	END_IF

ELSE;
END_IF
(*清除单位切换按钮*)
io_xTaperUnitType:=FALSE;

KS_CovertUnit_Taper(
	ADR(io_byTaperUnit)(*i_pbyUnit*),
	io_byTaperUnitConfirm.0(*i_xConfirmN*),
	io_byTaperUnitConfirm.1(*i_xConfirmMpa*),
	ADR(io_rPercentMatchN)(*i_prConfirmTaperPercentMatchN*),
	ADR(io_rPercentMatchMpa)(*i_prConfirmTaperPercentMatchMpa*),
	i_rN(*i_rConfirmTaperN*),
	i_rMpa(*i_rConfirmTaperMpa*),
	ADR(io_rTaperValueBegin_Hmi)(*i_prTaperValueBegin_Hmi*),
	ADR(io_rTaperValueEnd_Hmi)(*i_prTaperValueEnd_Hmi*),
	ADR(io_rTaperValueCur_Hmi)(*i_prTaperValueCur_Hmi*),

	ADR(byLastUnit)(*i_pbyLastUnit*),
	ADR(io_rTaper_Begin)(*i_plrTaperPencent_Begin*),
	ADR(io_rTaper_End)(*i_plrTaperPencent_End*),
	io_rTaper_Cur(*i_lrTaperPencent_Cur*),
	(*2025.1.15.153326+*)
	i_pbyInitTaper,
	i_prInitTaper_Hmi);
(*2022.10.16.104937*)
io_rTaperMax:=100;
IF io_byTaperUnit=1 THEN(*放料单位|N*)
	io_rTaperMax:=500;
ELSIF io_byTaperUnit=2 THEN(*放料单位|Mpa*)
	io_rTaperMax:=1;
END_IF
(*清除确认按钮*)
io_byTaperUnitConfirm:=0;

