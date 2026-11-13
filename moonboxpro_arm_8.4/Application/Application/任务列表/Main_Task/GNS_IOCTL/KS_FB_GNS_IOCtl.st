(*@CES
Name=KS_FB_GNS_IOCtl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=781c10e6-f7cc-4f5a-850b-3bc704dbe54f
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GNS_IOCtl
VAR_INPUT
	i_xEn: BOOL;
	i_xUseIO_FromGNS_Enable: BOOL;//使能控制
	i_xRdEn: BOOL;
	i_xWrEn: BOOL;
	//X0:P6端口-16位||X1:P8端口-16位||X2:P4端口-8位||X3:P3端口-8位
	i_padiGNSIO_Input: POINTER TO ARRAY [1..2] OF DINT;//X0是bit0-bit15||X1是bit16-bit31||X2是数组2bit0-bit7||X3是数组2bit8-bit15
	//Y0:P5端口-16位||Y1:P7端口-16位
	i_pdiGNSIO_Output: POINTER TO DINT;//Y0是bit0-bit15||Y1是bit16-bit31
	
END_VAR
VAR_OUTPUT
	o_xEn: BOOL;
	o_iErNo: INT;
END_VAR
VAR
	adiTemp: ARRAY [1..2] OF DINT;
	iRtn_Rd: INT;
	iRtn_Wr: INT;
	
END_VAR

{IMPLEMENTATION}
o_xEn:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	IF i_padiGNSIO_Input<>0 AND i_pdiGNSIO_Output<>0 THEN
		IF i_xUseIO_FromGNS_Enable THEN
			IF i_xRdEn THEN//获取输入
				iRtn_Rd:= GTN_GetDIEx(
					1,			//core
					MC_GPI,		//diType
					ADR(adiTemp),//pValue
					2
					);
				IF iRtn_Rd=0 THEN
					i_padiGNSIO_Input^[1]:= adiTemp[1];
					i_padiGNSIO_Input^[2]:= adiTemp[2];
				ELSE
					o_iErNo:= -1;
				END_IF
			END_IF
			IF i_xWrEn THEN//处理输出
				iRtn_Wr:= GTN_SetDo(
					1,
					MC_GPO,
					i_pdiGNSIO_Output^				
					);
				IF iRtn_Wr<>0 THEN
					o_iErNo:= -2;
				ELSE;
				END_IF	
			END_IF
		ELSE
			o_iErNo:= -3;	
		END_IF
	ELSE
		o_iErNo:= -4;
	END_IF
ELSE
	o_iErNo:= -5;
END_IF
