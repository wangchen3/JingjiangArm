(*@CES
Name=KS_GenTimeString
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=deb9626e-0703-4969-b954-92f6cc3bdf0c
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GenTimeString : STRING
(* 输出格式yyyymmddHHMMSS[uuu]
输出yyyymmdd的dword/最大到99991231/(dword范围0~4294967295)
输出HHMMSS[uuu]的dword/最大到235959999
description:
当i_pdwDATA和i_pdwTIME都输入0时/则返回可阅读方式的字符串格式[YYYY-mm-dd HH:MM:SS.mmm]
returns:
如果SysTimeRtc.library接口调用失败会有两个特别的时间返回/以标识错误类别/分别是:'1999-12-31 23:59:59.999'和'2999-01-01 00:00:00.999';
*)
VAR_INPUT
	i_pdwDATE: POINTER TO DWORD;(* 返回日期YYYYmmdd的dword形式 *)
	i_pdwTIME: POINTER TO DWORD;(* 返回HHMMSSmmm的dword形式 *)
	i_piErrCode: POINTER TO INT;(* 错误代码/-1.SysTimeRtcHighResGet() failed/-2.SysTimeRtcConvertHighResToLocal() failed/-3. string length not equal 17 *)
END_VAR
VAR
	sResult: STRING := '';
	udiRtn: RTS_IEC_RESULT;
	stSYSTIME: SYSTIME;
	stRTS_SYSTIMEDATE: RTS_SYSTIMEDATE;
END_VAR
{IMPLEMENTATION}
IF SysTimeRtcHighResGet(stSYSTIME)=0 THEN(* 获得当前高精度UTC时间戳 *)
	IF SysTimeRtcConvertHighResToLocal(stSYSTIME, stRTS_SYSTIMEDATE)=0 THEN
		IF i_pdwDATE<>0 OR i_pdwTIME<>0 THEN(* 需要拿到日期和时间的dword类型 *)
			sResult:= CONCAT(sResult, KS_FixedWidthStr(WORD_TO_STRING(stRTS_SYSTIMEDATE.wYear), 4));
			sResult:= CONCAT(sResult, KS_FixedWidthStr(WORD_TO_STRING(stRTS_SYSTIMEDATE.wMonth), 2));
			sResult:= CONCAT(sResult, KS_FixedWidthStr(WORD_TO_STRING(stRTS_SYSTIMEDATE.wDay), 2));
			sResult:= CONCAT(sResult, KS_FixedWidthStr(WORD_TO_STRING(stRTS_SYSTIMEDATE.wHour), 2));
			sResult:= CONCAT(sResult, KS_FixedWidthStr(WORD_TO_STRING(stRTS_SYSTIMEDATE.wMinute), 2));
			sResult:= CONCAT(sResult, KS_FixedWidthStr(WORD_TO_STRING(stRTS_SYSTIMEDATE.wSecond), 2));
			sResult:= CONCAT(sResult, KS_FixedWidthStr(WORD_TO_STRING(stRTS_SYSTIMEDATE.wMilliseconds), 3));
			IF LEN(sResult)<>17 THEN(* 长度不满足要求 *)
				IF i_piErrCode<>0 THEN i_piErrCode^:= -3; END_IF
			ELSE(* 获取date和time的dword类型值 *)
				IF i_pdwDATE<>0 THEN i_pdwDATE^:= STRING_TO_DWORD(LEFT(sResult, 8)); END_IF
				IF i_pdwTIME<>0 THEN i_pdwTIME^:= STRING_TO_DWORD(RIGHT(sResult, 9)); END_IF
			END_IF
		ELSE(* 期望拿到可阅读的时间/YYYY-mm-dd HH:MM:SS.mmm格式 *)
			sResult:= CONCAT(sResult, KS_FixedWidthStr(WORD_TO_STRING(stRTS_SYSTIMEDATE.wYear), 4));
			sResult:= CONCAT(sResult, '-');
			sResult:= CONCAT(sResult, KS_FixedWidthStr(WORD_TO_STRING(stRTS_SYSTIMEDATE.wMonth), 2));
			sResult:= CONCAT(sResult, '-');
			sResult:= CONCAT(sResult, KS_FixedWidthStr(WORD_TO_STRING(stRTS_SYSTIMEDATE.wDay), 2));
			sResult:= CONCAT(sResult, ' ');
			sResult:= CONCAT(sResult, KS_FixedWidthStr(WORD_TO_STRING(stRTS_SYSTIMEDATE.wHour), 2));
			sResult:= CONCAT(sResult, ':');
			sResult:= CONCAT(sResult, KS_FixedWidthStr(WORD_TO_STRING(stRTS_SYSTIMEDATE.wMinute), 2));
			sResult:= CONCAT(sResult, ':');
			sResult:= CONCAT(sResult, KS_FixedWidthStr(WORD_TO_STRING(stRTS_SYSTIMEDATE.wSecond), 2));
			sResult:= CONCAT(sResult, '.');
			sResult:= CONCAT(sResult, KS_FixedWidthStr(WORD_TO_STRING(stRTS_SYSTIMEDATE.wMilliseconds), 3));
		END_IF
	ELSE(* SysTimeRtcConvertHighResToLocal() faield *)
		IF i_pdwDATE<>0 OR i_pdwTIME<>0 THEN
			sResult:= '29990101000000999';
		ELSE
			sResult:= '2999-01-01 00:00:00.999';
		END_IF
	END_IF
ELSE(* SysTimeRtcHighResGet() failed *)
	IF i_pdwDATE<>0 OR i_pdwTIME<>0 THEN
		sResult:= '19991231235959999';
	ELSE
		sResult:= '1999-12-31 23:59:59.999';
	END_IF
END_IF
KS_GenTimeString:= sResult;