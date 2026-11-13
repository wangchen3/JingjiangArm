(*@CES
Name=KS_HY_GetTimeString
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=6552801a-dd25-4c90-9866-0e8db1fb41da
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_HY_GetTimeString : STRING
VAR_INPUT
END_VAR
VAR
	sFinal: STRING;
	udiResult: RTS_IEC_RESULT;
	stUTC_Timestamp: SysTime;
	stdNow: SysTimeDate;
	s_year: STRING;
	s_month: STRING;
	s_day: STRING;
	s_hour: STRING;
	s_minute: STRING;
	s_second: STRING;
	s_milliseconds: STRING;
(* 保留效率测试的部分痕迹
	stUTC_Timestamp_2: SysTime;
	ulElapsed: ULINT;
*)
END_VAR

{IMPLEMENTATION}
(* 获取时间戳字串 *)
udiResult:= SysTimeRtcHighResGet(stUTC_Timestamp);
udiResult:= SysTimeRtcConvertHighResToLocal(stUTC_Timestamp, stdNow);

s_year:=
KS_HY_UINT_TO_STRING(stdNow.wYear, 4);

s_month:=
KS_HY_UINT_TO_STRING(stdNow.wMonth, 2);

s_day:=
KS_HY_UINT_TO_STRING(stdNow.wDay, 2);

s_hour:=
KS_HY_UINT_TO_STRING(stdNow.wHour, 2);

s_minute:=
KS_HY_UINT_TO_STRING(stdNow.wMinute, 2);

s_second:=
KS_HY_UINT_TO_STRING(stdNow.wSecond, 2);

s_milliseconds:=
KS_HY_UINT_TO_STRING(stdNow.wMilliseconds, 3);

sFinal:= s_year;
sFinal:= CONCAT(sFinal, '/');
sFinal:= CONCAT(sFinal, s_month);
sFinal:= CONCAT(sFinal, '/');
sFinal:= CONCAT(sFinal, s_day);
sFinal:= CONCAT(sFinal, ' ');
sFinal:= CONCAT(sFinal, s_hour);
sFinal:= CONCAT(sFinal, ':');
sFinal:= CONCAT(sFinal, s_minute);
sFinal:= CONCAT(sFinal, ':');
sFinal:= CONCAT(sFinal, s_second);
sFinal:= CONCAT(sFinal, '.');
sFinal:= CONCAT(sFinal, s_milliseconds);

(*实测字符串操作耗时远远小于1ms
Result:= SysTimeRtcHighResGet(stUTC_Timestamp_2);
ulElapsed:= stUTC_Timestamp_2-stUTC_Timestamp;
*)

KS_HY_GetTimeString:= sFinal;
