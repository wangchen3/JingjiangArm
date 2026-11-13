(*@CES
Name=StArc_Mol_Param
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=fa3e3698-9f51-498f-bb40-b12e90f03388
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
(*2025.3.5.143340||35BYTES*)
TYPE StArc_Mol_Param :
STRUCT
	xUse_NewArcMol							: BOOL;(*给新算法先加个开关，后续可能不用了-先2025.3.5.152830*)
	(*2025.3.5.143328+*)
	(*套色模型计算pid函数获取的pid值@Cal_Kp_Ki|30bytes*)
	xUsePID_Mol								: BOOL;(*使用标志@代码中未用该变量,先留着吧*)
	rKadj_PID_Mol							: REAL;(*模型的pid增益_初始增益@开机和接料使用*)
	rKadj_I_Mol								: REAL;(*模型的I值增益_初始增益@开机和接料使用*)
	rKp_MolCal								: REAL;
	rKi_MolCal								: REAL;
	(*2024.9.2.083021 增加稳态和接料的模型参数*)
	byKadj_SetType							: BYTE;(*套色K值设置方式@ =0|使用初始增益|=1根据状态设置*)(*2024.9.2.131145 使用扩展参数种*)
	byArcAdjSts								: BYTE;(*套色调整状态@=0 初始状态(增益略大) |=1 稳态状态(增益略小)*)
	rKadj_PID_Mol_SteadySts					: REAL;(*模型的pid增益_稳态增益*)
	rKadj_I_Mol_SteadySts					: REAL;(*模型的I值增益_稳态增益*)
	(*2025.1.11.174053@v3方式的幅值裕度和相位裕度*)
	rMargin_Mag_Arc							: REAL:=20;
	rMargin_Phi_Arc							: REAL:=50;	
	
	
(*套色陷波器*)	
	xUseAntiNotch_Arc			: BOOL;(*套色使用陷波器@*)
	rWn_Arc						: REAL;(*陷波中心频率 rad/s*)
	rBw_Arc						: REAL;(*陷波宽度 rad/s*)
	rDp_Arc						: REAL;(*陷波深度 dB*)
	
	xUsePeriodic				: BOOL;(*使用Periodic方法*)
	rG_Periodic					: REAL;(*趋近增益  不同频率可能符号改变*)
	rW_Periodic					: REAL;(*需要抑制的频率，应该尽可能精确*)
	
	stStArcSpeedUpParam										: StArcSpeedUp;(*套色升速模型参数@30bytes|双积分*)
	stStArcSpeedUpFeedforward								: StArcSpeedUpFeedforward;(*前馈参数@30bytes*)
	
	rKp_GC						: REAL;
	rKi_GC						: REAL;
	rKd_GC						: REAL;
	rN_GC						: REAL;
	xCompensateEn_H				: BOOL;
	byCompensateValue_Hor		: BYTE;
	byMaxAddValue_Total_Hor		: BYTE;
	(*2026.5.14.191903+ 小郭测试算法@8bytes*)
    rPM_deg    : REAL :=50;    (* 目标相位裕度 60->50q(*2026.05.21.220750||wang.xy*)(°) *)

    rWc_Ts     : REAL :=0.3;    (* 归一化穿越频率 *)
	
	abyReserved:ARRAY [1..4] OF BYTE;(*预留31个字节*)
					(*12-->4*)
	
END_STRUCT
END_TYPE


{IMPLEMENTATION}
