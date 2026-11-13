(*@CES
Name=KS_GetInitSts
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=7ae6f696-fe0b-48ae-942d-bfb0aac909fe
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetInitSts : BYTE(*获取初始值状态|返回修改的状态*)
VAR_INPUT
	i_bySwitchType:BYTE;(*切换方式|0-空转状态下不考虑单联动状态下都可以切换运动状态
								  |1-空转状态下只有处于联动状态下的轴可以切换*)
	i_xLinkageKnob: BOOL;(*联动旋钮*)
	i_xLinkageSts: BOOL;(*联动状态*)
END_VAR
VAR
	byAxisMotionSts: BYTE;
END_VAR
{IMPLEMENTATION}
IF i_bySwitchType=0 THEN(*空转状态下不考虑单联动状态下都可以切换运动状态*)
	IF i_xLinkageKnob THEN
		byAxisMotionSts:= 0;
	ELSE
		byAxisMotionSts:= 2;
	END_IF
ELSIF i_bySwitchType=1 THEN(*空转状态下只有处于联动状态下的轴可以切换*)
	IF i_xLinkageSts THEN
		byAxisMotionSts:=0;
	ELSE
		byAxisMotionSts:=2;
	END_IF
END_IF
KS_GetInitSts:=byAxisMotionSts;