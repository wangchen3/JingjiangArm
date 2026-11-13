(*@CES
Name=ENUM_ADJUSTSTEP
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=efa34ddf-7ecc-460b-b490-cc3a675ccb88
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE ENUM_ADJUSTSTEP :
(
	STEP_AUTO,(*自动调整状态*)
	STEP_MANU,(*手动调整状态*)
	STEP_PREG,(*配方-预套准状态*)
	STEP_INCH,(*单运行状态*)
	STEP_TEST,(*小郭测试使用*)
	STEP_IDIE(*其他*)
);
END_TYPE

{IMPLEMENTATION}
