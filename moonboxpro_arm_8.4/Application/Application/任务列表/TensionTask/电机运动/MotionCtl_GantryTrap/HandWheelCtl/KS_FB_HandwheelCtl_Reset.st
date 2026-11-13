(*@CES
Name=KS_FB_HandwheelCtl_Reset
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=166e6113-4ec8-46e9-b440-4c67f8b36266
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_HandwheelCtl_Reset
VAR_INPUT
	i_iD : INT;
	i_pstStHandWheel_BtnCtl : POINTER TO StHandWheel_BtnCtl;
END_VAR
VAR_OUTPUT
END_VAR
VAR
END_VAR

{IMPLEMENTATION}
i_pstStHandWheel_BtnCtl^.axReq_Confirm_Load_Unload[i_iD]:= FALSE;
i_pstStHandWheel_BtnCtl^.axReq_Confirm_press_up[i_iD]:=FALSE;
i_pstStHandWheel_BtnCtl^.axReq_Confirm_press_dn[i_iD]:= FALSE;
i_pstStHandWheel_BtnCtl^.axFlag_Ctl_Roller_All[i_iD]:= FALSE;
i_pstStHandWheel_BtnCtl^.axFlag_Ctl_Roller_M[i_iD]:= FALSE;	
i_pstStHandWheel_BtnCtl^.axFlag_Ctl_Roller_G[i_iD]:= FALSE;                                           
i_pstStHandWheel_BtnCtl^.axReqMoveFor[i_iD]:= FALSE;
i_pstStHandWheel_BtnCtl^.axReqMoveRev[i_iD]:= FALSE;
