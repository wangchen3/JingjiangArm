(*@CES
Name=KS_CheckArcIdValid
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=246184da-21c6-48ff-adc4-5d24f4660108
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CheckArcIdValid : BOOL
VAR_INPUT
	i_iAxisId:INT;(*轴id*)
	i_iArcId:INT;(*套色id@修改后的*)
	i_pabyColorIdCurrent: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*色组色序*)
END_VAR
VAR
	iN: INT;
	xValid:BOOL:=TRUE;(*默认是有效的*)	
END_VAR

{IMPLEMENTATION}
IF i_pabyColorIdCurrent<>0 THEN
	IF i_iAxisId>1 AND i_iArcId>1 THEN
		FOR iN:=1 TO i_iAxisId-1 BY 1 DO(*检查修改的轴前面的轴套色id*)			
			IF i_pabyColorIdCurrent^[iN]>1 THEN(**)
				IF i_iArcId>i_pabyColorIdCurrent^[iN] THEN(*新修改的比上面轴的大就行*);
				ELSE(*小于等于任何一个都认为是无效的*)
					xValid:=FALSE;
					EXIT;
				END_IF
			END_IF
		END_FOR
	END_IF
END_IF

KS_CheckArcIdValid:=xValid;