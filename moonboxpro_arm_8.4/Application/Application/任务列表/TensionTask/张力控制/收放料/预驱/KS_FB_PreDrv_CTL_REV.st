(*@CES
Name=KS_FB_PreDrv_CTL_REV
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=a6d290c7-282b-4175-9277-4851cd27826e
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_PreDrv_CTL_REV
(*2023.5.16.085144
接料反转的速度单位应该是米每分(m/min)，以前写错为了rpm
修改接口命名-同时修改了界面对应参数显示内容*)
(*2024.04.12.182613 增加了用于计算最大加速度的速度输入*)
(*2024.05.14.190344 优化裁切标志处理*)
VAR_INPUT
	i_xEn: BOOL;
	i_lrVel_Film: LREAL; (*当前料膜速度*)
	i_diTime_Acc_PreDrv: DINT; (*预驱加速时间单位是s*)
	i_iTime_Cycle: INT; (*程序循环时间单位是ms*)
	i_lrVel_Max: LREAL; (*最大速度单位是m/min*)
	i_lrCoef_PreDrv: LREAL; (*预驱系数*)
	i_xoCutter: BOOL;(*裁切完成了*)
	i_xPreRev_Cutted: BOOL;
	i_iPreRevLenth_MM_Cutted:INT;
(*	i_iPreRevVel_RPM_Cutted: INT;		(*接料完成后，预驱反转的的速度*)*)
	i_iPreRevVel_MPM_Cutted: INT;		(*接料完成后，预驱反转的的线速度@m/min|2023.5.16.085141*)
	i_iPre_DecTime: INT;

	(*2021.5.6.150439 预驱后支持启动停止预驱-Liu.yt*)
	i_xBtnPreDrvStartOrStop:BOOL;(*预驱启动停止按钮*)
	i_uiMaxVel_UseCalcAcc:UINT;(*最大速度,用于计算最大加减速@2024.04.12.165352*)
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_xIng_PreDrv: BOOL;(*预驱中-加速..*)
	o_xDone_PreDrv: BOOL;(*预驱完成*)
	o_xPreDrvAxis_Releasing: BOOL; (*2017-08-29 16:30:40| 预驱轴释放中...*)
END_VAR
VAR_IN_OUT
	io_rVel_PreDrv: REAL;(*预驱速度*)
END_VAR
VAR
	lrAccel_PreDrv: LREAL;(*预驱加速度单位是m/min/ms*)
	rTotalLenth_MM_Temp:REAL;
	rPreRevLenth_MM:REAL;
	xPreRev_Cutted: BOOL;
	iPreDecVel_RPM_Tar: INT;
	rPre_DecTime: REAL;
	lrPre_Dec: LREAL;		(*预驱减速度单位是m/Min*)
	rPreRevTotalLenth_MM_Cutted:REAL;

	(*2021.5.6.150750 预驱启动停止按钮控制|*)
	afbRTrig:ARRAY [1..2] OF R_TRIG;
	xIng_PreDrvAcc:BOOL;(*预驱加速中*)
	xIng_PreDrvAccDne:BOOL;(*预驱加速完成*)
	xIng_PreDrvDec:BOOL;(*预驱减速中*)
	xIng_PreDrvDecDne:BOOL;(*预驱减速完成*)
	xCutDne: BOOL;(*裁切完成标志@2024.05.14.190339*)
END_VAR

{IMPLEMENTATION}
(*只处理预驱过程中*)
(*2021.5.6.150737|取按钮沿*)
afbRTrig[1](clk:=i_xBtnPreDrvStartOrStop);
afbRTrig[2](CLK:=i_xEn);(*使能沿触发*)
IF i_xEn THEN
	IF afbRTrig[1].Q THEN
		IF xIng_PreDrvAcc OR xIng_PreDrvAccDne THEN
			xIng_PreDrvDec:=TRUE;
			xIng_PreDrvAcc:=FALSE;
			xIng_PreDrvAccDne:=FALSE;
			xIng_PreDrvDecDne:=FALSE;
		ELSIF xIng_PreDrvDec OR xIng_PreDrvDecDne THEN
			xIng_PreDrvAcc:=TRUE;
			xIng_PreDrvDec:=FALSE;
			xIng_PreDrvAccDne:=FALSE;
			xIng_PreDrvDecDne:=FALSE;
		END_IF
	END_IF
END_IF

(*功能块使能沿*)
IF afbRTrig[2].Q THEN
	xIng_PreDrvAcc:=TRUE;
END_IF

IF NOT i_xEn THEN(*没使能取消标志*)
	xIng_PreDrvAcc:=FALSE;
	xIng_PreDrvDec:=FALSE;
	xIng_PreDrvAccDne:=FALSE;
	xIng_PreDrvDecDne:=FALSE;
END_IF

(*2024.05.14.190258 获取裁切完成信号*)
IF i_xoCutter THEN
	xCutDne:=TRUE;
END_IF


IF i_xEn THEN(*预驱使能*)
	(*预驱加速的最大速度修改为最大速度2021.5.6.170116-Liu.yt*)
	IF i_diTime_Acc_PreDrv <>0 THEN
		lrAccel_PreDrv:=UINT_TO_LREAL(i_uiMaxVel_UseCalcAcc)(*i_lrVel_Max*)/i_diTime_Acc_PreDrv/1000;
	ELSE
		lrAccel_PreDrv:=UINT_TO_LREAL(i_uiMaxVel_UseCalcAcc)(*i_lrVel_Max*)/10/1000;
	END_IF

	IF i_iPre_DecTime<>0 THEN(*计算预驱减加速度*)
		lrPre_Dec:=UINT_TO_LREAL(i_uiMaxVel_UseCalcAcc)(*i_lrVel_Max*)/i_iPre_DecTime/1000;
	ELSE
		lrPre_Dec:=UINT_TO_LREAL(i_uiMaxVel_UseCalcAcc)(*i_lrVel_Max*)/10/1000;
	END_IF

	IF i_lrVel_Film > 0 THEN
		IF xIng_PreDrvAcc THEN(*预驱加速中*)
			IF (i_lrVel_Film*i_lrCoef_PreDrv-io_rVel_PreDrv) > lrAccel_PreDrv*i_iTime_Cycle THEN
				io_rVel_PreDrv:=io_rVel_PreDrv+lrAccel_PreDrv*i_iTime_Cycle;
			ELSE
				io_rVel_PreDrv:=i_lrVel_Film*i_lrCoef_PreDrv;
				xIng_PreDrvAccDne:=TRUE;
				xIng_PreDrvAcc:=FALSE;
			END_IF
		ELSIF xIng_PreDrvDec THEN(*预驱减速中*)
			IF io_rVel_PreDrv>lrPre_Dec*i_iTime_Cycle THEN
				io_rVel_PreDrv:=io_rVel_PreDrv-lrPre_Dec*i_iTime_Cycle;
			ELSE
				io_rVel_PreDrv:=0;
				xIng_PreDrvDecDne:=TRUE;
				xIng_PreDrvDec:=FALSE;
			END_IF
		END_IF

		IF xIng_PreDrvAccDne THEN
			io_rVel_PreDrv:=i_lrVel_Film*i_lrCoef_PreDrv;
		END_IF

		(*保证和以前的意义一致。*)
		o_xIng_PreDrv:=xIng_PreDrvAcc;(*预驱中使用预驱加速标志*)
		o_xDone_PreDrv:=xIng_PreDrvAccDne;(*预驱完成使用加速完成标志|到达了预驱速度了*)

		o_xPreDrvAxis_Releasing:=xIng_PreDrvDec OR xIng_PreDrvDecDne;(*预驱轴减速标志使用预驱减速和减速完成进行输出*)
(*
		IF NOT o_xDone_PreDrv THEN
			IF (i_lrVel_Film*i_lrCoef_PreDrv-io_lrVel_PreDrv) > lrAccel_PreDrv*i_iTime_Cycle THEN
				io_lrVel_PreDrv:=io_lrVel_PreDrv+lrAccel_PreDrv*i_iTime_Cycle;
				o_xIng_PreDrv:=TRUE;
				o_xDone_PreDrv:=FALSE;
			ELSE
				io_lrVel_PreDrv:=i_lrVel_Film*i_lrCoef_PreDrv;
				o_xIng_PreDrv:=FALSE;
				o_xDone_PreDrv:=TRUE;
			END_IF
		ELSE
			io_lrVel_PreDrv:=i_lrVel_Film*i_lrCoef_PreDrv;
		END_IF
*)
	ELSE
		io_rVel_PreDrv:=0;
		o_xIng_PreDrv:=FALSE;
		o_xDone_PreDrv:=FALSE;
		o_xPreDrvAxis_Releasing:=FALSE;
	END_IF
	rTotalLenth_MM_Temp:=0;
	rPreRevLenth_MM:=0;
	xPreRev_Cutted:=FALSE;
ELSIF (o_xIng_PreDrv OR o_xDone_PreDrv ) AND i_lrVel_Film>0 THEN
	IF xCutDne(*i_xoCutter*) AND o_xDone_PreDrv THEN(*2024.05.14.190520 调整*)
		xPreRev_Cutted:=i_xPreRev_Cutted;
	END_IF
	xCutDne:=FALSE;(*2024.05.14.190513+*)
	(*配置预驱减速参数*)
	IF xPreRev_Cutted THEN (*接料后反转,速度输出负值*)
		rPre_DecTime:=INT_TO_REAL(i_iPre_DecTime)/2;
		iPreDecVel_RPM_Tar:=-i_iPreRevVel_MPM_Cutted;
	ELSE
		rPre_DecTime:=INT_TO_REAL(i_iPre_DecTime);
		iPreDecVel_RPM_Tar:=0;
	END_IF
	IF rPre_DecTime<>0 THEN(*计算预驱减加速度*)
		lrPre_Dec:=UINT_TO_LREAL(i_uiMaxVel_UseCalcAcc)(*i_lrVel_Max*)/rPre_DecTime/1000;
	ELSE
		lrPre_Dec:=UINT_TO_LREAL(i_uiMaxVel_UseCalcAcc)(*i_lrVel_Max*)/5/1000;
	END_IF
(*预驱减速规划*)
	IF  io_rVel_PreDrv-lrPre_Dec*i_iTime_Cycle>iPreDecVel_RPM_Tar  THEN
		io_rVel_PreDrv:=io_rVel_PreDrv-lrPre_Dec*i_iTime_Cycle;
		o_xPreDrvAxis_Releasing:=TRUE;
	ELSE
		io_rVel_PreDrv:=iPreDecVel_RPM_Tar;
	END_IF
	(*计算预驱反转需要的总长度，包括输入的值+正转预驱的值*)
	IF io_rVel_PreDrv>0 THEN
		rTotalLenth_MM_Temp:=rTotalLenth_MM_Temp+io_rVel_PreDrv/60*INT_TO_REAL(i_iTime_Cycle);
	END_IF
	rPreRevTotalLenth_MM_Cutted:=i_iPreRevLenth_MM_Cutted+rTotalLenth_MM_Temp;

	IF xPreRev_Cutted AND io_rVel_PreDrv<0 THEN (*预驱反转了，计算固定的料长*)
		rPreRevLenth_MM:=rPreRevLenth_MM+ABS(io_rVel_PreDrv)*INT_TO_REAL(i_iTime_Cycle)/60;(*mm*)
		IF rPreRevTotalLenth_MM_Cutted<rPreRevLenth_MM THEN (*料长走够了 停机,简单点不做减速了*)
			io_rVel_PreDrv:=0;
			o_xDone_PreDrv:=FALSE;
			o_xIng_PreDrv:=FALSE;
			o_xPreDrvAxis_Releasing:=FALSE;
		END_IF
	ELSIF NOT xPreRev_Cutted THEN(*预驱不反转的时候速度停到0 取消标志*)
		IF io_rVel_PreDrv<=0 THEN
			o_xDone_PreDrv:=FALSE;
			o_xIng_PreDrv:=FALSE;
			o_xPreDrvAxis_Releasing:=FALSE;
		END_IF
	END_IF
ELSIF i_lrVel_Film<=0 THEN
	IF o_xDone_PreDrv OR o_xIng_PreDrv THEN
		io_rVel_PreDrv:=0;
	END_IF
	o_xDone_PreDrv:=FALSE;
	o_xIng_PreDrv:=FALSE;
	xPreRev_Cutted:=FALSE;
	o_xPreDrvAxis_Releasing:=FALSE;
END_IF