(*@CES
Name=KS_GetHorizonManuAdj
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=d3a21ffb-1d17-434b-a6db-735f209d6991
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetHorizonManuAdj : INT(*界面手动调整量2018.9.4.093836*)(*um*)(*返回值为实际需要调整的量，-22222为参数异常*)
(*2022.2.18.164444 按钮方向方向和运动方向相关了*)
(*增加了注释文字@正值是向操作侧@负值是向传动侧@已经和电机旋转方向相关了*)
(*2023.3.9.225628 通过查看动态库发现,动态库中将原来的左按钮赋值为otostudio约定的右按钮
右按钮赋值为otostudio的左按钮
@以前约定向左pabyHorManuBtn= 1 2 5
@向右pabyHorManuBtn=3 4 6
为了不修改动态库,在这里再进行一次取反以保证一致！！@将i_xHorManuDirSwitch=true*)
(*2024.11.6.093600 同步*)
(*2024.11.5.110659*)
(*重新处理界面手动按钮清理，防止整体清除界面手动按钮时B系被A系清理掉了*)
VAR_INPUT
	i_xHorManuDirSwitch:BOOL;(*方向取反*)
	i_iHorManuAdj_Step:INT;(*横向手动调整当量um*)
	i_iHorManuAdj_FastStep:INT;(*横向手动快速调整当量um*)
	i_iHorManuAdj_MidStep:INT;(*横向手动快速调整当量um*)
	piUnitId:POINTER TO INT;(*色组号*)

	pabyHorManuBtn:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*横向手动按钮，0为不调整，1为左向慢调0.05mm，2为左向快调暂定为0.5mm；3为右向慢调，4为右向快调；
										这里界面上的按钮只控制左右，逻辑控制横向电机是向传动侧还是操作侧运动*)
	padiHorAdjustMent:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF DINT;(*横向手动调整的量*)
	i_iGrpAxisNum_Pu:INT;
	i_abyGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF BYTE; (*系的轴列表*)
	i_pstStSysParam: POINTER TO StSysParam;
END_VAR
VAR
	iN: INT;
	iCoeff: INT;(*方向系数*)
	iResult: INT;
	iUnitId: INT;
END_VAR


{IMPLEMENTATION}
KS_GetHorizonManuAdj:=0;
IF pabyHorManuBtn<>0 AND padiHorAdjustMent<>0 AND piUnitId<>0 THEN(*指针合法性检查*);
ELSE
	KS_GetHorizonManuAdj:=-22222;(*特殊值标识报警*)
	RETURN;
END_IF

piUnitId^:=0;
IF i_iHorManuAdj_Step<=0 THEN
	i_iHorManuAdj_Step:=50;(*0.05MM*)
ELSE;
END_IF

IF i_iHorManuAdj_FastStep<=0 THEN
	i_iHorManuAdj_FastStep:=500;(*0.5MM*)
ELSE;
END_IF
(*2022.8.9.094516处理0.02档位*)
IF i_iHorManuAdj_MidStep<=0 THEN
	i_iHorManuAdj_FastStep:=100;(*0.1MM*)
ELSE;
END_IF
(*一个周期只处理一个轴*)(*调整量的正值代表向操作侧运动*)
(*2021.10.26.091200  使用轴列表变量*)
FOR iUnitId:=1 TO i_iGrpAxisNum_Pu BY 1 DO(*检查所有色组*)
	iN:=i_abyGrpAxisList[iUnitId];
(*方向*)
	iCoeff:=0;
(*增加0.02档位2022.8.9.094247||*)
(*	IF  pabyHorManuBtn^[iN]=1 OR  pabyHorManuBtn^[iN]=2  THEN(*向左*)*)
	IF  pabyHorManuBtn^[iN]=1 OR  pabyHorManuBtn^[iN]=2 OR  pabyHorManuBtn^[iN]=5 THEN(*向左*)
		IF i_pstStSysParam^.astStUnitParam_UnSave[iN].xMotRev_PrnRoller THEN (*电机反转*)(*向左是向传动侧运动*)
			iCoeff:=-1;
		ELSE(*电机正转*)(*向左是向操作侧运动*)
			iCoeff:=1;
		END_IF
	ELSIF  pabyHorManuBtn^[iN]=3 OR  pabyHorManuBtn^[iN]=4 OR  pabyHorManuBtn^[iN]=6 THEN (*向右*)(*和向左取反*)
		IF i_pstStSysParam^.astStUnitParam_UnSave[iN].xMotRev_PrnRoller THEN (*电机反转*)
			iCoeff:=1;
		ELSE(*电机正转*)
			iCoeff:=-1;
		END_IF
	END_IF

	IF i_xHorManuDirSwitch THEN
		iCoeff:=-iCoeff;
	END_IF
(*调整量值*)
	iResult:=0;
	IF  pabyHorManuBtn^[iN]=1 OR  pabyHorManuBtn^[iN]=3 THEN (*都是慢调*)
		iResult:=(i_iHorManuAdj_Step);
	ELSIF pabyHorManuBtn^[iN]=2 OR  pabyHorManuBtn^[iN]=4 THEN (*都是快调*)
		iResult:=(i_iHorManuAdj_FastStep);
	ELSIF pabyHorManuBtn^[iN]=5 OR  pabyHorManuBtn^[iN]=6 THEN (*中间档位-202022.8.9.094640*)
		iResult:=(i_iHorManuAdj_MidStep);
	END_IF
	iResult:=iResult*iCoeff;

	IF i_pstStSysParam^.astStUnitParam_Save[iN].xLinkage THEN (*检查联动轴*)
		IF pabyHorManuBtn^[iN]<>0 THEN (*说明有调整按下了*)
			pabyHorManuBtn^[iN]:=0;(*清零按钮标志*)(*2024.11.5.110459*)
			KS_GetHorizonManuAdj:=iResult;(*将调整量输出*)
			piUnitId^:=iN;
			padiHorAdjustMent^[iN]:=padiHorAdjustMent^[iN]+iResult;(*在界面显示*)
			EXIT;
		END_IF
	ELSE
		pabyHorManuBtn^[iN]:=0;(*清零按钮标志*)(*2024.11.5.110459*)
	END_IF
END_FOR
