(*@CES
Name=KSIO_AD
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=aa598b09-6eb3-4e37-bb94-f4d8224e5ed0
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KSIO_AD : DINT
VAR_INPUT
	i_lrVolt: LREAL; (* 电压值 *)
	i_lrVolt_min: LREAL; (* 模拟量量程下限 *)
	i_lrVolt_max: LREAL; (* 模拟量量程上限 *)
	i_diRange_min: DINT; (* 数字量量程下限 *)
	i_diRange_max: DINT; (* 数字量量程上限 *)
END_VAR
VAR
	diResult: DINT;
	diRange_min: DINT;
	diRange_max: DINT;
END_VAR
{IMPLEMENTATION}
diResult:= 0;
IF i_lrVolt_min<>i_lrVolt_max THEN (*分母不能为0*)
	diResult:= LREAL_TO_DINT(i_diRange_min+(i_lrVolt-i_lrVolt_min)*(i_diRange_max-i_diRange_min)/(i_lrVolt_max-i_lrVolt_min)); (*计算实际的数字量*)

	(*取边界值*)
	IF i_diRange_max>=i_diRange_min THEN
		diRange_max:= i_diRange_max;
		diRange_min:= i_diRange_min;
	ELSE
		diRange_max:= i_diRange_min;
		diRange_min:= i_diRange_max;
	END_IF

	(*防止越界||*)
	IF diResult>diRange_max THEN
		diResult:= diRange_max;
	ELSIF diResult<diRange_min THEN
		diResult:= diRange_min;
	END_IF
END_IF

KSIO_AD:= diResult;