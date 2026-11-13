(*@CES
Name=Cached_Array_Pointers
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=43bd4314-ec4c-41de-8fe2-1da090fdbc31
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE Cached_Array_Pointers :
STRUCT
	(*PI控制器*)
		arUk_PI:ARRAY [1..2] OF REAL;(*输入寄存器*)
		arYk_PI: ARRAY [1..2] OF REAL;(*输出寄存器*)
	(*Kalman*)
	(*上一拍的状态误差协方差矩阵Ph和状态矩阵Xh*)
		arPh:ARRAY [1..4,1..4] OF REAL;(*上一个周期的先验状态误差协方差矩阵*)
		arXh: ARRAY [1..4] OF REAL;(*上一个周期估计状态向量Xh指针*)
	(*LQR迭代求解DARE*)
		arX_DARE:ARRAY [1..4,1..4] OF REAL;(*上一个周期已经迭代收敛的值X_Dare*)

	(*LQR最大迭代次数*)
		iMaxIterateCnt_LQR:INT;

	(*MinBeat最大迭代次数*)
		iMaxIterateCnt_MinBeat:INT;

	(*2024.06.08.150458+lreal类型*)
	(*上一拍的状态误差协方差矩阵Ph和状态矩阵Xh*)
		alrPh:ARRAY [1..4,1..4] OF LREAL;(*上一个周期的先验状态误差协方差矩阵*)
		alrXh: ARRAY [1..4] OF LREAL;(*上一个周期估计状态向量Xh指针*)
	(*LQR迭代求解DARE*)
		alrX_DARE:ARRAY [1..4,1..4] OF LREAL;(*上一个周期已经迭代收敛的值X_Dare*)	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
