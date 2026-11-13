(*@CES
Name=KS_SetValueByAIType
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=1789f748-e9c1-482e-88f3-0e0eb31b2a1c
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_SetValueByAIType : BOOL(*根据传感器类型写入换算值|电位器写入模拟量值|绝对值编码器方式根据标志写入绝对值或者换算值*)
(*针对编码器过圈问题处理*)
(*2024.01.21.105453 过圈的处理不太完善*)
VAR_INPUT
	i_dwAIData:DWORD;(*采样值*)
	i_byAiType:BYTE;
	(* 控制0~5的状态切换/0:-10v~10v; /.1:0~10v; /.2:4~20mA; /.3:-5~5v; /.4:0~5v; /.5:0~20mA *)
	(*2022.8.29.174810 增加一种类型|/.6 绝对值编码器方式*)
	i_byOutType:BYTE;(*绝对值方式下输出形式|0: 实际绝对值|1:根据+-10v转换值-相对于中位值的(用于最终计算张力调整量)
					   电位器方式下输出形式|0: 实际值|1:相对于中位值的(用于最终计算张力调整量)*)
	i_lrAIData_med:LREAL;(*中位值*)
	(*2024.01.21.102636 该值应该是编码器旋转的最大角度@以前的注释有问题*)
	i_byMaxAngle_AITypeEnc:BYTE:=60;(*绝对值方式下摆臂最大角度(对称|单位°)|用于控制i_byOutType=1时+-10v和角度对应关系*)
	i_dwEncResolution:DWORD:=8388608;(*单圈分辨率|23BITS*)
	i_plrValue:POINTER TO LREAL;(*换算值*)
END_VAR
VAR
	lrAngle_Med									: LREAL;(*中位角度|0对应0°|i_dwEncResolution对应360°*)
	lrAngle_Cur									: LREAL;(*当前角度|0对应0°|i_dwEncResolution对应360°*)
	lrAngle_Max									: LREAL;(*最大角度(正角度)|相对于中位*)
	lrAngle_Min									: LREAL;(*最小角度(负角度)|相对于中位*)
	iAngle_Max_Valid							: INT:=180;(*最大合法偏摆角度*)
	iAngle_add									: INT:=20;(*在最大角度和最小角度上叠加的角度@这个之内都是合法的*)
	lrN_min										: LREAL;
	lrN_max										: LREAL;
	diN_min										: DINT;
	diN_max										: DINT;
	lrTempResult								: LREAL;
	lrTemp										: LREAL;
	lrTemp1										: LREAL;
	wAIData										: WORD;
END_VAR
{IMPLEMENTATION}
CASE i_byAiType OF
 		6:(*绝对值方式*)
			(*0对应0°|i_dwEncResolution对应360°*)
			IF i_dwEncResolution<>0 THEN
				lrAngle_Cur:=DWORD_TO_LREAL(i_dwAIData)/i_dwEncResolution*360;
			END_IF
			(*0对应0°|i_dwEncResolution对应360°*)
			IF i_dwEncResolution<>0 THEN
				lrAngle_Med:=(i_lrAIData_med)/i_dwEncResolution*360;
			END_IF
			(*求最大\小偏摆角度*)
			lrTemp:=BYTE_TO_LREAL(i_byMaxAngle_AITypeEnc)/2;(*取输入最大摆动的一半|该值在下面运算被使用了*)
			(*计算合法角度范围@2024.01.21.103626+注释*)
			lrAngle_Max:=lrTemp+lrAngle_Med;
			lrAngle_Max:=lrAngle_Max+iAngle_add;(*叠加冗余@2024.01.21.103531*)

			lrAngle_Min:=-lrTemp+lrAngle_Med;
			lrAngle_Min:=lrAngle_Min-iAngle_add;(*叠加冗余@2024.01.21.103528*)


			IF i_byOutType=1 THEN(*转换为+-10V(相对于中位)|-10 对应lrAngle_Min角度|10对应lrAngle_Max角度*)
				IF (lrAngle_Cur>=lrAngle_Min AND
					lrAngle_Cur<=lrAngle_Max) THEN(*当前角度处于区间内*)
					lrTemp1:=lrAngle_Cur-lrAngle_Med;(*相对于中位*)
				ELSIF lrAngle_Cur<lrAngle_Min THEN
					lrTemp1:=lrAngle_Cur+360-lrAngle_Med;(*相对于中位*)
				ELSIF lrAngle_Cur>=lrAngle_Max THEN
					lrTemp1:=lrAngle_Cur-360-lrAngle_Med;(*相对于中位*)
				END_IF


				IF lrTemp<>0 THEN
					lrTempResult:=10/lrTemp*lrTemp1;(*相对于中位值*)
					IF lrTempResult>10 THEN
						lrTempResult:=10;
					ELSIF lrTempResult<=-10 THEN
						lrTempResult:=-10;
					END_IF
				END_IF

			ELSE(*使用当前值*)
				lrTempResult:=DWORD_TO_LREAL(i_dwAIData);
			END_IF

ELSE(*电位器方式*)
	wAIData:=DWORD_TO_WORD(i_dwAIData);
	KS_QueryRangeByAType(i_byAiType, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
	lrTempResult:= KSIO_DA(WORD_TO_INT(wAIData), lrN_min, lrN_max, diN_min, diN_max);

	IF i_byOutType=1 THEN(*相对于中位值的(用于最终计算张力调整量)*)
		lrTempResult:=lrTempResult-i_lrAIData_med;
	ELSE(*实际值*);
	END_IF
END_CASE

IF i_plrValue<>0 THEN
	i_plrValue^:=lrTempResult;
END_IF