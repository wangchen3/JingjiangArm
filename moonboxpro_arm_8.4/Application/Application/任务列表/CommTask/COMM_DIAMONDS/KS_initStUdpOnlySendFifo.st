(*@CES
Name=KS_initStUdpOnlySendFifo
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=adc63081-b5d3-43ed-b864-3076b5b98476
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_initStUdpOnlySendFifo : INT
VAR_INPUT
	i_pstStUdpOnlySendFifo: POINTER TO StUdpOnlySendFifo;
END_VAR
VAR
	iResult: INT;
END_VAR

{IMPLEMENTATION}
iResult:= 0;
IF i_pstStUdpOnlySendFifo<>0 THEN
	i_pstStUdpOnlySendFifo^.byR:= 0;
	i_pstStUdpOnlySendFifo^.byW:= 0;
ELSE
	iResult:= -1;
END_IF
KS_initStUdpOnlySendFifo:= iResult;
