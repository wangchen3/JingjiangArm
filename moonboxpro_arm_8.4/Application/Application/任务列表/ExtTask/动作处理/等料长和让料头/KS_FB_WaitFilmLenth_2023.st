(*@CES
Name=KS_FB_WaitFilmLenth_2023
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=95d2fbf5-d878-4bd9-9c1a-e124bb4a65e6
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_WaitFilmLenth_2023
(*2023.08.07.155408 增加接口处理
数组索引使用联动轴还是色序轴*)
(*2025.2.18.153137 增加i_rWatiFilmLenth_Coeff 控制实际让料头的长度*)
VAR_INPUT
	i_xEn:BOOL;
	i_xWaitFilmLenthEn:BOOL;(*等料长使能条件@界面开关+印刷状态+至少合压一色@大条件i_xEn就是印刷状态*)
	i_pstStSysParam: POINTER TO StSysParam;
	i_rVel_Film:REAL;(*料膜速度*)
	i_iGrpLinkageAxisNum_Pu: INT; (* 系的色组联动轴数量|色组按照从小到大排序了 *)
	i_aiGrpLinkageAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT; (* 系的联动轴列表 *)
	i_xWaitFilmLenth_From1stLinkageAxis:BOOL;(* 等待整机料长标志@2023.3.7.150604*)
	i_iCycleTime_Plc:INT;
	i_xUseLinkageList:BOOL;(*默认使用色序轴|TRUE 使用联动轴*)
	(*2025.1.4.111759*)
	i_paxFlag_PressDne:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*实际压辊完成标志*)
	(*2025.2.18.152101+等料长的系数@等料长的长度*该值|实现的时候是通过按照改系数减小每个周期运动量来实现的*)
	i_rWatiFilmLenth_Coeff:REAL;
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;
	o_xWaitFilmLenthing:BOOL;
	o_xWaitFilmLenthEd:BOOL;
	o_axFlag_WaitFilmLenth:ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*等料长标志@支持等前一联动色和第一色*)
	o_arWaitFilmLenth:ARRAY [1..MAX_UNIT_NUM] OF REAL;(*需要等待的料长|开启后计算获得*)
	o_arMovingFilmLenth:ARRAY [1..MAX_UNIT_NUM] OF REAL;(*已经运动的料长|开启后计算获得*)
END_VAR
VAR
	iN: INT;
	iAxisId: INT;
	xWaitFilmLenthing:BOOL;(*等待料长中*)
	xWaitFilmLenthEd:BOOL;(*等待料长结束*)
	iPrevPressLinkageAxisId: INT;(*前一个联动合压轴id@修改名称*)
	i1stLinkageAxisId: INT;(*第一个联动轴id@2023.6.2.154952 有别的作用*)
	i1stPressLinkageAxisId: INT;(*第一个联动合压轴号@2023.6.2.154940修改名称*)
	axAxisWaitFilmLenthing:ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*轴等待料长中*)
	axAxisWaitFilmLenthEd:ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*轴等待料长结束*)
	axFlag_WaitFilmLenth:ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*等料长标志*)
	arWaitFilmLenth:ARRAY [1..MAX_UNIT_NUM] OF REAL;(*需要等待的料长值*)
	arFilmLenthInWaitFilmLenthSts:ARRAY [1..MAX_UNIT_NUM] OF REAL;(*等待的料长状态下已经走过的料长值*)
	xWaitFilmLenth_From1stLinkageAxis: BOOL;(*2023.3.7.150728*)
	lrCurCycleFilmDisplacement: LREAL;
	xRollerPressDneSts: BOOL;
	rPreReg_ConstVal: REAL;
	rFilmLenth: REAL;
	(*2023.08.07.155610*)
	iAxisNum_Total: INT;
	aiAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT;
	rFilmLenthWhenCurUnitPressDn: REAL;(*计算当前色在合压时距离前一色的料长@即使现在还未合压|2023.09.11.120015*)
	rWatiFilmLenth_Coeff: REAL;(*2025.2.18.152305+*)
END_VAR

{IMPLEMENTATION}
IF i_iCycleTime_Plc=0 THEN
	i_iCycleTime_Plc:=gc_TENSION_TSK_CYCLE_TIME;
END_IF
(*2025.2.18.152517+*)
rWatiFilmLenth_Coeff:=i_rWatiFilmLenth_Coeff;
IF rWatiFilmLenth_Coeff=0 THEN
	rWatiFilmLenth_Coeff:=1;
END_IF

lrCurCycleFilmDisplacement:= i_iCycleTime_Plc *i_rVel_Film / 60.0; (*单位:mm*)
(*每个周期运动的量/系数，意思就是说|实际走的距离是计算距离*系数@2025.2.18.152647*)
lrCurCycleFilmDisplacement:=lrCurCycleFilmDisplacement/rWatiFilmLenth_Coeff;

xWaitFilmLenth_From1stLinkageAxis:=i_xWaitFilmLenth_From1stLinkageAxis;(*等待方式@有效按照等待首色料长
																				@反之按照前一色等待料长*)

(*2023.08.07.155527 *)
IF i_xUseLinkageList THEN
	iAxisNum_Total:=i_iGrpLinkageAxisNum_Pu;
	aiAxisList:=i_aiGrpLinkageAxisList;
ELSE(*使用色序轴|生成色序轴列表*)
	iAxisNum_Total:=0;
	SysMemSet(ADR(aiAxisList),0,SIZEOF(aiAxisList));
	FOR iN:=1 TO i_iGrpLinkageAxisNum_Pu BY 1 DO(*在联动轴中找*)
		iAxisId:=i_aiGrpLinkageAxisList[iN];
		IF iAxisId>0 AND iAxisId<=MAX_UNIT_NUM THEN
			IF i_pstStSysParam^.astStUnitParam_UnSave[iAxisId].byColorIdCurrent>0 AND
			   i_pstStSysParam^.astStUnitParam_UnSave[iAxisId].byColorIdCurrent<=MAX_UNIT_NUM THEN(*色序合法*)
				iAxisNum_Total:=iAxisNum_Total+1;
				aiAxisList[iAxisNum_Total]:=iAxisId;
			END_IF
		END_IF
	END_FOR
END_IF

IF i_xEn THEN (*印刷状态*)
	IF i_xWaitFilmLenthEn THEN
		IF NOT xWaitFilmLenthEd THEN
			IF NOT xWaitFilmLenthing THEN
				xWaitFilmLenthing:=TRUE;
				FOR iN:=1 TO iAxisNum_Total BY 1 DO
					iAxisId:=aiAxisList[iN];(*取联动轴id*)
					IF iAxisId>0 AND iAxisId<=MAX_UNIT_NUM THEN(*ID合法*)

						IF iN<>1 THEN(*第一个联动轴不需要|即使第一个联动轴不是第一个印刷轴。那么第一个印刷轴
									等料长被置位也没关系因为它本来就不需要调整*)
							axFlag_WaitFilmLenth[iAxisId]:= TRUE; (*置位-开机等料长|*)
						END_IF
					END_IF
				END_FOR
			END_IF
		ELSE(*等料长结束了*)
			xWaitFilmLenthing:=FALSE;
		END_IF
	ELSE
		IF xWaitFilmLenthing THEN
			xWaitFilmLenthing:=FALSE;(*不再等待料长了*)
			xWaitFilmLenthEd:=TRUE;(*停止等料长*)
		END_IF
	END_IF

	IF NOT xWaitFilmLenthEd THEN(*没有等待结束*)
		i1stLinkageAxisId:=aiAxisList[1];
		FOR iN:=1 TO iAxisNum_Total BY 1 DO
			iAxisId:=aiAxisList[iN];(*取联动轴id*)
(*			xRollerPressDneSts:=i_pastStIOMap_AxisBasic^[iAxisId].o_xRel_Press;*)
			xRollerPressDneSts:=i_paxFlag_PressDne^[iAxisId];
	
			IF iAxisId>0 AND iAxisId<=MAX_UNIT_NUM THEN(*ID合法*)
				//pstStAxisParam:= ADR(i_pastStAxisParam^[iAxisId]);
				rPreReg_ConstVal:= LREAL_TO_REAL(i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_ConstVal);(*使用静态料长值*)

				IF xWaitFilmLenthing THEN(*等待料长中*)
					IF iN<>1 THEN(*第一个联动轴不需要等料长*)
						IF xWaitFilmLenth_From1stLinkageAxis THEN(*从第一个联动合压轴等待*)
							(*寻找第一个合压联动轴*)
							iPrevPressLinkageAxisId:=-1;
							(*2023.6.2.154753 调整名称@第一个合压联动轴*)
							i1stPressLinkageAxisId:=
								KS_Get1stPressLinkageAxisId(iAxisid,
									iAxisNum_Total,
									ADR(aiAxisList),
									i_paxFlag_PressDne);
							(*2023.6.2.155117*)
							IF i1stLinkageAxisId>0 AND
								i1stLinkageAxisId<=MAX_UNIT_NUM THEN(*第一个轴有效*)
								(*第一个合压的轴就是第一个联动的轴 *)
								IF i1stPressLinkageAxisId=i1stLinkageAxisId THEN;
								ELSE
									i1stPressLinkageAxisId:=-1;(*认为没找到*)
								END_IF
							ELSE
								i1stPressLinkageAxisId:=-1;(*就当没找到*)
							END_IF

						ELSE(*从前一个合压轴开始等待*)
							(*寻找前一个合压联动轴*)
							i1stPressLinkageAxisId:=-1;
							iPrevPressLinkageAxisId:=
								KS_GetPrevPressLinkageAxisId(iAxisid,
									iAxisNum_Total,
									ADR(aiAxisList),
									i_paxFlag_PressDne);
						END_IF

						IF iPrevPressLinkageAxisId=-1 AND i1stPressLinkageAxisId=-1 THEN
							(*没找到合压联动轴|
							此时等料长标志一直被置位但是如果长时间没找到虽然标志被置位但是该色能不能调整其实也没关系
							为了使得等料长功能能正常结束，简单点直接在超过88m/min的时候强制结束*)
							(*兼容等整机料长的情况上面的注释可能有些不准确了*)
							IF i_rVel_Film>=88 THEN
								axAxisWaitFilmLenthing[iAxisid]:=FALSE;
								axAxisWaitFilmLenthEd[iAxisid]:=TRUE;(*直接让他结束@不要等待了*)
							END_IF
						ELSE(*找到了 就启动吧*)
							IF NOT axAxisWaitFilmLenthEd[iAxisid] THEN(*没有等待结束*)
								axAxisWaitFilmLenthing[iAxisid]:=TRUE;(*此时启动等料长*)
							END_IF
						END_IF
					ELSE
						axAxisWaitFilmLenthing[iAxisid]:=FALSE;
						axAxisWaitFilmLenthEd[iAxisid]:=TRUE;
						arWaitFilmLenth[iAxisid]:=0;
					END_IF

					IF axAxisWaitFilmLenthing[iAxisid] THEN(*正在等料长呢*)
						IF iPrevPressLinkageAxisId<>-1 THEN(*跟前一色料长方式下找到了*)
							(*计算等待的料长|简单点直接使用色组间固定料长*间隔色组个数*)
	(*								rFilmLenth:=(iAxisid-iPrevPressLinkageAxisId)*rPreReg_ConstVal;*)
							rFilmLenth:=(*根据压辊状态计算料长值*)
								KS_CalcFilmLenth_Unit(iAxisid,
										iPrevPressLinkageAxisId,
										i_paxFlag_PressDne,
										i_pstStSysParam,
										ADR(rFilmLenthWhenCurUnitPressDn));(*2023.09.11.121509+*)
(*							IF arWaitFilmLenth[iAxisid]>rFilmLenth OR(*需要的长度更新为小值 更新当前值*)*)
							IF arWaitFilmLenth[iAxisid]>rFilmLenthWhenCurUnitPressDn OR(*需要的长度更新为小值 更新当前合压的料长值*)
								arWaitFilmLenth[iAxisid]=0 THEN(*刚开始*)
								arWaitFilmLenth[iAxisid]:=rFilmLenth;
								arFilmLenthInWaitFilmLenthSts[iAxisId]:=0;(*清除走过的距离值|重新计*)
							END_IF
						ELSIF i1stPressLinkageAxisId<>-1 THEN(*整机料长方式下找到了*)
							(*计算等待的料长|简单点直接使用色组间固定料长*间隔色组个数*)
	(*								rFilmLenth:=(iAxisid-i1stPressLinkageAxisId)*rPreReg_ConstVal;*)
							rFilmLenth:=(*根据压辊状态计算料长值*)
								KS_CalcFilmLenth_Unit(iAxisid,
										i1stPressLinkageAxisId,
										i_paxFlag_PressDne,
										i_pstStSysParam,0);
							IF arWaitFilmLenth[iAxisid]<rFilmLenth OR(*需要的长度更新为大值 更新当前值*)
								arWaitFilmLenth[iAxisid]=0 THEN(*刚开始*)
								arWaitFilmLenth[iAxisid]:=rFilmLenth;
								arFilmLenthInWaitFilmLenthSts[iAxisId]:=0;(*清除走过的距离值|重新计*)
							END_IF
						END_IF


(*						arFilmLenthInWaitFilmLenthSts[iAxisId]:=(*统计已经走过的距离*)
										arFilmLenthInWaitFilmLenthSts[iAxisId]+lrCurCycleFilmDisplacement;*)

						arFilmLenthInWaitFilmLenthSts[iAxisId]:=(*统计已经走过的距离*)
										LREAL_TO_REAL(arFilmLenthInWaitFilmLenthSts[iAxisId]+lrCurCycleFilmDisplacement);
						IF arFilmLenthInWaitFilmLenthSts[iAxisId]>=arWaitFilmLenth[iAxisid] THEN(*超过等待值|就认为结束了*)
							axAxisWaitFilmLenthing[iAxisid]:=FALSE;
							axAxisWaitFilmLenthEd[iAxisid]:=TRUE;(*等待结束了*)
						END_IF
					ELSE(*
						arFilmLenthInWaitFilmLenthSts[iAxisId]:=0;
						arWaitFilmLenth[iAxisid]:=0;*);
					END_IF
				ELSE(*退出等料长状态了 处理所有轴的标志*)
					IF axAxisWaitFilmLenthing[iAxisid] THEN
						axAxisWaitFilmLenthing[iAxisid]:=FALSE;
						axAxisWaitFilmLenthEd[iAxisid]:=TRUE;(*等待结束了*)
					END_IF
				END_IF

				(*检查所有的等料长已经结束了*)
				IF iN=1 THEN
					xWaitFilmLenthEd:=axAxisWaitFilmLenthEd[iAxisid];
				ELSE
					xWaitFilmLenthEd:=xWaitFilmLenthEd AND axAxisWaitFilmLenthEd[iAxisid];(*所有轴等料长标志复位*)
				END_IF
			END_IF
		END_FOR
	ELSE(*等待结束了*)
		FOR iN:=1 TO iAxisNum_Total BY 1 DO
			iAxisId:=aiAxisList[iN];(*取联动轴id*)
			IF iAxisId>0 AND iAxisId<=MAX_UNIT_NUM THEN(*ID合法*)
				axAxisWaitFilmLenthing[iAxisid]:=FALSE;
				axAxisWaitFilmLenthEd[iAxisid]:=TRUE;(*等待结束了*)
			END_IF
		END_FOR
		iPrevPressLinkageAxisId:=-1;
		i1stPressLinkageAxisId:=-1;
	END_IF

	(*处理等料长标志*)
	FOR iN:=1 TO iAxisNum_Total BY 1 DO
		iAxisId:=aiAxisList[iN];(*取联动轴id*)
		IF iAxisId>0 AND iAxisId<=MAX_UNIT_NUM THEN(*ID合法*)
			IF axAxisWaitFilmLenthEd[iAxisid] THEN(*等待结束了 清除控制标志*)
				axFlag_WaitFilmLenth[iAxisId]:= FALSE; (*清除-开机等料长*)
			END_IF
		END_IF
	END_FOR
ELSE
	xWaitFilmLenthing:=FALSE;(*2023.2.26.215717 重新使用变量处理等料长逻辑*)
	xWaitFilmLenthEd:=FALSE;(*2023.2.26.230418*)
	iPrevPressLinkageAxisId:=-1;
	i1stPressLinkageAxisId:=-1;

	FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
		axFlag_WaitFilmLenth[iN]:= FALSE; (*清-开机等料长*)

		arWaitFilmLenth[iN]:=0;
		arFilmLenthInWaitFilmLenthSts[iN]:=0;
		axAxisWaitFilmLenthing[iN]:=FALSE;
		axAxisWaitFilmLenthEd[iN]:=FALSE;
		axFlag_WaitFilmLenth[iN]:=FALSE;
	END_FOR
END_IF

o_xWaitFilmLenthing:=xWaitFilmLenthing;
o_xWaitFilmLenthEd:=xWaitFilmLenthEd;
o_axFlag_WaitFilmLenth:=axFlag_WaitFilmLenth;
o_axFlag_WaitFilmLenth:=axFlag_WaitFilmLenth;
o_arWaitFilmLenth:=arWaitFilmLenth;
o_arMovingFilmLenth:=arFilmLenthInWaitFilmLenthSts;