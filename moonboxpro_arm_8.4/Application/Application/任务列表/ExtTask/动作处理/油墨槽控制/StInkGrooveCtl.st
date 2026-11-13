(*@CES
Name=StInkGrooveCtl
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=c6ce6a04-2efb-4550-ab95-73592a3e1ea7
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StInkGrooveCtl :(*油墨槽控制@不保持|50bytes*)
STRUCT
	bySts							:BYTE;(*状态@就不用枚举了*)
	byMovingSts						:BYTE;(*运动状态|=0 不运动|=1 上升|=2 下降*)
	xCtlMode						:BOOL;(*控制模式|=false速度模式|=true 位置模式*)
	xMoveDir						:BOOL;(*运动的方向*)
	rVel							:REAL;(*速度值@r/min*)
	rMoveDis						:REAL;(*需要运动的距离@mm(带方向)*)
	diMoveDis_Pulse					:DINT;(*需要运动的距离(正值)@pulse*)
	wLastPulse_Act_Rd				:WORD;(*实际读取的脉冲数记录@上一拍*)
	xZeroValid						:BOOL;(*零位有效*)
	diPulse_Moved					:DINT;(*已经移动的脉冲|在原点处会更新为0*)
	rPos_Cur						:REAL;(*当前位置@mm|经过下限位零点后才有值*)
	iMsg							:TypeEnumInkGrooveMsg;(*信息 |=1 零点丢失
																  	 |=2 未确认基准
																   	 |=3 距离超限
																   	 |=4 上限位
																   	 |=5 下限位
																   	 |=6 速度模式下,运动异常*)
	diThisMovedPulse				:DINT;(*本次运动的距离@脉冲*)
	rThisMovedDis					:REAL;(*本次运动的距离@mm*)
	wLastPulse_Act_Rd_1				:WORD;(*实际读取的脉冲数记录@上一拍|用于计算本次运动的而距离值*)
	abyReseved						:ARRAY [1..11] OF BYTE;

END_STRUCT
END_TYPE

{IMPLEMENTATION}
