(*@CES
Name=stEuumMachineryType
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=aab11485-0b5d-4c95-bba7-862ff1a86d0f
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
//{attribute 'qualified_only'}
{attribute 'strict'}
TYPE stEuumMachineryType :((*机器类型*)
	MACHINERYTYPE_ROTOGRAVE,(*凹版印刷机*)
	MACHINERYTYPE_FELXO_INLINE,(*机组式柔印@套色叠加轴在网辊*)
	MACHINERYTYPE_FELXO_INLINE_ONEBOTOMROLLER,(*机组式柔印@单底辊(套色叠加轴是需要在底辊上)*)
	MACHINERYTYPE_FELXO_CL,(*卫星式柔印*)
	MACHINERYTYPE_OFFSET(*胶印机*)
);
END_TYPE
{IMPLEMENTATION}
