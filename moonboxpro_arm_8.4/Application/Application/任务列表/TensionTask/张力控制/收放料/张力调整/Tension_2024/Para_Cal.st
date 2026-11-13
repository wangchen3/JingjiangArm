(*@CES
Name=Para_Cal
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=ef90c73f-dc4b-4bec-847d-13655df4417f
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION Para_Cal : REAL
(*做了微调@2024.05.07.103831by Liu*)
(*主要是用于使用时变参数/设置参数的切换*)
(*时变算法还不太完善，需要优化切记！！！@2024.05.13.193242*)
(*2025.5.12.211538 限制不能为负值*)
VAR_INPUT
	i_xUseTime_Variaition:BOOL;(*使用时变算法*)
	i_stInitial_Model_Parameters_Input: Initial_Model_Parameters;(*2024.05.07.093000 调整接口名*)
	i_pTime_Varying_Parameters_Output: POINTER TO Time_Varying_Parameters;
	i_rEST_R:REAL;(*估计的卷半径m*)
	i_rUseTime_R_Min:REAL;(*使用时变的最小卷半径|m@2024.05.14.080937*)
	i_xUseTime_b1:BOOL;(*有效则b1随卷径实时变化-不实时变化则使用b1_0@2024.05.14.080937*)
END_VAR

VAR
	(*2024.05.07.092928 调整@Liu*)
	Initial_Model_Parameters_Input: Initial_Model_Parameters;
	rE:REAL:=2.718281828459045;(*自然常数e*)
(*Initial_Model_Parameters*)
	R_0: REAL;             (*初始卷半径m*)
	a0_0: REAL;           (*初始a0*)
	b1_0: REAL;	 	(*初始b1*)
	Wn_0: REAL;	(*初始Wn*)
	Beta_0: REAL;	(*初始Beta*)
	l_0: REAL;		(*初始调整系数l*)
(*Time_Varying_Parameters*)
	Ru:REAL;(*估计的卷半径m*)
	a0:REAL;
	b1:REAL;
	Beta:REAL;
	Wn:REAL;
	l:REAL;
(*中间变量*)
	Temp:REAL;
	Ru_Temp:REAL;
	rUseTime_R_Min: REAL;
END_VAR
{IMPLEMENTATION}
	rUseTime_R_Min:=i_rUseTime_R_Min;
	IF rUseTime_R_Min<95.0/2/1000 THEN(*做合法判断*)
		rUseTime_R_Min:=95.0/2/1000;
	END_IF

	(*内部参数赋值*)
	Initial_Model_Parameters_Input:=i_stInitial_Model_Parameters_Input;(*2024.05.07.092953|liu*)
	(*Initial_Model_Parameters*)
	R_0  	:= Initial_Model_Parameters_Input.R_0;             (*初始卷半径m*)
	IF R_0<90.0/2/1000 THEN(*初始卷径默认值@2024.05.07.103750|下面逻辑有/的操作*)
		R_0:=90.0/2/1000;
	END_IF

	a0_0	:= Initial_Model_Parameters_Input.a0_0;           (*初始a0*)
	b1_0 	:= Initial_Model_Parameters_Input.b1_0;	 	(*初始b1*)
	Wn_0 	:= Initial_Model_Parameters_Input.Wn_0;	(*初始Wn*)
	Beta_0 	:= Initial_Model_Parameters_Input.Beta_0;	(*初始Beta*)
	l_0 	:= Initial_Model_Parameters_Input.l_0;		(*初始调整系数l*)
	(*半径*)
	(*Ru 计算主机转速@重要*)
	Ru := i_rEST_R;

	IF i_xUseTime_Variaition THEN(*使用估计的转速值到电机*);
		(*根据卷径关系计算时变参数*)
(*
	(*	b1 := b1_0*EXPT((R_0/Ru),3); *)
		Temp := -3.99*(Ru/R_0);
(*		b1 := 0.8648 * EXPT(gc_rE,Temp);*)
(*		b1 := 0.8648 * EXPT(rE,Temp);*)
		b1 :=0.05;(*华丰测试使用@2024.05.13.193222*)
		Beta := Beta_0*EXPT((R_0/Ru),2);
		Wn := Wn_0*EXPT((R_0/Ru),2);
		l := l_0;
		a0 := a0_0;
*)

		(*根据卷径关系计算时变参数  考虑小卷时转动惯量不随Ru变化 对Ru做判断*)
		(*Ru_Temp 用于计算时变参数*)
		IF Ru<rUseTime_R_Min THEN(*初始卷径默认值@2024.05.07.103750|下面逻辑有/的操作*)
			Ru_Temp:=rUseTime_R_Min;
		ELSE
			Ru_Temp:=Ru;
		END_IF

	(*	b1 := b1_0*EXPT((R_0/Ru),3); *)
		Temp := -3.99*(Ru_Temp/R_0);
		IF i_xUseTime_b1 THEN
			b1 := 0.8648 * EXPT(rE,Temp);
			(*2025.5.12.211538 限制不能为负值*)
			IF b1<=0 THEN
				b1:=0.01;
			END_IF
		ELSE
			b1 :=b1_0;(*华丰测试使用@2024.05.13.193222*)
		END_IF
		Beta := LREAL_TO_REAL(Beta_0*EXPT((R_0/Ru_Temp),2));
		Wn := LREAL_TO_REAL(Wn_0*EXPT((R_0/Ru_Temp),2));
		l := l_0;
		a0 := a0_0;

		(*结构体赋值*)
		i_pTime_Varying_Parameters_Output^.EST_R := Ru;
		i_pTime_Varying_Parameters_Output^.a0 := a0;
		i_pTime_Varying_Parameters_Output^.b1 := b1;
		i_pTime_Varying_Parameters_Output^.Wn := Wn;
		i_pTime_Varying_Parameters_Output^.Beta := Beta;
		i_pTime_Varying_Parameters_Output^.l := l;
	ELSE
		(*结构体赋值*)
		i_pTime_Varying_Parameters_Output^.EST_R := Ru;
		i_pTime_Varying_Parameters_Output^.a0 := a0_0;
		i_pTime_Varying_Parameters_Output^.b1 := b1_0;
		i_pTime_Varying_Parameters_Output^.Wn := Wn_0;
		i_pTime_Varying_Parameters_Output^.Beta := Beta_0;
		i_pTime_Varying_Parameters_Output^.l := l_0;
	END_IF