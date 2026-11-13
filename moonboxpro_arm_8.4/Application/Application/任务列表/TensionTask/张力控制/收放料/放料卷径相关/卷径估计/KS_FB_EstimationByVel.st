(*@CES
Name=KS_FB_EstimationByVel
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=7013804d-3856-4a07-9c38-8f3020ce9a4d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_EstimationByVel(*收放料通过牵引速度(也可以使用料膜速度)以及自己转速估计卷半径以及料膜厚度算法-By.CHEN*)
(*预估之前会重新初始化预估卷径值*)
(*2023.06.08.162623 限制最大卷径增加接口
初始卷径值获取方式可配置*)
(*2023.6.24.101658 重新调整初始卷径的赋值方式@Liu.yt*)
(*2024.01.02.111942优化接口*)
VAR_INPUT
	i_xEn:BOOL;(*估计使能|*)
	i_xFilmToBig:BOOL;(*TRUE:料膜变大；FALSE:料膜变小*)
	i_rFeedBack:REAL;(*摆臂位置反馈位置-V*)
	i_rVel_rpm:REAL;(*估计所需要的当前转速|r/min*)
	i_rVel_mpm:REAL;(*估计所需要的当前速度变量|-线速度m/min*)
	i_xCutDne:BOOL;(*裁切完成标志|只有效一个周期*)
	i_rNewDia:REAL;(*新卷卷直径-mm*)
	i_uiMaxDia:UINT;(*机械最大卷直径-mm*)
	i_uiInitDiam:UINT;(*初始卷直径|=0自动方式设置-mm*)
	i_xTypeGetInitDiam:BOOL;(*方式切换|FALSE=使用停机之前的值|=TRUE 使用固定值*)
	i_rInitThickNess:REAL:=0;(*估计厚度初始值@2023.12.15.234758*)
	i_rInitThickNess_Cut:REAL:=0;(*接料时候估计厚度初始值-接料时候使用之前记录的值@2023.12.15.234758*)
	i_rPara_R:REAL;(*卷径迭代参数|100@2023.12.16.101753*)
	i_iCycleTime_Plc: INT;
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;
	o_rEstThickness:REAL;(*估计的厚度|mm*)
END_VAR
VAR_IN_OUT
	io_rEstDia:REAL;(*估计的卷径-直径mm*)
END_VAR
VAR
	xInitParaDne:BOOL:=FALSE;(*初始化参数完成*)
	(*估计算法使用了矩阵计算|下面数组实际是矩阵定义*)
	arPh:ARRAY [1..3,1..3] OF REAL:=[1,0,0,0,1,0,0,0,0];
	arXh:ARRAY [1..3] OF REAL:=[200,0,0];(*Xh[1]为估计的卷半径,Xh[2]为估计的厚度,Xh[3]为估计的张力*)
	rInitDiam: REAL;(*2023.6.24.101953 初始卷径*)
	uiDiam_Min:UINT:=80;(*最小卷径*)
	rLastInitDiam:REAL;(*初始卷径备份值@发生变化了就更新下*)
	xLastTypeGetInitDiam: BOOL;(*卷径更新方式切换了|更新下*)
END_VAR
{IMPLEMENTATION}
IF i_uiMaxDia < 500 THEN
	i_uiMaxDia:=500;
END_IF

IF i_rPara_R<=0 THEN
	i_rPara_R:=100;
END_IF

IF i_uiInitDiam=0 THEN
	rInitDiam:=(UINT_TO_REAL(i_uiMaxDia)-200)/2.0+200;
ELSE
	rInitDiam:=UINT_TO_REAL(i_uiInitDiam);
END_IF
(*初始值的限值处理*)
IF rInitDiam<uiDiam_Min THEN
	rInitDiam:=uiDiam_Min;
ELSIF rInitDiam>i_uiMaxDia THEN
	rInitDiam:=UINT_TO_REAL(i_uiMaxDia);
END_IF

(*裁切完成了需要更新卷径估计值*)
IF i_xCutDne THEN
	KS_InitEstPara(i_rNewDia/2, i_rInitThickNess_Cut, ADR(arPh), ADR(arXh));(*以新卷半径为基础估计*)
	io_rEstDia:=arXh[1]*2;(*输出为直径*)
END_IF
IF i_xEn THEN(*可以进行估计了|在接换料的时候需要初始化估计参数*)
	(*执行估计算法*)
	RadiEst(
		i_xFilmToBig,
		i_rVel_rpm(*i_Wu*),
		i_rVel_mpm*1000/60(*i_Vt*),
		i_rFeedBack(*i_Tf*),
		1000(*i_EaL*),
		INT_TO_REAL(i_iCycleTime_Plc)/1000(*i_Ts*),
		1(*i_Para_Tf*),
		i_rPara_R(*100*)(*i_Para_R*),(*2023.12.16.101934 修改为了参数*)
		ADR(arPh)(*i_pPh*),
		ADR(arXh)(*i_pXh*));
	io_rEstDia:=arXh[1]*2;(*输出为直径*)
	xInitParaDne:=FALSE;
ELSE(*不使能的时候初始化估计数组*)

	IF rInitDiam<>rLastInitDiam THEN(*初始值发生了变化@重新赋值*)
		xInitParaDne:=FALSE;
	END_IF
	rLastInitDiam:=rInitDiam;(*放到这里应该问题不大。不用在if中再放一次*)

	IF i_xTypeGetInitDiam<>xLastTypeGetInitDiam THEN
		xInitParaDne:=FALSE;
	END_IF
	xLastTypeGetInitDiam:=i_xTypeGetInitDiam;(*放到这里应该问题不大。不用在if中再放一次*)



	IF NOT xInitParaDne THEN
		xInitParaDne:=TRUE;
		(*新方法|2023.06.08.161459*)
		IF i_xTypeGetInitDiam THEN
			KS_InitEstPara(rInitDiam/2, i_rInitThickNess, ADR(arPh), ADR(arXh));(*以新卷半径为基础估计*)
		ELSE
			KS_InitEstPara(io_rEstDia/2, i_rInitThickNess, ADR(arPh), ADR(arXh));(*2022.7.25.165959 初始值修改为之前的值*)
		END_IF
(*		KS_InitEstPara(150, 0, ADR(arPh), ADR(arXh));*)
(*		KS_InitEstPara(200, 0, ADR(arPh), ADR(arXh));*)(* 2021.12.20.100929预估值改为300*)
		io_rEstDia:=arXh[1]*2;(*输出为直径*)
	END_IF
END_IF
(*输出估计的卷半径为直径
以及厚度值*)
o_rEstThickness:=arXh[2];


IF io_rEstDia>=i_uiMaxDia THEN(*输出的估计值进行限值*)
	io_rEstDia:=UINT_TO_REAL(i_uiMaxDia);
ELSIF io_rEstDia<uiDiam_Min THEN
	io_rEstDia:=uiDiam_Min;
END_IF