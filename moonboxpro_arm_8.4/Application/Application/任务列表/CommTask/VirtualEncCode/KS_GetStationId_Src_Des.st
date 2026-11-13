(*@CES
Name=KS_GetStationId_Src_Des
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=f3e0b804-8a2f-4d3b-8764-62f3cf7084b8
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetStationId_Src_Des : INT(*获得源站号和目标站号|
														错误码-1 没有合适源轴号
														-2 手动的目标轴号不存在
														-3 自动找到的轴号非法
														-4 设置的参数错误*)
//针对火眼系统调整实现代码,目标轴id，取值1~16。只支持手动设置。
VAR_INPUT
	i_byGrpId:INT;(*系id*)
	i_xIsDualUwRw:BOOL;(*是否双收双放机型*)
	i_xAsOneMachine:BOOL;(*作为一台机器使用*)
	i_iAxisIdManu:BYTE;(*手动输入的虚拟码盘目标输出轴号*)
	i_iGrpAxisNum_Pu: INT;(*色组轴*)
	i_paiGrpAxisList: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF INT;(*轴列表|有排序规则|*)
	i_pstStSysParam: POINTER TO StSysParam;(*系统参数*)
	i_piAxisId_Src:POINTER TO INT;(*源轴号*)
	i_piAxisId_Des:POINTER TO INT;(*目标轴号*)
	i_piStationId_Src:POINTER TO INT;(*源站号*)
	i_piStationId_Des:POINTER TO INT;(*目标站号*)
END_VAR
VAR
	in: INT;
	iM: INT;
	iAxisId: INT;
	xAutoSet: BOOL;
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;(*轴参数*)
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;(*轴参数*)
	//pstStRSV_UnitParam_Save: POINTER TO StRSV_UnitParam_Save;(*轴参数*)
	//pstStRSV_UnitParam_UnSave: POINTER TO StRSV_UnitParam_UnSave;(*轴参数*)
	//pstStPTSts_Repacked:POINTER TO StPTSts_Repacked;
	iAxisId_Src: INT:=0;(*输出源轴号*)
	iAxisId_Des: INT:=0;(*输出目标轴号*)
	xValid: BOOL;
	iErrCode: INT;
	iStationId_Src: INT;(*源轴id*)
	iStationId_Des: INT;(*目标轴id*)
	(*2024.01.02.141320*)
	xValidStationType: BOOL;
	xFindStationInfIndex: BOOL;(*找到了索引*)
END_VAR
{IMPLEMENTATION}
iErrCode:=0;
iAxisId_Src:=0;(*初始值*)
iAxisId_Des:=0;
(*源站号和目标站号设置为非法值|用于判定是否设置成功了*)
iStationId_Src:=-1;
iStationId_Des:=-1;
IF i_pstStSysParam<>0 THEN//AND
	//i_paiGrpAxisList<>0 THEN
	(*判定是手动输入目标输出轴号还是自动判定输出目标轴号|自动就判定为收牵轴，无收放牵的就是最后一色*)
	IF i_iAxisIdManu>=1 AND
		i_iAxisIdManu<=MAX_UNIT_NUM THEN(*轴号为非法值时我们进行自动判定*)
		xAutoSet:=FALSE;(*手动设置*)
	ELSE
		//xAutoSet:=TRUE;(*自动设置*)
		iErrCode:=-4;//参数设置失败
	END_IF

	IF iErrCode=0 THEN//参数正常
		(*找到第一个非调整非涂布的轴*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iAxisId:=i_paiGrpAxisList^[iN];
			pstStUnitParam_Save:=ADR(i_pstStSysParam^.astStUnitParam_Save[iAxisId]);
			pstStUnitParam_UnSave:=ADR(i_pstStSysParam^.astStUnitParam_UnSave[iAxisId]);
			//pstStRSV_UnitParam_Save:=ADR(i_pstStSysParam^.astStRSV_UnitParam_Save[iAxisId]);
			//pstStRSV_UnitParam_UnSave:=ADR(i_pstStSysParam^.astStRSV_UnitParam_UnSave[iAxisId]);
			
	
			IF pstStUnitParam_Save^.xLinkage THEN(*联动并且不是涂布|我们作为源站号*)
				iAxisId_Src:=iAxisId;(*如果全是涂布我们取最后一个轴*)
				IF NOT pstStUnitParam_Save^.xSwitchOn_CoatingPrn  THEN
					iAxisId_Src:=iAxisId;
					EXIT;
				END_IF
			END_IF
		END_FOR
	
		IF iAxisId_Src=0 THEN(*未找到合适的源轴号*)
			iErrCode:=-1;
		END_IF
	
		IF iAxisId_Src<>0 THEN(*找到了合适的源轴号*)
			IF NOT xAutoSet THEN(*目标轴号手动设置*)
				(*判断目标轴是否在列表中*)
				xValid:=KS_JudgeAxisIdValid(i_iAxisIdManu(*i_iAxisId*),
											i_iGrpAxisNum_Pu(*i_iGrpAxisTotalNum*),
											i_paiGrpAxisList);
	
				IF xValid THEN(*目标站号存在*)
					iAxisId_Des:=i_iAxisIdManu;
				ELSE
					iErrCode:=-2;
				END_IF
			ELSE(*目标轴号自动设置@取消使用*)
				;
				(*自动找到目标站号*)
				iAxisId_Des:=KS_AutoGetAxisIdDes(
								i_byGrpId(*i_byGrpId*),
								i_xIsDualUwRw(*i_xIsDualUwRw*),
								i_xAsOneMachine(*i_xAsOneMachine*),
								i_iGrpAxisNum_Pu(*i_iGrpAxisTotalNum*),
								i_paiGrpAxisList(*i_paiGrpAxisList*));
				IF iAxisId_Des>=1 AND
					iAxisId_Des<=MAX_UNIT_NUM THEN(*自动得到的目标轴号合法*)
					;
				ELSE
					iErrCode:=-3;
				END_IF
			END_IF
	
			IF iErrCode = 0 THEN(*目标轴id合法*)
				iStationId_Src:=iAxisId_Src;
				iStationId_Des:=iAxisId_Des;
			END_IF
			(*end*)
		END_IF
	END_IF//参数世标
END_IF

(*源轴号输出*)
IF i_piAxisId_Src<>0 THEN
	i_piAxisId_Src^:=iAxisId_Src;
END_IF

(*目标轴号输出*)
IF i_piAxisId_Des<>0 THEN
	i_piAxisId_Des^:=iAxisId_Des;
END_IF

(*源站号输出*)
IF i_piStationId_Src<>0 THEN
	i_piStationId_Src^:=iStationId_Src;
END_IF

(*目标站号输出*)
IF i_piStationId_Des<>0 THEN
	i_piStationId_Des^:=iStationId_Des;
END_IF

KS_GetStationId_Src_Des:=iErrCode;(*错误码*)