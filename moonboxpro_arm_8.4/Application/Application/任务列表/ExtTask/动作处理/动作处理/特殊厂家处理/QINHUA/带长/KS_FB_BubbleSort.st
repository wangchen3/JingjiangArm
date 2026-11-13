(*@CES
Name=KS_FB_BubbleSort
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=b2f07950-3780-485f-8a02-a8bc89709713
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_BubbleSort 
VAR_INPUT
	i_plrArrList : POINTER TO ARRAY[1..100] OF LREAL;
	i_iLeft : INT;
	i_iRight : INT;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	i, j : INT;           // 循环索引和临时变量 
	lrtemp : lREAL;
END_VAR

{IMPLEMENTATION}
FOR i := i_iLeft TO i_iRight DO 
    FOR j := i_iLeft TO i_iRight - i DO 
        IF i_plrArrList^[j] > i_plrArrList^[j + 1] THEN 
            // 交换元素 
            lrtemp := i_plrArrList^[j];
            i_plrArrList^[j] := i_plrArrList^[j + 1];
            i_plrArrList^[j + 1] :=lrtemp;
        END_IF 
    END_FOR 
END_FOR 