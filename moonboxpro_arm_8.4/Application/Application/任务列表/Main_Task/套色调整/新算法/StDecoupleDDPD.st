(*@CES
Name=StDecoupleDDPD
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=9ccc1699-6ed1-4128-b336-af80ee495568
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StDecoupleDDPD :
STRUCT
	arTrF_ADelay:ARRAY [1..ARC_DELAY_N_MAX_DDPD] OF REAL;(*A函数延时寄存器*)
	arTrF_BDelay:ARRAY [1..ARC_DELAY_N_MAX_DDPD] OF REAL;(*B函数延时寄存器*)

	arTrF_UA_G1:ARRAY [1..2] OF REAL;(*A函数中使用G1输入寄存器*)
	arTrF_YA_G1:ARRAY [1..2] OF REAL;(*A函数中使用G1输出寄存器*)
	arTrF_UA_G2:ARRAY [1..2] OF REAL;(*A函数中使用G2输入寄存器*)
	arTrF_YA_G2:ARRAY [1..2] OF REAL;(*A函数中使用G2输出寄存器*)

	arTrF_UB_G1:ARRAY [1..2] OF REAL;(*B函数中使用G1输入寄存器*)
	arTrF_YB_G1:ARRAY [1..2] OF REAL;(*B函数中使用G1输出寄存器*)
	arTrF_UB_G2:ARRAY [1..2] OF REAL;(*B函数中使用G2输入寄存器*)
	arTrF_YB_G2:ARRAY [1..2] OF REAL;(*B函数中使用G2输出寄存器*)

	arTrF_UC_G2:ARRAY [1..2] OF REAL;(*C函数中使用G2输入寄存器*)
	arTrF_YC_G2:ARRAY [1..2] OF REAL;(*C函数中使用G2输出寄存器*)

	arTrF_UGrp_B:ARRAY [1..2] OF REAL;(*Grp函数中使用传函B输入寄存器*)
	arTrF_YGrp_B:ARRAY [1..2] OF REAL;(*Grp函数中使用传函B输出寄存器*)
	arTrF_UGrp_A:ARRAY [1..2] OF REAL;(*Grp函数中使用传函A输入寄存器*)
	arTrF_YGrp_A:ARRAY [1..2] OF REAL;(*Grp函数中使用传函A输出寄存器*)
	arTrF_UGrp_C:ARRAY [1..2] OF REAL;(*Grp函数中使用传函C输入寄存器*)
	arTrF_YGrp_C:ARRAY [1..2] OF REAL;(*Grp函数中使用传函C输出寄存器*)
	arTrF_UGrp_G2_5:ARRAY [1..2] OF REAL;(*Grp函数中使用传函G2_5输入寄存器*)
	arTrF_YGrp_G2_5:ARRAY [1..2] OF REAL;(*Grp函数中使用传函G2_5输出寄存器*)
	arTrF_UGrp_G2_6:ARRAY [1..2] OF REAL;(*Grp函数中使用传函G2_6输入寄存器*)
	arTrF_YGrp_G2_6:ARRAY [1..2] OF REAL;(*Grp函数中使用传函G2_6输出寄存器*)
	arTrF_UGrp_G2_7:ARRAY [1..2] OF REAL;(*Grp函数中使用传函G2_7输入寄存器*)
	arTrF_YGrp_G2_7:ARRAY [1..2] OF REAL;(*Grp函数中使用传函G2_7输出寄存器*)
	arTrF_UGrp_G2_8:ARRAY [1..2] OF REAL;(*Grp函数中使用传函G2_8输入寄存器*)
	arTrF_YGrp_G2_8:ARRAY [1..2] OF REAL;(*Grp函数中使用传函G2_8输出寄存器*)
	arTrF_UGrp_G2_9:ARRAY [1..2] OF REAL;(*Grp函数中使用传函G2_9输入寄存器*)
	arTrF_YGrp_G2_9:ARRAY [1..2] OF REAL;(*Grp函数中使用传函G2_9输出寄存器*)
	arTrF_UGrp_G2_10:ARRAY [1..2] OF REAL;(*Grp函数中使用传函G2_10输入寄存器*)
	arTrF_YGrp_G2_10:ARRAY [1..2] OF REAL;(*Grp函数中使用传函G2_10输出寄存器*)
	arTrF_UGrp_G2_11:ARRAY [1..2] OF REAL;(*Grp函数中使用传函G2_11输入寄存器*)
	arTrF_YGrp_G2_11:ARRAY [1..2] OF REAL;(*Grp函数中使用传函G2_11输出寄存器*)
	arTrF_UGrp_G2_12:ARRAY [1..2] OF REAL;(*Grp函数中使用传函G2_12输入寄存器*)
	arTrF_YGrp_G2_12:ARRAY [1..2] OF REAL;(*Grp函数中使用传函G2_12输出寄存器*)
	arTrF_UGrp_G2_13:ARRAY [1..2] OF REAL;(*Grp函数中使用传函G2_13输入寄存器*)
	arTrF_YGrp_G2_13:ARRAY [1..2] OF REAL;(*Grp函数中使用传函G2_13输出寄存器*)

END_STRUCT
END_TYPE

{IMPLEMENTATION}
