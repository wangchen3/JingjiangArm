(*@CES
Name=KS_VelPrfByAxisMotionSts
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=bab22195-914f-4e07-a531-52e1aa67a074
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_VelPrfByAxisMotionSts : BOOL(*根据轴运动状态标志控制轴速度输出
													  |0:同步运动状态.
													  |1:同步运动时停止运动状态.
													  |2:停止运动状态
													  |3:停止运动时加速到单运行速度状态.
													  |4:单运行时减速到停止状态.
													  |5:停止运动时或者使用单运行速度运行时加速到同步运动状态.
													  |6:非同步运动时急停到0状态.
													  |7:非同步运动时空转停机到0状态.*)
(*该功能的加减速时间分开|2022.5.29.004252*)
(*2022.12.26.135440 |出现过因为pstStAxisParam^.byEnableModeSwitchDne.1变量作为速度规划条件的时候
因为停机时机的问题引起的速度不能清除的问题，使用本地变量作为条件*)
(*2023.2.15.173943 所有的减速时间都由手动减速时间修改为了停止时间*)
(*2023.07.24.171926处理因为时序问题引起的motionctl中不能正确设置当前伺服状态*)
VAR_INPUT
	i_iGrpId: INT;
	i_iGrpAxisNum_Pu: INT; (*色组轴数量*)
	i_pstStSysParam: POINTER TO StSysParam;
//	i_pstStGrpParam: POINTER TO StGrpParam;(*系参数访问入口|*)
	i_paiGrpAxisList: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF INT; (*系内所有轴的列表*)
//	i_pastStAxisParam: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StAxisParam;
	i_pabyAxisMotionSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF BYTE;(*轴运动状态*)
	i_palrAxisMotionVel:POINTER TO ARRAY [1..MAX_STATION_NUM] OF LREAL;(*轴速度*)
	i_palrAcceleToSync:POINTER TO ARRAY [1..16] OF LREAL;(*用来保证同步的加速度|m/min/ms|16个轴*)
	i_xMotionEnabled: BOOL;(*MotionCtl功能块准备好了|可以规划速度|2022.7.14.133144*)
	i_pxVelPrfEn: POINTER TO BOOL;(*可以规划速度已经使能|2022.7.14.133144*)
	i_xNeedKeepSync:BOOL;(*需要保证同步|在前往同步时候如果加减速有效了-则按照界面输入时间进行加减速|2022.7.21.174859*)
	i_paxAxisVelPrfEn:POINTER TO ARRAY [1..MAX_STATION_NUM] OF BOOL;(*2022.12.26.135324 增加了轴速度的规划使能标志|进行速度规划的条件*)
	i_uiMaxVel_UseCalcAcc:UINT;(*用于计算最大加速度的最大速度@2024.04.12.180552*)
END_VAR
VAR
	iTimeAccDec: INT;(*加减速时间|s|正负标记加减速*)
	lrVel_Max: REAL;(*最大速度*)
	lrDelVelPerCycle: LREAL;(*单位周期的速度变化*)
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;
	abyLastAxisMotionSts:ARRAY [1..MAX_STATION_NUM] OF BYTE;
	iN: INT;
	iUnitId: INT;
	byAxisMotionSts: BYTE;
	byLastAxisMotionSts: BYTE;
	lrAxisMotionVel: LREAL;
	lrVel_Cur: LREAL;
	lrVel_Tar: LREAL;
	xUseInputAccele: BOOL;(**)
	dwAxisVelPrfMustEnable: DWORD;
END_VAR
{IMPLEMENTATION}
IF i_pstStSysParam<>0 AND
	i_paiGrpAxisList<>0 AND
	i_pabyAxisMotionSts<>0 AND
	i_iGrpAxisNum_Pu>0 AND
	i_palrAxisMotionVel<>0 AND
	i_palrAcceleToSync<>0 AND
	i_pxVelPrfEn<>0 AND
	i_paxAxisVelPrfEn<>0 THEN

	IF i_xMotionEnabled  THEN(*上伺服模式写为4成功后执行速度控制*)
		i_pxVelPrfEn^:=TRUE;
	END_IF

	FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
		iUnitId:=i_paiGrpAxisList^[iN];
		byAxisMotionSts:=i_pabyAxisMotionSts^[iUnitId];
		byLastAxisMotionSts:=abyLastAxisMotionSts[iUnitId];
		lrAxisMotionVel:=i_palrAxisMotionVel^[iUnitId];
		pstStUnitParam_Save:=ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
		pstStUnitParam_UnSave:=ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);

		(*2023.07.24.171926@将清除位置移动到此处|
		处理因为时序问题引起的motionctl中不能正确设置当前伺服状态*)
		(*2022.12.26.135650@解决异常速度规划不能到0问题*)
		IF i_paxAxisVelPrfEn^[iUnitId] AND
			NOT pstStUnitParam_UnSave^.byEnableModeSwitchDne.1 AND
			lrAxisMotionVel<=0.00001 THEN(*速度规划到0了|复位标志*)
			i_paxAxisVelPrfEn^[iUnitId]:=FALSE;
		END_IF


		(*2022.12.26.135440 |出现过因为pstStAxisParam^.byEnableModeSwitchDne.1变量作为速度规划条件的时候
		因为停机时机的问题引起的速度不能清除的问题，使用本地变量作为条件*)
		IF pstStUnitParam_UnSave^.byEnableModeSwitchDne.1 THEN
			i_paxAxisVelPrfEn^[iUnitId]:=pstStUnitParam_UnSave^.byEnableModeSwitchDne.1;
		END_IF

		(*2024.12.31.102049 同步*)
		IF pstStUnitParam_Save^.xSwitchOn_CoatingPrn THEN(*涂布*)
			lrVel_Cur:=pstStUnitParam_UnSave^.lrVelocity_CoatingPrn;
		ELSE
			(*2024.12.22.164428@色组轴*)
			IF NOT i_pstStSysParam^.stStSysParam_Save.xAxisPrfVelEn THEN
				lrVel_Cur:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur;
			ELSE
				//2026.5.9.193956这里更新了，不知道有没有问题
				IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_AutoAcc OR 
						i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_AutoDec THEN
					lrVel_Cur:=pstStUnitParam_UnSave^.rAxisPrfVel;
				ELSE
					lrVel_Cur:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur;
				END_IF
			END_IF
		END_IF

		xUseInputAccele:=FALSE;

		CASE byAxisMotionSts OF
			0:(*同步转动状态*)
				lrVel_Tar:=lrVel_Cur;
				iTimeAccDec:=0;(*完全跟随*)
			1:(*同步运动状态下减速到停止状态*)
				lrVel_Tar:=0;
(*				iTimeAccDec:=-i_pstStGrpParam^.iTime_ManuDec;(*手动减速时间跟随*)*)
				iTimeAccDec:=-i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iTime_Stop;(*停止时间跟随@2023.2.15.174049*)
			2:(*停止运动状态*)
				lrVel_Tar:=0;
(*				iTimeAccDec:=-i_pstStGrpParam^.iTime_ManuDec;(*手动减速时间跟随*)*)
				iTimeAccDec:=-i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iTime_Stop;(*停止时间跟随@2023.2.15.174049*)
			3:(*停止运动状态加速到单运行速度*)
				lrVel_Tar:=i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rVel_Inch;
				iTimeAccDec:=i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iTime_ManuAcc;(*手动加速时间跟随*)
			4:(*单运行减速到停止位置*)
				lrVel_Tar:=0;
(*				iTimeAccDec:=-i_pstStGrpParam^.iTime_ManuDec;(*手动减速时间跟随*)*)
				iTimeAccDec:=-i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iTime_Stop;(*停止时间跟随@2023.2.15.174049*)
			5:(*加速到同步速度状态*)
				lrVel_Tar:=lrVel_Cur;
				IF lrAxisMotionVel<=lrVel_Tar THEN(*2022.12.26.134601 +条件*)
					iTimeAccDec:=i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iTime_ManuAcc;(*手动加速时间跟随*)
				ELSE(*2022.12.26.134601 +条件*)
					iTimeAccDec:=-i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iTime_ManuAcc;(*手动减速时间跟随*)
				END_IF
				IF i_palrAcceleToSync^[iUnitId]<>0 THEN(*说明计算出来了同步*)
					xUseInputAccele:=TRUE;
				END_IF
			6:(*非同步状态时急停到0状态*)
				lrVel_Tar:=0;
				iTimeAccDec:=-i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iTime_Estop;(*急停时间跟随*)

			7:
				lrVel_Tar:=0;
				iTimeAccDec:=-i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iTime_stop;(*停止时间跟随*)
		ELSE
			lrVel_Tar:=0;
			iTimeAccDec:=-i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iTime_Estop;(*急停时间跟随*)
		END_CASE;

		(*速度控制*)
		(*计算加减加速度值*)
		lrVel_Max:=(i_uiMaxVel_UseCalcAcc);
		IF lrVel_Max<=20 THEN(*最大速度限制到20m/min以上*)
			lrVel_Max:=20;
		END_IF
		IF iTimeAccDec<>0 THEN
			lrDelVelPerCycle:=lrVel_Max*gc_iCycleTime_Motion/iTimeAccDec/1000;
			(*由外部计算出的加速度控制到达同步速度时保证位置同步|2021.1.5.155658*)
			IF xUseInputAccele AND i_xNeedKeepSync THEN(*需要使用外部输入的加速度进行加速|2022.7.21.175130增加需要同步使能*)
				lrDelVelPerCycle:=i_palrAcceleToSync^[iUnitId]*gc_iCycleTime_Motion;
			END_IF
			IF i_pxVelPrfEn^ AND
				//NOT i_pstStGrpParam^.xFlag_PTfifofull AND
(*				pstStAxisParam^.byEnableModeSwitchDne.1 THEN*)
				i_paxAxisVelPrfEn^[iUnitId] THEN(*2022.12.26.152739 替换*)

				lrAxisMotionVel:=lrAxisMotionVel+lrDelVelPerCycle;
				IF lrDelVelPerCycle>0 THEN(*加速*)
					IF lrAxisMotionVel>=lrVel_Tar THEN
						lrAxisMotionVel:=lrVel_Tar;
					END_IF
				ELSE(*减速*)
					IF lrAxisMotionVel<=lrVel_Tar THEN
						lrAxisMotionVel:=lrVel_Tar;
					END_IF
				END_IF
			END_IF
		ELSE
			lrAxisMotionVel:=lrVel_Tar;
		END_IF

		IF NOT pstStUnitParam_UnSave^.xMoveEnable_Motor OR(*2022.7.14.102148 联动标志修改为了电机运动使能标志*)
			lrAxisMotionVel<0.00001 THEN(*防止因为数据类型的原因导致值不能完全=0*)
			lrAxisMotionVel:=0.0;
		END_IF

		IF lrAxisMotionVel<>0 THEN(*速度未到0了*)
			dwAxisVelPrfMustEnable:=dwAxisVelPrfMustEnable OR
									SHL(DWORD#1,iUnitId-1);

		END_IF

		i_palrAxisMotionVel^[iUnitId]:=lrAxisMotionVel;
		(*2023.07.24.171926@将清除位置移动到规划使能的位置|
		处理因为时序问题引起的motionctl中不能正确设置当前伺服状态*)
(*
		(*2022.12.26.135650@解决异常速度规划不能到0问题*)
		IF i_paxAxisVelPrfEn^[iAxisId] AND
			NOT pstStAxisParam^.byEnableModeSwitchDne.1 AND
			lrAxisMotionVel<=0.00001 THEN(*速度规划到0了|复位标志*)
			i_paxAxisVelPrfEn^[iAxisId]:=FALSE;
		END_IF
*)
	END_FOR

	(*2022.7.14.134141  *)
	IF i_pxVelPrfEn^ AND
		(NOT i_xMotionEnabled) THEN
		IF dwAxisVelPrfMustEnable=0 THEN(*不需要使能了*)
			i_pxVelPrfEn^:=FALSE;
		END_IF
	END_IF
ELSE;
END_IF