(*@CES
Name=KS_GetStationInf
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=b7f0280a-edd9-42bd-a20b-0c2dea9f3ec3
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetStationInf : BOOL
(*获取站的信息*)
VAR_INPUT
	i_iStationId			: INT;
	i_pstStationInf			: POINTER TO StStationInf;
	i_pstStSysStationInf	: POINTER TO StSysStationInf;
END_VAR
VAR
	iN: INT;
	pstStationInf				: POINTER TO StStationInf;
	xFindIt: BOOL;
END_VAR

{IMPLEMENTATION}
KS_InitStationInf(i_pstStationInf);
IF i_iStationId>0 AND i_iStationId<=255 THEN
	FOR iN:=1 TO i_pstStSysStationInf^.byStationNum BY 1 DO
		pstStationInf:=ADR(i_pstStSysStationInf^.astStationInf[iN]);
		IF pstStationInf^.xValid THEN(*信息有效了*)
			IF pstStationInf^.iStationId = i_iStationId THEN
				xFindIt:=TRUE;
				EXIT;
			END_IF
		END_IF
	END_FOR

	(*结构体初始化*)
	IF xFindIt THEN
		i_pstStationInf^:=pstStationInf^;
	END_IF
END_IF
KS_GetStationInf:=xFindIt;