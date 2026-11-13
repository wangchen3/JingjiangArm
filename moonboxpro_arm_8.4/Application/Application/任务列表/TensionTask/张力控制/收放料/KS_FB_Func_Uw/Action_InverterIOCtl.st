(*@CES
Name=Action_InverterIOCtl
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=4aed1388-868c-4c3f-9d99-f4794e1232da
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*变频器IO控制*)
(*
	i_pstStEvtReq^.xOutAxisAFor: BOOL;(*A轴正转输出*)
	i_pstStEvtReq^.xOutAxisARev: BOOL;(*A轴反转输出*)
	i_pstStEvtReq^.xOutAxisAZeroServo: BOOL;(*A轴零伺服输出*)
	i_pstStEvtReq^.xOutAxisBFor: BOOL;(*B轴正转输出*)
	i_pstStEvtReq^.xOutAxisBRev: BOOL;(*B轴反转输出*)
	i_pstStEvtReq^.xOutAxisBZeroServo: BOOL;(*B轴零伺服输出*)
*)
(*单运行放这里处理算了*)
IF i_pstStEvtReq^.xEvt_Inch AND
	(NOT o_xSts_PreCutting) AND 
	(NOT i_xFlag_Tension) AND
	(NOT i_xFlag_Print) AND
	(NOT i_xFlag_Estop) THEN
	xInch:= TRUE;
ELSE
	xInch:= FALSE;
END_IF
IF i_pstStEvtReq^.xEvt_RevInch AND
	(NOT o_xSts_PreCutting) AND 
	(NOT i_xFlag_Tension) AND
	(NOT i_xFlag_Print) AND
	(NOT i_xFlag_Estop) THEN
	xRevInch:= TRUE;
ELSE
	xRevInch:= FALSE;
END_IF
i_pstStEvtReq^.xOutLampAxisInching:= xInch OR xRevInch;

IF i_rVel_Film>0 THEN
	IF xFlag_PreDrv_ing_Out OR 	xFlag_PreDrv_end_Out THEN(*预驱中或预驱完成*)
		(*放料A轴*)
		i_pstStEvtReq^.xOutAxisAFor:= TRUE; (*正转*)
		i_pstStEvtReq^.xOutAxisARev:= FALSE;
		i_pstStEvtReq^.xOutAxisAZeroServo:= FALSE;

		(*放料B轴*)
		i_pstStEvtReq^.xOutAxisBFor:= TRUE; (*正转*)
		i_pstStEvtReq^.xOutAxisBRev:= FALSE;
		i_pstStEvtReq^.xOutAxisBZeroServo:= FALSE;
	ELSE
		IF xCutAxisA_In_Out THEN
			(*放料A轴*)
			i_pstStEvtReq^.xOutAxisAFor:= TRUE; (*正转*)
			i_pstStEvtReq^.xOutAxisARev:= FALSE;
			i_pstStEvtReq^.xOutAxisAZeroServo:= FALSE;

			(*放料B轴*)
			i_pstStEvtReq^.xOutAxisBFor:= xPreDrvAxis_Releasing_Out; (*正转*)
			i_pstStEvtReq^.xOutAxisBRev:= FALSE;
			i_pstStEvtReq^.xOutAxisBZeroServo:= FALSE;
		ELSE
			(*放料A轴*)
			i_pstStEvtReq^.xOutAxisAFor:= xPreDrvAxis_Releasing_Out; (*正转*)
			i_pstStEvtReq^.xOutAxisARev:= FALSE;
			i_pstStEvtReq^.xOutAxisAZeroServo:= FALSE;
			(*放料B轴*)
			i_pstStEvtReq^.xOutAxisBFor:= TRUE; (*正转*)
			i_pstStEvtReq^.xOutAxisBRev:= FALSE;
			i_pstStEvtReq^.xOutAxisBZeroServo:= FALSE;
		END_IF		
	END_IF
ELSIF i_xFlag_Tension THEN
	
	(*2017-08-29 11:35:57
	/.非印刷情况的张力投入,一般是拉料状态.
	*)
	(*2017-08-29 15:02:28|
	/.放料变频
	*)
	IF xCutAxisA_In_Out THEN (*当前轴是A轴*)
		i_pstStEvtReq^.xOutAxisAFor:= xInverterCW; (*正转*)
		i_pstStEvtReq^.xOutAxisARev:= FALSE;
		i_pstStEvtReq^.xOutAxisAZeroServo:= FALSE;
		i_pstStEvtReq^.xOutAxisBFor:= FALSE; (*正转*)
		i_pstStEvtReq^.xOutAxisBRev:= FALSE;
		i_pstStEvtReq^.xOutAxisBZeroServo:= FALSE;		

	ELSE
		i_pstStEvtReq^.xOutAxisAFor:= FALSE; (*正转*)
		i_pstStEvtReq^.xOutAxisARev:= FALSE;
		i_pstStEvtReq^.xOutAxisAZeroServo:= FALSE;
		i_pstStEvtReq^.xOutAxisBFor:= xInverterCW; (*正转*)
		i_pstStEvtReq^.xOutAxisBRev:= FALSE;
		i_pstStEvtReq^.xOutAxisBZeroServo:= FALSE;		
	END_IF	
ELSE
	(*2017-08-29 11:31:52
	/.非张力 非印刷 都要把变频停掉
	*)
	(*2017-08-29 15:02:52|
	/.放料变频
	*)
	(*2021.9.2.104343 增加收放料速度调试模式使能处理|*)
	IF NOT xAxisDebugEn_In_Out THEN(*非调试模式*)
		IF xCutAxisA_In_Out THEN
			(*放料A轴*)
			i_pstStEvtReq^.xOutAxisAFor:= xInch OR xInverterCW OR xRevInch;(*2024.2.26.092844*)
			i_pstStEvtReq^.xOutAxisARev:= FALSE;
			i_pstStEvtReq^.xOutAxisAZeroServo:= FALSE;

			(*放料B轴*)
			i_pstStEvtReq^.xOutAxisBFor:= FALSE(*FALSE*);
			i_pstStEvtReq^.xOutAxisBRev:= FALSE;
			i_pstStEvtReq^.xOutAxisBZeroServo:= FALSE;
		ELSE
			(*放料A轴*)
			i_pstStEvtReq^.xOutAxisAFor:= FALSE(*FALSE*);
			i_pstStEvtReq^.xOutAxisARev:= FALSE;
			i_pstStEvtReq^.xOutAxisAZeroServo:= FALSE;

			(*放料B轴*)
			i_pstStEvtReq^.xOutAxisBFor:= xInch OR xInverterCW OR xRevInch;(*2024.2.26.092930*)
			i_pstStEvtReq^.xOutAxisBRev:= FALSE;
			i_pstStEvtReq^.xOutAxisBZeroServo:= FALSE;
		END_IF
	ELSE(*轴速度调试模式*)
		(*放料A轴*)
		i_pstStEvtReq^.xOutAxisAFor:= xAxisADebugRunning_In_Out;
		i_pstStEvtReq^.xOutAxisARev:= FALSE;
		i_pstStEvtReq^.xOutAxisAZeroServo:= FALSE;

		(*放料B轴*)
		i_pstStEvtReq^.xOutAxisBFor:= xAxisBDebugRunning_In_Out;
		i_pstStEvtReq^.xOutAxisBRev:= FALSE;
		i_pstStEvtReq^.xOutAxisBZeroServo:= FALSE;
	END_IF	
END_IF