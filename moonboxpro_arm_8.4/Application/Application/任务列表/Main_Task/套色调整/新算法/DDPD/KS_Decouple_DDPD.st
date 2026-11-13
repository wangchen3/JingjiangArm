(*@CES
Name=KS_Decouple_DDPD
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=9165b926-0854-4833-988c-46e8c47a2c19
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_Decouple_DDPD : REAL
VAR_INPUT
	i_xEn:BOOL;
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
	(*系统参数*)
	i_rC:REAL;(*版周长mm*)
	i_rV:REAL;(*运行速度m/min*)
	i_arLength:ARRAY [1..DECOUPLD_DDPD_MAX] OF REAL;(*料长数组，下标2表示一色至二色的料长单位m*)
	i_DecoupleDepth:INT;(*解耦深度手动输入，输入范围4~11，表示当前色会向后传递多少色，
							实际输入应小于实际印刷色组个数，输入不在范围内默认为4*)
	i_pastStDecoupleDDPD: POINTER TO ARRAY [1..DECOUPLD_DDPD_MAX] OF StDecoupleDDPD;
END_VAR
VAR
	i_rPI: ARRAY [1..DECOUPLD_DDPD_MAX] OF REAL;(*色组pi控制量*)
	arDecoupleOut:ARRAY [1..DECOUPLD_DDPD_MAX] OF REAL;(*解耦输出*)
	rtemp:REAL;(*求和中间变量*)
	rPai:REAL:=3.1415926535;(*圆周率*)
	rRadius:REAL;(*版辊半径*)
	w0:REAL;(*角速度*)
	iI: INT:=0;
	(*A*)
	rK:REAL:=2.3E-4;(*材料弹性系数(1/EA)*)
	rT:REAL:=100;(*放牵张力T*单位N*)
	rA:ARRAY [1..DECOUPLD_DDPD_MAX] OF REAL;(*系统参数a*)
	rB:ARRAY [1..DECOUPLD_DDPD_MAX] OF REAL;(*系统参数b*)
	rN:ARRAY [1..DECOUPLD_DDPD_MAX] OF INT;(*延时拍数*)
	rTs:REAL:=0;(*采样时间*)
	prA:POINTER TO  ARRAY [1..2] OF  REAL;(*i_rA指针*)
	iJ: INT;
	iK:INT;
	(*内部控制变量*)
	bK4:INT;
	bK5:INT;
	bK6:INT;
	bK7:INT;
	bK8:INT;
	bK9:INT;
	bK10:INT;
	diTmp: DINT;
END_VAR
{IMPLEMENTATION}
i_rPI[2]:=i_rPI2;
i_rPI[3]:=i_rPI3;
i_rPI[4]:=i_rPI4;
i_rPI[5]:=i_rPI5;
i_rPI[6]:=i_rPI6;
i_rPI[7]:=i_rPI7;
i_rPI[8]:=i_rPI8;
i_rPI[9]:=i_rPI9;
i_rPI[10]:=i_rPI10;
i_rPI[11]:=i_rPI11;
i_rPI[12]:=i_rPI12;
i_rPI[13]:=i_rPI13;

IF i_xEn
	AND i_pastStDecoupleDDPD<> 0
	AND ( i_rV >0)
	AND ( i_rC >0) THEN(*版周长大于0*)
	rRadius:=i_rC/1000.0/rPai/2.0;
	w0:=i_rV/60.0/rRadius;
	rTs:=i_rC/(i_rV*1000.0/60.0);
	(*处理传递函数相关参数*)
	FOR iI:=2 TO DECOUPLD_DDPD_MAX BY 1 DO
		IF i_arLength[iI]>0 THEN
			rA[iI-1]:=rRadius*w0/i_arLength[iI];
			rB[iI-1]:=rRadius*(1.0+rK*rT)/(i_arLength[iI]*rK);
			diTmp:=TRUNC (i_arLength[iI]/(i_rC/1000))+1;
			rN[iI-1]:=DINT_TO_INT(diTmp);
			IF rN[iI-1] > ARC_DELAY_N_MAX_DDPD THEN
				rN[iI-1] := ARC_DELAY_N_MAX_DDPD;
			END_IF
		END_IF
	END_FOR
	(*延时寄存器A后移一拍*)
	FOR iI:=2 TO DECOUPLD_DDPD_MAX BY 1 DO
		IF i_arLength[iI]>0 THEN
			FOR iJ:=rN[iI] TO 2 BY -1 DO
				i_pastStDecoupleDDPD^[iI].arTrF_ADelay[iJ]:=i_pastStDecoupleDDPD^[iI].arTrF_ADelay[iJ-1];
				i_pastStDecoupleDDPD^[iI].arTrF_BDelay[iJ]:=i_pastStDecoupleDDPD^[iI].arTrF_BDelay[iJ-1];
			END_FOR
		END_IF
	END_FOR
	(*其他寄存器后移一拍*)
	FOR iI:=2 TO DECOUPLD_DDPD_MAX BY 1 DO
		IF i_arLength[iI]>0 THEN
			i_pastStDecoupleDDPD^[iI].arTrF_UA_G1[2]:=i_pastStDecoupleDDPD^[iI].arTrF_UA_G1[1];
			i_pastStDecoupleDDPD^[iI].arTrF_YA_G1[2]:=i_pastStDecoupleDDPD^[iI].arTrF_YA_G1[1];
			i_pastStDecoupleDDPD^[iI].arTrF_UA_G2[2]:=i_pastStDecoupleDDPD^[iI].arTrF_UA_G2[1];
			i_pastStDecoupleDDPD^[iI].arTrF_YA_G2[2]:=i_pastStDecoupleDDPD^[iI].arTrF_YA_G2[1];

			i_pastStDecoupleDDPD^[iI].arTrF_UB_G1[2]:=i_pastStDecoupleDDPD^[iI].arTrF_UB_G1[1];
			i_pastStDecoupleDDPD^[iI].arTrF_YB_G1[2]:=i_pastStDecoupleDDPD^[iI].arTrF_YB_G1[1];
			i_pastStDecoupleDDPD^[iI].arTrF_UB_G2[2]:=i_pastStDecoupleDDPD^[iI].arTrF_UB_G2[1];
			i_pastStDecoupleDDPD^[iI].arTrF_YB_G2[2]:=i_pastStDecoupleDDPD^[iI].arTrF_YB_G2[1];

			i_pastStDecoupleDDPD^[iI].arTrF_UC_G2[2]:=i_pastStDecoupleDDPD^[iI].arTrF_UC_G2[1];
			i_pastStDecoupleDDPD^[iI].arTrF_YC_G2[2]:=i_pastStDecoupleDDPD^[iI].arTrF_YC_G2[1];

			i_pastStDecoupleDDPD^[iI].arTrF_UGrp_B[2]:=i_pastStDecoupleDDPD^[iI].arTrF_UGrp_B[1];
			i_pastStDecoupleDDPD^[iI].arTrF_YGrp_B[2]:=i_pastStDecoupleDDPD^[iI].arTrF_YGrp_B[1];
			i_pastStDecoupleDDPD^[iI].arTrF_UGrp_A[2]:=i_pastStDecoupleDDPD^[iI].arTrF_UGrp_A[1];
			i_pastStDecoupleDDPD^[iI].arTrF_YGrp_A[2]:=i_pastStDecoupleDDPD^[iI].arTrF_YGrp_A[1];
			i_pastStDecoupleDDPD^[iI].arTrF_UGrp_C[2]:=i_pastStDecoupleDDPD^[iI].arTrF_UGrp_C[1];
			i_pastStDecoupleDDPD^[iI].arTrF_YGrp_C[2]:=i_pastStDecoupleDDPD^[iI].arTrF_YGrp_C[1];
			i_pastStDecoupleDDPD^[iI].arTrF_UGrp_G2_5[2]:=i_pastStDecoupleDDPD^[iI].arTrF_UGrp_G2_5[1];
			i_pastStDecoupleDDPD^[iI].arTrF_YGrp_G2_5[2]:=i_pastStDecoupleDDPD^[iI].arTrF_YGrp_G2_5[1];
			i_pastStDecoupleDDPD^[iI].arTrF_UGrp_G2_6[2]:=i_pastStDecoupleDDPD^[iI].arTrF_UGrp_G2_6[1];
			i_pastStDecoupleDDPD^[iI].arTrF_YGrp_G2_6[2]:=i_pastStDecoupleDDPD^[iI].arTrF_YGrp_G2_6[1];
			i_pastStDecoupleDDPD^[iI].arTrF_UGrp_G2_7[2]:=i_pastStDecoupleDDPD^[iI].arTrF_UGrp_G2_7[1];
			i_pastStDecoupleDDPD^[iI].arTrF_YGrp_G2_7[2]:=i_pastStDecoupleDDPD^[iI].arTrF_YGrp_G2_7[1];
			i_pastStDecoupleDDPD^[iI].arTrF_UGrp_G2_8[2]:=i_pastStDecoupleDDPD^[iI].arTrF_UGrp_G2_8[1];
			i_pastStDecoupleDDPD^[iI].arTrF_YGrp_G2_8[2]:=i_pastStDecoupleDDPD^[iI].arTrF_YGrp_G2_8[1];
			i_pastStDecoupleDDPD^[iI].arTrF_UGrp_G2_9[2]:=i_pastStDecoupleDDPD^[iI].arTrF_UGrp_G2_9[1];
			i_pastStDecoupleDDPD^[iI].arTrF_YGrp_G2_9[2]:=i_pastStDecoupleDDPD^[iI].arTrF_YGrp_G2_9[1];
			i_pastStDecoupleDDPD^[iI].arTrF_UGrp_G2_10[2]:=i_pastStDecoupleDDPD^[iI].arTrF_UGrp_G2_10[1];
			i_pastStDecoupleDDPD^[iI].arTrF_YGrp_G2_10[2]:=i_pastStDecoupleDDPD^[iI].arTrF_YGrp_G2_10[1];
			i_pastStDecoupleDDPD^[iI].arTrF_UGrp_G2_11[2]:=i_pastStDecoupleDDPD^[iI].arTrF_UGrp_G2_11[1];
			i_pastStDecoupleDDPD^[iI].arTrF_YGrp_G2_11[2]:=i_pastStDecoupleDDPD^[iI].arTrF_YGrp_G2_11[1];
			i_pastStDecoupleDDPD^[iI].arTrF_UGrp_G2_12[2]:=i_pastStDecoupleDDPD^[iI].arTrF_UGrp_G2_12[1];
			i_pastStDecoupleDDPD^[iI].arTrF_YGrp_G2_12[2]:=i_pastStDecoupleDDPD^[iI].arTrF_YGrp_G2_12[1];
			i_pastStDecoupleDDPD^[iI].arTrF_UGrp_G2_13[2]:=i_pastStDecoupleDDPD^[iI].arTrF_UGrp_G2_13[1];
			i_pastStDecoupleDDPD^[iI].arTrF_YGrp_G2_13[2]:=i_pastStDecoupleDDPD^[iI].arTrF_YGrp_G2_13[1];

		END_IF
	END_FOR
	CASE i_DecoupleDepth OF
	4:
		bK4:=0;	bK5:=0;	bK6:=0;	bK7:=0;	bK8:=0;	bK9:=0;	bK10:=0;
	5:
		bK4:=1;	bK5:=0;	bK6:=0;	bK7:=0;	bK8:=0;	bK9:=0;	bK10:=0;
	6:
		bK4:=1;	bK5:=1;	bK6:=0;	bK7:=0;	bK8:=0;	bK9:=0;	bK10:=0;
	7:
		bK4:=1;	bK5:=1;	bK6:=1;	bK7:=0;	bK8:=0;	bK9:=0;	bK10:=0;
	8:
		bK4:=1;	bK5:=1;	bK6:=1;	bK7:=1;	bK8:=0;	bK9:=0;	bK10:=0;
	9:
		bK4:=1;	bK5:=1;	bK6:=1;	bK7:=1;	bK8:=1;	bK9:=0;	bK10:=0;
	10:
		bK4:=1;	bK5:=1;	bK6:=1;	bK7:=1;	bK8:=1;	bK9:=1;	bK10:=0;
	11:
		bK4:=1;	bK5:=1;	bK6:=1;	bK7:=1;	bK8:=1;	bK9:=1;	bK10:=1;
	ELSE
		bK4:=0;	bK5:=0;	bK6:=0;	bK7:=0;	bK8:=0;	bK9:=0;	bK10:=0;
	END_CASE
	(*2U*)
	IF i_arLength[2]>0 THEN
		KS_DDPDGrp_2(i_rPI[2],rA,rB,rN[2],rTs,ADR(i_pastStDecoupleDDPD^[2]));
		arDecoupleOut[2]:=i_rPI[2];(*PI2*)
	END_IF
	(*3U*)
	IF i_arLength[3]>0 THEN
		rtemp:=i_pastStDecoupleDDPD^[2].arTrF_YGrp_A[1]+i_rPI[3];
		arDecoupleOut[3]:=rtemp;(*DW32+PI3*)
		KS_DDPDGrp_3(rtemp,rA,rB,rN[3],rTs,ADR(i_pastStDecoupleDDPD^[3]));
	END_IF
	(*4U*)
	(*B4*)
	IF i_arLength[4]>0 THEN
		rtemp:=i_pastStDecoupleDDPD^[2].arTrF_YGrp_C[1];(*DW42*)
		prA:=ADR(rA[2]);
		KS_TrF_GB(rtemp,prA^,rB[3],rN[3],rTs,
					ADR(i_pastStDecoupleDDPD^[4].arTrF_UGrp_B),
					ADR(i_pastStDecoupleDDPD^[4].arTrF_UB_G1),
					ADR(i_pastStDecoupleDDPD^[4].arTrF_UB_G2),
					ADR(i_pastStDecoupleDDPD^[4].arTrF_YGrp_B ),
					ADR(i_pastStDecoupleDDPD^[4].arTrF_YB_G1),
					ADR(i_pastStDecoupleDDPD^[4].arTrF_YB_G2),
					ADR(i_pastStDecoupleDDPD^[3].arTrF_BDelay));
		rtemp:=i_pastStDecoupleDDPD^[4].arTrF_YGrp_B[1]+i_pastStDecoupleDDPD^[3].arTrF_YGrp_A[1]+i_rPI[4];(*(DW42)_B+DW43+PI4*)
		arDecoupleOut[4]:=rtemp;
		KS_DDPDGrp_4(rtemp,rA,rB,rN[4],rTs,ADR(i_pastStDecoupleDDPD^[4]));
	END_IF
	(*5U*)
	(*B5*)
	IF i_arLength[5]>0 THEN
		rtemp:=i_pastStDecoupleDDPD^[2].arTrF_YGrp_G2_5[1]+i_pastStDecoupleDDPD^[3].arTrF_YGrp_C[1];(*DW52+DW53*)
		prA:=ADR(rA[3]);
		KS_TrF_GB(rtemp,prA^,rB[4],rN[4],rTs,
					ADR(i_pastStDecoupleDDPD^[5].arTrF_UGrp_B),
					ADR(i_pastStDecoupleDDPD^[5].arTrF_UB_G1),
					ADR(i_pastStDecoupleDDPD^[5].arTrF_UB_G2),
					ADR(i_pastStDecoupleDDPD^[5].arTrF_YGrp_B ),
					ADR(i_pastStDecoupleDDPD^[5].arTrF_YB_G1),
					ADR(i_pastStDecoupleDDPD^[5].arTrF_YB_G2),
					ADR(i_pastStDecoupleDDPD^[4].arTrF_BDelay));
		rtemp:=i_pastStDecoupleDDPD^[5].arTrF_YGrp_B[1]+i_pastStDecoupleDDPD^[4].arTrF_YGrp_A[1]+i_rPI[5];(*(DW52+DW53)_B+DW54+PI5*)
		arDecoupleOut[5]:=rtemp;
		KS_DDPDGrp_5(rtemp,rA,rB,rN[5],rTs,ADR(i_pastStDecoupleDDPD^[5]));
	END_IF
	(*6U*)
	(*B6*)
	IF i_arLength[6]>0 THEN
		rtemp:=i_pastStDecoupleDDPD^[2].arTrF_YGrp_G2_6[1]+i_pastStDecoupleDDPD^[3].arTrF_YGrp_G2_6[1]+
				i_pastStDecoupleDDPD^[4].arTrF_YGrp_C[1];(*DW62+DW63+DW64*)
		prA:=ADR(rA[4]);
		KS_TrF_GB(rtemp,prA^,rB[5],rN[5],rTs,
					ADR(i_pastStDecoupleDDPD^[6].arTrF_UGrp_B),
					ADR(i_pastStDecoupleDDPD^[6].arTrF_UB_G1),
					ADR(i_pastStDecoupleDDPD^[6].arTrF_UB_G2),
					ADR(i_pastStDecoupleDDPD^[6].arTrF_YGrp_B ),
					ADR(i_pastStDecoupleDDPD^[6].arTrF_YB_G1),
					ADR(i_pastStDecoupleDDPD^[6].arTrF_YB_G2),
					ADR(i_pastStDecoupleDDPD^[5].arTrF_BDelay));
		rtemp:=i_pastStDecoupleDDPD^[6].arTrF_YGrp_B[1]+i_pastStDecoupleDDPD^[5].arTrF_YGrp_A[1]+i_rPI[6];(*(DW62+DW63+DW64)_B+DW65+PI6*)
		arDecoupleOut[6]:=rtemp;
		KS_DDPDGrp_6(rtemp,rA,rB,rN[6],rTs,ADR(i_pastStDecoupleDDPD^[6]));
	END_IF
	(*7U*)
	(*B7*)
	IF i_arLength[7]>0 THEN
		rtemp:=bK4*i_pastStDecoupleDDPD^[2].arTrF_YGrp_G2_7[1]+i_pastStDecoupleDDPD^[3].arTrF_YGrp_G2_7[1]+
				i_pastStDecoupleDDPD^[4].arTrF_YGrp_G2_7[1]+i_pastStDecoupleDDPD^[5].arTrF_YGrp_C[1];(*DW72+DW73+DW74+DW75*)
		prA:=ADR(rA[5]);
		KS_TrF_GB(rtemp,prA^,rB[6],rN[6],rTs,
					ADR(i_pastStDecoupleDDPD^[7].arTrF_UGrp_B),
					ADR(i_pastStDecoupleDDPD^[7].arTrF_UB_G1),
					ADR(i_pastStDecoupleDDPD^[7].arTrF_UB_G2),
					ADR(i_pastStDecoupleDDPD^[7].arTrF_YGrp_B ),
					ADR(i_pastStDecoupleDDPD^[7].arTrF_YB_G1),
					ADR(i_pastStDecoupleDDPD^[7].arTrF_YB_G2),
					ADR(i_pastStDecoupleDDPD^[6].arTrF_BDelay));
		(*(DW72+DW73+DW74+DW75)_B+DW76+PI7*)
		rtemp:=i_pastStDecoupleDDPD^[7].arTrF_YGrp_B[1]+i_pastStDecoupleDDPD^[6].arTrF_YGrp_A[1]+i_rPI[7];
		arDecoupleOut[7]:=rtemp;
		KS_DDPDGrp_7(rtemp,rA,rB,rN[7],rTs,ADR(i_pastStDecoupleDDPD^[7]));
	END_IF
	(*8U*)
	(*B8*)(*DW82+DW83+DW84+DW85+DW86*)
	IF i_arLength[8]>0 THEN
		rtemp:=bK5*i_pastStDecoupleDDPD^[2].arTrF_YGrp_G2_8[1]+
				bK4*i_pastStDecoupleDDPD^[3].arTrF_YGrp_G2_8[1]+i_pastStDecoupleDDPD^[4].arTrF_YGrp_G2_8[1]+
				i_pastStDecoupleDDPD^[5].arTrF_YGrp_G2_8[1]+i_pastStDecoupleDDPD^[6].arTrF_YGrp_C[1];
		prA:=ADR(rA[6]);
		KS_TrF_GB(rtemp,prA^,rB[7],rN[7],rTs,
					ADR(i_pastStDecoupleDDPD^[8].arTrF_UGrp_B),
					ADR(i_pastStDecoupleDDPD^[8].arTrF_UB_G1),
					ADR(i_pastStDecoupleDDPD^[8].arTrF_UB_G2),
					ADR(i_pastStDecoupleDDPD^[8].arTrF_YGrp_B ),
					ADR(i_pastStDecoupleDDPD^[8].arTrF_YB_G1),
					ADR(i_pastStDecoupleDDPD^[8].arTrF_YB_G2),
					ADR(i_pastStDecoupleDDPD^[7].arTrF_BDelay));
		(*(DW82+DW83+DW84+DW85+DW86)_B+DW87+PI8*)
		rtemp:=i_pastStDecoupleDDPD^[8].arTrF_YGrp_B[1]+i_pastStDecoupleDDPD^[7].arTrF_YGrp_A[1]+i_rPI[8];
		arDecoupleOut[8]:=rtemp;
		KS_DDPDGrp_8(rtemp,rA,rB,rN[8],rTs,ADR(i_pastStDecoupleDDPD^[8]));
	END_IF
	(*9U*)
	(*B9*)(*DW92+DW93+DW94+DW95+DW96+DW97*)
	IF i_arLength[9]>0 THEN
		rtemp:=bK6*i_pastStDecoupleDDPD^[2].arTrF_YGrp_G2_9[1]+bK5*i_pastStDecoupleDDPD^[3].arTrF_YGrp_G2_9[1]+
				bK4*i_pastStDecoupleDDPD^[4].arTrF_YGrp_G2_9[1]+i_pastStDecoupleDDPD^[5].arTrF_YGrp_G2_9[1]+
				i_pastStDecoupleDDPD^[6].arTrF_YGrp_G2_9[1]+i_pastStDecoupleDDPD^[7].arTrF_YGrp_C[1];
		prA:=ADR(rA[7]);
		KS_TrF_GB(rtemp,prA^,rB[8],rN[8],rTs,
					ADR(i_pastStDecoupleDDPD^[9].arTrF_UGrp_B),
					ADR(i_pastStDecoupleDDPD^[9].arTrF_UB_G1),
					ADR(i_pastStDecoupleDDPD^[9].arTrF_UB_G2),
					ADR(i_pastStDecoupleDDPD^[9].arTrF_YGrp_B ),
					ADR(i_pastStDecoupleDDPD^[9].arTrF_YB_G1),
					ADR(i_pastStDecoupleDDPD^[9].arTrF_YB_G2),
					ADR(i_pastStDecoupleDDPD^[8].arTrF_BDelay));
		(*(DW92+DW93+DW94+DW95+DW96+DW97)_B+DW98+PI9*)
		rtemp:=i_pastStDecoupleDDPD^[9].arTrF_YGrp_B[1]+i_pastStDecoupleDDPD^[8].arTrF_YGrp_A[1]+i_rPI[9];
		arDecoupleOut[9]:=rtemp;
		KS_DDPDGrp_9(rtemp,rA,rB,rN[9],rTs,ADR(i_pastStDecoupleDDPD^[9]));
	END_IF
	(*10U*)
	(*B10*)(*DW102+DW103+DW104+DW105+DW106+DW107+DW108*)
	IF i_arLength[10]>0 THEN
		rtemp:=bK7*i_pastStDecoupleDDPD^[2].arTrF_YGrp_G2_10[1]+
				bK6*i_pastStDecoupleDDPD^[3].arTrF_YGrp_G2_10[1]+bK5*i_pastStDecoupleDDPD^[4].arTrF_YGrp_G2_10[1]+
				bK4*i_pastStDecoupleDDPD^[5].arTrF_YGrp_G2_10[1]+i_pastStDecoupleDDPD^[6].arTrF_YGrp_G2_10[1]+
				i_pastStDecoupleDDPD^[7].arTrF_YGrp_G2_10[1]+i_pastStDecoupleDDPD^[8].arTrF_YGrp_C[1];
		prA:=ADR(rA[8]);
		KS_TrF_GB(rtemp,prA^,rB[9],rN[9],rTs,
					ADR(i_pastStDecoupleDDPD^[10].arTrF_UGrp_B),
					ADR(i_pastStDecoupleDDPD^[10].arTrF_UB_G1),
					ADR(i_pastStDecoupleDDPD^[10].arTrF_UB_G2),
					ADR(i_pastStDecoupleDDPD^[10].arTrF_YGrp_B ),
					ADR(i_pastStDecoupleDDPD^[10].arTrF_YB_G1),
					ADR(i_pastStDecoupleDDPD^[10].arTrF_YB_G2),
					ADR(i_pastStDecoupleDDPD^[9].arTrF_BDelay));
		(*(DW102+DW103+DW104+DW105+DW106+DW107+DW108)_B+DW109+PI10*)
		rtemp:=i_pastStDecoupleDDPD^[10].arTrF_YGrp_B[1]+i_pastStDecoupleDDPD^[9].arTrF_YGrp_A[1]+i_rPI[10];
		arDecoupleOut[10]:=rtemp;
		KS_DDPDGrp_10(rtemp,rA,rB,rN[10],rTs,ADR(i_pastStDecoupleDDPD^[10]));
	END_IF
	(*11U*)
	(*B11*)(*DW112+DW113+DW114+DW115+DW116+DW117+DW118+DW119*)
	IF i_arLength[11]>0 THEN
		rtemp:=bK8*i_pastStDecoupleDDPD^[2].arTrF_YGrp_G2_11[1]+bK7*i_pastStDecoupleDDPD^[3].arTrF_YGrp_G2_11[1]+
				bK6*i_pastStDecoupleDDPD^[4].arTrF_YGrp_G2_11[1]+bK6*i_pastStDecoupleDDPD^[5].arTrF_YGrp_G2_11[1]+
				bK4*i_pastStDecoupleDDPD^[6].arTrF_YGrp_G2_11[1]+i_pastStDecoupleDDPD^[7].arTrF_YGrp_G2_11[1]+
				i_pastStDecoupleDDPD^[8].arTrF_YGrp_G2_11[1]+i_pastStDecoupleDDPD^[9].arTrF_YGrp_C[1];
		prA:=ADR(rA[9]);
		KS_TrF_GB(rtemp,prA^,rB[10],rN[10],rTs,
					ADR(i_pastStDecoupleDDPD^[11].arTrF_UGrp_B),
					ADR(i_pastStDecoupleDDPD^[11].arTrF_UB_G1),
					ADR(i_pastStDecoupleDDPD^[11].arTrF_UB_G2),
					ADR(i_pastStDecoupleDDPD^[11].arTrF_YGrp_B ),
					ADR(i_pastStDecoupleDDPD^[11].arTrF_YB_G1),
					ADR(i_pastStDecoupleDDPD^[11].arTrF_YB_G2),
					ADR(i_pastStDecoupleDDPD^[10].arTrF_BDelay));
		(*(DW112+DW113+DW114+DW115+DW116+DW117+DW118+DW119)_B+DW1110+PI11*)
		rtemp:=i_pastStDecoupleDDPD^[11].arTrF_YGrp_B[1]+i_pastStDecoupleDDPD^[10].arTrF_YGrp_A[1]+i_rPI[11];
		arDecoupleOut[11]:=rtemp;
		KS_DDPDGrp_11(rtemp,rA,rB,rN[11],rTs,ADR(i_pastStDecoupleDDPD^[11]));
	END_IF
	(*12U*)
	(*B12*)(*DW122+DW123+DW124+DW125+DW126+DW127+DW128+DW129+DW1210*)
		IF i_arLength[12]>0 THEN
		rtemp:=bK9*i_pastStDecoupleDDPD^[2].arTrF_YGrp_G2_12[1]+
				bK8*i_pastStDecoupleDDPD^[3].arTrF_YGrp_G2_12[1]+bK7*i_pastStDecoupleDDPD^[4].arTrF_YGrp_G2_12[1]+
				bK6*i_pastStDecoupleDDPD^[5].arTrF_YGrp_G2_12[1]+bK5*i_pastStDecoupleDDPD^[6].arTrF_YGrp_G2_12[1]+
				bK4*i_pastStDecoupleDDPD^[7].arTrF_YGrp_G2_12[1]+i_pastStDecoupleDDPD^[8].arTrF_YGrp_G2_12[1]+
				i_pastStDecoupleDDPD^[9].arTrF_YGrp_G2_12[1]+i_pastStDecoupleDDPD^[10].arTrF_YGrp_C[1];
		prA:=ADR(rA[10]);
		KS_TrF_GB(rtemp,prA^,rB[11],rN[11],rTs,
					ADR(i_pastStDecoupleDDPD^[12].arTrF_UGrp_B),
					ADR(i_pastStDecoupleDDPD^[12].arTrF_UB_G1),
					ADR(i_pastStDecoupleDDPD^[12].arTrF_UB_G2),
					ADR(i_pastStDecoupleDDPD^[12].arTrF_YGrp_B ),
					ADR(i_pastStDecoupleDDPD^[12].arTrF_YB_G1),
					ADR(i_pastStDecoupleDDPD^[12].arTrF_YB_G2),
					ADR(i_pastStDecoupleDDPD^[11].arTrF_BDelay));
		(*(DW122+DW123+DW124+DW125+DW126+DW127+DW128+DW129+DW1210)_B+DW1211+PI12*)
		rtemp:=i_pastStDecoupleDDPD^[12].arTrF_YGrp_B[1]+i_pastStDecoupleDDPD^[11].arTrF_YGrp_A[1]+i_rPI[12];
		arDecoupleOut[12]:=rtemp;
		KS_DDPDGrp_12(rtemp,rA,rB,rN[12],rTs,ADR(i_pastStDecoupleDDPD^[12]));
	END_IF
	(*13U*)
	(*B13*)(*DW132+DW133+DW134+DW135+DW136+DW137+DW138+DW139+DW1310+DW1311*)
	IF i_arLength[13]>0 THEN
		rtemp:=bK10*i_pastStDecoupleDDPD^[2].arTrF_YGrp_G2_13[1]+bK9*i_pastStDecoupleDDPD^[3].arTrF_YGrp_G2_13[1]+
				bK8*i_pastStDecoupleDDPD^[4].arTrF_YGrp_G2_13[1]+bK7*i_pastStDecoupleDDPD^[5].arTrF_YGrp_G2_13[1]+
				bK6*i_pastStDecoupleDDPD^[6].arTrF_YGrp_G2_13[1]+bK5*i_pastStDecoupleDDPD^[7].arTrF_YGrp_G2_13[1]+
				bK4*i_pastStDecoupleDDPD^[8].arTrF_YGrp_G2_13[1]+i_pastStDecoupleDDPD^[9].arTrF_YGrp_G2_13[1]+
				i_pastStDecoupleDDPD^[10].arTrF_YGrp_G2_13[1]+i_pastStDecoupleDDPD^[11].arTrF_YGrp_C[1];
		prA:=ADR(rA[11]);
		KS_TrF_GB(rtemp,prA^,rB[12],rN[12],rTs,
					ADR(i_pastStDecoupleDDPD^[13].arTrF_UGrp_B),
					ADR(i_pastStDecoupleDDPD^[13].arTrF_UB_G1),
					ADR(i_pastStDecoupleDDPD^[13].arTrF_UB_G2),
					ADR(i_pastStDecoupleDDPD^[13].arTrF_YGrp_B ),
					ADR(i_pastStDecoupleDDPD^[13].arTrF_YB_G1),
					ADR(i_pastStDecoupleDDPD^[13].arTrF_YB_G2),
					ADR(i_pastStDecoupleDDPD^[12].arTrF_BDelay));
		(*(DW132+DW133+DW134+DW135+DW136+DW137+DW138+DW139+DW1310+DW1311)_B+DW1312+PI13*)
		rtemp:=i_pastStDecoupleDDPD^[13].arTrF_YGrp_B[1]+i_pastStDecoupleDDPD^[13].arTrF_YGrp_A[1]+i_rPI[13];
		arDecoupleOut[13]:=rtemp;
	END_IF
ELSE
	i_prU2^:=i_rPI2;
	i_prU3^:=i_rPI3;
	i_prU4^:=i_rPI4;
	i_prU5^:=i_rPI5;
	i_prU6^:=i_rPI6;
	i_prU7^:=i_rPI7;
	i_prU8^:=i_rPI8;
	i_prU9^:=i_rPI9;
	i_prU10^:=i_rPI10;
	i_prU11^:=i_rPI11;
	i_prU12^:=i_rPI12;
	i_prU13^:=i_rPI13;
END_IF
	i_prU2^:=arDecoupleOut[2];
	i_prU3^:=arDecoupleOut[3];
	i_prU4^:=arDecoupleOut[4];
	i_prU5^:=arDecoupleOut[5];
	i_prU6^:=arDecoupleOut[6];
	i_prU7^:=arDecoupleOut[7];
	i_prU8^:=arDecoupleOut[8];
	i_prU9^:=arDecoupleOut[9];
	i_prU10^:=arDecoupleOut[10];
	i_prU11^:=arDecoupleOut[11];
	i_prU12^:=arDecoupleOut[12];
	i_prU13^:=arDecoupleOut[13];