(*@CES
Name=KSIO_DA
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=6e901fa2-602f-4438-9b06-80acf888523a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KSIO_DA : LREAL
VAR_INPUT
	i_iData: INT; (* 数值输入/由于发现外部使用时直接WORD_TO_DINT()造成边界错误/修复输入类型/2020.1.2.093534_ *)
	i_lrVolt_min: LREAL; (* 模拟量量程下限 *)
	i_lrVolt_max: LREAL; (* 模拟量量程上限 *)
	i_diRange_min: DINT; (* 数字量量程下限 *)
	i_diRange_max: DINT; (* 数字量量程上限 *)
END_VAR
VAR
	lrVolt_min: LREAL;
	lrVolt_max: LREAL;
	lrResult: LREAL;
	diTmpData: DINT; (* 2020.1.2.093627_ *)
END_VAR
{IMPLEMENTATION}
lrResult:= 0;
diTmpData:= INT_TO_DINT(i_iData); (* 2020.1.2.093707_ *)
IF i_diRange_min<>i_diRange_max THEN (* 分母不能为0 *)
	lrResult:= i_lrVolt_min+(diTmpData-i_diRange_min)*(i_lrVolt_max-i_lrVolt_min)/(i_diRange_max-i_diRange_min); (* 计算实际的电压值 *)

	(* 取边界值 *)
	IF i_lrVolt_max>=i_lrVolt_min THEN
		lrVolt_max:= i_lrVolt_max;
		lrVolt_min:= i_lrVolt_min;
	ELSE
		lrVolt_max:= i_lrVolt_min;
		lrVolt_min:= i_lrVolt_max;
	END_IF

	(* 如果超边界就取边界值好了 *)
	IF lrResult>lrVolt_max THEN
		lrResult:= lrVolt_max;
	ELSIF lrResult<lrVolt_min THEN
		lrResult:= lrVolt_min;
	END_IF
END_IF

KSIO_DA:= lrResult;