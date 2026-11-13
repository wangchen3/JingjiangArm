(*@CES
Name=StParam_Mailbox_Dep
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=8959721b-aa70-4a50-8488-8b5c585a49ff
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StParam_Mailbox_Dep :
STRUCT
	dwSemaphore								:DWORD;(*通讯旗语						*)

	iGirth_Uw_A								: INT; (*放A周长*)
	iGirth_Uw_B								: INT; (*放B周长*)
	iGirth_Pu								: INT;(*版周长*)
	iVelocity_Tar							: INT;(*目标速度*)
	iAI_mid_Uw								: INT;(*放料中位*)
	iAI_mid_If								: INT;(*放牵中位*)
	byDir_Uw_If_AI							: BYTE;(*放料放牵摆臂方向判断bit0:放料bit1:放牵*)
	wKp_Uw									: WORD;(*放料P*)
	wKi_Uw									: WORD;(*放料I*)
	wKd_Uw									: WORD;(*放料D*)
	wKp_If									: WORD;(*放牵P*)
	wKi_If									: WORD;(*放牵i*)
	wKd_If									: WORD;(*放牵d*)
	bySwitch_AutoCut_Uw						: BYTE;(*放料自动裁切使能开关bit0:使能；bit1:剩余卷径方式bit2:剩余米数方式*)
	iDia_PaperRoller_Uw						: INT;(*纸筒直径*10*)
	iFilmThickNess							: INT;(*料模厚度*1000*)
	wAutoMaticCutDia_Uw						: WORD;(*剩余卷径方式卷径设定*)
	wAutoMaticCutMeters_Uw					: WORD;(*剩余米数方式米数设定*)
	wActRemainFilmLenth_Uw					: WORD;(*实际剩余料长-校正纸筒直径可用*)
	iAlarm_Uw_Dia 							: INT;(*放料报警卷径设置*)
	iDelayMsec_CutterHolder					: INT;(*刀架执行时间*)
	iDelayMsec_RollerCylinder				: INT;(*压辊执行时间*)
	iDelayMsec_CutOffKnifeCylinder			: INT;(*裁刀执行时间*)
	uiMM_Roller2GummedTape					: WORD;(*压辊胶带距离*)
	uiMM_Roller2CutOfKnife					: WORD;(*压辊裁刀距离*)
	uiMM_CutOfKnife2GummedTape				: WORD;(*裁刀胶带距离*)
	iCoefCut_FilmVolPerimeter_Uw			: INT;(*放料裁切圈数*)
	iStepVariation4ChangeTime				: INT; (* 2018.9.30.100457/用来步进胶辊延时和裁刀延时的变化量 *)
	bySwitch_Compensate_Uw					: BYTE;(*放料翻转架补偿开关：Bit0:补偿开启,bit1:方向取反,bit2:0弧度确认*)
	wDiam_Tower_Uw							: WORD;(*放料翻转架的直径|mm*)
	wDiam_NextRoller_Uw						: WORD;(*放料翻转架下个辊的直径|mm*)
	wXPos_NextRoller_Uw						: WORD;(*放料翻转架下个辊的X位置|mm|翻转架中心作为坐标系0点*)
	wYPos_NextRoller_Uw						: WORD;(*放料翻转架下个辊的Y位置|mm|翻转架中心作为坐标系0点*)
	wDiam_DeflectorRoller_Uw				: WORD;(*翻料架上导向辊的直径|mm*)
	wDiam_DeflectorRollPos_Uw				: WORD;(*ABjuli翻料架的导向辊圆心运动直径|距离翻转架圆心=该值/2|mm*)
	byDiamMeasureTypeId						: BYTE;(*卷径测量方式=0：电位器=1 编码器=2 超声波(I)=3 超声波(S)=4 *)
	iStdVol_Diam_1							: INT;
	iStdVol_Diam_2							: INT;
	iStdVol_Diam_3							: INT;
	iStdVol_Diam_4							: INT;
	dwStdVol_Volt_AxisA_1					: DWORD;
	dwStdVol_Volt_AxisA_2					: DWORD;
	dwStdVol_Volt_AxisA_3					: DWORD;
	dwStdVol_Volt_AxisA_4					: DWORD;
	iStdVol_Coef_Axis_1						: INT;(* 卷径测量系数*1000 *)
	iStdVol_Coef_Axis_2						: INT;
	iStdVol_Coef_Axis_3						: INT;
	byIsDebug_DiaMeasureArea_Uw				: BYTE;
	bySwitch_DiaMeasure						: BYTE;(*bit0:自动卷径开关bit1:双轴biw2:弧面bit3:调试模式*)
	bySwitch_Enc_Uw							: BYTE;(*放料编码器标定相关bit0:双轴系数bit1:调试模式
								bit2:定位写入bit3:最小径写入*)
	(*修改变量名-放料人机屏的一些按钮通讯@2023.09.21.103603*)
	wButton_Uw 								: WORD;	
	//到这里上面总共103字节||增加预留47||放牵预计总共150字节双向通讯||不够还可以扩展，总量不超过480
	abyRsv_Deputy							: ARRAY [1..47] OF BYTE;
(*以上为放牵|放料人机需要内容2025.11.16.133721||下面存放1色人机屏内容*)
	wButtonFun_Lamp_Unit					:WORD ;(*HMI界面按钮及指示灯			*)
	wSwitchFun_Unit							:WORD ;(*界面开关*)
	rStep_Pressure_Prn_Net					:REAL ;(*版辊网辊按钮步进量				*)
	rLong_Step_Roller_Pressure				:REAL ;(*色组压力控制长步进值			*)
	rShort_Step_Roller_Pressure				:REAL ;(*色组压力控制短步进值			*)
	wAirInletWindDoorValue					:WORD ;(*进风口风门开度值				*)
	wAirExhaustWindDoorValue				:WORD ;(*排风口风门开度值				*)
	wAirReturnWindDoorValue					:WORD ;(*回风口风门开度值				*)
	dwCtlBits_UnitBaseCraft					:DWORD;(*界面工艺开关及状态				*)
	wHz_UnitInkRoller_ManuallySet			:WORD ;(*递墨辊手动频率					*)
	wCoeff_UnitInkRoller_Auto				:WORD ;(*递墨辊自动系数					*)
	wHz_UnitScraper_ManuallySet				:WORD ;(*刮刀手动频率					*)
	wCoeff_UnitScraper_Auto					:WORD ;(*刮刀自动系数					*)
	wHz_UnitHotWind							:WORD ;(*热风频率						*)
	wHz_UnitHotWind_2						:WORD ;(*热风2频率						*)
	wSV_UnitTemCtl							:WORD ;(*加热设定温度					*)
	wUnit_output_I							:WORD ;(*IO监控输出1					*)
	wUnit_output_II							:WORD ;(*IO监控输出2					*)
	rHz_AxisAirBlowning_ManuallySet			: REAL;
	rHz_AxisAirExhaust_ManuallySet			: REAL;

	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
