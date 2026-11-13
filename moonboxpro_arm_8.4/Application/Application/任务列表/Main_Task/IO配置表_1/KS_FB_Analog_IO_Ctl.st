(*@CES
Name=KS_FB_Analog_IO_Ctl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=4016e3e3-194e-4d0e-bf3a-be5de89b9130
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_Analog_IO_Ctl(*AI/O Type Value: 0:-10v~10v; 1:0~10v; 2:4~20mA; 3:-5~5v; 4:0~5v; 5:0~20mA||6:绝对值编码器*)
(*2022.8.30.085346 由于增加了绝对值编码器方式的摆臂控制|将所有摆臂输入数字量数据类型修改DWORD*)
(*2023.09.04.130949 增加超声波卷径检测按照轴输入的模拟量获取逻辑*)
(*2023.11.06.144531 处理中位值赋值类型转换问题-LREAL_TO_DWORD,导致精度丢失*)
VAR_INPUT
	i_xEn										: BOOL;(*功能块整体使能|*)

	i_dwAI_Uw_I									: DWORD;(*1放料模拟量|*)(*2022.8.30.145138 修改数据类型*)
	i_byAIType_Uw_I								: BYTE;(*see AI/O Type Value|*)
	i_xNegPolarity_Uw_I							: BOOL;(*1放-放料摆臂方向取反|*)

	i_dwAI_If_I									: DWORD;(*1放牵模拟量|*)(*2022.8.30.145138 修改数据类型*)
	i_byAIType_If_I								: BYTE;(*see AI/O Type Value|*)
	i_xNegPolarity_If_I							: BOOL;(*1放-放牵摆臂方向取反|*)

	i_dwAI_Of_I									: DWORD;(*1收牵模拟量|*)(*2022.8.30.145138 修改数据类型*)
	i_byAIType_Of_I								: BYTE;(*see AI/O Type Value|*)
	i_xNegPolarity_Of_I							: BOOL;(*1放-收牵摆臂方向取反|*)

	i_dwAI_Rw_I									: DWORD;(*1收料模拟量|*)(*2022.8.30.145138 修改数据类型*)
	i_byAIType_Rw_I								: BYTE;(*see AI/O Type Value|*)
	i_xNegPolarity_Rw_I							: BOOL;(*1放-收料摆臂方向取反|*)

	i_wAI_Uw_DiamMeasure_UpCut_I				: WORD;(*A放料卷径测量电位器(上裁位)|*)
	i_byAIType_DiamMeasure_UpCut_I				: BYTE;(*see AI/O Type Value|*)

	i_wAI_Uw_DiamMeasure_DnCut_I				: WORD;(*A放料卷径测量电位器(下裁位)|*)
	i_byAIType_DiamMeasure_DnCut_I				: BYTE;(*see AI/O Type Value|*)

	i_dwAI_Uw_II								: DWORD;(*2放料模拟量|*)(*2022.8.30.145138 修改数据类型*)
	i_byAIType_Uw_II							: BYTE;(*see AI/O Type Value|*)
	i_xNegPolarity_Uw_II						: BOOL;(*2放-放料摆臂方向取反|*)

	i_dwAI_If_II								: DWORD;(*2放牵模拟量|*)(*2022.8.30.145138 修改数据类型*)
	i_byAIType_If_II							: BYTE;(*see AI/O Type Value|*)
	i_xNegPolarity_If_II						: BOOL;(*2放-放牵摆臂方向取反|*)

	i_dwAI_Of_II								: DWORD;(*2收牵模拟量|*)(*2022.8.30.145138 修改数据类型*)
	i_byAIType_Of_II							: BYTE;(*see AI/O Type Value|*)
	i_xNegPolarity_Of_II						: BOOL;(*2放-收牵摆臂方向取反|*)

	i_dwAI_Rw_II								: DWORD;(*2收料模拟量|*)(*2022.8.30.145138 修改数据类型*)
	i_byAIType_Rw_II							: BYTE;(*see AI/O Type Value|*)
	i_xNegPolarity_Rw_II						: BOOL;(*2放-收料摆臂方向取反|*)

	i_wAI_Uw_DiamMeasure_UpCut_II				: WORD;(*2放料卷径测量电位器(上裁位)|*)
	i_byAIType_DiamMeasure_UpCut_II				: BYTE;(*see AI/O Type Value|*)

	i_wAI_Uw_DiamMeasure_DnCut_II				: WORD;(*2放料卷径测量电位器(下裁位)|*)
	i_byAIType_DiamMeasure_DnCut_II				: BYTE;(*see AI/O Type Value|*)

	i_byAOType_Uw_AxisA_I						: BYTE;(*A|放料A轴输出|see AI/O Type Value||*)
	i_byAOType_Uw_AxisB_I						: BYTE;(*A|放料B轴输出|see AI/O Type Value||*)
	i_byAOType_Rw_AxisA_I						: BYTE;(*A|收料A轴输出|see AI/O Type Value||*)
	i_byAOType_Rw_AxisB_I						: BYTE;(*A|收料B轴输出|see AI/O Type Value||*)
	i_byAOType_Uw_Taper_I						: BYTE;(*A|放料锥度模拟量|see AI/O Type Value|@2019.8.2.161635|*)
	i_byAOType_Rw_Taper_I						: BYTE;(*A|收料锥度模拟量|see AI/O Type Value||*)
	i_byAOType_If_Taper_I						: BYTE;(*A|放牵锥度模拟量|see AI/O Type Value|@2019.8.2.161635|*)
	i_byAOType_Of_Taper_I						: BYTE;(*A|收牵锥度模拟量|see AI/O Type Value|@2019.8.2.161635|*)
	i_byAOType_Velocity_I						: BYTE;(*A|速度表输出类型|see AI/O Type Value||*)
	i_byAOType_VelocityEx_I						: BYTE;(*A|扩展速度表输出类型|see AI/O Type Value||*)

	i_byAOType_Uw_AxisA_II						: BYTE;(*B|放料A轴输出|see AI/O TYPE Value||*)
	i_byAOType_Uw_AxisB_II						: BYTE;(*B|放料B轴输出|see AI/O TYPE Value||*)
	i_byAOType_Rw_AxisA_II						: BYTE;(*B|收料A轴输出|see AI/O TYPE Value||*)
	i_byAOType_Rw_AxisB_II						: BYTE;(*B|收料B轴输出|see AI/O TYPE Value||*)
	i_byAOType_Uw_Taper_II						: BYTE;(*B|放料锥度模拟量|see AI/O TYPE Value|@2019.8.2.161635|*)
	i_byAOType_Rw_Taper_II						: BYTE;(*B|收料锥度模拟量|see AI/O TYPE Value||*)
	i_byAOType_If_Taper_II						: BYTE;(*B|放牵锥度模拟量|see AI/O TYPE Value|@2019.8.2.161635|*)
	i_byAOType_Of_Taper_II						: BYTE;(*B|收牵锥度模拟量|see AI/O TYPE Value|@2019.8.2.161635|*)
	i_byAOType_Velocity_II						: BYTE;(*B|速度表输出类型|see AI/O TYPE Value||*)
	i_byAOType_VelocityEx_II					: BYTE;(*B|扩展速度表输出类型|see AI/O TYPE Value||*)

	i_xAI_Enable								: BOOL;(*处理AI|*)
	i_xAO_Enable								: BOOL;(*处理AO|*)

	i_xIsDualUwRw								: BOOL;(*双收双放机型|*)
	i_xAsOneMachine								: BOOL;(*作为一台机使用|*)

	i_xSts_IOtest								: BOOL := FALSE;(*IO测试状态|*)
	(*2022.8.30.215915*)
	i_byMaxAngle_AITypeEnc						:BYTE:=20;(*绝对值方式下摆臂最大角度(对称|单位°)|用于控制i_byOutType_AITypeEnc=1时+-10v和角度对应关系*)
	i_dwEncResolution_Uw_I						:DWORD:=8388608;(*单圈分辨率|23BITS*)
	i_dwEncResolution_Rw_I						:DWORD:=8388608;(*单圈分辨率|23BITS*)
	i_dwEncResolution_If_I						:DWORD:=8388608;(*单圈分辨率|23BITS*)
	i_dwEncResolution_Of_I						:DWORD:=8388608;(*单圈分辨率|23BITS*)

	i_dwEncResolution_Uw_II						:DWORD:=8388608;(*单圈分辨率|23BITS*)
	i_dwEncResolution_Rw_II						:DWORD:=8388608;(*单圈分辨率|23BITS*)
	i_dwEncResolution_If_II						:DWORD:=8388608;(*单圈分辨率|23BITS*)
	i_dwEncResolution_Of_II						:DWORD:=8388608;(*单圈分辨率|23BITS*)
	(*2023.08.29.083432*)
	i_wAI_Uw_DiamMeasure_AxisA_I				:WORD;(*A轴放料卷径测量电压@用于超声波|*)
	i_wAI_Uw_DiamMeasure_AxisB_I				:WORD;(*B轴放料卷径测量电压@用于超声波|*)
	i_byAIType_DiamMeasure_Axis_I				:BYTE;(*see AI/O Type Value|*)

	i_wAI_Uw_DiamMeasure_AxisA_II				:WORD;(*A轴放料卷径测量电压@用于超声波|*)
	i_wAI_Uw_DiamMeasure_AxisB_II				:WORD;(*B轴放料卷径测量电压@用于超声波|*)
	i_byAIType_DiamMeasure_Axis_II				:BYTE;(*see AI/O Type Value|*)
	i_pastStProgMonitoring						: POINTER TO ARRAY [1..2] OF StProgMonitoring;	
	i_pbyAiFilterTms_UwRw_I						: POINTER TO BYTE;(*滤波次数*)
	i_pbyAiFilterTms_UwRw_II					: POINTER TO BYTE;
	i_pbyAiFilterTms_IfOf_I						: POINTER TO BYTE;
	i_pbyAiFilterTms_IfOf_II					: POINTER TO BYTE;
	i_pbyAiFilterTms_DiaMeasure_I				: POINTER TO BYTE;			
	i_pbyAiFilterTms_DiaMeasure_II				: POINTER TO BYTE;
// 	2025.08.22.201829+
// 	i_pxBtn_ConfirmMedian_Uw_I					: POINTER TO BOOL;(*摆臂中位确认按钮-放料*)
// 	i_pxBtn_ConfirmMedian_Rw_I					: POINTER TO BOOL;(*摆臂中位确认按钮-收料*)
// 	i_pxBtn_ConfirmMedian_If_I					: POINTER TO BOOL;(*摆臂中位确认按钮-放牵*)
// 	i_pxBtn_ConfirmMedian_Of_I					: POINTER TO BOOL;(*摆臂中位确认按钮-收牵*)	
// 	i_pxBtn_ConfirmMedian_Uw_II					: POINTER TO BOOL;(*摆臂中位确认按钮-放料*)
// 	i_pxBtn_ConfirmMedian_Rw_II					: POINTER TO BOOL;(*摆臂中位确认按钮-收料*)
// 	i_pxBtn_ConfirmMedian_If_II					: POINTER TO BOOL;(*摆臂中位确认按钮-放牵*)
// 	i_pxBtn_ConfirmMedian_Of_II					: POINTER TO BOOL;(*摆臂中位确认按钮-收牵*)	
	i_pbyBtn_ConfirmMedian_I					: POINTER TO BYTE;(*摆臂中位确认按钮-|./0放料|./1收料|./2放牵|./2收牵*)
	i_pbyBtn_ConfirmMedian_II					: POINTER TO BYTE;(*摆臂中位确认按钮-|./0放料|./1收料|./2放牵|./2收牵*)
	i_prAI_med_Uw_I									: POINTER TO REAL;
	i_prAI_med_Rw_I									: POINTER TO REAL;
	i_prAI_med_If_I									: POINTER TO REAL;
	i_prAI_med_Of_I									: POINTER TO REAL;
	i_prAI_med_Uw_II								: POINTER TO REAL;
	i_prAI_med_Rw_II									: POINTER TO REAL;
	i_prAI_med_If_II									: POINTER TO REAL;
	i_prAI_med_Of_II									: POINTER TO REAL;
	i_xIsDebugMode_I									: BOOL;
	i_xIsDebugMode_II									: BOOL;		
	i_byDiamMeasureTypeId_I									: BYTE;	
	i_byDiamMeasureTypeId_II									: BYTE;	
	i_wUwRwAxisProf_I										: WORD;
	i_wUwRwAxisProf_II										: WORD;
	i_xCutterOnTop_Uw_I										: BOOL;
	i_xCutterOnTop_Uw_II										: BOOL;
	
	i_lrAO_Inverter_Uw_AxisA_I								: LREAL;(*变频器电压值输出*)
	i_lrAO_Inverter_Uw_AxisB_I								: LREAL;(*变频器电压值输出*)
	i_lrAO_Inverter_Rw_AxisA_I								: LREAL;(*变频器电压值输出*)
	i_lrAO_Inverter_Rw_AxisB_I								: LREAL;(*变频器电压值输出*)
	i_lrAO_Inverter_Uw_AxisA_II								: LREAL;(*变频器电压值输出*)
	i_lrAO_Inverter_Uw_AxisB_II								: LREAL;(*变频器电压值输出*)
	i_lrAO_Inverter_Rw_AxisA_II								: LREAL;(*变频器电压值输出*)
	i_lrAO_Inverter_Rw_AxisB_II								: LREAL;(*变频器电压值输出*)
	i_lrUpperFreq_Uw_I										: LREAL;
	i_lrUpperFreq_Uw_II										: LREAL;
	i_lrUpperFreq_Rw_I										: LREAL;
	i_lrUpperFreq_Rw_II										: LREAL;
	
	i_rVel_Max_I												: REAL;(*最大速度*)
	i_rVel_Cur_I												: REAL;(*当前速度*)
	i_rVel_Max_II												: REAL;(*最大速度*)
	i_rVel_Cur_II												: REAL;(*当前速度*)
	i_lrTaper_Cur_Uw_I											: LREAL;(*放料锥度*)
	i_lrTaper_Cur_Rw_I											: LREAL;(*放料锥度*)
	i_lrTaper_Cur_If_I											: LREAL;(*放料锥度*)
	i_lrTaper_Cur_Of_I											: LREAL;(*放料锥度*)
	i_lrTaper_Cur_Uw_II											: LREAL;(*放料锥度*)
	i_lrTaper_Cur_Rw_II											: LREAL;(*放料锥度*)
	i_lrTaper_Cur_If_II											: LREAL;(*放料锥度*)
	i_lrTaper_Cur_Of_II											: LREAL;(*放料锥度*)
END_VAR
VAR_OUTPUT
	o_xEno										: BOOL;
	o_iErNo										: INT;
	(*------------------------------A系_|*)
	(*变频器速度|*)
	o_wAO_Inverter_Uw_AxisA_I					: WORD;(*A|放料A轴输出*)
	o_wAO_Inverter_Uw_AxisB_I					: WORD;(*A|放料B轴输出*)
	o_wAO_Inverter_Rw_AxisA_I					: WORD;(*A|收料A轴输出*)
	o_wAO_Inverter_Rw_AxisB_I					: WORD;(*A|收料B轴输出*)
	(*锥度|*)
	o_wAO_Uw_Taper_I							: WORD;(*A|放料锥度模拟量@2019.8.2.154151|*)
	o_wAO_Rw_Taper_I							: WORD;(*A|收料锥度模拟量*)
	o_wAO_If_Taper_I							: WORD;(*A|放牵锥度模拟量@2019.8.2.154151|*)
	o_wAO_Of_Taper_I							: WORD;(*A|收牵锥度模拟量@2019.8.2.154151|*)
	(*速度表|*)
	o_wAO_Velocity_I							: WORD;(*A|速度*)
	o_wAO_VelocityEx_I							: WORD;(*A|扩展速度*)
	(*------------------------------B系_|*)
	(*变频器速度|*)
	o_wAO_Inverter_Uw_AxisA_II					: WORD;(*B|放料A轴输出*)
	o_wAO_Inverter_Uw_AxisB_II					: WORD;(*B|放料B轴输出*)
	o_wAO_Inverter_Rw_AxisA_II					: WORD;(*B|收料A轴输出*)
	o_wAO_Inverter_Rw_AxisB_II					: WORD;(*B|收料B轴输出*)
	(*锥度|*)
	o_wAO_Uw_Taper_II							: WORD;(*B|放料锥度模拟量@2019.8.2.154151|*)
	o_wAO_Rw_Taper_II							: WORD;(*B|收料锥度模拟量*)
	o_wAO_If_Taper_II							: WORD;(*B|放牵锥度模拟量@2019.8.2.154151|*)
	o_wAO_Of_Taper_II							: WORD;(*B|收牵锥度模拟量@2019.8.2.154151|*)
	(*速度表|*)
	o_wAO_Velocity_II							: WORD;(*B|速度*)
	o_wAO_VelocityEx_II							: WORD;(*B|扩展速度*)
	
	o_rAI_Uw_I										: REAL;(*放料摆臂-中位值*)
	o_rAI_Rw_I										: REAL;(*收料摆臂-中位值*)
	o_rAI_If_I										: REAL;(*放牵摆臂-中位值*)
	o_rAI_Of_I										: REAL;(*收牵摆臂-中位值*)	
	o_rAI_Uw_II										: REAL;(*放料摆臂-中位值*)
	o_rAI_Rw_II										: REAL;(*收料摆臂-中位值*)
	o_rAI_If_II										: REAL;(*放牵摆臂-中位值*)
	o_rAI_Of_II										: REAL;(*收牵摆臂-中位值*)			
	o_rAI_DiamMeasure_Uw_Cur_I						: REAL;(*最终使用数据结构里的参数||？？？*)
	o_rAI_DiamMeasure_Uw_Cur_II						: REAL;(*最终使用数据结构里的参数||？？？*)
	
END_VAR
VAR
	iA,iN										: INT;
	xIsDualUwRw									: BOOL := FALSE;
	xAsOneMachine								: BOOL := FALSE;

	(*2018.3.27.150821|*)
	byAveTms_UwRw								: BYTE := 0;
	byAveTms_IfOf								: BYTE := 0;
	abyAveTms_DiaMeasure						: ARRAY [1..2] OF BYTE := [2(0)];

	(*2017-08-28 09:38:37|
	/.数组[0]位置存放的是平均结果,[1]存放的是最新的值|
	*)
	awAI_Uw										: ARRAY [1..2,0..50] OF WORD; (*两组放料*)
	awAI_If										: ARRAY [1..2,0..50] OF WORD; (*两组放牵*)
	awAI_Of										: ARRAY [1..2,0..50] OF WORD; (*两组收牵*)
	awAI_Rw										: ARRAY [1..2,0..50] OF WORD; (*两组收料*)
	awAI_DiamMeasure_UpCut						: ARRAY [1..2,0..50] OF WORD;(*A\B放料的标准卷径测量电位器|*)
	awAI_DiamMeasure_DnCut						: ARRAY [1..2,0..50] OF WORD;(*A\B放料的标准卷径测量电位器|*)
	(*2023.08.29.083812*)
	awAI_DiamMeasure_AxisA						: ARRAY [1..2,0..50] OF WORD;(*A\B放料ab轴的标准卷径测量|*)
	awAI_DiamMeasure_AxisB						: ARRAY [1..2,0..50] OF WORD;(*A\B放料ab轴的标准卷径测量|*)

	(*做累加和平均滤波使用的|*)
	alrSumVal_If								: ARRAY [1..2] OF LREAL;
	alrSumVal_Of								: ARRAY [1..2] OF LREAL;
	alrSumVal_Uw								: ARRAY [1..2] OF LREAL;
	alrSumVal_Rw								: ARRAY [1..2] OF LREAL;
	alrSumVal_DiaMeasure_UpCut					: ARRAY [1..2] OF LREAL;(*上裁|*)
	alrSumVal_DiaMeasure_DnCut					: ARRAY [1..2] OF LREAL;(*下裁|*)
	(*2023.08.29.091200*)
	alrSumVal_DiaMeasure_AxisA					: ARRAY [1..2] OF LREAL;(*轴A|*)
	alrSumVal_DiaMeasure_AxisB					: ARRAY [1..2] OF LREAL;(*轴B|*)
	(*2018.4.4.113708|*)
	lrN_min										: LREAL;
	lrN_max										: LREAL;
	diN_min										: DINT;
	diN_max										: DINT;
	lrTempResult								: LREAL;

	lrTmp										: LREAL;
	lrTmpVel_Volt								: LREAL;
	lrTmpTaper_Uw								: LREAL;(*2019.8.2.162447|*)
	lrTmpTaper_Rw								: LREAL;(*2018.11.22.120210|add|*)
	lrTmpTaper_If								: LREAL;(*2019.8.2.162447|*)
	lrTmpTaper_Of								: LREAL;(*2019.8.2.162447|*)

	(*2019.4.2.124449|计算输出频率的临时变量|*)
	lrFreq_Uw_AxisA_I							: LREAL;
	lrFreq_Uw_AxisB_I							: LREAL;
	lrFreq_Uw_AxisA_II							: LREAL;
	lrFreq_Uw_AxisB_II							: LREAL;
	lrFreq_Rw_AxisA_I							: LREAL;
	lrFreq_Rw_AxisB_I							: LREAL;
	lrFreq_Rw_AxisA_II							: LREAL;
	lrFreq_Rw_AxisB_II							: LREAL;

	(*2022.8.30.085601*)
	wAI_Uw_I									: WORD;(*放料模拟量|电压\电流输入*)
	wAI_Rw_I									: WORD;(*收料模拟量|电压\电流输入*)
	wAI_If_I									: WORD;(*放牵模拟量|电压\电流输入*)
	wAI_Of_I									: WORD;(*收牵模拟量|电压\电流输入*)
	wAI_Uw_II									: WORD;(*放料模拟量|电压\电流输入*)
	wAI_Rw_II									: WORD;(*收料模拟量|电压\电流输入*)
	wAI_If_II									: WORD;(*放牵模拟量|电压\电流输入*)
	wAI_Of_II									: WORD;(*收牵模拟量|电压\电流输入*)
	(*2022.8.30.221117 为了兼容编码器方式*)
	dwAiData: DWORD;
	byAITyp: BYTE;
	dwAdr_lrValue: DWORD;
	xNegPolarity: BOOL;
	lrAIData_med:LREAL;
	byMaxAngle_AITypeEnc: BYTE:=20;(*绝对值方式下摆臂最大角度(对称|单位°)|用于控制i_byOutType_AITypeEnc=1时+-10v和角度对应关系*)
	dwEncResolution: DWORD;
	apbyAiFilterTms_UwRw: ARRAY [1..2] OF POINTER TO BYTE;
	apbyAiFilterTms_IfOf: ARRAY [1..2] OF POINTER TO BYTE;	
	apbyAiFilterTms_DiaMeasure: ARRAY [1..2] OF POINTER TO BYTE;
	apxBtn_ConfirmMedian_Uw: ARRAY [1..2] OF POINTER TO BOOL;
	apxBtn_ConfirmMedian_Rw: ARRAY [1..2] OF POINTER TO BOOL;
	apxBtn_ConfirmMedian_If: ARRAY [1..2] OF POINTER TO BOOL;
	apxBtn_ConfirmMedian_Of: ARRAY [1..2] OF POINTER TO BOOL;
	aprAI_med_Uw: ARRAY [1..2] OF POINTER TO REAL;
	aprAI_med_Rw: ARRAY [1..2] OF POINTER TO REAL;
	aprAI_med_If: ARRAY [1..2] OF POINTER TO REAL;
	aprAI_med_Of: ARRAY [1..2] OF POINTER TO REAL;
	arAI_Uw: ARRAY [1..2] OF REAL;
	arAI_Rw: ARRAY [1..2] OF REAL;
	arAI_If: ARRAY [1..2] OF REAL;
	arAI_Of: ARRAY [1..2] OF REAL;
	arAI_DiamMeasure_Uw_cur: ARRAY [1..2] OF REAL;
	axIsDebugMode: ARRAY [1..2] OF BOOL;
	byDiamMeasureTypeId: BYTE;
	wUwRwAxisProf: WORD;
	xCutterOnTop_Uw: BOOL;
	
	//2025.08.22.201729
	xBtn_ConfirmMedian_Uw_I					: BOOL;(*摆臂中位确认按钮-放料*)
	xBtn_ConfirmMedian_Rw_I					: BOOL;(*摆臂中位确认按钮-收料*)
	xBtn_ConfirmMedian_If_I					: BOOL;(*摆臂中位确认按钮-放牵*)
	xBtn_ConfirmMedian_Of_I					: BOOL;(*摆臂中位确认按钮-收牵*)	
	xBtn_ConfirmMedian_Uw_II				: BOOL;(*摆臂中位确认按钮-放料*)
	xBtn_ConfirmMedian_Rw_II				: BOOL;(*摆臂中位确认按钮-收料*)
	xBtn_ConfirmMedian_If_II				: BOOL;(*摆臂中位确认按钮-放牵*)
	xBtn_ConfirmMedian_Of_II				: BOOL;(*摆臂中位确认按钮-收牵*)	
END_VAR

{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;

(*2022.8.30.144728 由于增加了编码器方式的摆臂输入|将输入的数据类型改为了DWORD
为了兼容将原来电位器输入的值写入到word型临时变量中*)
wAI_Uw_I:=DWORD_TO_WORD(i_dwAI_Uw_I);
wAI_Rw_I:=DWORD_TO_WORD(i_dwAI_Rw_I);
wAI_If_I:=DWORD_TO_WORD(i_dwAI_If_I);
wAI_Of_I:=DWORD_TO_WORD(i_dwAI_Of_I);

wAI_Uw_II:=DWORD_TO_WORD(i_dwAI_Uw_II);
wAI_Rw_II:=DWORD_TO_WORD(i_dwAI_Rw_II);
wAI_If_II:=DWORD_TO_WORD(i_dwAI_If_II);
wAI_Of_II:=DWORD_TO_WORD(i_dwAI_Of_II);
byMaxAngle_AITypeEnc:=i_byMaxAngle_AITypeEnc;

IF i_xEn AND i_pastStProgMonitoring<>0 THEN

	IF xIsDualUwRw<>i_xIsDualUwRw OR
		xAsOneMachine<>i_xAsOneMachine THEN
		xIsDualUwRw:= i_xIsDualUwRw;
		xAsOneMachine:= i_xAsOneMachine;

		byAveTms_UwRw:= 0;
		byAveTms_IfOf:= 0;
		abyAveTms_DiaMeasure[1]:= 0;
		abyAveTms_DiaMeasure[2]:= 0;
	END_IF

	IF i_xAI_Enable THEN
		(*
		/.han.dp|
		/.用[1]位置存放最新的模拟量输入|
		/.*)
		FOR iA:=1 TO 2 BY 1 DO(*A/B两个系|*)
			FOR iN:=50 TO 2 BY -1 DO
				(*放料\收料摆臂电位器|*)
				awAI_Uw[iA,iN] := awAI_Uw[iA,iN-1];
				awAI_Rw[iA,iN] := awAI_Rw[iA,iN-1];

				(*放牵\收牵摆臂电位器|*)
				awAI_If[iA,iN] := awAI_If[iA,iN-1];
				awAI_Of[iA,iN] := awAI_Of[iA,iN-1];

				(*标准卷径电位器|*)
				(*2018.7.16.095847\修正更名后遗漏的bug|*)
				(*awAI_DiamMeasure[iA,iN]:= awAI_DiamMeasure[iA,iN-1];*)
				awAI_DiamMeasure_UpCut[iA,iN]:= awAI_DiamMeasure_UpCut[iA,iN-1];
				awAI_DiamMeasure_DnCut[iA,iN]:= awAI_DiamMeasure_DnCut[iA,iN-1];
			END_FOR
		END_FOR

		(*放料\收料|*)
		awAI_Uw[1,1] := wAI_Uw_I;(*A|*)
		awAI_Rw[1,1] := wAI_Rw_I;
		awAI_Uw[2,1] := wAI_Uw_II;(*B|*)
		awAI_Rw[2,1] := wAI_Rw_II;

		(*放牵\收牵|*)
		awAI_If[1,1] := wAI_If_I;(*A|*)
		awAI_Of[1,1] := wAI_Of_I;
		awAI_If[2,1] := wAI_If_II;(*B|*)
		awAI_Of[2,1] := wAI_Of_II;

		(*卷径测量|*)
		(*2018.7.15.103321\开始分上下裁了|*)
		(*上裁|*)
		awAI_DiamMeasure_UpCut[1,1]:= i_wAI_Uw_DiamMeasure_UpCut_I;(*A|*)
		awAI_DiamMeasure_UpCut[2,1]:= i_wAI_Uw_DiamMeasure_UpCut_II;(*B|*)
		(*下裁|*)
		awAI_DiamMeasure_DnCut[1,1]:= i_wAI_Uw_DiamMeasure_DnCut_I;(*A|*)
		awAI_DiamMeasure_DnCut[2,1]:= i_wAI_Uw_DiamMeasure_DnCut_II;(*B|*)

		(*A轴*)
		awAI_DiamMeasure_AxisA[1,1]:= i_wAI_Uw_DiamMeasure_AxisA_I;(*A系|*)
		awAI_DiamMeasure_AxisA[2,1]:= i_wAI_Uw_DiamMeasure_AxisA_II;(*B系|*)
		(*b轴*)
		awAI_DiamMeasure_Axisb[1,1]:= i_wAI_Uw_DiamMeasure_Axisb_I;(*A系|*)
		awAI_DiamMeasure_Axisb[2,1]:= i_wAI_Uw_DiamMeasure_Axisb_II;(*B系|*)


		(*2018.11.22.102945\增加监控输出点|*)
		IF i_pastStProgMonitoring<>0 THEN
			(*I组输入|*)
			(*输入的值|不处理绝对值编码器的值-只处理电位器的|2022.8.30.151106*)
			i_pastStProgMonitoring^[1].i_wUw_cur:= awAI_Uw[1,1];
			i_pastStProgMonitoring^[1].i_wRw_cur:= awAI_Rw[1,1];
			i_pastStProgMonitoring^[1].i_wIf_cur:= awAI_If[1,1];
			i_pastStProgMonitoring^[1].i_wOf_cur:= awAI_Of[1,1];


			(*2022.8.30.215849 修改*)
			(*放料*)
			KS_SetValueByAIType(
					i_dwAI_Uw_I(*i_dwAIData*),
					i_byAIType_Uw_I(*i_byAiType*),
					0(*i_byOutType_AITypeEnc*),
					0(*i_lrAIData_med*),
					0(*i_byMaxAngle_AITypeEnc*),
					0(*i_dwEncResolution*),
					ADR(i_pastStProgMonitoring^[1].i_lrUw_real)(*i_plrValue*));
			(*放牵*)
			KS_SetValueByAIType(
					i_dwAI_If_I(*i_dwAIData*),
					i_byAIType_If_I(*i_byAiType*),
					0(*i_byOutType_AITypeEnc*),
					0(*i_lrAIData_med*),
					0(*i_byMaxAngle_AITypeEnc*),
					0(*i_dwEncResolution*),
					ADR(i_pastStProgMonitoring^[1].i_lrIf_real)(*i_plrValue*));
			(*收牵*)
			KS_SetValueByAIType(
					i_dwAI_Of_I(*i_dwAIData*),
					i_byAIType_Of_I(*i_byAiType*),
					0(*i_byOutType_AITypeEnc*),
					0(*i_lrAIData_med*),
					0(*i_byMaxAngle_AITypeEnc*),
					0(*i_dwEncResolution*),
					ADR(i_pastStProgMonitoring^[1].i_lrOf_real)(*i_plrValue*));
			(*收料*)
			KS_SetValueByAIType(
					i_dwAI_Rw_I(*i_dwAIData*),
					i_byAIType_Rw_I(*i_byAiType*),
					0(*i_byOutType_AITypeEnc*),
					0(*i_lrAIData_med*),
					0(*i_byMaxAngle_AITypeEnc*),
					0(*i_dwEncResolution*),
					ADR(i_pastStProgMonitoring^[1].i_lrRw_real)(*i_plrValue*));
			(*II组输入|*)
			(*输入的值|不处理绝对值编码器的值-只处理电位器的|2022.8.30.151106*)
			i_pastStProgMonitoring^[2].i_wUw_cur:= awAI_Uw[2,1];
			i_pastStProgMonitoring^[2].i_wRw_cur:= awAI_Rw[2,1];
			i_pastStProgMonitoring^[2].i_wIf_cur:= awAI_If[2,1];
			i_pastStProgMonitoring^[2].i_wOf_cur:= awAI_Of[2,1];

			(*2022.8.30.215849 修改*)
			(*放料*)
			KS_SetValueByAIType(
					i_dwAI_Uw_II(*i_dwAIData*),
					i_byAIType_Uw_II(*i_byAiType*),
					0(*i_byOutType_AITypeEnc*),
					0(*i_lrAIData_med*),
					0(*i_byMaxAngle_AITypeEnc*),
					0(*i_dwEncResolution*),
					ADR(i_pastStProgMonitoring^[2].i_lrUw_real)(*i_plrValue*));
			(*放牵*)
			KS_SetValueByAIType(
					i_dwAI_If_II(*i_dwAIData*),
					i_byAIType_If_II(*i_byAiType*),
					0(*i_byOutType_AITypeEnc*),
					0(*i_lrAIData_med*),
					0(*i_byMaxAngle_AITypeEnc*),
					0(*i_dwEncResolution*),
					ADR(i_pastStProgMonitoring^[2].i_lrIf_real)(*i_plrValue*));
			(*收牵*)
			KS_SetValueByAIType(
					i_dwAI_Of_II(*i_dwAIData*),
					i_byAIType_Of_II(*i_byAiType*),
					0(*i_byOutType_AITypeEnc*),
					0(*i_lrAIData_med*),
					0(*i_byMaxAngle_AITypeEnc*),
					0(*i_dwEncResolution*),
					ADR(i_pastStProgMonitoring^[2].i_lrOf_real)(*i_plrValue*));
			(*收料*)
			KS_SetValueByAIType(
					i_dwAI_Rw_II(*i_dwAIData*),
					i_byAIType_Rw_II(*i_byAiType*),
					0(*i_byOutType_AITypeEnc*),
					0(*i_lrAIData_med*),
					0(*i_byMaxAngle_AITypeEnc*),
					0(*i_dwEncResolution*),
					ADR(i_pastStProgMonitoring^[2].i_lrRw_real)(*i_plrValue*));

			(*上下裁刀I组输入|*)
			i_pastStProgMonitoring^[1].i_wDiamMeasureUpCut:= awAI_DiamMeasure_UpCut[1,1];
			i_pastStProgMonitoring^[1].i_wDiamMeasureDnCut:= awAI_DiamMeasure_DnCut[1,1];

			(*上下裁刀II组输入|*)
			i_pastStProgMonitoring^[2].i_wDiamMeasureUpCut:= awAI_DiamMeasure_UpCut[2,1];
			i_pastStProgMonitoring^[2].i_wDiamMeasureDnCut:= awAI_DiamMeasure_DnCut[2,1];


			(*AB轴I组输入|*)
			i_pastStProgMonitoring^[1].i_wDiamMeasureAxisA:= awAI_DiamMeasure_AxisA[1,1];
			i_pastStProgMonitoring^[1].i_wDiamMeasureAxisB:= awAI_DiamMeasure_AxisB[1,1];

			(*AB轴II组输入|*)
			i_pastStProgMonitoring^[2].i_wDiamMeasureAxisA:= awAI_DiamMeasure_AxisA[2,1];
			i_pastStProgMonitoring^[2].i_wDiamMeasureAxisB:= awAI_DiamMeasure_AxisB[2,1];
		END_IF





		apbyAiFilterTms_UwRw[1]:=i_pbyAiFilterTms_UwRw_I;
		apbyAiFilterTms_UwRw[2]:=i_pbyAiFilterTms_UwRw_II;
		apbyAiFilterTms_IfOf[1]:=i_pbyAiFilterTms_IfOf_I;
		apbyAiFilterTms_IfOf[2]:=i_pbyAiFilterTms_IfOf_II;
		apbyAiFilterTms_DiaMeasure[1]:=i_pbyAiFilterTms_DiaMeasure_I;
		apbyAiFilterTms_DiaMeasure[2]:=i_pbyAiFilterTms_DiaMeasure_II;
		
		FOR iA:=1 TO 2 BY 1 DO
			(*
			/.放料\收料|
			/.*)
			(*检查放料\收料滤波平均次数的合法|*)
			IF apbyAiFilterTms_UwRw[iA]^<1 OR
				apbyAiFilterTms_UwRw[iA]^>50 THEN
				apbyAiFilterTms_UwRw[iA]^:= 1;
			END_IF

			(*放料\收料平均次数的计算|不足次数的时候按已经采集的数量进行平均|*)
			byAveTms_UwRw:= byAveTms_UwRw+1;
			IF byAveTms_UwRw>apbyAiFilterTms_UwRw[iA]^ THEN
				byAveTms_UwRw:= apbyAiFilterTms_UwRw[iA]^;
			END_IF

			alrSumVal_Uw[iA]:= 0;
			alrSumVal_Rw[iA]:= 0;
			FOR iN:=1 TO byAveTms_UwRw BY 1 DO
				alrSumVal_Uw[iA]:= alrSumVal_Uw[iA] + awAI_Uw[iA,iN];
				alrSumVal_Rw[iA]:= alrSumVal_Rw[iA] + awAI_Rw[iA,iN];
			END_FOR

			(*[0]的位置用来存放平均值|*)
			awAI_Uw[iA,0]:= LREAL_TO_WORD(alrSumVal_Uw[iA]/BYTE_TO_LREAL(byAveTms_UwRw));
			awAI_Rw[iA,0]:= LREAL_TO_WORD(alrSumVal_Rw[iA]/BYTE_TO_LREAL(byAveTms_UwRw));


			(*
			/.放牵\收牵|
			/.*)
			(*检查放牵\收牵滤波平均次数的合法|*)
			IF apbyAiFilterTms_IfOf[iA]^<1 OR
				apbyAiFilterTms_IfOf[iA]^>50 THEN
				apbyAiFilterTms_IfOf[iA]^:= 1;
			END_IF

			(*放牵\收牵平均次数的计算|不足次数的时候按已经采集的数量进行平均|*)
			byAveTms_IfOf:= byAveTms_IfOf+1;
			IF byAveTms_IfOf>apbyAiFilterTms_IfOf[iA]^ THEN
				byAveTms_IfOf:= apbyAiFilterTms_IfOf[iA]^;
			END_IF

			alrSumVal_If[iA]:= 0;
			alrSumVal_Of[iA]:= 0;
			FOR iN:=1 TO byAveTms_IfOf BY 1 DO
				alrSumVal_If[iA]:= alrSumVal_If[iA] + awAI_If[iA,iN];
				alrSumVal_Of[iA]:= alrSumVal_Of[iA] + awAI_Of[iA,iN];
			END_FOR

			(*[0]的位置用来存放平均值|*)
			awAI_If[iA,0]:= LREAL_TO_WORD(alrSumVal_If[iA]/BYTE_TO_LREAL(byAveTms_IfOf));
			awAI_Of[iA,0]:= LREAL_TO_WORD(alrSumVal_Of[iA]/BYTE_TO_LREAL(byAveTms_IfOf));


			(*
			/.卷径测量电位器|
			/.*)
			(*检查卷径测量滤波平均次数的合法|*)
			IF apbyAiFilterTms_DiaMeasure[iA]^<1 OR
				apbyAiFilterTms_DiaMeasure[iA]^>50 THEN
				apbyAiFilterTms_DiaMeasure[iA]^:= 1;
			END_IF

			(*开始对卷径电位器测量值进行平均|*)
			abyAveTms_DiaMeasure[iA]:= abyAveTms_DiaMeasure[iA]+1;
			IF abyAveTms_DiaMeasure[iA]>apbyAiFilterTms_DiaMeasure[iA]^ THEN
				abyAveTms_DiaMeasure[iA]:= apbyAiFilterTms_DiaMeasure[iA]^;
			END_IF

			alrSumVal_DiaMeasure_UpCut[iA]:= 0;
			alrSumVal_DiaMeasure_DnCut[iA]:= 0;
			(*2023.08.29.091238*)
			alrSumVal_DiaMeasure_AxisA[iA]:= 0;
			alrSumVal_DiaMeasure_AxisB[iA]:= 0;
			FOR iN:=1 TO abyAveTms_DiaMeasure[iA] BY 1 DO
				alrSumVal_DiaMeasure_UpCut[iA]:= alrSumVal_DiaMeasure_UpCut[iA]+awAI_DiamMeasure_UpCut[iA,iN];
				alrSumVal_DiaMeasure_DnCut[iA]:= alrSumVal_DiaMeasure_DnCut[iA]+awAI_DiamMeasure_DnCut[iA,iN];
				(*2023.08.29.091238*)
				alrSumVal_DiaMeasure_AxisA[iA]:= alrSumVal_DiaMeasure_AxisA[iA]+awAI_DiamMeasure_AxisA[iA,iN];
				alrSumVal_DiaMeasure_AxisB[iA]:= alrSumVal_DiaMeasure_AxisB[iA]+awAI_DiamMeasure_AxisB[iA,iN];
			END_FOR

			(*[0]的位置用来存放平均值|*)
			(*上裁|*)
			awAI_DiamMeasure_UpCut[iA,0]:= LREAL_TO_WORD(alrSumVal_DiaMeasure_UpCut[iA]/BYTE_TO_LREAL(abyAveTms_DiaMeasure[iA]));
			(*下裁|*)
			awAI_DiamMeasure_DnCut[iA,0]:= LREAL_TO_WORD(alrSumVal_DiaMeasure_DnCut[iA]/BYTE_TO_LREAL(abyAveTms_DiaMeasure[iA]));
			(*2023.08.29.091319*)
			(*A轴|*)
			awAI_DiamMeasure_AxisA[iA,0]:= LREAL_TO_WORD(alrSumVal_DiaMeasure_AxisA[iA]/BYTE_TO_LREAL(abyAveTms_DiaMeasure[iA]));
			(*B轴|*)
			awAI_DiamMeasure_AxisB[iA,0]:= LREAL_TO_WORD(alrSumVal_DiaMeasure_AxisB[iA]/BYTE_TO_LREAL(abyAveTms_DiaMeasure[iA]));
		END_FOR

		//2025.08.22.201744+
		//A系
		xBtn_ConfirmMedian_Uw_I := i_pbyBtn_ConfirmMedian_I^.0;
		xBtn_ConfirmMedian_Rw_I := i_pbyBtn_ConfirmMedian_I^.1;
		xBtn_ConfirmMedian_If_I := i_pbyBtn_ConfirmMedian_I^.2;
		xBtn_ConfirmMedian_Of_I := i_pbyBtn_ConfirmMedian_I^.3;
		//b系
		xBtn_ConfirmMedian_Uw_II := i_pbyBtn_ConfirmMedian_II^.0;
		xBtn_ConfirmMedian_Rw_II := i_pbyBtn_ConfirmMedian_II^.1;
		xBtn_ConfirmMedian_If_II := i_pbyBtn_ConfirmMedian_II^.2;
		xBtn_ConfirmMedian_Of_II := i_pbyBtn_ConfirmMedian_II^.3;
		
		apxBtn_ConfirmMedian_Uw[1]:= ADR(xBtn_ConfirmMedian_Uw_I);
		apxBtn_ConfirmMedian_Uw[2]:= ADR(xBtn_ConfirmMedian_Uw_II);
		apxBtn_ConfirmMedian_Rw[1]:= ADR(xBtn_ConfirmMedian_Rw_I);
		apxBtn_ConfirmMedian_Rw[2]:= ADR(xBtn_ConfirmMedian_Rw_II);
		apxBtn_ConfirmMedian_If[1]:= ADR(xBtn_ConfirmMedian_If_I);
		apxBtn_ConfirmMedian_If[2]:= ADR(xBtn_ConfirmMedian_If_II);
		apxBtn_ConfirmMedian_Of[1]:= ADR(xBtn_ConfirmMedian_Of_I);
		apxBtn_ConfirmMedian_Of[2]:= ADR(xBtn_ConfirmMedian_Of_II);
		
		aprAI_med_Uw[1]:= i_prAI_med_Uw_I;
		aprAI_med_Uw[2]:= i_prAI_med_Uw_II;
		aprAI_med_Rw[1]:= i_prAI_med_Rw_I;
		aprAI_med_Rw[2]:= i_prAI_med_Rw_II;
		aprAI_med_If[1]:= i_prAI_med_If_I;
		aprAI_med_If[2]:= i_prAI_med_If_II;
		aprAI_med_Of[1]:= i_prAI_med_Of_I;
		aprAI_med_Of[2]:= i_prAI_med_Of_II;
		axIsDebugMode[1]:= i_xIsDebugMode_I;
		axIsDebugMode[2]:= i_xIsDebugMode_II;
		FOR iA:=1 TO 2 BY 1 DO
			(*2022.8.31.111900  中位确认不需要调试模式限值-界面输入控件增加了点击条件-----start*)
			IF apxBtn_ConfirmMedian_Uw[iA]^ THEN
				apxBtn_ConfirmMedian_Uw[iA]^:= FALSE;

				(*2022.8.30.220303 修改*)
				IF iA=1 THEN
					byAITyp:=i_byAIType_Uw_I;
					IF byAITyp=6 THEN(*编码器方式|*)
						dwAiData:=i_dwAI_Uw_I;
					ELSE
						dwAiData:=awAI_Uw[iA,0];
					END_IF
				ELSE
					byAITyp:=i_byAIType_Uw_II;
					IF byAITyp=6 THEN(*编码器方式|*)
						dwAiData:=i_dwAI_Uw_II;
					ELSE
						dwAiData:=awAI_Uw[iA,0];
					END_IF
				END_IF
				dwAdr_lrValue:= aprAI_med_Uw[iA];
				KS_SetValueByAIType(
						dwAiData(*i_dwAIData*),
						byAITyp(*i_byAiType*),
						0(*i_byOutType_AITypeEnc*),
						0(*i_lrAIData_med*),
						0(*i_byMaxAngle_AITypeEnc*),
						0(*i_dwEncResolution*),
						dwAdr_lrValue(*i_plrValue*));
			END_IF

			IF apxBtn_ConfirmMedian_If[iA]^ THEN
				apxBtn_ConfirmMedian_If[iA]^:= FALSE;

				(*2022.8.30.220303 修改*)
				IF iA=1 THEN
					byAITyp:=i_byAIType_If_I;
					IF byAITyp=6 THEN(*编码器方式|*)
						dwAiData:=i_dwAI_If_I;
					ELSE
						dwAiData:=awAI_If[iA,0];
					END_IF
				ELSE
					byAITyp:=i_byAIType_If_II;
					IF byAITyp=6 THEN(*编码器方式|*)
						dwAiData:=i_dwAI_If_II;
					ELSE
						dwAiData:=awAI_If[iA,0];
					END_IF
				END_IF
				dwAdr_lrValue:= aprAI_med_If[iA];
				KS_SetValueByAIType(
						dwAiData(*i_dwAIData*),
						byAITyp(*i_byAiType*),
						0(*i_byOutType_AITypeEnc*),
						0(*i_lrAIData_med*),
						0(*i_byMaxAngle_AITypeEnc*),
						0(*i_dwEncResolution*),
						dwAdr_lrValue(*i_plrValue*));
			END_IF
			IF apxBtn_ConfirmMedian_Of[iA]^ THEN
				apxBtn_ConfirmMedian_Of[iA]^:= FALSE;

				(*2022.8.30.220303 修改*)
				IF iA=1 THEN
					byAITyp:=i_byAIType_Of_I;
					IF byAITyp=6 THEN(*编码器方式|*)
						dwAiData:=i_dwAI_Of_I;
					ELSE
						dwAiData:=awAI_Of[iA,0];
					END_IF
				ELSE
					byAITyp:=i_byAIType_Of_II;
					IF byAITyp=6 THEN(*编码器方式|*)
						dwAiData:=i_dwAI_Of_II;
					ELSE
						dwAiData:=awAI_Of[iA,0];
					END_IF
				END_IF
				dwAdr_lrValue:=aprAI_med_Of[iA];
				KS_SetValueByAIType(
						dwAiData(*i_dwAIData*),
						byAITyp(*i_byAiType*),
						0(*i_byOutType_AITypeEnc*),
						0(*i_lrAIData_med*),
						0(*i_byMaxAngle_AITypeEnc*),
						0(*i_dwEncResolution*),
						dwAdr_lrValue(*i_plrValue*));
			END_IF
			IF apxBtn_ConfirmMedian_Rw[iA]^ THEN
				apxBtn_ConfirmMedian_Rw[iA]^:= FALSE;

				(*2022.8.30.220303 修改*)
				IF iA=1 THEN
					byAITyp:=i_byAIType_Rw_I;
					IF byAITyp=6 THEN(*编码器方式|*)
						dwAiData:=i_dwAI_Rw_I;
					ELSE
						dwAiData:=awAI_Rw[iA,0];
					END_IF
				ELSE
					byAITyp:=i_byAIType_Rw_II;
					IF byAITyp=6 THEN(*编码器方式|*)
						dwAiData:=i_dwAI_Rw_II;
					ELSE
						dwAiData:=awAI_Rw[iA,0];
					END_IF
				END_IF
				dwAdr_lrValue:=aprAI_med_Rw[iA];
				KS_SetValueByAIType(
						dwAiData(*i_dwAIData*),
						byAITyp(*i_byAiType*),
						0(*i_byOutType_AITypeEnc*),
						0(*i_lrAIData_med*),
						0(*i_byMaxAngle_AITypeEnc*),
						0(*i_dwEncResolution*),
						dwAdr_lrValue(*i_plrValue*));
			END_IF
			(*2022.8.31.111900  中位确认不需要调试模式限值-界面输入控件增加了点击条件-----end*)

			IF axIsDebugMode[iA] THEN (*调试模式*)
				arAI_Uw[iA]:= 0;
				arAI_Rw[iA]:= 0;
				arAI_If[iA]:= 0;
				arAI_Of[iA]:= 0;
				
			ELSE(*生产模式*)
				(*放料摆臂输入|*)
				(*2022.8.30.220303 修改*)
				IF iA=1 THEN
					byAITyp:=i_byAIType_Uw_I;
					xNegPolarity:=i_xNegPolarity_Uw_I;
					dwEncResolution:=i_dwEncResolution_Uw_I;
					IF byAITyp=6 THEN(*编码器方式|*)
						dwAiData:=i_dwAI_Uw_I;
					ELSE
						dwAiData:=awAI_Uw[iA,0];
					END_IF
				ELSE
					byAITyp:=i_byAIType_Uw_II;
					xNegPolarity:=i_xNegPolarity_Uw_II;
					dwEncResolution:=i_dwEncResolution_Uw_II;
					IF byAITyp=6 THEN(*编码器方式|*)
						dwAiData:=i_dwAI_Uw_II;
					ELSE
						dwAiData:=awAI_Uw[iA,0];
					END_IF
				END_IF
(*				lrAIData_med:=LREAL_TO_DWORD(apstStGrpParam[iA]^.lrAI_SwingArm_Uw_med);*)
				lrAIData_med:=(aprAI_med_Uw[iA]^);(*2023.11.06.144626*)
				dwAdr_lrValue:=ADR(lrTempResult);
				KS_SetValueByAIType(
						dwAiData(*i_dwAIData*),
						byAITyp(*i_byAiType*),
						1(*i_byOutType_AITypeEnc*),
						lrAIData_med(*i_lrAIData_med*),
						byMaxAngle_AITypeEnc(*i_byMaxAngle_AITypeEnc*),
						dwEncResolution(*i_dwEncResolution*),
						dwAdr_lrValue(*i_plrValue*));
				IF xNegPolarity THEN
					lrTempResult:= -lrTempResult;
				END_IF
				arAI_Uw[iA]:= LREAL_TO_REAL(lrTempResult);


				(*2022.8.30.220303 修改*)
				IF iA=1 THEN
					byAITyp:=i_byAIType_If_I;
					xNegPolarity:=i_xNegPolarity_If_I;
					dwEncResolution:=i_dwEncResolution_If_I;
					IF byAITyp=6 THEN(*编码器方式|*)
						dwAiData:=i_dwAI_If_I;
					ELSE
						dwAiData:=awAI_If[iA,0];
					END_IF
				ELSE
					byAITyp:=i_byAIType_If_II;
					xNegPolarity:=i_xNegPolarity_If_II;
					dwEncResolution:=i_dwEncResolution_If_II;
					IF byAITyp=6 THEN(*编码器方式|*)
						dwAiData:=i_dwAI_If_II;
					ELSE
						dwAiData:=awAI_If[iA,0];
					END_IF
				END_IF
(*				lrAIData_med:=LREAL_TO_DWORD(apstStGrpParam[iA]^.lrAI_SwingArm_If_med);*)
				lrAIData_med:=(aprAI_med_If[iA]^);(*2023.11.06.144626*)
				dwAdr_lrValue:=ADR(lrTempResult);
				KS_SetValueByAIType(
						dwAiData(*i_dwAIData*),
						byAITyp(*i_byAiType*),
						1(*i_byOutType_AITypeEnc*),
						lrAIData_med(*i_lrAIData_med*),
						byMaxAngle_AITypeEnc(*i_byMaxAngle_AITypeEnc*),
						dwEncResolution(*i_dwEncResolution*),
						dwAdr_lrValue(*i_plrValue*));
				IF xNegPolarity THEN
					lrTempResult:= -lrTempResult;
				END_IF
				arAI_If[iA]:= LREAL_TO_REAL(lrTempResult);

				(*2022.8.30.220303 修改*)
				IF iA=1 THEN
					byAITyp:=i_byAIType_Of_I;
					xNegPolarity:=i_xNegPolarity_Of_I;
					dwEncResolution:=i_dwEncResolution_Of_I;
					IF byAITyp=6 THEN(*编码器方式|*)
						dwAiData:=i_dwAI_Of_I;
					ELSE
						dwAiData:=awAI_Of[iA,0];
					END_IF
				ELSE
					byAITyp:=i_byAIType_Of_II;
					xNegPolarity:=i_xNegPolarity_Of_II;
					dwEncResolution:=i_dwEncResolution_Of_II;
					IF byAITyp=6 THEN(*编码器方式|*)
						dwAiData:=i_dwAI_Of_II;
					ELSE
						dwAiData:=awAI_Of[iA,0];
					END_IF
				END_IF
(*				lrAIData_med:=LREAL_TO_DWORD(apstStGrpParam[iA]^.lrAI_SwingArm_Of_med);*)
				lrAIData_med:=(aprAI_med_Of[iA]^);(*2023.11.06.144626*)
				dwAdr_lrValue:=ADR(lrTempResult);
				KS_SetValueByAIType(
						dwAiData(*i_dwAIData*),
						byAITyp(*i_byAiType*),
						1(*i_byOutType_AITypeEnc*),
						lrAIData_med(*i_lrAIData_med*),
						byMaxAngle_AITypeEnc(*i_byMaxAngle_AITypeEnc*),
						dwEncResolution(*i_dwEncResolution*),
						dwAdr_lrValue(*i_plrValue*));
				IF xNegPolarity THEN
					lrTempResult:= -lrTempResult;
				END_IF
				arAI_Of[iA]:= LREAL_TO_REAL(lrTempResult);

				(*2022.8.30.220303 修改*)
				IF iA=1 THEN
					byAITyp:=i_byAIType_Rw_I;
					xNegPolarity:=i_xNegPolarity_Rw_I;
					dwEncResolution:=i_dwEncResolution_Rw_I;
					IF byAITyp=6 THEN(*编码器方式|*)
						dwAiData:=i_dwAI_Rw_I;
					ELSE
						dwAiData:=awAI_Rw[iA,0];
					END_IF
				ELSE
					byAITyp:=i_byAIType_Rw_II;
					xNegPolarity:=i_xNegPolarity_Rw_II;
					dwEncResolution:=i_dwEncResolution_Rw_II;
					IF byAITyp=6 THEN(*编码器方式|*)
						dwAiData:=i_dwAI_Rw_II;
					ELSE
						dwAiData:=awAI_Rw[iA,0];
					END_IF
				END_IF
(*				lrAIData_med:=LREAL_TO_DWORD(apstStGrpParam[iA]^.lrAI_SwingArm_Rw_med);*)
				lrAIData_med:=(aprAI_med_Rw[iA]^);(*2023.11.06.144626*)
				dwAdr_lrValue:=ADR(lrTempResult);
				KS_SetValueByAIType(
						dwAiData(*i_dwAIData*),
						byAITyp(*i_byAiType*),
						1(*i_byOutType_AITypeEnc*),
						lrAIData_med(*i_lrAIData_med*),
						byMaxAngle_AITypeEnc(*i_byMaxAngle_AITypeEnc*),
						dwEncResolution(*i_dwEncResolution*),
						dwAdr_lrValue(*i_plrValue*));
				IF xNegPolarity THEN
					lrTempResult:= -lrTempResult;
				END_IF
				arAI_Rw[iA]:= LREAL_TO_REAL(lrTempResult);
			END_IF


			(*2019.3.19.110338|要求在任何模式下都读取卷径电压值|*)
			(*卷径测量电位器输入|*)
			IF iA=1 THEN
				byDiamMeasureTypeId:= i_byDiamMeasureTypeId_I;
				wUwRwAxisProf:= i_wUwRwAxisProf_I;
				xCutterOnTop_Uw:= i_xCutterOnTop_Uw_I;
			ELSE
				byDiamMeasureTypeId:= i_byDiamMeasureTypeId_II;
				wUwRwAxisProf:= i_wUwRwAxisProf_II;
				xCutterOnTop_Uw:= i_xCutterOnTop_Uw_II;
			END_IF
			
			IF byDiamMeasureTypeId=3 THEN(*超声波方式|ab轴单独*)
				IF wUwRwAxisProf.0 THEN(*当前轴a轴获取b轴的超声波数据*)
					IF iA=1 THEN
						KS_QueryRangeByAType(i_byAIType_DiamMeasure_Axis_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
					ELSE
						KS_QueryRangeByAType(i_byAIType_DiamMeasure_Axis_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
					END_IF
					arAI_DiamMeasure_Uw_cur[iA]:= LREAL_TO_REAL(KSIO_DA(WORD_TO_INT(awAI_DiamMeasure_AxisB[iA,0]), lrN_min, lrN_max, diN_min, diN_max));
				ELSE(*当前轴B轴获取A轴的超声波数据*)
					IF iA=1 THEN
						KS_QueryRangeByAType(i_byAIType_DiamMeasure_Axis_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
					ELSE
						KS_QueryRangeByAType(i_byAIType_DiamMeasure_Axis_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
					END_IF
					arAI_DiamMeasure_Uw_cur[iA]:= LREAL_TO_REAL(KSIO_DA(WORD_TO_INT(awAI_DiamMeasure_AxisA[iA,0]), lrN_min, lrN_max, diN_min, diN_max));
				END_IF
			ELSE(*电位器或者编码器*)
				IF xCutterOnTop_Uw THEN(*上裁|*)
					IF iA=1 THEN
						KS_QueryRangeByAType(i_byAIType_DiamMeasure_UpCut_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
					ELSE
						KS_QueryRangeByAType(i_byAIType_DiamMeasure_UpCut_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
					END_IF
					arAI_DiamMeasure_Uw_cur[iA]:= LREAL_TO_REAL(KSIO_DA(WORD_TO_INT(awAI_DiamMeasure_UpCut[iA,0]), lrN_min, lrN_max, diN_min, diN_max));
				ELSE(*下裁|*)
					IF iA=1 THEN
						KS_QueryRangeByAType(i_byAIType_DiamMeasure_DnCut_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
					ELSE
						KS_QueryRangeByAType(i_byAIType_DiamMeasure_DnCut_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
					END_IF
					arAI_DiamMeasure_Uw_cur[iA]:= LREAL_TO_REAL(KSIO_DA(WORD_TO_INT(awAI_DiamMeasure_DnCut[iA,0]), lrN_min, lrN_max, diN_min, diN_max));
				END_IF
			END_IF
			IF iA=1 THEN
				o_rAI_DiamMeasure_Uw_Cur_I:= arAI_DiamMeasure_Uw_cur[iA];
			ELSE
				o_rAI_DiamMeasure_Uw_Cur_II:= arAI_DiamMeasure_Uw_cur[iA];				
			END_IF
			(*2018.11.22.102945\增加监控输出点|*)
			IF i_pastStProgMonitoring<>0 THEN
				i_pastStProgMonitoring^[iA].i_lrUw_cur:= arAI_Uw[iA];
				i_pastStProgMonitoring^[iA].i_lrRw_cur:= arAI_Rw[iA];
				i_pastStProgMonitoring^[iA].i_lrIf_cur:= arAI_If[iA];
				i_pastStProgMonitoring^[iA].i_lrOf_cur:= arAI_Of[iA];

				(*上裁|*)
				IF iA=1 THEN
					KS_QueryRangeByAType(i_byAIType_DiamMeasure_UpCut_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				ELSE
					KS_QueryRangeByAType(i_byAIType_DiamMeasure_UpCut_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				END_IF
				i_pastStProgMonitoring^[iA].i_lrDiamMeasureUpCut:= KSIO_DA(WORD_TO_INT(awAI_DiamMeasure_UpCut[iA,0]), lrN_min, lrN_max, diN_min, diN_max);

				(*下裁|*)
				IF iA=1 THEN
					KS_QueryRangeByAType(i_byAIType_DiamMeasure_DnCut_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				ELSE
					KS_QueryRangeByAType(i_byAIType_DiamMeasure_DnCut_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				END_IF
				i_pastStProgMonitoring^[iA].i_lrDiamMeasureDnCut:= KSIO_DA(WORD_TO_INT(awAI_DiamMeasure_DnCut[iA,0]), lrN_min, lrN_max, diN_min, diN_max);


				(*A轴|*)
				IF iA=1 THEN
					KS_QueryRangeByAType(i_byAIType_DiamMeasure_Axis_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				ELSE
					KS_QueryRangeByAType(i_byAIType_DiamMeasure_Axis_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				END_IF
				i_pastStProgMonitoring^[iA].i_lrDiamMeasureAxisA:= KSIO_DA(WORD_TO_INT(awAI_DiamMeasure_AxisA[iA,0]), lrN_min, lrN_max, diN_min, diN_max);

				(*b轴|*)
				IF iA=1 THEN
					KS_QueryRangeByAType(i_byAIType_DiamMeasure_Axis_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				ELSE
					KS_QueryRangeByAType(i_byAIType_DiamMeasure_Axis_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				END_IF
				i_pastStProgMonitoring^[iA].i_lrDiamMeasureAxisB:= KSIO_DA(WORD_TO_INT(awAI_DiamMeasure_AxisB[iA,0]), lrN_min, lrN_max, diN_min, diN_max);
			END_IF

		END_FOR

		(*2025.08.11.202625*)
		o_rAI_Uw_I:= arAI_Uw[1];
		o_rAI_Uw_II:= arAI_Uw[2];
		o_rAI_Rw_I:= arAI_Rw[1];
		o_rAI_Rw_II:= arAI_Rw[2];
		o_rAI_If_I:= arAI_If[1];
		o_rAI_If_II:= arAI_If[2];
		o_rAI_Of_I:= arAI_Of[1];
		o_rAI_Of_II:= arAI_Of[2];
			
		//2025.08.22.202236 写入
		//A系
		i_pbyBtn_ConfirmMedian_I^.0 := xBtn_ConfirmMedian_Uw_I;
		i_pbyBtn_ConfirmMedian_I^.1 := xBtn_ConfirmMedian_Rw_I;
		i_pbyBtn_ConfirmMedian_I^.2 := xBtn_ConfirmMedian_If_I;
		i_pbyBtn_ConfirmMedian_I^.3 := xBtn_ConfirmMedian_Of_I;
		//b系
		i_pbyBtn_ConfirmMedian_II^.0 := xBtn_ConfirmMedian_Uw_II;
		i_pbyBtn_ConfirmMedian_II^.1 := xBtn_ConfirmMedian_Rw_II;
		i_pbyBtn_ConfirmMedian_II^.2 := xBtn_ConfirmMedian_If_II;
		i_pbyBtn_ConfirmMedian_II^.3 := xBtn_ConfirmMedian_Of_II;
	END_IF


	(*
	/.han.dp| 2018.3.27.163945|
	/.使能输出处理|
	/.*)
	IF i_xAO_Enable THEN (*使能输出处理*)
		IF i_xIsDualUwRw THEN
			IF i_xAsOneMachine THEN(*当1台整机开*)
				KS_QueryRangeByAType(i_byAOType_Uw_AxisA_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				o_wAO_Inverter_Uw_AxisA_I:= DINT_TO_WORD(KSIO_AD(i_lrAO_Inverter_Uw_AxisA_I, lrN_min, lrN_max, diN_min, diN_max));

				(*放料A轴频率监控|2019.9.5.164828_*)
				IF lrN_max<>lrN_min THEN
					IF ABS(lrN_max)=ABS(lrN_min) THEN
						lrFreq_Uw_AxisA_I:= ABS(i_lrAO_Inverter_Uw_AxisA_I) / ABS(lrN_max) * i_lrUpperFreq_Uw_I;
					ELSE
						lrFreq_Uw_AxisA_I:= ABS(i_lrAO_Inverter_Uw_AxisA_I-lrN_min) / ABS(lrN_max-lrN_min) * i_lrUpperFreq_Uw_I;
					END_IF
				ELSE
					lrFreq_Uw_AxisA_I:= -1220;
				END_IF

				KS_QueryRangeByAType(i_byAOType_Uw_AxisB_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				o_wAO_Inverter_Uw_AxisB_I:= DINT_TO_WORD(KSIO_AD(i_lrAO_Inverter_Uw_AxisB_I, lrN_min, lrN_max, diN_min, diN_max));

				(*放料B轴频率监控|2019.9.5.164916_*)
				IF lrN_max<>lrN_min THEN
					IF ABS(lrN_max)=ABS(lrN_min) THEN
						lrFreq_Uw_AxisB_I:= ABS(i_lrAO_Inverter_Uw_AxisB_I) / ABS(lrN_max) * i_lrUpperFreq_Uw_I;
					ELSE
						lrFreq_Uw_AxisB_I:= ABS(i_lrAO_Inverter_Uw_AxisB_I-lrN_min) / ABS(lrN_max-lrN_min) * i_lrUpperFreq_Uw_I;
					END_IF
				ELSE
					lrFreq_Uw_AxisB_I:= -1220;
				END_IF


				o_wAO_Inverter_Rw_AxisA_I:= 0;
				o_wAO_Inverter_Rw_AxisB_I:= 0;


				(*--------------------------------------------锥度_|*)
				o_wAO_Uw_Taper_II:= 0;(*II组的放料锥度清零@2019.8.2.163024|*)
				o_wAO_Rw_Taper_I:= 0;
				o_wAO_If_Taper_II:= 0;(*II组的放牵锥度清零@2019.8.2.163024|*)
				o_wAO_Of_Taper_I:= 0;(*I组的收牵锥度清零@2019.8.2.163024|*)
				(*--------------------------------------------_锥度|*)


				(*A系速度表\2018.6.10.150915|*)
				(*当前速度/最大速度*(lrN_max-lrN_min)+lrN_min|*)
				KS_QueryRangeByAType(i_byAOType_Velocity_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				lrTmp:= 0;
				IF i_rVel_Max_I<>0 THEN
					lrTmp:= (i_rVel_Cur_I/i_rVel_Max_I)*(lrN_max-lrN_min)+lrN_min;
				END_IF
				lrTmpVel_Volt:= lrTmp;(*2018.11.22.121719|*)
				o_wAO_Velocity_I:= DINT_TO_WORD(KSIO_AD(lrTmp, lrN_min, lrN_max, diN_min, diN_max));

				(*A扩展线速度表|*)
				KS_QueryRangeByAType(i_byAOType_VelocityEx_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				lrTmp:= 0;
				IF i_rVel_Max_I<>0 THEN
					lrTmp:= (i_rVel_Cur_I/i_rVel_Max_I)*(lrN_max-lrN_min)+lrN_min;
				END_IF
				o_wAO_VelocityEx_I:= DINT_TO_WORD(KSIO_AD(lrTmp, lrN_min, lrN_max, diN_min, diN_max));

				(*2018.11.22.112018\扩展显示|*)
				IF i_pastStProgMonitoring<>0 THEN
					(*线速度|*)
					i_pastStProgMonitoring^[1].o_lrVelocity_Vol:= lrTmpVel_Volt;
					i_pastStProgMonitoring^[1].o_wVelocity_cur:= o_wAO_Velocity_I;

					(*放A|*)
					i_pastStProgMonitoring^[1].o_wUwAxisA_cur:= o_wAO_Inverter_Uw_AxisA_I;
					i_pastStProgMonitoring^[1].o_lrUwAxisA_Vol:= i_lrAO_Inverter_Uw_AxisA_I;
					i_pastStProgMonitoring^[1].o_lrUwAxisA_Feq:= lrFreq_Uw_AxisA_I;(*2019.4.2.131556|*)

					(*放B|*)
					i_pastStProgMonitoring^[1].o_wUwAxisB_cur:= o_wAO_Inverter_Uw_AxisB_I;
					i_pastStProgMonitoring^[1].o_lrUwAxisB_Vol:= i_lrAO_Inverter_Uw_AxisB_I;
					i_pastStProgMonitoring^[1].o_lrUwAxisB_Feq:= lrFreq_Uw_AxisB_I;(*2019.4.2.131556|*)

					(*收A|*)
					i_pastStProgMonitoring^[1].o_wRwAxisA_cur:= o_wAO_Inverter_Rw_AxisA_I;
					i_pastStProgMonitoring^[1].o_lrRwAxisA_Vol:= 0;
					i_pastStProgMonitoring^[1].o_lrRwAxisA_Feq:= 0;(*2019.4.2.131640|*)

					(*收B|*)
					i_pastStProgMonitoring^[1].o_wRwAxisB_cur:= o_wAO_Inverter_Rw_AxisB_I;
					i_pastStProgMonitoring^[1].o_lrRwAxisB_Vol:= 0;
					i_pastStProgMonitoring^[1].o_lrRwAxisB_Feq:= 0;(*2019.4.2.131634|*)

					(*锥度|*)
					i_pastStProgMonitoring^[1].o_wTaper_cur:= o_wAO_Rw_Taper_I;
					i_pastStProgMonitoring^[1].o_lrTaper_Vol:= 0;
				END_IF


				o_wAO_Inverter_Uw_AxisA_II:= 0;
				o_wAO_Inverter_Uw_AxisB_II:= 0;

				KS_QueryRangeByAType(i_byAOType_Uw_AxisA_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				o_wAO_Inverter_Rw_AxisA_II:= DINT_TO_WORD(KSIO_AD(i_lrAO_Inverter_Rw_AxisA_I, lrN_min, lrN_max, diN_min, diN_max));

				(*收料A轴频率监控|2019.9.5.170858_*)
				IF lrN_max<>lrN_min THEN
					IF ABS(lrN_max)=ABS(lrN_min) THEN
						lrFreq_Rw_AxisA_II:= ABS(i_lrAO_Inverter_Rw_AxisA_I) / ABS(lrN_max) * i_lrUpperFreq_Rw_I;
					ELSE
						lrFreq_Rw_AxisA_II:= ABS(i_lrAO_Inverter_Rw_AxisA_I-lrN_min) / ABS(lrN_max-lrN_min) * i_lrUpperFreq_Rw_I;
					END_IF
				ELSE
					lrFreq_Rw_AxisA_II:= -1220;
				END_IF

				KS_QueryRangeByAType(i_byAOType_Uw_AxisB_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				o_wAO_Inverter_Rw_AxisB_II:= DINT_TO_WORD(KSIO_AD(i_lrAO_Inverter_Rw_AxisB_I, lrN_min, lrN_max, diN_min, diN_max));

				(*收料B轴频率监控|2019.9.5.171029_*)
				IF lrN_max<>lrN_min THEN
					IF ABS(lrN_max)=ABS(lrN_min) THEN
						lrFreq_Rw_AxisB_II:= ABS(i_lrAO_Inverter_Rw_AxisB_I) / ABS(lrN_max) * i_lrUpperFreq_Rw_I;
					ELSE
						lrFreq_Rw_AxisB_II:= ABS(i_lrAO_Inverter_Rw_AxisB_I-lrN_min) / ABS(lrN_max-lrN_min) * i_lrUpperFreq_Rw_I;
					END_IF
				ELSE
					lrFreq_Rw_AxisB_II:= -1220;
				END_IF


				(*--------------------------------------------锥度_|*)
				(*2019.8.2|锥度控制增加多项控制_|*)
				(*放料|*)
				KS_QueryRangeByAType(i_byAOType_Uw_Taper_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));(*放料用A系|*)
				lrTmpTaper_Uw:= (i_lrTaper_Cur_Uw_I/100.0)*(lrN_max-lrN_min)+lrN_min;
				o_wAO_Uw_Taper_I:= DINT_TO_WORD(KSIO_AD(lrTmpTaper_Uw, lrN_min, lrN_max, diN_min, diN_max));(*放料张力|*)
				(*收料|*)
				KS_QueryRangeByAType(i_byAOType_Rw_Taper_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));(*收料用B系|*)
				lrTmpTaper_Rw:= (i_lrTaper_Cur_Rw_I/100.0)*(lrN_max-lrN_min)+lrN_min;(*2018.11.22.133043|*)
				o_wAO_Rw_Taper_II:= DINT_TO_WORD(KSIO_AD(lrTmpTaper_Rw, lrN_min, lrN_max, diN_min, diN_max));(*收料张力|*)
				(*放牵|*)
				KS_QueryRangeByAType(i_byAOType_If_Taper_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));(*放牵用A系|*)
				lrTmpTaper_If:= (i_lrTaper_Cur_If_I/100.0)*(lrN_max-lrN_min)+lrN_min;
				o_wAO_If_Taper_I:= DINT_TO_WORD(KSIO_AD(lrTmpTaper_If, lrN_min, lrN_max, diN_min, diN_max));
				(*收牵|*)
				KS_QueryRangeByAType(i_byAOType_Of_Taper_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));(*收牵用B系|*)
				lrTmpTaper_Of:= (i_lrTaper_Cur_Of_I/100.0)*(lrN_max-lrN_min)+lrN_min;
				o_wAO_Of_Taper_II:= DINT_TO_WORD(KSIO_AD(lrTmpTaper_Of, lrN_min, lrN_max, diN_min, diN_max));
				(*--------------------------------------------_锥度|*)

				(*线速度表输出|*)
				o_wAO_Velocity_II:= 0;
				o_wAO_VelocityEx_II:= 0;


				(*2018.11.22.112018\扩展显示|*)
				IF i_pastStProgMonitoring<>0 THEN
					(*线速度|*)
					i_pastStProgMonitoring^[2].o_lrVelocity_Vol:= 0;
					i_pastStProgMonitoring^[2].o_wVelocity_cur:= o_wAO_Velocity_II;

					(*放A|*)
					i_pastStProgMonitoring^[2].o_wUwAxisA_cur:= o_wAO_Inverter_Uw_AxisA_II;
					i_pastStProgMonitoring^[2].o_lrUwAxisA_Vol:= 0;
					i_pastStProgMonitoring^[2].o_lrUwAxisA_Feq:= 0;(*2019.4.2.131908|*)

					(*放B|*)
					i_pastStProgMonitoring^[2].o_wUwAxisB_cur:= o_wAO_Inverter_Uw_AxisB_II;
					i_pastStProgMonitoring^[2].o_lrUwAxisB_Vol:= 0;
					i_pastStProgMonitoring^[2].o_lrUwAxisB_Feq:= 0;(*2019.4.2.131908|*)

					(*收A|*)
					i_pastStProgMonitoring^[2].o_wRwAxisA_cur:= o_wAO_Inverter_Rw_AxisA_II;
					i_pastStProgMonitoring^[2].o_lrRwAxisA_Vol:= i_lrAO_Inverter_Rw_AxisA_I;
					i_pastStProgMonitoring^[2].o_lrUwAxisA_Feq:= lrFreq_Rw_AxisA_II;(*2019.4.2.131908|*)

					(*收B|*)
					i_pastStProgMonitoring^[2].o_wRwAxisB_cur:= o_wAO_Inverter_Rw_AxisB_II;
					i_pastStProgMonitoring^[2].o_lrRwAxisB_Vol:= i_lrAO_Inverter_Rw_AxisB_I;
					i_pastStProgMonitoring^[2].o_lrUwAxisB_Feq:= lrFreq_Rw_AxisB_II;(*2019.4.2.131908|*)

					(*锥度|*)
					i_pastStProgMonitoring^[2].o_lrTaper_Vol:= lrTmpTaper_Rw;
					i_pastStProgMonitoring^[2].o_wTaper_cur:= o_wAO_Rw_Taper_II;
				END_IF
			ELSE
				(*A|*)
				KS_QueryRangeByAType(i_byAOType_Uw_AxisA_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				o_wAO_Inverter_Uw_AxisA_I:= DINT_TO_WORD(KSIO_AD(i_lrAO_Inverter_Uw_AxisA_I, lrN_min, lrN_max, diN_min, diN_max));

				(*放料A轴频率监控|2019.9.5.164008_*)
				IF lrN_max<>lrN_min THEN
					IF ABS(lrN_max)=ABS(lrN_min) THEN(*2019.9.5.163350_|按带方向对待|参考上限频率|*)
						lrFreq_Uw_AxisA_I:= ABS(i_lrAO_Inverter_Uw_AxisA_I) / ABS(lrN_max) * i_lrUpperFreq_Uw_I;
					ELSE
						lrFreq_Uw_AxisA_I:= ABS(i_lrAO_Inverter_Uw_AxisA_I-lrN_min) / ABS(lrN_max-lrN_min) * i_lrUpperFreq_Uw_I;
					END_IF
				ELSE
					lrFreq_Uw_AxisA_I:= -1220;
				END_IF

				KS_QueryRangeByAType(i_byAOType_Uw_AxisB_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				o_wAO_Inverter_Uw_AxisB_I:= DINT_TO_WORD(KSIO_AD(i_lrAO_Inverter_Uw_AxisB_I, lrN_min, lrN_max, diN_min, diN_max));

				(*放料B轴频率监控|2019.9.5.164003_*)
				IF lrN_max<>lrN_min THEN
					IF ABS(lrN_max)=ABS(lrN_min) THEN
						lrFreq_Uw_AxisB_I:= ABS(i_lrAO_Inverter_Uw_AxisB_I) / ABS(lrN_max) * i_lrUpperFreq_Uw_I;
					ELSE
						lrFreq_Uw_AxisB_I:= ABS(i_lrAO_Inverter_Uw_AxisB_I-lrN_min) / ABS(lrN_max-lrN_min) * i_lrUpperFreq_Uw_I;
					END_IF
				ELSE
					lrFreq_Uw_AxisB_I:= -1220;
				END_IF


				KS_QueryRangeByAType(i_byAOType_Rw_AxisA_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				o_wAO_Inverter_Rw_AxisA_I:= DINT_TO_WORD(KSIO_AD(i_lrAO_Inverter_Rw_AxisA_I, lrN_min, lrN_max, diN_min, diN_max));

				(*收料A轴频率监控|2019.9.5.164036_*)
				IF lrN_max<>lrN_min THEN
					IF ABS(lrN_max)=ABS(lrN_min) THEN
						lrFreq_Rw_AxisA_I:= ABS(i_lrAO_Inverter_Rw_AxisA_I) / ABS(lrN_max) * i_lrUpperFreq_Rw_I;
					ELSE
						lrFreq_Rw_AxisA_I:= ABS(i_lrAO_Inverter_Rw_AxisA_I-lrN_min) / ABS(lrN_max-lrN_min) * i_lrUpperFreq_Rw_I;
					END_IF
				ELSE
					lrFreq_Rw_AxisA_I:= -1220;
				END_IF


				KS_QueryRangeByAType(i_byAOType_Rw_AxisB_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				o_wAO_Inverter_Rw_AxisB_I:= DINT_TO_WORD(KSIO_AD(i_lrAO_Inverter_Rw_AxisB_I, lrN_min, lrN_max, diN_min, diN_max));

				(*收料B轴频率监控|2019.9.5.164205_*)
				IF lrN_max<>lrN_min THEN
					IF ABS(lrN_max)=ABS(lrN_min) THEN
						lrFreq_Rw_AxisB_I:= ABS(i_lrAO_Inverter_Rw_AxisB_I) / ABS(lrN_max) * i_lrUpperFreq_Rw_I;
					ELSE
						lrFreq_Rw_AxisB_I:= ABS(i_lrAO_Inverter_Rw_AxisB_I-lrN_min) / ABS(lrN_max-lrN_min) * i_lrUpperFreq_Rw_I;
					END_IF
				ELSE
					lrFreq_Rw_AxisB_I:= -1220;
				END_IF


				(*--------------------------------------------A锥度_|*)
				(*放料|*)
				KS_QueryRangeByAType(i_byAOType_Uw_Taper_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				lrTmpTaper_Uw:= (i_lrTaper_Cur_Uw_I/100.0)*(lrN_max-lrN_min)+lrN_min;
				o_wAO_Uw_Taper_I:= DINT_TO_WORD(KSIO_AD(lrTmpTaper_Uw, lrN_min, lrN_max, diN_min, diN_max));
				(*收料|*)
				KS_QueryRangeByAType(i_byAOType_Rw_Taper_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				lrTmpTaper_Rw:= (i_lrTaper_Cur_Rw_I/100.0)*(lrN_max-lrN_min)+lrN_min;
				o_wAO_Rw_Taper_I:= DINT_TO_WORD(KSIO_AD(lrTmpTaper_Rw, lrN_min, lrN_max, diN_min, diN_max));
				(*放牵|*)
				KS_QueryRangeByAType(i_byAOType_If_Taper_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				lrTmpTaper_If:= (i_lrTaper_Cur_If_I/100.0)*(lrN_max-lrN_min)+lrN_min;
				o_wAO_If_Taper_I:= DINT_TO_WORD(KSIO_AD(lrTmpTaper_If, lrN_min, lrN_max, diN_min, diN_max));
				(*收牵|*)
				KS_QueryRangeByAType(i_byAOType_Of_Taper_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				lrTmpTaper_Of:= (i_lrTaper_Cur_Of_I/100.0)*(lrN_max-lrN_min)+lrN_min;
				o_wAO_Of_Taper_I:= DINT_TO_WORD(KSIO_AD(lrTmpTaper_Of, lrN_min, lrN_max, diN_min, diN_max));
				(*--------------------------------------------_A锥度|*)

				(*A系速度表\2018.6.10.150915|*)
				(*当前速度/最大速度*(lrN_max-lrN_min)+lrN_min|*)
				KS_QueryRangeByAType(i_byAOType_Velocity_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				lrTmp:= 0;
				IF i_rVel_Max_I<>0 THEN
					lrTmp:= (i_rVel_Cur_I/i_rVel_Max_I)*(lrN_max-lrN_min)+lrN_min;
				END_IF
				lrTmpVel_Volt:= lrTmp;(*2018.11.22.120710|*)
				o_wAO_Velocity_I:= DINT_TO_WORD(KSIO_AD(lrTmp, lrN_min, lrN_max, diN_min, diN_max));

				(*2018.7.15.102117\A扩展线速度表|*)
				KS_QueryRangeByAType(i_byAOType_VelocityEx_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				lrTmp:= 0;
				IF i_rVel_Max_I<>0 THEN
					lrTmp:= (i_rVel_Cur_I/i_rVel_Max_I)*(lrN_max-lrN_min)+lrN_min;
				END_IF
				o_wAO_VelocityEx_I:= DINT_TO_WORD(KSIO_AD(lrTmp, lrN_min, lrN_max, diN_min, diN_max));

				(*2018.11.22.112018\扩展监控输出|*)
				IF i_pastStProgMonitoring<>0 THEN
					(*线速度|*)
					i_pastStProgMonitoring^[1].o_lrVelocity_Vol:= lrTmpVel_Volt;
					i_pastStProgMonitoring^[1].o_wVelocity_cur:= o_wAO_Velocity_I;

					(*放A|*)
					i_pastStProgMonitoring^[1].o_wUwAxisA_cur:= o_wAO_Inverter_Uw_AxisA_I;
					i_pastStProgMonitoring^[1].o_lrUwAxisA_Vol:= i_lrAO_Inverter_Uw_AxisA_I;
					i_pastStProgMonitoring^[1].o_lrUwAxisA_Feq:= lrFreq_Uw_AxisA_I;(*2019.4.2.125855|*)

					(*放B|*)
					i_pastStProgMonitoring^[1].o_wUwAxisB_cur:= o_wAO_Inverter_Uw_AxisB_I;
					i_pastStProgMonitoring^[1].o_lrUwAxisB_Vol:= i_lrAO_Inverter_Uw_AxisB_I;
					i_pastStProgMonitoring^[1].o_lrUwAxisB_Feq:= lrFreq_Uw_AxisB_I;(*2019.4.2.125855|*)

					(*收A|*)
					i_pastStProgMonitoring^[1].o_wRwAxisA_cur:= o_wAO_Inverter_Rw_AxisA_I;
					i_pastStProgMonitoring^[1].o_lrRwAxisA_Vol:= i_lrAO_Inverter_Rw_AxisA_I;
					i_pastStProgMonitoring^[1].o_lrRwAxisA_Feq:= lrFreq_Rw_AxisA_I;(*2019.4.2.125855|*)

					(*收B|*)
					i_pastStProgMonitoring^[1].o_wRwAxisB_cur:= o_wAO_Inverter_Rw_AxisB_I;
					i_pastStProgMonitoring^[1].o_lrRwAxisB_Vol:= i_lrAO_Inverter_Rw_AxisB_I;
					i_pastStProgMonitoring^[1].o_lrRwAxisB_Feq:= lrFreq_Rw_AxisB_I;(*2019.4.2.125855|*)

					(*锥度|*)
					i_pastStProgMonitoring^[1].o_lrTaper_Vol:= lrTmpTaper_Rw;
					i_pastStProgMonitoring^[1].o_wTaper_cur:= o_wAO_Rw_Taper_I;
				END_IF


				(*B|*)
				KS_QueryRangeByAType(i_byAOType_Uw_AxisA_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				o_wAO_Inverter_Uw_AxisA_II:= DINT_TO_WORD(KSIO_AD(i_lrAO_Inverter_Uw_AxisA_II, lrN_min, lrN_max, diN_min, diN_max));

				(*B系放料A轴频率监控|2019.9.5.164442_*)
				IF lrN_max<>lrN_min THEN
					IF ABS(lrN_max)=ABS(lrN_min) THEN
						lrFreq_Uw_AxisA_II:= ABS(i_lrAO_Inverter_Uw_AxisA_II) / ABS(lrN_max) * i_lrUpperFreq_Uw_II;
					ELSE
						lrFreq_Uw_AxisA_II:= ABS(i_lrAO_Inverter_Uw_AxisA_II-lrN_min) / ABS(lrN_max-lrN_min) * i_lrUpperFreq_Uw_II;
					END_IF
				ELSE
					lrFreq_Uw_AxisA_II:= -1220;
				END_IF

				KS_QueryRangeByAType(i_byAOType_Uw_AxisB_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				o_wAO_Inverter_Uw_AxisB_II:= DINT_TO_WORD(KSIO_AD(i_lrAO_Inverter_Uw_AxisB_II, lrN_min, lrN_max, diN_min, diN_max));

				(*B系放料B轴频率监控|2019.9.5.164504_*)
				IF lrN_max<>lrN_min THEN
					IF ABS(lrN_max)=ABS(lrN_min) THEN
						lrFreq_Uw_AxisB_II:= ABS(i_lrAO_Inverter_Uw_AxisB_II) / ABS(lrN_max) * i_lrUpperFreq_Uw_II;
					ELSE
						lrFreq_Uw_AxisB_II:= ABS(i_lrAO_Inverter_Uw_AxisB_II-lrN_min) / ABS(lrN_max-lrN_min) * i_lrUpperFreq_Uw_II;
					END_IF
				ELSE
					lrFreq_Uw_AxisB_II:= -1220;
				END_IF

				KS_QueryRangeByAType(i_byAOType_Rw_AxisA_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				o_wAO_Inverter_Rw_AxisA_II:= DINT_TO_WORD(KSIO_AD(i_lrAO_Inverter_Rw_AxisA_II, lrN_min, lrN_max, diN_min, diN_max));

				(*B系收料A轴频率监控|2019.9.5.164618_*)
				IF lrN_max<>lrN_min THEN
					IF ABS(lrN_max)=ABS(lrN_min) THEN
						lrFreq_Rw_AxisA_II:= ABS(i_lrAO_Inverter_Rw_AxisA_II) / ABS(lrN_max) * i_lrUpperFreq_Rw_II;
					ELSE
						lrFreq_Rw_AxisA_II:= ABS(i_lrAO_Inverter_Rw_AxisA_II-lrN_min) / ABS(lrN_max-lrN_min) * i_lrUpperFreq_Rw_II;
					END_IF
				ELSE
					lrFreq_Rw_AxisA_II:= -1220;
				END_IF

				KS_QueryRangeByAType(i_byAOType_Rw_AxisB_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				o_wAO_Inverter_Rw_AxisB_II:= DINT_TO_WORD(KSIO_AD(i_lrAO_Inverter_Rw_AxisB_II, lrN_min, lrN_max, diN_min, diN_max));

				(*B系收料B轴频率监控|2019.9.5.164712_*)
				IF lrN_max<>lrN_min THEN
					IF ABS(lrN_max)=ABS(lrN_min) THEN
						lrFreq_Rw_AxisB_II:= ABS(i_lrAO_Inverter_Rw_AxisB_II) / ABS(lrN_max) * i_lrUpperFreq_Rw_II;
					ELSE
						lrFreq_Rw_AxisB_II:= ABS(i_lrAO_Inverter_Rw_AxisB_II-lrN_min) / ABS(lrN_max-lrN_min) * i_lrUpperFreq_Rw_II;
					END_IF
				ELSE
					lrFreq_Rw_AxisB_II:= -1220;
				END_IF


				(*--------------------------------------------B锥度_|*)
				(*放料|*)
				KS_QueryRangeByAType(i_byAOType_Uw_Taper_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				lrTmpTaper_Uw:= (i_lrTaper_Cur_Uw_II/100.0)*(lrN_max-lrN_min)+lrN_min;
				o_wAO_Uw_Taper_II:= DINT_TO_WORD(KSIO_AD(lrTmpTaper_Uw, lrN_min, lrN_max, diN_min, diN_max));
				(*收料|*)
				KS_QueryRangeByAType(i_byAOType_Rw_Taper_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				lrTmpTaper_Rw:= (i_lrTaper_Cur_Rw_II/100.0)*(lrN_max-lrN_min)+lrN_min;
				o_wAO_Rw_Taper_II:= DINT_TO_WORD(KSIO_AD(lrTmpTaper_Rw, lrN_min, lrN_max, diN_min, diN_max));
				(*放牵|*)
				KS_QueryRangeByAType(i_byAOType_If_Taper_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				lrTmpTaper_If:= (i_lrTaper_Cur_If_II/100.0)*(lrN_max-lrN_min)+lrN_min;
				o_wAO_If_Taper_II:= DINT_TO_WORD(KSIO_AD(lrTmpTaper_If, lrN_min, lrN_max, diN_min, diN_max));
				(*收牵|*)
				KS_QueryRangeByAType(i_byAOType_Of_Taper_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				lrTmpTaper_Of:= (i_lrTaper_Cur_Of_II/100.0)*(lrN_max-lrN_min)+lrN_min;
				o_wAO_Of_Taper_II:= DINT_TO_WORD(KSIO_AD(lrTmpTaper_Of, lrN_min, lrN_max, diN_min, diN_max));
				(*--------------------------------------------_B锥度|*)


				(*B系速度表\2018.6.10.150915|*)
				(*当前速度/最大速度*(lrN_max-lrN_min)+lrN_min|*)
				KS_QueryRangeByAType(i_byAOType_Velocity_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				lrTmp:= 0;
				IF i_rVel_Max_II<>0 THEN
					lrTmp:= (i_rVel_Cur_II/i_rVel_Max_II)*(lrN_max-lrN_min)+lrN_min;
				END_IF
				lrTmpVel_Volt:= lrTmp;(*2018.11.22.120503|*)
				o_wAO_Velocity_II:= DINT_TO_WORD(KSIO_AD(lrTmp, lrN_min, lrN_max, diN_min, diN_max));

				(*2018.7.15.102043\扩展线速度表|*)
				KS_QueryRangeByAType(i_byAOType_VelocityEx_II, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				lrTmp:= 0;
				IF i_rVel_Max_II<>0 THEN
					lrTmp:= (i_rVel_Cur_II/i_rVel_Max_II)*(lrN_max-lrN_min)+lrN_min;
				END_IF
				o_wAO_VelocityEx_II:= DINT_TO_WORD(KSIO_AD(lrTmp, lrN_min, lrN_max, diN_min, diN_max));


				(*2018.11.22.112018\扩展监控输出|*)
				IF i_pastStProgMonitoring<>0 THEN
					(*线速度|*)
					i_pastStProgMonitoring^[2].o_lrVelocity_Vol:= lrTmpVel_Volt;
					i_pastStProgMonitoring^[2].o_wVelocity_cur:= o_wAO_Velocity_II;

					(*放A|*)
					i_pastStProgMonitoring^[2].o_wUwAxisA_cur:= o_wAO_Inverter_Uw_AxisA_II;
					i_pastStProgMonitoring^[2].o_lrUwAxisA_Vol:= i_lrAO_Inverter_Uw_AxisA_II;
					i_pastStProgMonitoring^[2].o_lrUwAxisA_Feq:= lrFreq_Uw_AxisA_II;(*2019.4.2.130347|*)

					(*放B|*)
					i_pastStProgMonitoring^[2].o_wUwAxisB_cur:= o_wAO_Inverter_Uw_AxisB_II;
					i_pastStProgMonitoring^[2].o_lrUwAxisB_Vol:= i_lrAO_Inverter_Uw_AxisB_II;
					i_pastStProgMonitoring^[2].o_lrUwAxisB_Feq:= lrFreq_Uw_AxisB_II;(*2019.4.2.130347|*)

					(*收A|*)
					i_pastStProgMonitoring^[2].o_wRwAxisA_cur:= o_wAO_Inverter_Rw_AxisA_II;
					i_pastStProgMonitoring^[2].o_lrRwAxisA_Vol:= i_lrAO_Inverter_Rw_AxisA_II;
					i_pastStProgMonitoring^[2].o_lrRwAxisA_Feq:= lrFreq_Rw_AxisA_II;(*2019.4.2.130347|*)

					(*收B|*)
					i_pastStProgMonitoring^[2].o_wRwAxisB_cur:= o_wAO_Inverter_Rw_AxisB_II;
					i_pastStProgMonitoring^[2].o_lrRwAxisB_Vol:= i_lrAO_Inverter_Rw_AxisB_II;
					i_pastStProgMonitoring^[2].o_lrRwAxisB_Feq:= lrFreq_Rw_AxisB_II;(*2019.4.2.130347|*)

					(*锥度|*)
					i_pastStProgMonitoring^[2].o_lrTaper_Vol:= lrTmpTaper_Rw;
					i_pastStProgMonitoring^[2].o_wTaper_cur:= o_wAO_Rw_Taper_II;
				END_IF

			END_IF
		ELSE
			(*A|*)
			KS_QueryRangeByAType(i_byAOType_Uw_AxisA_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
			o_wAO_Inverter_Uw_AxisA_I:= DINT_TO_WORD(KSIO_AD(i_lrAO_Inverter_Uw_AxisA_I, lrN_min, lrN_max, diN_min, diN_max));

			(*放料A轴频率监控|2019.9.5.174625_*)
			IF lrN_max<>lrN_min THEN
				IF ABS(lrN_max)=ABS(lrN_min) THEN
					lrFreq_Uw_AxisA_I:= ABS(i_lrAO_Inverter_Uw_AxisA_I) / ABS(lrN_max) * i_lrUpperFreq_Uw_I;
				ELSE
					lrFreq_Uw_AxisA_I:= ABS(i_lrAO_Inverter_Uw_AxisA_I-lrN_min) / ABS(lrN_max-lrN_min) * i_lrUpperFreq_Uw_I;
				END_IF
			ELSE
				lrFreq_Uw_AxisA_I:= -1220;
			END_IF

			KS_QueryRangeByAType(i_byAOType_Uw_AxisB_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
			o_wAO_Inverter_Uw_AxisB_I:= DINT_TO_WORD(KSIO_AD(i_lrAO_Inverter_Uw_AxisB_I, lrN_min, lrN_max, diN_min, diN_max));

			(*放料B轴频率监控|2019.9.5.174659_*)
			IF lrN_max<>lrN_min THEN
				IF ABS(lrN_max)=ABS(lrN_min) THEN
					lrFreq_Uw_AxisB_I:= ABS(i_lrAO_Inverter_Uw_AxisB_I) / ABS(lrN_max) * i_lrUpperFreq_Uw_I;
				ELSE
					lrFreq_Uw_AxisB_I:= ABS(i_lrAO_Inverter_Uw_AxisB_I-lrN_min) / ABS(lrN_max-lrN_min) * i_lrUpperFreq_Uw_I;
				END_IF
			ELSE
				lrFreq_Uw_AxisB_I:= -1220;
			END_IF

			KS_QueryRangeByAType(i_byAOType_Rw_AxisA_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
			o_wAO_Inverter_Rw_AxisA_I:= DINT_TO_WORD(KSIO_AD(i_lrAO_Inverter_Rw_AxisA_I, lrN_min, lrN_max, diN_min, diN_max));

			(*收料A轴频率监控|2019.9.5.174750_*)
			IF lrN_max<>lrN_min THEN
				IF ABS(lrN_max)=ABS(lrN_min) THEN
					lrFreq_Rw_AxisA_I:= ABS(i_lrAO_Inverter_Rw_AxisA_I) / ABS(lrN_max) * i_lrUpperFreq_Rw_I;
				ELSE
					lrFreq_Rw_AxisA_I:= ABS(i_lrAO_Inverter_Rw_AxisA_I-lrN_min) / ABS(lrN_max-lrN_min) * i_lrUpperFreq_Rw_I;
				END_IF
			ELSE
				lrFreq_Rw_AxisA_I:= -1220;
			END_IF

			KS_QueryRangeByAType(i_byAOType_Rw_AxisB_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
			o_wAO_Inverter_Rw_AxisB_I:= DINT_TO_WORD(KSIO_AD(i_lrAO_Inverter_Rw_AxisB_I, lrN_min, lrN_max, diN_min, diN_max));

			(*收料B轴频率监控|2019.9.5.174849_*)
			IF lrN_max<>lrN_min THEN
				IF ABS(lrN_max)=ABS(lrN_min) THEN
					lrFreq_Rw_AxisB_I:= ABS(i_lrAO_Inverter_Rw_AxisB_I) / ABS(lrN_max) * i_lrUpperFreq_Rw_I;
				ELSE
					lrFreq_Rw_AxisB_I:= ABS(i_lrAO_Inverter_Rw_AxisB_I-lrN_min) / ABS(lrN_max-lrN_min) * i_lrUpperFreq_Rw_I;
				END_IF
			ELSE
				lrFreq_Rw_AxisB_I:= -1220;
			END_IF


			(*--------------------------------------------A锥度_|*)
			(*放料|*)
			KS_QueryRangeByAType(i_byAOType_Uw_Taper_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
			lrTmpTaper_Uw:= (i_lrTaper_Cur_Uw_I/100.0)*(lrN_max-lrN_min)+lrN_min;
			o_wAO_Uw_Taper_I:= DINT_TO_WORD(KSIO_AD(lrTmpTaper_Uw, lrN_min, lrN_max, diN_min, diN_max));
			(*收料|*)
			KS_QueryRangeByAType(i_byAOType_Rw_Taper_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
			lrTmpTaper_Rw:= (i_lrTaper_Cur_Rw_I/100.0)*(lrN_max-lrN_min)+lrN_min;
			o_wAO_Rw_Taper_I:= DINT_TO_WORD(KSIO_AD(lrTmpTaper_Rw, lrN_min, lrN_max, diN_min, diN_max));
			(*放牵|*)
			KS_QueryRangeByAType(i_byAOType_If_Taper_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
			lrTmpTaper_If:= (i_lrTaper_Cur_If_I/100.0)*(lrN_max-lrN_min)+lrN_min;
			o_wAO_If_Taper_I:= DINT_TO_WORD(KSIO_AD(lrTmpTaper_If, lrN_min, lrN_max, diN_min, diN_max));
			(*收牵|*)
			KS_QueryRangeByAType(i_byAOType_Of_Taper_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
			lrTmpTaper_Of:= (i_lrTaper_Cur_Of_I/100.0)*(lrN_max-lrN_min)+lrN_min;
			o_wAO_Of_Taper_I:= DINT_TO_WORD(KSIO_AD(lrTmpTaper_Of, lrN_min, lrN_max, diN_min, diN_max));
			(*--------------------------------------------_A锥度|*)

			(*A系速度表\2018.6.10.150915|*)
			(*当前速度/最大速度*(lrN_max-lrN_min)+lrN_min|*)
			KS_QueryRangeByAType(i_byAOType_Velocity_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
			lrTmp:= 0;
			IF i_rVel_Max_I<>0 THEN
				lrTmp:= (i_rVel_Cur_I/i_rVel_Max_I)*(lrN_max-lrN_min)+lrN_min;
			END_IF
			lrTmpVel_Volt:= lrTmp;(*2018.11.22.121234|*)
			o_wAO_Velocity_I:= DINT_TO_WORD(KSIO_AD(lrTmp, lrN_min, lrN_max, diN_min, diN_max));

			(*2018.7.15.101637\
			/*A系扩展速度表\
			/*当前速度/最大速度*(lrN_max-lrN_min)+lrN_min|*)
			KS_QueryRangeByAType(i_byAOType_VelocityEx_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
			lrTmp:= 0;
			IF i_rVel_Max_I<>0 THEN
				lrTmp:= (i_rVel_Cur_I/i_rVel_Max_I)*(lrN_max-lrN_min)+lrN_min;
			END_IF
			o_wAO_VelocityEx_I:= DINT_TO_WORD(KSIO_AD(lrTmp, lrN_min, lrN_max, diN_min, diN_max));

			(*2018.11.22.112018\扩展监控输出|*)
			IF i_pastStProgMonitoring<>0 THEN
				(*线速度|*)
				i_pastStProgMonitoring^[1].o_lrVelocity_Vol:= lrTmpVel_Volt;
				i_pastStProgMonitoring^[1].o_wVelocity_cur:= o_wAO_Velocity_I;

				(*放A|*)
				i_pastStProgMonitoring^[1].o_wUwAxisA_cur:= o_wAO_Inverter_Uw_AxisA_I;
				i_pastStProgMonitoring^[1].o_lrUwAxisA_Vol:= i_lrAO_Inverter_Uw_AxisA_I;
				i_pastStProgMonitoring^[1].o_lrUwAxisA_Feq:= lrFreq_Uw_AxisA_I;(*2019.4.2.131034|*)

				(*放B|*)
				i_pastStProgMonitoring^[1].o_wUwAxisB_cur:= o_wAO_Inverter_Uw_AxisB_I;
				i_pastStProgMonitoring^[1].o_lrUwAxisB_Vol:= i_lrAO_Inverter_Uw_AxisB_I;
				i_pastStProgMonitoring^[1].o_lrUwAxisB_Feq:= lrFreq_Uw_AxisB_I;(*2019.4.2.131034|*)

				(*收A|*)
				i_pastStProgMonitoring^[1].o_wRwAxisA_cur:= o_wAO_Inverter_Rw_AxisA_I;
				i_pastStProgMonitoring^[1].o_lrRwAxisA_Vol:= i_lrAO_Inverter_Rw_AxisA_I;
				i_pastStProgMonitoring^[1].o_lrRwAxisA_Feq:= lrFreq_Rw_AxisA_I;(*2019.4.2.131034|*)

				(*收B|*)
				i_pastStProgMonitoring^[1].o_wRwAxisB_cur:= o_wAO_Inverter_Rw_AxisB_I;
				i_pastStProgMonitoring^[1].o_lrRwAxisB_Vol:= i_lrAO_Inverter_Rw_AxisB_I;
				i_pastStProgMonitoring^[1].o_lrRwAxisB_Feq:= lrFreq_Rw_AxisB_I;(*2019.4.2.131034|*)

				(*锥度|*)
				KS_QueryRangeByAType(i_byAOType_Rw_Taper_I, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
				i_pastStProgMonitoring^[1].o_lrTaper_Vol:= (i_lrTaper_Cur_Rw_I/100.0)*(lrN_max-lrN_min)+lrN_min;
				i_pastStProgMonitoring^[1].o_wTaper_cur:= o_wAO_Rw_Taper_I;
			END_IF


			(*B|*)
			o_wAO_Inverter_Uw_AxisA_II:= 0;
			o_wAO_Inverter_Uw_AxisB_II:= 0;
			o_wAO_Inverter_Rw_AxisA_II:= 0;
			o_wAO_Inverter_Rw_AxisB_II:= 0;
			o_wAO_Uw_Taper_II:= 0;(*2019.8.2.164427|*)
			o_wAO_Rw_Taper_II:= 0;
			o_wAO_If_Taper_II:= 0;(*2019.8.2.164427|*)
			o_wAO_Of_Taper_II:= 0;(*2019.8.2.164427|*)
			o_wAO_Velocity_II:= 0;
			o_wAO_VelocityEx_II:= 0;

			(*2018.11.22.114414\扩展监控信息的输出|*)
			IF i_pastStProgMonitoring<>0 THEN
				(*线速度|*)
				i_pastStProgMonitoring^[2].o_lrVelocity_Vol:= 0;
				i_pastStProgMonitoring^[2].o_wVelocity_cur:= o_wAO_Velocity_II;

				(*放A|*)
				i_pastStProgMonitoring^[2].o_wUwAxisA_cur:= o_wAO_Inverter_Uw_AxisA_II;
				i_pastStProgMonitoring^[2].o_lrUwAxisA_Vol:= 0;
				i_pastStProgMonitoring^[2].o_lrUwAxisA_Feq:= 0;(*2019.4.2.130554|*)

				(*放B|*)
				i_pastStProgMonitoring^[2].o_wUwAxisB_cur:= o_wAO_Inverter_Uw_AxisB_II;
				i_pastStProgMonitoring^[2].o_lrUwAxisB_Vol:= 0;
				i_pastStProgMonitoring^[2].o_lrUwAxisB_Feq:= 0;(*2019.4.2.130554|*)

				(*收A|*)
				i_pastStProgMonitoring^[2].o_wRwAxisA_cur:= o_wAO_Inverter_Rw_AxisA_II;
				i_pastStProgMonitoring^[2].o_lrRwAxisA_Vol:= 0;
				i_pastStProgMonitoring^[2].o_lrRwAxisA_Feq:= 0;(*2019.4.2.130554|*)

				(*收B|*)
				i_pastStProgMonitoring^[2].o_wRwAxisB_cur:= o_wAO_Inverter_Rw_AxisB_II;
				i_pastStProgMonitoring^[2].o_lrRwAxisB_Vol:= 0;
				i_pastStProgMonitoring^[2].o_lrRwAxisB_Feq:= 0;(*2019.4.2.130554|*)

				(*锥度|*)
				i_pastStProgMonitoring^[2].o_lrTaper_Vol:= 0;
				i_pastStProgMonitoring^[2].o_wTaper_cur:= o_wAO_Rw_Taper_II;
			END_IF
		END_IF
	END_IF

	o_xEno:= TRUE;
ELSE
	(*A|*)
	o_wAO_Inverter_Uw_AxisA_I:= 0;(*A|放料A轴输出*)
	o_wAO_Inverter_Uw_AxisB_I:= 0;(*A|放料B轴输出*)
	o_wAO_Inverter_Rw_AxisA_I:= 0;(*A|收料A轴输出*)
	o_wAO_Inverter_Rw_AxisB_I:= 0;(*A|收料B轴输出*)
	o_wAO_Uw_Taper_I:= 0;(*A|放料锥度模拟量@2019.8.2.160947|*)
	o_wAO_Rw_Taper_I:= 0;(*A|收料锥度模拟量*)
	o_wAO_If_Taper_I:= 0;(*A|放牵锥度模拟量@2019.8.2.160947|*)
	o_wAO_Of_Taper_I:= 0;(*A|收牵锥度模拟量@2019.8.2.160947|*)
	o_wAO_Velocity_I:= 0;(*A|速度*)
	o_wAO_VelocityEx_I:= 0;(*A|扩展速度*)

	(*B|*)
	o_wAO_Inverter_Uw_AxisA_II:= 0;(*B|放料A轴输出*)
	o_wAO_Inverter_Uw_AxisB_II:= 0;(*B|放料B轴输出*)
	o_wAO_Inverter_Rw_AxisA_II:= 0;(*B|收料A轴输出*)
	o_wAO_Inverter_Rw_AxisB_II:= 0;(*B|收料B轴输出*)
	o_wAO_Uw_Taper_II:= 0;(*B|放料锥度模拟量@2019.8.2.160947|*)
	o_wAO_Rw_Taper_II:= 0;(*B|收料锥度模拟量*)
	o_wAO_If_Taper_II:= 0;(*B|放牵锥度模拟量@2019.8.2.160947|*)
	o_wAO_Of_Taper_II:= 0;(*B|收牵锥度模拟量@2019.8.2.160947|*)
	o_wAO_Velocity_II:= 0;(*B|速度*)
	o_wAO_VelocityEx_II:= 0;(*B|扩展速度*)

	(*ReInitial local variables|*)
	byAveTms_UwRw:= 0;
	byAveTms_IfOf:= 0;
	abyAveTms_DiaMeasure[1]:= 0;
	abyAveTms_DiaMeasure[2]:= 0;

	IF i_xEn AND
		i_pastStProgMonitoring=0 THEN
		o_iErNo:= -1;(*Bad Parameters|*)
	END_IF

	(*2018.11.22.114507\扩展监控信息输出|*)
	IF i_pastStProgMonitoring<>0 THEN
		FOR iA:=1 TO 2 BY 1 DO
			(*线速度|*)
			i_pastStProgMonitoring^[iA].o_lrVelocity_Vol:= 0;
			i_pastStProgMonitoring^[iA].o_wVelocity_cur:= 0;
	
			(*放A|*)
			i_pastStProgMonitoring^[iA].o_wUwAxisA_cur:= 0;
			i_pastStProgMonitoring^[iA].o_lrUwAxisA_Vol:= 0;
	
			(*放B|*)
			i_pastStProgMonitoring^[iA].o_wUwAxisB_cur:= 0;
			i_pastStProgMonitoring^[iA].o_lrUwAxisB_Vol:= 0;
	
			(*收A|*)
			i_pastStProgMonitoring^[iA].o_wRwAxisA_cur:= 0;
			i_pastStProgMonitoring^[iA].o_lrRwAxisA_Vol:= 0;
	
			(*收B|*)
			i_pastStProgMonitoring^[iA].o_wRwAxisB_cur:= 0;
			i_pastStProgMonitoring^[iA].o_lrRwAxisB_Vol:= 0;

			(*锥度|*)
			i_pastStProgMonitoring^[iA].o_lrTaper_Vol:= 0;
			i_pastStProgMonitoring^[iA].o_wTaper_cur:= 0;
		END_FOR
	END_IF

END_IF