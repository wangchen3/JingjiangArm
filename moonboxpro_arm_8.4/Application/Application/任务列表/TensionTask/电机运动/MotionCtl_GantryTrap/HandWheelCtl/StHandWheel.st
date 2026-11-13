(*@CES
Name=StHandWheel
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=e24024ef-b057-4603-89fd-c6f3dc30d212
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StHandWheel :
STRUCT
	wButton_HardWheel: WORD;(*手轮按键bit0-bit12对应按键1-13（手轮从左到右，从上到下）*)
// 	byRate_HardWheel: BYTE;(*倍率选择=13：X1;=14：X10;=15：X100;=16：X1000;=26：未定义（1000X后面还有一个档位）*)
// 	byAxisId_HardWheelCtl: BYTE;(*手轮旋钮当前选择
// 								=6：OFF
// 								=17：X
// 								=18：Y
// 								=19：Z
// 								=20：A*)

//2023.9.25.131020|手轮实际是倍率和轴选不是之前的定义，我们交换了一些2023.9.25.13110|
	byKnob_Right: BYTE;(*右选择=13：0档位;
								=14：1档位;
								=15：2档位;
								=16：3档位;
								=26：4档位（1000X后面还有一个档位）*)
	byKnob_Left: BYTE;(*左旋钮当前选择
								=6：0档位
								=17：1档位
								=18：2档位
								=19：3档位
								=20：4档位*)
	lrTargetPos_HardWheel: LREAL;(*当前手轮值-可以通过GT_RN_ZeroHandPos指令清除*)
	byHandWheelSts: BYTE;(**)
	asDisplay_HardWheel_HMI: ARRAY [1..4] OF STRING(16);(*手轮HMI显示-*)
	(*屏显功能说明：
	1.显示信号、电池电量
	2.当前操作色组号、当前操作的轴、标定模式以及标定轴、步进值
	3.显示版辊两侧电机实时位置(mm)
	4.显示网辊两侧电机实时位置(mm)
	(屏显格式说明：1行显示11个字符
	2/3/4行能显示16个字符)*)
	//2024.3.13.142250用于通讯给从站的变量
	arPos_HandWheel: ARRAY [1..4] OF REAL;//4个压力电机位置版辊M-G，网辊M-G
	byCtlId_HandWheel: BYTE;
	byCtlSts_HandWheel: BYTE;
						(*
							bit0:锁定模式
							bit1:运行模式
							bit2:标定DEBUG
							bit3:急停
							bit4:报警
							bit5:版/网切换
							bit6:清零处理
			2025.04.02.144750
							bit7:切换色组
						*)	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
