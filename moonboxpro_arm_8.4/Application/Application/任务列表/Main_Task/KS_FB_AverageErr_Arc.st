(*@CES
Name=KS_FB_AverageErr_Arc
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=91f3b4d4-1a1f-49cc-9d09-db86b76ec74e
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AverageErr_Arc
VAR_INPUT
	i_xEn: BOOL;
	i_iErr: INT;(*输入的有效误差*)
	i_xErrValid: BOOL;(*误差有效性*)
	i_byAverageNum: BYTE;(*误差平均次数*)
END_VAR
VAR_OUTPUT
	o_xEn: BOOL;
	o_iErNo: INT;
	o_iErrResult: INT;
END_VAR
VAR
	rErrResult: REAL;(*误差平均使用的*)
	iBufferedIndexRd				: INT							;(*buffered array read index|*)
	iBufferedIndexWr				: INT							;(*buffered array write index|*)
	iPushedErrItemsAtLeast			: INT							;
	arErrorBuffered			: ARRAY [1..20] OF REAL						;
	iCountForSignalLost				: INT	;
	rSumTotal						: REAL;
	iIndex							: INT;
END_VAR

{IMPLEMENTATION}
o_xEn:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	IF i_byAverageNum>0 THEN
		rErrResult:= INT_TO_REAL(i_iErr);
		IF i_xErrValid THEN
			iBufferedIndexWr:= iBufferedIndexWr+1;	
			IF iBufferedIndexWr>20 THEN
				iBufferedIndexWr:= iBufferedIndexWr-20;
			END_IF
			arErrorBuffered[iBufferedIndexWr]:= rErrResult;
			IF iPushedErrItemsAtLeast<i_byAverageNum THEN
				iPushedErrItemsAtLeast:= iPushedErrItemsAtLeast+1;
			ELSE
				IF i_byAverageNum>1 THEN
					iBufferedIndexRd:= iBufferedIndexWr;
					rSumTotal:= 0;
					FOR iIndex:=1 TO i_byAverageNum BY 1 DO
						rSumTotal:= rSumTotal+arErrorBuffered[iBufferedIndexRd];
						iBufferedIndexRd:= iBufferedIndexRd-1;
						IF iBufferedIndexRd<1 THEN
							iBufferedIndexRd:= iBufferedIndexRd+20;
						END_IF
					END_FOR
					rErrResult:= rSumTotal/i_byAverageNum;		
				END_IF
			END_IF
			iCountForSignalLost:= 0;
			o_iErrResult:= REAL_TO_INT(rErrResult) ;
		ELSE(*连续丢失3幅就重新开始计算平均*)
			iCountForSignalLost:= 	iCountForSignalLost+1;
			IF 	iCountForSignalLost>3 THEN
				iBufferedIndexWr:= 0;
				iPushedErrItemsAtLeast:= 0;
			END_IF
			o_iErNo:= -1;
		END_IF
	ELSE
		o_iErrResult:= i_iErr;
	END_IF
END_IF