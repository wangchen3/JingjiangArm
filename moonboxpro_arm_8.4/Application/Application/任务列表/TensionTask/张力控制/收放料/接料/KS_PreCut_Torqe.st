(*@CES
Name=KS_PreCut_Torqe
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=b6163163-986a-478e-816a-4e7210ccbcc5
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_PreCut_Torqe : BOOL(*力矩方式接料|胶辊合压后取消转矩2020.4.10.103703*)
								(*在预驱结束的时候我们控制取消转矩输出有效，防止在接完料后预驱停止时
								存在转矩时引起的未知异常*)
VAR_INPUT
	i_xPreDrvAxisRunning:BOOL;(*预驱轴运行中|用来控制在停止预驱过程中的转矩输出取消的逻辑。*)
	i_xRoller_Cut:BOOL;(*裁切胶辊合压了|这个作为我们启动力矩方式的条件*)
	i_iRoller_DelayTime:INT;(*胶辊延迟时间*)
	i_iPlcCycleTime:INT:=20;(*plc的执行时间*)
	i_piTimeCnt:POINTER TO INT;(*用于时间计数*)
END_VAR
VAR
	xTorqueClr: BOOL;(*取消转矩标志*)
END_VAR
{IMPLEMENTATION}
IF i_piTimeCnt<>0 THEN
	IF i_iRoller_DelayTime<=0 THEN(*胶辊延时合理化判断*)
		i_iRoller_DelayTime:=200;(*默认就取200ms*)
	END_IF

	IF i_iPlcCycleTime<=0 THEN(*周期时间合理化判断*)
		i_iPlcCycleTime:=20;
	END_IF

	IF i_xRoller_Cut THEN(*裁切胶辊合压了|我们启动延时*)
		IF i_piTimeCnt^*i_iPlcCycleTime>=i_iRoller_DelayTime THEN(*计时到了|我们输出取消转矩信号*)
			xTorqueClr:=TRUE;
		ELSE
			i_piTimeCnt^:=i_piTimeCnt^+1;
		END_IF
	ELSE
		IF i_piTimeCnt^*i_iPlcCycleTime>=i_iRoller_DelayTime THEN(*我们已经接完料了|此时原来的当前轴会进行预驱减速
																   我们在未停止预驱使能的时候我们继续输出取消转矩*)
			IF i_xPreDrvAxisRunning THEN(*预驱有效了*)
				xTorqueClr:=TRUE;
			ELSE
				i_piTimeCnt^:=0;
			END_IF
		ELSE
			i_piTimeCnt^:=0;
		END_IF
	END_IF
END_IF
KS_PreCut_Torqe:=xTorqueClr;