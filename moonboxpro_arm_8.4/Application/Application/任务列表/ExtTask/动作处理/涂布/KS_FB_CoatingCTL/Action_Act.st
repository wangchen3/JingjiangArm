(*@CES
Name=Action_Act
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=bb2c58b1-9823-44ec-956c-df33f15c974a
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}

(*获取列表*)
KS_GetCoatingAxisList(
				i_iGrpAxisNum_Pu,
				ADR(i_aiGrpAxisList),
				i_pstStCoatingAxisInf,
				axSwitchOn_CoatingPrn_In);
(*获取参数*)
KS_GetCoatingAxisInf(
	i_pstStCoatingAxisInf, 
	i_paxFlag_PressDne, 
	i_palrGirth_CoatingPrn, 
	axSwitchOn_CoatingPrn_In, 
	abyAdjMode_CoatingPrn_In, 
	axReverseAdj_CoatingPrn_In, 
	alrAI_CoatingPrn_In, 
	alrAI_med_CoatingPrn_In, 
	alrGirth_Using_CoatingPrn_In, 
	aiKp_CoatingPrn_In, 
	aiKi_CoatingPrn_In, 
	aiKd_CoatingPrn_In, 
	ADR(alrVelocity_CoatingPrn_In), 
	alrGirth_In );
	
(*获取模拟量*)
KS_GetCoatingAllnf(
	TRUE(*i_xGetCoatingAxisAI*), 
	FALSE(*i_xGetUnitAxisAI*), 
	rPressure_Max_In(*i_rPressure_Max*), 
	i_iGrpAxisNum_Pu(*i_iGrpAxisNum_Pu*), 
	ADR(i_aiGrpAxisList)(*i_paiGrpAxisList*), 
	i_pstStCoatingAxisInf(*i_pstStCoatingAxisInf*), 
	i_pastStIOMap_AxisExtra(*i_pastStIOMap_AxisExtra*), 
	ADR(aiAIAxisIdlist_Last_In)(*i_paiAIAxisIdlist_Last*), 
	ADR(abySensorType_CoatingPrn_In)(*i_pabySensorType_CoatingPrn*), 
	abyAdjMode_CoatingPrn_In(*i_abyAdjMode_CoatingPrn*), 
	ADR(alrAI_CoatingPrn_In)(*i_palrAI_CoatingPrn*));
	
(*界面摆臂显示列表处理*)
iIndex:=0;
FOR iN:=1 TO gc_byCoatingMaxSum_New BY 1 DO
	iIndex:=iIndex+1;
	IF iN<=byCoatingAxisNum_In THEN
		abyAxisList_CoatingPrn_Out[iN]:=INT_TO_BYTE(i_pstStCoatingAxisInf^.aiAxisIdList[iN]);
	ELSE
		abyAxisList_CoatingPrn_Out[iN]:=gc_byInvisCoatingPrnAxisIdx;
	END_IF
END_FOR
byAxisNum_CoatingPrn_Out:=byCoatingAxisNum_In;

xNotCoatingUnitPressed:=FALSE;
FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:= i_aiGrpAxisList[iN];

	IF i_palrGirth_CoatingPrn^[iUnitId]=0 THEN(*涂布轴周长=0.将涂布输入的轴周长写入*)
		i_palrGirth_CoatingPrn^[iUnitId]:=alrGirth_Using_CoatingPrn_In[iUnitId];
	END_IF

	(*2019.12.18.103510 增加了判断非涂布色组合压的标志|
	防止在未有非涂布色组合压情况下，失去主速度的状态后涂布色进行调整的问题*)
	IF xLinkage_In[iUnitId] THEN(*联动状态下*)
		IF ((NOT axSwitchOn_CoatingPrn_In[iUnitId]) OR
			( axSwitchOn_CoatingPrn_In[iUnitId] AND abyAdjMode_CoatingPrn_In[iUnitId]=0)) AND
			i_paxFlag_PressDne^[iUnitId] THEN(*如果涂布未打开,该色的压辊合压了我们输出标志*)
			IF NOT xNotCoatingUnitPressed THEN
				xNotCoatingUnitPressed:=TRUE;
			END_IF
		END_IF
	END_IF


	(*涂布方式切换*)
	IF abyAdjMode_CoatingPrn_In[iUnitId]<>0 THEN
		abyAdjMode_CoatingPrn_In[iUnitId]:=
							abyAdjMode_CoatingPrn_In[iUnitId]+1;
	END_IF

	IF abyAdjMode_CoatingPrn_In[iUnitId]>=gc_byCoatingWay THEN
		abyAdjMode_CoatingPrn_In[iUnitId]:=0;
	END_IF
	abyAdjMode_CoatingPrn_In[iUnitId]:=0;

END_FOR

//2026.08.06.100803 | + | 修复涂布功能块的bug | 将 iCoatId 全部替换为iN
(*涂布逻辑循环*)
FOR iN:=1 TO gc_byCoatingMaxSum_New  BY 1 DO
	IF iN<=byCoatingAxisNum_In THEN
		iUnitId:= i_pstStCoatingAxisInf^.aiAxisIdList[iN];

		xFlag_PressDne:=i_paxFlag_PressDne^[iUnitId];
		IF iN>gc_byCoatingMaxSum_New THEN
			EXIT;
		END_IF
		
//2026.8.20.171814|niu.j		
		pstStCoatingAxisParam:=ADR(i_pstStCoatingAxisInf^.astStCoatingAxisParam[iN]);
		(*涂布张力*)
		lrAIDel:=pstStCoatingAxisParam^.rAI_CoatingPrn-pstStCoatingAxisParam^.rAI_med_CoatingPrn;
		lrTemp:=lrAIDel;
		(*在这里我们把他压力差值转换为模拟量差值2019.8.9.172418*)
		IF pstStCoatingAxisParam^.byAdjMode_CoatingPrn=2 OR
			pstStCoatingAxisParam^.byAdjMode_CoatingPrn=3 THEN
			(*在使用压力传感器时上面两个值都是压力值,为了和模拟量的调整当量一致,不将张力值转换为电压值简单一点
			*1/50的系数进行转换*)
			lrTemp:=lrTemp/50;(*之前电压转换压力的时候乘的系数大概为50;500N对应10v*)
		END_IF
		
		xTensionCtlEn:=rVel_Film_In>0 AND
						pstStCoatingAxisParam^.xSwitchOn_CoatingPrn AND
						xFlag_PressDne AND(*压辊合压,印刷状态,涂布开*)
						xNotCoatingUnitPressed;(*2019.12.18.104046 增加了 非涂布色压辊合压的标志|防止失去主速度的状态*)

		afbKS_FB_Coating_Tension[iN](
			i_xEn:= xTensionCtlEn,
			i_xCoatingAdjDir:= pstStCoatingAxisParam^.xReverseAdj_CoatingPrn,
			i_byCoatingAdjWay:= pstStCoatingAxisParam^.byAdjMode_CoatingPrn,
			i_lrCurrentVel:= rVel_Cur_In,
			i_lrFilmVel:=rVel_Film_In ,
			i_lrCoatingGirth:= pstStCoatingAxisParam^.lrGirth_Using_CoatingPrn,
			i_lrAnalog:=lrTemp,
			i_lrP:=INT_TO_LREAL(pstStCoatingAxisParam^.iKp_CoatingPrn),
			i_lrD:=INT_TO_LREAL(pstStCoatingAxisParam^.iKd_CoatingPrn),
			i_byVelLimit_PerCent:=byVelLimit_PerCent_IfOf_In,(*2023.1.1.001931 增加*)
			o_xEn=> ,
			o_lrCoatingVel=>pstStCoatingAxisParam^.lrVelocity_CoatingPrn,
			o_lrCoatingUsingGirth=>pstStCoatingAxisParam^.lrGirth_CoatingPrn);

		(*界面显示表最大值*)
		IF pstStCoatingAxisParam^.byAdjMode_CoatingPrn=1  THEN
			iMaxTemp:=5;
		ELSIF pstStCoatingAxisParam^.byAdjMode_CoatingPrn=2 OR pstStCoatingAxisParam^.byAdjMode_CoatingPrn=3 THEN
		(*压力传感器界面指针最大显示值*)
			iMaxTemp:=50;
		ELSE
			iMaxTemp:=5;
		END_IF
		IF lrAIDel > iMaxTemp THEN lrAIDel:=iMaxTemp;
		ELSIF lrAIDel <-iMaxTemp THEN lrAIDel:=-iMaxTemp; END_IF
		pstStCoatingAxisParam^.rAI_CoatingHMI:=lrAIDel;
	ELSE
		afbKS_FB_Coating_Tension[iN](
			i_xEn:= FALSE,
			i_lrCurrentVel:= rVel_Cur_In,
			i_lrFilmVel:=rVel_Film_In ,
			i_lrAnalog:=0,
			i_byVelLimit_PerCent:=byVelLimit_PerCent_IfOf_In,(*2023.1.1.001931 增加*)
			o_xEn=> ,
			o_lrCoatingVel=>,
			o_lrCoatingUsingGirth=>);
	END_IF

END_FOR

(*更新到轴参数中*)
KS_SetCoatingAxisInf(
	i_pstStCoatingAxisInf, 
	ADR(aiAxisIdList_Last), 
	i_palrGirth_CoatingPrn, 
	i_palrAI_CoatingHMI, 
	axSwitchOn_CoatingPrn_In, 
	abyAdjMode_CoatingPrn_In, 
	axReverseAdj_CoatingPrn_In, 
	alrAI_CoatingPrn_In, 
	alrAI_med_CoatingPrn_In, 
	alrGirth_Using_CoatingPrn_In, 
	aiKp_CoatingPrn_In, 
	aiKi_CoatingPrn_In, 
	aiKd_CoatingPrn_In, 
	ADR(alrVelocity_CoatingPrn_In), 
	alrGirth_In );
