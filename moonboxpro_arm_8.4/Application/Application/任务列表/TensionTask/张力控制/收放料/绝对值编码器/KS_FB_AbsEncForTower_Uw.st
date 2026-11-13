(*@CES
Name=KS_FB_AbsEncForTower_Uw
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=d98d8ca0-7a8d-43cd-ae5f-617bd40f4b0e
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AbsEncForTower_Uw(*放料翻转架使用绝对值编码器方式|2021.4.8.113526*)
(*放料卷径测量值，使用编码器原始值|2022.2.22.142034*)
(*2024.02.21.143910
	接口调整@将使能分开为-定位使用绝对值编码器使能
		  	@            -卷径测量使用绝对值编码器使能*)
VAR_INPUT
(*	i_xEn: BOOL;(*使用绝对值编码器|*)*)
	i_xAxisPosEn:BOOL;(*定位使用绝对值编码器使能@2024.02.21.144021*)
	i_xDiamMeasureEn:BOOL;(*卷径测量使用绝对值编码器使能@2024.02.21.144021*)
	i_xMultAxisPosEn:BOOL;(*2021.5.7.104117 增加多轴位置使能标志|默认轴定位是对称处理的*)
	i_iGrpId: INT; (*1.A系;2.B系*)
	i_pxGetAxisLocation:POINTER TO BOOL;(*获取轴定位标志|用于调试测量*)
	i_pxCurAxisAFroDebug:POINTER TO BOOL;(*界面选择的当前轴为A轴|用于调试使用--需要将使用的当前轴变量修改为相反轴*)
	i_pxCutterOnTopFroDebug:POINTER TO BOOL;(*界面选择的上下裁刀标志|用于调试使用*)
	i_pbyEncodeValueWr:POINTER TO BYTE;(*编码器值写入	编码器值写入|放料:
																		 01 写入轴定位值
																		 02 写入轴最小径定位值*)
	i_dwAbsEncSinglePos:DWORD;(*单圈绝对值|*)
	i_wAbsEncMultiPos:WORD;(*绝对值编码器多圈值*)
	i_dwAbsEnCodeResolution:DWORD:=131072;(*单圈绝对值编码器值*)
	(*2022.4.23.115840 增加翻转架转动输入|用于判断绝对值编码器是否正常*)
	i_xTowerMoving:BOOL;(*翻转架正在运动中*)
	i_xBtn_AxisLocationManu:BOOL;(*手动定位按钮|用于在出现编码器故障时候。保证正常接料*)
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;
	o_dwEnCodePos:DWORD;(*编码器位置值*)
	o_xAxisAMinimumDiamProtect: BOOL;(*放料A轴最小径位置到达*)
	o_xAxisBMinimumDiamProtect: BOOL;(*放料B轴最小径位置到达*)
	o_xAxisALocation:BOOL;(*放料A轴定位到达*)
	o_xAxisBLocation:BOOL;(*放料B轴定位到达*)
	o_xAxisLocationInvalid: BOOL;(*轴定位无效*)
	o_xAxisLocation_MinDiaInvalid: BOOL;(*轴最小径无效*)
	o_xAxisLocationWrDne: BOOL;(*轴定位写入成功*)
	o_xAxisLocation_MinDiaWrDne: BOOL;(*轴最小径写入成功*)
END_VAR
VAR_IN_OUT
	(*2022.4.23.120032*)
	io_xEnCodeFailed:BOOL;
	io_xCutOnTop: BOOL;
	io_xCurAxisA: BOOL;
	io_adwAxisALocation: ARRAY [0..1] OF DWORD;
	io_adwAxisBLocation: ARRAY [0..1] OF DWORD;
	io_adwAxisALocation_MinDia: ARRAY [0..1] OF DWORD;
	io_adwAxisBLocation_MinDia: ARRAY [0..1] OF DWORD;
	io_rAIByAbsEnc_Cur: REAL;
END_VAR
VAR
//	pstStGrpParam: POINTER TO StGrpParam; (*访问当前系参数的指针*)

	dwEnCodePos_Cycle: DWORD;(*一圈的编码器值*)
	dwPos_SingleTurn: DWORD;(*取输入的值*)
	dwPos_MultTurn: DWORD;(*取输入的值*)
	dwEnCodePos: DWORD;(*使用的编码器位置值*)
	xInitLastEncPos: BOOL;(*初始化备份编码器位置值*)
	dwLastEnCodePos: DWORD;(*上个周期编码器位置值*)
	dwEnCodePos_MultTurn: DWORD;(*多圈值*)


	iCutterOnTop_Uw:INT;
	pdwAxisLocation_Uw: POINTER TO DWORD;(*预驱轴定位指针-放料*)
	pdwAxisLocation_MinDia_Uw: POINTER TO DWORD;(*预驱轴最小径指针-放料*)
	pdwCurAxisLocation_Uw: POINTER TO DWORD;(*当前轴定位指针-放料*)
	pdwCurAxisLocation_MinDia_Uw: POINTER TO DWORD;(*当前轴最小径指针-放料*)
	xRtn_InPos_Location: BOOL;(*定位到位标志*)
	xRtn_InPos_MinDia: BOOL;(*最小径到位标志*)
	xLastCurAxisAFroDebug: BOOL;(*保存上个周期的调试当前轴|实际的预驱轴*)
	xLastCurAxisA: BOOL;(*保留上个周期的当前轴*)
	(*2022.4.23.122548*)
	(*周期计数值*)
	iCycleCnt: INT;
	dwEncodePosSaForJudge: DWORD;
	dwTemp: DWORD;
END_VAR
{IMPLEMENTATION}
o_xAxisAMinimumDiamProtect:=FALSE;
o_xAxisBMinimumDiamProtect:=FALSE;
o_xAxisALocation:=FALSE;
o_xAxisBLocation:=FALSE;
o_xAxisLocationInvalid:=FALSE;
o_xAxisLocation_MinDiaInvalid:=FALSE;
o_xAxisLocationWrDne:=FALSE;
o_xAxisLocation_MinDiaWrDne:=FALSE;
o_dwEnCodePos:=0;
IF (i_iGrpId=1 OR i_iGrpId=2) AND
	i_pxGetAxisLocation<>0 AND
	i_pxCurAxisAFroDebug<>0 AND
	i_pxCutterOnTopFroDebug<>0 AND
	i_pbyEncodeValueWr<>0 THEN
//	pstStGrpParam:=ADR(i_pstStShmGlobalParam^.astStGrpParam[i_iGrpId]);

	IF i_xAxisPosEn THEN(*编码器方式使能*)
		IF i_pxGetAxisLocation^ THEN(*编码器调试打开后刷新中的上下裁AB轴参数*)
			io_xCutOnTop:=i_pxCutterOnTopFroDebug^;

			IF io_xCurAxisA=i_pxCurAxisAFroDebug^ THEN(*调试轴和当前轴一样|切换当前轴*)
				IF xLastCurAxisA<>io_xCurAxisA THEN(*当前轴切换了*)
					i_pxCurAxisAFroDebug^:=NOT io_xCurAxisA;(*界面选择是预驱轴的轴号*)
				END_IF

				IF xLastCurAxisAFroDebug<>i_pxCurAxisAFroDebug^ THEN(*调试轴切换了*)
					io_xCurAxisA:=NOT i_pxCurAxisAFroDebug^;(*界面选择是预驱轴的轴号*)
				END_IF
			END_IF
		ELSE
			i_pxCurAxisAFroDebug^:=NOT io_xCurAxisA;(*界面选择是预驱轴的轴号*)
			i_pxCutterOnTopFroDebug^:=io_xCutOnTop;
		END_IF
		xLastCurAxisA:= io_xCurAxisA;
		xLastCurAxisAFroDebug:=i_pxCurAxisAFroDebug^;

		(*2021.1.26.153819 改用最后一个数字量模块特殊固件读取绝对值编码器|*)
		dwPos_SingleTurn:=i_dwAbsEncSinglePos;
		dwPos_MultTurn:=WORD_TO_DWORD(i_wAbsEncMultiPos);
		(*一圈的编码器值*)
		dwEnCodePos_Cycle:=i_dwAbsEnCodeResolution;
		(*编码器的取值0作为了使用编码器判断位置和使用接近开关判断位置的标志
		所以我们不输出0|=0时写1*)
		dwEnCodePos:=dwPos_SingleTurn;(*可以叠加多圈值*)
		dwEnCodePos_MultTurn:=dwPos_MultTurn;
		IF dwEnCodePos=0 THEN
			dwEnCodePos:=1;
		END_IF
		o_dwEnCodePos:=dwEnCodePos;(*输出*)

		(*根据现在选项取定位值|放料*)
		iCutterOnTop_Uw:=BOOL_TO_INT(io_xCutOnTop);
		IF io_xCurAxisA THEN(*A轴|取预驱轴B的值*)
			(*取地址*)
			(*预驱轴*)
			pdwAxisLocation_Uw:=ADR(io_adwAxisBLocation[iCutterOnTop_Uw]);
			pdwAxisLocation_MinDia_Uw:=ADR(io_adwAxisBLocation_MinDia[iCutterOnTop_Uw]);
			(*当前轴*)
			pdwCurAxisLocation_Uw:=ADR(io_adwAxisALocation[iCutterOnTop_Uw]);
			pdwCurAxisLocation_MinDia_Uw:=ADR(io_adwAxisALocation_MinDia[iCutterOnTop_Uw]);
		ELSE(*B轴|取预驱轴A的值*)
			(*取地址*)
			(*预驱轴*)
			pdwAxisLocation_Uw:=ADR(io_adwAxisALocation[iCutterOnTop_Uw]);
			pdwAxisLocation_MinDia_Uw:=ADR(io_adwAxisALocation_MinDia[iCutterOnTop_Uw]);
			(*当前轴*)
			pdwCurAxisLocation_Uw:=ADR(io_adwAxisBLocation[iCutterOnTop_Uw]);
			pdwCurAxisLocation_MinDia_Uw:=ADR(io_adwAxisBLocation_MinDia[iCutterOnTop_Uw]);
		END_IF

		IF NOT i_pxGetAxisLocation^ THEN(*没有调试写入状态也不要写*)
			i_pbyEncodeValueWr^:=0;
		END_IF

		CASE i_pbyEncodeValueWr^ OF
			1:(*写入轴定位-放料*)
				IF pdwAxisLocation_Uw<>0 THEN
					pdwAxisLocation_Uw^:=dwEnCodePos;
				END_IF
				o_xAxisLocationWrDne:=TRUE;(*轴定位写入成功*)
			2:(*写入轴最小径定位-放料*)
				IF pdwAxisLocation_MinDia_Uw<>0 THEN
					pdwAxisLocation_MinDia_Uw^:=dwEnCodePos;
				END_IF
				o_xAxisLocation_MinDiaWrDne:=TRUE;
		ELSE;
		END_CASE

		(*2021.5.7.104844 处理对称定位和单轴定位*)
		IF i_xMultAxisPosEn THEN(*多轴定位*);
		ELSE(*对称定位|将预驱轴采集的值写入到当前轴*)
			IF o_xAxisLocationWrDne THEN(*轴定位写入动作*)
				IF pdwAxisLocation_Uw<>0 AND
					pdwCurAxisLocation_Uw<>0 THEN
					pdwCurAxisLocation_Uw^:=pdwAxisLocation_Uw^+i_dwAbsEnCodeResolution/2;(*对称处理*)
					IF pdwCurAxisLocation_Uw^>i_dwAbsEnCodeResolution THEN(*过圈处理*)
						pdwCurAxisLocation_Uw^:=pdwCurAxisLocation_Uw^-i_dwAbsEnCodeResolution;
					END_IF
				END_IF
			ELSIF o_xAxisLocation_MinDiaWrDne THEN(*最小径写入*)
				IF pdwAxisLocation_MinDia_Uw<>0 AND
					pdwCurAxisLocation_MinDia_Uw<>0 THEN
					pdwCurAxisLocation_MinDia_Uw^:=pdwAxisLocation_MinDia_Uw^+i_dwAbsEnCodeResolution/2;(*对称处理*)
					IF pdwCurAxisLocation_MinDia_Uw^>i_dwAbsEnCodeResolution THEN(*过圈处理*)
						pdwCurAxisLocation_MinDia_Uw^:=pdwCurAxisLocation_MinDia_Uw^-i_dwAbsEnCodeResolution;
					END_IF
				END_IF
			END_IF
		END_IF
		i_pbyEncodeValueWr^:=0;


		(*2024.02.21.144108 调整位置*)
(*
		(*放料卷径测量值，使用编码器原始值|2022.2.22.142034*)
		(*由于原来的逻辑中使用的是电压值|简单一点将编码器值写到0--10变化,我们只使用单圈值*)
		IF pstStGrpParam^.byDiamMeasureTypeId=2 THEN(*使用编码器方式进行卷径测量-*)

			pstStGrpParam^.lrAI_DiamMeasure_Uw_cur:=DWORD_TO_LREAL(dwEnCodePos);
		END_IF
*)

		IF NOT xInitLastEncPos THEN(*刚启动读取的时候更新上个周期的位置值*)
			xInitLastEncPos:=TRUE;
			dwLastEnCodePos:=dwEnCodePos;
		END_IF
		(*放料定位|*)
		IF pdwAxisLocation_Uw^<>0 (*AND NOT i_pxGetAxisLocation^*) THEN(*定位有值 不再轴定位确认模式*)
			(*定位判断是否到位*)
						KS_JudgeInPos(
							pdwAxisLocation_Uw^(*i_dwPos_Tar*),
							dwEnCodePos(*i_dwPos_Cur*),
							dwLastEnCodePos(*i_dwLastPos_Cur**),
							dwEnCodePos_Cycle(*i_dwPos_Cycle*),
							ADR(xRtn_InPos_Location));


			o_xAxisALocation:=xRtn_InPos_Location AND (NOT io_xCurAxisA);(*预驱轴为A轴*)
			o_xAxisBLocation:=xRtn_InPos_Location AND io_xCurAxisA;(*预驱轴为B轴*)
		ELSIF pdwAxisLocation_Uw^=0 THEN(*定位无效|输出标志 使用接近开关*)
			o_xAxisLocationInvalid:=TRUE;
			xRtn_InPos_Location:=FALSE;
		END_IF

		(*放料最小径*)
		IF pdwAxisLocation_MinDia_Uw^<>0 (*AND NOT i_pxGetAxisLocation^*) THEN(*最小径定位有值 不再轴定位确认模式*)
			(*最小径位置判断*)
			KS_JudgeInPos(
				pdwAxisLocation_MinDia_Uw^(*i_dwPos_Tar*),
				dwEnCodePos(*i_dwPos_Cur*),
				dwLastEnCodePos(*i_dwLastPos_Cur**),
				dwEnCodePos_Cycle(*i_dwPos_Cycle*),
				ADR(xRtn_InPos_MinDia));
			o_xAxisAMinimumDiamProtect:=xRtn_InPos_MinDia AND (NOT io_xCurAxisA);
			o_xAxisBMinimumDiamProtect:=xRtn_InPos_MinDia AND io_xCurAxisA;
		ELSIF pdwAxisLocation_MinDia_Uw^=0 THEN(*最小径无效*)
			o_xAxisLocation_MinDiaInvalid:=TRUE;
			xRtn_InPos_MinDia:=FALSE;
		END_IF
		dwLastEnCodePos:=dwEnCodePos;

		(*2022.4.23.115742 增加了编码器检查逻辑*)
		IF i_xTowerMoving THEN
			IF iCycleCnt=0 THEN(*记录开始位置*)
				dwEncodePosSaForJudge:=dwEnCodePos;
			END_IF
			iCycleCnt:=iCycleCnt+1;
			IF iCycleCnt>=50 THEN(*1S检查一次位置*)
				iCycleCnt:=0;
				(*变化量超过1000个脉冲。我们认为是正常的*)
				dwTemp:=(dwEnCodePos+i_dwAbsEnCodeResolution-dwEncodePosSaForJudge) MOD i_dwAbsEnCodeResolution;
				IF dwTemp>=i_dwAbsEnCodeResolution/2 THEN(*说明是反向转了*)
					dwTemp:=LREAL_TO_DWORD(ABS(DWORD_TO_LREAL(dwTemp)-DWORD_TO_LREAL(i_dwAbsEnCodeResolution)));
				END_IF
				IF dwTemp>=1000 THEN
					io_xEnCodeFailed:=FALSE;
				ELSE
					io_xEnCodeFailed:=TRUE;
				END_IF
			END_IF
		ELSE
			iCycleCnt:=0;
		END_IF


			(*2022.4.23.130646 增加手动定位*)
		IF io_xEnCodeFailed THEN
			IF i_xBtn_AxisLocationManu THEN
				o_xAxisALocation:=(NOT io_xCurAxisA);(*预驱轴为A轴*)
				o_xAxisBLocation:=io_xCurAxisA;(*预驱轴为B轴*)
			END_IF
		END_IF
	ELSE(*未使能编码器模式*)
(*deprecated@2021.7.16.093420/
		i_pxGetAxisLocation^:=FALSE;
*)
		io_xEnCodeFailed:=FALSE;
		iCycleCnt:=0;
		xInitLastEncPos:=FALSE;
		i_pxCurAxisAFroDebug^:=NOT io_xCurAxisA;(*界面选择是预驱轴的轴号*)
		i_pxCutterOnTopFroDebug^:=io_xCutOnTop;
		xLastCurAxisA:=io_xCurAxisA;
		xLastCurAxisAFroDebug:=i_pxCurAxisAFroDebug^;
		i_pbyEncodeValueWr^:=0;
		xRtn_InPos_Location:=FALSE;
		xRtn_InPos_MinDia:=FALSE;
	END_IF

	(*2024.02.21.144158 移动*)
	(*放料卷径测量值，使用编码器原始值|2022.2.22.142034*)
	(*由于原来的逻辑中使用的是电压值|简单一点将编码器值写到0--10变化,我们只使用单圈值*)
	IF i_xDiamMeasureEn THEN(*使用编码器方式进行卷径测量-*)
		(*2021.1.26.153819 改用最后一个数字量模块特殊固件读取绝对值编码器|*)
		dwPos_SingleTurn:=i_dwAbsEncSinglePos;
		(*编码器的取值0作为了使用编码器判断位置和使用接近开关判断位置的标志
		所以我们不输出0|=0时写1*)
		dwEnCodePos:=dwPos_SingleTurn;(*可以叠加多圈值*)
		IF dwEnCodePos=0 THEN
			dwEnCodePos:=1;
		END_IF
		o_dwEnCodePos:=dwEnCodePos;

		io_rAIByAbsEnc_Cur:=DWORD_TO_LREAL(dwEnCodePos);
	END_IF


(*	o_xEn:=i_xEn;*)
ELSE;(*参数非法*)
	o_xEn:=FALSE;
	io_xEnCodeFailed:=FALSE;
	iCycleCnt:=0;
	xInitLastEncPos:=FALSE;
	xRtn_InPos_Location:=FALSE;
	xRtn_InPos_MinDia:=FALSE;
END_IF