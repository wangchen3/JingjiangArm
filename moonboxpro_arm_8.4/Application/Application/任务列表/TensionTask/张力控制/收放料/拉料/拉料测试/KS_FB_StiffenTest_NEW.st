(*@CES
Name=KS_FB_StiffenTest_NEW
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=fda8fbd7-0a6c-4f2d-8463-9715153d8e4b
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_StiffenTest_NEW
(*2026.3.11 小卷标定测试区间周期数，大卷验证-PID各项按比率乘系数*)
VAR_INPUT
	i_xEn: BOOL;(*使能标志|*)
	i_xDebugMode:BOOL;(*调试模式*)
	i_lrAI_Uw: LREAL;(*放料电位器输入|*)
	i_lrAI_Rw: LREAL;(*收料电位器输入|*)
	i_lrAI_If:LREAL;(*放牵模拟量输入*)
	i_lrAI_Of:LREAL;(*收牵模拟量输入*)
	
	i_xRollerSts_If:BOOL;(**牵引压辊状态*)
	i_xRollerSts_Of:BOOL;(**牵引压辊状态*)
	i_xMachineRev: BOOL;(*反向走料*)
	i_lrThreshold_Stiffen: LREAL := 0.5;(*拉料进入稳定状态的阀值|*)
//	i_prVel_Uw: POINTER TO REAL := 0;(*放料速度值的地址|*)
	
	i_iCycleTime_Plc: INT;  (*PLC执行时间*)
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;(*返回i_xEn的值|*)
	o_iErNo: INT;(*0无错误\<0有错误发生|*)
	o_xStiffenDone: BOOL;(*拉料完成标志|*)
	o_xZeroServo_Uw: BOOL;(*放料零伺服|*)
	o_xForeward_Uw: BOOL;(*放料使能\正转|*)
	o_xZeroServo_Rw: BOOL;(*收料零伺服|*)
	o_xForeward_Rw: BOOL;(*收料使能\正转|*)
	
	o_lrAIMax_Uw:LREAL;
	o_lrAIMin_Uw: LREAL;(*放料模拟量最小值*)
	o_lrAIMax_Rw: LREAL;
	o_lrAIMin_Rw: LREAL;
	o_lrAIMin_If: LREAL;
	o_lrAIMax_If: LREAL;
	o_lrAIMin_Of: LREAL;
	o_lrAIMax_Of: LREAL;

	o_lrUwShaftSpeed_RPM:LREAL; (* 输出给放料轴的转速 *)
	o_lrRwShaftSpeed_RPM:LREAL; (* 输出给收料轴的转速 *)

END_VAR
VAR
	xFlagDone_Uw: BOOL;
	xFlagDone_Rw: BOOL;
	
	xLastEn      : BOOL;          // 记录上一个周期的使能状态，用于检测上升沿
	xRunning      : BOOL;    // 当前是否正在运行 PID
    xLastRunning  : BOOL;  // 上一周期的运行状态 (用于检测上升沿)
	lrTs          : LREAL ;
	   
     (* pid-要用中卷坐标定*)
    lrKp_Base_Uw: LREAL := 2.0;  //比例系数
    lrTi_Base_Uw: LREAL := 2.0;  //积分时间（s），越大积分越慢
    lrTv_Base_Uw: LREAL := 0.15;  //微分时间（s），越小微分越弱
	
	lrKp_Base_Rw: LREAL := 2;  //比例系数
    lrTi_Base_Rw: LREAL := 3.0;  //积分时间（s），越大积分越慢
    lrTv_Base_Rw: LREAL := 0.1;  //微分时间（s），越小微分越弱
	(*放料*)
	lrKpReal_Uw: LREAL;  //实时比例系数
    lrTiReal_Uw: LREAL;  //实时积分时间
    lrTvReal_Uw: LREAL;  //实时微分时间
	(*收料*)
    lrKpReal_Rw: LREAL;  //实时比例系数
    lrTiReal_Rw: LREAL;  //实时积分时间
    lrTvReal_Rw: LREAL;  //实时微分时间
	
    lrErr_UW      : LREAL;      // 当前偏差
	lrErr_RW      : LREAL;      // 获取当前误差
    lrErrLast_Uw    : LREAL;      // 放料上次偏差
	lrErrLast_Rw    : LREAL;      // 收料上次偏差
    lrIntegral_UW ,lrIntegral_RW: LREAL;      // 积分累加
    lrDRaw_Uw ,lrDRaw_Rw : LREAL;      // 原始微分项

	lrP_Component_Uw, lrI_Component_Uw, lrD_Component_Uw : LREAL;
    lrP_Component_Rw, lrI_Component_Rw, lrD_Component_Rw : LREAL;
    lrTotalOut_Uw, lrTotalOut_Rw : LREAL;
	
	lrVel_limit : LREAL := 45.0; (*限制基准速度*)
    lrRampTime  : LREAL := 0.5;  // 设定的加速时间 0.5秒
	
	lrAIMin_Uw98,lrAIMin_Rw98 : LREAL;
	lrAIMin_Uw75,lrAIMin_Rw75 : LREAL;
	iMeasure_Timer_Uw,iMeasure_Timer_Rw : REAL;
	xMeasure_Done_Uw,xMeasure_Done_Rw : BOOL;   (*自适应比率计算完成*)
    rAdaptiveRatio_Uw,rAdaptiveRatio_Rw :LREAL;  (*自适应比率*)
	
	lrT_Base : LREAL := 35.0;  (*中卷标定的基准周期*)
	lrRatio_Min: LREAL := 0.2;(*最小自适应比率（大卷下限）*)
    lrRatio_Max: LREAL := 5.0;(*最大自适应比率（小卷上限）*)
	
	fb_SpeedRamp_Uw : KS_FB_SpeedRamp;  (*斜坡速度*)
	fb_SpeedRamp_Rw : KS_FB_SpeedRamp;  (*斜坡速度*)
END_VAR

{IMPLEMENTATION}
(* 初始化与故障检测 *)
o_xEno := i_xEn;
o_iErNo := 0;
lrTs :=INT_TO_REAL(i_iCycleTime_Plc) / 1000.0;(*PLC周期0.02s*)

xRunning:=i_xEn;

IF xRunning AND NOT xLastRunning THEN
	lrErr_UW       := i_lrAI_Uw;  // 获取当前误差
	lrErr_RW       := i_lrAI_Rw;  // 获取当前误差
	lrIntegral_UW  := 0.0;        // 清空积分
	lrTotalOut_Uw    := 0.0;
	lrIntegral_RW  := 0.0;        // 清空积分
	lrTotalOut_Rw    := 0.0;
	
	 (*放料*)
    lrKpReal_Uw := lrKp_Base_Uw;
    lrTiReal_Uw := lrTi_Base_Uw;
    lrTvReal_Uw := lrTv_Base_Uw;
    iMeasure_Timer_Uw := 0;
    xMeasure_Done_Uw := FALSE;
    rAdaptiveRatio_Uw := 1.0;     // 默认 1.0 
	
	(*收料*)
	lrKpReal_Rw := lrKp_Base_Rw;
    lrTiReal_Rw := lrTi_Base_Rw;
    lrTvReal_Rw := lrTv_Base_Rw;
	iMeasure_Timer_Rw := 0;
    xMeasure_Done_Rw := FALSE;
    rAdaptiveRatio_Rw := 1.0;     // 默认 1.0 
	
	// 状态标志复位
    xFlagDone_Uw := FALSE;
    xFlagDone_Rw := FALSE;
    o_xStiffenDone := FALSE;
    o_xZeroServo_Uw := FALSE;
    o_xZeroServo_Rw := FALSE;
END_IF

IF xRunning THEN//开始张力投入，pid控制开始
	
    lrErr_UW := i_lrAI_Uw;  
	lrErr_RW := i_lrAI_Rw; 
	
		(*----------------放料侧-pid计算----------------------*)
   
	lrAIMin_Uw98 := o_lrAIMin_Uw * 0.98;
    lrAIMin_Uw75 := o_lrAIMin_Uw * 0.75;
    // 自适应比率测量模块 (-8V 到 -6V 测速)
    IF NOT xMeasure_Done_Uw THEN
        IF (i_lrAI_Uw >= lrAIMin_Uw98) AND (i_lrAI_Uw <= lrAIMin_Uw75) THEN
            iMeasure_Timer_Uw := iMeasure_Timer_Uw + 1;      // 进入测量区间计次
        END_IF
        
        IF (i_lrAI_Uw > lrAIMin_Uw75) THEN           // 测量结束 (电压超过 -6.0)
            IF iMeasure_Timer_Uw > 0 THEN        //实测时间越长，说明越慢，需要越大的倍数来加速
                rAdaptiveRatio_Uw := (iMeasure_Timer_Uw / lrT_Base);     // 实测周期 / 基准周期(10)-小卷用了50周期。Ratio = 50 / 10 = 5.0 (放大5倍)
            ELSE
                rAdaptiveRatio_Uw :=1.0;  
            END_IF
            
            // 安全限幅
            IF rAdaptiveRatio_Uw < lrRatio_Min THEN 
				rAdaptiveRatio_Uw := lrRatio_Min;
			END_IF;
            IF rAdaptiveRatio_Uw > lrRatio_Max THEN 
				rAdaptiveRatio_Uw := lrRatio_Max ; 
			END_IF;
            xMeasure_Done_Uw := TRUE;
		
					(*放料 ——pid参数自适应g*)
            lrKpReal_Uw := lrKp_Base_Uw * rAdaptiveRatio_Uw;(*比例：卷大→Kp小*)
            lrTiReal_Uw := lrTi_Base_Uw / rAdaptiveRatio_Uw;(*积分：卷大→Ti长→积分慢（防饱和）*)
            lrTvReal_Uw := lrTv_Base_Uw * rAdaptiveRatio_Uw;(*微分：卷大→Td小→微分弱（防抖振）*)
			
        END_IF
    END_IF
	
	// P 比例项
	lrP_Component_Uw := lrKpReal_Uw * lrErr_UW;
	
	IF ABS(lrErr_UW) > 2.0 THEN
    //  离得太远：强制把积分清零，不要攒任何旧账！
		lrIntegral_UW := 0.0; 
	ELSE
	//  离得近了：允许积分项开始工作
		IF lrTiReal_Uw > 0 THEN
			lrIntegral_UW :=  lrIntegral_UW + (lrKpReal_Uw * (lrTs / lrTiReal_Uw) * lrErr_UW);
		END_IF
	END_IF
	lrI_Component_Uw := lrIntegral_UW;
	
	//  D 微分项 
	IF lrTs > 0 THEN
		lrDRaw_Uw := lrKpReal_Uw * lrTvReal_Uw * (lrErr_UW - lrErrLast_Uw) / lrTs;
	END_IF
	lrD_Component_Uw := lrDRaw_Uw;
	
	lrTotalOut_Uw := lrP_Component_Uw + lrI_Component_Uw + lrD_Component_Uw;  // PID 总输出 
	
	
	(*----------------------收料侧-pid计算----------------------------------*)
	lrAIMin_Rw98 := o_lrAIMin_Rw * 0.98;
    lrAIMin_Rw75 := o_lrAIMin_Rw * 0.75;
	
	    // 自适应比率测量模块 (-8V 到 -6V 测速)
    IF NOT xMeasure_Done_Rw THEN
        IF (i_lrAI_Rw >= lrAIMin_Rw98) AND (i_lrAI_Rw <= lrAIMin_Rw75) THEN
            iMeasure_Timer_Rw := iMeasure_Timer_Rw + 1;      // 进入测量区间计次
        END_IF
        
        IF (i_lrAI_Rw > lrAIMin_Rw75) THEN           // 测量结束 (电压超过 -6.0)
            IF iMeasure_Timer_Rw > 0 THEN        //实测时间越长，说明越慢，需要越大的倍数来加速
                rAdaptiveRatio_Rw := (iMeasure_Timer_Rw / lrT_Base);     // 实测周期 / 基准周期(10)-小卷用了50周期。Ratio = 50 / 10 = 5.0 (放大5倍)
            ELSE
                rAdaptiveRatio_Rw :=1.0;  
            END_IF
            
            // 安全限幅
            IF rAdaptiveRatio_Rw < lrRatio_Min THEN 
				rAdaptiveRatio_Rw := lrRatio_Min;
			END_IF;
            IF rAdaptiveRatio_Rw > lrRatio_Max THEN 
				rAdaptiveRatio_Rw := lrRatio_Max ; 
			END_IF;
            xMeasure_Done_Rw := TRUE;
		
			lrKpReal_Rw := lrKp_Base_Rw * rAdaptiveRatio_Rw;(*比例：卷大→Kp小*)
            lrTiReal_Rw := lrTi_Base_Rw / rAdaptiveRatio_Rw;(*积分：卷大→Ti长→积分慢（防饱和）*)
            lrTvReal_Rw := lrTv_Base_Rw * rAdaptiveRatio_Rw;(*微分：卷大→Td小→微分弱（防抖振）*)
			
        END_IF
    END_IF
	
	// P 比例项
	lrP_Component_Rw := lrKpReal_Rw * lrErr_RW;
	

	// 修改后的收料积分逻辑
	IF ABS(lrErr_RW) > 2.0 THEN
		// 误差大时，彻底清空积分，防止带病进入死区
		lrIntegral_RW := 0.0;
	ELSE
		IF lrTiReal_Rw > 0 THEN
			lrIntegral_RW := lrIntegral_RW + (lrKpReal_Rw * (lrTs / lrTiReal_Rw) * lrErr_RW);
		END_IF
	END_IF
	lrI_Component_Rw := lrIntegral_RW;

	
	//  D 微分项 
	IF lrTs > 0 THEN
		lrDRaw_Rw := lrKpReal_Rw * lrTvReal_Rw * (lrErr_RW - lrErrLast_Rw) / lrTs;
	END_IF
	lrD_Component_Rw := lrDRaw_Rw;
	
	lrTotalOut_Rw := -(lrP_Component_Rw + lrI_Component_Rw + lrD_Component_Rw);  // PID 总输出 
    
  // 更新历史误差
	lrErrLast_Uw := lrErr_UW;
	lrErrLast_Rw := lrErr_RW;
	
 // 运行期间的其他使能
   o_xForeward_Uw := TRUE; 
   o_xForeward_Rw := TRUE; 
	
	(*-----------------摆臂到达中位逻辑判断-----------------*)
	//放料
	IF ABS(i_lrAI_Uw)<= i_lrThreshold_Stiffen THEN
		xFlagDone_Uw := TRUE;
	ELSIF ABS(i_lrAI_Uw)> (i_lrThreshold_Stiffen +1.0) THEN 
		xFlagDone_Uw := FALSE;
	END_IF

	(*放料零伺服转换*)
	IF xFlagDone_Uw THEN
		IF  ABS(i_lrAI_Uw) < (i_lrThreshold_Stiffen + 0.5) THEN
			o_xZeroServo_Uw:=TRUE;
		END_IF;
	ELSE
		IF ABS(i_lrAI_Uw) > (i_lrThreshold_Stiffen + 1.0) THEN
			o_xZeroServo_Uw:=FALSE;
		END_IF;
	END_IF
	
	//收料
	IF ABS(i_lrAI_Rw)<= i_lrThreshold_Stiffen THEN
		xFlagDone_Rw := TRUE;
	ELSIF ABS(i_lrAI_Rw)> (i_lrThreshold_Stiffen+1.0) THEN 
		xFlagDone_Rw := FALSE;
	END_IF
	
	(*收料零伺服转换*)
	IF xFlagDone_Rw THEN
		IF  ABS(i_lrAI_Uw) < (i_lrThreshold_Stiffen + 0.5)  THEN
			o_xZeroServo_Rw:=TRUE;
		END_IF;
	ELSE
		IF ABS(i_lrAI_Rw) > (i_lrThreshold_Stiffen + 1.0) THEN
			o_xZeroServo_Rw:=FALSE;
		END_IF;
	END_IF
	
	// 只有在双摆臂都进入中位阈值内，才判定拉料完成
    IF o_xZeroServo_Uw AND o_xZeroServo_Rw THEN
        o_xStiffenDone := TRUE;
    ELSE
        o_xStiffenDone := FALSE;
    END_IF
	
   
ELSE
    // 只有当速度真正归零后，才清空PID数据，等待下次启动
    IF o_lrUwShaftSpeed_RPM = 0.0 AND  o_lrRwShaftSpeed_RPM = 0.0 THEN
		lrP_Component_Uw :=0.0;
		lrI_Component_Uw :=0.0;
		lrD_Component_Uw :=0.0;
 		lrP_Component_Rw:=0.0;
		lrI_Component_Rw:=0.0;
		lrD_Component_Rw:=0.0;
		
        lrIntegral_UW := 0;
        lrErrLast_Uw    := 0;
        lrTotalOut_Uw  := 0;      
        o_xForeward_Uw := FALSE; 
		iMeasure_Timer_Uw := 0;
        xMeasure_Done_Uw := FALSE;
        rAdaptiveRatio_Uw := 1.0;
		
		
		lrIntegral_RW := 0;
        lrErrLast_Rw    := 0;
        lrTotalOut_Rw  := 0;      
        o_xForeward_Rw := FALSE; 
		iMeasure_Timer_Rw := 0;
        xMeasure_Done_Rw := FALSE;
        rAdaptiveRatio_Rw := 1.0;
		o_xStiffenDone := FALSE;
    END_IF
    
END_IF

 // 斜坡停机（提前调用，确保速度值为当前周期最新）
fb_SpeedRamp_Uw(
 i_lrTarget   := SEL(xRunning AND NOT xFlagDone_Uw , 0.0, lrTotalOut_Uw), // 如果到位(xFlagDone_Uw=TRUE)，目标速度给0，靠PID死区或零伺服稳住
 i_lrRampTime := lrRampTime,         // 设定的斜坡时间
 i_lrVelLimit := lrVel_limit,          // 基准速度限制
 i_lrTs       := lrTs,                 // 周期时间
 o_lrCurrentVel => o_lrUwShaftSpeed_RPM   // 当前速度变量（更新为当前周期最新值）
);

fb_SpeedRamp_Rw(
 i_lrTarget   := SEL(xRunning AND NOT xFlagDone_Rw , 0.0, lrTotalOut_Rw),     
 i_lrRampTime := lrRampTime,         // 设定的斜坡时间
 i_lrVelLimit := lrVel_limit,          // 基准速度限制
 i_lrTs       := lrTs,                 // 周期时间
 o_lrCurrentVel => o_lrRwShaftSpeed_RPM    // 当前速度变量（更新为当前周期最新值）
);

KS_GetMax_MinVlaue(ADR(o_lrAIMax_Uw), ADR(o_lrAIMin_Uw),i_lrAI_Uw );
KS_GetMax_MinVlaue(ADR(o_lrAIMax_Rw), ADR(o_lrAIMin_Rw),i_lrAI_Rw );
    
// 更新状态供下个周期检测上升沿
xLastRunning := xRunning;
o_xEno:=i_xEn;

g_lrP_Component_Uw:=lrP_Component_Uw;
g_lrI_Component_Uw:=lrI_Component_Uw;
g_lrD_Component_Uw:=lrDRaw_Uw;

g_lrP_Component_Rw:=lrP_Component_Rw;
g_lrI_Component_Rw:=lrI_Component_Rw;
g_lrD_Component_Rw:=lrDRaw_Rw;