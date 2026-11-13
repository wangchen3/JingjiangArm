(*@CES
Name=StParam_PDU_Up
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=86ab3953-ed0c-4c63-9744-6672adabd60d
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StParam_PDU_Up :
STRUCT
	byPkgId						: BYTE;(*数据包ID*)
	abyPayLoad					: ARRAY [1..45] OF BYTE;(*数据可变区域*)
	wCHK						: WORD;(*校验码*)	
	byIDX_V						: BYTE;(*纵向误差索引*)
	byIDX_H						: BYTE;(* 横向误差索引 *)
	iErr_V_Raw					: INT;(*纵向误差原始值-跟前色*)
	iErr_H_Raw					: INT;(*横向误差原始值-跟前色*)
	iErr_V_Raw_1				: INT;(*纵向误差原始值-跟任意色*)
	iErr_H_Raw_1				: INT;(*横向误差原始值-跟任意色*)
	uiFSampleCounter			: UINT;(*精采样计数*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
