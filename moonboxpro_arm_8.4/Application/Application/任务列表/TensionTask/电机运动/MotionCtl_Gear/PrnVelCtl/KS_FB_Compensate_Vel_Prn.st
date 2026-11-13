(*@CES
Name=KS_FB_Compensate_Vel_Prn
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=f2c8bddd-aead-4231-9ab2-ee8ef03f3302
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_Compensate_Vel_Prn
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_rVel_Cur: REAL;
	i_iGrpUnitNum_Pu : INT;
	i_aiGrpUnitList: ARRAY [1..MAX_UNIT_NUM] OF INT;
	i_iGrpLinkageAxisNum_Pu: INT;
	i_aiGrpLinkageAxisList : ARRAY [1..MAX_UNIT_NUM] OF INT;
//	i_palrAxisMotionVel: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*轴速度*)
	i_paxFlag_PressDne: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	//增加加速度及加加速度输入只2026.4.11.153755
	i_rVel_A: REAL;//加速度
	i_rVel_Jerk: REAL;//加加速度；     
	i_arAxisVelPrf_Coeff1: ARRAY [1..MAX_UNIT_NUM] OF REAL;
	i_arAxisVelPrf_Coeff2: ARRAY [1..MAX_UNIT_NUM] OF REAL;
	i_arAxisVelPrf_Coeff3: ARRAY [1..MAX_UNIT_NUM] OF REAL;
	i_xFlag_Accing: BOOL;                                                                                                                                                                                                                                                                                                                               	
	i_xFlag_Decing: BOOL;                                                                                                                                                                                                                                                                                                                               	
END_VAR
VAR_OUTPUT
	o_alrAxisPrfVel: ARRAY [1..MAX_UNIT_NUM] OF LREAL;
END_VAR
VAR
	iN: INT;
	iUnitId: INT;
	iPrevAxisId: INT;
	iPrevPressLinkageAxisId: INT;
	rAxisVelPrf_Coeff1: REAL;
	rAxisVelPrf_Coeff2: REAL;
	rAxisVelPrf_Coeff3: REAL;
 	rAxisVelPrf_Coeff: REAL;
	rCompensate_Vel: REAL;
	rTmp: REAL;
END_VAR

{IMPLEMENTATION}
(*按照所有轴输出*)
IF i_xEn THEN
	FOR iN:=1 TO i_iGrpUnitNum_Pu BY 1 DO
		iUnitId:= i_aiGrpUnitList[iN];
	//	pstStAxisParam:=ADR(i_pstStShmGlobalParam^.astStAxisParam[iAxisId]);
		IF in=1 THEN(*第一个轴为主速度*)
			o_alrAxisPrfVel[iUnitId]:= i_rVel_Cur;
		ELSE
			(*寻找前一个联动合压轴id*)
			iPrevPressLinkageAxisId:=
				KS_GetPrevPressLinkageAxisId(iUnitId,
					i_iGrpLinkageAxisNum_Pu,
					ADR(i_aiGrpLinkageAxisList[in]),
					i_paxFlag_PressDne);
	
			iPrevAxisId:= i_aiGrpUnitList[iN-1];
			IF iPrevPressLinkageAxisId<>-1 THEN(*找到了合压的前一个轴*)
				iPrevAxisId:=iPrevPressLinkageAxisId;
			ELSE;(*如果没找到，就用当前轴的前一个轴*)
			END_IF
			(*系数通过轴参数获取*)
			IF i_arAxisVelPrf_Coeff1[iUnitId]=0 THEN
				i_arAxisVelPrf_Coeff1[iUnitId]:= -200;
			END_IF
			rAxisVelPrf_Coeff1:=i_arAxisVelPrf_Coeff1[iUnitId];
			(*强制写为负值*)
			rAxisVelPrf_Coeff1:=-ABS(rAxisVelPrf_Coeff1);
			rAxisVelPrf_Coeff2:=i_arAxisVelPrf_Coeff2[iUnitId];
			rAxisVelPrf_Coeff3:=i_arAxisVelPrf_Coeff3[iUnitId];
	
			(*减加速度过程中修改加加速度的系数@2024.12.21.172422*)
			rAxisVelPrf_Coeff:=1;
			IF (i_rVel_Jerk<0 AND i_xFlag_Accing) OR
				(i_rVel_Jerk>0 AND i_xFlag_Decing) THEN
				rAxisVelPrf_Coeff:=rAxisVelPrf_Coeff3;
			END_IF
	
			(*前一个色组的速度基础上叠加补偿量@2024.12.29.134559*)
			(*补偿量*)
			rCompensate_Vel:=1/(rAxisVelPrf_Coeff1)*
						(i_rVel_Jerk*rAxisVelPrf_Coeff+rAxisVelPrf_Coeff2*i_rVel_A);
	
			rTmp:=rCompensate_Vel;
	
			o_alrAxisPrfVel[iUnitId]:=rTmp+o_alrAxisPrfVel[iPrevAxisId];
		END_IF
	END_FOR
END_IF