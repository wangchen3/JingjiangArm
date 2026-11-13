(*@CES
Name=KS_FB_GrpScraperCtrl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=814d300f-0715-4bc4-9acf-36b27b3399e9
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GrpScraperCtrl
(*2022.3.22.151509 增加了 刮刀手自动
增加了通讯频率的赋值
系数修改轴系数*)
(*2022.7.23.180329 处理遗漏的牵引轴刮刀自动处理逻辑*)
(*2022.8.19.164222 收放牵作为整机控制输出|使能标志位于轴参数中
微调了逻辑*)
(*2024.9.12.144252 对刮刀最大最小频率变量进行修改*)
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_iGrpAxisNum_Pu: INT;(*色组轴的数量|*)
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT;(*系内所有轴的id列表,色组部分已经按照从小到大的顺序排序了，之后的是牵引|*)
	i_pstStSysParam: POINTER TO StSysParam;(*参数地址|*)
	i_iAxisId_If: INT; 
	i_iAxisId_Of: INT;
	i_pstStEvtReq: POINTER TO StEvtReq;(*按钮输入操作及边沿触发描述|*)	
	i_pastStIOMap_Main_FE	: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|*)	
	i_pastStIOMap_AxisExtra: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_Extra_FE;(*色组io|*)
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_iErNo: INT;(*0成功\-1失败|*)
END_VAR
VAR
	iN: INT;
	iUnitId: INT;
(*	iHzMin:LREAL:=1;
	iHzMax: LREAL:=60;(*2018.8.24.084905*)
*)	lrFinalHz:LREAL;(*计算出来的频率*)


	xLinkage: BOOL;
	rVel_Judge: REAL;
	
(*2025.8.12.111244||输入输出参数*)
(*输入参数*)
	rVel_Cur_In: REAL;(*当前速度*)
	rGirth_PrnRoller_In: REAL;(*版周长*)
	iRatio_ScraperContrastToPrintRoller_In: INT;(*刮刀变频系数*)
	rRatedRpm_Scraper_In: REAL;(*刮刀额定转速*)
	iNum_ScraperMotor_In: INT;(*刮刀减速比*)
	iDen_ScraperMotor_In: INT;(*刮刀减速比*)
	rRatedFreq_Scraper_In: REAL;(*额定频率*)
	rCoeff_Scraper_In: REAL;(*速度系数*)
	xSwitch_ScraperAuto_In: BOOL;(*刮刀自动*)
	rHz_UnitScraper_ManuallySet_In: REAL;(*刮刀手动频率*)
	rUpperFreq_Scraper_In: REAL;
	
	
	iVelSa_ScraperRun_In: INT;(*刮刀启动速度*)
	axFlag_Linkage_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL; (*色组联动标志*)
	arAxisVel_In: ARRAY [1..MAX_UNIT_NUM] OF REAL; (*轴速度*)
	xScraperOn_IfOf_In: BOOL;
	axScraperOn_Unit_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL; (*刮刀使能*)
	xScraperInveterError_IfOf_In: BOOL;
	axScraperInveterError_Unit_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL; (*刮刀报警*)
	axSwitch_ScraperAuto_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*刮刀自动*)
	arHz_UnitScraper_ManuallySet_In: ARRAY [1..MAX_UNIT_NUM] OF REAL;(*刮刀手动频率*)
	arGirth_PrnRoller_In: ARRAY [1..MAX_UNIT_NUM] OF REAL;(*版周长*)
	arCoeff_UnitScraper_Auto_In: ARRAY [1..MAX_UNIT_NUM] OF REAL;
(*输出参数*)
	xScraperOn_IfOf_Out: BOOL;
	axScraperOn_Unit_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	rAxisScraperVel_Out: REAL;
	arAxisScraperVel_Out: ARRAY [1..MAX_UNIT_NUM] OF REAL;
	wAO_Scraper_IfOf_Out: WORD;
	awAO_Scraper_Unit_Out: ARRAY [1..MAX_UNIT_NUM] OF WORD;
	rHz_UnitScraper_CurrWR_Out: REAL;
	arHz_UnitScraper_CurrWR_Out: ARRAY [1..MAX_UNIT_NUM] OF REAL;
(*输入输出参数*)
	rMaxFreq_Scraper_In_Out: REAL;
	rMinFreq_Scraper_In_Out: REAL;
END_VAR
{IMPLEMENTATION}
(*2019.03.20.141125|检查*)
(*2019.8.8.145450|简化逻辑|X.gc*)
o_xEno:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	IF (i_iGrpAxisNum_Pu>=1 AND i_iGrpAxisNum_Pu<=MAX_UNIT_NUM) AND(*色组数量有效|*)
		i_pstStSysParam<>0 AND(*参数地址有效|*)
		i_pstStEvtReq<>0 AND(*系参数地址有效|*)
		i_pastStIOMap_Main_FE<>0 AND
		i_pastStIOMap_AxisExtra<>0 THEN(*轴IO表有效|*)
(*输入变量*)
		Action_Input();
		
		rVel_Judge:= rVel_Cur_In;
		IF rVel_Judge> iVelSa_ScraperRun_In THEN
			xScraperOn_IfOf_Out:= xScraperOn_IfOf_In AND (NOT xScraperInveterError_IfOf_In);
		ELSE
			xScraperOn_IfOf_Out:= FALSE;
		END_IF
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:= i_aiGrpAxisList[iN];
			(*2022.3.30.193529  修改为色组使用轴速度|牵引使用主机速度方式*)
			rVel_Judge:=ABS(arAxisVel_In[iUnitId]);

			IF rVel_Judge >= iVelSa_ScraperRun_In(*2023.3.8.094220更新为变量*)(* 2  *)THEN(*2020.1.14.134734 根据用户需求将刮刀启动速度修改位10m/min*)
				(*空转或印刷并且刮刀输入使能|*)
				xLinkage:=axFlag_Linkage_In[iUnitId];
				axScraperOn_Unit_Out[iUnitId]:= xLinkage AND axScraperOn_Unit_In[iUnitId]
													AND (NOT axScraperInveterError_Unit_In[iUnitId]) ;
			ELSE
				axScraperOn_Unit_Out[iUnitId]:=FALSE;
			END_IF
		END_FOR
(*以上使能处理完毕*)
(*先处理牵引频率2025.8.12.145937*)		
		IF xScraperOn_IfOf_Out THEN(*刮刀已使能*)
		(*2022.7.23.175900 牵引轴根据工艺辅助界面1内的参数处理*)
			IF rGirth_PrnRoller_In*iRatio_ScraperContrastToPrintRoller_In*rRatedRpm_Scraper_In <> 0 THEN
				lrFinalHz:=(rVel_Cur_In*1000*iNum_ScraperMotor_In*rRatedFreq_Scraper_In*
						rCoeff_Scraper_In)
						/(rGirth_PrnRoller_In*iRatio_ScraperContrastToPrintRoller_In*rRatedRpm_Scraper_In);(*Xie.GC|2018.8.6.134457|版的转速与刮刀转速成iRatio_ScraperContrastToPrintRoller比例*)
			ELSE
				lrFinalHz:=0;
			END_IF			
			IF xSwitch_ScraperAuto_In THEN(*自动*)
				;
			ELSE
				lrFinalHz:= rHz_UnitScraper_ManuallySet_In;			
			END_IF
			IF rMaxFreq_Scraper_In_Out<=0 OR rMaxFreq_Scraper_In_Out>rUpperFreq_Scraper_In THEN
				rMaxFreq_Scraper_In_Out:= rUpperFreq_Scraper_In;
			END_IF
			IF rMinFreq_Scraper_In_Out<=0 OR rMinFreq_Scraper_In_Out>rMaxFreq_Scraper_In_Out THEN
				rMinFreq_Scraper_In_Out:= rMaxFreq_Scraper_In_Out;
			END_IF


			IF lrFinalHz>rMaxFreq_Scraper_In_Out THEN
				lrFinalHz:= rMaxFreq_Scraper_In_Out;
			ELSIF lrFinalHz<rMinFreq_Scraper_In_Out THEN
				lrFinalHz:= rMinFreq_Scraper_In_Out;
			END_IF
		ELSE
			lrFinalHz:= 0;
		END_IF
		IF rUpperFreq_Scraper_In=0 THEN
			rUpperFreq_Scraper_In:= 50;
		END_IF
		rAxisScraperVel_Out:= LREAL_TO_REAL(lrFinalHz*10.0/ rUpperFreq_Scraper_In)(*iHzMax*);

		wAO_Scraper_IfOf_Out:=
			DINT_TO_WORD(KSIO_AD(rAxisScraperVel_Out, 0, 10, 0, 32767));
		(*2022.3.22.151848  增加通讯频率的赋值*)
		rHz_UnitScraper_CurrWR_Out:= LREAL_TO_REAL(lrFinalHz);		
		
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:= i_aiGrpAxisList[iN];
			IF axScraperOn_Unit_Out[iUnitId] THEN (*刮刀使能*)
			
				(*色组轴|根据轴参数处理|2022.7.23.175825*)
				IF arGirth_PrnRoller_In[iUnitId]*iRatio_ScraperContrastToPrintRoller_In*rRatedRpm_Scraper_In <> 0 THEN
					lrFinalHz:=(rVel_Cur_In*1000*iNum_ScraperMotor_In*rRatedFreq_Scraper_In*
							(*i_pstStGrpParam^.lrCoeff_Scraper)*)(*2022.3.22.151251替换变量*)
							arCoeff_UnitScraper_Auto_In[iUnitId])
							/(arGirth_PrnRoller_In[iUnitId]*iRatio_ScraperContrastToPrintRoller_In*rRatedRpm_Scraper_In);(*Xie.GC|2018.8.6.134457|版的转速与刮刀转速成iRatio_ScraperContrastToPrintRoller比例*)
				ELSE
					lrFinalHz:=0;
				END_IF
			


				IF axSwitch_ScraperAuto_In[iN] THEN(*自动*);
				ELSE(*手动|*)
					lrFinalHz:= arHz_UnitScraper_ManuallySet_In[iUnitId];
				END_IF
			
				IF lrFinalHz> rMaxFreq_Scraper_In_Out THEN
					lrFinalHz:= rMaxFreq_Scraper_In_Out;
				ELSIF lrFinalHz<rMinFreq_Scraper_In_Out THEN
					lrFinalHz:= rMinFreq_Scraper_In_Out;
				END_IF
			ELSE
				lrFinalHz:= 0;
			END_IF
			arAxisScraperVel_Out[iUnitId]:= LREAL_TO_REAL(lrFinalHz*10.0/ rUpperFreq_Scraper_In)(*iHzMax*);

			awAO_Scraper_Unit_Out[iUnitId]:=
				DINT_TO_WORD(KSIO_AD(arAxisScraperVel_Out[iUnitId], 0, 10, 0, 32767));
			(*2022.3.22.151848  增加通讯频率的赋值*)
			arHz_UnitScraper_CurrWR_Out[iUnitId]:= LREAL_TO_REAL(lrFinalHz);
		END_FOR
		
		Action_Output();
	ELSE
		o_iErNo:= -1;
	END_IF
END_IF