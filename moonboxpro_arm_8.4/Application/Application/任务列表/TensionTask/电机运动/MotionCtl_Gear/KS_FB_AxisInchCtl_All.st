(*@CES
Name=KS_FB_AxisInchCtl_All
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=891b7f07-929e-4459-bfed-60e763b2668b
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AxisInchCtl_All
VAR_INPUT
	i_xEn: BOOL;(*使能|*)
	i_iGrpId: INT;(*系id|*)
	i_iGrpAxisNum_Pu: INT;(*色组轴的数量|*)
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT;(*系内所有轴的id列表,色组部分已经按照从小到大的顺序排序了，之后的是牵引|*)
	i_pstStSysParam: POINTER TO StSysParam;(*参数结构|*)
	i_pstStEvtReq: POINTER TO StEvtReq;(*输入动作|*)
	i_pastStIOMap_Axis_FE					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域*)
	i_rAcc_Inch : REAL := 0.2;
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;(*Same with i_xEn|*)
	o_iErNo: INT;(*-1参数错误\|*)
	o_xHasAxisOnInchRunningSts: BOOL;(*True标识有轴还在单运行|*)
	o_diVel_Virtual_Tar_Inch: DINT;(*虚拟主轴规划速度*)
	o_lrMax_a_S_pos_Inch: LREAL;(*虚拟主轴最大减速度*)
	o_arInchTarVel : ARRAY [1..MAX_UNIT_NUM] OF REAL;
	o_xInchDecing : BOOL;
END_VAR
VAR
	iN: INT;
	iUnitId: INT;
	//2025.10.28.140624 | bai.zy | 单运行的轴速度先单独拿出来
	adiVel_Virtual_Tar_Inch : ARRAY [1..MAX_UNIT_NUM] OF DINT;
	afbTRIG_SwitchInching_Prn: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	
	xHasAxisOnInchRunningSts : BOOL;
	
	diVel_Virtual_Tar_Inch_Pre : DINT;
	xHasAxisOnInchRunningSts_Pre : BOOL;
	
	xPrintInching_Pre : BOOL;
	xPrintInching_Lasting : BOOL;
	xInchDecing : BOOL;
	iInchDecCnt : INT;
	
	iDecCnt : INT;
	//2026.04.01.170415 Hou.N 增加总匀墨处理逻辑
	afbTRIG_SwitchInching_Net_On:ARRAY [1..MAX_UNIT_NUM] OF  R_TRIG;
	afbTRIG_SwitchInching_Net_Off: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	xSwitch_Inching_Net:ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	aitest1:ARRAY [1..MAX_UNIT_NUM] OF INT;
	aitest2:ARRAY [1..MAX_UNIT_NUM] OF INT;
	
	fbTRIG_SwitchInching_Net_On : R_TRIG;
	fbTRIG_SwitchInching_Net_Off : R_TRIG;
	axSwitch_Inch_Net: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	aiTest:ARRAY [1..MAX_UNIT_NUM] OF INT;
	afbTRIG_Switch:ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
END_VAR

{IMPLEMENTATION}
o_lrMax_a_S_pos_Inch:= 1;
IF i_xEn THEN
	IF (i_iGrpId=1 OR i_iGrpId=2) AND
		(i_iGrpAxisNum_Pu>=1 AND i_iGrpAxisNum_Pu<=MAX_STATION_NUM) AND
		i_pstStSysParam<>0 THEN	
		
		//2026.04.01.170603 Hou.N 增加总匀墨处理
(*		fbTRIG_SwitchInching_Net_On(CLK:=i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xSwitch_GrpInkEn );
		IF fbTRIG_SwitchInching_Net_On.Q THEN	
			FOR iN := 1 TO i_iGrpAxisNum_Pu BY 1 DO
				IF i_pstStSysParam^.astStUnitParam_Save[iN].xLinkage THEN
					i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].xSwitch_Inching_Net :=TRUE;
				END_IF
			END_FOR
		END_IF
		
		fbTRIG_SwitchInching_Net_Off(CLK:= NOT i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xSwitch_GrpInkEn );
		IF fbTRIG_SwitchInching_Net_Off.Q THEN
			FOR iN := 1 TO i_iGrpAxisNum_Pu BY 1 DO
				IF i_pstStSysParam^.astStUnitParam_Save[iN].xLinkage THEN
					i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].xSwitch_Inching_Net :=FALSE;
				END_IF
			END_FOR
		END_IF	
*)
		IF NOT i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xSwitch_GrpInkEn THEN
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iUnitId:= i_aiGrpAxisList[iN];
				axSwitch_Inch_Net[iUnitId]:= FALSE;
			END_FOR
		ELSE
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iUnitId:= i_aiGrpAxisList[iN];
				axSwitch_Inch_Net[iUnitId]:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xSwitch_Inching_Net;
			END_FOR			
		END_IF
		
		
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:= i_aiGrpAxisList[iN];

			afbTRIG_SwitchInching_Prn[iUnitId](CLK := i_pastStIOMap_Axis_FE^[iUnitId].i_xInch );
			IF afbTRIG_SwitchInching_Prn[iUnitId].Q THEN 
				//2026.09.06.103922 当前凹印机现场使用时，设备类型强制写4，也并在条件里
				IF i_pstStSysParam^.stStSysParam_Save.dwEquipmentProf.3 or i_pstStSysParam^.stStSysParam_Save.dwEquipmentProf.2 THEN //凹印机只能在单动时候使用2026.5.27.103527 
				//IF i_pstStSysParam^.stStSysParam_Save.dwEquipmentProf.3 THEN //凹印机只能在单动时候使用2026.5.27.103527
					IF (NOT i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage) THEN
						i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xSwitch_Inching_Prn := NOT i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xSwitch_Inching_Prn;
					END_IF
				ELSE//其他机型先不限制单联动吧|只针对版辊2026.5.27.103529
					i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xSwitch_Inching_Prn := NOT i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xSwitch_Inching_Prn;
				END_IF
			END_IF

			i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xInching_NetRoller:=
				axSwitch_Inch_Net[iUnitId];
				//i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xSwitch_Inching_Net;
			i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xInching_BottomRoller:=
				i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xSwitch_Inching_Bottom;
			//2026.04.06.131959  test
			afbTRIG_Switch[iUnitId](CLK := i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xSwitch_Inching_Prn) ;
			IF 	afbTRIG_Switch[iUnitId].Q THEN
				aiTest[iUnitId]:=aiTest[iUnitId]+1;
			END_IF
			
			i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisInching := 
				i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xSwitch_Inching_Prn;
				
			IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xPrintInching THEN
				i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xInching_NetRoller := TRUE;
				i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xInching_BottomRoller := TRUE;
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisInching := TRUE;
			END_IF
		END_FOR
		
		//增加牵引
		i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_If_Roller := i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xSwitch_Inching_If;
		i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_Of_Roller := i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xSwitch_Inching_Of;
		IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xPrintInching THEN
			i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_If_Roller :=TRUE;
		    i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_Of_Roller :=TRUE;
		END_IF
		
		IF NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stop OR (*非停机状态下,禁止各种形式的单运行*)
			(i_pstStEvtReq^.xReqStop AND i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stop) THEN(*2021.10.15.094231 增加按下停止按钮时候清除单运行*)
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iUnitId:= i_aiGrpAxisList[iN];(*轴id|*)
				i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xInching_NetRoller:=FALSE;
				i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xInching_BottomRoller:=FALSE;
 				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisInching := FALSE;
				
				(*2026.09.06.103518+ 非停机状态下的单运行标志清除，否则会出现开机过程中按过单运行，停机后自动单运行*)
				i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xSwitch_Inching_Prn := FALSE;
            	i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xSwitch_Inching_Net := FALSE;
           		i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xSwitch_Inching_Bottom :=FALSE;
			END_FOR
			(*非停机的时候清除全体运行标志|2019.12.6.110407*)
			
			//增加牵引
			i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_If_Roller := FALSE;
			i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_Of_Roller := FALSE;
			
		END_IF	
(*		
		FOR iN:=1 TO i_iGrpAxisNum_Pu  BY 1 DO
			iUnitId:= i_aiGrpAxisList[iN];(*轴id|*)
	
			IF 	i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xInching_NetRoller OR 
				i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xInching_BottomRoller OR
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisInching THEN
	// 			IF pstStUnitParam_UnSave^.iAxisPrnRunCaseId=MOTION_STEP_Nothing THEN(*这里做速度规划-让主轴先动起来*)
					adiVel_Virtual_Tar_Inch[iUnitId] := LREAL_TO_DINT(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rVel_Inch
																	*GC_LRMOTORPPR/
																	gc_rGirth_Master/60.0/1000);
					o_lrMax_a_S_pos_Inch:= 1;

					IF NOT o_xHasAxisOnInchRunningSts THEN
						o_xHasAxisOnInchRunningSts:= TRUE;
					END_IF
				//END_IF
			ELSE
				o_xHasAxisOnInchRunningSts:= FALSE;	
				//o_diVel_Virtual_Tar_Inch:= 0;
				adiVel_Virtual_Tar_Inch[iUnitId] := 0;
				o_lrMax_a_S_pos_Inch:= 1;			

			END_IF
		END_FOR
		
		IF i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_If_Roller OR 
			i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_Of_Roller THEN
			
			adiVel_Virtual_Tar_Inch[i_iGrpId] := LREAL_TO_DINT(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rVel_Inch
																	*GC_LRMOTORPPR/
																	gc_rGirth_Master/60.0/1000);
			o_lrMax_a_S_pos_Inch:= 1;
			
			//点动速度为5米/分
			IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xPrintInching THEN
				adiVel_Virtual_Tar_Inch[i_iGrpId] := LREAL_TO_DINT(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Inching_Print
																	*GC_LRMOTORPPR/
																	gc_rGirth_Master/60.0/1000);
			END_IF
		END_IF
*)	
		xHasAxisOnInchRunningSts := FALSE;
		FOR iN:=1 TO i_iGrpAxisNum_Pu  BY 1 DO
			iUnitId:= i_aiGrpAxisList[iN];(*轴id|*)
			IF 	i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xInching_NetRoller OR 
				i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xInching_BottomRoller OR
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisInching THEN
				xHasAxisOnInchRunningSts := TRUE;
				EXIT;
			END_IF
		END_FOR		

		xHasAxisOnInchRunningSts := xHasAxisOnInchRunningSts OR 
			i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_If_Roller OR 
			i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_Of_Roller;
		
		IF xHasAxisOnInchRunningSts THEN
			o_diVel_Virtual_Tar_Inch := LREAL_TO_DINT(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rVel_Inch
																	*GC_LRMOTORPPR/
																	gc_rGirth_Master/60.0/1000);
			o_lrMax_a_S_pos_Inch:= 1;
			//点动速度为5米/分
			IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xPrintInching THEN
				o_diVel_Virtual_Tar_Inch := LREAL_TO_DINT(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Inching_Print
																	*GC_LRMOTORPPR/
																	gc_rGirth_Master/60.0/1000);
			END_IF
		ELSIF xHasAxisOnInchRunningSts_Pre <> xHasAxisOnInchRunningSts AND NOT xInchDecing THEN
			xInchDecing := TRUE;
			iDecCnt := REAL_TO_INT(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur*1000/(i_rAcc_Inch*1000/gc_TENSION_TSK_CYCLE_TIME)/gc_TENSION_TSK_CYCLE_TIME+0.5);
			o_diVel_Virtual_Tar_Inch := LREAL_TO_DINT(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rVel_Inch
																	*GC_LRMOTORPPR/
																	gc_rGirth_Master/60.0/1000);
			o_lrMax_a_S_pos_Inch:= 1;
			//点动速度为5米/分
			IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xPrintInching THEN
				o_diVel_Virtual_Tar_Inch := LREAL_TO_DINT(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Inching_Print
																	*GC_LRMOTORPPR/
																	gc_rGirth_Master/60.0/1000);
			END_IF
			
			IF xPrintInching_Pre <>i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xPrintInching THEN
				xPrintInching_Lasting := TRUE;
			END_IF
		ELSIF xInchDecing THEN
			o_diVel_Virtual_Tar_Inch := LREAL_TO_DINT(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rVel_Inch
																	*GC_LRMOTORPPR/
																	gc_rGirth_Master/60.0/1000);
			o_lrMax_a_S_pos_Inch:= 1;
			//点动速度为5米/分
			IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xPrintInching OR xPrintInching_Lasting THEN
				o_diVel_Virtual_Tar_Inch := LREAL_TO_DINT(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Inching_Print
																	*GC_LRMOTORPPR/
																	gc_rGirth_Master/60.0/1000);
			END_IF
			iInchDecCnt := iInchDecCnt + 1;
			IF iInchDecCnt > iDecCnt THEN//8*1000/gc_TENSION_TSK_CYCLE_TIME THEN
				iInchDecCnt := 0;
				xInchDecing := FALSE;
				xPrintInching_Lasting := FALSE;
			END_IF
		ELSE
			o_xHasAxisOnInchRunningSts:= FALSE;	;
			//adiVel_Virtual_Tar_Inch[iUnitId] := 0;
			o_diVel_Virtual_Tar_Inch := 0;
			o_lrMax_a_S_pos_Inch:= 1;

			xInchDecing := FALSE;
			xPrintInching_Lasting := FALSE;
		END_IF
		diVel_Virtual_Tar_Inch_Pre := o_diVel_Virtual_Tar_Inch;
		xHasAxisOnInchRunningSts_Pre := xHasAxisOnInchRunningSts;
		xPrintInching_Pre := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xPrintInching;
		o_xInchDecing := xInchDecing;
		//2025.10.28.140948 | bai.zy | 输出速度
// 		FOR iN := 1 TO i_iGrpAxisNum_Pu BY 1 DO
// 			iUnitId:= i_aiGrpAxisList[iN];(*轴id|*)
// 			IF (i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_If_Roller OR i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_Of_Roller OR
// 				i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xInching_NetRoller  OR i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xInching_BottomRoller OR i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisInching) AND
// 				 adiVel_Virtual_Tar_Inch[iN] <> 0 THEN
// 				o_diVel_Virtual_Tar_Inch :=  adiVel_Virtual_Tar_Inch[iN];
// 				EXIT;
// 			END_IF
// 		END_FOR		
	ELSE;
	END_IF
END_IF
