(*@CES
Name=ENUM_MarkType
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=321db1e3-f3d5-4ccd-ba69-c64547f2641d
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE ENUM_MarkType :
(
	MARK_TYPE_LINE			:= 1, (* Line Mark *)
	MARK_TYPE_TRAPE_VFLP	:= 2, (* Vert Forward Left Positive *)
	MARK_TYPE_TRAPE_VFLN	:= 3, (* Vert Forward Left Negitive *)
	MARK_TYPE_TRAPE_VBLP	:= 4, (* Vert Backward Left Positive *)
	MARK_TPYE_TRAPE_VBLN	:= 5, (* Vert Backward Left Negitive *)
	MARK_TYPE_TRIANGLE_R	:= 6, (* 2018.8.28.135823\三角标-定点在右边 *)
	MARK_TYPE_TRIANGLE_L	:= 7  (* 2018.8.28.135828\三角标-定点在左边 *)
);
END_TYPE

{IMPLEMENTATION}
