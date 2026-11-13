(*@CES
Name=KS_FB_GetLatchValue
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=ed2f2b11-af18-4922-a052-26b8330b7fb0
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GetLatchValue
VAR_INPUT
	i_xEn : BOOL;
	i_iGrpUnitNum: INT;
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStLatch : POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StLatch;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	iN : INT;
	iM : INT;
	iRtn : INT;
	audiTempData : ARRAY [1..MAX_UNIT_NUM] OF UDINT;
END_VAR

{IMPLEMENTATION}

IF i_xEn THEN
	IF i_pstStSysParam <> 0 AND i_pastStLatch <> 0 THEN
		FOR iN := 1 TO i_iGrpUnitNum BY 1 DO
			iRtn := GTN_GetMailbox(
				core:= 1, 
				station:= 0, 
				byteAddress:= 16#C412, //锁存时间32位数据（低24位锁存时间，高8位di触发次数），单位us,:低16位网络地址0xc412,高16位网络地址0xc414
				pData:= ADR(audiTempData[iN]), 
				wordCount:= 2, 
				dataMode:= 1, 
				desId:=iN, 
				typeVar:= 1);
				
			i_pastStLatch^[iN].iTriggerCnt := UDINT_TO_INT(SHR(audiTempData[iN],24));
			i_pastStLatch^[iN].udiTriggerTimeErr := SHR(SHL(audiTempData[iN],16#8),16#8);
				
			iRtn := GTN_GetMailbox(
				core:= 1, 
				station:= 0, 
				byteAddress:= 16#C454, //锁存编码器32位数据，一个版周最大脉冲值131072，低16位网络地址0xc454，高16位网络地址0xc456
				pData:= ADR(i_pastStLatch^[iN].udiTriggerEncErr), 
				wordCount:= 2, 
				dataMode:= 1, 
				desId:=iN, 
				typeVar:= 1);
		END_FOR
	END_IF
ELSE
	;
END_IF
 

