(*@CES
Name=KS_FillUnitMailboxCmd_DN
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=71378417-e57d-41a2-ab76-6caecfcdbb3a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_FillUnitMailboxCmd_DN : INT
VAR_INPUT
	i_pstStParam_Mailbox: POINTER TO StParam_Mailbox;
	i_pstStUnitParam_Save: POINTER TO StUnitParam_Save;
	i_pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;
END_VAR
VAR
	iResult: INT;
END_VAR
{IMPLEMENTATION}
iResult:= 0;
IF i_pstStParam_Mailbox<>0 AND i_pstStUnitParam_Save<>0 THEN
	i_pstStParam_Mailbox^.dwSemaphore						:= SEMA_DOWNLOAD;
	i_pstStParam_Mailbox^.dwPlateAdjustmentProf             := 0;
	i_pstStParam_Mailbox^.iRapidAdjProf_h                  	:= 0;
	i_pstStParam_Mailbox^.iGateSa                      	    := i_pstStUnitParam_Save^.iGateSa;
	i_pstStParam_Mailbox^.iGateSaEx                     	:= i_pstStUnitParam_Save^.iGateSaEx;
	i_pstStParam_Mailbox^.rAdjust_V                     	:= i_pstStUnitParam_Save^.rAdj_V;
	i_pstStParam_Mailbox^.rAdjust_H                     	:= i_pstStUnitParam_Save^.rAdj_H;
	i_pstStParam_Mailbox^.dwFlag_Ctl                    	:= i_pstStUnitParam_Save^.dwFlag_Ctl;
	i_pstStParam_Mailbox^.dwFlag_Sts                    	:= i_pstStUnitParam_Save^.dwFlag_Sts;
	i_pstStParam_Mailbox^.wButtonFun_Lamp               	:= i_pstStUnitParam_Save^.wButtonFun_Lamp;
	i_pstStParam_Mailbox^.dwSlaveBtn_HMI                	:= i_pstStUnitParam_Save^.dwSlaveBtn_HMI;
	i_pstStParam_Mailbox^.rStep_Pressure_Prn_Net        	:= i_pstStUnitParam_Save^.rStep_Pressure_Prn_Net;
	i_pstStParam_Mailbox^.rLong_Step_Roller_Pressure    	:= i_pstStUnitParam_Save^.rLong_Step_Roller_Pressure;
	i_pstStParam_Mailbox^.rShort_Step_Roller_Pressure   	:= i_pstStUnitParam_Save^.rShort_Step_Roller_Pressure;
	i_pstStParam_Mailbox^.wAirInletWindDoorValue        	:= i_pstStUnitParam_Save^.byHotBlower_AO;
	i_pstStParam_Mailbox^.wAirExhaustWindDoorValue      	:= i_pstStUnitParam_Save^.wAirExhaustWindDoorValue;
	i_pstStParam_Mailbox^.wAirReturnWindDoorValue       	:= i_pstStUnitParam_Save^.wAirReturnWindDoorValue;
	i_pstStParam_Mailbox^.dwCtlBits_UnitBaseCraft       	:= i_pstStUnitParam_Save^.dwCtlBits_UnitBaseCraft;
	i_pstStParam_Mailbox^.wHz_UnitInkRoller_ManuallySet 	:= REAL_TO_WORD(i_pstStUnitParam_Save^.rHz_UnitInkRoller_ManuallySet*100.0);
	i_pstStParam_Mailbox^.wCoeff_UnitInkRoller_Auto     	:= REAL_TO_WORD(i_pstStUnitParam_Save^.rCoeff_UnitInkRoller_Auto*100.0);
	i_pstStParam_Mailbox^.wHz_UnitScraper_ManuallySet   	:= REAL_TO_WORD(i_pstStUnitParam_Save^.rHz_UnitScraper_ManuallySet*100.0);
	i_pstStParam_Mailbox^.wCoeff_UnitScraper_Auto       	:= REAL_TO_WORD(i_pstStUnitParam_Save^.rCoeff_UnitScraper_Auto*100.0);
	i_pstStParam_Mailbox^.wHz_UnitHotWind               	:= REAL_TO_WORD(i_pstStUnitParam_Save^.rHz_UnitHotWind_ManuallySet*100.0);
	i_pstStParam_Mailbox^.wHz_UnitHotWind_2             	:= REAL_TO_WORD(i_pstStUnitParam_Save^.rHz_UnitHotWind_2_ManuallySet*100.0);
	i_pstStParam_Mailbox^.wSV_UnitTemCtl                	:= REAL_TO_WORD(i_pstStUnitParam_Save^.rSV_UnitTemCtl*100.0);
	i_pstStParam_Mailbox^.wUnit_output_I                	:= i_pstStUnitParam_UnSave^.wUnit_output_I;
	i_pstStParam_Mailbox^.wUnit_output_II               	:= i_pstStUnitParam_UnSave^.wUnit_output_II;
	//xi.hy//新增
	i_pstStParam_Mailbox^.bySignalSelect          				:= i_pstStUnitParam_Save^.bySignalSelect;
	i_pstStParam_Mailbox^.rOffset_T1          				:= i_pstStUnitParam_Save^.rOffset_T1;
	i_pstStParam_Mailbox^.rSource_Light_T1                  := i_pstStUnitParam_Save^.rSource_Light_T1;
	i_pstStParam_Mailbox^.rBias_T1          				:= i_pstStUnitParam_Save^.rBias_T1;
	i_pstStParam_Mailbox^.rBrightness_Light_T1              := i_pstStUnitParam_Save^.rBrightness_Light_T1;
	i_pstStParam_Mailbox^.rOffset_T2          				:= i_pstStUnitParam_Save^.rOffset_T2;
	i_pstStParam_Mailbox^.rSource_Light_T2                  := i_pstStUnitParam_Save^.rSource_Light_T2;
	i_pstStParam_Mailbox^.rBias_T2          				:= i_pstStUnitParam_Save^.rBias_T2;
	i_pstStParam_Mailbox^.rBrightness_Light_T2              := i_pstStUnitParam_Save^.rBrightness_Light_T2;
	
	
ELSE
	iResult:= -1;
END_IF
KS_FillUnitMailboxCmd_DN:= iResult;