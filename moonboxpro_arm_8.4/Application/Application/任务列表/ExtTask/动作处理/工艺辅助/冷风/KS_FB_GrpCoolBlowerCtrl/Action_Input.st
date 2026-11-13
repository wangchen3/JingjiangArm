(*@CES
Name=Action_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=19c1f262-43e1-41a2-9636-ec3da2d42e87
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}

FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:=i_aiGrpAxisList[iN];
	pstStIOMap_Axis_Extra_FE := ADR(i_PastStIOMap_Axis_Extra_FE^[iUnitId]) ; 
	axCoolBlower_In[iUnitId]			:= pstStIOMap_Axis_Extra_FE^.i_xCoolBlower;	
	axCoolBlower_Button_In[iUnitId]			:=pstStIOMap_Axis_Extra_FE^.i_xCoolBlower_Button ;
END_FOR

	