(*@CES
Name=KS_A2B_SmoothDeal
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=9cfb7a1c-ce6a-4c3a-85a6-d0a941a33b90
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_A2B_SmoothDeal : REAL
(*从A变化到B平滑处理,返回当前值*)
VAR_INPUT
	i_rA:REAL;
	i_rB:REAL;
	i_rDelta:REAL;(*变化值*)
END_VAR
VAR
	rC:REAL;
END_VAR
{IMPLEMENTATION}
IF i_rDelta<>0 THEN
	IF i_rA > i_rB THEN
		rC:= i_rA - i_rDelta;
		IF rC < i_rB THEN(*限值处理*)
			rC:=i_rB;
		END_IF
	ELSIF i_rA < i_rB THEN
		rC:= i_rA + i_rDelta;
		IF rC > i_rB THEN(*限值处理*)
			rC:=i_rB;
		END_IF
	ELSE
		rC:= i_rB;
	END_IF
ELSE
	rC:=i_rB;
END_IF

KS_A2B_SmoothDeal:=rC;