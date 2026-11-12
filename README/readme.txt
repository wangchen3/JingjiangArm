#define DWVERSION 2022041301
//2022041301|| ???ó′?2é?ù?????ú1é??ó2?2022.4.13.151211

;	# KESAI\Process\calcerr.c
;	# 新增两个函数
;	# INT KS_GetSignalDetails()// 获取信号特征细节
;	# INT KS_CalcErrUseRSdata()// 通过粗采样数据计算套印误差/门内当前色和前一色/以及当前色和第1色的误差/找寻第1色的原则是当前色根据顺逆序20mm*（色序-1），适用于常规色标/不考虑跨色及插标等方式
;	# 调用接口增加到
;	# 
;	# USER\main.c增加
;	# static WORD g_wCnt_Rs = 0;
;	# static INT g_iRtn_Calc2022 = 0;
;	# static INT g_aiVResult[2] = {0};
;	# 
;	# 
;	# GT_RN_SampleRoundUpdata()前增加如下代码：
;	# ///////////////////////////////////////////
;	# 			g_wCnt_Rs++;
;	# 			// 2022.4.13.145245
;	# 			REAL rGirth = 620;
;	# 			if( stStAxisParam.lrGirth!=0 ) {
;	# 				rGirth = stStAxisParam.lrGirth;
;	# 			}
;	# 			g_iRtn_Calc2022 =
;	# 			KS_CalcErrUseRSdata(
;	# 				pbyRoundData1,//BYTE* i_pbyT1Rs,
;	# 				pbyRoundData2,//BYTE* i_pbyT2Rs,
;	# 				alrBase[0],//REAL i_rBaselineT1Rs,
;	# 				alrBase[1],//REAL i_rBaselineT2Rs,
;	# 				stStAxisParam.iGateSa,//INT i_iGateADDR,
;	# 				stStAxisParam.iGateWidthRondPt,//INT i_iGateWidthPointNR_Rs,
;	# 				(INT)(20.0*4000/rGirth),//INT i_i20mmWidthPointNR_Rs,
;	# 				stStAxisParam.iMarkTypeId,//INT i_iMarkTypId,
;	# 				stStAxisParam.iMarkArrangeModal,//INT i_iArrangeTypId,
;	# 				stStAxisParam.iAxisId,//INT i_iColorId,
;	# 				rGirth,// 2022.4.13.183007/repair bug.
;	# 				g_aiVResult);//,//REAL o_arVResult[2],
;	# 				//g_arHResult);//REAL o_arHResult[2])
;	# ///////////////////////////////////////////
;	# 通讯内容利用奥特马上报5#命令中的预热温度及状态等内容，复用上报main的全局定义信息。


//	char *sVersion="KESAI_GTSD_II_Slave version:2020.5.15.160306";//版本号：
	/*
		1.增加屏保延时和屏保状态切换
		2.保存文件相关
		3.横向快速对版
	*/
//	char *sVersion="KESAI_GTSD_II_Slave version:2020.05.12.163203";//版本号：其余版本记录详细见readme.txt
	/*
		1.增加看门狗相关
	*/	
	
//	char *sVersion="KESAI_GTSD_II_Slave version:2020.05.08.091428";//版本号：
	/*
		1.存放历史误差数组深度改为50
		2.接收成功标志和100ms标志关联
	*/
//	char *sVersion="KESAI_GTSD_II_Slave version:2020.05.05.172422";//版本号：
	/*
		1.改进接收中断处理
		2.威纶人机宏指令更新
		3.发送周期更改为6个周期-读-发-读-发-读-发
	*/
//	char *sVersion="KESAI_GTSD_II_Slave version:2020.04.24.113838";//版本号：
	/*
		优化计算基线效率问题前-算基线采用两个循环-后续放在一个循环里
	*/
//	char *sVersion="KESAI_GTSD_II_Slave version:2020.04.21.094043";//版本号：
	/*
		整理程序，删除多余变量，检查逻辑重复
		i_pxInclDeputyStation 
		i_piDeputyStationId
		副主站通讯相关
	*/	
//	char *sVersion="KESAI_GTSD_II_Slave version:2020.4.18.171857";//版本号：
	/*
		将变换频率较低参数，改变再发送
	*/	
//	char *sVersion="KESAI_GTSD_II_Slave version:2020.04.01.115921";//版本号：
	/*
		将计算误差修改为单组波门
	*/	

//	char *sVersion="KESAI_GTSD_II_Slave version:2020.03.31.200322";//版本号：
	/*
		合并远程升级代码，准备将计算误差修改为单组波门
	*/	


//	char *sVersion="KESAI_GTSD_II_Slave version:2020.03.26.182543";//版本号：
	/*2020.03.26.182547
		485发送内容分开-单向发送及双向通讯内容
	*/	


//	char *sVersion="KESAI_GTSD_II_Slave version:2020.03.24.154304";//版本号：
	/*2020.03.24.154304
		该版本前使用查询发送-更新为中断发送，中断接收
	*/	

//	char *sVersion="KESAI_GTSD_II_Slave version:2020.03.20.164514";//版本号：
	/*
		2020.03.20.164532|波门双向通讯正常d
	*/

//	char *sVersion="KESAI_GTSD_II_Slave version:2020.03.19.174325";//版本号：
	/*
		2020.03.19.174339：首次联机调试程序：目前问题：1.485双向通讯
		2.上行参数 3.首次运行程序不知在哪等待 4.
	*/
//	char *sVersion="KESAI_GTSD_II_Slave version:2020.03.12.133950";//版本号：
	/*
		2020.03.12.133950：编译通过，测试版-程序正常运行，无死循环
	*/
//	char *sVersion="KESAI_GTSD_II_Slave version:2020.03.06.165741";//版本号：
	/*
		2020.03.06.170641：初始版本-合并黄工源代码
	*/
