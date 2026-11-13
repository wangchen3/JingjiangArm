(*@CES
Name=KS_RstSysParam_UnSave
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=a7b887dc-87a6-43de-9951-73882ec7d195
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_RstSysParam_UnSave : INT
VAR_INPUT
	i_pstStSysParam_UnSave: POINTER TO StSysParam_UnSave;
	i_pstStSysParam_UnSave_RSV: POINTER TO StRSV_SysParam_UnSave;
END_VAR
VAR
	iResult: INT;
END_VAR

{IMPLEMENTATION}
iResult:=0;

IF i_pstStSysParam_UnSave<>0 AND i_pstStSysParam_UnSave_RSV<>0 THEN
	SysMemSet(ADR(i_pstStSysParam_UnSave_RSV^.abyRSV_SysParam_UnSave),
				0, 
				SIZEOF(i_pstStSysParam_UnSave_RSV^.abyRSV_SysParam_UnSave));
	i_pstStSysParam_UnSave^.byCurrUsrLevel					:= 0;
	i_pstStSysParam_UnSave^.diEncPos_Virtual                := 65536;
	i_pstStSysParam_UnSave^.xCommEn_Tcp                     := FALSE;
	i_pstStSysParam_UnSave^.xOpenSocketing                  := FALSE;
	i_pstStSysParam_UnSave^.xOpenSocketDne                  := FALSE;
	i_pstStSysParam_UnSave^.xOpenSocketFailed               := FALSE;
	i_pstStSysParam_UnSave^.xConnectOk_Tcp                  := FALSE;
	i_pstStSysParam_UnSave^.byConnectSts_Tcp                := 0;
	SysMemSet(ADR(i_pstStSysParam_UnSave^.abyReserved_Tcp),
				0,
				SIZEOF(i_pstStSysParam_UnSave^.abyReserved_Tcp));

	i_pstStSysParam_UnSave^.xCommEn_WatchDevice_Tcp         := FALSE;
	i_pstStSysParam_UnSave^.xOpenSocketing_WatchDevice      := FALSE;
	i_pstStSysParam_UnSave^.xOpenSocketDne_WatchDevice      := FALSE;
	i_pstStSysParam_UnSave^.xOpenSocketFailed_WatchDevice   := FALSE;
	i_pstStSysParam_UnSave^.xConnectOk_WatchDevice_Tcp      := FALSE;
	i_pstStSysParam_UnSave^.byConnectSts_WatchDevice_Tcp    := 0;
	SysMemSet(ADR(i_pstStSysParam_UnSave^.abyReserved1_Tcp),
				0,
				SIZEOF(i_pstStSysParam_UnSave^.abyReserved1_Tcp));
	
	i_pstStSysParam_UnSave^.xCommEn_485                     := FALSE;
	i_pstStSysParam_UnSave^.xOpenPortDne                    := FALSE;
	i_pstStSysParam_UnSave^.xOpenPortFailed                 := FALSE;
	i_pstStSysParam_UnSave^.xCommEn_WatchDevice_485         := FALSE;
	i_pstStSysParam_UnSave^.byConnectSts_485                := 0;
	SysMemSet(ADR(i_pstStSysParam_UnSave^.abyReserved_485),
				0,
				SIZEOF(i_pstStSysParam_UnSave^.abyReserved_485));
	
	i_pstStSysParam_UnSave^.rAO0_WaterValue_Start           := 50;
	i_pstStSysParam_UnSave^.rAO0_WaterValue_Start2          := 80;
(*	i_pstStSysParam_UnSave^.stStSysCfgStruct                := 0;(*系统配置初始化怎么处理*)
	*)	
	i_pstStSysParam_UnSave^.byTaperUnitType:= 0;
	i_pstStSysParam_UnSave^.byArcDeCoupleStepTest			:= 0;
	i_pstStSysParam_UnSave^.xSaveFineSampleData_ToArc		:= FALSE;	
	i_pstStSysParam_UnSave^.byCurGrpId_HMI					:= 1;	
	iResult:=1;
ELSE
	iResult:=-1;
END_IF