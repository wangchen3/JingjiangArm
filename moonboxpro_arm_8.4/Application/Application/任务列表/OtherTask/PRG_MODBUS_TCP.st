(*@CES
Name=PRG_MODBUS_TCP
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=8040f7c3-2c5c-428c-829e-f8dbe8b2490b
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
PROGRAM PRG_MODBUS_TCP
VAR
	axCoils: ARRAY [1..2] OF BYTE;(*线圈*)
	axDiscreteInput: ARRAY [1..2] OF BYTE;(*离散线圈*)
	awInputReg: ARRAY [1..2] OF WORD;(*输入寄存器*)
	awHoldingReg: ARRAY [1..1000] OF WORD;(*保持寄存器区*)
	wPort_VisionUI: WORD := 502;(*视觉访问的端口号*)
	udiXOFST_VisionUIGave: UDINT := 0;(*4字节*)
	uiXOFST_UpdateFlag: UINT := 0;(*X坐标值被更新标志*)
	//fbModbus_TCP_Slave: Modbus_TCP_Slave;(*ModBus TCP从站功能*)
	
	dwGirth_Temp:DWORD;
	wGirth_Temp_L:WORD;
	wGirth_Temp_H:WORD;
		(*地址约定
		40116: X坐标测量功能的使能,=1表示可以采集,其余值(推荐0)均为不可以.科赛程序控制;固德只读;
		40871: 测量X坐标的偏差(数据低位);固德写给科赛;
		40872: 测量X坐标的偏差(数据高位);固德写给科赛;
		40873: 写1表示40871和40872被更新了;科赛读取数据后写0即可
		40007: 版周长低位
		40008: 版周长高位
		*)
END_VAR


{IMPLEMENTATION}
awHoldingReg[116]:= BOOL_TO_WORD(g_xSendResToOnline);(*使能标志*)
//2026.04.11.184336 增加版周长通讯
dwGirth_Temp:=REAL_TO_DWORD(g_stStSysParam.astStGrpParam_Save[1].rGirth_PrnRoller*1000);
wGirth_Temp_L:=DWORD_TO_WORD(dwGirth_Temp);
wGirth_Temp_H:=DWORD_TO_WORD(SHR(dwGirth_Temp,16));
awHoldingReg[7]:=wGirth_Temp_L;
awHoldingReg[8]:=wGirth_Temp_H;
(*
fbModbus_TCP_Slave(
	pCoils:= ADR(axCoils), 
	pDiscreteInput:= ADR(axDiscreteInput), 
	pInputReg:= ADR(awInputReg), 
	pHoldingReg:= ADR(awHoldingReg), 
	CMax:= 16, 
	DIMax:= 16, 
	IRMax:= 2, 
	HRMax:= 1000, 
	Enable:= TRUE, 
	port:= wPort_VisionUI, 
	Enable_WatchDog:= FALSE, 
	tWatchDogTime:= , 
	ClientStatus=> , 
	wErrorId=> , 
	bError=> );
	*)
uiXOFST_UpdateFlag:= awHoldingReg[873];
IF uiXOFST_UpdateFlag=1 THEN
	g_stStSysParam.astStRSV_GrpParam_UnSave[1].xBasePosDoneByOnline:=TRUE;
	awHoldingReg[873]:=0;
	udiXOFST_VisionUIGave:= SHL(WORD_TO_UDINT(awHoldingReg[871]),16) OR WORD_TO_UDINT(awHoldingReg[872]);
	g_stStSysParam.astStRSV_GrpParam_UnSave[1].rFiberMoveBasePosByOnline:=UDINT_TO_REAL(udiXOFST_VisionUIGave)*0.001165+103.8341;
	
END_IF









