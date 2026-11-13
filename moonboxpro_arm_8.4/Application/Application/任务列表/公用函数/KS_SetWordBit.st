(*@CES
Name=KS_SetWordBit
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=02828fa7-5c3c-4227-9d4b-97efc9023b71
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_SetWordBit : BOOL(*设置word位*)
VAR_INPUT
	i_byBitId:BYTE;(*0--15*)
	i_xSetBool:BOOL;
	i_pwValue:POINTER TO WORD;
END_VAR
VAR
	wTmp: WORD;
	xSetDne: BOOL;
END_VAR
{IMPLEMENTATION}
IF i_byBitId>=0 AND
	i_byBitId<16 THEN

	wTmp:=16#00000001;
	wTmp:=SHL(wTmp,i_byBitId);

	IF i_pwValue<>0 THEN
		IF i_xSetBool THEN(*写1*)
			i_pwValue^:=i_pwValue^ OR wTmp;
		ELSE(*写0*)
			wTmp:=NOT wTmp;(*先取反*)
			i_pwValue^:=i_pwValue^ AND wTmp;
		END_IF

		xSetDne:=TRUE;
	END_IF
ELSE;
END_IF
KS_SetWordBit:=xSetDne;