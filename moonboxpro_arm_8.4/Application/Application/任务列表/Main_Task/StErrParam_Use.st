(*@CES
Name=StErrParam_Use
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=58394340-2af0-469d-907b-43e2b620f20c
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StErrParam_Use :(*这个是最终计算调整量需要的所有误差相关内容*)
STRUCT
	iErr_V: INT;(*纵向误差*)
	iErr_H: INT;(*横向误差*)
	iErr_V_Unprocessed	: INT;(*纵向误差-原始误差*)
	iErr_H_Unprocessed	: INT;(*横向误差-原始误差*)
	byIDX_V: BYTE;(*纵向索引*)
	byIDX_H: BYTE;(*横向索引*)
	byErrSts: BYTE;(*误差状态*)
	uiFSampleCounter:UINT;(*精采样数据计数*)
	iVerror_FollowPreUnit:INT;(*纵向跟踪前一色误差*)
	iVerror_Follow1Unit:INT;(*纵向跟踪第一色误差*)
	iHerror_FollowPreUnit :INT 	; (*横向跟前一色误差*)
	iHerror_Follow1Unit :INT 	;(*横向跟1色误差*)	
	(*2025.9.16.094302*)
	iResult_VFollowpre_1stDerivate	: INT;(*YZJ计算误差*)
	//2025.11.13.105908||上传基线和峰值
	uiPeakValue_t1				: UINT;
	uiPeakValue_t2				: UINT;
	uiBaseUse_t1				: UINT;
	uiBaseUse_t2				: UINT;
	//2026.4.11.153149+2026.5.9.110438
	iErr_V_Display	: INT;(*纵向误差-显示平均处理*)
	iErr_H_Display	: INT;(*横向误差-原始误差*)		

//2026.5.12.202228	
	(*2026.5.10.150407/han.dp*)
	uiV_cam_raw: UINT;(*相机纵向原始误差*)
	iV_cam_pure: INT;(*相机纵向纯误差*)
	uiH_cam_raw: UINT;(*相机横向原始误差*)
	iH_cam_pure: INT;(*相机横向纯误差*)
	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
