(*@CES
Name=KS_FB_WindLengthDeal
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=8419287e-18db-4bbd-b007-6d98fe5ae6c0
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_WindLengthDeal(*收料印刷长度计算*)
VAR_INPUT
	i_xEn									:BOOL;
	i_pxCalcLenWayChange					:POINTER TO BOOL;(*计米方式切换标志*)
	i_piCoeff_Lenth							:POINTER TO INT;(*速度计米时长度系数|单位%*)
	i_pxAxisAClr							:POINTER TO BOOL;(*轴A清零*)
	i_pxAxisBClr							:POINTER TO BOOL;(*轴B清零*)
	i_pxTotalClr							:POINTER TO BOOL;(*总长清零*)

	i_iGrpAxisNum_Pu						: INT;(*色组轴数量|*)
	i_aiGrpAxisList							: ARRAY [1..MAX_UNIT_NUM] OF INT;(*轴列表|有排序规则|*)
	i_xCurAxis_A							: BOOL;(*当前轴*)
	i_rVel_Film								: REAL;(*料膜速度*)
	i_xFlag_Print							: BOOL;(*印刷标志*)
	i_xFlag_RollerPressAtLeast1				: BOOL;(*至少合压一色*)
	i_lrPrf_Pos_FirstAxis					: LREAL;(*版规划位置*)
	i_uiNum_FirstAxis						: UINT;(*减速比*)
	i_uiDen_FirstAxis						: UINT;(**)
	i_rGirth_FirstAxis						: REAL;(*版周长*)
	i_iCycleTime_Plc						: INT;(*程序执行3周期*)
	i_xIsDebugMode							: BOOL;(*调试模式*)
	i_xMachineRev							: BOOL;	
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;
END_VAR
VAR
	xPreCurrentAxis: BOOL;
	xGetInitPos: BOOL;(*获得初始pt位置标志*)
	iN: INT;
	iGetPosAxisId: INT;
	lrInitPos: LREAL;
	lrDelPos: LREAL;
	lrInitPos_Axis: LREAL;(*轴的初始位置|pt叠加的初始值*)
	lrStartLenth_Axis: LREAL;(*轴的开始位置|计长清零或者使能后的*)

	lrStartLenth_Total: LREAL;(*总的开始位置|计长清零或者使能后的*)
	lrInitPos_Total: LREAL;(*pt叠加的初始值*)
	lrCoeff_Lenth: LREAL;
	iAxisId: INT;
	lrDelPrintLenth: LREAL;(*总走料值的变化量*)
	lrTotal_LengthBak: LREAL;(*上个周期总料长*)
	lrAxisPrf_Pos: LREAL;
	lrPrevPrf_Pos_FirstAxis:LREAL;
	
END_VAR
VAR_IN_OUT
	io_lrAxisALength: LREAL;	(* A轴印刷长度 *)
	io_lrAxisBLength: LREAL;	(* B轴印刷长度 *)
	io_lrTotal_Length:LREAL;	(*印刷总长度*)
	io_lrPrintLength: LREAL;
	(*2025.8.22.204530*)
	io_byPrintLength_CalcCtl: BYTE;(*计米方式*)
END_VAR


{IMPLEMENTATION}
IF i_pxCalcLenWayChange<>0 THEN(*计米方式切换*)
	IF i_pxCalcLenWayChange^ THEN
		i_pxCalcLenWayChange^:=FALSE;
		io_byPrintLength_CalcCtl:=
			3-io_byPrintLength_CalcCtl;
		IF io_byPrintLength_CalcCtl=1 OR
			io_byPrintLength_CalcCtl=2 THEN;
		ELSE
			io_byPrintLength_CalcCtl:=1;(*增加了出错处理*)
		END_IF
	END_IF
END_IF


	(*没有色组就不计米*)
IF i_iGrpAxisNum_Pu>0 THEN
	(*2020.7.31.141914 计米只有一种方式|啥都不要了！*)
	io_byPrintLength_CalcCtl:=1;
		(*计长清零*)
	IF i_pxAxisAClr<>0 AND
		i_pxAxisBClr<>0 AND
		i_pxTotalClr<>0 THEN
		(*A轴清零*)
		IF i_pxAxisAClr^ THEN
			i_pxAxisAClr^:=FALSE;
			io_lrAxisALength:=0;
			IF i_xCurAxis_A THEN(*当前轴为A轴*)
				lrStartLenth_Axis:=0;
				lrInitPos_Axis:=lrDelPos;
			END_IF
		END_IF
	
		(*b轴清零*)
		IF i_pxAxisBClr^ THEN
			i_pxAxisBClr^:=FALSE;
			io_lrAxisBLength:=0;
			IF NOT i_xCurAxis_A THEN(*当前轴为B轴*)
				lrStartLenth_Axis:=0;
				lrInitPos_Axis:=lrDelPos;
			END_IF
		END_IF
	
		(*总长清零*)
		IF i_pxTotalClr^ THEN
			i_pxTotalClr^:=FALSE;
			io_lrTotal_Length:=0;
			lrStartLenth_Total:=0;
			lrInitPos_Total:=lrDelPos;
			lrTotal_LengthBak:=io_lrTotal_Length;
		END_IF
	END_IF
	IF i_piCoeff_Lenth<>0 THEN
		lrCoeff_Lenth:=INT_TO_LREAL(i_piCoeff_Lenth^);

		IF lrCoeff_Lenth<=0 THEN
			lrCoeff_Lenth:=100.0;
			i_piCoeff_Lenth^:=100;
		END_IF
	ELSE
		lrCoeff_Lenth:=100.0;
	END_IF

	lrCoeff_Lenth:=lrCoeff_Lenth/100;

	IF i_xFlag_Print AND i_xFlag_RollerPressAtLeast1 THEN(*可以计算印刷长度*)
		IF io_byPrintLength_CalcCtl=1 THEN(**规划位置*)
			
			(*因为我们需要读取规划位置  我们保证到达写入pt步再进行位子读取*)
			(**2025.8.22.210200先用料膜速度判断吧
			IF (i_pstStGrpParam^.iMotionStepId=MOTION_STEP_WritePT(*写PT|*)OR
				i_pstStGrpParam^.iMotionStepId=MOTION_STEP_WillLeaveWritePT(*离开PT|*)) THEN*)
			IF i_rVel_Film>5 THEN
				(*计算位置变化*)
				//返回的规划位置是32bit无符号数据,自然溢出.计算的时候统一使用DWORD运算
				//修改数据类型时需要调整这段代码 by liu.yt
				lrDelPos:=0;
				IF NOT xGetInitPos THEN
					lrInitPos:= i_lrPrf_Pos_FirstAxis;
					//2025.9.16.190421+ liu.yt
					lrAxisPrf_Pos := i_lrPrf_Pos_FirstAxis;//获取轴的初始规划位置@累计值 by liu.yt
					lrPrevPrf_Pos_FirstAxis:=i_lrPrf_Pos_FirstAxis;//初始化备份值@ by liu.yt
				END_IF
				//2025.9.16.190309+  by liu.yt
				lrAxisPrf_Pos:=lrAxisPrf_Pos + DWORD_TO_DINT(LREAL_TO_DWORD(i_lrPrf_Pos_FirstAxis) - LREAL_TO_DWORD(lrPrevPrf_Pos_FirstAxis));//@ by  liu.yt

				lrPrevPrf_Pos_FirstAxis:=i_lrPrf_Pos_FirstAxis;//用于计算增量@ by  liu.yt
				//end
				
				//lrDelPos:= i_lrPrf_Pos_FirstAxis-lrInitPos;
				lrDelPos:= lrAxisPrf_Pos-lrInitPos;//2025.9.16.190502 + by liu.yt
				
				(*单位转换|取正值*)
				lrDelPos:=ABS(lrDelPos)/GC_LRMOTORPPR/i_uiNum_FirstAxis
							*i_uiDen_FirstAxis
							*i_rGirth_FirstAxis/1000;
						(*2020.5.25.115145 修复单位错误mm-->m*)
	
				IF  i_xCurAxis_A THEN			(*收卷当前A轴*)
					IF NOT xGetInitPos THEN
						lrStartLenth_Axis:=io_lrAxisALength;
						lrInitPos_Axis:=lrDelPos;
					END_IF
	
					IF xPreCurrentAxis<>i_xCurAxis_A THEN (*当前轴发生了变化*)
						io_lrAxisALength:=0;
						lrStartLenth_Axis:=0;
						lrInitPos_Axis:=lrDelPos;
					END_IF

					io_lrAxisALength :=lrStartLenth_Axis+(lrDelPos-lrInitPos_Axis)*lrCoeff_Lenth;
				ELSE
					IF NOT xGetInitPos THEN
						lrStartLenth_Axis:=io_lrAxisBLength;
						lrInitPos_Axis:=lrDelPos;
					END_IF
	
					IF xPreCurrentAxis<>i_xCurAxis_A THEN (*当前轴发生了变化*)
						io_lrAxisBLength:=0;
						lrStartLenth_Axis:=0;
						lrInitPos_Axis:=lrDelPos;
					END_IF
	
					io_lrAxisBLength :=lrStartLenth_Axis+(lrDelPos-lrInitPos_Axis)*lrCoeff_Lenth;
				END_IF
	
				IF NOT xGetInitPos THEN
					lrStartLenth_Total:=io_lrTotal_Length;
					lrInitPos_Total:=lrDelPos;
				END_IF
	
				io_lrTotal_Length := lrStartLenth_Total + (lrDelPos-lrInitPos_Total)*lrCoeff_Lenth;
				xGetInitPos:=TRUE;
			ELSE(*未到达写入pt步*)
				xGetInitPos:=FALSE;
			END_IF
		ELSE(*默认方式*)
			IF i_xCurAxis_A THEN			(*收卷当前A轴*)
				IF xPreCurrentAxis<>i_xCurAxis_A THEN (*当前轴发生了变化*)
					io_lrAxisALength:=0;
				END_IF
				io_lrAxisALength := io_lrAxisALength + i_rVel_Film * i_iCycleTime_Plc * lrCoeff_Lenth / 1000 / 60;
			ELSE
				IF xPreCurrentAxis<>i_xCurAxis_A THEN (*当前轴发生了变化*)
					io_lrAxisBLength:=0;
				END_IF
				io_lrAxisBLength := io_lrAxisBLength + i_rVel_Film * i_iCycleTime_Plc *lrCoeff_Lenth / 1000 / 60;
			END_IF
			io_lrTotal_Length := io_lrTotal_Length + i_rVel_Film * i_iCycleTime_Plc *lrCoeff_Lenth / 1000 / 60;
		END_IF

		(*2020.7.31.154826 增加了总计米的计算|用于显示这台机器生产的总米数*)
		IF NOT i_xIsDebugMode AND
			NOT i_xMachineRev  THEN(*非调试模式,非反向走料才更新*)
			lrDelPrintLenth:=io_lrTotal_Length-lrTotal_LengthBak;
			io_lrPrintLength:=io_lrPrintLength+lrDelPrintLenth;
		END_IF
	ELSE
		xGetInitPos:=FALSE;
	END_IF
	lrTotal_LengthBak:=io_lrTotal_Length;
	xPreCurrentAxis:= i_xCurAxis_A;(*上个周期的当前轴状态*)
END_IF