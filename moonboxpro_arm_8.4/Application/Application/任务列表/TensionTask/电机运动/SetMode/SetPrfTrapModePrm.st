(*@CES
Name=SetPrfTrapModePrm
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=a2a95545-544a-475f-b543-56a661f67a2d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION SetPrfTrapModePrm : INT
VAR_INPUT
	i_iCoreId:INT;						//前64轴核号为1，后64轴轴号为2
	i_iAxisId:INT;
	i_lrVel:LREAL;
	i_lrAcc:LREAL;
	i_lrDec:LREAL;
	i_iSmoothTime: INT;
	//i_paiRtn : POINTER TO ARRAY [1..10] OF INT;
END_VAR
VAR
	iN : INT;
	aiRtn : ARRAY [1..10] OF INT;
	stTrapPrm : TTrapPrm;
END_VAR

{IMPLEMENTATION}
aiRtn[1] :=  GTN_PrfTrap(i_iCoreId,i_iAxisId);

// 读取点位运动参数(需要读取所有运动参数到上位机变量)
aiRtn[2] :=  GTN_GetTrapPrm(i_iCoreId,i_iAxisId, ADR(stTrapPrm));

// 设置需要修改的运动参数
stTrapPrm.acc := i_lrAcc;
stTrapPrm.dec := i_lrDec;
stTrapPrm.velStart := 0;
stTrapPrm.smoothTime := i_iSmoothTime;

// 设置点位运动参数
aiRtn[3] :=  GTN_SetTrapPrm(i_iCoreId,i_iAxisId,ADR(stTrapPrm));

aiRtn[4] := GTN_SetVel(i_iCoreId,i_iAxisId,i_lrVel);

SetPrfTrapModePrm:=aiRtn[1]+aiRtn[2]+aiRtn[3]+aiRtn[4];

// FOR iN := 1 TO 10 BY 1 DO
// 	i_paiRtn^[iN] := aiRtn[iN];
// END_FOR