(*@CES
Name=StMcgsBtn_HMI
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=5e6016cf-d5df-40b4-85da-5580a79e1b5e
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StMcgsBtn_HMI :
STRUCT
	xSwitch_Linkage: BIT;
	xSwitch_PressRollAuto: BIT;
	//2026.06.03.132205
	xSwitch_TurnoverFilm:BIT;
	
	xBtn_Inch: BIT;
	xBtn_Press: BIT;
	xBtn_UnPress: BIT;
	
	xLamp_Inching: BIT;
	//2026.04.08.195710
	//xBtn_TurnoverFilm:BIT;
	xBtn_Stop:BIT;
	xBtn_Ink:BIT;
	xBtn_Print:BIT;
	xBtn_PreStart:BIT;	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
