(*@CES
Name=KS_PushErrDataToListHead
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=c74a8f5a-6a41-4eb7-93e5-be98c4af3798
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_PushErrDataToListHead : BOOL(* 将误差数据放到最开始的位置 *)
VAR_INPUT
	i_pastStForArcErrRelay: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StForArcErrRelay; (* 误差队列 *)
	i_iAxisId: INT; (* 轴id *)
	i_iErrData: INT; (* 误差数据 *)
END_VAR
VAR
	iN: INT;
	xResult: BOOL;
	iTotalItems: INT;
	pstStForArcErrRelay: POINTER TO StForArcErrRelay;
END_VAR
{IMPLEMENTATION}
xResult:= FALSE;
IF i_pastStForArcErrRelay<>0 AND
	i_iAxisId>=1 AND i_iAxisId<=MAX_UNIT_NUM THEN
	pstStForArcErrRelay:= ADR(i_pastStForArcErrRelay^[i_iAxisId]);
	iTotalItems:= DWORD_TO_INT(SIZEOF(pstStForArcErrRelay^.aiErrDataList)/SIZEOF(pstStForArcErrRelay^.aiErrDataList[1])); (* 算出数组的元素最大数量 *)
	FOR iN:=iTotalItems TO 2 BY -1 DO (* 把[1]的位置空出来/用来放i_iErrData *)
		pstStForArcErrRelay^.aiErrDataList[iN]:= pstStForArcErrRelay^.aiErrDataList[iN-1];
	END_FOR

	 (*  2018.8.17.153837/数据写入 *)
	CASE i_iErrData OF
	gc_iValueReferToLost,gc_iValueReferToFakePoint,gc_iValueReferToSkipTheHeader: (* 放前一次的误差进来 *)
		pstStForArcErrRelay^.aiErrDataList[1]:= pstStForArcErrRelay^.aiErrDataList[2];
	ELSE
		pstStForArcErrRelay^.aiErrDataList[1]:= i_iErrData; (* 将最新的误差放进来 *)
	END_CASE

	xResult:= TRUE;
END_IF
KS_PushErrDataToListHead:= xResult;