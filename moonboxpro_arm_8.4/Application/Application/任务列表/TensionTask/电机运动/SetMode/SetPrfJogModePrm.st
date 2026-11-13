(*@CES
Name=SetPrfJogModePrm
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=a1a4e312-954b-4b17-a8ec-a6ba64bc8c04
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION SetPrfJogModePrm : INT
VAR_INPUT
	i_iCore:INT;							//前64轴核号为1，后64轴轴号为2
	i_iAxisId:INT;
	i_lrAcc:LREAL;
	i_lrDec:LREAL;
	i_rSmooth: REAL;	
END_VAR
VAR
	iRtn:INT;
	stJogPrm:TJogPrm;	
END_VAR

{IMPLEMENTATION}
iRtn :=  GTN_PrfJog(i_iCore,i_iAxisId) + iRtn;

// 读取点位运动参数(需要读取所有运动参数到上位机变量)
iRtn :=  GTN_GetJogPrm(i_iCore,i_iAxisId, ADR(stJogPrm)) + iRtn;

// 设置需要修改的运动参数
stJogPrm.acc := i_lrAcc;
stJogPrm.dec := i_lrDec;
stJogPrm.smooth := i_rSmooth;

// 设置点位运动参数
iRtn :=  GTN_SetJogPrm(i_iCore,i_iAxisId,ADR(stJogPrm)) + iRtn;

SetPrfJogModePrm:=iRtn;