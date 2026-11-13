(*@CES
Name=KS_DDPDGrp_6
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=48354b88-366d-4c1c-8f94-1b5c3f71a6e7
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_DDPDGrp_6 : REAL
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
	prA:=ADR(i_rA[5]);
	prB:=ADR(i_rB[5]);
	(*DW76*)
	KS_TrF_GA(i_rU,prA^,prB^,i_rN,i_rTs,
				ADR(i_pastStDecoupleDDPD^.arTrF_UGrp_A),
				ADR(i_pastStDecoupleDDPD^.arTrF_UA_G1),
				ADR(i_pastStDecoupleDDPD^.arTrF_UA_G2),
				ADR(i_pastStDecoupleDDPD^.arTrF_YGrp_A ),
				ADR(i_pastStDecoupleDDPD^.arTrF_YA_G1),
				ADR(i_pastStDecoupleDDPD^.arTrF_YA_G2),
				ADR(i_pastStDecoupleDDPD^.arTrF_ADelay));
	(*DW86*)
	KS_TrF_GC(i_rU,prA^,prB^,i_rN,i_rTs,
				ADR(i_pastStDecoupleDDPD^.arTrF_UGrp_C),
				ADR(i_pastStDecoupleDDPD^.arTrF_UC_G2),
				ADR(i_pastStDecoupleDDPD^.arTrF_YGrp_C),
				ADR(i_pastStDecoupleDDPD^.arTrF_YC_G2));

	(*DW96*)
	KS_TrF_G2(i_pastStDecoupleDDPD^.arTrF_YGrp_C[1],i_rTs,i_rA[7],i_rA[6],
	ADR(i_pastStDecoupleDDPD^.arTrF_UGrp_G2_9),ADR(i_pastStDecoupleDDPD^.arTrF_YGrp_G2_9));
	(*DW106*)
	KS_TrF_G2(i_pastStDecoupleDDPD^.arTrF_YGrp_G2_9[1],i_rTs,i_rA[8],i_rA[7],
	ADR(i_pastStDecoupleDDPD^.arTrF_UGrp_G2_10),ADR(i_pastStDecoupleDDPD^.arTrF_YGrp_G2_10));
	(*DW116*)
	KS_TrF_G2(i_pastStDecoupleDDPD^.arTrF_YGrp_G2_10[1],i_rTs,i_rA[9],i_rA[8],
	ADR(i_pastStDecoupleDDPD^.arTrF_UGrp_G2_11),ADR(i_pastStDecoupleDDPD^.arTrF_YGrp_G2_11));
	(*DW126*)
	KS_TrF_G2(i_pastStDecoupleDDPD^.arTrF_YGrp_G2_11[1],i_rTs,i_rA[10],i_rA[9],
	ADR(i_pastStDecoupleDDPD^.arTrF_UGrp_G2_12),ADR(i_pastStDecoupleDDPD^.arTrF_YGrp_G2_12));
	(*DW136*)
	KS_TrF_G2(i_pastStDecoupleDDPD^.arTrF_YGrp_G2_12[1],i_rTs,i_rA[11],i_rA[10],
	ADR(i_pastStDecoupleDDPD^.arTrF_UGrp_G2_13),ADR(i_pastStDecoupleDDPD^.arTrF_YGrp_G2_13));
END_IF