(*@CES
Name=KS_GetAxisInitPhaseWhenPreRegister
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=f2256f17-a4f2-4244-aed7-c9a2efcbad83
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetAxisInitPhaseWhenPreRegister : BOOL
(*只处理了联动轴的*)
(*预套准时轴的初始相位初始位置处理方法|默认就是手动转动*)
VAR_INPUT
	i_byAxisInitPhaseTypeWhenPreRegister:BYTE;(*预套准时轴初始相位方式选择|默认手动转到mark线位置|=1 自动记忆初始相位解放双手*)
	i_xFlag_CanSaveData:BOOL;(*可以保存数据标志@只有再type=1时起作用*)
	(*一些按钮输入@需要外部清零作为沿触发*)
	i_xBtn_SaveAllData:BOOL;(*全部保存*)
	i_xBtn_SaveProtionData:BOOL;(*部分保存*)
	i_xBtn_SaveCancel:BOOL;(*取消按钮*)
	i_xBtn_DisHmi:BOOL;(*界面显示按钮*)
	(*轴的一些参数*)
	i_iGrpAxisNum_Pu: INT;(*色组轴的数量|*)
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT;(*系内所有轴的id列表,色组部分已经按照从小到大的顺序排序了，之后的是牵引|*)
	i_pstStSysParam: POINTER TO StSysParam;
//	i_pastStPTSts: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StPTSts;(*PT运动轴的状态|*)
	(*一些状态输出*)
	i_pxInitPhaseHmiSts:POINTER TO BOOL;(*初始相位操作界面状态标志位*)
	i_pxFlag_SaveAll:POINTER TO BOOL;(*全部保存标志*)
	i_pxFlag_SaveProtion:POINTER TO BOOL;(*部分保存标志*)
END_VAR
VAR
	iN: INT;
	iUnitId: INT;
//	pstStPTSts: POINTER TO StPTSts;(*PT运动轴的状态|*)
	xInitPhaseHmiSts: BOOL;
	xFlag_SaveAll: BOOL;
	xFlag_SaveProtion: BOOL;

	axInitPhaseValid:ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*初始相位有效*)
	axNeedUpdate:ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*需要更新的标志*)
	axUpdateDne:ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*更新完成的标志*)
	axUpdateFailed:ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*更新失败的标志*)
	xUpdateData: BOOL;(*更新数据标志*)
	xUpdateDne: BOOL;(*更新完成*)
	xFlag_CanSaveData: BOOL;(*可以保存数据*)
	xResetAxisFlag: BOOL;
END_VAR
{IMPLEMENTATION}
IF i_pxInitPhaseHmiSts<>0 THEN
	xInitPhaseHmiSts:=i_pxInitPhaseHmiSts^;
END_IF
IF i_pxFlag_SaveAll<>0 THEN
	xFlag_SaveAll:=i_pxFlag_SaveAll^;
END_IF
IF i_pxFlag_SaveProtion<>0 THEN
	xFlag_SaveProtion:=i_pxFlag_SaveProtion^;
END_IF

xFlag_CanSaveData:=i_xFlag_CanSaveData;

IF i_pstStSysParam<>0 THEN
	CASE i_byAxisInitPhaseTypeWhenPreRegister OF
		1:(*自动记忆初始相位解放双手*)

			(*获取状态位*)
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1DO
				iUnitId:=i_aiGrpAxisList[iN];
				
				axInitPhaseValid[iUnitId]:=i_pstStSysParam^.astStUnitParam_Save[iUnitId].byPhaseState.0;
				axNeedUpdate[iUnitId]:=i_pstStSysParam^.astStUnitParam_Save[iUnitId].byPhaseState.1;
				axUpdateDne[iUnitId]:=i_pstStSysParam^.astStUnitParam_Save[iUnitId].byPhaseState.4;
				axUpdateFailed[iUnitId]:=i_pstStSysParam^.astStUnitParam_Save[iUnitId].byPhaseState.5;
			END_FOR

			(*按钮处理|*)
			IF NOT xFlag_SaveAll AND
				NOT xFlag_SaveProtion THEN(*存储标志无效的时候检测按钮输入*)
				(*全部更新按钮@保证互斥*)
				IF i_xBtn_SaveAllData THEN
					xFlag_SaveAll:=TRUE;
					xResetAxisFlag:=TRUE;(*复位轴标志@重新开始*)
				END_IF
				(*部分更新按钮@保证互斥*)
				IF NOT xFlag_SaveAll THEN
					IF i_xBtn_SaveProtionData THEN
						xFlag_SaveProtion:=TRUE;
						xResetAxisFlag:=TRUE;(*复位轴标志@重新开始*)
					END_IF
				END_IF
			END_IF

			(*界面显示按钮*)
			IF i_xBtn_DisHmi THEN
				xInitPhaseHmiSts:=TRUE;(*界面显示*)
			END_IF
			(*取消按钮*)
			IF i_xBtn_SaveCancel THEN
				xInitPhaseHmiSts:=FALSE;(*取消界面*)
			END_IF


			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1DO
				iUnitId:=i_aiGrpAxisList[iN];
				
				(*判断当前轴是否保存过初始版辊位置*)
				IF i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_InstallPlate<>0 THEN
					axInitPhaseValid[iUnitId]:=TRUE;
				ELSE
					axInitPhaseValid[iUnitId]:=FALSE;
				END_IF

				(*逻辑处理*)
				xUpdateData:=FALSE;
				IF xFlag_SaveAll THEN(*全部更新@2023.10.14.162459*)
					IF i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage THEN(*只要是联动的就更新*)
						xUpdateData:=TRUE;
						axNeedUpdate[iUnitId]:=TRUE;(*需要更新标志*)
					ELSE
						axNeedUpdate[iUnitId]:=FALSE;(*清除标志*)
					END_IF
				ELSIF xFlag_SaveProtion THEN(*部分更新@2023.10.14.162456*)
					IF i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage AND
						(NOT axInitPhaseValid[iUnitId]) THEN(*没有保存的进行更新*)
						xUpdateData:=TRUE;
						axNeedUpdate[iUnitId]:=TRUE;(*需要更新标志*)
					ELSE
						axNeedUpdate[iUnitId]:=FALSE;(*清除标志*)
					END_IF
				ELSE(*更新完了\不需要更新|清除一些标志*)
					axNeedUpdate[iUnitId]:=FALSE;(*清除标志*)
				END_IF


				IF NOT xInitPhaseHmiSts OR (*界面关闭的时候清除标志位*)
					xResetAxisFlag THEN(*重新开始*)
					axUpdateDne[iUnitId]:=FALSE;(*更新成功标志清除*)
					axUpdateFailed[iUnitId]:=FALSE;(*更新失败标志清除*)
				END_IF

				IF axUpdateDne[iUnitId] OR(*更新成功|都不再更新*)
					axUpdateFailed[iUnitId] THEN(*更新失败|都不再更新*)
					xUpdateData:=FALSE;
				END_IF

				(*需要更新位置*)
				IF xUpdateData THEN
					IF xFlag_CanSaveData THEN(*可以保存数据*)
						i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_InstallPlate:=
								KS_GetPhaseValue(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wVirTual_Cnt,gc_iVirEncPPR);
						IF i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_InstallPlate=0 THEN(*保证保存的值非零*)
							i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_InstallPlate:=1;
						END_IF
						(*非法值判断*)
						IF i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_InstallPlate>0 AND
							i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_InstallPlate<gc_iVirEncPPR THEN(*值合法*)
							axUpdateDne[iUnitId]:=TRUE;(*更新完成*)
						ELSE
							axUpdateFailed[iUnitId]:=TRUE;(*更新失败*)
						END_IF
					ELSE(*不能保存数据|置位失败标志*)
						axUpdateFailed[iUnitId]:=TRUE;(*更新失败*)
					END_IF
				END_IF

			END_FOR

			(*处理整机标志位*)
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1DO
				iUnitId:=i_aiGrpAxisList[iN];
				
				xUpdateDne:=(axUpdateDne[iUnitId] OR axUpdateFailed[iUnitId]);
				IF xFlag_SaveAll OR(*全部更新*)
					xFlag_SaveProtion(*部分更新*)THEN
					IF axNeedUpdate[iUnitId] THEN
						IF xUpdateDne THEN(*更新完成了*);
						ELSE
							EXIT;
						END_IF
					END_IF

					IF iN=i_iGrpAxisNum_Pu THEN(*能走到这里说明都完成了*)
						xFlag_SaveAll:=FALSE;
						xFlag_SaveProtion:=FALSE;
					END_IF
				END_IF
			END_FOR

			(*输出状态位*)
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1DO
				iUnitId:=i_aiGrpAxisList[iN];
				i_pstStSysParam^.astStUnitParam_Save[iUnitId].byPhaseState.0:=axInitPhaseValid[iUnitId];
				i_pstStSysParam^.astStUnitParam_Save[iUnitId].byPhaseState.1:=axNeedUpdate[iUnitId];
				i_pstStSysParam^.astStUnitParam_Save[iUnitId].byPhaseState.4:=axUpdateDne[iUnitId];
				i_pstStSysParam^.astStUnitParam_Save[iUnitId].byPhaseState.5:=axUpdateFailed[iUnitId];
				(*清除无效位*)
				i_pstStSysParam^.astStUnitParam_Save[iUnitId].byPhaseState.2:=FALSE;
				i_pstStSysParam^.astStUnitParam_Save[iUnitId].byPhaseState.3:=FALSE;
				i_pstStSysParam^.astStUnitParam_Save[iUnitId].byPhaseState.6:=FALSE;
				i_pstStSysParam^.astStUnitParam_Save[iUnitId].byPhaseState.7:=FALSE;
			END_FOR

			IF NOT xInitPhaseHmiSts THEN(*界面关闭的时候清除标志位*)
				xFlag_SaveAll:=FALSE;
				xFlag_SaveProtion:=FALSE;
			END_IF
	ELSE(*默认方案*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1DO
			iUnitId:=i_aiGrpAxisList[iN];

(*这里就不清零@2025.1.12.175804
KS_ReloadPreRegValue 这里加了大条件*)
(*			pstStAxisParam^.iPhase_InstallPlate:=0;(*清零这个值*)*)
			(*一些参数清除*)
			i_pstStSysParam^.astStUnitParam_Save[iUnitId].byPhaseState:=0;
		END_FOR
		xInitPhaseHmiSts:=FALSE;(*取消界面*)
		xFlag_SaveAll:=FALSE;(*全部保存标志*)
		xFlag_SaveProtion:=FALSE;(*部分保存标志*)
	END_CASE
END_IF


(*状态输出*)
IF i_pxInitPhaseHmiSts<>0 THEN
	i_pxInitPhaseHmiSts^:=xInitPhaseHmiSts;
END_IF
IF i_pxFlag_SaveAll<>0 THEN
	i_pxFlag_SaveAll^:=xFlag_SaveAll;
END_IF
IF i_pxFlag_SaveProtion<>0 THEN
	i_pxFlag_SaveProtion^:=xFlag_SaveProtion;
END_IF