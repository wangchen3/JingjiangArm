(*@CES
Name=TypeEnumInkGrooveMsg
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=e4841006-6196-426e-9e86-ef53e879e515
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE TypeEnumInkGrooveMsg :
(*信息枚举@和语言文件相关|1--9错误码|200以后为状态*)
(
	MSG_NONE:=0,(*无意义*)
	MSG_ZEROINVALID:=1,(*零点非法*)
	MSG_BASEINFINVALID,(*基准信息未确认*)
	MSG_MOVEDIS_OUTLIMTIT,(*运动距离超限*)
	MSG_UPLIMIT,(*上限位*)
	MSG_DNLIMIT,(*下限位*)
	MSG_MOVEFAILED,(*运动失败=6*)

	MSG_UPING:=200,(*向上运动中*)
	MSG_DNING(*向下运动中*)
);
END_TYPE

{IMPLEMENTATION}
