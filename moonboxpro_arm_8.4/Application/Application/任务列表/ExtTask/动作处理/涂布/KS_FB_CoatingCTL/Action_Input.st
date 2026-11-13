(*@CES
Name=Action_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=ea4a972a-2eda-419c-a7cb-c4aeb5f97a43
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:= i_aiGrpAxisList[iN];
	axSwitchOn_CoatingPrn_In[iUnitId]:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].xSwitchOn_CoatingPrn;
	abyAdjMode_CoatingPrn_In[iUnitId]:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].byAdjMode_CoatingPrn;
	axReverseAdj_CoatingPrn_In[iUnitId]:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].xReverseAdj_CoatingPrn;
	alrAI_CoatingPrn_In[iUnitId]:= i_pstStsysParam^.astStUnitParam_Save[iUnitId].lrAI_CoatingPrn;
	alrAI_med_CoatingPrn_In[iUnitId]:= i_pstStsysParam^.astStUnitParam_Save[iUnitId].lrAI_med_CoatingPrn;
	alrGirth_Using_CoatingPrn_In[iUnitId]:= i_pstStsysParam^.astStUnitParam_Save[iUnitId].lrGirth_Using_CoatingPrn;
	aiKp_CoatingPrn_In[iUnitId]:= i_pstStsysParam^.astStUnitParam_Save[iUnitId].iKp_CoatingPrn;
	aiKi_CoatingPrn_In[iUnitId]:= i_pstStsysParam^.astStUnitParam_Save[iUnitId].iKi_CoatingPrn;
	aiKd_CoatingPrn_In[iUnitId]:= i_pstStsysParam^.astStUnitParam_Save[iUnitId].iKd_CoatingPrn;
	(*变量使用错误@2026.08.21.133945+*)
	(*alrVelocity_CoatingPrn_In[iUnitId]:=i_pstStCoatingAxisInf^.astStCoatingAxisParam[iUnitId].lrVelocity_CoatingPrn;*)
	alrVelocity_CoatingPrn_In[iUnitId]:=i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].lrVelocity_CoatingPrn;
	abySensorType_CoatingPrn_In[iUnitId]:= i_pstStsysParam^.astStUnitParam_Save[iUnitId].bySensorType_CoatingPrn;
	alrGirth_In[iUnitId]:= i_pstStsysParam^.astStUnitParam_Save[iUnitId].rGirth_PrnRoller;//未确定参数
//	lrGirth_Using_CoatingPrn_In[iUnitId]:= i_pstStsysParam^.astStUnitParam_Save[iUnitId].lrGirth_Using_CoatingPrn;
	xLinkage_In[iUnitId]:= i_pstStsysParam^.astStUnitParam_Save[iUnitId].xLinkage;

END_FOR


rPressure_Max_In:=i_pstStsysParam^.astStGrpParam_Save[i_iGrpId].rPressure_Max;
rVel_Cur_In:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur;
rVel_Film_In:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Film;
byVelLimit_PerCent_IfOf_In:=i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byVelLimit_PerCent_IfOf;

(*
	xSwitchOn_CoatingPrn			:BOOL;(*涂布开关*)
	byAdjMode_CoatingPrn			:BYTE;(*涂布轴模式*)
	xReverseAdj_CoatingPrn			:BOOL;(*涂布轴调整取反*)
	rAI_CoatingPrn					:REAL;(*涂布轴模拟量*)
	rAI_med_CoatingPrn				:REAL;(*涂布轴中位值*)
	lrGirth_Using_CoatingPrn		:LREAL;(*涂布轴周长@界面输入*)
	iKp_CoatingPrn					:INT;(*涂布kp*)
	iKi_CoatingPrn					:INT;(*涂布ki*)
	iKd_CoatingPrn					:INT;(*涂布kd*)
	xFlag_PressDne					:BOOL;(*涂布轴合压*)
	rAI_CoatingHMI					:REAL;(*涂布模拟量显示*)
	lrGirth_CoatingPrn				:LREAL;(*涂布周长@用于运算pt*)
	lrVelocity_CoatingPrn			:LREAL;(*涂布速度*)	
*)
//2026.8.20.172558这里xian不要
//niu.j
(*
FOR iCoatId:=1 TO gc_byCoatingMaxSum_New BY 1 DO
	aiAxisIdList_In[iCoatId]:=i_pstStCoatingAxisInf^.aiAxisIdList[iCoatId];
	xSwitchOn_CoatingPrn_In[iCoatId]:=i_pstStCoatingAxisInf^.astStCoatingAxisParam[iCoatId].xSwitchOn_CoatingPrn;
	byAdjMode_CoatingPrn_In[iCoatId]:=i_pstStCoatingAxisInf^.astStCoatingAxisParam[iCoatId].byAdjMode_CoatingPrn;
	xReverseAdj_CoatingPrn_In[iCoatId]:=i_pstStCoatingAxisInf^.astStCoatingAxisParam[iCoatId].xReverseAdj_CoatingPrn;
	rAI_CoatingPrn_In[iCoatId]:=i_pstStCoatingAxisInf^.astStCoatingAxisParam[iCoatId].rAI_CoatingPrn;
	rAI_med_CoatingPrn_In[iCoatId]:=i_pstStCoatingAxisInf^.astStCoatingAxisParam[iCoatId].rAI_med_CoatingPrn;
	lrGirth_Using_CoatingPrnHMI_In[iCoatId]:=i_pstStCoatingAxisInf^.astStCoatingAxisParam[iCoatId].lrGirth_Using_CoatingPrn;
	iKp_CoatingPrn_In[iCoatId]:=i_pstStCoatingAxisInf^.astStCoatingAxisParam[iCoatId].iKp_CoatingPrn;
	iKi_CoatingPrn_In[iCoatId]:=i_pstStCoatingAxisInf^.astStCoatingAxisParam[iCoatId].iKi_CoatingPrn;
	iKd_CoatingPrn_In[iCoatId]:=i_pstStCoatingAxisInf^.astStCoatingAxisParam[iCoatId].iKd_CoatingPrn;
	xFlag_PressDne_In[iCoatId]:=i_pstStCoatingAxisInf^.astStCoatingAxisParam[iCoatId].xFlag_PressDne;
	rAI_CoatingHMI_In[iCoatId]:=i_pstStCoatingAxisInf^.astStCoatingAxisParam[iCoatId].rAI_CoatingHMI;
	lrGirth_CoatingPrn_In[iCoatId]:=i_pstStCoatingAxisInf^.astStCoatingAxisParam[iCoatId].lrGirth_CoatingPrn;
	lrVelocity_CoatingPrn_In[iCoatId]:=i_pstStCoatingAxisInf^.astStCoatingAxisParam[iCoatId].lrVelocity_CoatingPrn;
	
END_FOR
*)
byCoatingAxisNum_In:=i_pstStCoatingAxisInf^.byCoatingAxisNum;

