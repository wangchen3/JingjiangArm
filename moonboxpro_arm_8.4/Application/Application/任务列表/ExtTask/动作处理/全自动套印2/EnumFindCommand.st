(*@CES
Name=EnumFindCommand
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=4d4922df-cbf7-48ea-9894-b69efa7c7e4f
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
// {attribute 'qualified_only'}
// {attribute 'strict'}
TYPE EnumFindCommand :
(
    FIND_CMD_IDLE := 0,                    (* 空闲 *)
    FIND_CMD_START_SINGLE,                 (* 开始单色寻找 *)
    FIND_CMD_START_MIX,                    (* 开始混色寻找 *)
    FIND_CMD_RESET                         (* 重置 *)
);
END_TYPE
{IMPLEMENTATION}
