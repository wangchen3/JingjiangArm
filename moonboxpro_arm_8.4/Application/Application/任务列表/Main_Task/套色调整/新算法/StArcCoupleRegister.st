(*@CES
Name=StArcCoupleRegister
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=014f585b-ff6a-407f-8a06-d08ac4655030
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StArcCoupleRegister :
(*套色耦合寄存器参数@华南理工小黄实现@2023.11.18.192510*)
STRUCT
	(*输入输出寄存器*)
	arU2k: ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器2*)

	arU3k: ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器3*)
	arY3k: ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输出寄存器3*)

	arU4k: ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器4*)
	arY4k: ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输出寄存器4*)

	arU5k: ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器5*)
	arY5k: ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输出寄存器5*)

	arU6k: ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器6*)
	arY6k: ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输出寄存器6*)

	arU7k: ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器7*)
	arY7k: ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输出寄存器7*)

	arU8k: ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器8*)
	arY8k: ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输出寄存器8*)

	arU9k: ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器9*)
	arY9k: ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输出寄存器9*)

	arU10k: ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器10*)
	arY10k: ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输出寄存器10*)

	arU11k: ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器11*)
	arY11k: ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输出寄存器11*)

	arU12k: ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器12*)
	arY12k: ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输出寄存器12*)
	(*内部寄存器*)
	(*JIEOU3*)
	arJIEOU3_Gc1_1_Gc1_Yk: ARRAY [1..2] OF REAL;(*JIEOU3中Gc1_1的Gc1输出寄存器*)

	(*JIEOU4*)
	(*Gc1_1寄存器*)
	arJIEOU4_Gc1_1_Gc1_Yk: ARRAY [1..2] OF REAL;(*Gc1_1 Gc1输出寄存器*)
	(*Gc2_1寄存器*)
	arJIEOU4_Gc2_1_Yk: ARRAY [1..2] OF REAL;(*Gc2_1输出寄存器*)

	arJIEOU4_Gc2_1_Gc1_Uk: ARRAY [1..2] OF REAL;(*Gc2_1 Gc1输入寄存器*)
	arJIEOU4_Gc2_1_Gc2_Yk: ARRAY [1..2] OF REAL;(*Gc2_1 Gc2输出寄存器*)

	(*JIEOU5*)
	(*Gc1_1寄存器*)
	arJIEOU5_Gc1_1_Gc1_Yk: ARRAY [1..2] OF REAL;(*Gc1_1 Gc1输出寄存器*)
	(*Gc2_1寄存器*)
	arJIEOU5_Gc2_1_Yk: ARRAY [1..2] OF REAL;(*Gc2_1输出寄存器*)

	arJIEOU5_Gc2_1_Gc1_Uk: ARRAY [1..2] OF REAL;(*Gc2_1 Gc1输入寄存器*)
	arJIEOU5_Gc2_1_Gc2_Yk: ARRAY [1..2] OF REAL;(*Gc2_1 Gc2输出寄存器*)

	(*Gc2寄存器1*)
	arJIEOU5_Gc2Yk: ARRAY [1..2] OF REAL;(*Gc2输出寄存器1*)

	(*JIEOU6*)
	(*Gc1_1寄存器*)
	arJIEOU6_Gc1_1_Gc1_Yk: ARRAY [1..2] OF REAL;(*Gc1_1 Gc1输出寄存器*)
	(*Gc2_1寄存器*)
	arJIEOU6_Gc2_1_Yk: ARRAY [1..2] OF REAL;(*Gc2_1输出寄存器*)

	arJIEOU6_Gc2_1_Gc1_Uk: ARRAY [1..2] OF REAL;(*Gc2_1 Gc1输入寄存器*)
	arJIEOU6_Gc2_1_Gc2_Yk: ARRAY [1..2] OF REAL;(*Gc2_1 Gc2输出寄存器*)

	(*Gc2寄存器1*)
	arJIEOU6_Gc2Yk_K4: ARRAY [1..2] OF REAL;(*Gc2输出寄存器1*)
	(*Gc2寄存器2*)
	arJIEOU6_Gc2Yk_K3: ARRAY [1..2] OF REAL;(*Gc2输出寄存器2*)

	(*JIEOU7*)
	(*Gc1_1寄存器*)
	arJIEOU7_Gc1_1_Gc1_Yk: ARRAY [1..2] OF REAL;(*Gc1_1 Gc1输出寄存器*)
	(*Gc2_1寄存器*)
	arJIEOU7_Gc2_1_Yk: ARRAY [1..2] OF REAL;(*Gc2_1输出寄存器*)

	arJIEOU7_Gc2_1_Gc1_Uk: ARRAY [1..2] OF REAL;(*Gc2_1 Gc1输入寄存器*)
	arJIEOU7_Gc2_1_Gc2_Yk: ARRAY [1..2] OF REAL;(*Gc2_1 Gc2输出寄存器*)

	(*Gc2寄存器1*)
	arJIEOU7_Gc2Uk_K4: ARRAY [1..2] OF REAL;(*Gc2_K4输入寄存器1*)
	arJIEOU7_Gc2Yk_K4: ARRAY [1..2] OF REAL;(*Gc2输出寄存器1*)
	(*Gc2寄存器2*)
	arJIEOU7_Gc2Yk_K3: ARRAY [1..2] OF REAL;(*Gc2输出寄存器2*)

	(*JIEOU8*)
	(*Gc1_1寄存器*)
	arJIEOU8_Gc1_1_Gc1_Yk: ARRAY [1..2] OF REAL;(*Gc1_1 Gc1输出寄存器*)
	(*Gc2_1寄存器*)
	arJIEOU8_Gc2_1_Yk: ARRAY [1..2] OF REAL;(*Gc2_1输出寄存器*)

	arJIEOU8_Gc2_1_Gc1_Uk: ARRAY [1..2] OF REAL;(*Gc2_1 Gc1输入寄存器*)
	arJIEOU8_Gc2_1_Gc2_Yk: ARRAY [1..2] OF REAL;(*Gc2_1 Gc2输出寄存器*)

	(*Gc2寄存器1*)
	arJIEOU8_Gc2Uk_K5: ARRAY [1..2] OF REAL;(*Gc2_K4输入寄存器1*)
	arJIEOU8_Gc2Yk_K5: ARRAY [1..2] OF REAL;(*Gc2输出寄存器1*)
	(*Gc2寄存器2*)
	arJIEOU8_Gc2Uk_K4: ARRAY [1..2] OF REAL;(*Gc2_K4输入寄存器2*)
	arJIEOU8_Gc2Yk_K4: ARRAY [1..2] OF REAL;(*Gc2输出寄存器2*)
	(*Gc2寄存器3*)
	arJIEOU8_Gc2Yk_K3: ARRAY [1..2] OF REAL;(*Gc2输出寄存器3*)

	(*JIEOU9*)
	(*Gc1_1寄存器*)
	arJIEOU9_Gc1_1_Gc1_Yk: ARRAY [1..2] OF REAL;(*Gc1_1 Gc1输出寄存器*)
	(*Gc2_1寄存器*)
	arJIEOU9_Gc2_1_Yk: ARRAY [1..2] OF REAL;(*Gc2_1输出寄存器*)

	arJIEOU9_Gc2_1_Gc1_Uk: ARRAY [1..2] OF REAL;(*Gc2_1 Gc1输入寄存器*)
	arJIEOU9_Gc2_1_Gc2_Yk: ARRAY [1..2] OF REAL;(*Gc2_1 Gc2输出寄存器*)

	(*Gc2寄存器1*)
	arJIEOU9_Gc2Uk_K5: ARRAY [1..2] OF REAL;(*Gc2_K5输入寄存器1*)
	arJIEOU9_Gc2Yk_K5: ARRAY [1..2] OF REAL;(*Gc2_K5输出寄存器1*)
	(*Gc2寄存器2*)
	arJIEOU9_Gc2Uk_K4: ARRAY [1..2] OF REAL;(*Gc2_K4输入寄存器2*)
	arJIEOU9_Gc2Yk_K4: ARRAY [1..2] OF REAL;(*Gc2_K4输出寄存器2*)
	(*Gc2寄存器3*)
	arJIEOU9_Gc2Yk_K3: ARRAY [1..2] OF REAL;(*Gc2_K3输出寄存器3*)


	(*JIEOU10*)
	(*Gc1_1寄存器*)
	arJIEOU10_Gc1_1_Gc1_Yk: ARRAY [1..2] OF REAL;(*Gc1_1 Gc1输出寄存器*)
	(*Gc2_1寄存器*)
	arJIEOU10_Gc2_1_Yk: ARRAY [1..2] OF REAL;(*Gc2_1输出寄存器*)

	arJIEOU10_Gc2_1_Gc1_Uk: ARRAY [1..2] OF REAL;(*Gc2_1 Gc1输入寄存器*)
	arJIEOU10_Gc2_1_Gc2_Yk: ARRAY [1..2] OF REAL;(*Gc2_1 Gc2输出寄存器*)

	(*Gc2寄存器1*)
	arJIEOU10_Gc2Uk_K5: ARRAY [1..2] OF REAL;(*Gc2_K5输入寄存器1*)
	arJIEOU10_Gc2Yk_K5: ARRAY [1..2] OF REAL;(*Gc2_K5输出寄存器1*)
	(*Gc2寄存器2*)
	arJIEOU10_Gc2Uk_K4: ARRAY [1..2] OF REAL;(*Gc2_K4输入寄存器2*)
	arJIEOU10_Gc2Yk_K4: ARRAY [1..2] OF REAL;(*Gc2_K4输出寄存器2*)
	(*Gc2寄存器3*)
	arJIEOU10_Gc2Yk_K3: ARRAY [1..2] OF REAL;(*Gc2_K3输出寄存器3*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
