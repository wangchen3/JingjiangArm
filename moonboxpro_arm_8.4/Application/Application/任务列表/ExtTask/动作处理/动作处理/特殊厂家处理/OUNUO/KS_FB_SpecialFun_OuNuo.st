(*@CES
Name=KS_FB_SpecialFun_OuNuo
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=87514a68-a3ca-4efa-baca-091a98755211
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_SpecialFun_OuNuo
VAR_INPUT
	i_xEn:BOOL;
	i_iGrpId								: INT;
	i_pstStSysParam			: POINTER TO StSysParam;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	xChangeSpeeding: BOOL;(*速度变化中*)
	fbChangeSpeeding:R_TRIG;
	tTimeNow:TIME;
	tTimeChangeSpeedingSa: TIME;(*变速开始时间*)
	tTimeChangeSpeedingAlarm:TIME:=T#3000MS;
	xChangeSpeedingNeedAlarm: BOOL;(*变速响铃|先按照3s响铃处理*)
	pstStGrpParam_UnSave:POINTER TO StGrpParam_UnSave;
END_VAR


{IMPLEMENTATION}
IF i_xEn THEN
	IF i_pstStSysParam <> 0 AND (i_iGrpId=1 OR i_iGrpId=2) THEN
		pstStGrpParam_UnSave:=ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);

		g_byArcLampDisWay:=2;(*欧诺专用三色灯*)
		g_xCoolBlowerOpenByKnob:=TRUE;(*旋钮直接控制冷风@2024.6.28.122527*)
		
		(*2026.05.26.153411 同步*)
		tTimeNow:=TIME();
		(*加减速响铃3s处理*)
		xChangeSpeeding:=NOT pstStGrpParam_UnSave^.xFlag_InkAccing AND
						NOT pstStGrpParam_UnSave^.xFlag_EStoping AND
						NOT pstStGrpParam_UnSave^.xFlag_Stoping AND
						NOT pstStGrpParam_UnSave^.xFlag_FastStoping AND
						(pstStGrpParam_UnSave^.xFlag_Accing OR
						pstStGrpParam_UnSave^.xFlag_Decing);
		fbChangeSpeeding(CLK:=xChangeSpeeding);
		IF fbChangeSpeeding.Q THEN
			xChangeSpeedingNeedAlarm:=TRUE;
		END_IF

		IF xChangeSpeedingNeedAlarm THEN
			pstStGrpParam_UnSave^.xAlarmBell_Rw:=TRUE;
			IF tTimeNow-tTimeChangeSpeedingSa>=tTimeChangeSpeedingAlarm THEN(*时间到了*)
				xChangeSpeedingNeedAlarm:=FALSE;
				pstStGrpParam_UnSave^.xAlarmBell_Rw:=FALSE;(*停止响铃*)
			END_IF
		ELSE
			tTimeChangeSpeedingSa:=tTimeNow;
		END_IF
	ELSE
		;
	END_IF
ELSE
	;
END_IF
