(*@CES
Name=KS_FB_GrpAlarmBellControl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=91de606a-1433-4ee1-833d-0b9475f7a542
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GrpAlarmBellControl(*报警铃处理功能块|wang.nt|2025.08.12.114029*)
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId:INT;
	i_iGrpAxisNum_Pu: INT;(*色组轴数|*)
	i_pstStSysParam: POINTER TO StSysParam;
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT;(*轴-站映射表|*)
	i_pastStIOMap_AxisBasic: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*基础io|*)
	i_pastStIOMap_Main: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Main_FE;(*基础io|*)
	i_pstStEvtReq: POINTER TO StEvtReq;
	i_iAxisId_If: INT;
	i_iAxisId_Of: INT;
	(*乔欣功能增加变量*)
	(*新增加的输入参数--没料时保持响铃，按下任意接料相关按钮则停止响铃|2020.1.10.103514Liu.yt*)
	i_xKeepAlarm_NoMaterial:BOOL;(*有效则一直报警 否则就停止报警！若没有出现过true则按照延迟3s响铃*)
	i_xAlarm_CutDne_Uw:BOOL;(*放料裁切完成后报警一段时间使能标志|5S*)

	(*2020.9.9.115353  针对利佳创增加的报警功能|Liu.yt*)
	i_xAlarm_AccOrDecing:BOOL;
	i_xAlarm_CutFinish_Uw:BOOL;(*接料完成后报警*)
	i_xAlarm_CutFinish_Rw:BOOL;(*接料完成后报警*)
	i_xAlarm_VolDiamAlarm_Uw:BOOL;

	(*2021.4.30.112256 增加放料响铃常输出|*)
	i_xAlarmBell_Uw:BOOL;
	(*2021.6.1.084348 收料报警铃常输出*)
	i_xAlarmBell_Rw:BOOL;
	i_axFlag_AdjValid_V:ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*2025.08.12.150129|纵向自动*)
	i_axThisUnitEna: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*本色组套色开*)
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_iErNo: INT;
	o_xPrnRollerLoose_AtLeast1:BOOL;(*至少一色的夹板松了|用于文字提示|2022.4.3.163820*)
	o_xLostPressure:BOOL;(*气压低报警|用于文字提示*)
	o_xbrakeResistanceTempHigh_AtLeast1:BOOL;(*至少一色制动电阻温度高*)
END_VAR
VAR
	iN: INT;
	iAxisId: INT;
	xTmp: BOOL;
	xTmp_UwAlarm: BOOL;
	afbFlag_TON: ARRAY [1..4] OF TON;
	pstStIOMap_AxisBasic: POINTER TO StIOMap_Axis_FE;
	iJ: INT;
	iAxisId_Pu: INT;
	pstStIOMap_Main: POINTER TO StIOMap_Main_FE;

	(*为乔欣没料一直报警以及接料后报警的逻辑添加变量2020.1.10.103803|Liu.yt*)
	xCanAlarm_If: BOOL;
	xFlag_KeepAlarm_NoMaterial: BOOL;
	xFlag_CutDne_Uw: BOOL:=FALSE;
	xCanAlarm_CutDne: BOOL;
	abyLostPressureInCnt: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*2022.7.24.115721  增加输入防抖*)
	tTimeTmp: TIME;
END_VAR

{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	IF i_iGrpAxisNum_Pu>0 AND
		i_pstStSysParam<>0 AND
		i_pastStIOMap_AxisBasic<>0 AND
		i_pstStEvtReq<>0 THEN

		(*预启动报警|*)
		afbFlag_TON[1](
			IN:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_KeepAlarming,
			PT:= gc_tmAlarmHold_PreStart);

		(*放料卷径报警|*)
		(*2024.8.15.171001+*)
		IF i_pstStSysParam^.stStSysParam_Save.byAlarmHold_VOL_Uw=0 THEN
			i_pstStSysParam^.stStSysParam_Save.byAlarmHold_VOL_Uw:=3;
		END_IF
		tTimeTmp:=DWORD_TO_TIME(BYTE_TO_DWORD(i_pstStSysParam^.stStSysParam_Save.byAlarmHold_VOL_Uw)*1000);

		afbFlag_TON[2](
			IN:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_VolDiamAlarm_Uw,
			PT:= tTimeTmp(*gc_tmAlarmHold_VOL_Uw*));

(*-----------------------------------------------------------------QIAOXIN*)
		(*为乔欣没料一直报警的逻辑添加变量2020.1.10.103555|Liu.yt*)
		IF i_xKeepAlarm_NoMaterial OR
			i_xAlarm_VolDiamAlarm_Uw THEN(*利佳创没料报警标志*)
			xFlag_KeepAlarm_NoMaterial:=TRUE;
		END_IF


		IF xFlag_KeepAlarm_NoMaterial THEN
			xCanAlarm_If:=i_xKeepAlarm_NoMaterial OR i_xAlarm_VolDiamAlarm_Uw;
		ELSE
			xCanAlarm_If:=NOT afbFlag_TON[2].Q;
		END_IF
		
		(*为乔欣增加的接料后延时5s响铃报警逻辑2020.1.10.103600|Liu.yt*)
		IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Cut_end_Uw AND i_xAlarm_CutDne_Uw THEN
			xFlag_CutDne_Uw:=TRUE;
		END_IF

		(*2024.8.15.171001+*)
		IF i_pstStSysParam^.stStSysParam_Save.byAlarmHold_CutDne_Uw=0 THEN
			i_pstStSysParam^.stStSysParam_Save.byAlarmHold_CutDne_Uw:=3;
		END_IF
		tTimeTmp:=DWORD_TO_TIME(BYTE_TO_DWORD(i_pstStSysParam^.stStSysParam_Save.byAlarmHold_CutDne_Uw)*1000);

		afbFlag_TON[4](IN:=xFlag_CutDne_Uw,PT:=tTimeTmp(*gc_tmAlarmHold_CutDne_Uw*));(*放料裁切完成*)
		IF afbFlag_TON[4].Q THEN(*时间到了*)
			xFlag_CutDne_Uw:=FALSE;
		END_IF

		xCanAlarm_CutDne:=xFlag_CutDne_Uw;(*启动报警*)

(*-----------------------------------------------------------------QIAOXIN*)

		(*印长报警|*)
		xTmp:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].wUwRwAxisProf.1 AND i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].axFlag_PrnLen_Alarm[1];
		xTmp:= xTmp OR ((NOT i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].wUwRwAxisProf.1) AND i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].axFlag_PrnLen_Alarm[2]);
		xTmp:= xTmp OR i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].axFlag_PrnLen_Alarm[3];

		(*2024.8.15.171001+*)
		IF i_pstStSysParam^.stStSysParam_Save.byAlarmHold_PrnLength=0 THEN
			i_pstStSysParam^.stStSysParam_Save.byAlarmHold_PrnLength:=3;
		END_IF
		tTimeTmp:=DWORD_TO_TIME(BYTE_TO_DWORD(i_pstStSysParam^.stStSysParam_Save.byAlarmHold_PrnLength)*1000);


		afbFlag_TON[3](
			IN:= xTmp,
			PT:= tTimeTmp(*gc_tmAlarmHold_PrnLength*));

		IF afbFlag_TON[1].Q AND i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_KeepAlarming THEN
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_KeepAlarming:= FALSE;
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PrestartTimeout:=TRUE;
		ELSE
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PrestartTimeout:=FALSE;
		END_IF

		(*计长报警默认接在收牵处|*)
		xTmp:= (i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].wUwRwAxisProf.1 AND i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].axFlag_PrnLen_Alarm[1]);(*A轴印长报警|*)
		xTmp:= xTmp OR ((NOT i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].wUwRwAxisProf.1) AND i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].axFlag_PrnLen_Alarm[2]);(*B轴印长报警|*)
		xTmp:= xTmp OR i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].axFlag_PrnLen_Alarm[3];(*总印长报警|*)
		IF i_iAxisId_Of>=1 AND i_iAxisId_Of<=MAX_UNIT_NUM THEN
			IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print AND
				xTmp AND
				NOT afbFlag_TON[3].Q THEN
				xTmp_UwAlarm:= TRUE;
			ELSE
				xTmp_UwAlarm:= FALSE;
			END_IF
		END_IF


		(*预启动报警或人为按下报警按钮|*)
		IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_KeepAlarming THEN
			xTmp:= TRUE;
		ELSE
			xTmp:= i_pstStEvtReq^.xEvt_AlarmBell;
		END_IF
		xTmp:= xTmp OR xTmp_UwAlarm;

		(*主报警默认接在收牵的位置|*)
		IF i_iAxisId_Of>=1 AND i_iAxisId_Of<=MAX_UNIT_NUM THEN
			pstStIOMap_Main:= ADR(i_pastStIOMap_Main^[i_iAxisId_Of]);
			(*2020.9.9.115605修改下面逻辑屏蔽上面逻辑|Liu.yt*)
			pstStIOMap_Main^.o_xRel_AlarmBell:=xTmp OR
									(i_xAlarm_AccOrDecing OR(*增加了加减速报警2020.9.9.115613*)
									i_xAlarm_CutFinish_Rw) OR(*增加了收料结完料后报警2020.9.9.115618*)
									i_xAlarmBell_Rw;(*2021.6.1.084445 收料报警铃常输出*)

		END_IF


		(*放料报警默认接在放牵处|*)
		IF i_iAxisId_If>=1 AND i_iAxisId_If<=MAX_UNIT_NUM THEN
			pstStIOMap_Main:= ADR(i_pastStIOMap_Main^[i_iAxisId_If]);
			IF (i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print AND
				((i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_VolDiamAlarm_Uw AND xCanAlarm_If)OR
				i_xAlarm_CutFinish_Uw OR(*放料接料完成报警*)
				xCanAlarm_CutDne)) OR i_xAlarmBell_Uw THEN
				pstStIOMap_Main^.o_xRel_AlarmBell:= TRUE;
			ELSE
				pstStIOMap_Main^.o_xRel_AlarmBell:= FALSE;
			END_IF
		END_IF

		(*2019.01.15.171049|niu.j|套色报警处理*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iAxisId:= i_aiGrpAxisList[iN];
			pstStIOMap_AxisBasic:= ADR(i_pastStIOMap_AxisBasic^[iAxisId]);
			IF iN<=i_iGrpAxisNum_Pu THEN
				pstStIOMap_AxisBasic^.o_xRel_ArcAlarm_Unit:= FALSE;
				IF i_pstStSysParam^.astStUnitParam_Save[iAxisId].xLinkage AND i_axThisUnitEna[iAxisId] AND i_axFlag_AdjValid_V[iAxisId] THEN
					IF i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xSwitch_Alarm_Arc THEN
						pstStIOMap_AxisBasic^.o_xRel_ArcAlarm_Unit:= pstStIOMap_AxisBasic^.o_xLamp_Lost
							OR pstStIOMap_AxisBasic^.o_xLamp_Warning;
					ELSE
						;
					END_IF
					
				END_IF
			ELSE
				pstStIOMap_Main^.o_xRel_ArcAlarm:=FALSE;
				IF i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xSwitch_Alarm_Arc THEN
					FOR iJ:=1 TO i_iGrpAxisNum_Pu BY 1 DO
						iAxisId_Pu:= i_aiGrpAxisList[iJ];
						pstStIOMap_AxisBasic:= ADR(i_pastStIOMap_AxisBasic^[iAxisId_Pu]);
						IF pstStIOMap_AxisBasic^.o_xRel_ArcAlarm_Unit THEN
							pstStIOMap_Main^.o_xRel_ArcAlarm:= TRUE;
							EXIT;
						ELSE
							;
						END_IF
					END_FOR
				END_IF
			END_IF
		END_FOR

		(*2022.4.3.162946  增加了压力低报警-夹板松报警输出|牵引作为总的夹板松输出*)
		o_xPrnRollerLoose_AtLeast1:=FALSE;
		o_xLostPressure:=FALSE;
		o_xbrakeResistanceTempHigh_AtLeast1:=FALSE;
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iAxisId:= i_aiGrpAxisList[iN];
			//pstStAxisParam:= ADR(i_pstStShmGlobalParam^.astStAxisParam[iAxisId]);
			pstStIOMap_AxisBasic:= ADR(i_pastStIOMap_AxisBasic^[iAxisId]);
			(*夹板松报警处理*)
			IF iN<=i_iGrpAxisNum_Pu THEN(*色组轴*)
				pstStIOMap_AxisBasic^.o_xPrnRollerLoose_H:=
									(i_pstStSysParam^.astStUnitParam_Save[iN].xLinkage)AND
									pstStIOMap_AxisBasic^.i_xPrnRollerLoose_H;

				IF NOT o_xPrnRollerLoose_AtLeast1 THEN
					o_xPrnRollerLoose_AtLeast1:=pstStIOMap_AxisBasic^.o_xPrnRollerLoose_H;
				END_IF
			ELSE(*牵引轴*)
				pstStIOMap_AxisBasic^.o_xPrnRollerLoose_H:=o_xPrnRollerLoose_AtLeast1;
			END_IF


			(*气压低报警处理|用于控制响铃*)
			(*2024.8.17.151108 在io获取的地方做了5次防抖*)
			pstStIOMap_AxisBasic^.o_xLostPressure:=pstStIOMap_AxisBasic^.i_xLostPressure;

			IF NOT o_xLostPressure THEN
				o_xLostPressure:=pstStIOMap_AxisBasic^.o_xLostPressure;
			END_IF

			(*ptc过温报警提示*)
			pstStIOMap_AxisBasic^.o_xPtcTempHigh:=pstStIOMap_AxisBasic^.i_xPtcSignal;
			IF NOT o_xbrakeResistanceTempHigh_AtLeast1 THEN
				o_xbrakeResistanceTempHigh_AtLeast1:=pstStIOMap_AxisBasic^.o_xPtcTempHigh;
			END_IF
		END_FOR
	ELSE
		o_iErNo:= -1;
	END_IF
END_IF