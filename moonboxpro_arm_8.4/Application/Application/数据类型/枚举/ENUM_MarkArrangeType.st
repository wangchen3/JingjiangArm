(*@CES
Name=ENUM_MarkArrangeType
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=1b9c9704-f7e9-4499-af37-1e699b1dbe55
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE ENUM_MarkArrangeType :
(
	MARK_ARRANGE_VFOR		:= 1, (* 纵顺 *)
	MARK_ARRANGE_VREV		:= 2, (* 纵逆 *)
	MARK_ARRANGE_HFOR		:= 3, (* 横顺 *)
	MARK_ARRANGE_HREV		:= 4, (* 横逆 *)
	MARK_ARRANGE_OMK		:= 5  (* 单标记 *)
);
END_TYPE

{IMPLEMENTATION}
