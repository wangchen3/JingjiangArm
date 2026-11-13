(*@CES
Name=Decouple_ALL
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=4a65de4b-fb01-4d32-a723-be267d5c50df
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION Decouple_ALL : REAL
(*Decouple_ALL为解耦FUN，输入每个色组PI控制器的原始输出，输出解耦后每个色组电机的输入值（替换掉原始的PI输出）。*)
(*2023.11.17.173924从实现来看，这里数值索引代表的是套色顺序不是轴顺序*)
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

	i_prU2: POINTER TO REAL;(*解耦后控制器2输出*)
	i_prU3: POINTER TO REAL;(*解耦后控制器3输出*)
	i_prU4: POINTER TO REAL;(*解耦后控制器4输出*)
	i_prU5: POINTER TO REAL;(*解耦后控制器5输出*)
	i_prU6: POINTER TO REAL;(*解耦后控制器6输出*)
	i_prU7: POINTER TO REAL;(*解耦后控制器7输出*)
	i_prU8: POINTER TO REAL;(*解耦后控制器8输出*)
	i_prU9: POINTER TO REAL;(*解耦后控制器9输出*)
	i_prU10: POINTER TO REAL;(*解耦后控制器10输出*)
(*系统参数*)
(*	i_rC:REAL;(*版周长mm*)*)(*2024.6.29.140358 屏蔽*)
	i_rV:REAL;(*运行速度m/min*)
	i_rL:REAL;(*机组料长m*)
(*输入输出寄存器*)
	i_prU2k:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器2*)
(*	i_prY2k:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输出寄存器2*) *)

	i_prU3k:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器3*)
	i_prY3k:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输出寄存器3*)

	i_prU4k:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器4*)
	i_prY4k:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输出寄存器4*)

	i_prU5k:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器5*)
	i_prY5k:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输出寄存器5*)

	i_prU6k:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器6*)
	i_prY6k:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输出寄存器6*)

	i_prU7k:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器7*)
	i_prY7k:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输出寄存器7*)

	i_prU8k:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器8*)
	i_prY8k:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输出寄存器8*)

	i_prU9k:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器9*)
	i_prY9k:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输出寄存器9*)

	i_prU10k:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器10*)
	i_prY10k:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输出寄存器10*)
(*内部寄存器*)
(*JIEOU3*)
(*	i_prGc1_1_Uk:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*Gc1_1输入寄存器*) *)(*i_prU2k 代替*)
	i_prJIEOU3_Gc1_1_Gc1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*JIEOU3中Gc1_1的Gc1输出寄存器*)

(*JIEOU4*)
	(*Gc1_1寄存器*)
(*	i_prGc1_1_Uk:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*Gc1_1输入寄存器*) *)(*i_prY3k代替*)
	i_prJIEOU4_Gc1_1_Gc1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc1_1 Gc1输出寄存器*)
	(*Gc2_1寄存器*)
(*	i_prGc2_1_Uk:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*Gc2_1输入寄存器*)*)(*i_prU2k代替*)
	i_prJIEOU4_Gc2_1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1输出寄存器*)

	i_prJIEOU4_Gc2_1_Gc1_Uk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1 Gc1输入寄存器*)
	i_prJIEOU4_Gc2_1_Gc2_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1 Gc2输出寄存器*)

(*JIEOU5*)
(*Gc1_1寄存器*)
(*	i_prGc1_1_Uk:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*Gc1_1输入寄存器*)*)(*i_prY4k代替*)
	i_prJIEOU5_Gc1_1_Gc1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc1_1 Gc1输出寄存器*)
(*Gc2_1寄存器*)
(*	i_prGc2_1_Uk:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*Gc2_1输入寄存器*)*)(*i_prY3k代替*)
	i_prJIEOU5_Gc2_1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1输出寄存器*)

	i_prJIEOU5_Gc2_1_Gc1_Uk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1 Gc1输入寄存器*)
	i_prJIEOU5_Gc2_1_Gc2_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1 Gc2输出寄存器*)

(*Gc2寄存器1*)
(*	i_prGc2Uk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2输入寄存器1*)*)(*i_prJIEOU4_Gc2_1_Yk代替*)
	i_prJIEOU5_Gc2Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2输出寄存器1*)

(*JIEOU6*)
(*Gc1_1寄存器*)
(*	i_prGc1_1_Uk:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*Gc1_1输入寄存器*)  *)(*i_prY5k代替*)
	i_prJIEOU6_Gc1_1_Gc1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc1_1 Gc1输出寄存器*)
(*Gc2_1寄存器*)
(*	i_prGc2_1_Uk:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*Gc2_1输入寄存器*)  *)(*i_prY4k代替*)
	i_prJIEOU6_Gc2_1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1输出寄存器*)

	i_prJIEOU6_Gc2_1_Gc1_Uk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1 Gc1输入寄存器*)
	i_prJIEOU6_Gc2_1_Gc2_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1 Gc2输出寄存器*)

(*Gc2寄存器1*)
(*	i_prJIEOU6_Gc2Uk_K4:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K4输入寄存器1*) *)(*i_prJIEOU5_Gc2Yk代替*)
	i_prJIEOU6_Gc2Yk_K4:POINTER TO ARRAY [1..2] OF REAL;(*Gc2输出寄存器1*)
(*Gc2寄存器2*)
(*	i_prJIEOU6_Gc2Uk_K3:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K3输入寄存器2*)  *)(*i_prJIEOU5_Gc2_1_Yk代替*)
	i_prJIEOU6_Gc2Yk_K3:POINTER TO ARRAY [1..2] OF REAL;(*Gc2输出寄存器2*)

(*JIEOU7*)
(*Gc1_1寄存器*)
(*	i_prGc1_1_Uk:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*Gc1_1输入寄存器*)  *)(*i_prY6k代替*)
	i_prJIEOU7_Gc1_1_Gc1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc1_1 Gc1输出寄存器*)
(*Gc2_1寄存器*)
(*	i_prGc2_1_Uk:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*Gc2_1输入寄存器*)  *)(*i_prY5k代替*)
	i_prJIEOU7_Gc2_1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1输出寄存器*)

	i_prJIEOU7_Gc2_1_Gc1_Uk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1 Gc1输入寄存器*)
	i_prJIEOU7_Gc2_1_Gc2_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1 Gc2输出寄存器*)

(*Gc2寄存器1*)
	i_prJIEOU7_Gc2Uk_K4:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K4输入寄存器1*)
	i_prJIEOU7_Gc2Yk_K4:POINTER TO ARRAY [1..2] OF REAL;(*Gc2输出寄存器1*)
(*Gc2寄存器2*)
(*	i_prJIEOU7_Gc2Uk_K3:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K3输入寄存器2*)  *)(*i_prJIEOU6_Gc2_1_Yk代替*)
	i_prJIEOU7_Gc2Yk_K3:POINTER TO ARRAY [1..2] OF REAL;(*Gc2输出寄存器2*)

(*JIEOU8*)
(*Gc1_1寄存器*)
(*	i_prGc1_1_Uk:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*Gc1_1输入寄存器*)  *)(*i_prY7k代替*)
	i_prJIEOU8_Gc1_1_Gc1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc1_1 Gc1输出寄存器*)
(*Gc2_1寄存器*)
(*	i_prGc2_1_Uk:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*Gc2_1输入寄存器*)  *)(*i_prY6k代替*)
	i_prJIEOU8_Gc2_1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1输出寄存器*)

	i_prJIEOU8_Gc2_1_Gc1_Uk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1 Gc1输入寄存器*)
	i_prJIEOU8_Gc2_1_Gc2_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1 Gc2输出寄存器*)

(*Gc2寄存器1*)
	i_prJIEOU8_Gc2Uk_K5:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K5输入寄存器1*)
	i_prJIEOU8_Gc2Yk_K5:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K5输出寄存器1*)
(*Gc2寄存器2*)
	i_prJIEOU8_Gc2Uk_K4:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K4输入寄存器2*)
	i_prJIEOU8_Gc2Yk_K4:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K4输出寄存器2*)
(*Gc2寄存器3*)
(*	i_prJIEOU7_Gc2Uk_K3:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K3输入寄存器3*)  *)(*i_prJIEOU7_Gc2_1_Yk代替*)
	i_prJIEOU8_Gc2Yk_K3:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K3输出寄存器3*)

(*JIEOU9*)
(*Gc1_1寄存器*)
(*	i_prGc1_1_Uk:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*Gc1_1输入寄存器*)  *)(*i_prY8k代替*)
	i_prJIEOU9_Gc1_1_Gc1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc1_1 Gc1输出寄存器*)
(*Gc2_1寄存器*)
(*	i_prGc2_1_Uk:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*Gc2_1输入寄存器*)  *)(*i_prY7k代替*)
	i_prJIEOU9_Gc2_1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1输出寄存器*)

	i_prJIEOU9_Gc2_1_Gc1_Uk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1 Gc1输入寄存器*)
	i_prJIEOU9_Gc2_1_Gc2_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1 Gc2输出寄存器*)

(*Gc2寄存器1*)
	i_prJIEOU9_Gc2Uk_K5:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K5输入寄存器1*)
	i_prJIEOU9_Gc2Yk_K5:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K5输出寄存器1*)
(*Gc2寄存器2*)
	i_prJIEOU9_Gc2Uk_K4:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K4输入寄存器2*)
	i_prJIEOU9_Gc2Yk_K4:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K4输出寄存器2*)
(*Gc2寄存器3*)
(*	i_prJIEOU9_Gc2Uk_K3:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K3输入寄存器3*)  *)(*i_prJIEOU8_Gc2_1_Yk代替*)
	i_prJIEOU9_Gc2Yk_K3:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K3输出寄存器3*)


(*JIEOU10*)
(*Gc1_1寄存器*)
(*	i_prGc1_1_Uk:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*Gc1_1输入寄存器*)  *)(*i_prY9k代替*)
	i_prJIEOU10_Gc1_1_Gc1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc1_1 Gc1输出寄存器*)
(*Gc2_1寄存器*)
(*	i_prGc2_1_Uk:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*Gc2_1输入寄存器*)  *)(*i_prY8k代替*)
	i_prJIEOU10_Gc2_1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1输出寄存器*)

	i_prJIEOU10_Gc2_1_Gc1_Uk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1 Gc1输入寄存器*)
	i_prJIEOU10_Gc2_1_Gc2_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1 Gc2输出寄存器*)

(*Gc2寄存器1*)
	i_prJIEOU10_Gc2Uk_K5:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K5输入寄存器1*)
	i_prJIEOU10_Gc2Yk_K5:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K5输出寄存器1*)
(*Gc2寄存器2*)
	i_prJIEOU10_Gc2Uk_K4:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K4输入寄存器2*)
	i_prJIEOU10_Gc2Yk_K4:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K4输出寄存器2*)
(*Gc2寄存器3*)
(*	i_prJIEOU10_Gc2Uk_K3:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K3输入寄存器3*)  *)(*i_prJIEOU9_Gc2_1_Yk代替*)
	i_prJIEOU10_Gc2Yk_K3:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_K3输出寄存器3*)



(*控制参数*)
	i_iN:INT;(*时延拍数N=TL/Ts+1*)
	i_bEn:BOOL;(*解耦使能 1：开解耦*)
	i_iNum:INT;(*机组解耦深度 （前几组解耦）@默认3*)
	(*2024.6.29.140218+*)
	i_rTs:REAL;(*按圈解耦输入的是 版周长/速度@s
				周期解耦的话 就输入的是运动控制周期*)
END_VAR
VAR
(*	rTs:REAL:=0;(*采样时间*)   *)
	iI: INT:=0;
(*内部控制变量*)
	bK3:BOOL:=1;
	bK4:BOOL:=1;
	bK5:BOOL:=1;
	bK6:BOOL:=1;
(*A*)
	rA:REAL:=0;
END_VAR
{IMPLEMENTATION}
(*2023.11.17.172430 防止数据溢出*)
IF i_iN>ARC_DELAY_N_MAX THEN
	i_iN:=ARC_DELAY_N_MAX;
END_IF

(*A*)
rA:=i_rV/60.0/i_rL;
(*控制变量赋值*)
IF i_iNum=2 THEN
	bK3:=0;
	bK4:=0;
	bK5:=0;
	bK6:=0;
ELSIF i_iNum=3 THEN
	bK3:=1;
	bK4:=0;
	bK5:=0;
	bK6:=0;
ELSIF i_iNum=4 THEN
	bK3:=1;
	bK4:=1;
	bK5:=0;
	bK6:=0;
ELSIF i_iNum=5 THEN
	bK3:=1;
	bK4:=1;
	bK5:=1;
	bK6:=0;
ELSIF i_iNum=6 THEN
	bK3:=1;
	bK4:=1;
	bK5:=1;
	bK6:=1;
END_IF

(*寄存器更新*)
(*U2*)
(*输入输出寄存器*)
FOR iI:=0 TO i_iN-2 BY 1 DO
	i_prU2k^[i_iN-iI]:=i_prU2k^[i_iN-iI-1];
END_FOR

(*U3  JIEOU3*)
(*输入输出寄存器*)
FOR iI:=0 TO i_iN-2 BY 1 DO
	i_prU3k^[i_iN-iI]:=i_prU3k^[i_iN-iI-1];
END_FOR

FOR iI:=0 TO i_iN-2 BY 1 DO
	i_prY3k^[i_iN-iI]:=i_prY3k^[i_iN-iI-1];
END_FOR

(*内部寄存器*)
i_prJIEOU3_Gc1_1_Gc1_Yk^[2]:=i_prJIEOU3_Gc1_1_Gc1_Yk^[1];

(*U4  JIEOU4*)
(*输入输出寄存器*)
FOR iI:=0 TO i_iN-2 BY 1 DO
	i_prU4k^[i_iN-iI]:=i_prU4k^[i_iN-iI-1];
END_FOR
FOR iI:=0 TO i_iN-2 BY 1 DO
	i_prY4k^[i_iN-iI]:=i_prY4k^[i_iN-iI-1];
END_FOR
(*内部寄存器*)
(*Gc1_1寄存器*)
i_prJIEOU4_Gc1_1_Gc1_Yk^[2]:=i_prJIEOU4_Gc1_1_Gc1_Yk^[1];
(*Gc2_1寄存器*)
i_prJIEOU4_Gc2_1_Yk^[2]:=i_prJIEOU4_Gc2_1_Yk^[1];

i_prJIEOU4_Gc2_1_Gc1_Uk^[2]:=i_prJIEOU4_Gc2_1_Gc1_Uk^[1];
i_prJIEOU4_Gc2_1_Gc2_Yk^[2]:=i_prJIEOU4_Gc2_1_Gc2_Yk^[1];

(*U5  JIEOU5*)
(*输入输出寄存器*)
FOR iI:=0 TO i_iN-2 BY 1 DO
	i_prU5k^[i_iN-iI]:=i_prU5k^[i_iN-iI-1];
END_FOR
FOR iI:=0 TO i_iN-2 BY 1 DO
	i_prY5k^[i_iN-iI]:=i_prY5k^[i_iN-iI-1];
END_FOR
(*内部寄存器*)
(*Gc2*)
i_prJIEOU5_Gc2Yk^[2]:=i_prJIEOU5_Gc2Yk^[1];

(*Gc1_1*)
i_prJIEOU5_Gc1_1_Gc1_Yk^[2]:=i_prJIEOU5_Gc1_1_Gc1_Yk^[1];

(*Gc2_1*)
i_prJIEOU5_Gc2_1_Yk^[2]:=i_prJIEOU5_Gc2_1_Yk^[1];

i_prJIEOU5_Gc2_1_Gc1_Uk^[2]:=i_prJIEOU5_Gc2_1_Gc1_Uk^[1];
i_prJIEOU5_Gc2_1_Gc2_Yk^[2]:=i_prJIEOU5_Gc2_1_Gc2_Yk^[1];

(*U6  JIEOU6*)
(*输入输出寄存器*)
FOR iI:=0 TO i_iN-2 BY 1 DO
	i_prU6k^[i_iN-iI]:=i_prU6k^[i_iN-iI-1];
END_FOR
FOR iI:=0 TO i_iN-2 BY 1 DO
	i_prY6k^[i_iN-iI]:=i_prY6k^[i_iN-iI-1];
END_FOR
(*内部寄存器*)
(*Gc2*)
i_prJIEOU6_Gc2Yk_K4^[2]:=i_prJIEOU6_Gc2Yk_K4^[1];
i_prJIEOU6_Gc2Yk_K3^[2]:=i_prJIEOU6_Gc2Yk_K3^[1];

(*Gc1_1*)
i_prJIEOU6_Gc1_1_Gc1_Yk^[2]:=i_prJIEOU6_Gc1_1_Gc1_Yk^[1];

(*Gc2_1*)
i_prJIEOU6_Gc2_1_Yk^[2]:=i_prJIEOU6_Gc2_1_Yk^[1];

i_prJIEOU6_Gc2_1_Gc1_Uk^[2]:=i_prJIEOU6_Gc2_1_Gc1_Uk^[1];
i_prJIEOU6_Gc2_1_Gc2_Yk^[2]:=i_prJIEOU6_Gc2_1_Gc2_Yk^[1];

(*U7  JIEOU7*)
(*输入输出寄存器*)
FOR iI:=0 TO i_iN-2 BY 1 DO
	i_prU7k^[i_iN-iI]:=i_prU7k^[i_iN-iI-1];
END_FOR
FOR iI:=0 TO i_iN-2 BY 1 DO
	i_prY7k^[i_iN-iI]:=i_prY7k^[i_iN-iI-1];
END_FOR
(*内部寄存器*)
(*Gc2*)
i_prJIEOU7_Gc2Uk_K4^[2]:=i_prJIEOU7_Gc2Uk_K4^[1];
i_prJIEOU7_Gc2Yk_K4^[2]:=i_prJIEOU7_Gc2Yk_K4^[1];

i_prJIEOU7_Gc2Yk_K3^[2]:=i_prJIEOU7_Gc2Yk_K3^[1];

(*Gc1_1*)
i_prJIEOU7_Gc1_1_Gc1_Yk^[2]:=i_prJIEOU7_Gc1_1_Gc1_Yk^[1];

(*Gc2_1*)
i_prJIEOU7_Gc2_1_Yk^[2]:=i_prJIEOU7_Gc2_1_Yk^[1];

i_prJIEOU7_Gc2_1_Gc1_Uk^[2]:=i_prJIEOU7_Gc2_1_Gc1_Uk^[1];
i_prJIEOU7_Gc2_1_Gc2_Yk^[2]:=i_prJIEOU7_Gc2_1_Gc2_Yk^[1];


(*U8  JIEOU8*)
(*输入输出寄存器*)
FOR iI:=0 TO i_iN-2 BY 1 DO
	i_prU8k^[i_iN-iI]:=i_prU8k^[i_iN-iI-1];
END_FOR
FOR iI:=0 TO i_iN-2 BY 1 DO
	i_prY8k^[i_iN-iI]:=i_prY8k^[i_iN-iI-1];
END_FOR
(*内部寄存器*)
(*Gc2*)
i_prJIEOU8_Gc2Uk_K5^[2]:=i_prJIEOU8_Gc2Uk_K5^[1];
i_prJIEOU8_Gc2Yk_K5^[2]:=i_prJIEOU8_Gc2Yk_K5^[1];

i_prJIEOU8_Gc2Uk_K4^[2]:=i_prJIEOU8_Gc2Uk_K4^[1];
i_prJIEOU8_Gc2Yk_K4^[2]:=i_prJIEOU8_Gc2Yk_K4^[1];

i_prJIEOU8_Gc2Yk_K3^[2]:=i_prJIEOU8_Gc2Yk_K3^[1];

(*Gc1_1*)
i_prJIEOU8_Gc1_1_Gc1_Yk^[2]:=i_prJIEOU8_Gc1_1_Gc1_Yk^[1];

(*Gc2_1*)
i_prJIEOU8_Gc2_1_Yk^[2]:=i_prJIEOU8_Gc2_1_Yk^[1];

i_prJIEOU8_Gc2_1_Gc1_Uk^[2]:=i_prJIEOU8_Gc2_1_Gc1_Uk^[1];
i_prJIEOU8_Gc2_1_Gc2_Yk^[2]:=i_prJIEOU8_Gc2_1_Gc2_Yk^[1];


(*U9  JIEOU9*)
(*输入输出寄存器*)
FOR iI:=0 TO i_iN-2 BY 1 DO
	i_prU9k^[i_iN-iI]:=i_prU9k^[i_iN-iI-1];
END_FOR
FOR iI:=0 TO i_iN-2 BY 1 DO
	i_prY9k^[i_iN-iI]:=i_prY9k^[i_iN-iI-1];
END_FOR
(*内部寄存器*)
(*Gc2*)
i_prJIEOU9_Gc2Uk_K5^[2]:=i_prJIEOU9_Gc2Uk_K5^[1];
i_prJIEOU9_Gc2Yk_K5^[2]:=i_prJIEOU9_Gc2Yk_K5^[1];

i_prJIEOU9_Gc2Uk_K4^[2]:=i_prJIEOU9_Gc2Uk_K4^[1];
i_prJIEOU9_Gc2Yk_K4^[2]:=i_prJIEOU9_Gc2Yk_K4^[1];

i_prJIEOU9_Gc2Yk_K3^[2]:=i_prJIEOU9_Gc2Yk_K3^[1];

(*Gc1_1*)
i_prJIEOU9_Gc1_1_Gc1_Yk^[2]:=i_prJIEOU9_Gc1_1_Gc1_Yk^[1];

(*Gc2_1*)
i_prJIEOU9_Gc2_1_Yk^[2]:=i_prJIEOU9_Gc2_1_Yk^[1];

i_prJIEOU9_Gc2_1_Gc1_Uk^[2]:=i_prJIEOU9_Gc2_1_Gc1_Uk^[1];
i_prJIEOU9_Gc2_1_Gc2_Yk^[2]:=i_prJIEOU9_Gc2_1_Gc2_Yk^[1];


(*U10  JIEOU10*)
(*输入输出寄存器*)
FOR iI:=0 TO i_iN-2 BY 1 DO
	i_prU10k^[i_iN-iI]:=i_prU10k^[i_iN-iI-1];
END_FOR
FOR iI:=0 TO i_iN-2 BY 1 DO
	i_prY10k^[i_iN-iI]:=i_prY10k^[i_iN-iI-1];
END_FOR
(*内部寄存器*)
(*Gc2*)
i_prJIEOU10_Gc2Uk_K5^[2]:=i_prJIEOU10_Gc2Uk_K5^[1];
i_prJIEOU10_Gc2Yk_K5^[2]:=i_prJIEOU10_Gc2Yk_K5^[1];

i_prJIEOU10_Gc2Uk_K4^[2]:=i_prJIEOU10_Gc2Uk_K4^[1];
i_prJIEOU10_Gc2Yk_K4^[2]:=i_prJIEOU10_Gc2Yk_K4^[1];

i_prJIEOU10_Gc2Yk_K3^[2]:=i_prJIEOU10_Gc2Yk_K3^[1];

(*Gc1_1*)
i_prJIEOU10_Gc1_1_Gc1_Yk^[2]:=i_prJIEOU10_Gc1_1_Gc1_Yk^[1];

(*Gc2_1*)
i_prJIEOU10_Gc2_1_Yk^[2]:=i_prJIEOU10_Gc2_1_Yk^[1];

i_prJIEOU10_Gc2_1_Gc1_Uk^[2]:=i_prJIEOU10_Gc2_1_Gc1_Uk^[1];
i_prJIEOU10_Gc2_1_Gc2_Yk^[2]:=i_prJIEOU10_Gc2_1_Gc2_Yk^[1];


(*计算*)
i_prU2^:=i_rPI2;

JIEOU3(i_rPI2,i_rPI3,i_prU3,i_rTs,rA,i_prU2k,i_prJIEOU3_Gc1_1_Gc1_Yk,i_iN,i_bEn);
i_prY3k^[1]:=i_prU3^;

JIEOU4(i_rPI2,i_prU3^,i_rPI4,i_prU4,i_rTs,rA,i_prY3k,i_prJIEOU4_Gc1_1_Gc1_Yk,i_prU2k,i_prJIEOU4_Gc2_1_Yk, i_prJIEOU4_Gc2_1_Gc1_Uk, i_prJIEOU4_Gc2_1_Gc2_Yk,i_iN,i_bEn);
i_prY4k^[1]:=i_prU4^;

JIEOU5(i_prJIEOU4_Gc2_1_Yk^[1],i_prU3^,i_prU4^,i_rPI5,i_prU5,i_rTs,rA,i_prY4k,i_prJIEOU5_Gc1_1_Gc1_Yk,i_prY3k,i_prJIEOU5_Gc2_1_Yk, i_prJIEOU5_Gc2_1_Gc1_Uk, i_prJIEOU5_Gc2_1_Gc2_Yk,i_prJIEOU4_Gc2_1_Yk,i_prJIEOU5_Gc2Yk,i_iN,i_bEn,bK3);
i_prY5k^[1]:=i_prU5^;

JIEOU6(i_prJIEOU5_Gc2Yk^[1],i_prJIEOU5_Gc2_1_Yk^[1],i_prU4^,i_prU5^,i_rPI6,
i_prU6,i_rTs,rA,i_prY5k,i_prJIEOU6_Gc1_1_Gc1_Yk,i_prY4k,i_prJIEOU6_Gc2_1_Yk,i_prJIEOU6_Gc2_1_Gc1_Uk,i_prJIEOU6_Gc2_1_Gc2_Yk,
i_prJIEOU5_Gc2Yk,i_prJIEOU6_Gc2Yk_K4,i_prJIEOU5_Gc2_1_Yk,i_prJIEOU6_Gc2Yk_K3,i_iN,i_bEn,bK3,bK4);
i_prY6k^[1]:=i_prU6^;

JIEOU7(i_prJIEOU6_Gc2Yk_K4^[1],i_prJIEOU6_Gc2Yk_K3^[1],i_prJIEOU6_Gc2_1_Yk^[1],i_prU5^,i_prU6^,i_rPI7,
i_prU7,i_rTs,rA,i_prY6k,i_prJIEOU7_Gc1_1_Gc1_Yk,i_prY5k,i_prJIEOU7_Gc2_1_Yk,i_prJIEOU7_Gc2_1_Gc1_Uk,i_prJIEOU7_Gc2_1_Gc2_Yk,
i_prJIEOU7_Gc2Uk_K4,i_prJIEOU7_Gc2Yk_K4,i_prJIEOU6_Gc2_1_Yk,i_prJIEOU7_Gc2Yk_K3,i_iN,i_bEn,bK3,bK4,bK5);
i_prY7k^[1]:=i_prU7^;

JIEOU8(i_prJIEOU6_Gc2Yk_K4^[1],i_prJIEOU6_Gc2Yk_K3^[1],i_prJIEOU7_Gc2Yk_K3^[1],i_prJIEOU7_Gc2_1_Yk^[1],i_prU6^,i_prU7^,i_rPI8,
i_prU8,i_rTs,rA,i_prY7k,i_prJIEOU8_Gc1_1_Gc1_Yk,i_prY6k,i_prJIEOU8_Gc2_1_Yk,i_prJIEOU8_Gc2_1_Gc1_Uk,i_prJIEOU8_Gc2_1_Gc2_Yk,
i_prJIEOU8_Gc2Uk_K5,i_prJIEOU8_Gc2Yk_K5,i_prJIEOU8_Gc2Uk_K4,i_prJIEOU8_Gc2Yk_K4,i_prJIEOU7_Gc2_1_Yk,i_prJIEOU8_Gc2Yk_K3,i_iN,i_bEn,bK3,bK4,bK5,bK6);
i_prY8k^[1]:=i_prU8^;

JIEOU9(i_prJIEOU8_Gc2Yk_K5^[1],i_prJIEOU7_Gc2Yk_K3^[1],i_prJIEOU8_Gc2Yk_K3^[1],i_prJIEOU8_Gc2_1_Yk^[1],i_prU7^,i_prU8^,i_rPI9,
i_prU9,i_rTs,rA,i_prY8k,i_prJIEOU9_Gc1_1_Gc1_Yk,i_prY7k,i_prJIEOU9_Gc2_1_Yk,i_prJIEOU9_Gc2_1_Gc1_Uk,i_prJIEOU9_Gc2_1_Gc2_Yk,
i_prJIEOU9_Gc2Uk_K5,i_prJIEOU9_Gc2Yk_K5,i_prJIEOU9_Gc2Uk_K4,i_prJIEOU9_Gc2Yk_K4,i_prJIEOU8_Gc2_1_Yk,i_prJIEOU9_Gc2Yk_K3,i_iN,i_bEn,bK3,bK4,bK5,bK6);
i_prY9k^[1]:=i_prU9^;

JIEOU10(i_prJIEOU9_Gc2Yk_K5^[1],i_prJIEOU8_Gc2Yk_K3^[1],i_prJIEOU9_Gc2Yk_K3^[1],i_prJIEOU9_Gc2_1_Yk^[1],i_prU8^,i_prU9^,i_rPI10,
i_prU10,i_rTs,rA,i_prY9k,i_prJIEOU10_Gc1_1_Gc1_Yk,i_prY8k,i_prJIEOU10_Gc2_1_Yk,i_prJIEOU10_Gc2_1_Gc1_Uk,i_prJIEOU10_Gc2_1_Gc2_Yk,
i_prJIEOU10_Gc2Uk_K5,i_prJIEOU10_Gc2Yk_K5,i_prJIEOU10_Gc2Uk_K4,i_prJIEOU10_Gc2Yk_K4,i_prJIEOU9_Gc2_1_Yk,i_prJIEOU10_Gc2Yk_K3,i_iN,i_bEn,bK3,bK4,bK5,bK6);
i_prY10k^[1]:=i_prU10^;