(*@CES
Name=Action_Normal_Update_HMIBtn
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=189c0e70-8fb7-42d7-b2cb-806a8ba76bd1
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
// FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
// 	g_astStMcgsBtn_HMI[iN].xSwitch_Linkage:= g_stStSysParam.astStUnitParam_Save[iN].wSwitchFun.0;
// 	g_astStMcgsBtn_HMI[iN].xSwitch_PressRollAuto:= g_stStSysParam.astStUnitParam_Save[iN].wSwitchFun.1;
// 	g_astStMcgsBtn_HMI[iN].xBtn_Inch:= g_stStSysParam.astStUnitParam_Save[iN].wButtonFun_Lamp.0;
// 
// 	IF g_astStMcgsBtn_HMI[iN].xBtn_Inch THEN
// 		g_aiCntInch[iN] := g_aiCntInch[iN] + 1;
// 	END_IF	
// END_FOR


//2025.12.03.133036 | TEST_
FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
	IF g_axPress_Manu[iN] THEN
		aiPress_Manu[iN] := aiPress_Manu[iN] + 1;
		IF aiPress_Manu[iN] > 5 THEN
			aiPress_Manu[iN] := 0;
			g_axPress_Manu[iN]:= FALSE;
		END_IF
	END_IF
	IF g_axUnPress_Manu[iN] THEN
		aiUnPress_Manu[iN] := aiUnPress_Manu[iN] + 1;
		IF aiUnPress_Manu[iN] > 5 THEN
			aiUnPress_Manu[iN] := 0;
			g_axUnPress_Manu[iN]:= FALSE;
		END_IF
	END_IF	
END_FOR