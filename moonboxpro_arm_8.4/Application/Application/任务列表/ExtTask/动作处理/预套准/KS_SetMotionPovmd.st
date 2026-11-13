(*@CES
Name=KS_SetMotionPovmd
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=ddeda59d-b720-4e82-aa52-b27576ad532a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_SetMotionPovmd : INT(*2022.7.8.175801  新增加了PT模式使能切换模式
需要再pt功能初始化完成后有效即：设置pt模式和模态后使用*)
VAR_INPUT
	i_iStationId:INT;(*站号|*)
	i_xSetMotionPovmdEn:BOOL;(*设置PT使能模式使能*)
	i_wMotorEnMode:WORD;
	(*电机使能模式|0: 不使能 1: 使能 3: 使能后轴可以手动转动 4: 取消模式3状态
	3、4以为的值都不允许set
	实际应用下会3、4状态下切换*)
END_VAR
VAR
	iRtn:INT;
	wMode: WORD;
END_VAR

{IMPLEMENTATION}
IF i_xSetMotionPovmdEn THEN
	wMode:=i_wMotorEnMode;
	IF (i_iStationId>=0 AND i_iStationId<MAX_UNIT_NUM) THEN
		IF wMode=3 OR wMode=4 THEN
			(*iRtn:= GTD_SetMotionPovmd(1,wMode,i_iStationId);*);(*临时屏蔽|2025.08.22.134427*)
		ELSE
			iRtn:=0;
		END_IF
	ELSE
		iRtn:=-1;
	END_IF
END_IF
KS_SetMotionPovmd:=iRtn;