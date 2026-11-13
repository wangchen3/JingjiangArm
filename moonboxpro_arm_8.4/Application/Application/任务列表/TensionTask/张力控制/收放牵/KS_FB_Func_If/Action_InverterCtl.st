(*@CES
Name=Action_InverterCtl
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=cdbf623c-4e54-4fe1-8ea2-36d6ce5bcc3d
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
//处理牵引变频控制相关
//先处理报警信息
IF xInverterAlarmIO THEN(*IO输入了*)
	xInverterAlarm_Out:= TRUE;
END_IF
//处理复位报警信号
IF xClrAlarmInf_In THEN
	xInverterReset:= xInverterAlarmIO;
ELSIF NOT xInverterAlarmIO THEN
	xInverterReset:= FALSE;
END_IF
//提示信息处理
IF xInverterAlarm_Out THEN//有报警提示了，检查是否点击界面的清除
	IF xClrAlarmInf_In THEN
		xCanClrAlarmInf:=TRUE;		
	END_IF
	IF xCanClrAlarmInf THEN
		IF NOT xInverterAlarmIO THEN//报警已经没了,可以清除提示了
			xInverterAlarm_Out:= FALSE;
		END_IF
	END_IF
ELSE
	xCanClrAlarmInf:= FALSE;
END_IF

(*2021.7.29.093047增加了收放牵变频控制时单运行使能标志*)
xInchEn:= (xFlag_Ink_In OR xFlag_Stop_In) AND (NOT xFlag_Tension_In);
fbTrig_Inch(CLK:= xInchBtn_In);
IF xInchType_In THEN(*按下走按下停*)
	IF fbTrig_Inch.Q THEN
		xInch:= NOT xInch;
	END_IF
ELSE//按下走松开停
	xInch:= xInchBtn_In;
END_IF
IF NOT xInchEn THEN
	xInch:= FALSE;
END_IF
xInchDir:= xInchDir_In;
iInchVel:= iInchVel_In;

xInch_Out:= xInch;

Action_VelToVol();

xInverter_Cw:= xFlag_Print_In OR (xInchEn AND xInch);
(*2023.5.16.114800@关于牵引报警急停处理*)
IF xInverterAlarm_Out THEN(*报警了@取消使能以及速度输出*)
	xInverter_Cw:= FALSE;
	rAO_Inverter_Out:= 0;
	rAO_VelFilm_Out:= 0;
END_IF
(*		xIsDualUwRw:= i_dwEquipmentProf.20;
		xAsOneMachine:= i_dwEquipmentProf.21;*)
wAO_Inverter_Out:= DINT_TO_WORD(KSIO_AD(
	rAO_Inverter_Out,
	-10,
	10,
	-32767,
	32767
	));
xInverter_Cw_Out:= xInverter_Cw;
//变频自调处理
wAO_FilmVel_Out:= DINT_TO_WORD(KSIO_AD(
	rAO_VelFilm_Out,
	-10,
	10,
	-32767,
	32767
	));
xAdjustEn_Out:= NOT (NOT i_xIsDebugMode AND
			xFlag_Print_In AND xRollerSts_IfOf_In);	
xInverterAlarmIO:= 	xInverterAlarm_IO_In;
xInverterResetIO_Out:= xInverterReset;


