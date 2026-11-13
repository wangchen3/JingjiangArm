(*@CES
Name=StSts_UnitParam_2
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=204de66d-e1be-420b-af3f-8c8766064217
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StSts_UnitParam_2 :(*总110字节，两个色组一个数据包*)(*2025.7.3.175755增加330字节预留-总440字节*)
STRUCT
	
	
	
	byCurPos_Roller									: BYTE;(*辊子当前位置|0 换版位
																		  1 离压位
																		  2 合压位*)
	byInPos_Roller										: BYTE;(*辊子到位标志|.0 全部到位
																		  .1 版辊操作侧到位
																		  .2 版辊传动侧到位
																		  .3 网辊操作侧到位
																		  .4 网辊传动侧到位*)		
	byColorIdCurrent									: BYTE;(*当前色序				*)
	byColorIdFollow									: BYTE;(*跟踪色序				*)
	byArcSts											: BYTE;(* 套色状态/bit0=报警/bit1=丢失 *)	
	wSts_HorzManuPreReg								: WORD; (* 横向手动预套准状态标志|bit0运行标志|bit1正转|bit2反转|bit3左限位|bit4右限位|bit5停止 *)
	iPos_HorzManuPreReg								: INT;(*横向手动预套准位置|*)	
	wSTS_UnitExhaust									: WORD;(* 排风状态|/.0 通讯返回运行状态
															   /.6 排风打开超时-
															   /.7 485通讯断开标志
															   高8位作为报警码*)
(*	原来的接口，先不要了				作为预留6字节										   
	wUnit_input_I 										: WORD;						
	wUnit_input_II 									: WORD;							
	wUnit_input_III 									: WORD;
	*)
	
//2025.12.30.223243增加风门当前位置显示||6-4=2
	rUnitExhaustDamperPos_Cur				: REAL;(*排风风门写入当前位置值*)	
	abyRsv_Data_1										: ARRAY [1..2] OF BYTE;
	
	wSTS_UnitHotWind_2									: WORD;(* 热风II状态 *)
	wSTS_UnitHotWind									: WORD;(* 热风状态 |.0 运行\停止
															               /.6 热风风打开超时-
															  			   /.7 485通讯断开标志*)
	wSTS_UnitScraper									: WORD;(* 刮刀状态/pdu上行给主站/ |.0 运行\停止
															              				  /.6 刮刀打开超时-
															                              /.7 485通讯断开标志*)
	wSTS_UnitInkRoller									: WORD;(* 递墨辊状态/pdu上行给主站 |.0 运行\停止
															              				   /.6 递墨辊刀打开超时
															                               /.7 485通讯断开标志*)
	wSTS_UnitTemCtl									: WORD;(* 色组温度控制报警代码|低8位作为运行状态
																				/.0 通讯返回运行状态
																				/.1 加热使能输出状态
												  高8位作为报警状态/.8 断偶标志 
																   /.9 超温标志
																   /.10 离线标志*)	

	awInput_IOTestDI_Axis							: ARRAY [1..7] OF WORD;															   
	awInput_IOTestDI_Axis_Extra						: ARRAY [1..7] OF WORD;		
	awInput_IOTestAI_Axis							: ARRAY [1..6] OF WORD;															   
	awInput_IOTestAI_Axis_Extra						: ARRAY [1..16] OF WORD;		
(*增加IO监控2025.8.20.153450*)													

//2025.10.15.163922||增加涂布模拟量和轴速度||11-8=3
	rAI_Coating									: REAL;   //涂布摆臂值
	rVel_Coating								: REAL;	//涂布轴速度

//增加一些秦华相关的2025.12.31.112154||总共14字节||113-14=99
	rLength_Band								: REAL;//带长
	iTriggerCnt									: INT;//DI触发
	udiTriggerTimeErr							: UDINT;//DI时间
	udiTriggerEncErr							: UDINT;//DI编码器
//2026.2.2.160436||增加柔印相关一些内容；||niu.j||总12字节99-12= 87；
	rParallelError_Prn_MM						: REAL;
	rParallelError_Net_MM						: REAL;
	rParallelError_Str_MM						: REAL;
//2026.4.25.141239增加全自动套印相关内容2026.4.25.141251
//6字节
	wCommFromDubheFindSignal 	: WORD;//:WORD;(*Bit0 xFlag_AutoAdj_En:BOOL;(*该轴全自动套印使能*)
										//Bit1 xFlag_FindFirstSuccess					: BOOL;(*找到当前色完成*)
										//Bit2 xFlag_FindPreSuccess					: BOOL;(*找到前一色*)
										//Bit3 xFlag_AutoAdj_En:BOOL;(*该轴全自动套印完成*)			）
										//Bit4 xCurManuAdjust :BOOL;(*当前色未找到，需要手动调整光电眼位置，调整好后人工置位*)-----------------Reset
										//Bit5 xPreCurManuAdjust :BOOL;(*前一色未找到，需要观察原因调整好后，人工点确定，等一个机组料长后置位*)
										//*)
	iError_Msg					: INT;//	: INT;(*0:无错误                 -------------------------------------------错误码
										//-1~-100:单色色标失败原因
										//-101~-200:混色色标失败原因*)	
	iStep_AutoAdjust 			: INT;//:  INT;(*主站全自动套印的找标的执行状态   -------------------步骤码*)

//结束2026.4.25.141327

//2026.4.25.142714部分两个变量不需要双向通讯|2变量8字节|81-8=73
	rKp_MolCal                     					: REAL;
	rKi_MolCal                     					: REAL;

//2026.06.15.184209 增加电压实时值0-220v 增加电压实时值0-220v 73-3=70
	abyVoltage_PV:ARRAY [1..3] OF BYTE;
	
//2026.06.29.200311||增加横向伺服当前位置单向只写70-4=66
	diPos_Horz									:DINT;
	
	abyDataRsv										: ARRAY [1..66] OF BYTE;	
											   
//////////////////////////////////////分界线-每隔一段数据增加些预留空间/////////////////////////////////////////////////////////////////////////////	
	abyRsvData_c										: ARRAY [1..220] OF BYTE;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
END_STRUCT
END_TYPE

{IMPLEMENTATION}
