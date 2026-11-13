(*@CES
Name=Action_Actctl
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=fdbebdc1-b0c9-4de1-8ffb-4729292fbdae
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*2019.03.20.094116|检查*)
(*iColdWindOpenSum用于总开开启第一个时不延时*)
o_xEno:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	IF (i_iGrpAxisNum_Pu>=1 AND i_iGrpAxisNum_Pu<=MAX_UNIT_NUM) AND(*系的色组数量有效|*)
		i_pstStEvtReq<>0 AND
		i_PastStIOMap_Axis_Extra_FE<> 0THEN

		(*2023.09.11.082132*)
		FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
			
			(*预热风按钮旋钮处理*)
			IF i_xUseButton_PreHotBlower THEN
				IF axPreHotBlower_In[iN] AND NOT axLastPreHotBlower[iN] THEN(*检测按下沿*)
					axPreHotBlowerOpen[iN]:=NOT axPreHotBlowerOpen[iN];
				END_IF
			ELSE(*使用旋钮*)
				axPreHotBlowerOpen[iN]:=  axPreHotBlower_In[iN]  AND
												NOT axPreHotBlower_Err_In[iN];
			END_IF
			axLastPreHotBlower[iN]:= axPreHotBlower_In[iN] ;

			IF axPreHotBlowerOpen[iN] THEN(*打开了*)
				IF axPreHotBlower_Err_In[iN] OR(*预热风报错了*)
					i_xflag_Estop THEN (*急停了|取消打开使能*)
					axPreHotBlowerOpen[iUnitId]:=FALSE;
				END_IF
			END_IF


			(*预加热按钮旋钮处理*)
			IF i_xUseButton_PreHeating THEN
				IF axPreHeating_In[iN] AND NOT axLastPreHeating[iN] THEN(*检测按下沿*)
					axPreHeatingOpen[iN]:=NOT axPreHeatingOpen[iN];
				END_IF
			ELSE(*使用旋钮*)
				axPreHeatingOpen[iN]:= axPreHeating_In[iN] AND
												NOT axPreHeating_Err_In[iN];
			END_IF
			IF i_xflag_printPreHeating AND i_xflag_print THEN(*印刷时候自动打开预加热*)
				axPreHeatingOpen_Print[iN]:=TRUE;
			ELSE
				axPreHeatingOpen_Print[iN]:=FALSE(*TRUE*);(*2023.12.07.145206*)
			END_IF
			axPreHeatingOpen[iN]:=axPreHeatingOpen[iN] OR axPreHeatingOpen_Print[iN];


			axLastPreHeating[iN]:=axPreHeating_In[iN];

			IF axPreHeatingOpen[iN] THEN(*打开了*)
				IF axPreHeating_Err_In[iN] OR(*预热报错了*)
					i_xflag_Estop OR (*急停了|取消打开使能*)
					i_xMachineRev THEN(*反向走了不允许开预加热*)
					axPreHeatingOpen[iUnitId]:=FALSE;
				END_IF
			END_IF

			(*不再列表中的轴清除掉*)
			FOR iM:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iUnitId:=i_aiGrpAxisList[iM];
				IF iUnitId=iN THEN(*在列表中|*)
					EXIT;
				ELSE
					IF iM=i_iGrpAxisNum_Pu THEN
						axPreHotBlowerOpen[iUnitId]:=FALSE;
						axPreHeatingOpen[iUnitId]:=FALSE;
					END_IF
				END_IF
			END_FOR
		END_FOR


		(*预加热相关处理*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:= i_aiGrpAxisList[iN];
			
			IF axPreHotBlowerOpen[iUnitId]  THEN(*预热风输入有效 未报警*)
				axOutputRel_PreHotBlower[iUnitId]:=TRUE;(*输出预热风信号*)
				axOutputLamp_PreHotBlower[iUnitId]:=TRUE;
			ELSE
				axOutputRel_PreHotBlower[iUnitId]:=FALSE;(*输出预热风信号*)
				axOutputLamp_PreHotBlower[iUnitId]:=FALSE;(*预热风指示灯*)
			END_IF

			IF axOutputRel_PreHotBlower[iUnitId] THEN(*预热风信号输出有效*)
				IF axPreHeatingOpen[iUnitId]  THEN(*预加热输入信号有效,并且未报警*)(*预热报警信号也可作为温控输入标志使用*)
					axOutputRel_PreHeating[iUnitId]:=TRUE;(*预加热输出信号置位*)
					axOutputLamp_PreHeating[iUnitId]:=TRUE;(*预加热指示灯*)
				ELSE
					axOutputRel_PreHeating[iUnitId]:=FALSE;(*预加热输出信号置位*)
					axOutputLamp_PreHeating[iUnitId]:=FALSE;(*预加热指示灯*)
				END_IF
			ELSE
				axOutputRel_PreHeating[iUnitId]:=FALSE;(*预加热输出信号置位*)
				axOutputLamp_PreHeating[iUnitId]:=FALSE;(*预加热指示灯*)
			END_IF

		END_FOR
	ELSE
		o_iErNo:= -1;
	END_IF
END_IF