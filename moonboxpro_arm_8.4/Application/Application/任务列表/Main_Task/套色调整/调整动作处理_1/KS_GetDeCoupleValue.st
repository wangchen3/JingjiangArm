(*@CES
Name=KS_GetDeCoupleValue
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=995c7d9f-9a05-4cb2-b6a6-1d5dc0875634
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetDeCoupleValue : BOOL
(*获取解耦量@经过一级增益输出*)
VAR_INPUT
	i_iUnitId:INT;(*输入解耦量的轴id*)
	i_rDeCoupleValue:REAL;(*输入的解耦量*)
	i_pstStDeCoupleCoeff:POINTER TO StDeCoupleCoeff;(*2024.9.10.134022  耦合系数*)
	i_parDeCopuleValue_Act:POINTER TO ARRAY [3..16] OF REAL;(*索引代表目标轴的解耦量*)
END_VAR
VAR
	iMaxDeCoupleAxis:INT:=16;(*参数*)
	arDeCopuleValue_Act: ARRAY [3..16] OF REAL;(*索引代表目标轴的解耦量*)
	iAxisId_Src: INT;(*耦合源的轴id*)
	iN: INT;
	rCoeffTmp: REAL;
	rDeCoupleValue: REAL;
END_VAR
{IMPLEMENTATION}
IF i_iUnitId>=2 AND
	i_iUnitId<=15 AND
	i_pstStDeCoupleCoeff<>0 AND
	i_parDeCopuleValue_Act<>0 THEN

	(*2024.9.10.150028+增益*)
	iAxisId_Src:=i_iUnitId;
	rDeCoupleValue:=i_rDeCoupleValue;
	FOR iN:=iAxisId_Src+1 TO iMaxDeCoupleAxis BY 1 DO
		rCoeffTmp:=KS_GetDecoupleCoeff(iAxisId_Src,iN,i_pstStDeCoupleCoeff);(*2色的调整量对3色的解耦系数*)
		//2025.11.16.110125 强制解耦系数=1
		rCoeffTmp := 1;
		arDeCopuleValue_Act[iN]:=KS_Gain(rDeCoupleValue,rCoeffTmp);(*增加了个增益|rCoeffTmp=1 则输出还是rDeCoupleValue*)
	END_FOR
ELSE;
END_IF

(*输出*)
IF i_parDeCopuleValue_Act<>0 THEN
	i_parDeCopuleValue_Act^:=arDeCopuleValue_Act;
END_IF