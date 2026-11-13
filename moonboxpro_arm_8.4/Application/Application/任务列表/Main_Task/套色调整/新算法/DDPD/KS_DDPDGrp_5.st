(*@CES
Name=KS_DDPDGrp_5
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=b37a0618-2b5f-41d1-aa83-f451c8f1151a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_DDPDGrp_5 : REAL
VAR_INPUT
	i_rU:REAL;(*输入*)
	i_rA:ARRAY [1..DECOUPLD_DDPD_MAX] OF REAL;(*系统参数a*)
	i_rB:ARRAY [1..DECOUPLD_DDPD_MAX] OF REAL;(*系统参数b*)
	i_rN: INT;(*延时拍数*)
	i_rTs:REAL;(*采样时间*)
	i_pastStDecoupleDDPD: POINTER TO  StDecoupleDDPD;
END_VAR
VAR
	prA:POINTER TO  ARRAY [1..2] OF  REAL;(*i_rA指针*)
	prB:POINTER TO  ARRAY [1..2] OF REAL;(*i_rB指针*)
END_VAR
{IMPLEMENTATION}
IF i_pastStDecoupleDDPD<>0 AND i_rN>0 THEN
	prA:=ADR(i_rA[4]);
	prB:=ADR(i_rB[4]);
	(*DW65*)
	KS_TrF_GA(i_rU,prA^,prB^,i_rN,i_rTs,
				ADR(i_pastStDecoupleDDPD^.arTrF_UGrp_A),
				ADR(i_pastStDecoupleDDPD^.arTrF_UA_G1),
				ADR(i_pastStDecoupleDDPD^.arTrF_UA_G2),
				ADR(i_pastStDecoupleDDPD^.arTrF_YGrp_A ),
				ADR(i_pastStDecoupleDDPD^.arTrF_YA_G1),
				ADR(i_pastStDecoupleDDPD^.arTrF_YA_G2),
				ADR(i_pastStDecoupleDDPD^.arTrF_ADelay));
	(*DW75*)
	KS_TrF_GC(i_rU,prA^,prB^,i_rN,i_rTs,
				ADR(i_pastStDecoupleDDPD^.arTrF_UGrp_C),
				ADR(i_pastStDecoupleDDPD^.arTrF_UC_G2),
				ADR(i_pastStDecoupleDDPD^.arTrF_YGrp_C),
				ADR(i_pastStDecoupleDDPD^.arTrF_YC_G2));
	(*DW85*)
	KS_TrF_G2(i_pastStDecoupleDDPD^.arTrF_YGrp_C[1],i_rTs,i_rA[6],i_rA[5],
	ADR(i_pastStDecoupleDDPD^.arTrF_UGrp_G2_8),ADR(i_pastStDecoupleDDPD^.arTrF_YGrp_G2_8));
	(*DW95*)
	KS_TrF_G2(i_pastStDecoupleDDPD^.arTrF_YGrp_G2_8[1],i_rTs,i_rA[7],i_rA[6],
	ADR(i_pastStDecoupleDDPD^.arTrF_UGrp_G2_9),ADR(i_pastStDecoupleDDPD^.arTrF_YGrp_G2_9));
	(*DW105*)
	KS_TrF_G2(i_pastStDecoupleDDPD^.arTrF_YGrp_G2_9[1],i_rTs,i_rA[8],i_rA[7],
	ADR(i_pastStDecoupleDDPD^.arTrF_UGrp_G2_10),ADR(i_pastStDecoupleDDPD^.arTrF_YGrp_G2_10));
	(*DW115*)
	KS_TrF_G2(i_pastStDecoupleDDPD^.arTrF_YGrp_G2_10[1],i_rTs,i_rA[9],i_rA[8],
	ADR(i_pastStDecoupleDDPD^.arTrF_UGrp_G2_11),ADR(i_pastStDecoupleDDPD^.arTrF_YGrp_G2_11));
	(*DW125*)
	KS_TrF_G2(i_pastStDecoupleDDPD^.arTrF_YGrp_G2_11[1],i_rTs,i_rA[10],i_rA[9],
	ADR(i_pastStDecoupleDDPD^.arTrF_UGrp_G2_12),ADR(i_pastStDecoupleDDPD^.arTrF_YGrp_G2_12));
	(*DW135*)
	KS_TrF_G2(i_pastStDecoupleDDPD^.arTrF_YGrp_G2_12[1],i_rTs,i_rA[11],i_rA[10],
	ADR(i_pastStDecoupleDDPD^.arTrF_UGrp_G2_13),ADR(i_pastStDecoupleDDPD^.arTrF_YGrp_G2_13));
END_IF