(*@CES
Name=StFindResult
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=f624abef-a881-46ee-91b9-f19468406fe9
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
// 寻找模块结果
TYPE StFindResult :
STRUCT
    xSuccess: BOOL;                      (* 寻找成功 *)
    iCurLabelPos: INT;                   (* 当前色位置 *)
    iPreLabelPos: INT;                   (* 前色位置 *)
    iCurBestPos: INT;                    (* 当前色最佳位置 *)
    rFiberMoveDist: REAL;                (* 光纤移动距离 *)
    iErrorCode: INT;                     (* 错误代码 *)
	eState: EnumFindState;				(*轴状态*)	
    //sErrorMessage: STRING(255);          (* 错误信息 *)
END_STRUCT
END_TYPE
{IMPLEMENTATION}
