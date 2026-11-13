(*@CES
Name=DECOUPLE_FOLLOW1_AddCoeff
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=a42bc11b-6918-460b-8e75-a424ada56d00
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION DECOUPLE_FOLLOW1_AddCoeff : BOOL
VAR_INPUT
(*IO*)
	i_rPI2:REAL;(*PI2*)
	i_rPI3:REAL;(*PI3*)
	i_rPI4:REAL;(*PI4*)
	i_rPI5:REAL;(*PI5*)
	i_rPI6:REAL;(*PI6*)
	i_rPI7:REAL;(*PI7*)
	i_rPI8:REAL;(*PI8*)
	i_rPI9:REAL;(*PI9*)
	i_rPI10:REAL;(*PI10*)
	i_rPI11:REAL;(*PI11*)
	i_rPI12:REAL;(*PI12*)
	i_rPI13:REAL;(*PI13*)



	i_prU2: POINTER TO REAL;(*解耦后控制器2输出*)
	i_prU3: POINTER TO REAL;(*解耦后控制器3输出*)
	i_prU4: POINTER TO REAL;(*解耦后控制器4输出*)
	i_prU5: POINTER TO REAL;(*解耦后控制器5输出*)
	i_prU6: POINTER TO REAL;(*解耦后控制器6输出*)
	i_prU7: POINTER TO REAL;(*解耦后控制器7输出*)
	i_prU8: POINTER TO REAL;(*解耦后控制器8输出*)
	i_prU9: POINTER TO REAL;(*解耦后控制器9输出*)
	i_prU10: POINTER TO REAL;(*解耦后控制器10输出*)
	i_prU11: POINTER TO REAL;(*解耦后控制器11输出*)
	i_prU12: POINTER TO REAL;(*解耦后控制器12输出*)
	i_prU13: POINTER TO REAL;(*解耦后控制器13输出*)



(*内部寄存器*)
(*控制器2*)
	i_prJIEOU2_Gc1_Uk:POINTER TO ARRAY [1..2] OF REAL;(*控制器2*中的Gc1输入寄存器*)
	i_prJIEOU2_Gc1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*控制器2*中的Gc1输出寄存器*)

(*控制器3*)
	i_prJIEOU3_Gc1_Uk:POINTER TO ARRAY [1..2] OF REAL;(*控制器3*中的Gc1输入寄存器*)
	i_prJIEOU3_Gc1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*控制器3*中的Gc1输出寄存器*)

(*控制器4*)
	i_prJIEOU4_Gc1_Uk:POINTER TO ARRAY [1..2] OF REAL;(*控制器4*中的Gc1输入寄存器*)
	i_prJIEOU4_Gc1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*控制器4*中的Gc1输出寄存器*)

(*控制器5*)
	i_prJIEOU5_Gc1_Uk:POINTER TO ARRAY [1..2] OF REAL;(*控制器5*中的Gc1输入寄存器*)
	i_prJIEOU5_Gc1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*控制器5*中的Gc1输出寄存器*)

(*控制器6*)
	i_prJIEOU6_Gc1_Uk:POINTER TO ARRAY [1..2] OF REAL;(*控制器6*中的Gc1输入寄存器*)
	i_prJIEOU6_Gc1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*控制器6*中的Gc1输出寄存器*)

(*控制器7*)
	i_prJIEOU7_Gc1_Uk:POINTER TO ARRAY [1..2] OF REAL;(*控制器7*中的Gc1输入寄存器*)
	i_prJIEOU7_Gc1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*控制器7*中的Gc1输出寄存器*)

(*控制器8*)
	i_prJIEOU8_Gc1_Uk:POINTER TO ARRAY [1..2] OF REAL;(*控制器8*中的Gc1输入寄存器*)
	i_prJIEOU8_Gc1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*控制器8*中的Gc1输出寄存器*)

(*控制器9*)
	i_prJIEOU9_Gc1_Uk:POINTER TO ARRAY [1..2] OF REAL;(*控制器9*中的Gc1输入寄存器*)
	i_prJIEOU9_Gc1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*控制器9*中的Gc1输出寄存器*)

(*控制器10*)
	i_prJIEOU10_Gc1_Uk:POINTER TO ARRAY [1..2] OF REAL;(*控制器10*中的Gc1输入寄存器*)
	i_prJIEOU10_Gc1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*控制器10*中的Gc1输出寄存器*)

(*控制器11*)
	i_prJIEOU11_Gc1_Uk:POINTER TO ARRAY [1..2] OF REAL;(*控制器11*中的Gc1输入寄存器*)
	i_prJIEOU11_Gc1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*控制器11*中的Gc1输出寄存器*)

(*控制器12*)
	i_prJIEOU12_Gc1_Uk:POINTER TO ARRAY [1..2] OF REAL;(*控制器12*中的Gc1输入寄存器*)
	i_prJIEOU12_Gc1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*控制器12*中的Gc1输出寄存器*)


(*系统参数*)
	i_rC:REAL;(*版周长mm*)
	i_rV:REAL;(*运行速度m/min*)
	i_rL:REAL;(*机组料长@m*)
(*控制参数*)
	i_bEn:BOOL;(*解耦使能 1：开解耦*)
	(*2024.7.24.103955+*)
	i_rTs:REAL;(*按圈解耦输入的是 版周长/速度@s
				周期解耦的话 就输入的是运动控制周期*)

	(*2024.9.10.162856+各色的机组料长*)
	i_xUseVarLenth:BOOL;(*使用可变料长标志@*)
	i_arL:ARRAY [1..16] OF REAL;(*色组机组料长@m*)
	i_pstStDeCoupleCoeff:POINTER TO StDeCoupleCoeff;(*2024.9.10.134022  耦合系数*)
END_VAR
VAR
(*A*)
	rA:REAL:=0;
	arA:ARRAY [2..16] OF REAL;
(*中间变量*)
	rTemp2:REAL:=0;
	rTemp3:REAL:=0;
	rTemp4:REAL:=0;
	rTemp5:REAL:=0;
	rTemp6:REAL:=0;
	rTemp7:REAL:=0;
	rTemp8:REAL:=0;
	rTemp9:REAL:=0;
	rTemp10:REAL:=0;
	rTemp11:REAL:=0;
	rTemp12:REAL:=0;
	rTemp13:REAL:=0;
	iI: INT:=0;
	iN: INT;

	iAxisId_Src: INT;
	arDeCoupleValue:ARRAY [2..15,3..16] OF REAL;(*最终解耦的量@[3,5]=3色计算的解耦量对5色叠加量@中间有个当量系数*)
	rTmp: REAL;
END_VAR
{IMPLEMENTATION}
IF i_pstStDeCoupleCoeff<>0 THEN;
ELSE
	RETURN;
END_IF
(*A*)
IF i_rL<>0 THEN
	rA:=i_rV/60.0/i_rL;
ELSE;
END_IF

FOR iN:=2 TO 16 BY 1 DO
	IF i_xUseVarLenth THEN
		IF i_arL[iN]<>0 THEN
			arA[iN]:=i_rV/60.0/i_arL[iN];
		ELSE;
		END_IF
	ELSE
		arA[iN]:=rA;
	END_IF
END_FOR
(*计算*)
(*控制器2 *)
Gc1_new(i_rPI2,ADR(rTemp2),i_rTs,arA[2],i_prJIEOU2_Gc1_Uk,i_prJIEOU2_Gc1_Yk);(*s/(s+A)*)
i_prU2^ := i_rPI2;
(*2024.9.10.150028+增益*)
iAxisId_Src:=2;
KS_GetDeCoupleValue(iAxisId_Src,rTemp2,i_pstStDeCoupleCoeff,ADR(arDeCoupleValue[iAxisId_Src,3]));


(*控制器3 *)
Gc1_new(i_rPI3,ADR(rTemp3),i_rTs,arA[3],i_prJIEOU3_Gc1_Uk,i_prJIEOU3_Gc1_Yk);(*s/(s+A)*)
(*2024.9.10.150028+增益*)
iAxisId_Src:=3;
KS_GetDeCoupleValue(iAxisId_Src,rTemp3,i_pstStDeCoupleCoeff,ADR(arDeCoupleValue[iAxisId_Src,3]));
(*输出*)
IF i_bEn<>0 THEN
(*	i_prU3^ := rTemp2+i_rPI3;*)
	i_prU3^ := arDeCoupleValue[2,3]+i_rPI3;
ELSE
	i_prU3^:=i_rPI3;
END_IF


(*控制器4 *)
Gc1_new(i_rPI4,ADR(rTemp4),i_rTs,arA[4],i_prJIEOU4_Gc1_Uk,i_prJIEOU4_Gc1_Yk);(*s/(s+A)*)
(*2024.9.10.150028+增益*)
iAxisId_Src:=4;
KS_GetDeCoupleValue(iAxisId_Src,rTemp4,i_pstStDeCoupleCoeff,ADR(arDeCoupleValue[iAxisId_Src,3]));
(*输出*)
IF i_bEn<>0 THEN
(*	i_prU4^ := rTemp2+rTemp3+i_rPI4;*)
	rTmp:=0;
	FOR iN:=2 TO iAxisId_Src-1 BY 1 DO
		rTmp:=rTmp+arDeCoupleValue[iN,iAxisId_Src];
	END_FOR
	i_prU4^ := rTmp+i_rPI4;
ELSE
	i_prU4^:=i_rPI4;
END_IF

(*控制器5 *)
Gc1_new(i_rPI5,ADR(rTemp5),i_rTs,arA[5],i_prJIEOU5_Gc1_Uk,i_prJIEOU5_Gc1_Yk);(*s/(s+A)*)
(*2024.9.10.150028+增益*)
iAxisId_Src:=5;
KS_GetDeCoupleValue(iAxisId_Src,rTemp5,i_pstStDeCoupleCoeff,ADR(arDeCoupleValue[iAxisId_Src,3]));
(*输出*)
IF i_bEn<>0 THEN
(*	i_prU5^ := rTemp2+rTemp3+rTemp4+i_rPI5;*)
	rTmp:=0;
	FOR iN:=2 TO iAxisId_Src-1 BY 1 DO
		rTmp:=rTmp+arDeCoupleValue[iN,iAxisId_Src];
	END_FOR
	i_prU5^ := rTmp+i_rPI5;
ELSE
	i_prU5^:=i_rPI5;
END_IF


(*控制器6 *)
Gc1_new(i_rPI6,ADR(rTemp6),i_rTs,arA[6],i_prJIEOU6_Gc1_Uk,i_prJIEOU6_Gc1_Yk);(*s/(s+A)*)
(*2024.9.10.150028+增益*)
iAxisId_Src:=6;
KS_GetDeCoupleValue(iAxisId_Src,rTemp6,i_pstStDeCoupleCoeff,ADR(arDeCoupleValue[iAxisId_Src,3]));
IF i_bEn<>0 THEN
(*	i_prU6^ :=rTemp2+rTemp3+rTemp4+rTemp5+i_rPI6;*)
	rTmp:=0;
	FOR iN:=2 TO iAxisId_Src-1 BY 1 DO
		rTmp:=rTmp+arDeCoupleValue[iN,iAxisId_Src];
	END_FOR
	i_prU6^ :=rTmp+i_rPI6;
ELSE
	i_prU6^:=i_rPI6;
END_IF

(*控制器7 *)
Gc1_new(i_rPI7,ADR(rTemp7),i_rTs,arA[7],i_prJIEOU7_Gc1_Uk,i_prJIEOU7_Gc1_Yk);(*s/(s+A)*)
(*2024.9.10.150028+增益*)
iAxisId_Src:=7;
KS_GetDeCoupleValue(iAxisId_Src,rTemp7,i_pstStDeCoupleCoeff,ADR(arDeCoupleValue[iAxisId_Src,3]));
IF i_bEn<>0 THEN
(*	i_prU7^ := rTemp2+rTemp3+rTemp4+rTemp5+rTemp6+i_rPI7;*)
	rTmp:=0;
	FOR iN:=2 TO iAxisId_Src-1 BY 1 DO
		rTmp:=rTmp+arDeCoupleValue[iN,iAxisId_Src];
	END_FOR
	i_prU7^ := rTmp+i_rPI7;
ELSE
	i_prU7^:=i_rPI7;
END_IF

(*控制器8 *)
Gc1_new(i_rPI8,ADR(rTemp8),i_rTs,arA[8],i_prJIEOU8_Gc1_Uk,i_prJIEOU8_Gc1_Yk);(*s/(s+A)*)
(*2024.9.10.150028+增益*)
iAxisId_Src:=8;
KS_GetDeCoupleValue(iAxisId_Src,rTemp8,i_pstStDeCoupleCoeff,ADR(arDeCoupleValue[iAxisId_Src,3]));
IF i_bEn<>0 THEN
(*	i_prU8^ :=rTemp2+rTemp3+rTemp4+rTemp5+rTemp6+rTemp7+i_rPI8;*)
	rTmp:=0;
	FOR iN:=2 TO iAxisId_Src-1 BY 1 DO
		rTmp:=rTmp+arDeCoupleValue[iN,iAxisId_Src];
	END_FOR
	i_prU8^ :=rTmp+i_rPI8;
ELSE
	i_prU8^:=i_rPI8;
END_IF

(*控制器9 *)
Gc1_new(i_rPI9,ADR(rTemp9),i_rTs,arA[9],i_prJIEOU9_Gc1_Uk,i_prJIEOU9_Gc1_Yk);(*s/(s+A)*)
(*2024.9.10.150028+增益*)
iAxisId_Src:=9;
KS_GetDeCoupleValue(iAxisId_Src,rTemp9,i_pstStDeCoupleCoeff,ADR(arDeCoupleValue[iAxisId_Src,3]));
IF i_bEn<>0 THEN
(*	i_prU9^ :=rTemp2+rTemp3+rTemp4+rTemp5+rTemp6+rTemp7+rTemp8+i_rPI9;*)
	rTmp:=0;
	FOR iN:=2 TO iAxisId_Src-1 BY 1 DO
		rTmp:=rTmp+arDeCoupleValue[iN,iAxisId_Src];
	END_FOR
	i_prU9^ :=rTmp+i_rPI9;
ELSE
	i_prU9^:=i_rPI9;
END_IF

(*控制器10 *)
Gc1_new(i_rPI10,ADR(rTemp10),i_rTs,arA[10],i_prJIEOU10_Gc1_Uk,i_prJIEOU10_Gc1_Yk);(*s/(s+A)*)
(*2024.9.10.150028+增益*)
iAxisId_Src:=10;
KS_GetDeCoupleValue(iAxisId_Src,rTemp10,i_pstStDeCoupleCoeff,ADR(arDeCoupleValue[iAxisId_Src,3]));
IF i_bEn<>0 THEN
	(*	i_prU10^ :=rTemp2+rTemp3+rTemp4+rTemp5+rTemp6+rTemp7+rTemp8+rTemp9+i_rPI10;*)
	rTmp:=0;
	FOR iN:=2 TO iAxisId_Src-1 BY 1 DO
		rTmp:=rTmp+arDeCoupleValue[iN,iAxisId_Src];
	END_FOR
	i_prU10^ :=rTmp+i_rPI10;
ELSE
	i_prU10^:=i_rPI10;
END_IF

(*控制器11 *)
Gc1_new(i_rPI11,ADR(rTemp11),i_rTs,arA[11],i_prJIEOU11_Gc1_Uk,i_prJIEOU11_Gc1_Yk);(*s/(s+A)*)
(*2024.9.10.150028+增益*)
iAxisId_Src:=11;
KS_GetDeCoupleValue(iAxisId_Src,rTemp11,i_pstStDeCoupleCoeff,ADR(arDeCoupleValue[iAxisId_Src,3]));
IF i_bEn<>0 THEN
(*	i_prU11^ :=rTemp2+rTemp3+rTemp4+rTemp5+rTemp6+rTemp7+rTemp8+rTemp9+rTemp10+i_rPI11;*)
	rTmp:=0;
	FOR iN:=2 TO iAxisId_Src-1 BY 1 DO
		rTmp:=rTmp+arDeCoupleValue[iN,iAxisId_Src];
	END_FOR
	i_prU11^ :=rTmp+i_rPI11;
ELSE
	i_prU11^:=i_rPI11;
END_IF

(*控制器12 *)
Gc1_new(i_rPI12,ADR(rTemp12),i_rTs,arA[12],i_prJIEOU12_Gc1_Uk,i_prJIEOU12_Gc1_Yk);(*s/(s+A)*)
(*2024.9.10.150028+增益*)
iAxisId_Src:=12;
KS_GetDeCoupleValue(iAxisId_Src,rTemp12,i_pstStDeCoupleCoeff,ADR(arDeCoupleValue[iAxisId_Src,3]));
IF i_bEn<>0 THEN
(*	i_prU12^ :=rTemp2+rTemp3+rTemp4+rTemp5+rTemp6+rTemp7+rTemp8+rTemp9+rTemp10+rTemp11+i_rPI12;*)
	rTmp:=0;
	FOR iN:=2 TO iAxisId_Src-1 BY 1 DO
		rTmp:=rTmp+arDeCoupleValue[iN,iAxisId_Src];
	END_FOR
	i_prU12^ :=rTmp+i_rPI12;
ELSE
	i_prU12^:=i_rPI12;
END_IF

(*控制器13 *)
IF i_bEn<>0 THEN
(*	i_prU13^ :=rTemp2+rTemp3+rTemp4+rTemp5+rTemp6+rTemp7+rTemp8+rTemp9+rTemp10+rTemp11+rTemp12+i_rPI13;*)
	rTmp:=0;
	FOR iN:=2 TO iAxisId_Src-1 BY 1 DO
		rTmp:=rTmp+arDeCoupleValue[iN,iAxisId_Src];
	END_FOR
	i_prU13^ :=rTmp+i_rPI13;
ELSE
	i_prU13^:=i_rPI13;
END_IF