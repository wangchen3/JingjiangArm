(*@CES
Name=KS_FB_Taper_UwRw_IfOf
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=4508f757-99f8-49ac-966d-1f120aaadfc2
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_Taper_UwRw_IfOf
VAR_INPUT
	i_xEn: BOOL;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	fbKS_FB_TaperUnitDeal: KS_FB_TaperUnitDeal;
	(*锥度变化临时变量|只处理放料 放牵收牵*)
	rMaxTaper:REAL:=100;(*最大锥度|目前使用%*)
	iTimeTaperChange:INT:=10000;(*锥度变化时间|ms*)
	rTaperTar: REAL;
	rTaperCur: REAL;
	rDeltTaper: REAL;
	xInit_Taper_Cur: BOOL;
END_VAR
{IMPLEMENTATION}
IF i_xEn THEN
	(*2021.7.29.094016 张力单位切换控制逻辑|以及标定逻辑*)
	fbKS_FB_TaperUnitDeal(i_pstStGrpParam:=pstStGrpParam );

	(*处理4个锥度|放料、放牵、收料、收牵*)
	(*需要确定是否需要进行单位转换|目前是%*)
	(*使用起始锥度作为界面显示|当前锥度做规划*)
	(*放料*)
	(*由于当前锥度是保持型的|在这里做开机初始复位处理|*)
	IF NOT xInit_Taper_Cur THEN
		xInit_Taper_Cur:=TRUE;
		pstStGrpParam^.lrTaper_Cur_Uw:=0;
		pstStGrpParam^.lrTaper_Cur_If:=0;
		pstStGrpParam^.lrTaper_Cur_Of:=0;
	END_IF

	rTaperTar:=pstStGrpParam^.lrTaper_Begin_Uw;
	rTaperCur:=pstStGrpParam^.lrTaper_Cur_Uw;
	rDeltTaper:=rMaxTaper/iTimeTaperChange*gc_iCycleTime_Plc;
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
	pstStGrpParam^.lrTaper_Cur_Uw:=rTaperCur;
	(*放牵*)
	rTaperTar:=pstStGrpParam^.lrTaper_Begin_If;
	rTaperCur:=pstStGrpParam^.lrTaper_Cur_If;
	rDeltTaper:=rMaxTaper/iTimeTaperChange*gc_iCycleTime_Plc;
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
	pstStGrpParam^.lrTaper_Cur_If:=rTaperCur;
	(*收牵*)
	rTaperTar:=pstStGrpParam^.lrTaper_Begin_Of;
	rTaperCur:=pstStGrpParam^.lrTaper_Cur_Of;
	rDeltTaper:=rMaxTaper/iTimeTaperChange*gc_iCycleTime_Plc;
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
	pstStGrpParam^.lrTaper_Cur_Of:=rTaperCur;
END_IF