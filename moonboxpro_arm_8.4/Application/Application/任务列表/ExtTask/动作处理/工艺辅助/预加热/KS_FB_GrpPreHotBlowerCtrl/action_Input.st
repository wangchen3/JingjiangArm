(*@CES
Name=action_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=1e48bded-e2df-4897-9004-36bfb5efe5d4
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:=i_aiGrpAxisList[iN];
	pstStIOMap_Axis_Extra_FE := ADR(i_PastStIOMap_Axis_Extra_FE^[iUnitId]) ; 
	
	axPreHotBlower_In[iUnitId]   := pstStIOMap_Axis_Extra_FE^.i_xPreHotBlower;
	axPreHotBlower_Err_In[iUnitId] :=   pstStIOMap_Axis_Extra_FE^.i_xPreHotBlower_Err;
	axPreHeating_In[iUnitId]   :=  pstStIOMap_Axis_Extra_FE^.i_xPreHeating;
	axPreHeating_Err_In[iUnitId]   :=  pstStIOMap_Axis_Extra_FE^.i_xPreHeating_Err;
	
END_FOR