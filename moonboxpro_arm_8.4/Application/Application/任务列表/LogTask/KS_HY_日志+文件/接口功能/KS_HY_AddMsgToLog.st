(*@CES
Name=KS_HY_AddMsgToLog
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=bcb6c59b-ebd6-4321-878d-202e813fcffa
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_HY_AddMsgToLog : INT
(* 2025.8.23.115118
/ 添加消息到日志fifo中
*)
VAR_INPUT
	i_pstStHYLogFifo: POINTER TO StHYLogFifo;(* 日志FIFO *)
	i_iLogLevel: INT;(* 日志等级 *)
	i_sMsgContent: STRING;(* 内容部分 *)
	i_sMsgNote: STRING;(* 注解部分 *)
END_VAR
VAR
	iResult: INT;
	byIdxW_tmp: BYTE;
	pstStHYLogItem_tmp: POINTER TO StHYLogItem;
END_VAR

{IMPLEMENTATION}
iResult:= 0;
IF i_pstStHYLogFifo<>0 THEN
	(* 参数有效 *)

	(* 获取时间戳字串[YYYY/MM/DD hh:mm:ss.mmm] *)
	(* 日志内容格式:
	/ 2025/08/23 17:01:00.123[A]E-Stop Pressed.(9)
	*)
	byIdxW_tmp:= i_pstStHYLogFifo^.byIdxW;
	pstStHYLogItem_tmp:= ADR(i_pstStHYLogFifo^.astStHYLogItem[byIdxW_tmp]);
	pstStHYLogItem_tmp^.sDetails:= KS_HY_GetTimeString();

	(* 日志等级 *)
	pstStHYLogItem_tmp^.sDetails:= CONCAT(pstStHYLogItem_tmp^.sDetails, '[');
	IF i_iLogLevel=LOG_LEVEL_INFO THEN(* 一版消息 *)
		pstStHYLogItem_tmp^.sDetails:= CONCAT(pstStHYLogItem_tmp^.sDetails, 'I');
	ELSIF i_iLogLevel=LOG_LEVEL_DEBUG THEN(* 调试消息 *)
		pstStHYLogItem_tmp^.sDetails:= CONCAT(pstStHYLogItem_tmp^.sDetails, 'D');
	ELSIF i_iLogLevel=LOG_LEVEL_ALARM THEN(* 报警消息 *)
		pstStHYLogItem_tmp^.sDetails:= CONCAT(pstStHYLogItem_tmp^.sDetails, 'A');
	ELSIF i_iLogLevel=LOG_LEVEL_ERROR THEN(* 错误消息 *)
		pstStHYLogItem_tmp^.sDetails:= CONCAT(pstStHYLogItem_tmp^.sDetails, 'E');
	ELSIF i_iLogLevel=LOG_LEVEL_FATAL THEN(* 严重消息 *)
		pstStHYLogItem_tmp^.sDetails:= CONCAT(pstStHYLogItem_tmp^.sDetails, 'F');
	ELSE(* 未知消息 *)
		pstStHYLogItem_tmp^.sDetails:= CONCAT(pstStHYLogItem_tmp^.sDetails, '?');
	END_IF
	pstStHYLogItem_tmp^.sDetails:= CONCAT(pstStHYLogItem_tmp^.sDetails, ']');

	(* 日志正文 *)
	IF LEN(i_sMsgContent)>0 THEN
		pstStHYLogItem_tmp^.sDetails:= CONCAT(pstStHYLogItem_tmp^.sDetails, i_sMsgContent);
	END_IF

	(* 注解部分如果无信息/则整段不添加 *)
	IF LEN(i_sMsgNote)>0 THEN
		pstStHYLogItem_tmp^.sDetails:= CONCAT(pstStHYLogItem_tmp^.sDetails, '(');
		pstStHYLogItem_tmp^.sDetails:= CONCAT(pstStHYLogItem_tmp^.sDetails, i_sMsgNote);
		pstStHYLogItem_tmp^.sDetails:= CONCAT(pstStHYLogItem_tmp^.sDetails, ')');
	END_IF

	(* 下次写入的位置/由于接口支持多个任务调用
	/ 尽量不要直接操作i_pstStHYLogFifo内的数组索引
	*)
	byIdxW_tmp:= byIdxW_tmp+1;
	i_pstStHYLogFifo^.byIdxW:= byIdxW_tmp;
ELSE
	(* 参数无效 *)

	iResult:= -1;
END_IF

KS_HY_AddMsgToLog:= iResult;
