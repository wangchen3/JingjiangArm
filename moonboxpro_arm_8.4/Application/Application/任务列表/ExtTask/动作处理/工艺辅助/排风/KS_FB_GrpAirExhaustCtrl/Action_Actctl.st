(*@CES
Name=Action_Actctl
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=7a9aaa90-0a9b-4360-bf1f-0adbda78fd6c
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
	
o_xEno:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	IF (i_iGrpAxisNum_Pu>=1 AND i_iGrpAxisNum_Pu<=MAX_UNIT_NUM) AND(*系的色组数量有效|*)
		i_pstStEvtReq<>0  AND 
		i_pstStSysParam <>0 AND 
		i_PastStIOMap_Axis_Extra_FE <>0 THEN
	
		(*2024.01.22.143013+*)
		IF i_iCycleTime_Plc<=0 THEN
			i_iCycleTime_Plc:= gc_EXT_TSK_CYCLE_TIME;
		END_IF

		(*2021.7.29.164011 增加了排风和急停关联标志|*)
		xAirExhaustStopConnecEstop:=FALSE;
		IF i_xStopAirExhaustWhenEstop THEN
			xAirExhaustStopConnecEstop:=i_xFlag_Estop OR i_pstStEvtReq^.xReqEstop;
		END_IF

		IF NOT (*i_pstStGrpParam^.xFlag_Estop*)xAirExhaustStopConnecEstop THEN(*2018.8.13.160714*)
			IF i_pstStEvtReq^.xReqAllExhBlower THEN(*排风按下检测上升沿*)
				xAirExhaustFlag:=NOT xAirExhaustFlag;
				FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
					iAxisId:= i_aiGrpAxisList[iN];
					axlamp_AllExhBlower_Up_Out[iAxisId]:= xAirExhaustFlag ;
					axlamp_AllExhBlower_Dn_Out[iAxisId]:= xAirExhaustFlag ;
				END_FOR
				iExhStartStep:=1;
				iDelay_ExhStartCount:=0;
				iDelay_ExhChangeCount:=0;
			END_IF
		ELSE
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iAxisId:= i_aiGrpAxisList[iN];
				axlamp_AllExhBlower_Up_Out[iAxisId]:= FALSE ;
				axlamp_AllExhBlower_Dn_Out[iAxisId]:= FALSE;
			END_FOR
			xAirExhaustFlag:=FALSE;(*排风启动标志*)
		END_IF

		(*排风初始化*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iAxisId:= i_aiGrpAxisList[iN];
			axRel_AllExhBlower_Up_Out[iAxisId]:=FALSE;
			axRel_ModeTriangle_AllExhBlower_Up_Out[iAxisId]:=FALSE;
			axRel_ModeStar_AllExhBlower_Up_Out[iAxisId]:=FALSE;
			axRel_AllExhBlower_Dn_Out[iAxisId]:= FALSE;
			axRel_ModeTriangle_AllExhBlower_Dn_Out[iAxisId]:=FALSE;
			axRel_ModeStar_AllExhBlower_Dn_Out[iAxisId]:=FALSE;
		END_FOR
		o_xAirExhaustFinishFlag:=FALSE;

		IF  xAirExhaustFlag THEN(*排风有效*)
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iAxisId:= i_aiGrpAxisList[iN];
				IF axAllExhBlower_Err_Up_In[iAxisId] OR axAllExhBlower_Err_Dn_In[iAxisId]  THEN(*1：上排风 2：下排风 报警,*)
					xAllExhBlowerErr_Flag:=TRUE;
				ELSE
					xAllExhBlowerErr_Flag:=FALSE;
				END_IF
			END_FOR
			IF xAllExhBlowerErr_Flag THEN
				FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
					iAxisId:= i_aiGrpAxisList[iN];
					axlamp_AllExhBlower_Up_Out[iAxisId]:= FALSE ;
					axlamp_AllExhBlower_Dn_Out[iAxisId]:= FALSE;
				END_FOR
				xAirExhaustFlag:=FALSE;
			ELSE
				FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
					iAxisId:= i_aiGrpAxisList[iN];
					axRel_AllExhBlower_Up_Out[iAxisId]:=TRUE;
					axRel_AllExhBlower_Dn_Out[iAxisId]:= TRUE;
				END_FOR
				CASE iExhStartStep OF
				1:(*先启动三角型接法*)
					FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
						iAxisId:= i_aiGrpAxisList[iN];
						axRel_ModeStar_AllExhBlower_Up_Out[iAxisId]:=TRUE;
						axRel_ModeStar_AllExhBlower_Dn_Out[iAxisId]:=TRUE;(*星型启动*)
					END_FOR
					IF iDelay_ExhStartCount>= i_iDelayMsec_ExhPowerMode/i_iCycleTime_Plc THEN(*延迟30s*)
						iExhStartStep :=2;
					ELSE
						iDelay_ExhStartCount:=iDelay_ExhStartCount+1;
					END_IF
				2:
					IF iDelay_ExhChangeCount>= 500/i_iCycleTime_Plc THEN
						FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
							iAxisId:= i_aiGrpAxisList[iN];
							
							axRel_ModeTriangle_AllExhBlower_Up_Out[iAxisId]:=TRUE;
							axRel_ModeTriangle_AllExhBlower_Dn_Out[iAxisId]:=TRUE;;(*三角形运行*)
						END_FOR
					ELSE
						iDelay_ExhChangeCount:=iDelay_ExhChangeCount+1;
					END_IF
				ELSE
					;
				END_CASE
				o_xAirExhaustFinishFlag:=TRUE;
			END_IF
		END_IF

(*美格色组排风启动2018.10.13.141323by liu.yt*)
		IF o_xAirExhaustFinishFlag THEN(*排风标志有效*)
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iAxisId:= i_aiGrpAxisList[iN];
				IF axAirExhaustSwitch_In[iAxisId]  THEN(*该色排风开*)
					IF NOT axAirExhaustEn_Out[iAxisId] AND NOT axAirExhaustEn_Auto[iN] THEN(*该色未使能*)(*2018.7.10.131202 增加了axAirHotEn_Auto[uiN] 条件控制热风自动只启动一次*)
						IF   iAirExhaustOpenSum=0  THEN
							axAirExhaustEn_Out[iAxisId]:=TRUE;
							iAirExhaustOpenSum:=1;
							iAirExhaustDelayCount:=0;
						ELSE
							IF i_iDelayMsec_HeatBlower<iAirExhaustDelayCount*i_iCycleTime_Plc THEN(*延时到临时工用热风延时*)
								axAirExhaustEn_Out[iAxisId]:=TRUE;
								iAirExhaustOpenSum:=iAirExhaustOpenSum+1;
								iAirExhaustDelayCount:=0;
							ELSE
								iAirExhaustDelayCount:=iAirExhaustDelayCount+1;
								EXIT;
							END_IF
						END_IF
					ELSE;
					END_IF
				ELSE(*该色排风关*)
					IF NOT axAirExhaustSwitch_In[iAxisId] AND axPreBtnAirExhaustON[iN]  THEN
						IF axAirExhaustEn_Out[iAxisId] THEN
							iAirExhaustOpenSum:=iAirExhaustOpenSum-1;
							axAirExhaustEn_Out[iAxisId]:=FALSE;
						END_IF
					END_IF
				END_IF
				axPreBtnAirExhaustON[iN]:=axAirExhaustSwitch_In[iAxisId] ;


		(*MG2018.10.13.145234 增加全体排风风开了之后只执行一次*)
				IF axAirExhaustSwitch_In[iAxisId]  THEN
					IF axAirExhaustEn_Out[iAxisId]  THEN
						axAirExhaustEn_Auto[iN]:=TRUE;
					END_IF
				ELSE
					axAirExhaustEn_Auto[iN]:=FALSE;
				END_IF
			END_FOR
		
		
		
		
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO(*检查排风是否全部打开*)
				iAxisId:= i_aiGrpAxisList[iN];
				IF  axAirExhaustSwitch_In[iAxisId] =axAirExhaustEn_Out[iAxisId] THEN
					xAirExhaustDelayRunFinish:=TRUE;
				ELSE
					xAirExhaustDelayRunFinish:=FALSE;
					EXIT;
				END_IF
			END_FOR
		
			IF xAirExhaustDelayRunFinish THEN
				iAirExhaustDelayCount:=0;
			END_IF
			xAutoAirExhaustFlag:=TRUE;
		ELSIF xAutoAirExhaustFlag THEN
			xAutoAirExhaustFlag:=FALSE;
			iAirExhaustOpenSum:=0;
			iAirExhaustDelayCount:=0;
			xAirExhaustDelayRunFinish:=FALSE;
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO(*检查排风是否全部打开*)
				iAxisId:= i_aiGrpAxisList[iN];
				axAirExhaustEn_Out[iAxisId]:=FALSE;
				axAirExhaustEn_Auto[iN]:=FALSE;
				axPreBtnAirExhaustON[iN]:=FALSE;
			END_FOR
		END_IF
		
		
		(*MG增加功能2018.10.13.145554*)
		(*按钮控制排风起停*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iAxisId:= i_aiGrpAxisList[iN];
			IF axAirExhaustButton_In[iAxisId] AND NOT axPreAirExhaustRun[iN] THEN (*按钮上升沿，排风启动停止控制*)
				axAirExhaustEn_Out[iAxisId]:=NOT axAirExhaustEn_Out[iAxisId];(*切换排风使能状态*)
				IF axAirExhaustEn_Out[iAxisId] THEN
					iAirExhaustOpenSum:=iAirExhaustOpenSum+1;
				ELSE
					iAirExhaustOpenSum:=iAirExhaustOpenSum-1;
				END_IF
			ELSE;
			END_IF
			axPreAirExhaustRun[iN]:=axAirExhaustButton_In[iAxisId];
		END_FOR
		
		IF iAirExhaustOpenSum<0  THEN
			iAirExhaustOpenSum:=0;
		ELSIF iAirExhaustOpenSum>i_iGrpAxisNum_Pu THEN
			iAirExhaustOpenSum:=i_iGrpAxisNum_Pu;
		END_IF

(*2021.7.22.102550 这部分逻辑还没用*)
(*
		(*2020.11.12.112502 增加了排风的常用频率参数*)
		pstStSystemExtInfo:=ADR(i_pstStShmGlobalParam^.stStSystemExtInfo);
		byNormalFreq:=255;(*特殊值*)
		IF i_byNormalFrqIndex>=1 AND i_byNormalFrqIndex<=4 THEN
			IF i_byNormalFrqIndex=4 THEN
				byNormalFreq:=0;(*常用频率为0*)
			ELSE
				byNormalFreq:=pstStSystemExtInfo^.abyNormalFreq_ExhaustAir[i_byNormalFrqIndex];
			END_IF
		END_IF
		(*END----*)
*)

		(*处理排风频率输出逻辑|2020.11.2.152104*)
		(*参数合理化*)
		IF byFreqUpper_ExhaustAir_In=0 THEN
			byFreqUpper_ExhaustAir_In:=50;
		END_IF
		byFreqUpper:=byFreqUpper_ExhaustAir_In;
		IF uiFreqCoeff_Auto_ExhaustAir_In=0 THEN(*放大了100倍*)
			uiFreqCoeff_Auto_ExhaustAir_In:=100;
		END_IF
		rFreqCoeff:=UINT_TO_REAL(uiFreqCoeff_Auto_ExhaustAir_In)/100;


		byNormalFreq:=255;
		FOR iN:= 1 TO i_iGrpAxisNum_Pu BY 1 DO
			iAxisId:=i_aiGrpAxisList[iN];
			(*2020.11.12.113231 常用频率处理*)
			IF byNormalFreq=255 THEN(*不是更新状态|由上面处理成了写入一次状态*);
			ELSE(*更新频率*)
				abyFreq_ExhaustAir_In[iAxisId]:=byNormalFreq;
			END_IF
			(*End--*)

			(*2025.1.15.103152 处理*)
			(*pstStAxisParam^.byFreq_ExhaustAir 该值已经不再使用了,为了保证模拟量方式的输出,
			使用rHz_UnitExhaust_ManuallySet手动设置值执行输出频率*)
			abyFreq_ExhaustAir_In[iAxisId]:=REAL_TO_BYTE(arHz_UnitExhaust_ManuallySet_In[iAxisId]);(*2025.1.15.103238+*)

			byFreq:=abyFreq_ExhaustAir_In[iAxisId];
			(*频率=0|自动控制输出频率
			  频率<>0|根据该值输出*)
			IF byFreq<>0 THEN
				byFreqCur:=byFreq;
			ELSE(*根据当前速度变化*)
				IF i_rVel_Max<>0 THEN
					byFreqCur:=LREAL_TO_BYTE(i_rVel_Cur*rFreqCoeff/i_rVel_Max*byFreqMax_ExhaustAir_In);
					(*最小值判定|*)
					IF byFreqCur<byFreqMin_ExhaustAir_In THEN
						byFreqCur:=byFreqMin_ExhaustAir_In ;
					END_IF

					(*最大值判定|*)
					IF byFreqCur>byFreqMax_ExhaustAir_In THEN
						byFreqCur:=byFreqMax_ExhaustAir_In;
					END_IF
				ELSE(*按照最大频率输出*)
					byFreqCur:=byFreqMax_ExhaustAir_In;
				END_IF
			END_IF

			(*对当前频率的最大频率进行限制*)
			IF byFreqCur>byFreqUpper THEN
				byFreqCur:=byFreqUpper;
			END_IF


			(*当前频率赋值*)
			IF axAirExhaustEn_Out[iAxisId] OR (*排风启动了输出|否则输出频率=0*)
				(xAirExhaustFlag AND (iAxisId=31 OR iAxisId=32 OR iAxisId=29 OR iAxisId=30)) THEN (*全体排风有效了|牵引轴也输出频率*);
			ELSE
				byFreqCur:=0;
			END_IF
			abyFreqCur_ExhaustAir_Out[iAxisId]:=byFreqCur;
			(*输出排风变频电压*)
			awAO_AllExhBlower_Up_Out[iAxisId]:=
							LREAL_TO_WORD(BYTE_TO_LREAL(byFreqCur)/byFreqUpper*32767);
			awAO_AllExhBlower_Dn_Out[iAxisId]:=
							LREAL_TO_WORD(BYTE_TO_LREAL(byFreqCur)/byFreqUpper*32767);
		END_FOR

	
		
	ELSE
		o_iErNo:= -1;
	END_IF
END_IF