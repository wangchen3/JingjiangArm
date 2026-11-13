(*@CES
Name=Action_WindLength
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=1012244c-17b0-485f-9999-06d42ab8f3b8
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*计米功能重新处理*)

(*2020.5.7.182018_
	*计米清零重新整理|*)
(*重新处理计米标志清零2020.11.4.103358-Liu.yt*)
	FOR iN:=1 TO 3 BY 1 DO(*2020.7.30.111243|记米清零分A/B系|X.^_^*)
		axFilmLenSet0_Rw[iN]:=FALSE;
		IF axClearPrnLen_In[iN] OR(*Modbus通知要清零|*)
			abyClrPrnLenCount_In_Out[iN]>=2 THEN(*屏幕按钮双击清零|*)
			abyClrPrnLenCount_In_Out[iN]:= 0;
			(*2020.11.4.103501计米清零标志重新处理|屏蔽上面代码*)
			axFilmLenSet0_Rw[iN]:=TRUE;
		ELSIF abyClrPrnLenCount_In_Out[iN]>0 THEN
			IF (TIME()-atmTimeouts_ClrPrnLen[iN])>=T#1S THEN
				abyClrPrnLenCount_In_Out[iN]:= 0;
			END_IF
		ELSE
			atmTimeouts_ClrPrnLen[iN]:= TIME();
		END_IF
	END_FOR

(*2020.11.4.102638 计米功能修改-Liu.yt*)
(*2020.11.4.102638 重新处理计米|增加速度计米和规划计米、支持系数|Liu.yt*)
iCoeff_Lenth_Rw:=REAL_TO_INT(rPrintLengthCoef_In*100);
(*寻找第一个联动的非涂布轴*)
fbKS_FB_WindLengthDeal(
	i_xEn:= TRUE, 
	i_pxCalcLenWayChange:=ADR(xCalcPrintLenWayChange),
	i_piCoeff_Lenth:= ADR(iCoeff_Lenth_Rw),
	i_pxAxisAClr:= ADR(axFilmLenSet0_Rw[1]),
	i_pxAxisBClr:= ADR(axFilmLenSet0_Rw[2]),
	i_pxTotalClr:= ADR(axFilmLenSet0_Rw[3]),
	i_iGrpAxisNum_Pu:= i_iGrpAxisNum_Pu, 
	i_aiGrpAxisList:= i_aiGrpAxisList, 
	i_xCurAxis_A:= xCutAxisA_In_Out, 
	i_rVel_Film:= i_rVel_Film, 
	i_xFlag_Print:= i_xFlag_Print, 
	i_xFlag_RollerPressAtLeast1:= xFlag_RollerPressAtLeast1_In, 
	i_lrPrf_Pos_FirstAxis:= lrPrf_Pos_FirstAxis_In, 
	i_uiNum_FirstAxis:= uiNum_FirstAxis_In, 
	i_uiDen_FirstAxis:= uiDen_FirstAxis_In, 
	i_rGirth_FirstAxis:= rGirth_FirstAxis_In, 
	i_iCycleTime_Plc:= i_iCycleTime_Plc, 
	i_xIsDebugMode:= i_xIsDebugMode, 
	i_xMachineRev:= i_xMachineRev, 
	o_xEn=> , 
	io_lrAxisALength:= alrPrnLen_In_Out[1], 
	io_lrAxisBLength:= alrPrnLen_In_Out[2], 
	io_lrTotal_Length:= alrPrnLen_In_Out[3], 
	io_lrPrintLength:= lrPrintLength_In_Out, 
	io_byPrintLength_CalcCtl:= byPrintLength_CalcCtl_In_Out
);


axFlag_PrnLen_Alarm_In_Out[1]:=FALSE;
axFlag_PrnLen_Alarm_In_Out[2]:=FALSE;
axFlag_PrnLen_Alarm_In_Out[3]:=FALSE;
(*2017-08-24 09:00:17| 将测试条件<=改为>=运行模式*)
IF alrPrnLen_In_Out[1]>=alrPrnLen_Alarm_In[1] AND
	alrPrnLen_Alarm_In[1]<>0 AND (*且报警计长不是0，0标识不报警*)
	xCutAxisA_In_Out  THEN (*收料A轴计长报警*)
	axFlag_PrnLen_Alarm_In_Out[1]:=TRUE;
END_IF
IF alrPrnLen_In_Out[2]>=alrPrnLen_Alarm_In[2] AND
	alrPrnLen_Alarm_In[2]<>0 AND
	(NOT xCutAxisA_In_Out) THEN (*收料B轴计长报警*)
	axFlag_PrnLen_Alarm_In_Out[2]:=TRUE;
END_IF
IF alrPrnLen_In_Out[3]>=alrPrnLen_Alarm_In[3] AND
	alrPrnLen_Alarm_In[3]<>0 THEN (*收料总计长报警*)
	axFlag_PrnLen_Alarm_In_Out[3]:=TRUE;
END_IF
