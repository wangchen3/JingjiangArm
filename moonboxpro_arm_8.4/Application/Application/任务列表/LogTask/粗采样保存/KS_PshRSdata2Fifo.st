(*@CES
Name=KS_PshRSdata2Fifo
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=7d186a17-b9d1-422c-94b2-454e470a5b16
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_PshRSdata2Fifo : INT
VAR_INPUT
	i_pstStRSampFifo: POINTER TO StRSampFifo;
	i_pbyRs_T1: POINTER TO BYTE;
	i_pbyRs_T2: POINTER TO BYTE;
	i_byUnitNR: BYTE;
	i_diVel: DINT;
	i_udiTskCycleNR: UDINT;
END_VAR
VAR
	iResult: INT;
	byIDX_Tmp: BYTE;
END_VAR
{IMPLEMENTATION}
IF i_pstStRSampFifo<>0 AND
	i_pbyRs_T1<>0 AND
	i_pbyRs_T2<>0 THEN

	byIDX_Tmp:= i_pstStRSampFifo^.byIDX_Wr AND BYTE#7;(* 控制循环0~7 *)
	i_pstStRSampFifo^.astStRSampData[byIDX_Tmp].byUnitNR:= i_byUnitNR;
	i_pstStRSampFifo^.astStRSampData[byIDX_Tmp].diVel:= i_diVel;
	i_pstStRSampFifo^.astStRSampData[byIDX_Tmp].udiTskCycleNR:= i_udiTskCycleNR;
	SysMemCpy(
		ADR(i_pstStRSampFifo^.astStRSampData[byIDX_Tmp].abyRs_T1),
		i_pbyRs_T1,
		SIZEOF(i_pstStRSampFifo^.astStRSampData[byIDX_Tmp].abyRs_T1) );
	SysMemCpy(
		ADR(i_pstStRSampFifo^.astStRSampData[byIDX_Tmp].abyRs_T2),
		i_pbyRs_T2,
		SIZEOF(i_pstStRSampFifo^.astStRSampData[byIDX_Tmp].abyRs_T2) );

	i_pstStRSampFifo^.byIDX_Wr:= byIDX_Tmp+1;

	iResult:= 0;
ELSE
	iResult:= -1;
END_IF
KS_PshRSdata2Fifo:= iResult;