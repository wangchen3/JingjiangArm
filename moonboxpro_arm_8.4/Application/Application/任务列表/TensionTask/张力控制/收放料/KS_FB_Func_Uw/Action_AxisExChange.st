(*@CES
Name=Action_AxisExChange
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=a6b71d44-357e-400a-82ee-3730c6792cc9
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*轴切换*)
xDiamWr_Manu:=FALSE;(*2024.05.28.163755*)
IF xCurAxisDia_Wr_In_Out THEN
	xCurAxisDia_Wr_In_Out:= FALSE;
	IF NOT i_xFlag_Print THEN
		IF xCutAxisA_In_Out THEN(*当前A轴*)
			io_rDiamCurAxis:= rGirth_AxisA_In / gc_lrPi;
		ELSE
			io_rDiamCurAxis:= rGirth_AxisB_In / gc_lrPi;			
		END_IF
		rEstiDia_In_Out:= io_rDiamCurAxis;
		rDiameterTmp:=io_rDiamCurAxis;
		xDiamWr_Manu:= TRUE;
	END_IF
END_IF
IF (NOT i_xFlag_Estop) AND//非急停状态
	(NOT i_xFlag_Print) AND//非印刷状态
	(NOT o_xSts_PreCutting) AND i_pstStEvtReq^.xReq_AxisExchange THEN(*非预备接料*)
	xCutAxisA_In_Out:= NOT xCutAxisA_In_Out;
	IF xCutAxisA_In_Out THEN
		i_pstStEvtReq^.xOutAxisAFor:= FALSE;
		i_pstStEvtReq^.xOutAxisARev:= FALSE;
		i_pstStEvtReq^.xOutAxisAZeroServo:= FALSE;
		io_rDiamCurAxis:= rGirth_AxisA_In / gc_lrPi;
	ELSE
		i_pstStEvtReq^.xOutAxisBFor:= FALSE;
		i_pstStEvtReq^.xOutAxisBRev:= FALSE;
		i_pstStEvtReq^.xOutAxisBZeroServo:= FALSE;
		io_rDiamCurAxis:= rGirth_AxisB_In / gc_lrPi;		
	END_IF
	rEstiDia_In_Out:= io_rDiamCurAxis;
	rDiameterTmp:=io_rDiamCurAxis;	
END_IF
i_pstStEvtReq^.xOutAxisALamp:= xCutAxisA_In_Out;
i_pstStEvtReq^.xOutAxisBLamp:= NOT xCutAxisA_In_Out;
