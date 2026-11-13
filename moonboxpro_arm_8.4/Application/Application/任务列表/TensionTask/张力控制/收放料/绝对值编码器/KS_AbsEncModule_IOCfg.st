(*@CES
Name=KS_AbsEncModule_IOCfg
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=61e03de1-f970-45d9-ad75-c0c3bbeef4b8
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_AbsEncModule_IOCfg : BOOL(*数字量模块增加读取绝对值编码器功能后的io部分处理--2021.4.9.133300 只处理编码器部分*)
//2021.1.26.085118
//特殊固件将数字量修改为模拟量模块，用于通过glink1输出口通讯读取绝对值编码器功能。
//在这里针对io输入输出\读取的绝对值进行处理！
//IO位于W0地址、
//绝对值数据：W1-W2保存单圈位置
//			W3保存单圈位置
//			W4(7:0)保存绝对值状态

//2025.08.20.152747 处理输入输出io
VAR_INPUT
	i_xInputEn: BOOL;
	i_xOutPutEn: BOOL;
	i_xGetAbsEnc:BOOL;(*读取绝对值编码器值标志*)
	(*全部罗列，防止输入输出值不刷新|*)
	i_wIW0:WORD;(*输入IW0*)
	(*绝对位置值|*)
	i_wIW1:WORD;(*输入IW1*)
	i_wIW2:WORD;(*输入IW2*)
	i_wIW3:WORD;(*输入IW3*)
	i_wIW4:WORD;(*输入IW4*)
	(*配置输出qw0|通过测试发现在只输出8位以后的io可能由于
	一些模块限制不能正常输出。在这里配置只是为了能够解决这个问题*)
	i_pwQW0:POINTER TO WORD;(*输处QW0*)
	i_pdwAbsSinglePos:POINTER TO DWORD;
	i_pwAbsMultiPos:POINTER TO WORD;
	i_pbyAbsSts:POINTER TO BYTE;
	//2025.08.20.152113+
	i_pstStAbsEncIOModule:POINTER TO StAbsEncIOModule;
END_VAR
VAR
	abyTemp: ARRAY [1..8] OF BYTE;
	pawTemp: POINTER TO ARRAY [1..4] OF WORD;
	pdwTemp: POINTER TO DWORD;
	pwTemp: POINTER TO WORD;
	dwAbsSinglePos: DWORD;(*单圈位置*)
	wAbsMultiPos: WORD;(*多圈位置*)
	byAbsSts: BYTE;(*状态*)
	//2025.08.20.152237+
	wIX:WORD;
	wQX:WORD;
END_VAR
{IMPLEMENTATION}
(*输入使能的时候处理*)
(*绝对值处理*)
IF i_xInputEn THEN//处理输入
	(*输入使能的时候处理*)
	(*绝对值处理*)
	IF i_xGetAbsEnc THEN
		pawTemp:=ADR(abyTemp);
		pawTemp^[1]:=i_wIW1;
		pawTemp^[2]:=i_wIW2;
		pawTemp^[3]:=i_wIW3;
		pawTemp^[4]:=i_wIW4;
	
		pdwTemp:=ADR(abyTemp);
		(*单圈值|取前1--4字节*)
		dwAbsSinglePos:=pdwTemp^ ;
		(*多圈值|取5-6字节*)
		pwTemp:=ADR(abyTemp[5]);
		wAbsMultiPos:=pwTemp^;
		(*状态值|7字节*)
		byAbsSts:=abyTemp[7];
	END_IF
	
	wIX := i_wIW0;
	//获取输入@2025.08.20.152455
	IF i_pstStAbsEncIOModule<>0 THEN
		i_pstStAbsEncIOModule^.wIX:=wIX;
	END_IF
		
	IF i_pdwAbsSinglePos<>0 THEN
		i_pdwAbsSinglePos^:=dwAbsSinglePos;
	END_IF
	IF i_pwAbsMultiPos<>0 THEN
		i_pwAbsMultiPos^:=wAbsMultiPos;
	END_IF
	IF i_pbyAbsSts<>0 THEN
		i_pbyAbsSts^:=byAbsSts;
	END_IF
END_IF

//IO输出
IF i_xOutPutEn THEN
	//写入到输出io@2025.08.20.152508
	IF i_pstStAbsEncIOModule<>0 THEN
		wQX := i_pstStAbsEncIOModule^.wQX;
	END_IF
	IF i_pwQW0<>0 THEN
		i_pwQW0^:=wQX;
	END_IF
END_IF

