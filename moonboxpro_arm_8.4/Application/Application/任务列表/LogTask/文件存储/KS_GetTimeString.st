(*@CES
Name=KS_GetTimeString
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=2915fd67-d492-46c1-83ff-21d786551c5b
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetTimeString : STRING
VAR_INPUT
	i_iTimeFmtId: INT := TIMEFORMAT_NO_HYPHEN;
	i_xInclHMSU: BOOL := FALSE;(* 只有日期/不含具体时间部分 *)
	i_xInclMilliseconds: BOOL := FALSE;(* 包含毫秒部分/前提是i_xIncludeHMSU有效 *)
	i_pdwYMD: POINTER TO DWORD := 0;(* 年月日/最大99991231/保存数据项时如果需要/请传入合法的地址 *)
	i_pdwHMSU: POINTER TO DWORD := 0;(* 时分秒+毫秒/最大235959999/保存数据项时如果需要/请传入合法的地址 *)
END_VAR
VAR
	sResult: STRING;
	sYMD: STRING;
	sHMSU: STRING;
	stTimestamp: SYSTIME;
	stSysTimedate: RTS_SYSTIMEDATE;(* RTS_SYSTIMEDATE *)
	udiRtn: RTS_IEC_RESULT;
	asTimedateItem: ARRAY [1..7] OF STRING(10) := [7('')];
	
//	stSysTimedate_Rec: RTS_SYSTIMEDATE;(* RTS_SYSTIMEDATE *)
	
END_VAR
{IMPLEMENTATION}
udiRtn:= SysTimeRtcHighResGet(stTimestamp);(* 获得当前高精度UTC时间戳 *)
udiRtn:= SysTimeRtcConvertHighResToLocal(stTimestamp, stSysTimedate);
IF NOT g_xInitTime THEN
	g_xInitTime:= TRUE;
	SysMemCpy(ADR(g_stSysTimedate_Rec),ADR(stSysTimedate),SIZEOF(g_stSysTimedate_Rec));
END_IF
(* 年 *)
asTimedateItem[1]:= WORD_TO_STRING(stSysTimedate.wYear);

(* 月 *)
IF stSysTimedate.wMonth<10 THEN
	asTimedateItem[2]:= '0';
	asTimedateItem[2]:= CONCAT(asTimedateItem[2], WORD_TO_STRING(stSysTimedate.wMonth));
ELSE
	asTimedateItem[2]:= WORD_TO_STRING(stSysTimedate.wMonth);
END_IF

(* 日 *)
IF stSysTimedate.wDay<10 THEN
	asTimedateItem[3]:= '0';
	asTimedateItem[3]:= CONCAT(asTimedateItem[3], WORD_TO_STRING(stSysTimedate.wDay));
ELSE
	asTimedateItem[3]:= WORD_TO_STRING(stSysTimedate.wDay);
END_IF

(* 时 *)
IF g_stSysTimedate_Rec.wHour<>stSysTimedate.wHour THEN
	IF (WORD_TO_INT(stSysTimedate.wHour)-WORD_TO_INT(g_stSysTimedate_Rec.wHour)<>1) AND 
		(WORD_TO_INT(stSysTimedate.wHour)-WORD_TO_INT(g_stSysTimedate_Rec.wHour)<>-23) THEN
		stSysTimedate.wHour:=  g_stSysTimedate_Rec.wHour;
	END_IF
END_IF
IF stSysTimedate.wHour<10 THEN
	asTimedateItem[4]:= '0';
	asTimedateItem[4]:= CONCAT(asTimedateItem[4], WORD_TO_STRING(stSysTimedate.wHour));
ELSE
	asTimedateItem[4]:= WORD_TO_STRING(stSysTimedate.wHour);
END_IF

(* 分 *)
IF stSysTimedate.wMinute<10 THEN
	asTimedateItem[5]:= '0';
	asTimedateItem[5]:= CONCAT(asTimedateItem[5], WORD_TO_STRING(stSysTimedate.wMinute));
ELSE
	asTimedateItem[5]:= WORD_TO_STRING(stSysTimedate.wMinute);
END_IF

(* 秒 *)
IF stSysTimedate.wSecond<10 THEN
	asTimedateItem[6]:= '0';
	asTimedateItem[6]:= CONCAT(asTimedateItem[6], WORD_TO_STRING(stSysTimedate.wSecond));
ELSE
	asTimedateItem[6]:= WORD_TO_STRING(stSysTimedate.wSecond);
END_IF

(* 毫秒 *)
IF stSysTimedate.wMilliseconds<10 THEN
	asTimedateItem[7]:= '00';
	asTimedateItem[7]:= CONCAT(asTimedateItem[7], WORD_TO_STRING(stSysTimedate.wMilliseconds));
ELSIF stSysTimedate.wMilliseconds<100 THEN
	asTimedateItem[7]:= '0';
	asTimedateItem[7]:= CONCAT(asTimedateItem[7], WORD_TO_STRING(stSysTimedate.wMilliseconds));
ELSE
	asTimedateItem[7]:= WORD_TO_STRING(stSysTimedate.wMilliseconds);
END_IF

IF i_iTimeFmtId=TIMEFORMAT_NO_HYPHEN THEN(* yyyymmdd[HHMMSS[uuu]] *)
	sResult:= asTimedateItem[1];
	sResult:= CONCAT(sResult, asTimedateItem[2]);
	sResult:= CONCAT(sResult, asTimedateItem[3]);
	IF i_xInclHMSU THEN
		sResult:= CONCAT(sResult, asTimedateItem[4]);
		sResult:= CONCAT(sResult, asTimedateItem[5]);
		sResult:= CONCAT(sResult, asTimedateItem[6]);
		IF i_xInclMilliseconds THEN
			sResult:= CONCAT(sResult, asTimedateItem[7]);
		END_IF
	END_IF
ELSIF i_iTimeFmtId=TIMEFORMAT_HYPHEN_COLON THEN(* yyyy-mm-dd[ HH:MM:SS[.uuu]] *)
	sResult:= asTimedateItem[1];
	sResult:= CONCAT(sResult, '-'); sResult:= CONCAT(sResult, asTimedateItem[2]);
	sResult:= CONCAT(sResult, '-'); sResult:= CONCAT(sResult, asTimedateItem[3]);
	IF i_xInclHMSU THEN
		sResult:= CONCAT(sResult, ' '); sResult:= CONCAT(sResult, asTimedateItem[4]);
		sResult:= CONCAT(sResult, ':'); sResult:= CONCAT(sResult, asTimedateItem[5]);
		sResult:= CONCAT(sResult, ':'); sResult:= CONCAT(sResult, asTimedateItem[6]);
		IF i_xInclMilliseconds THEN
			sResult:= CONCAT(sResult, '.'); sResult:= CONCAT(sResult, asTimedateItem[7]);
		END_IF
	END_IF
ELSIF i_iTimeFmtId=TIMEFORMAT_MMDD THEN(* mmdd *)
	sResult:= asTimedateItem[2];
	sResult:= CONCAT(sResult, asTimedateItem[3]);
ELSIF i_iTimeFmtId=TIMEFORMAT_MMDDHH THEN(* mmddHH *)
	sResult:= asTimedateItem[2];
	sResult:= CONCAT(sResult, asTimedateItem[3]);
	sResult:= CONCAT(sResult, asTimedateItem[4]);
ELSE(* include [i_iTimeFmtId=TIMEFORMAT_HYPHEN_DOT](* yyyy.mm.dd[.HHMMSS[_uuu]] *) *)
	sResult:= asTimedateItem[1];
	sResult:= CONCAT(sResult, '.'); sResult:= CONCAT(sResult, asTimedateItem[2]);
	sResult:= CONCAT(sResult, '.'); sResult:= CONCAT(sResult, asTimedateItem[3]);
	IF i_xInclHMSU THEN
		sResult:= CONCAT(sResult, '.'); sResult:= CONCAT(sResult, asTimedateItem[4]);
		sResult:= CONCAT(sResult, asTimedateItem[5]);
		sResult:= CONCAT(sResult, asTimedateItem[6]);
		IF i_xInclMilliseconds THEN
			sResult:= CONCAT(sResult, '_');
			sResult:= CONCAT(sResult, asTimedateItem[7]);
		END_IF
	END_IF
END_IF
IF i_pdwYMD<>0 THEN(* 年月日 *)
	sYMD:= asTimedateItem[1];
	sYMD:= CONCAT(sYMD, asTimedateItem[2]);
	sYMD:= CONCAT(sYMD, asTimedateItem[3]);
	i_pdwYMD^:= STRING_TO_DWORD(sYMD);
END_IF
IF i_pdwHMSU<>0 THEN(* 时分秒+毫秒 *)
	sHMSU:= asTimedateItem[4];
	sHMSU:= CONCAT(sHMSU, asTimedateItem[5]);
	sHMSU:= CONCAT(sHMSU, asTimedateItem[6]);
	sHMSU:= CONCAT(sHMSU, asTimedateItem[7]);
	i_pdwHMSU^:= STRING_TO_DWORD(sHMSU);
END_IF
SysMemCpy(ADR(g_stSysTimedate_Rec),ADR(stSysTimedate),SIZEOF(g_stSysTimedate_Rec));

KS_GetTimeString:= sResult;