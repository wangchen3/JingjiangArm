(*@CES
Name=KS_FetchNextSampleDataPtr
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=600b6e6a-0af7-4a30-ab9c-796b863be3cd
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_FetchNextSampleDataPtr : BOOL
VAR_INPUT
	i_pstStSampleDataForTest: POINTER TO StSampleDataForTest;
	i_ppbyRS_T1: POINTER TO POINTER TO BYTE;(* 粗采样T1数据起点 *)
	i_ppbyRS_T2: POINTER TO POINTER TO BYTE;(* 粗采样T2数据起点 *)
	i_ppbyFS_T1: POINTER TO POINTER TO BYTE;(* 精采样T1数据起点 *)
	i_ppbyFS_T2: POINTER TO POINTER TO BYTE;(* 精采样T2数据起点 *)
END_VAR
VAR
	xResult: BOOL;
	byIDX_Tmp: BYTE;
END_VAR
{IMPLEMENTATION}
IF i_pstStSampleDataForTest<>0 AND
	i_ppbyRS_T1<>0 AND
	i_ppbyRS_T2<>0 AND
	i_ppbyFS_T1<>0 AND
	i_ppbyFS_T2<>0 THEN

	xResult:= TRUE;

	(* 将当前数据位置反馈到出口参数 *)
	byIDX_Tmp:= i_pstStSampleDataForTest^.byIdx AND 7;(* 只取低3位 *)

	(* 粗采样 *)
	i_ppbyRS_T1^:= ADR(i_pstStSampleDataForTest^.abyBuf_Rs[byIDX_Tmp,   1]);
	i_ppbyRS_T2^:= ADR(i_pstStSampleDataForTest^.abyBuf_Rs[byIDX_Tmp,4001]);

	(* 精采样 *)
	i_ppbyFS_T1^:= ADR(i_pstStSampleDataForTest^.abyBuf_Fs[byIDX_Tmp,   1]);
	i_ppbyFS_T2^:= ADR(i_pstStSampleDataForTest^.abyBuf_Fs[byIDX_Tmp,4001]);

	(* go next *)
	i_pstStSampleDataForTest^.byIdx:= i_pstStSampleDataForTest^.byIdx+1;
ELSE
	xResult:= FALSE;
END_IF
KS_FetchNextSampleDataPtr:= xResult;