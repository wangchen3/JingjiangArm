(*@CES
Name=KS_FB_MapIO_Main
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=8d69e06b-f6f8-423a-a44d-88632eaed767
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_MapIO_Main
VAR_INPUT
	i_xEn									: BOOL;(*功能块使能|*)
	i_xEnableInput							: BOOL;(*使能输入|*)
	i_xEnableOutput							: BOOL;(*使能输出|*)
	i_pstStIOMap_Main_FE					: POINTER TO StIOMap_Main_FE;(*轴io数据区域|*)

	i_xPrestart								: BOOL; (* 预启动 *)
	i_xInk									: BOOL; (* 空转 *)
	i_xTension								: BOOL; (* 张力投入 *)
	i_xPrint								: BOOL; (* 印刷 *)
	i_xAcc									: BOOL; (* 加速 *)
	i_xDec									: BOOL; (* 减速 *)
	i_xPressAll								: BOOL; (* 全合压 *)
	i_xUnPressAll							: BOOL; (* 全离压 *)
	i_xEstop								: BOOL; (* 急停输入 *)
	i_xStop									: BOOL; (* 停机 *)
	i_xFastStop								: BOOL; (*快停*)
	i_xAlarmBell							: BOOL; (* 警报 *)
	i_xPressMode_Auto_IF					: BOOL; (* 放牵自动合压 *)
	i_xPressMode_Manu_IF					: BOOL; (* 放牵手动合压 *)
	i_xPressMode_Auto_OF					: BOOL; (* 收牵自动合压 *)
	i_xPressMode_Manu_OF					: BOOL; (* 收牵手动合压 *)
//2025.12.29.172113增加牵引变频相关变量
	i_xInverterAlarm_If						: BOOL;(*放牵变频报警输入*)
	i_xInverterAlarm_Of						: BOOL;(*收牵变频报警输入*)
	i_xInverterAlarm						: BOOL;(*牵引变频报警输入*)
	i_xInch_If								: BOOL;(*放牵单运行*)
	i_xInch_Of								: BOOL;(*收牵单运行*)

	i_xAllExhBlower_Up						: BOOL; (* 全上排风 *)
	i_xAllExhBlower_Err_Up					: BOOL; (* 上排风报警 *)
	i_xAllExhBlower_Dn						: BOOL; (* 全下排风 *)
	i_xAllExhBlower_Err_Dn					: BOOL; (* 下排风报警 *)
	i_xAllCoolBlower						: BOOL; (* 全冷风 *)
	i_xAllHotBlower							: BOOL; (* 全热风 *)
	i_xAllHeating							: BOOL; (* 全加热 *)
	(*2024.09.28.094834//增加秦华IO*)
	i_xJumpSelection						: BOOL; (* 跳板选择开关 *)
	i_xHydraulicPower						: BOOL; (* 液压站电源开关 *)
	(*2025.02.25.90543*)
	i_xPressMode_Auto_OF1							: BOOL; (* 收卷后牵引辊自动合压 *)
	i_xPressMode_Manu_OF1							: BOOL; (* 收卷后牵引辊手动合压 *)
	i_xTapPosition_Breaking					: BOOL; (* 断料档位 *)
	i_xTapPosition_UniformInk				: BOOL; (* 匀墨档位 *)

	i_xScraperOn							: BOOL; (* 刮刀开关 *)
	
	i_xRsvd_DI0								: BOOL; (* 数字量输入保留0 *)//超旭-点动
	i_xRsvd_DI1								: BOOL; (* 数字量输入保留1 *)
	i_xRsvd_DI2								: BOOL; (* 数字量输入保留2 *)
	i_xRsvd_DI3								: BOOL; (* 数字量输入保留3 *)
	i_xRsvd_DI4								: BOOL; (* 数字量输入保留4 *)
	i_xRsvd_DI5								: BOOL; (* 数字量输入保留5 *)
	i_xRsvd_DI6								: BOOL; (* 数字量输入保留6 *)
	i_xRsvd_DI7								: BOOL; (* 数字量输入保留7 *)
	i_xRsvd_DI8								: BOOL; (* 数字量输入保留8 *)
	i_xRsvd_DI9								: BOOL; (* 数字量输入保留9 *)
	i_wRsvd_AI0								: WORD; (* 模拟量输入保留0 *)
	i_wRsvd_AI1								: WORD; (* 模拟量输入保留1 *)
	i_wRsvd_AI2								: WORD; (* 模拟量输入保留2 *)
	i_wRsvd_AI3								: WORD; (* 模拟量输入保留3 *)
	i_wRsvd_AI4								: WORD; (* 模拟量输入保留4 *)
	i_wRsvd_AI5								: WORD; (* 模拟量输入保留5 *)

	
END_VAR
VAR_OUTPUT
	o_xEno									: BOOL;
	o_iErNo									: INT;
	o_xLamp_Prestart						: BOOL; (* 预启动指示 *)
	o_xLamp_Ink								: BOOL; (* 空转指示 *)
	o_xLamp_Tension							: BOOL; (* 张力投入指示 *)
	o_xLamp_Print							: BOOL; (* 印刷指示 *)
	o_xLamp_Acc								: BOOL; (* 加速指示 *)
	o_xLamp_Dec								: BOOL; (* 减速指示 *)
	o_xLamp_AllPress						: BOOL; (* 全合压指示 *)
	o_xLamp_UnPressAll						: BOOL; (* 全离压指示 *)
	o_xLamp_Estop							: BOOL; (* 急停灯输出 *)
	o_xLamp_Stop							: BOOL; (* 指示|停机 *)
	o_xRel_AlarmBell						: BOOL; (* 报警输出 *)
	o_xRel_ArcAlarm							: BOOL; (* 整机套色报警输出 *)
	o_xLamp_Press_IF						: BOOL; (* 放牵合压指示 *)
	o_xRel_Press_IF							: BOOL; (* 放牵合压输出 *)
	o_xLamp_Press_OF						: BOOL; (* 收牵合压指示 *)
	o_xRel_Press_OF							: BOOL; (* 收牵合压输出 *)
//2025.12.29.172304增加	牵引变频控制相关
	o_xCW_If								: BOOL; (* 放牵正转 *)
	o_wAO_If								: WORD; (* 放牵输出频率 *)
	o_xCW_Of								: BOOL; (* 收牵正转 *)
	o_wAO_Of								: WORD; (* 收牵输出频率 *)
	o_xAdjustEn_If							: BOOL; (* 放牵自调使能 *)
	o_wFilm_Vel_If							: WORD; (* 放牵主机速度 *)
	o_xAdjustEn_Of							: BOOL; (* 收牵自调使能 *)
	o_wFilm_Vel_Of							: WORD; (* 收牵主机速度 *)
	o_xINVERTER_RESET						: BOOL; (* (放/收)牵引变频复位 *)
	o_xInverterReset_If						: BOOL; (* 放牵变频复位 *)
	o_xInverterReset_Of						: BOOL; (* 收牵变频复位 *)
		
//2023.11.18.135519
	o_xRel_AllExhBlower_Up					: BOOL; (* 上排风继电器输出 *)
	o_xLamp_AllExhBlower_Up					: BOOL; (* 全上排风指示灯 *)
	o_xRel_ModeStar_AllExhBlower_Up			: BOOL; (* 上排风模式-星形 *)
	o_xRel_ModeTriangle_AllExhBlower_Up		: BOOL; (* 上排风模式-三角 *)
	o_xRel_ResetErr_AllExhBlower_Up			: BOOL; (* 上排风故障复位 *)
	o_wAO_AllExhBlower_Up					: WORD; (* 上排风模拟量输出 *)
	o_xRel_AllExhBlower_Dn					: BOOL; (* 下排风继电器输出 *)
	o_xLamp_AllExhBlower_Dn					: BOOL; (* 全下排风指示灯 *)
	o_xRel_ModeStar_AllExhBlower_Dn			: BOOL; (* 下排风模式-星形 *)
	o_xRel_ModeTriangle_AllExhBlower_Dn		: BOOL; (* 下排风模式-三角 *)
	o_xRel_ResetErr_AllExhBlower_Dn			: BOOL; (* 下排风故障复位 *)
	o_wAO_AllExhBlower_Dn					: WORD; (* 下排风模拟量输出 *)
	o_xLamp_AllCoolBlower					: BOOL; (* 全冷风指示灯 *)
	o_xLamp_AllHotBlower					: BOOL; (* 全热风指示灯 *)
	o_xLamp_AllHeating						: BOOL; (* 全加热指示灯 *)
	o_xScraperOn							: BOOL; (* 刮刀输出 *)
	o_wAO_Scraper							: WORD; (* 刮刀模拟量输出 *)
   
	o_xRsvd_DO0								: BOOL; (* 数字量输出保留0 *)
	o_xRsvd_DO1								: BOOL; (* 数字量输出保留1 *)
	o_xRsvd_DO2								: BOOL; (* 数字量输出保留2 *)
	o_xRsvd_DO3								: BOOL; (* 数字量输出保留3 *)
	o_xRsvd_DO4								: BOOL; (* 数字量输出保留4 *)
	o_xRsvd_DO5								: BOOL; (* 数字量输出保留5 *)
	o_xRsvd_DO6								: BOOL; (* 数字量输出保留6 *)
	o_xRsvd_DO7								: BOOL; (* 数字量输出保留7 *)
	o_xRsvd_DO8								: BOOL; (* 数字量输出保留8 *)
	o_xRsvd_DO9								: BOOL; (* 数字量输出保留9 *)
	o_wRsvd_AO0								: WORD; (* 模拟量输出保留0 *)
	o_wRsvd_AO1								: WORD; (* 模拟量输出保留1 *)
	o_wRsvd_AO2								: WORD; (* 模拟量输出保留2 *)
	o_wRsvd_AO3								: WORD; (* 模拟量输出保留3 *)
	o_wRsvd_AO4								: WORD; (* 模拟量输出保留4 *)
	o_wRsvd_AO5								: WORD; (* 模拟量输出保留5 *)	
END_VAR
VAR
	xtest: BOOL;
END_VAR

{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	IF i_pstStIOMap_Main_FE<>0 THEN
		IF i_xEnableInput THEN (* 输入 *)

			i_pstStIOMap_Main_FE^.i_xPrestart					:= i_xPrestart			; (* 预启动 *)
IF i_xPrestart THEN
	xtest:= TRUE;
END_IF
			i_pstStIOMap_Main_FE^.i_xInk							:= i_xInk				; (* 空转 *)
			i_pstStIOMap_Main_FE^.i_xTension						:= i_xTension			; (* 张力投入 *)
			i_pstStIOMap_Main_FE^.i_xPrint						:= i_xPrint				; (* 印刷 *)
			i_pstStIOMap_Main_FE^.i_xAcc							:= i_xAcc				; (* 加速 *)
			i_pstStIOMap_Main_FE^.i_xDec 						:= i_xDec				; (* 减速 *)
			
			i_pstStIOMap_Main_FE^.i_xPressAll					:= i_xPressAll			; (* 全合压 *)
			i_pstStIOMap_Main_FE^.i_xUnPressAll					:= i_xUnPressAll		; (* 全离压 *)
			i_pstStIOMap_Main_FE^.i_xEstop						:= i_xEstop				; (* 急停输入 *)
			i_pstStIOMap_Main_FE^.i_xStop						:= i_xStop				; (* 停机 *)
			i_pstStIOMap_Main_FE^.i_xFastStop						:= i_xFastStop				; (* 快停 *)
			i_pstStIOMap_Main_FE^.i_xAlarmBell					:= i_xAlarmBell			; (* 警报 *)
			i_pstStIOMap_Main_FE^.i_xPressMode_Auto_IF			:= i_xPressMode_Auto_IF	; (* 放牵自动合压 *)
			i_pstStIOMap_Main_FE^.i_xPressMode_Manu_IF 			:= i_xPressMode_Manu_IF	; (* 放牵手动合压 *)
			i_pstStIOMap_Main_FE^.i_xPressMode_Auto_OF			:= i_xPressMode_Auto_OF	; (* 收牵自动合压 *)
			i_pstStIOMap_Main_FE^.i_xPressMode_Manu_OF			:= i_xPressMode_Manu_OF	; (* 收牵手动合压 *)
//2025.12.30.141217
			i_pstStIOMap_Main_FE^.i_xInverterAlarm_If			:= i_xInverterAlarm_If	; (* 收牵手动合压 *)
			i_pstStIOMap_Main_FE^.i_xInverterAlarm_Of			:= i_xInverterAlarm_Of	; (* 收牵手动合压 *)
			i_pstStIOMap_Main_FE^.i_xInverterAlarm			:= i_xInverterAlarm	; (* 收牵手动合压 *)
			i_pstStIOMap_Main_FE^.i_xInch_If			:= i_xInch_If	; (* 收牵手动合压 *)
			i_pstStIOMap_Main_FE^.i_xInch_Of			:= i_xInch_Of	; (* 收牵手动合压 *)
			
			i_pstStIOMap_Main_FE^.i_xAllExhBlower_Up				:= i_xAllExhBlower_Up;
			i_pstStIOMap_Main_FE^.i_xAllExhBlower_Err_Up			:= i_xAllExhBlower_Err_Up;
			i_pstStIOMap_Main_FE^.i_xAllExhBlower_Dn				:= i_xAllExhBlower_Dn;
			i_pstStIOMap_Main_FE^.i_xAllExhBlower_Err_Dn			:= i_xAllExhBlower_Err_Dn;
			i_pstStIOMap_Main_FE^.i_xAllCoolBlower				:= i_xAllCoolBlower;
			i_pstStIOMap_Main_FE^.i_xAllHotBlower				:= i_xAllHotBlower;
			i_pstStIOMap_Main_FE^.i_xAllHeating					:= i_xAllHeating;
			(*2024.09.28.094834//增加秦华IO*)
			i_pstStIOMap_Main_FE^.i_xJumpSelection				:= i_xJumpSelection; (* 跳板选择开关 *)
			i_pstStIOMap_Main_FE^.i_xHydraulicPower				:= i_xHydraulicPower; (* 液压站电源开关 *)
// 			(*2025.02.25.90543*)
// 			i_pstStIOMap_Main_FLEXO^.i_xPressMode_Auto_OF1			:= i_xPressMode_Auto_OF1	; (* 收卷后牵引辊自动合压 *)
// 			i_pstStIOMap_Main_FLEXO^.i_xPressMode_Manu_OF1			:= i_xPressMode_Manu_OF1	; (* 收卷后牵引辊手动合压 *)
			i_pstStIOMap_Main_FE^.i_xTapPosition_Breaking:= i_xTapPosition_Breaking;
			i_pstStIOMap_Main_FE^.i_xTapPosition_UniformInk:= i_xTapPosition_UniformInk;
			i_pstStIOMap_Main_FE^.i_xScraperOn					:= i_xScraperOn;(*刮刀总开*)
			i_pstStIOMap_Main_FE^.i_xRsvd_DI0					:= i_xRsvd_DI0; (* 数字量输入保留0 *)
			i_pstStIOMap_Main_FE^.i_xRsvd_DI1					:= i_xRsvd_DI1; (* 数字量输入保留1 *)
			i_pstStIOMap_Main_FE^.i_xRsvd_DI2					:= i_xRsvd_DI2; (* 数字量输入保留2 *)
			i_pstStIOMap_Main_FE^.i_xRsvd_DI3					:= i_xRsvd_DI3; (* 数字量输入保留3 *)
			i_pstStIOMap_Main_FE^.i_xRsvd_DI4					:= i_xRsvd_DI4; (* 数字量输入保留4 *)
			i_pstStIOMap_Main_FE^.i_xRsvd_DI5					:= i_xRsvd_DI5; (* 数字量输入保留5 *)
			i_pstStIOMap_Main_FE^.i_xRsvd_DI6					:= i_xRsvd_DI6; (* 数字量输入保留6 *)
			i_pstStIOMap_Main_FE^.i_xRsvd_DI7					:= i_xRsvd_DI7; (* 数字量输入保留7 *)
			i_pstStIOMap_Main_FE^.i_xRsvd_DI8					:= i_xRsvd_DI8; (* 数字量输入保留8 *)
			i_pstStIOMap_Main_FE^.i_xRsvd_DI9					:= i_xRsvd_DI9; (* 数字量输入保留9 *)
			i_pstStIOMap_Main_FE^.i_wRsvd_AI0					:= i_wRsvd_AI0; (* 模拟量输入保留0 *)
			i_pstStIOMap_Main_FE^.i_wRsvd_AI1					:= i_wRsvd_AI1; (* 模拟量输入保留1 *)
			i_pstStIOMap_Main_FE^.i_wRsvd_AI2					:= i_wRsvd_AI2; (* 模拟量输入保留2 *)
			i_pstStIOMap_Main_FE^.i_wRsvd_AI3					:= i_wRsvd_AI3; (* 模拟量输入保留3 *)
			i_pstStIOMap_Main_FE^.i_wRsvd_AI4					:= i_wRsvd_AI4; (* 模拟量输入保留4 *)
			i_pstStIOMap_Main_FE^.i_wRsvd_AI5					:= i_wRsvd_AI5; (* 模拟量输入保留5 *)

		END_IF

		IF i_xEnableOutput THEN (* 输出 *)
			o_xLamp_Prestart										:= i_pstStIOMap_Main_FE^.o_xLamp_Prestart		; (* 预启动指示 *)
			o_xLamp_Ink												:= i_pstStIOMap_Main_FE^.o_xLamp_Ink 			; (* 空转指示 *)
			o_xLamp_Tension											:= i_pstStIOMap_Main_FE^.o_xLamp_Tension 		; (* 张力投入指示 *)
			o_xLamp_Print											:= i_pstStIOMap_Main_FE^.o_xLamp_Print 			; (* 印刷指示 *)
			o_xLamp_Acc												:= i_pstStIOMap_Main_FE^.o_xLamp_Acc 			; (* 加速指示 *)
			o_xLamp_Dec												:= i_pstStIOMap_Main_FE^.o_xLamp_Dec 			; (* 减速指示 *)
			o_xLamp_AllPress										:= i_pstStIOMap_Main_FE^.o_xLamp_AllPress 		; (* 全合压指示 *)
			o_xLamp_UnPressAll										:= i_pstStIOMap_Main_FE^.o_xLamp_UnPressAll 		; (* 全离压指示 *)
			o_xLamp_Estop											:= i_pstStIOMap_Main_FE^.o_xLamp_Estop 			; (* 急停灯输出 *)
			o_xLamp_Stop											:= i_pstStIOMap_Main_FE^.o_xLamp_Stop 			; (* 指示|停机 *)
			o_xRel_AlarmBell										:= i_pstStIOMap_Main_FE^.o_xRel_AlarmBell 		; (* 报警输出 *)
			o_xRel_ArcAlarm											:= i_pstStIOMap_Main_FE^.o_xRel_ArcAlarm 		; (* 整机套色报警输出 *)
			o_xLamp_Press_IF										:= i_pstStIOMap_Main_FE^.o_xLamp_Press_IF 		; (* 放牵合压指示 *)
			o_xRel_Press_IF											:= i_pstStIOMap_Main_FE^.o_xRel_Press_IF 		; (* 放牵合压输出 *)
			o_xLamp_Press_OF										:= i_pstStIOMap_Main_FE^.o_xLamp_Press_OF 		; (* 收牵合压指示 *)
			o_xRel_Press_OF											:= i_pstStIOMap_Main_FE^.o_xRel_Press_OF 		; (* 收牵合压输出 *)
//2025.12.30.141312
			o_xCW_If											:= i_pstStIOMap_Main_FE^.o_xCW_If 		; (* 收牵合压输出 *)
			o_wAO_If											:= i_pstStIOMap_Main_FE^.o_wAO_If 		; (* 收牵合压输出 *)
			o_xCW_Of											:= i_pstStIOMap_Main_FE^.o_xCW_Of 		; (* 收牵合压输出 *)
			o_wAO_Of											:= i_pstStIOMap_Main_FE^.o_wAO_Of 		; (* 收牵合压输出 *)
			o_xAdjustEn_If											:= i_pstStIOMap_Main_FE^.o_xAdjustEn_If 		; (* 收牵合压输出 *)
			o_wFilm_Vel_If											:= i_pstStIOMap_Main_FE^.o_wFilm_Vel_If 		; (* 收牵合压输出 *)
			o_xAdjustEn_Of											:= i_pstStIOMap_Main_FE^.o_xAdjustEn_Of 		; (* 收牵合压输出 *)
			o_wFilm_Vel_Of											:= i_pstStIOMap_Main_FE^.o_wFilm_Vel_Of 		; (* 收牵合压输出 *)
			o_xINVERTER_RESET											:= i_pstStIOMap_Main_FE^.o_xINVERTER_RESET 		; (* 收牵合压输出 *)
			o_xInverterReset_If											:= i_pstStIOMap_Main_FE^.o_xInverterReset_If 		; (* 收牵合压输出 *)
			o_xInverterReset_Of											:= i_pstStIOMap_Main_FE^.o_xInverterReset_Of 		; (* 收牵合压输出 *)

			
			o_xRel_AllExhBlower_Up								:= i_pstStIOMap_Main_FE^.o_xRel_AllExhBlower_Up;
			o_xLamp_AllExhBlower_Up								:= i_pstStIOMap_Main_FE^.o_xLamp_AllExhBlower_Up;
			o_xRel_ModeStar_AllExhBlower_Up						:= i_pstStIOMap_Main_FE^.o_xRel_ModeStar_AllExhBlower_Up;
			o_xRel_ModeTriangle_AllExhBlower_Up					:= i_pstStIOMap_Main_FE^.o_xRel_ModeTriangle_AllExhBlower_Up;
			o_xRel_ResetErr_AllExhBlower_Up						:= i_pstStIOMap_Main_FE^.o_xRel_ResetErr_AllExhBlower_Up;
			o_wAO_AllExhBlower_Up								:= i_pstStIOMap_Main_FE^.o_wAO_AllExhBlower_Up;
			o_xRel_AllExhBlower_Dn								:= i_pstStIOMap_Main_FE^.o_xRel_AllExhBlower_Dn;
			o_xLamp_AllExhBlower_Dn								:= i_pstStIOMap_Main_FE^.o_xLamp_AllExhBlower_Dn;
			o_xRel_ModeStar_AllExhBlower_Dn						:= i_pstStIOMap_Main_FE^.o_xRel_ModeStar_AllExhBlower_Dn;
			o_xRel_ModeTriangle_AllExhBlower_Dn					:= i_pstStIOMap_Main_FE^.o_xRel_ModeTriangle_AllExhBlower_Dn;
			o_xRel_ResetErr_AllExhBlower_Dn						:= i_pstStIOMap_Main_FE^.o_xRel_ResetErr_AllExhBlower_Dn;
			o_wAO_AllExhBlower_Dn								:= i_pstStIOMap_Main_FE^.o_wAO_AllExhBlower_Dn;
			o_xLamp_AllCoolBlower								:= i_pstStIOMap_Main_FE^.o_xLamp_AllCoolBlower;
			o_xLamp_AllHotBlower								:= i_pstStIOMap_Main_FE^.o_xLamp_AllHotBlower;
			o_xLamp_AllHeating									:= i_pstStIOMap_Main_FE^.o_xLamp_AllHeating;
			o_xScraperOn										:= i_pstStIOMap_Main_FE^.o_xScraperOn;
			o_wAO_Scraper										:= i_pstStIOMap_Main_FE^.o_wAO_Scraper;
			
			o_xRsvd_DO0						:= i_pstStIOMap_Main_FE^.o_xRsvd_DO0; (* 数字量输出保留0 *) //放牵压辊离压
			o_xRsvd_DO1						:= i_pstStIOMap_Main_FE^.o_xRsvd_DO1; (* 数字量输出保留1 *) 
			o_xRsvd_DO2						:= i_pstStIOMap_Main_FE^.o_xRsvd_DO2; (* 数字量输出保留2 *)
			o_xRsvd_DO3						:= i_pstStIOMap_Main_FE^.o_xRsvd_DO3; (* 数字量输出保留3 *)
			o_xRsvd_DO4						:= i_pstStIOMap_Main_FE^.o_xRsvd_DO4; (* 数字量输出保留4 *)
			o_xRsvd_DO5						:= i_pstStIOMap_Main_FE^.o_xRsvd_DO5; (* 数字量输出保留5 *)
			o_xRsvd_DO6						:= i_pstStIOMap_Main_FE^.o_xRsvd_DO6; (* 数字量输出保留6 *)
			o_xRsvd_DO7						:= i_pstStIOMap_Main_FE^.o_xRsvd_DO7; (* 数字量输出保留7 *)
			o_xRsvd_DO8						:= i_pstStIOMap_Main_FE^.o_xRsvd_DO8; (* 数字量输出保留8 *)
			o_xRsvd_DO9						:= i_pstStIOMap_Main_FE^.o_xRsvd_DO9; (* 数字量输出保留9 *)
			o_wRsvd_AO0						:= i_pstStIOMap_Main_FE^.o_wRsvd_AO0; (* 模拟量输出保留0 *)
			o_wRsvd_AO1						:= i_pstStIOMap_Main_FE^.o_wRsvd_AO1; (* 模拟量输出保留1 *)
			o_wRsvd_AO2						:= i_pstStIOMap_Main_FE^.o_wRsvd_AO2; (* 模拟量输出保留2 *)
			o_wRsvd_AO3						:= i_pstStIOMap_Main_FE^.o_wRsvd_AO3; (* 模拟量输出保留3 *)
			o_wRsvd_AO4						:= i_pstStIOMap_Main_FE^.o_wRsvd_AO4; (* 模拟量输出保留4 *)
			o_wRsvd_AO5						:= i_pstStIOMap_Main_FE^.o_wRsvd_AO5; (* 模拟量输出保留5 *)
		END_IF
	ELSE
		o_iErNo:= -1;
	END_IF
ELSE
	o_xLamp_Prestart				:= FALSE;(* 预启动指示 *)
    o_xLamp_Ink			       		:= FALSE;(* 空转指示 *)
    o_xLamp_Tension		        	:= FALSE;(* 张力投入指示 *)
    o_xLamp_Print		        	:= FALSE;(* 印刷指示 *)
    o_xLamp_Acc			        	:= FALSE;(* 加速指示 *)
    o_xLamp_Dec			        	:= FALSE;(* 减速指示 *)
    o_xLamp_AllPress	        	:= FALSE;(* 全合压指示 *)
    o_xLamp_UnPressAll	        	:= FALSE;(* 全离压指示 *)
    o_xLamp_Estop		        	:= FALSE;(* 急停灯输出 *)
    o_xLamp_Stop		        	:= FALSE;(* 指示|停机 *)
    o_xRel_AlarmBell	        	:= FALSE;(* 报警输出 *)
    o_xRel_ArcAlarm		        	:= FALSE;(* 整机套色报警输出 *)
    o_xLamp_Press_IF	        	:= FALSE;(* 放牵合压指示 *)
    o_xRel_Press_IF		        	:= FALSE;(* 放牵合压输出 *)
    o_xLamp_Press_OF	        	:= FALSE;(* 收牵合压指示 *)
    o_xRel_Press_OF		        	:= FALSE;(* 收牵合压输出 *)

	o_xRsvd_DO0						:= FALSE; (* 数字量输出保留0 *)
	o_xRsvd_DO1						:= FALSE; (* 数字量输出保留1 *)
	o_xRsvd_DO2						:= FALSE; (* 数字量输出保留2 *)
	o_xRsvd_DO3						:= FALSE; (* 数字量输出保留3 *)
	o_xRsvd_DO4						:= FALSE; (* 数字量输出保留4 *)
	o_xRsvd_DO5						:= FALSE; (* 数字量输出保留5 *)
	o_xRsvd_DO6						:= FALSE; (* 数字量输出保留6 *)
	o_xRsvd_DO7						:= FALSE; (* 数字量输出保留7 *)
	o_xRsvd_DO8						:= FALSE; (* 数字量输出保留8 *)
	o_xRsvd_DO9						:= FALSE; (* 数字量输出保留9 *)
	o_wRsvd_AO0						:= 0; (* 模拟量输出保留0 *)
	o_wRsvd_AO1						:= 0; (* 模拟量输出保留1 *)
	o_wRsvd_AO2						:= 0; (* 模拟量输出保留2 *)
	o_wRsvd_AO3						:= 0; (* 模拟量输出保留3 *)
	o_wRsvd_AO4						:= 0; (* 模拟量输出保留4 *)
	o_wRsvd_AO5						:= 0; (* 模拟量输出保留5 *)
END_IF