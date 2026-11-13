(*@CES
Name=Action_Hmi_Display
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=c1efb68e-db62-4724-9a99-eb79bd69ea3b
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*2026.05.20.224949 针对天枢的通讯机制金刚到天枢数据做时延处理 by liu.yt*)
IF xParaInit OR(*开机初始化*)
	xLastCutOnTop<>io_xCutOnTop THEN (*上下裁刀切换了*)
	(*需要上行|一定时间里禁止下行数据更新*)
	xUpdateUpLoadData:=TRUE;
	fbTon_UpLoadData(IN:=FALSE);
END_IF
fbTon_UpLoadData(IN:=xUpdateUpLoadData,PT:=T#1000MS);
IF fbTon_UpLoadData.Q THEN
	xUpdateUpLoadData:=FALSE;
END_IF
(*END*)

(*2021.11.5.095633*)
(*处理界面的标准卷径界面处理*)
(*根据上下裁刀标志取标准卷径值*)
pstStStdVolParam_DnCut_UpCut_HMI:=ADR(astStStdVolParam_DnCut_UpCut_In_Out[BOOL_TO_INT(io_xCutOnTop)]);
(*根据当前轴取值赋值*)
IF xCutAxisA_In_Out THEN(*当前轴为A轴|*)
	(*取B轴的标准卷径参数*)
	IF xParaInit OR(*开机初始化*)
		xLastCutOnTop<>io_xCutOnTop OR (*上下裁刀切换了*)
		(NOT xLastCurAxisA) OR (*当前轴切换了|*)
		xUpdateUpLoadData OR(*这段时间强制向上写*)
		SysMemCmp(ADR(pstStStdVolParam_DnCut_UpCut_HMI^.alrStdVol_Volt_AxisB),(*标准电压值变了|也可以当做开机初始化*)
				ADR(alrLastStdVol_Volt_AxisB),SIZEOF(alrLastStdVol_Volt_AxisB))<>0 THEN
		io_alrStdVol_Diam_Axis_Hmi:=
						//	pstStStdVolParam_DnCut_UpCut_HMI^.alrStdVol_Volt_AxisB
							pstStStdVolParam_DnCut_UpCut_HMI^.alrStdVol_Diam;
		io_alrStdVol_Volt_Axis_Hmi:=
							pstStStdVolParam_DnCut_UpCut_HMI^.alrStdVol_Volt_AxisB;
		io_alrStdVol_Coef_Axis_Hmi:=
							pstStStdVolParam_DnCut_UpCut_HMI^.alrStdVol_Coef_AxisB;
	END_IF
	
	
	(*写入界面的值*)
	IF NOT xUpdateUpLoadData THEN(*2026.05.20.225458+条件*)
		pstStStdVolParam_DnCut_UpCut_HMI^.alrStdVol_Diam:=
												io_alrStdVol_Diam_Axis_Hmi;
		pstStStdVolParam_DnCut_UpCut_HMI^.alrStdVol_Volt_AxisB:=
												io_alrStdVol_Volt_Axis_Hmi;
		pstStStdVolParam_DnCut_UpCut_HMI^.alrStdVol_Coef_AxisB:=
												io_alrStdVol_Coef_Axis_Hmi;
	END_IF
ELSE(*当前轴为B轴*)
	(*取B轴的标准卷径参数*)
	IF xLastCutOnTop<>io_xCutOnTop OR (*上下裁刀切换了*)
		xLastCurAxisA OR(*当前轴切换了|*)
		xUpdateUpLoadData OR(*这段时间强制向上写*)
		SysMemCmp(ADR(pstStStdVolParam_DnCut_UpCut_HMI^.alrStdVol_Volt_AxisA),(*标准电压值变了|也可以当做开机初始化*)
				ADR(alrLastStdVol_Volt_AxisA),SIZEOF(alrLastStdVol_Volt_AxisA))<>0 THEN
		io_alrStdVol_Diam_Axis_Hmi:=
							pstStStdVolParam_DnCut_UpCut_HMI^.alrStdVol_Diam;
		io_alrStdVol_Volt_Axis_Hmi:=
							pstStStdVolParam_DnCut_UpCut_HMI^.alrStdVol_Volt_AxisA;
		io_alrStdVol_Coef_Axis_Hmi:=
							pstStStdVolParam_DnCut_UpCut_HMI^.alrStdVol_Coef_AxisA;
	END_IF
	(*写入界面的值*)
	IF NOT xUpdateUpLoadData THEN(*2026.05.20.225458+条件*)
		pstStStdVolParam_DnCut_UpCut_HMI^.alrStdVol_Diam:=
												io_alrStdVol_Diam_Axis_Hmi;
		pstStStdVolParam_DnCut_UpCut_HMI^.alrStdVol_Volt_AxisA:=
												io_alrStdVol_Volt_Axis_Hmi;
		pstStStdVolParam_DnCut_UpCut_HMI^.alrStdVol_Coef_AxisA:=
												io_alrStdVol_Coef_Axis_Hmi;
	END_IF
END_IF
alrLastStdVol_Volt_AxisA:=pstStStdVolParam_DnCut_UpCut_HMI^.alrStdVol_Volt_AxisA;
alrLastStdVol_Volt_AxisB:=pstStStdVolParam_DnCut_UpCut_HMI^.alrStdVol_Volt_AxisB;

//2026.05.20.212619 增加处理
(*界面显示裁切相关时间变量处理*)
pstStTimeSet_DnCut_UpCut:=ADR(io_astStTimeSet_DnCut_UpCut[BOOL_TO_INT(io_xCutOnTop)]);
IF xParaInit OR(*开机初始化*)
	xLastCutOnTop<>io_xCutOnTop THEN(*裁刀换了*)
	io_stStTimeSet_DnCut_UpCut_Hmi:=pstStTimeSet_DnCut_UpCut^;
END_IF

io_stStTimeSet_DnCut_UpCut_Hmi.rStepVariation4ChangeDis:=pstStTimeSet_DnCut_UpCut^.rStepVariation4ChangeDis;(*只显示*)

(*都是金刚通讯实现机制惹的祸@2026.05.21.110637*)
IF NOT xUpdateUpLoadData THEN(*2026.05.20.225458+条件*)
	pstStTimeSet_DnCut_UpCut^:=io_stStTimeSet_DnCut_UpCut_Hmi;
ELSE
	io_stStTimeSet_DnCut_UpCut_Hmi:=pstStTimeSet_DnCut_UpCut^;
END_IF
//END

xLastCurAxisA:=xCutAxisA_In_Out;
xLastCutOnTop:=io_xCutOnTop;
xParaInit:=FALSE;

