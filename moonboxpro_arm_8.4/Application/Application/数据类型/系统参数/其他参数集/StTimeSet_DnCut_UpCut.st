(*@CES
Name=StTimeSet_DnCut_UpCut
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=3d90f000-d022-493a-8845-04f294dfa37c
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StTimeSet_DnCut_UpCut :
STRUCT
	iDelayMsec_CutterHolder			: INT; (* 裁刀架延时 *)
	iDelayMsec_RollerCylinder		: INT; (* 胶辊汽缸延时 *)
	iDelayMsec_CutOffKnifeCylinder	: INT; (* 裁刀汽缸延时 *)
	uiMM_Roller2GummedTape			: UINT; (* 压辊压在料上距胶带的距离/单位:mm *)
	uiMM_Roller2CutOfKnife			: UINT; (* 压辊距裁刀的材料距离|单位:mm *)
	uiMM_CutOfKnife2GummedTape		: UINT; (* 裁刀距胶带的距离/单位:mm *)
	iStepVariation4ChangeTime		: INT; (* 2018.9.30.100457/用来步进胶辊延时和裁刀延时的变化量 *)
	iDelaySec_AirInflation_Mixed	: INT; (* 一刀双裁大臂充气延时/2019.6.20.175319 *)
	iHodTime_HelpStep_RollerCylinder: INT;(*2021.7.17.140936 增加接料压辊助走持续时间--ALTMA*)
	rStepVariation4ChangeDis		: REAL;(*参考距离值|2022.10.13.105318|mm*)
	abyRsvdFields						: ARRAY [1..44] OF BYTE; (* 保留区域 *)
	(*2022.10.13.105336 +rStepVariation4ChangeDis|48-->44*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
