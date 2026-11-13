(*@CES
Name=Action_AxisExChange
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=2a50f089-711e-4b4c-9013-de05bc9d6e04
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
			io_rDiamCurAxis:= rGirth_AxisA_In_Out / gc_lrPi;
		ELSE
			io_rDiamCurAxis:= rGirth_AxisB_In_Out / gc_lrPi;			
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
		io_rDiamCurAxis:= rGirth_AxisA_In_Out / gc_lrPi;
	ELSE
		i_pstStEvtReq^.xOutAxisBFor:= FALSE;
		i_pstStEvtReq^.xOutAxisBRev:= FALSE;
		i_pstStEvtReq^.xOutAxisBZeroServo:= FALSE;
		io_rDiamCurAxis:= rGirth_AxisB_In_Out / gc_lrPi;		
	END_IF
	rEstiDia_In_Out:= io_rDiamCurAxis;
	rDiameterTmp:=io_rDiamCurAxis;	
END_IF
i_pstStEvtReq^.xOutAxisALamp:= xCutAxisA_In_Out;
i_pstStEvtReq^.xOutAxisBLamp:= NOT xCutAxisA_In_Out;


(*3/6吋切换处理*)

(*3、6寸赋值方式修改|2020.9.9.092740|Liu.yt*)
xGirth_RwBy3Inch_6Inch:=FALSE;
IF rGirth_6Inch_In<>0 AND
	rGirth_3Inch_In<>0 THEN(*说明有使用3、6寸*)
	xGirth_RwBy3Inch_6Inch:=TRUE;
END_IF

IF NOT xInit_AxisAGirth_AxisBGirth_Rw THEN(*开机时我们不处理当前轴卷径值。只有切换3 6寸时才进行切换*)
	xPreFlag_6Inch:= xFlag_6Inch_Out;
	xGirth_RwBy3Inch_6InchBak:=xGirth_RwBy3Inch_6Inch;
	rGirth_6Inch:=rGirth_6Inch_In;
	rGirth_3Inch:=rGirth_3Inch_In;
	xInit_AxisAGirth_AxisBGirth_Rw:=TRUE;
END_IF

IF xGirth_RwBy3Inch_6Inch THEN(*收料周长由3 6寸确定*)
	IF NOT xGirth_RwBy3Inch_6InchBak (*刚切换到3 6寸控制*)OR
		(xFlag_6Inch_Out AND(*6寸周长变化了|*)
		rGirth_6Inch<>rGirth_6Inch_In) OR
		(NOT xFlag_6Inch_Out AND(*3寸周长变化了*)
		rGirth_3Inch<>rGirth_3Inch_In) THEN
		xPreFlag_6Inch:=NOT xFlag_6Inch_Out;(*用来触发下面的更新周长逻辑*)
	END_IF

	IF xFlag_6Inch_Out AND NOT xPreFlag_6Inch THEN(*切换到6吋*)
		rGirth_AxisA_In_Out:=rGirth_6Inch_In;
		rGirth_AxisB_In_Out:=rGirth_6Inch_In;
	ELSIF NOT xFlag_6Inch_Out AND xPreFlag_6Inch THEN(*切换到3寸*)
		rGirth_AxisA_In_Out:=rGirth_3Inch_In;
		rGirth_AxisB_In_Out:=rGirth_3Inch_In;
	END_IF
ELSE(*周长由AB轴周长确认*)
	;
END_IF
xPreFlag_6Inch:= xFlag_6Inch_Out;
xGirth_RwBy3Inch_6InchBak:=xGirth_RwBy3Inch_6Inch;
rGirth_6Inch:=rGirth_6Inch_In;
rGirth_3Inch:=rGirth_3Inch_In;

