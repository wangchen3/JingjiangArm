(*@CES
Name=ENUM_MotionStepIDs
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=2f95a26a-5938-4297-8364-5fa39176fcfb
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}

TYPE ENUM_MotionStepIDs : (
	MOTION_STEP_NothingDo						:= -1,(*啥都不做*)
	MOTION_STEP_MotionCtrlModel				:= 9,(*2021.2.21.134018设置运动模式设置|+Liu.yt*)
	MOTION_STEP_ServoOff					:= 10,(*下伺服|*)
	MOTION_STEP_ClrSts						:= 11,(*清错误状态|*)
	MOTION_STEP_ZeroPos						:= 12,(*清位置|*)
	MOTION_STEP_ZeroPos_Again				:= 13,(*2018.9.4.144137\再次清位置|*)
	MOTION_STEP_ServoOn						:= 14,(*上伺服|*)
	MOTION_STEP_PtModeDynamic				:= 15,(*设置动态pt规划|*)
	MOTION_STEP_PtClear						:= 16,(*清除动态ptFIFO|*)
	MOTION_STEP_SetModal0					:= 17,(*2017-09-11 09:14:16| 模态0*)
	MOTION_STEP_SyncAllModal0				:= 18,(*同步所有轴模态|*)
	MOTION_STEP_SetModal1					:= 19,(*2017-09-11 09:14:24| 模态1*)
	MOTION_STEP_SyncAllModal1				:= 20,(*同步所有轴模态|*)
	MOTION_STEP_WaitingModalChanged			:= 21,(*等待模态切换0到1|*)
	MOTION_STEP_PushInitialPTdata			:= 22,(*压入初始的几段PT数据*)
	MOTION_STEP_WritePT						:= 23,(*写pt*)
	MOTION_STEP_CheckPTPrf					:= 24,(*检查pt规划器*)
	MOTION_STEP_SetTpid						:= 25,(*设置前馈增益|*)
	MOTION_STEP_SetPosErr					:= 26,(*设置位置偏差|*)
	MOTION_STEP_SetEncSns					:= 27,(*编码器反转|*)
	MOTION_STEP_CheckAllServoSts			:= 28,(*检查所有上伺服的状态|*)
	MOTION_STEP_WillLeaveWritePT			:= 29,(*将要离开PT写操作|2019.11.29.143804_*)
	MOTION_STEP_MULTI_GTCMD					:= 30,(*多个指令同时执行标志@单运行功能使用|点了按钮响应太慢了*)
	MOTION_STEP_ErrorOccured				:= 110(*错误发生*)
);
END_TYPE
{IMPLEMENTATION}
