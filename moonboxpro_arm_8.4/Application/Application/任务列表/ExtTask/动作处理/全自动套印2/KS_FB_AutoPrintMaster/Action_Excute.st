(*@CES
Name=Action_Excute
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=dcddb0f4-691e-4fe4-b068-13c425806964
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*按照调整顺序*)
(*写入到快速对版调整量中*)
IF xCalculationCompleted THEN
	(*2026.3.26.213909+调整量处理@按照快速对版逻辑 by liu.yt*)
	(*从前向后处理AND从后向前*)
	(*处理合压个数*)
	IF i_byAxisNum>=2 THEN(*个数超过2个才处理*)
		iNeedFastAdjAxisNum:= i_byAxisNum - 1;
		IF iNeedFastAdjAxisNum >= 3 THEN
			iAxisNum_1TO2 := (iNeedFastAdjAxisNum + 1) / 2;(*从前向后压的个数@+1 奇数个时从前向后压多一个*)
			iAxisNum_2TO1 := (iNeedFastAdjAxisNum) - iAxisNum_1TO2;(*剩下的从后向前*)
		ELSE(*2个或者一个就顺序处理@从前向后*)
			iAxisNum_1TO2:=iNeedFastAdjAxisNum;
			iAxisNum_2TO1 := 0;
		END_IF
	ELSE
		iAxisNum_1TO2 := 0;
		iAxisNum_2TO1 := 0;
	END_IF
	(*生成从前向后的列表*)
	iIndexTmp:=0;
	sysmemset(ADR(aiAxisIdList_FastAdj_1TO2),0,SIZEOF(aiAxisIdList_FastAdj_1TO2));(*复位列表*)
	IF iAxisNum_1TO2<>0 THEN
		FOR iN:=2 TO i_byAxisNum BY 1 DO (*从第2个列表轴开始统计*)
			iAxisId:= i_aiAxisList[iN];
			iIndexTmp:=iIndexTmp+1;
			aiAxisIdList_FastAdj_1TO2[iIndexTmp]:=iAxisId;
			IF iIndexTmp = iAxisNum_1TO2 THEN(*足够了就不要了*)
				EXIT;
			END_IF
		END_FOR
	END_IF
	(*生成从后向前的列表*)
	iIndexTmp:=0;
	sysmemset(ADR(aiAxisIdList_FastAdj_2TO1),0,SIZEOF(aiAxisIdList_FastAdj_2TO1));(*复位列表*)
	IF iAxisNum_2TO1<>0 THEN
		FOR iN:=i_byAxisNum TO 2 BY -1 DO (*从第最后一个列表轴开始统计*)
			iAxisId:= i_aiAxisList[iN];
			iIndexTmp:=iIndexTmp+1;
			aiAxisIdList_FastAdj_2TO1[iIndexTmp]:=iAxisId;
			IF iIndexTmp = iAxisNum_2TO1 THEN(*足够了就不要了*)
				EXIT;
			END_IF
		END_FOR
	END_IF
	
	(*启动*)
	iIndex1TO2:=0;
	IF iAxisNum_1TO2<>0 THEN(*需要处理*)
		iIndex1TO2:=1;
	END_IF
	iIndex2TO1:=0;
	IF iAxisNum_2TO1<>0 THEN(*需要处理*)
		iIndex2TO1:=1;
	END_IF
	xCalculationCompleted:=false;
END_IF

(*执行快速调整逻辑@按道理在计算完成后处理*)
(*从前向后处理*)
IF iIndex1TO2<>0 THEN(*有需要压辊*)
	IF iIndex1TO2 <= iAxisNum_1TO2 THEN
		iAxisId:= aiAxisIdList_FastAdj_1TO2[iIndex1TO2];
		xCanFastAdj:=TRUE;
		IF iIndex2TO1<>0 THEN(*从后向前有压辊执行*)
			IF iIndex1TO2 = iAxisNum_1TO2 THEN(*最后一个|观察下从后往前的压辊状态*)
				IF iIndex2TO1 > iAxisNum_2TO1 THEN(*处理完了*)
					;(*从前向后继续处理*)
				ELSIF iIndex2TO1 = iAxisNum_2TO1 THEN(*正在处理从后向前的最后一个*)
					iAxisIdTmp := aiAxisIdList_FastAdj_2TO1[iIndex2TO1];(*获取后面处理的轴id*)
					IF  axAdjust_ing[iAxisIdTmp] THEN
						xCanFastAdj:=FALSE;(*先等等！*)
					ELSE(*不调整我就开始了*)
						;
					END_IF
				ELSE(*还未处理到最后一个,继续处理*)
					;
				END_IF
			END_IF
		END_IF
		IF xCanFastAdj THEN (*可以快速对版标志*)
			IF o_arAdjPos_um[iAxisId]<>0 THEN
				IF NOT axAdjust_ing[iAxisId] THEN(*不在调整中*)
					(*写入到快速对版列表中*)
					KS_PushRapidAdjValue_V(i_pastStAxisRapidAdjProf_V, iAxisId, LREAL_TO_DINT(o_arAdjPos_um[iAxisId]));
					axAdjust_ing[iAxisId]:=TRUE;(*//置位调整中*)
				ELSE(*处于调整中的时候等待调整完成。*)
					IF NOT axFastAdjing[iAxisId] THEN(*等待快速对版中*)
						IF i_abyRapidAdjustStep[iAxisId]<>0 THEN
							axFastAdjing[iAxisId]:=TRUE;
						END_IF
					ELSE(*处于快速对版中|等待结束*)
						IF i_abyRapidAdjustStep[iAxisId]=0 THEN(*当前色处理完了*)
							axAdjust_finish[iAxisId]:=TRUE;
							axFastAdjing[iAxisId]:=FALSE;
							(*切换到下一色*)
							iIndex1TO2:=iIndex1TO2+1;
						END_IF
					END_IF
				END_IF
			ELSE(*没调整量就认为完成了*)
				axAdjust_finish[iAxisId]:=TRUE;
				(*切换到下一色*)
				iIndex1TO2:=iIndex1TO2+1;
			END_IF
		END_IF
	ELSE(*处理完了*)
		;
	END_IF
END_IF

(*从后向前处理*)
IF iIndex2TO1<>0 THEN(*有需要压辊*)
	IF iIndex2TO1 <= iAxisNum_2TO1 THEN
		iAxisId:= aiAxisIdList_FastAdj_2TO1[iIndex2TO1];
		xCanFastAdj:=TRUE;
		IF iIndex1TO2<>0 THEN(*从前向后有压辊执行*)
			IF iIndex2TO1 = iAxisNum_2TO1 THEN(*最后一个|观察下从前往后的压辊状态*)
				IF iIndex1TO2 > iAxisNum_1TO2 THEN(*处理完了*)
					;(*从后向前继续处理*)
				ELSIF iIndex1TO2 = iAxisNum_1TO2 THEN(*正在处理从前向后的最后一个*)
					iAxisIdTmp := aiAxisIdList_FastAdj_1TO2[iIndex1TO2];(*获取前面处理的轴id*)
					IF  axAdjust_ing[iAxisIdTmp] THEN
						xCanFastAdj:=FALSE;(*先等等！*)
					ELSE(*不调整我就开始了*)
						;
					END_IF
				ELSE(*还未处理到最后一个,继续处理*)
					;
				END_IF
			END_IF
		END_IF
		IF xCanFastAdj THEN (*可以快速对版标志*)
			IF o_arAdjPos_um[iAxisId]<>0 THEN
				IF NOT axAdjust_ing[iAxisId] THEN(*不在调整中*)
					(*写入到快速对版列表中*)
					KS_PushRapidAdjValue_V(i_pastStAxisRapidAdjProf_V, iAxisId, LREAL_TO_DINT(o_arAdjPos_um[iAxisId]));
					axAdjust_ing[iAxisId]:=TRUE;(*置位调整中*)
				ELSE(*处于调整中的时候等待调整完成。*)
					IF NOT axFastAdjing[iAxisId] THEN(*等待快速对版中*)
						IF i_abyRapidAdjustStep[iAxisId]<>0 THEN
							axFastAdjing[iAxisId]:=TRUE;
						END_IF
					ELSE(*处于快速对版中|等待结束*)
						IF i_abyRapidAdjustStep[iAxisId]=0 THEN(*当前色处理完了*)
							axAdjust_finish[iAxisId]:=TRUE;
							axFastAdjing[iAxisId]:=FALSE;
							(*切换到下一色*)
							iIndex2TO1:=iIndex2TO1+1;
						END_IF
					END_IF
				END_IF
			ELSE(*没调整量就认为完成了*)
				axAdjust_finish[iAxisId]:=TRUE;
				(*切换到下一色*)
				iIndex2TO1:=iIndex2TO1+1;
			END_IF
		END_IF
	ELSE(*处理完了*)
		;
	END_IF
END_IF
(*END********************************)

xAllAdjust_finish:= TRUE;
FOR iN:=2 TO i_byAxisNum BY 1 DO
	iAxisId:= i_aiAxisList[iN];
	IF NOT axAdjust_finish[iAxisId] THEN
		xAllAdjust_finish:= FALSE;
		byMeanANDAutoChangeCnt:=0;
		EXIT;
	END_IF
END_FOR

