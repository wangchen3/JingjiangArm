(*@CES
Name=KS_ButtonTipsDeal
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=5ebf7cae-3f30-4882-8889-64c24d28b024
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_ButtonTipsDeal : BOOL(*按钮使能提示处理*)
(*实现内容，界面按钮被点击的时候,在需要打开输出状态的时候输出提示标志,根据提示内容中确认和取消
决定最终是否打开输出状态*)
VAR_INPUT
	i_xCanSet:BOOL;(*可以直接设置标志@不需要提示*)
	i_xBtnTrig_Hmi:BOOL;(*界面按钮@需要外部清除形成沿触发*)
	i_xConfirOpen:BOOL;(*确认打开@沿触发*)
	i_xCancelTipsTrig:BOOL;(*取消提示@沿触发*)
	i_pxFlag_En:POINTER TO BOOL;(*使能标志@该标志有效才是真正意义的开启*)
	i_pxTipsDisPlay:POINTER TO BOOL;(*提示显示标志*)
END_VAR
VAR
	xFlag_En:BOOL;
	xTipsDisplay:BOOL;(*提示显示*)
END_VAR
{IMPLEMENTATION}
IF i_pxFlag_En<>0 AND
	i_pxTipsDisPlay<>0 THEN
	xFlag_En:=i_pxFlag_En^;
	xTipsDisplay:=i_pxTipsDisPlay^;

	IF i_xCanSet THEN(*此时可以直接修改*)
		IF i_xBtnTrig_Hmi THEN
			xFlag_En:=NOT xFlag_En;(*切换自动裁切标志*)
		END_IF
		xTipsDisplay:=FALSE;
	ELSE(*可以切换自动裁切标志@此时打开开关的时候需要提示*)
		IF i_xBtnTrig_Hmi THEN(*界面自动裁切打开被点了*)
			IF xFlag_En THEN(*已经打开了就直接关闭*)
				xFlag_En:=FALSE;
				xTipsDisplay:=FALSE;
			ELSE(*未打开的时候，提示根据选择决定是否打开*)
				xTipsDisplay:=TRUE;(*显示提示*)
			END_IF
		END_IF

		IF xTipsDisplay THEN
			(*确认可以打开*)
			IF i_xConfirOpen THEN
				xFlag_En:=TRUE;
				xTipsDisplay:=FALSE;
			END_IF

			(*取消提示*)
			IF i_xCancelTipsTrig THEN
				xTipsDisplay:=FALSE;
			END_IF
		END_IF
	END_IF
	i_pxFlag_En^:=xFlag_En;
	i_pxTipsDisPlay^:=xTipsDisplay;
END_IF