(*@CES
Name=Action_Version
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=e9e0c03b-37a2-45ee-bc3f-b9207a9343c8
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
//版本号规则：日期+版本|同一天修改的版本在最后两位进行迭代
//如11月1日第二次修改版本号为2025110102
pstStParam_Diamonds_Wr_SysSts^.dwFileVersion:= 2026091201;
(*
2026.09.12.170716+预套准机械参数之后预留120字节
*)
//pstStParam_Diamonds_Wr_SysSts^.dwFileVersion:= 2026090401;
(*
2026.09.04.142708+更新行走机构控制@和欧诺第二台一致
2026.09.04.142724+修复异站功能块bug
2026.09.06.104859+非停机状态下，版辊单运行标志的清除 并且 增加设备类型等于4时，联动色组不允许单运行
*)
//pstStParam_Diamonds_Wr_SysSts^.dwFileVersion:= 2026090201;
(*
2026.09.02.090923+05结构预套准更新
*)
//pstStParam_Diamonds_Wr_SysSts^.dwFileVersion:= 2026082502;
(*
2026.08.25.143216+使用料膜厚度rFilmThickNess_Using的默认值改为0.02
2026.08.25.143222+收料接料后的预估卷径方向rDiaPrf_CutDne反了，应该是加
*)
//pstStParam_Diamonds_Wr_SysSts^.dwFileVersion:= 2026082101;
(*
1.增加涂布功能
2.屏蔽报警功能块收放料变频器报警的输入并且保存报警的点位到pstStRecord_T^.wPreHotRollerFrq
*)
//pstStParam_Diamonds_Wr_SysSts^.dwFileVersion:= 2026081901;
(*
绍兴程序独立迭代
1.修复从站停止按钮不清除
2.收放料变频器报警输入
*)
//pstStParam_Diamonds_Wr_SysSts^.dwFileVersion:= 2026063001;
(*
近期更新：
1.色组控制轴保存数据的枚举位置
2.配方使用的bug,无法写入
3.刮刀手动频率功能块的赋值
4.保存系统配置的同步
5.横向伺服当前位置改为单向通讯
6.主从双向通讯删除了部分按钮计数
7.增加电压实时值和设定值的金刚通讯
*)
//pstStParam_Diamonds_Wr_SysSts^.dwFileVersion:= 2026051301;
//2026.5.13.142804合并公司凹印机和超旭程序
//gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.7-2026.03.27.175514';
//2026.04.02.191356  将横向限位实时编码器位置与金刚通讯从只写改为读写
//2026.04.02.164512  增加拿横向编码器、横向限位、总匀墨、增加报警处理
//2026.03.27.175514 | + | 给超旭同步秦华的金刚清除报警功能    2026.1.27.141112 | + | 增加清除报警的功能

//pstStParam_Diamonds_Wr_SysSts^.dwFileVersion:= 2026031701;
//gc_sVersion: STRING:= 'KSFieryEyes-MASTER_V1.0.6-2026.03.16.171137';
//2026.03.17.105157	| + |四色压辊
//2026.03.11.093012 | + | 同步获取编码器位数和最大转速的功能 下面的这一段改成自动的，不使用强制了，已经在秦华验证过
//2026.03.09.170159 | + |一色压辊自动处理
//2026.03.11.100402 | + | 使用Bit26作为压力电机自动合压开关
//2026.03.11.103736 | + | 停机维持伺服、停机上下伺服
//2026.03.12.102825 | + | 同步天枢的数据存储开关
//2026.03.14.113537 | + | 增加虚拟码盘异站功能
//2026.03.16.141753 | + | 增加日志打印
//2026.03.16.171137 | + | 增加单运行方向判断
//pstStParam_Diamonds_Wr_SysSts^.dwFileVersion:= 2025110101;
//pstStParam_Diamonds_Wr_SysSts^.dwFileVersion:= 2025110601;
//2025.11.6.134734更新收放料绝对值编码器标定相关变量
//2025.11.6.134759增加保存系统配置按钮
//2025110601版本数据结构大小：读写区域20460：：只写区域51040
