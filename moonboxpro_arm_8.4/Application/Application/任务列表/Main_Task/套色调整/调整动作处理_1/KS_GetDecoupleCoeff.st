(*@CES
Name=KS_GetDecoupleCoeff
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=852d1de3-7a28-44a3-92e4-8f2f04e4393a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetDecoupleCoeff : REAL
(*只处理到了14色对后色的解耦系数实现*)
(*获取失败就等于1*)
VAR_INPUT
	i_iArcAxisId_Src:INT;(*源@eg:=3|代表3色输出的解耦量*)
	i_iArcAxisId_Des:INT;(*目标@eg:=5|代表对于5色的作用*)
	i_pstStDeCoupleCoeff:POINTER TO StDeCoupleCoeff;(*系数内容*)
END_VAR
VAR
	xGetFailed: BOOL;
	rResult: REAL;
	arTmp: ARRAY [1..16] OF REAL;
	iLen: INT;
	iN: INT;
	iIndexSa: INT;
	iArcAxisId_Des: INT;
END_VAR
{IMPLEMENTATION}
xGetFailed:=FALSE;
IF i_iArcAxisId_Src<i_iArcAxisId_Des AND
	i_iArcAxisId_Src >=2 AND i_iArcAxisId_Src<=14 AND
	i_iArcAxisId_Des >=3 AND i_iArcAxisId_Des<=16 AND
	i_pstStDeCoupleCoeff<>0  THEN

	iIndexSa:=i_iArcAxisId_Src+1;
	iArcAxisId_Des:=i_iArcAxisId_Des;
	IF iIndexSa<=15 THEN
		CASE i_iArcAxisId_Src OF
			2:(*2色*)
				SysMemCpy(ADR(arTmp[iIndexSa]),
					ADR(i_pstStDeCoupleCoeff^.arCoeffU2),
					SIZEOF(i_pstStDeCoupleCoeff^.arCoeffU2));
			3:(*3色*)
				SysMemCpy(ADR(arTmp[iIndexSa]),
					ADR(i_pstStDeCoupleCoeff^.arCoeffU3),
					SIZEOF(i_pstStDeCoupleCoeff^.arCoeffU3));
			4:(*4色*)
				SysMemCpy(ADR(arTmp[iIndexSa]),
					ADR(i_pstStDeCoupleCoeff^.arCoeffU4),
					SIZEOF(i_pstStDeCoupleCoeff^.arCoeffU4));
			5:(*5色*)
				SysMemCpy(ADR(arTmp[iIndexSa]),
					ADR(i_pstStDeCoupleCoeff^.arCoeffU5),
					SIZEOF(i_pstStDeCoupleCoeff^.arCoeffU5));
			6:(*6色*)
				SysMemCpy(ADR(arTmp[iIndexSa]),
					ADR(i_pstStDeCoupleCoeff^.arCoeffU6),
					SIZEOF(i_pstStDeCoupleCoeff^.arCoeffU6));
			7:(*7色*)
				SysMemCpy(ADR(arTmp[iIndexSa]),
					ADR(i_pstStDeCoupleCoeff^.arCoeffU7),
					SIZEOF(i_pstStDeCoupleCoeff^.arCoeffU7));
			8:(*8色*)
				SysMemCpy(ADR(arTmp[iIndexSa]),
					ADR(i_pstStDeCoupleCoeff^.arCoeffU8),
					SIZEOF(i_pstStDeCoupleCoeff^.arCoeffU8));
			9:(*9色*)
				SysMemCpy(ADR(arTmp[iIndexSa]),
					ADR(i_pstStDeCoupleCoeff^.arCoeffU9),
					SIZEOF(i_pstStDeCoupleCoeff^.arCoeffU9));
			10:(*10色*)
				SysMemCpy(ADR(arTmp[iIndexSa]),
					ADR(i_pstStDeCoupleCoeff^.arCoeffU10),
					SIZEOF(i_pstStDeCoupleCoeff^.arCoeffU10));
			11:(*11色*)
				SysMemCpy(ADR(arTmp[iIndexSa]),
					ADR(i_pstStDeCoupleCoeff^.arCoeffU11),
					SIZEOF(i_pstStDeCoupleCoeff^.arCoeffU11));
			12:(*12色*)
				SysMemCpy(ADR(arTmp[iIndexSa]),
					ADR(i_pstStDeCoupleCoeff^.arCoeffU12),
					SIZEOF(i_pstStDeCoupleCoeff^.arCoeffU12));
			13:(*13色*)
				SysMemCpy(ADR(arTmp[iIndexSa]),
					ADR(i_pstStDeCoupleCoeff^.arCoeffU13),
					SIZEOF(i_pstStDeCoupleCoeff^.arCoeffU13));
			14:(*14色*)
				SysMemCpy(ADR(arTmp[iIndexSa]),
					ADR(i_pstStDeCoupleCoeff^.arCoeffU14),
					SIZEOF(i_pstStDeCoupleCoeff^.arCoeffU14));
		ELSE;
		END_CASE

		IF iArcAxisId_Des>=iIndexSa THEN
			xGetFailed:=TRUE;
			rResult:=arTmp[iArcAxisId_Des];
		END_IF
	END_IF

ELSE(*参数有误*);
END_IF
IF NOT xGetFailed THEN
	rResult:=1;
END_IF
KS_GetDecoupleCoeff:=rResult;
(*
IF i_prResult<>0 THEN
	i_prResult^:=rResult;
END_IF
*)