(*@CES
Name=StArcCoupleRegister_Follow1
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=d7272d1a-800d-4715-ade9-af56f66c62a8
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StArcCoupleRegister_Follow1 :(*解耦寄存器@跟踪第一色*)
STRUCT

(*内部寄存器*)
(*控制器2*)
	rJIEOU2_Gc1_Uk:ARRAY [1..2] OF REAL;(*控制器2*中的Gc1输入寄存器*)
	rJIEOU2_Gc1_Yk:ARRAY [1..2] OF REAL;(*控制器2*中的Gc1输出寄存器*)

(*控制器3*)
	rJIEOU3_Gc1_Uk:ARRAY [1..2] OF REAL;(*控制器3*中的Gc1输入寄存器*)
	rJIEOU3_Gc1_Yk:ARRAY [1..2] OF REAL;(*控制器3*中的Gc1输出寄存器*)

(*控制器4*)
	rJIEOU4_Gc1_Uk:ARRAY [1..2] OF REAL;(*控制器4*中的Gc1输入寄存器*)
	rJIEOU4_Gc1_Yk:ARRAY [1..2] OF REAL;(*控制器4*中的Gc1输出寄存器*)

(*控制器5*)
	rJIEOU5_Gc1_Uk:ARRAY [1..2] OF REAL;(*控制器5*中的Gc1输入寄存器*)
	rJIEOU5_Gc1_Yk:ARRAY [1..2] OF REAL;(*控制器5*中的Gc1输出寄存器*)

(*控制器6*)
	rJIEOU6_Gc1_Uk:ARRAY [1..2] OF REAL;(*控制器6*中的Gc1输入寄存器*)
	rJIEOU6_Gc1_Yk:ARRAY [1..2] OF REAL;(*控制器6*中的Gc1输出寄存器*)

(*控制器7*)
	rJIEOU7_Gc1_Uk:ARRAY [1..2] OF REAL;(*控制器7*中的Gc1输入寄存器*)
	rJIEOU7_Gc1_Yk:ARRAY [1..2] OF REAL;(*控制器7*中的Gc1输出寄存器*)

(*控制器8*)
	rJIEOU8_Gc1_Uk:ARRAY [1..2] OF REAL;(*控制器8*中的Gc1输入寄存器*)
	rJIEOU8_Gc1_Yk:ARRAY [1..2] OF REAL;(*控制器8*中的Gc1输出寄存器*)


(*控制器9*)
	rJIEOU9_Gc1_Uk:ARRAY [1..2] OF REAL;(*控制器9*中的Gc1输入寄存器*)
	rJIEOU9_Gc1_Yk:ARRAY [1..2] OF REAL;(*控制器9*中的Gc1输出寄存器*)


(*控制器10*)
	rJIEOU10_Gc1_Uk:ARRAY [1..2] OF REAL;(*控制器10*中的Gc1输入寄存器*)
	rJIEOU10_Gc1_Yk:ARRAY [1..2] OF REAL;(*控制器10*中的Gc1输出寄存器*)


(*控制器11*)
	rJIEOU11_Gc1_Uk:ARRAY [1..2] OF REAL;(*控制器11*中的Gc1输入寄存器*)
	rJIEOU11_Gc1_Yk:ARRAY [1..2] OF REAL;(*控制器11*中的Gc1输出寄存器*)


(*控制器12*)
	rJIEOU12_Gc1_Uk:ARRAY [1..2] OF REAL;(*控制器12*中的Gc1输入寄存器*)
	rJIEOU12_Gc1_Yk:ARRAY [1..2] OF REAL;(*控制器12*中的Gc1输出寄存器*)


END_STRUCT
END_TYPE

{IMPLEMENTATION}
