(*@CES
Name=KS_FB_GetCouplingValue_V
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=e94ac8aa-4621-40a7-a9f9-8f5e911582e3
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GetCouplingValue_V(*获取纵向的耦合值@2023.08.19.083723*)
(*
1部分-前色调整后色因为张力而引起的耦合量@默认+-60%|临时使用横向耦合量变量
2部分-前色调整等待固定料长后色需要耦合量@默认100%|使用纵向耦合量变量
*)
(*2023.11.17.194835 增加第10种耦合方式*)
(*2024.6.15.103803 增加第11种耦合方式@不隔色耦合方式|原来按圈计数修改为周期计算*)
(*2024.7.24.101353 只有跟一色支持20ms耦合@11种方式*)
(*2024.7.24.205751 删除了无用的代码*)
(*2024.8.2.171658 增加了跟踪第一色的隔色解耦*)
(*2024.9.6.204916 调整数据类型*)
VAR_INPUT
	i_xEn: BOOL; (* 使能 *)
	i_iGrpId: INT; (* 系id *)
	i_byCouplingType:BYTE;(*耦合方式@=0原来的直接传递的逻辑@不输出耦合量
									@=9 耦合算法，在套色调整处实现处理-隔色解耦@按圈解耦@2023.11.17.194455
									@=10 耦合算法，在套色调整处实现处理-隔色解耦@按圈解耦@2023.11.17.194455
									@=11 耦合算法，不隔色耦合方式@20ms周期解耦@2024.7.10.155211
									@=12 耦合算法，隔色耦合方式@20ms周期解耦@2024.8.2.170814*)
	(*支持数负值@超过一个色组料长*)
	i_iRemaindPartCouplingPos	: INT;(*剩余部分的耦合位置@距离总幅数
														   @=1 到达下一色前第一幅
														   @=2 到达下一色前第二幅*)
	i_xFlag_Follow1U:BOOL;(*跟踪第一色标志@按照整机处理不分色组*)
	i_iGrpArcAxisNum_Pu: INT; (* 系的色序轴数量|色序按照从小到大排序了 *)
	i_abyGrpArcAxisList: ARRAY [1..MAX_UNIT_NUM] OF BYTE; (* 系的色序轴列表 *)

	i_pstStSysParam: POINTER TO StSysParam; (* 参数结构 *)
	i_pastStIOMap_Axis_FE: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE; (* 基础io *)
	i_pstStDeCoupleCoeff:POINTER TO  StDeCoupleCoeff;(*2024.9.10.134022  耦合系数*)
	//i_axUseErrTransfer:ARRAY [1..2] OF BOOL;
	//2025.11.16.110740+
	i_rTs:REAL;//单位s
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_arCouplingValue:ARRAY [1..MAX_UNIT_NUM] OF REAL;(*张力耦合@+-耦合|um*)
END_VAR

VAR_IN_OUT
END_VAR
VAR
	iN: INT;
	iUnitId: INT;
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;
	pstStGrpParam_Save: POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave: POINTER TO StGrpParam_UnSave;
	
	iAdjValue:INT;(*调整量*)
	(*2024.6.15.103803*)
(*	aiAdjValue_V:ARRAY [2..16] OF INT;(*除了1色外套色轴调整量@索引是印刷顺序的含义*)*)
	(*2024.9.6.204908 修改数据类型*)
	arAdjValue_V:ARRAY [2..16] OF REAL;(*除了1色外套色轴调整量@索引是印刷顺序的含义*)

	arCoupleAdjValue_V:ARRAY [2..16] OF REAL;(*耦合后的调整量*)
	stStArcCoupleRegister_Follow1:StArcCoupleRegister_Follow1;
	(*2024.8.2.170442+*)
	astStDecoupleFDPD: ARRAY [1..DECOUPLD_FDPD_MAX] OF StDecoupleFDPD;
	arFilmLenth_ArcList:ARRAY [1..DECOUPLD_FDPD_MAX] OF REAL;(*套色轴的料膜长度@2024.8.2.170254*)
	arFilmLenth_ArcList_Axis16:ARRAY [1..16] OF REAL;(*套色轴的料膜长度@2024.9.10.164306*)
	rTs:REAL;//单位s
END_VAR
{IMPLEMENTATION}
(*增加耦合的计算输出@2023.3.11.104648*)
IF i_pstStSysParam<>0 AND
	i_pastStIOMap_Axis_FE<>0 AND
	(i_iGrpId=1 OR
	i_iGrpId=2) THEN
	pstStGrpParam_Save:= ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
	pstStGrpParam_UnSave:= ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
	(*传递只处理联动轴*)
	SysMemSet(ADR(o_arCouplingValue),0,SIZEOF(o_arCouplingValue));
	SysMemSet(ADR(arAdjValue_V),0,SIZEOF(arAdjValue_V));(*2024.6.15.103803+*)
	SysMemSet(ADR(arFilmLenth_ArcList),0,SIZEOF(arFilmLenth_ArcList));(*2024.8.2.171429+*)
	SysMemSet(ADR(arFilmLenth_ArcList_Axis16),0,SIZEOF(arFilmLenth_ArcList_Axis16));(*2024.8.2.171429+*)
	FOR iN:=1 TO i_iGrpArcAxisNum_Pu BY 1 DO
		iUnitId:= i_abyGrpArcAxisList[iN];
		IF iUnitId>0 AND iUnitId<=MAX_UNIT_NUM  THEN(*合法性判断*)
			pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
			pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
		
			(*删除无用代码@2024.7.24.204214*)
			CASE i_byCouplingType OF
				9,10:(*小黄设计的耦合算法，再套色调整处实现处理@2023.11.17.194455*)
					o_arCouplingValue[iUnitId]:=0;
				11,12:(*跟一色隔色和不隔色解耦@20ms周期处理*)
					o_arCouplingValue[iUnitId]:=0;
					IF iN>1 THEN(*第一色不传递*)
(*						iAdjValue:=pstStAxisParam^.iAdjValue_V;(*当前色的调整量*)*)
(*						iAdjValue:=LREAL_TO_INT(pstStAxisParam^.alrCurCycleAdjustVal_Auto_vh[1]);(*当前色的调整量@20ms的调整量*)
						aiAdjValue_V[iN]:=iAdjValue;(*写入到数组中@2024.6.15.103803*)*)
						(*调整数据类型*)
						
						arAdjValue_V[iN]:= INT_TO_REAL(PLC_PRG.aiFinalAdjust_V[iUnitId]);(*写入到数组中@2024.6.15.103803*)
						arFilmLenth_ArcList[iN]:=pstStUnitParam_Save^.rFilmLengthFromPrevPressUnit/1000;(*m*)
						arFilmLenth_ArcList_Axis16[iN]:=pstStUnitParam_Save^.rFilmLengthFromPrevPressUnit/1000;(*m*)
					END_IF
			ELSE(*就不计算了*);
			END_CASE
		END_IF
	END_FOR

	IF i_xEn AND (i_byCouplingType=11 OR i_byCouplingType=12) THEN(*11是不隔色解耦@12是隔色解耦*)
		SysMemSet(ADR(arCoupleAdjValue_V),0,SIZEOF(arCoupleAdjValue_V));
		IF (pstStGrpParam_Save^.xFlag_Follow_1U_V ) OR
			//i_axUseErrTransfer[i_iGrpId] OR(*误差传递使用这种解耦*)
			pstStGrpParam_UnSave^.xFlag_Follow_1U_V_UwCut OR(*放料裁切跟一色@2024.7.24.104527+*)
			pstStGrpParam_UnSave^.xFlagFollow1U_AccDecing THEN (*加减速跟一色@2024.7.25.112812*)

			//获取采样周期@2025.11.16.110940+
			rTs := i_rTs;
			
			IF i_byCouplingType=11 THEN
				(*增加解耦系数*)
				//DECOUPLE_FOLLOW1(  
				DECOUPLE_FOLLOW1_AddCoeff(
					arAdjValue_V[2](*i_rPI2*),
					arAdjValue_V[3](*i_rPI3*),
					arAdjValue_V[4](*i_rPI4*),
					arAdjValue_V[5](*i_rPI5*),
					arAdjValue_V[6](*i_rPI6*),
					arAdjValue_V[7](*i_rPI7*),
					arAdjValue_V[8](*i_rPI8*),
					arAdjValue_V[9](*i_rPI9*),
					arAdjValue_V[10](*i_rPI10*),
					arAdjValue_V[11](*i_rPI11*),
					arAdjValue_V[12](*i_rPI12*),
					arAdjValue_V[13](*i_rPI13*),
					ADR(arCoupleAdjValue_V[2])(*i_prU2*),
					ADR(arCoupleAdjValue_V[3])(*i_prU3*),
					ADR(arCoupleAdjValue_V[4])(*i_prU4*),
					ADR(arCoupleAdjValue_V[5])(*i_prU5*),
					ADR(arCoupleAdjValue_V[6])(*i_prU6*),
					ADR(arCoupleAdjValue_V[7])(*i_prU7*),
					ADR(arCoupleAdjValue_V[8])(*i_prU8*),
					ADR(arCoupleAdjValue_V[9])(*i_prU9*),
					ADR(arCoupleAdjValue_V[10])(*i_prU10*),
					ADR(arCoupleAdjValue_V[11])(*i_prU10*),
					ADR(arCoupleAdjValue_V[12])(*i_prU10*),
					ADR(arCoupleAdjValue_V[13])(*i_prU10*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU2_Gc1_Uk)(*i_prJIEOU2_Gc1_Uk*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU2_Gc1_Yk)(*i_prJIEOU2_Gc1_Yk*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU3_Gc1_Uk)(*i_prJIEOU3_Gc1_Uk*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU3_Gc1_Yk)(*i_prJIEOU3_Gc1_Yk*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU4_Gc1_Uk)(*i_prJIEOU4_Gc1_Uk*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU4_Gc1_Yk)(*i_prJIEOU4_Gc1_Yk*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU5_Gc1_Uk)(*i_prJIEOU5_Gc1_Uk*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU5_Gc1_Yk)(*i_prJIEOU5_Gc1_Yk*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU6_Gc1_Uk)(*i_prJIEOU6_Gc1_Uk*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU6_Gc1_Yk)(*i_prJIEOU6_Gc1_Yk*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU7_Gc1_Uk)(*i_prJIEOU7_Gc1_Uk*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU7_Gc1_Yk)(*i_prJIEOU7_Gc1_Yk*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU8_Gc1_Uk)(*i_prJIEOU8_Gc1_Uk*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU8_Gc1_Yk)(*i_prJIEOU8_Gc1_Yk*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU9_Gc1_Uk)(*i_prJIEOU9_Gc1_Uk*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU9_Gc1_Yk)(*i_prJIEOU9_Gc1_Yk*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU10_Gc1_Uk)(*i_prJIEOU10_Gc1_Uk*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU10_Gc1_Yk)(*i_prJIEOU10_Gc1_Yk*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU11_Gc1_Uk)(*i_prJIEOU11_Gc1_Uk*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU11_Gc1_Yk)(*i_prJIEOU11_Gc1_Yk*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU12_Gc1_Uk)(*i_prJIEOU12_Gc1_Uk*),
					ADR(stStArcCoupleRegister_Follow1.rJIEOU12_Gc1_Yk)(*i_prJIEOU12_Gc1_Yk*),
					pstStGrpParam_Save^.rGirth_PrnRoller(*i_rC*),
					pstStGrpParam_UnSave^.rVel_Film(*i_rV*),
					pstStGrpParam_Save^.rFilmLenth_InUnit(*i_rL*),
					TRUE(*i_bEn*),
					rTs(*i_rTs*),
					TRUE(*i_xUseVarLenth*),
					arFilmLenth_ArcList_Axis16(*i_arL*),
					i_pstStDeCoupleCoeff(*i_pstStDeCoupleCoeff*));
				(*复位隔色耦合方式的寄存器@2024.8.2.171032*)
				SysMemSet(ADR(astStDecoupleFDPD),0,SIZEOF(astStDecoupleFDPD));
			ELSE(*隔色耦合@2024.8.2.171240*)
				KS_Decouple_FDPD(
					TRUE(*i_xEn*),
					arAdjValue_V[2](*i_rPI2*),
					arAdjValue_V[3](*i_rPI3*),
					arAdjValue_V[4](*i_rPI4*),
					arAdjValue_V[5](*i_rPI5*),
					arAdjValue_V[6](*i_rPI6*),
					arAdjValue_V[7](*i_rPI7*),
					arAdjValue_V[8](*i_rPI8*),
					arAdjValue_V[9](*i_rPI9*),
					arAdjValue_V[10](*i_rPI10*),
					arAdjValue_V[11](*i_rPI11*),
					arAdjValue_V[12](*i_rPI12*),
					arAdjValue_V[13](*i_rPI13*),
					ADR(arCoupleAdjValue_V[2])(*i_prU2*),
					ADR(arCoupleAdjValue_V[3])(*i_prU3*),
					ADR(arCoupleAdjValue_V[4])(*i_prU4*),
					ADR(arCoupleAdjValue_V[5])(*i_prU5*),
					ADR(arCoupleAdjValue_V[6])(*i_prU6*),
					ADR(arCoupleAdjValue_V[7])(*i_prU7*),
					ADR(arCoupleAdjValue_V[8])(*i_prU8*),
					ADR(arCoupleAdjValue_V[9])(*i_prU9*),
					ADR(arCoupleAdjValue_V[10])(*i_prU10*),
					ADR(arCoupleAdjValue_V[11])(*i_prU11*),
					ADR(arCoupleAdjValue_V[12])(*i_prU12*),
					ADR(arCoupleAdjValue_V[13])(*i_prU13*),
					pstStGrpParam_Save^.rGirth_PrnRoller(*i_rC*),
					pstStGrpParam_UnSave^.rVel_Film(*i_rV*),
					rTs(*i_rTs*),
					arFilmLenth_ArcList(*i_arLength*),
					0(*i_DecoupleDepth*),
					ADR(astStDecoupleFDPD)(*i_pastStDecoupleFDPD*));
				(*复位不隔色耦合方式的寄存器@2024.8.2.171032*)
				SysMemSet(ADR(stStArcCoupleRegister_Follow1),0,SIZEOF(stStArcCoupleRegister_Follow1));
			END_IF
		ELSE
			(*复位不隔色耦合方式的寄存器@2024.8.2.171032*)
			SysMemSet(ADR(stStArcCoupleRegister_Follow1),0,SIZEOF(stStArcCoupleRegister_Follow1));
			(*复位隔色耦合方式的寄存器@2024.8.2.171032*)
			SysMemSet(ADR(astStDecoupleFDPD),0,SIZEOF(astStDecoupleFDPD));
		END_IF
		(*将套色索引的轴调整量写入到轴索引中*)
		FOR iN:=2 TO i_iGrpArcAxisNum_Pu BY 1 DO(*第一个不处理*)
			iUnitId:= i_abyGrpArcAxisList[iN];
			IF iUnitId>=2 AND iUnitId<=16 THEN(*只处理2--16轴*)
				o_arCouplingValue[iUnitId]:=arCoupleAdjValue_V[iN];(*只用这个变量输出*)
			END_IF
		END_FOR
	ELSE(*退出耦合*)
		(*复位不隔色耦合方式的寄存器@2024.8.2.171032*)
		SysMemSet(ADR(stStArcCoupleRegister_Follow1),0,SIZEOF(stStArcCoupleRegister_Follow1));
		(*复位隔色耦合方式的寄存器@2024.8.2.171032*)
		SysMemSet(ADR(astStDecoupleFDPD),0,SIZEOF(astStDecoupleFDPD));
		SysMemSet(ADR(arCoupleAdjValue_V),0,SIZEOF(arCoupleAdjValue_V));
	END_IF
END_IF