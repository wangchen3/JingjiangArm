(*@CES
Name=KS_AutoGetAxisIdDes
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=7287d099-c08a-4226-a3e8-15f3c52dcc8c
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_AutoGetAxisIdDes :INT(*自动获得码盘输出目标轴号*)
VAR_INPUT
	i_byGrpId:INT;(*系id*)
	i_xIsDualUwRw:BOOL;(*是否双收双放机型*)
	i_xAsOneMachine:BOOL;(*作为一台机器使用*)
	i_iGrpAxisTotalNum: INT;(*含牵引在的所有轴数量|*)
	i_paiGrpAxisList: POINTER TO ARRAY [1..MAX_STATION_NUM] OF INT;(*轴列表|有排序规则|*)
END_VAR
VAR
	iN: INT;
	iAxisIdDes: INT;
	iAxisId_Of_I:INT:=30;(*A系收牵*)
	iAxisId_Of_II:INT:=32;(*B系收牵|单收单放使用这个轴号*)
	iAxisId: INT;
	xAxisDesInRw: BOOL;(*TRUE 代表目标轴在收料侧|FALSE 代表在放料侧*)
	iAxisId_Of: INT;(*收牵轴号*)
END_VAR
{IMPLEMENTATION}
(*其实是可以不初始化的|功能自己会清除*)
xAxisDesInRw:=FALSE;
iAxisIdDes:=0;
iAxisId_Of:=iAxisId_Of_II;
IF i_paiGrpAxisList<>0 AND
	(i_byGrpId=1 OR
	i_byGrpId=2) THEN
	(*机型不同选择的目标轴号也不同*)
	IF i_xIsDualUwRw THEN(*双收双放*)
		IF i_xAsOneMachine THEN(*作为一台机器使用*)
			xAxisDesInRw:=TRUE;
			iAxisId_Of:=iAxisId_Of_II;
		ELSE(*作为两台机使用*)
			IF i_byGrpId=1 THEN(*A系*)
				xAxisDesInRw:=FALSE;
				iAxisId_Of:=iAxisId_Of_I;
			ELSE(*B系*)
				xAxisDesInRw:=TRUE;
				iAxisId_Of:=iAxisId_Of_II;
			END_IF
		END_IF
	ELSE(*单收单放*)
		(*输出到收料侧*)
		xAxisDesInRw:=TRUE;
		iAxisId_Of:=iAxisId_Of_II;
	END_IF

	FOR iN:=1 TO i_iGrpAxisTotalNum BY 1 DO(*查找目标输出轴号*)
		iAxisId:=i_paiGrpAxisList^[iN];
		IF iAxisId<>-1 THEN(*轴号正常*)
			IF xAxisDesInRw THEN(*目标轴在收料侧*)
				IF iAxisId<29 THEN(*查看色组轴*)
					iAxisIdDes:=iAxisId;(*不是牵引轴号我们取最后一个色组轴*)
				END_IF

				IF iAxisId=iAxisId_Of THEN(*轴号只要是收牵|我们就取这个轴作为目标轴号*)
					iAxisIdDes:=iAxisId;
					EXIT;
				END_IF
			ELSE(*目标轴在放料侧*)
				IF iN=1 THEN
					iAxisIdDes:=iAxisId;(*不是牵引轴号我们取第一个色组轴*)
				END_IF
				IF iAxisId=iAxisId_Of THEN(*轴号只要是收牵|我们就取这个轴作为目标轴号*)
					iAxisIdDes:=iAxisId;
					EXIT;
				END_IF
			END_IF
		END_IF
	END_FOR
END_IF
KS_AutoGetAxisIdDes:=iAxisIdDes;