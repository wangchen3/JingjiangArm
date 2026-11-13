(*@CES
Name=StDeCoupleCoeff
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=6e3db28e-6336-4f2e-a345-1cb80725834e
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StDeCoupleCoeff :(*解耦系数*)
STRUCT
	(*2024.9.10.132125+*)
	arCoeffU2:ARRAY [3..16] OF REAL;(*2色解耦系数@索引代表目标对象.eg [5]=2色的输出量对于5色的解耦系数*)
	arCoeffU3:ARRAY [4..16] OF REAL;(*4色解耦系数*)
	arCoeffU4:ARRAY [5..16] OF REAL;(*4色解耦系数*)
	arCoeffU5:ARRAY [6..16] OF REAL;(*5色解耦系数*)
	arCoeffU6:ARRAY [7..16] OF REAL;(*6色解耦系数*)
	arCoeffU7:ARRAY [8..16] OF REAL;(*7色解耦系数*)
	arCoeffU8:ARRAY [9..16] OF REAL;(*8色解耦系数*)
	arCoeffU9:ARRAY [10..16] OF REAL;(*9色解耦系数*)
	arCoeffU10:ARRAY [11..16] OF REAL;(*10色解耦系数*)
	arCoeffU11:ARRAY [12..16] OF REAL;(*11色解耦系数*)
	arCoeffU12:ARRAY [13..16] OF REAL;(*12色解耦系数*)
	arCoeffU13:ARRAY [14..16] OF REAL;(*13色解耦系数*)
	arCoeffU14:ARRAY [15..16] OF REAL;(*14色解耦系数*)
END_STRUCT
END_TYPE
{IMPLEMENTATION}
