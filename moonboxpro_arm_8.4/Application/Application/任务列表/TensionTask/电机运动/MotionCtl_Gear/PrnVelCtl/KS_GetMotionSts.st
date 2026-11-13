(*@CES
Name=KS_GetMotionSts
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=c01ac71d-e678-459d-bed7-b9a659b9ae68
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetMotionSts : BOOL(*色组轴的运动状态处理|只在开机时候使用 同时控制压辊合压状态|Liu.yt
										轴运动状态标志|0:同步运动状态. 
													  |1:同步运动时停止运动状态.
													  |2:停止运动状态
													  |3:停止运动时加速到单运行速度状态.
													  |4:单运行时减速到停止状态.
													  |5:停止运动时或者使用单运行速度运行时加速到同步运动状态.
													  |6:非同步运动时急停到0状态.
													  |7:非同步运动时空转停机到0状态.*)
(*2022.9.21.154927 6,7步中停止的条件判断写错了*)
(*2022.11.29.232720 轴速度是带方向|作为条件需要增加取绝对值*)
(*2023.11.27.165212 增加印刷是否能切换单联动的选择输入接口*)
VAR_INPUT
	i_iGrpId: INT;	
	i_xMotionStsSwitchEn:BOOL;(*切换使能|使用该功能需要常有效*)
	i_bySwitchType:BYTE;(*切换方式|0-空转状态下不考虑单联动状态下都可以切换运动状态
								  |1-空转状态下只有处于联动状态下的轴可以切换*)
	i_iGrpAxisNum_Pu: INT; (*色组轴数量*)
	i_pstStSysParam: POINTER TO StSysParam;
//	i_pstStGrpParam: POINTER TO StGrpParam;(*系参数访问入口|*)
	i_paiGrpAxisList: POINTER TO ARRAY [1..MAX_STATION_NUM] OF INT; (*系内所有轴的列表*)
//	i_pastStAxisParam: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StAxisParam;
	i_pastStIOMap_Main_FE						: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|AB系*)
	i_pastStIOMap_Axis_FE					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|`````````````````````````````````````````````*)
//	i_pastStIOMap_AxisBasic: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StIOMap_AxisBasic;(*基础io映射表|*)
	i_pabyAxisMotionSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF BYTE;(*轴运动状态|*)
	i_paxAxisInching:POINTER TO ARRAY [1..MAX_STATION_NUM] OF BOOL;(*轴在单运行|用于控制单运行指示灯显示*)
	i_paxLastAxisInchBtn:POINTER TO ARRAY [1..MAX_STATION_NUM] OF BOOL;(*轴的单运行按钮保留值|用于判断沿*)
	i_iMaxVel_StsSwitch:INT;(*状态切换的最大速度*)
	i_pxFlag_StsSwitchEn:POINTER TO BOOL;(*状态切换使能标志@内部的状态切换标志*)
	i_xChangLinkageStsWhenPrint:BOOL;(*印刷时候可以切换单联动@2023.11.27.164606*)
END_VAR
VAR

	iN: INT;
	xFlag_StsSwitchEn: BOOL;(*状态切换标志*)
	xStsSwitchEn: BOOL;(*状态切换使能*)
	xRetainStsEn: BOOL;(*保持状态标志*)
	iUnitId: INT;
	byAxisMotionSts: BYTE;
	xLastAxisInchBtn: BOOL;
	xAxisInching: BOOL;
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;
	pstStGrpParam_Save: POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave: POINTER TO StGrpParam_UnSave;
	pstStIOMap_Axis_FE: POINTER TO StIOMap_Axis_FE;
	xCanSwitchSts_CurAxis: BOOL;(*当前轴可以切换状态标志*)
	dwAxisMotionStsNotOk: DWORD;
END_VAR
{IMPLEMENTATION}
IF i_pstStSysParam<>0 AND
	i_paiGrpAxisList<>0 AND
	i_pastStIOMap_Main_FE<>0 AND
	i_pastStIOMap_Axis_FE<>0 AND
	i_pabyAxisMotionSts<>0 AND
	i_paxAxisInching<>0 AND
	i_paxLastAxisInchBtn<>0 AND
	i_iGrpAxisNum_Pu>0 AND
	i_pxFlag_StsSwitchEn<>0 THEN(*参数合法*)

	xFlag_StsSwitchEn:=i_pxFlag_StsSwitchEn^;
	pstStGrpParam_Save:= ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
	pstStGrpParam_UnSave:= ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
	(*2023.11.27.171042 增加了印刷时候有单联动切换的选择接口*)
	xStsSwitchEn:= (pstStGrpParam_UnSave^.xFlag_Ink OR(*空转状态下可以使用|*)
					(pstStGrpParam_UnSave^.xFlag_Print AND i_xChangLinkageStsWhenPrint)) AND
					pstStGrpParam_UnSave^.rVel_Cur<=i_iMaxVel_StsSwitch;(*小于速度限制可以使用*)
	(*印刷时候或者超过限制速度时候|与xStsSwitchEn搭配使用*)
	xRetainStsEn:=(pstStGrpParam_UnSave^.xFlag_Print AND NOT i_xChangLinkageStsWhenPrint)
				OR pstStGrpParam_UnSave^.rVel_Cur>i_iMaxVel_StsSwitch;


	(*切换条件处理*)
	IF  xStsSwitchEn THEN
		xFlag_StsSwitchEn:=TRUE;
	END_IF

	IF i_xMotionStsSwitchEn THEN
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:=i_paiGrpAxisList^[iN];
			pstStUnitParam_Save:=ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
			pstStUnitParam_UnSave:=ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
			pstStIOMap_Axis_FE:=ADR(i_pastStIOMap_Axis_FE^[iUnitId]);
			byAxisMotionSts:=i_pabyAxisMotionSts^[iUnitId];
			xLastAxisInchBtn:=i_paxLastAxisInchBtn^[iUnitId];
			xAxisInching:=i_paxAxisInching^[iUnitId];

			xCanSwitchSts_CurAxis:=FALSE;
			IF i_bySwitchType=0 THEN(*空转状态下不考虑单联动状态下都可以切换运动状态*)
				xCanSwitchSts_CurAxis:= pstStUnitParam_UnSave^.xMoveEnable_Motor;
			ELSIF i_bySwitchType=1 THEN(*空转状态下只有处于联动状态下的轴可以切换*)
				xCanSwitchSts_CurAxis:= pstStUnitParam_Save^.xLinkage;
			END_IF

			IF xCanSwitchSts_CurAxis THEN
				CASE byAxisMotionSts OF
					0:(*同步运动状态|此时检查但联动旋钮的状态*)
						IF NOT pstStIOMap_Axis_FE^.i_xLinkage AND (*切换到单动状态*)
							NOT pstStIOMap_Axis_FE^.o_xRel_Press THEN(*压辊未合压时起作用*)
							byAxisMotionSts:=1;
						END_IF
					1:(*处于停止运动过程状态|等待到达停止运动状态*)
						IF pstStIOMap_Axis_FE^.i_xLinkage THEN(*联动状态|恢复到同步运动状态*)
							byAxisMotionSts:=5;
						END_IF

						IF byAxisMotionSts=1 THEN
							IF ABS(pstStUnitParam_UnSave^.rAxisVel_PrnRoller)<=0.0001 THEN(*减速到0我们认为到达了停止运动状态*)
								byAxisMotionSts:=2;
							END_IF
						END_IF
					2:(*停止运动状态*)
						IF pstStIOMap_Axis_FE^.i_xLinkage THEN(*联动状态|恢复到同步运动状态*)
							byAxisMotionSts:=5;
						END_IF

						(*检查单运行是否按下*)
						IF byAxisMotionSts=2 THEN
							IF pstStIOMap_Axis_FE^.i_xInch AND NOT xLastAxisInchBtn THEN(*单运行按下了*)
								byAxisMotionSts:=3;
							END_IF
						END_IF

					3:(*加速到单运行状态*)
						IF pstStIOMap_Axis_FE^.i_xLinkage THEN(*联动状态|恢复到同步运动状态*)
							byAxisMotionSts:=5;
						END_IF

						IF byAxisMotionSts=3 THEN
							IF (pstStIOMap_Axis_FE^.i_xInch AND NOT xLastAxisInchBtn) OR(*单运行按下了*)
								NOT xStsSwitchEn THEN(*退出了状态*)
								byAxisMotionSts:=4;
							END_IF
						END_IF
					4:(*单运行状态停止到停止状态*)
						IF pstStIOMap_Axis_FE^.i_xLinkage THEN(*联动状态|恢复到同步运动状态*)
							byAxisMotionSts:=5;
						END_IF

						IF byAxisMotionSts=4 THEN
							IF ABS(pstStUnitParam_UnSave^.rAxisVel_PrnRoller)<=0.0001 THEN(*减速到0我们认为到达了停止运动状态*)
								byAxisMotionSts:=2;
							END_IF
						END_IF
					5:(*前往同步运动状态*)
						IF NOT pstStIOMap_Axis_FE^.i_xLinkage THEN(*切换到单动状态*)
							byAxisMotionSts:=1;
						END_IF

						IF byAxisMotionSts=5 THEN
							IF ABS(ABS(pstStUnitParam_UnSave^.rAxisVel_PrnRoller)-pstStGrpParam_UnSave^.rVel_Cur)<=0.0001 THEN(*到达当前速度*)
								byAxisMotionSts:=0;
							END_IF
						END_IF
					6,7:(*非同步状态下非停止状态下的停止和急停*)
						IF ABS(pstStUnitParam_UnSave^.rAxisVel_PrnRoller)<=0.0001 THEN(*到达0速度|2022.9.21.154723 -以前的条件写错了*)
							byAxisMotionSts:=KS_GetInitSts(i_bySwitchType,
													pstStIOMap_Axis_FE^.i_xLinkage,
													pstStUnitParam_Save^.xLinkage);
						END_IF
				ELSE
					byAxisMotionSts:=KS_GetInitSts(i_bySwitchType,
											pstStIOMap_Axis_FE^.i_xLinkage,
											pstStUnitParam_Save^.xLinkage);
				END_CASE
			ELSE
				byAxisMotionSts:=KS_GetInitSts(i_bySwitchType,
										pstStIOMap_Axis_FE^.i_xLinkage,
										pstStUnitParam_Save^.xLinkage);
			END_IF

			(*处理单运行指示*)
			IF byAxisMotionSts=3 OR(*单运行加速*)
				byAxisMotionSts=4 THEN(*单运行减速*)
				xAxisInching:=TRUE;
			ELSE
				xAxisInching:=FALSE;
			END_IF


			(*切换使能无效了-在状态恢复到初始状态时候xFlag_StsSwitchEn标志为false|
			byAxisMotionSts 在停机时候强制写为初值|
							在印刷状态或者超过限制速度时不切换|*)
			IF xRetainStsEn THEN(*保持之前状态|*)
				byAxisMotionSts:=i_pabyAxisMotionSts^[iUnitId];
			ELSE
				IF NOT xFlag_StsSwitchEn THEN
					byAxisMotionSts:=KS_GetInitSts(i_bySwitchType,
												pstStIOMap_Axis_FE^.i_xLinkage,
												pstStUnitParam_Save^.xLinkage);
				END_IF
			END_IF


			(*处理停机和急停*)
			IF byAxisMotionSts<>0 AND  byAxisMotionSts<>2 THEN
				IF pstStGrpParam_UnSave^.xFlag_EStoping THEN(*急停过程中|*)
					byAxisMotionSts:=6;
				ELSIF pstStGrpParam_UnSave^.xFlag_Ink AND
					(pstStGrpParam_UnSave^.xFlag_Stoping OR (*空转停止过程中*)
					pstStGrpParam_UnSave^.xFlag_FastStoping) THEN
					byAxisMotionSts:=7;
				END_IF

				(*判断轴运动状态|未处于停止状态或者同步状态|*)
				dwAxisMotionStsNotOk:=dwAxisMotionStsNotOk OR SHL(DWORD#1,iUnitId-1);
			END_IF

			(*使能模式控制|2022.7.14.121739*)
			IF i_bySwitchType=0 THEN
				IF byAxisMotionSts=2 THEN(*停止状态 写3*)
					pstStUnitParam_Save^.wEnableMode_Motor:=3;
				ELSE(*非停止状态|写4*)
					pstStUnitParam_Save^.wEnableMode_Motor:=4;
				END_IF
			ELSE
				IF pstStUnitParam_Save^.wEnableMode_Motor=3 OR
					pstStUnitParam_Save^.wEnableMode_Motor=4 THEN(*说明进行过使能切换|此时强制将使能模式写成4*)
					pstStUnitParam_Save^.wEnableMode_Motor:=4;
				ELSE
					pstStUnitParam_Save^.wEnableMode_Motor:=0;
				END_IF
			END_IF

			i_pabyAxisMotionSts^[iUnitId]:=byAxisMotionSts;
			i_paxAxisInching^[iUnitId]:=xAxisInching;
			i_paxLastAxisInchBtn^[iUnitId]:=i_pastStIOMap_Axis_FE^[iUnitId].i_xInch;
		END_FOR

		(*切换条件处理*)
		IF NOT xStsSwitchEn THEN
			IF xFlag_StsSwitchEn THEN
				IF dwAxisMotionStsNotOk=0 THEN(*都处于初始态|可以清除标志了*)
					xFlag_StsSwitchEn:=FALSE;
				END_IF
			END_IF
		END_IF
	ELSE(*不使能*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:=i_paiGrpAxisList^[iN];
			pstStUnitParam_Save:=ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
			pstStUnitParam_UnSave:=ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
			i_pabyAxisMotionSts^[iUnitId]:=0;
			i_paxAxisInching^[iUnitId]:=FALSE;
			i_paxLastAxisInchBtn^[iUnitId]:=FALSE;

			IF pstStUnitParam_Save^.wEnableMode_Motor=3 OR
				pstStUnitParam_Save^.wEnableMode_Motor=4 THEN(*说明进行过使能切换|此时强制将使能模式写成4*)
				pstStUnitParam_Save^.wEnableMode_Motor:=4;
			ELSE
				pstStUnitParam_Save^.wEnableMode_Motor:=0;
			END_IF
		END_FOR
		xFlag_StsSwitchEn:=FALSE;
	END_IF


	i_pxFlag_StsSwitchEn^:=xFlag_StsSwitchEn;
END_IF