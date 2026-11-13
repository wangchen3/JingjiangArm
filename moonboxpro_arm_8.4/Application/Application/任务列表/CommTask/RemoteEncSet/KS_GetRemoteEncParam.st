(*@CES
Name=KS_GetRemoteEncParam
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=5c03e2a5-041e-48c9-9983-827936801836
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetRemoteEncParam : BOOL
VAR_INPUT
	i_xGet:BOOL;
	i_byStationId:BYTE;
	i_puiA:POINTER TO UINT;
	i_puiB:POINTER TO UINT;
	i_puiN:POINTER TO UINT;
	i_dwMotorEnc:POINTER TO DWORD;
	i_dwMotorEnc_DDA:POINTER TO DWORD;
END_VAR
VAR
	diTmp:DINT;
END_VAR

{IMPLEMENTATION}
IF i_xGet THEN
	(*DDA后移位N*)
	GT_RN_UserRemoteEncRd(0,ADR(diTmp),i_byStationId);
	IF i_puiN<>0 THEN
		i_puiN^:=DINT_TO_UINT(diTmp);
	END_IF
	(*DDA后编码器分辨率*)
	GT_RN_UserRemoteEncRd(1,ADR(diTmp),i_byStationId);
	IF i_puiN<>0 THEN
		i_dwMotorEnc_DDA^:=DINT_TO_DWORD(diTmp);
	END_IF
	(*电机编码器分辨率*)
	GT_RN_UserRemoteEncRd(2,ADR(diTmp),i_byStationId);
	IF i_puiN<>0 THEN
		i_dwMotorEnc^:=DINT_TO_DWORD(diTmp);
	END_IF

	(*设置减速比A*)
	GT_RN_UserRemoteEncRd(3,ADR(diTmp),i_byStationId);
	IF i_puiA<>0 THEN
		i_puiA^:=DINT_TO_UINT(diTmp);
	END_IF

	(*设置减速比b*)
	GT_RN_UserRemoteEncRd(4,ADR(diTmp),i_byStationId);
	IF i_puiB<>0 THEN
		i_puiB^:=DINT_TO_UINT(diTmp);
	END_IF

END_IF