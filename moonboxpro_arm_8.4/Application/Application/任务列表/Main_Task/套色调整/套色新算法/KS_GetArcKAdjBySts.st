(*@CES
Name=KS_GetArcKAdjBySts
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=ab0b9e35-35e9-482c-8b4f-391e87029d49
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetArcKAdjBySts : BYTE
(*2024.9.2.104007*)
(*根据套色调整状态输出增益,@=0 初始状态(增益略大) |=1 稳态状态(增益略小)*)
(*匀速,速度高于一定值才判断,反之使用初始误差,
连续一定幅最多20幅误差小于一定值,变化量也小于一定值认为稳态*)
(*2024.9.6.124942 增加计算*)
VAR_INPUT
	i_xEn						: BOOL;(*使能标志@未使能则使用初始增益*)
	i_byKadj_SetType			: BYTE;(*套色K值设置方式
								@ =0 使用初始增益|计算Ki的速度=当前速度@实际积分的系数是定值
								@ =1 使用初始增益的同时,计算Ki的速度也是定值-按照30m/min输出@实际积分的系数是随速度减小的
								@ =2 根据状态设置|计算Ki的速度根据当前速度变化@实际积分的系数是定值
								@ =3 根据状态设置的同时,计算Ki的速度也是定值-按照30m/min输出@实际积分的系数是随速度减小的*)
	i_rKadj_PID_Mol_Init 		: REAL;(*模型的pid增益_初始增益@开机和接料使用*)
	i_rKadj_I_Mol_Init			: REAL;(*模型的I值增益_初始增益@开机和接料使用*)
	i_rKadj_PID_Mol_SteadySts	: REAL;(*模型的pid增益_稳态增益*)
	i_rKadj_I_Mol_SteadySts		: REAL;(*模型的I值增益_稳态增益*)
	i_xCut						: BOOL;(*裁切了@沿标志|判定状态使用*)
	i_xFilmArrived_Cut			: BOOL;(*裁切后料膜到达@让料头标志*)
	i_xEvenning					: BOOL;(*匀速状态@此时才能判定状态*)
	i_iVel_Cur					: INT;(*当前速度@m/min*)
	i_iErrValue					: INT;(*误差值@丝*)
	i_byErrThreshold			: BYTE:=30;(*套色误差阈值@单位丝|判定状态使用*)
	i_byDeltaErrThreshold		: BYTE:=10;(*套色误差变化量阈值@单位丝|判定状态使用*)
	i_iVelThreshold				: INT:=100;(*速度阀值@超过该速度才判断状态@允许=0*)

	i_pxCutting					: POINTER TO BOOL;(*裁切中标志*)
	i_paiErrValueList			: POINTER TO ARRAY [0..20] OF INT;(*20个缓存[20]=最新值@[0]=统计缓存个数*)
	i_pbyArcAdjSts				: POINTER TO BYTE;(*套色调整状态@=0 初始状态(增益略大) |=1 稳态状态(增益略小)*)
	i_prKadj_Pid				: POINTER TO REAL;(*输出的增益值*)
	i_prKadj_I					: POINTER TO REAL;(*输出的增益值*)
	i_prVel_Ki					: POINTER TO REAL;(*计算的ki的速度@2024.9.6.123736根据状态会变化*)
END_VAR
VAR
	rKadj_Pid				: REAL;(*输出的增益值*)
	rKadj_I					: REAL;(*输出的增益值*)
	xUseInitKAdj			: BOOL:=TRUE;(*默认使用初始k|反之则使用状态k*)
	byArcAdjSts				: BYTE;(*套色调整状态*)
	aiErrValueList			: ARRAY [1..20] OF INT;(*20个缓存[20]=最新值*)
	iErrValueListNum		: INT;(*缓存个数*)
	iErrValue				: INT;(*误差值*)
	iDeltaValue				: INT;(*变化量*)
	iErrNum					: INT;(*误差个数*)
	iN						: INT;(*循环*)
	iErrValue1				: INT;(*前一个误差*)
	iErrValue2				: INT;(*较新的误差*)
	xUpdatErrList			: BOOL;(*更新误差列表*)
	iVelThreshold			: INT;(*速度阈值临时*)
	xJudgeAdjSts			: BOOL;(*判断状态标志*)
	xIsSteadySts			: BOOL;(*已经是稳态了*)
	xNotSteadySts			: BOOL;(*s是非稳态@不再判断了*)
	xCutting				: BOOL;(*裁切中*)
	rVel_Ki					: REAL;(*计算Ki的速度*)
END_VAR
{IMPLEMENTATION}
IF i_pxCutting<>0 THEN
	xCutting:=i_pxCutting^;
END_IF

IF i_paiErrValueList<>0 THEN
	iErrValueListNum:=i_paiErrValueList^[0];
	SysMemCpy(ADR(aiErrValueList),ADR(i_paiErrValueList^[1]),SIZEOF(aiErrValueList));
END_IF
IF i_pbyArcAdjSts<>0 THEN
	byArcAdjSts:=i_pbyArcAdjSts^;
END_IF

iErrValue:=i_iErrValue;
iVelThreshold:=i_iVelThreshold;
iErrNum:=SIZEOF(aiErrValueList)/SIZEOF(aiErrValueList[1]);

IF i_xEn THEN
	IF i_byKadj_SetType = 2 OR i_byKadj_SetType=3 THEN(*根据状态切换增益*)
		xUseInitKAdj:=FALSE;
		(*裁切状态切换*)
		IF i_xCut THEN
			xCutting:=TRUE;
		ELSIF xCutting THEN
			IF i_xFilmArrived_Cut THEN
				xCutting:=FALSE;
			END_IF
		END_IF

		(*套色误差判断状态*)
		IF iErrValueListNum	< iErrNum THEN
			byArcAdjSts:=0;
			iErrValueListNum:=iErrValueListNum+1;(*开始累*)
			aiErrValueList[iErrValueListNum] := i_iErrValue;
		ELSE
			xUpdatErrList:=TRUE;
		END_IF

		(*判断是否已经进入了稳态*)
		IF byArcAdjSts=1 THEN
			xIsSteadySts:=TRUE;
		END_IF

		IF iErrValueListNum>= iErrNum THEN(*累计足够了*)
			FOR iN:=1 TO iErrNum-1 BY 1 DO
				(*更新列表*)
				IF xUpdatErrList THEN
					IF iN=1 THEN(*直接更新[1] [2],这样下面的计算才正确*)
						aiErrValueList[iN] := aiErrValueList[iN+1];
						aiErrValueList[iN+1] := aiErrValueList[iN+2];
					ELSIF iN<iErrNum-1 THEN(*=2 更新第3个|以此类推*)
						aiErrValueList[iN+1] := aiErrValueList[iN+2];
					ELSE(*更新最后一个*)
						aiErrValueList[iN+1] := i_iErrValue;
					END_IF
				END_IF

				(*获取误差*)
				iErrValue1:=aiErrValueList[iN];
				iErrValue2:=aiErrValueList[iN+1];
				iDeltaValue:=iErrValue2-iErrValue1;


				xJudgeAdjSts:=i_iVel_Cur>=iVelThreshold AND i_xEvenning;(*高速,匀速,才判断套色状态*)
				xJudgeAdjSts:=xJudgeAdjSts AND NOT xCutting;(*处于非裁切中才进行状态判定*)
				IF xJudgeAdjSts THEN
					IF NOT xIsSteadySts AND NOT xNotSteadySts THEN(*未进入稳态|没有判断出是非稳态*)
						IF iN=1 THEN(*判断2个误差的阈值*)
							IF ABS(iErrValue1)<=i_byErrThreshold AND
								ABS(iErrValue2)<=i_byErrThreshold AND
								ABS(iDeltaValue)<=i_byDeltaErrThreshold THEN
								byArcAdjSts:=1;(*稳态了*)
							ELSE
								byArcAdjSts:=0;(*非稳态了*)
								xNotSteadySts:=TRUE;
							END_IF
						ELSE(*判断较新误差的判断*)
							IF ABS(iErrValue2)<=i_byErrThreshold AND
								ABS(iDeltaValue)<=i_byDeltaErrThreshold THEN
								byArcAdjSts:=1;(*稳态了*)
							ELSE
								byArcAdjSts:=0;(*非稳态了*)
								xNotSteadySts:=TRUE;
							END_IF
						END_IF
					ELSE(*已经进入稳态了*);
					END_IF
				ELSE(*低速都按照初始误差了*)
					byArcAdjSts:=0;(*强制使用初始误差*)
				END_IF
			END_FOR
		END_IF


		IF i_byKadj_SetType=3 THEN(*输出速度为定值*)
			rVel_Ki:=30;
		ELSE(*输出速度根据当前速度变化*)
			rVel_Ki:=i_iVel_Cur;
		END_IF
	ELSE(*使用初始增益*)
		byArcAdjSts:=0;
		xCutting:=FALSE;
		IF iErrValueListNum<>0 THEN
			iErrValueListNum:=0;
			SysMemSet(ADR(aiErrValueList),0,SIZEOF(aiErrValueList));
		END_IF


		IF i_byKadj_SetType=1 THEN(*输出速度为定值*)
			rVel_Ki:=30;
		ELSE(*输出速度根据当前速度变化*)
			rVel_Ki:=i_iVel_Cur;
		END_IF
	END_IF
ELSE
	byArcAdjSts:=0;
	xCutting:=FALSE;
	(*缓存清除*)
	IF iErrValueListNum<>0 THEN
		iErrValueListNum:=0;
		SysMemSet(ADR(aiErrValueList),0,SIZEOF(aiErrValueList));
	END_IF
	rVel_Ki:=i_iVel_Cur;(*按照当前速度输出@2024.9.6.124559*)
END_IF

(*未处理逐步切换*)
IF xUseInitKAdj THEN(*使用初始k*)
	rKadj_Pid:=i_rKadj_PID_Mol_Init;
	rKadj_I:=i_rKadj_I_Mol_Init;
ELSE(*使用状态k*)
	IF byArcAdjSts =1 THEN
		rKadj_Pid:=i_rKadj_PID_Mol_SteadySts;
		rKadj_I:=i_rKadj_I_Mol_SteadySts;
	ELSE
		rKadj_Pid:=i_rKadj_PID_Mol_Init;
		rKadj_I:=i_rKadj_I_Mol_Init;
	END_IF
END_IF



IF i_pbyArcAdjSts<>0 THEN
	i_pbyArcAdjSts^:=byArcAdjSts;
END_IF
IF i_prKadj_Pid<>0 THEN
	i_prKadj_Pid^:=rKadj_Pid;
END_IF
IF i_prKadj_I<>0 THEN
	i_prKadj_I^:=rKadj_I;
END_IF
IF i_pxCutting<>0 THEN
	i_pxCutting^:=xCutting;
END_IF
IF i_paiErrValueList<>0 THEN
	i_paiErrValueList^[0]:=iErrValueListNum;
	SysMemCpy(ADR(i_paiErrValueList^[1]),ADR(aiErrValueList),SIZEOF(aiErrValueList));
END_IF
IF i_prVel_Ki<>0 THEN
	i_prVel_Ki^:=rVel_Ki;
END_IF