(*@CES
Name=KS_GetInkGrooveBaseInf
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=6496d967-7a0d-4af8-a414-ba22caa8f71e
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetInkGrooveBaseInf : BOOL
(*获取油墨槽基准信息*)
VAR_INPUT
	i_xEn:BOOL;(*获取使能@当前位置是有效的@且不在运动中*)
	i_xGetBtn:BOOL;(*获取按钮@沿触发*)
	i_rGirth:REAL;(*此时的版周长@mm*)
	i_rPos_Cur:REAL;(*此时位置@mm*)
	i_pxBaseInfValid:POINTER TO BOOL;(*基准信息有效*)
	i_prGirth_Base:POINTER TO REAL;(*基准周长(mm)@以该周长作为基准,计算其他周长的变化量*)
	i_prPos_Base:POINTER TO REAL;(*基准位置(mm)@基准周长对应的位置*)
END_VAR
VAR
END_VAR
{IMPLEMENTATION}
IF i_prGirth_Base<>0 AND
	i_prPos_Base<>0 THEN
	IF i_xEn THEN
		IF i_xGetBtn THEN
			i_pxBaseInfValid^:=TRUE;
			i_prGirth_Base^:=i_rGirth;
			i_prPos_Base^:=i_rPos_Cur;
		END_IF
	END_IF
END_IF