(*@CES
Name=SetPrfGantryTrapModePrm
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=46cb849a-922f-49f0-be65-4966a012b8cb
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION SetPrfGantryTrapModePrm : INT
VAR_INPUT
	i_iCoreId:INT;							//前64轴核号为1，后64轴轴号为2
	i_iGroupId : INT;
	i_iAxisMaster:INT;
	i_iAxisSlaver:INT;
	i_iAxisMasterVirtual:INT;//主轴叠加轴轴号；
	i_diSyncErrorLimit : DINT;
END_VAR
VAR
	iRtn:INT:=0;
	STGantryPrmPro : TGantryPrmPro;
	STPidAlign : TPidAlign;
END_VAR

{IMPLEMENTATION}
// SysMemSet(ADR(STGantryPrmPro),0,SIZEOF(STGantryPrmPro));
// 
// STGantryPrmPro.mode := GANTRY_MODE_NONE;									//龙门模式  20开环龙门模式  勿改
// STGantryPrmPro.master :=i_iAxisMaster;						//主轴轴号
// STGantryPrmPro.slave := i_iAxisSlaver;							//从轴轴号
// STGantryPrmPro.reserve[0] := i_iAxisMasterVirtual;				//主轴叠加轴轴号；此数组从0开始，一定要注意
// STGantryPrmPro.reserve[1] := 0;								//必须为0
// STGantryPrmPro.reserve[2] := 0;								//必须为0
// STGantryPrmPro.syncErrorLimit := i_diSyncErrorLimit;					//龙门最大差值
// 
// STGantryPrmPro.gantryMasterPid.kp := 1;
// STGantryPrmPro.gantrySlavePid.kp := 1;
// STGantryPrmPro.masterPid.kp := 1;
// STGantryPrmPro.slavePid.kp := 1;
// iRtn := GTN_SetGantryPrmPro(core:= i_iCoreId, group:=i_iGroupId, pGantryPrmPro:= ADR(STGantryPrmPro)) + iRtn;

SysMemSet(ADR(STGantryPrmPro),0,SIZEOF(STGantryPrmPro));

STGantryPrmPro.mode := 20;									//龙门模式  20开环龙门模式  勿改
STGantryPrmPro.master :=i_iAxisMaster;						//主轴轴号
STGantryPrmPro.slave := i_iAxisSlaver;							//从轴轴号
STGantryPrmPro.reserve[0] := i_iAxisMasterVirtual;				//主轴叠加轴轴号；此数组从0开始，一定要注意
STGantryPrmPro.reserve[1] := 0;								//必须为0
STGantryPrmPro.reserve[2] := 0;								//必须为0
STGantryPrmPro.syncErrorLimit := i_diSyncErrorLimit;					//龙门最大差值

STGantryPrmPro.gantryMasterPid.kp := 1;
STGantryPrmPro.gantrySlavePid.kp := 1;
STGantryPrmPro.masterPid.kp := 1;
STGantryPrmPro.slavePid.kp := 1;
//
// STPidAlign.kp := 1;
// STPidAlign.ki := 1;
// STPidAlign.kd := 1;
// STPidAlign.kaff := 1;
// STPidAlign.kvff := 1;
// STPidAlign.derivativeLimit := 1;
// STPidAlign.integralLimit := 1;
// STPidAlign.s_limit := 1;
// STPidAlign.reserve[1] := 0;
// STPidAlign.reserve[2] := 0;

// SysMemCpy(ADR(STGantryPrmPro.gantryMasterPid),ADR(STPidAlign),SIZEOF(STPidAlign));
// SysMemCpy(ADR(STGantryPrmPro.gantrySlavePid),ADR(STPidAlign),SIZEOF(STPidAlign));
// SysMemCpy(ADR(STGantryPrmPro.masterPid),ADR(STPidAlign),SIZEOF(STPidAlign));
// SysMemCpy(ADR(STGantryPrmPro.slavePid),ADR(STPidAlign),SIZEOF(STPidAlign));

iRtn := GTN_SetGantryPrmPro(core:= i_iCoreId, group:=i_iGroupId, pGantryPrmPro:= ADR(STGantryPrmPro)) + iRtn;


iRtn := SetPrfTrapModePrm(
				i_iCoreId:= i_iCoreId, 
				i_iAxisId:= i_iAxisMaster, 
				i_lrVel:= 100,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrVel, 
				i_lrAcc:= 1,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrAcc, 
				i_lrDec:= 1,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrDec, 
				i_iSmoothTime:= 0) + iRtn;//i_pastTStTrapParamUser^[iCnt_TrapAxis].iSmoothTime);
				
iRtn := SetPrfTrapModePrm(
				i_iCoreId:= i_iCoreId, 
				i_iAxisId:= i_iAxisSlaver, 
				i_lrVel:= 100,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrVel, 
				i_lrAcc:= 1,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrAcc, 
				i_lrDec:= 1,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrDec, 
				i_iSmoothTime:= 0) + iRtn;//i_pastTStTrapParamUser^[iCnt_TrapAxis].iSmoothTime);

iRtn := SetPrfTrapModePrm(
				i_iCoreId:= i_iCoreId, 
				i_iAxisId:= i_iAxisMasterVirtual, 
				i_lrVel:= 100,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrVel, 
				i_lrAcc:= 1,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrAcc, 
				i_lrDec:= 1,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrDec, 
				i_iSmoothTime:= 0) + iRtn;//i_pastTStTrapParamUser^[iCnt_TrapAxis].iSmoothTime);

SetPrfGantryTrapModePrm:=iRtn;