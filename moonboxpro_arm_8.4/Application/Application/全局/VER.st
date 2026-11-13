(*@CES
Name=VER
Type=ConstantList
TypeGuid=ffbfa93a-b94d-45fc-a329-229860183b1d
Guid=5d11c678-8099-465f-ae42-1f896e770119
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
VAR_GLOBAL
//	gc_sVersion: STRING:= '2025.7.3.102405';
//	gc_sVersion: STRING:= '2025.7.4.214233';
	(*合并金刚通讯*)
//	gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.1-2025.8.26.144842';
	(*更新速度计算对应关系
	更新lib库，增加相机拍照减速比设置
	*)
	(*2025.8.5.200223|更新金刚通讯前备份了一下8.5版本*)
	(*2025.8.6.175048|增加金刚界面参数赋值及参数保存、套色调整算法|niuj*)
	
	(*v1.0.1版本更新内容：
		1）主站与金刚通讯结构体更新
		2）天枢粗采样数据读取-保存待加
		3）S曲线规划
		4）套色调整
		5）时间：2025.8.26.145356*)
(*	gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.2-2025.8.27.152843';*)
	(*合并韩工最新关于日志和数据保存相关改动2025.8.27.152907*)
(*	gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.2-2025.9.6.104807';*)
	(*调整完全放在同一个任务里把2025.9.1.201639*)
(*	gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.2-2025.9.8.094600';*)
	(*测试完伪随机和增加读取站列表内容*)
(*	gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.2-2025.9.10.193907';*)
(*横向调整代码和IO输入输出全部放到主任务*)
(*通讯任务更改为10ms*)
(*	gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.2-2025.9.12.192152';*)
(*出差前最后版本2025.9.12.192201*)
//	gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.2-2025.9.18.142623';
(*第一次印刷后版本更新|
验证套色调整输出
张力算法
界面伪随机相关变量增加

*)
(*	gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.2-2025.11.1.164946';*)
(*
1.更新润新发现的一些问题
2.运动功能标准化
3.单运行、预套准
4.系统配置等金刚通讯
*)
(*	gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.2-2025.11.14.093524';

运城制版测试
*)	
(*	gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.2-2025.11.15.165030';
增加低通滤波频率下发*)
(*	gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.2-2025.11.16.112443';*)
(*增加获取CPU和内存大小，修改解耦相关内容*)
	//gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.2-2025.12.30.164122';
(*2025.12.30.164126
1.增加牵引变频控制
2.秦华逻辑增加
3.统一拓扑图
*)
//	gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.6-2026.03.16.171137';
//2026.03.11.093012 | + | 同步获取编码器位数和最大转速的功能 下面的这一段改成自动的，不使用强制了，已经在秦华验证过
//2026.03.09.170159 | + |一色压辊自动处理
//2026.03.11.100402 | + | 使用Bit26作为压力电机自动合压开关
//2026.03.11.103736 | + | 停机维持伺服、停机上下伺服
//2026.03.12.102825 | + | 同步天枢的数据存储开关
//2026.03.14.113537 | + | 增加虚拟码盘异站功能
//2026.03.16.141753 | + | 增加日志打印
//2026.03.16.171137 | + | 增加单运行方向判断

//gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.7-2026.03.27.175514';
//2026.03.27.175514 | + | 给超旭同步秦华的金刚清除报警功能    2026.1.27.141112 | + | 增加清除报警的功能

//gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.10-2026.5.15.115700';
//gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.11-2026.5.16.112818';
//2026.5.16.112820更新内容
(*
1.预套准参数保存失败原因：预套准结构变量输入写死，更新为变量
2.卷径检测界面变量绑定问题，输入问题；需同步更新金刚界面，
*)
//gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.11-2026.5.20.091328';
//实时同步程序
(*
1.修复裁切问题
2.修复套色不调整问题
3.修复配方恢复问题
4.更新轴运动状态监控变量表
*)
//gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.11-2026.5.30.112337';
//gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.11-2026.07.30.103148';
(*
近期更新：
1.色组控制轴保存数据的枚举位置
2.配方使用的bug,无法写入
3.刮刀手动频率功能块的赋值
4.保存系统配置的同步
5.横向伺服当前位置改为单向通讯
6.主从双向通讯删除了部分按钮计数
7.增加电压实时值和设定值的金刚通讯
8.更新了光纤行走基准定位功能bug
9.更新了xAxisBLocaltion_Out变量书写错误
10.横向伺服当前位置改为单向通讯删除时，没有保留位置，导致通讯有问题
11.增加横向预套准功能输出
12.增加停机时联动轴维持使能功能
*)
//gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.11-2026.08.19.102507';
(*
绍兴程序独立迭代
1.修复从站停止按钮不清除
2.收放料变频器报警输入
*)
//gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.11-2026.08.21.132221';
(*
1.增加涂布功能
2.屏蔽报警功能块收放料变频器报警的输入并且保存报警的点位pstStRecord_T^.wPreHotRollerFrq
*)
//gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.11-2026.08.25.162455';
(*
2026.08.25.143216+使用料膜厚度rFilmThickNess_Using的默认值改为0.02
2026.08.25.143222+收料接料后的预估卷径方向rDiaPrf_CutDne反了，应该是加
*)
//gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.11-2026.09.02.090905';
(*
2026.09.02.090923+05结构预套准更新
*)
//gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.11-2026.09.04.142650';
(*
2026.09.04.142708+更新行走机构控制@和欧诺第二台一致
2026.09.04.142724+修复异站功能块bug
2026.09.06.104859+非停机状态下，版辊单运行标志的清除 并且 增加设备类型等于4时，联动色组不允许单运行
*)
//gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.12-2026.09.12.170702';
(*
2026.09.12.170716+预套准机械参数之后预留120字节
*)
gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.12-2026.09.13.133606';
(*
2026.09.13.133619| + |增加获取虚拟码盘时返回值错误之后的保护
*)
END_VAR
{IMPLEMENTATION}
