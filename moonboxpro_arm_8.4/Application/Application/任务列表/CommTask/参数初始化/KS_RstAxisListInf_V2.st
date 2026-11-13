(*@CES
Name=KS_RstAxisListInf_V2
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=0f4af13f-6f8f-4e35-9417-a16a44e0dc0e
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_RstAxisListInf_V2 : BOOL
VAR_INPUT
	i_xEn: BOOL;
	i_byMachineMode: BYTE;(*=0:凹印机：=1柔印机*)
	i_pastStAxisIdListInf :POINTER TO ARRAY [1..128] OF StAxisIdListInf;
END_VAR
VAR
	iN: INT;
	xResult: BOOL;
END_VAR


{IMPLEMENTATION}
xResult:=FALSE;
IF i_xEn AND i_pastStAxisIdListInf<>0 THEN
(*配置核1-全部为电子齿轮参数配置
核2-龙门、点位、虚拟主轴、中心辊等
*)
(*凹印机配置参数文件*)
	IF i_byMachineMode=0 THEN
		FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
			(*凹印机实轴*)
			i_pastStAxisIdListInf^[iN].iAxisId:= iN;
			i_pastStAxisIdListInf^[iN].iCoreId:= 1;
			i_pastStAxisIdListInf^[iN].iUnitId:=iN;
			i_pastStAxisIdListInf^[iN].iTypeId:= TYPE_UNIT_PRN;
			i_pastStAxisIdListInf^[iN].iStdId:= iN+MAX_UNIT_NUM;
			(*凹印机叠加轴*)
			i_pastStAxisIdListInf^[iN+20].iAxisId:= iN+20;
			i_pastStAxisIdListInf^[iN+20].iCoreId:= 1;
			i_pastStAxisIdListInf^[iN+20].iUnitId:=iN;
			i_pastStAxisIdListInf^[iN+20].iTypeId:= TYPE_UNIT_ADJ;
			i_pastStAxisIdListInf^[iN+20].iStdId:= -1;		

// 			i_pastStAxisIdListInf^[iN+2*MAX_UNIT_NUM].iAxisId:= iN+2*MAX_UNIT_NUM;
// 			i_pastStAxisIdListInf^[iN+2*MAX_UNIT_NUM].iCoreId:= 1;
// 			i_pastStAxisIdListInf^[iN+2*MAX_UNIT_NUM].iUnitId:= iN;
// 			i_pastStAxisIdListInf^[iN+2*MAX_UNIT_NUM].iTypeId:= TYPE_UNIT_HORIZ;
// 			i_pastStAxisIdListInf^[iN+2*MAX_UNIT_NUM].iStdId:= 160+iN;		
		END_FOR	
		
		i_pastStAxisIdListInf^[17].iAxisId:= 10;
		i_pastStAxisIdListInf^[17].iCoreId:= 1;
		i_pastStAxisIdListInf^[17].iUnitId:= -1;
		i_pastStAxisIdListInf^[17].iTypeId:= TYPE_INFEED_I;
		i_pastStAxisIdListInf^[17].iStdId:= 72;
		
		i_pastStAxisIdListInf^[18].iAxisId:= 11;
		i_pastStAxisIdListInf^[18].iCoreId:= 1;
		i_pastStAxisIdListInf^[18].iUnitId:= -1;
		i_pastStAxisIdListInf^[18].iTypeId:= TYPE_OUTFEED_I;
		i_pastStAxisIdListInf^[18].iStdId:= 73;		
		
		i_pastStAxisIdListInf^[51].iAxisId:= 51;
		i_pastStAxisIdListInf^[51].iCoreId:= 1;
		i_pastStAxisIdListInf^[51].iUnitId:= -1;
		i_pastStAxisIdListInf^[51].iTypeId:= TYPE_UNWIND_A_I;
		i_pastStAxisIdListInf^[51].iStdId:= 48;
		
		i_pastStAxisIdListInf^[52].iAxisId:= 52;
		i_pastStAxisIdListInf^[52].iCoreId:= 1;
		i_pastStAxisIdListInf^[52].iUnitId:= -1;
		i_pastStAxisIdListInf^[52].iTypeId:= TYPE_UNWIND_B_I;
		i_pastStAxisIdListInf^[52].iStdId:= 49;	
		
		i_pastStAxisIdListInf^[53].iAxisId:= 53;
		i_pastStAxisIdListInf^[53].iCoreId:= 1;
		i_pastStAxisIdListInf^[53].iUnitId:= -1;
		i_pastStAxisIdListInf^[53].iTypeId:= TYPE_REWIND_A_I;
		i_pastStAxisIdListInf^[53].iStdId:= 50;
		
		i_pastStAxisIdListInf^[54].iAxisId:= 54;
		i_pastStAxisIdListInf^[54].iCoreId:= 1;
		i_pastStAxisIdListInf^[54].iUnitId:= -1;
		i_pastStAxisIdListInf^[54].iTypeId:= TYPE_REWIND_B_I;
		i_pastStAxisIdListInf^[54].iStdId:= 51;		

		
		i_pastStAxisIdListInf^[55].iAxisId:= 55;
		i_pastStAxisIdListInf^[55].iCoreId:= 1;
		i_pastStAxisIdListInf^[55].iUnitId:= -1;
		i_pastStAxisIdListInf^[55].iTypeId:= TYPE_INFEED_II;
		i_pastStAxisIdListInf^[55].iStdId:= 58;
		
		i_pastStAxisIdListInf^[56].iAxisId:= 56;
		i_pastStAxisIdListInf^[56].iCoreId:= 1;
		i_pastStAxisIdListInf^[56].iUnitId:= -1;
		i_pastStAxisIdListInf^[56].iTypeId:= TYPE_OUTFEED_II;
		i_pastStAxisIdListInf^[56].iStdId:= 59;		
		
		i_pastStAxisIdListInf^[57].iAxisId:= 57;
		i_pastStAxisIdListInf^[57].iCoreId:= 1;
		i_pastStAxisIdListInf^[57].iUnitId:= -1;
		i_pastStAxisIdListInf^[57].iTypeId:= TYPE_UNWIND_A_II;
		i_pastStAxisIdListInf^[57].iStdId:= 52;
		
		i_pastStAxisIdListInf^[58].iAxisId:= 58;
		i_pastStAxisIdListInf^[58].iCoreId:= 1;
		i_pastStAxisIdListInf^[58].iUnitId:= -1;
		i_pastStAxisIdListInf^[58].iTypeId:= TYPE_UNWIND_B_II;
		i_pastStAxisIdListInf^[58].iStdId:= 53;	
		
		i_pastStAxisIdListInf^[59].iAxisId:= 59;
		i_pastStAxisIdListInf^[59].iCoreId:= 1;
		i_pastStAxisIdListInf^[59].iUnitId:= -1;
		i_pastStAxisIdListInf^[59].iTypeId:= TYPE_REWIND_A_II;
		i_pastStAxisIdListInf^[59].iStdId:= 54;
		
		i_pastStAxisIdListInf^[60].iAxisId:= 60;
		i_pastStAxisIdListInf^[60].iCoreId:= 1;
		i_pastStAxisIdListInf^[60].iUnitId:= -1;
		i_pastStAxisIdListInf^[60].iTypeId:= TYPE_REWIND_B_II;
		i_pastStAxisIdListInf^[60].iStdId:= 55;		
		
		
		i_pastStAxisIdListInf^[63].iAxisId:= 63;
		i_pastStAxisIdListInf^[63].iCoreId:= 1;
		i_pastStAxisIdListInf^[63].iUnitId:= -1;
		i_pastStAxisIdListInf^[63].iTypeId:= TYPE_MASTER_II;
		i_pastStAxisIdListInf^[63].iStdId:= -1;
		i_pastStAxisIdListInf^[64].iAxisId:= 64;
		i_pastStAxisIdListInf^[64].iCoreId:= 1;
		i_pastStAxisIdListInf^[64].iUnitId:= -1;
		i_pastStAxisIdListInf^[64].iTypeId:= TYPE_MASTER_I;
		i_pastStAxisIdListInf^[64].iStdId:= -1;		
	ELSIF i_byMachineMode=1 THEN(*柔印全伺服先按10色-加中心辊，横向*)
		FOR iN:=1 TO 10 BY 1 DO
			(*柔印机实轴*)
			i_pastStAxisIdListInf^[iN].iAxisId:= iN;
			i_pastStAxisIdListInf^[iN].iCoreId:= 1;
			i_pastStAxisIdListInf^[iN].iUnitId:=iN;
			i_pastStAxisIdListInf^[iN].iTypeId:= TYPE_UNIT_PRN;
			i_pastStAxisIdListInf^[iN].iStdId:= iN + 16;

			i_pastStAxisIdListInf^[iN+10].iAxisId:= iN+10;
			i_pastStAxisIdListInf^[iN+10].iCoreId:= 1;
			i_pastStAxisIdListInf^[iN+10].iUnitId:=iN;
			i_pastStAxisIdListInf^[iN+10].iTypeId:= TYPE_UNIT_BOTTOM;
			i_pastStAxisIdListInf^[iN+10].iStdId:= iN+16;	
		
			i_pastStAxisIdListInf^[iN+20].iAxisId:= iN+20;
			i_pastStAxisIdListInf^[iN+20].iCoreId:= 1;
			i_pastStAxisIdListInf^[iN+20].iUnitId:=iN;
			i_pastStAxisIdListInf^[iN+20].iTypeId:= TYPE_UNIT_NET;
			i_pastStAxisIdListInf^[iN+20].iStdId:= iN+32;	
			(*柔印机叠加轴*)
			i_pastStAxisIdListInf^[iN+30].iAxisId:= iN+30;
			i_pastStAxisIdListInf^[iN+30].iCoreId:= 1;
			i_pastStAxisIdListInf^[iN+30].iUnitId:=iN;
			i_pastStAxisIdListInf^[iN+30].iTypeId:= TYPE_UNIT_ADJ;
			i_pastStAxisIdListInf^[iN+30].iStdId:= -1;		

			i_pastStAxisIdListInf^[iN+40].iAxisId:= iN+40;
			i_pastStAxisIdListInf^[iN+40].iCoreId:= 1;
			i_pastStAxisIdListInf^[iN+40].iUnitId:= iN;
			i_pastStAxisIdListInf^[iN+40].iTypeId:= TYPE_UNIT_HORIZ;
			i_pastStAxisIdListInf^[iN+40].iStdId:= 160+iN;		
		END_FOR
		i_pastStAxisIdListInf^[51].iAxisId:= 51;
		i_pastStAxisIdListInf^[51].iCoreId:= 1;
		i_pastStAxisIdListInf^[51].iUnitId:= -1;
		i_pastStAxisIdListInf^[51].iTypeId:= TYPE_INFEED_I;
		i_pastStAxisIdListInf^[51].iStdId:= 56;
		
		i_pastStAxisIdListInf^[52].iAxisId:= 52;
		i_pastStAxisIdListInf^[52].iCoreId:= 1;
		i_pastStAxisIdListInf^[52].iUnitId:= -1;
		i_pastStAxisIdListInf^[52].iTypeId:= TYPE_OUTFEED_I;
		i_pastStAxisIdListInf^[52].iStdId:= 57;		
		
		i_pastStAxisIdListInf^[53].iAxisId:= 53;
		i_pastStAxisIdListInf^[53].iCoreId:= 1;
		i_pastStAxisIdListInf^[53].iUnitId:= -1;
		i_pastStAxisIdListInf^[53].iTypeId:= TYPE_UNWIND_A_I;
		i_pastStAxisIdListInf^[53].iStdId:= 48;
		
		i_pastStAxisIdListInf^[54].iAxisId:= 54;
		i_pastStAxisIdListInf^[54].iCoreId:= 1;
		i_pastStAxisIdListInf^[54].iUnitId:= -1;
		i_pastStAxisIdListInf^[54].iTypeId:= TYPE_UNWIND_B_I;
		i_pastStAxisIdListInf^[54].iStdId:= 49;	
		
		i_pastStAxisIdListInf^[55].iAxisId:= 55;
		i_pastStAxisIdListInf^[55].iCoreId:= 1;
		i_pastStAxisIdListInf^[55].iUnitId:= -1;
		i_pastStAxisIdListInf^[55].iTypeId:= TYPE_REWIND_A_I;
		i_pastStAxisIdListInf^[55].iStdId:= 50;
		
		i_pastStAxisIdListInf^[56].iAxisId:= 56;
		i_pastStAxisIdListInf^[56].iCoreId:= 1;
		i_pastStAxisIdListInf^[56].iUnitId:= -1;
		i_pastStAxisIdListInf^[56].iTypeId:= TYPE_REWIND_B_I;
		i_pastStAxisIdListInf^[56].iStdId:= 51;		

		
		i_pastStAxisIdListInf^[57].iAxisId:= 57;
		i_pastStAxisIdListInf^[57].iCoreId:= 1;
		i_pastStAxisIdListInf^[57].iUnitId:= -1;
		i_pastStAxisIdListInf^[57].iTypeId:= TYPE_INFEED_II;
		i_pastStAxisIdListInf^[57].iStdId:= 58;
		
		i_pastStAxisIdListInf^[58].iAxisId:= 58;
		i_pastStAxisIdListInf^[58].iCoreId:= 1;
		i_pastStAxisIdListInf^[58].iUnitId:= -1;
		i_pastStAxisIdListInf^[58].iTypeId:= TYPE_OUTFEED_II;
		i_pastStAxisIdListInf^[58].iStdId:= 59;		
		
		i_pastStAxisIdListInf^[59].iAxisId:= 59;
		i_pastStAxisIdListInf^[59].iCoreId:= 1;
		i_pastStAxisIdListInf^[59].iUnitId:= -1;
		i_pastStAxisIdListInf^[59].iTypeId:= TYPE_UNWIND_A_II;
		i_pastStAxisIdListInf^[59].iStdId:= 52;
		
		i_pastStAxisIdListInf^[60].iAxisId:= 60;
		i_pastStAxisIdListInf^[60].iCoreId:= 1;
		i_pastStAxisIdListInf^[60].iUnitId:= -1;
		i_pastStAxisIdListInf^[60].iTypeId:= TYPE_UNWIND_B_II;
		i_pastStAxisIdListInf^[60].iStdId:= 53;	
		
		i_pastStAxisIdListInf^[61].iAxisId:= 61;
		i_pastStAxisIdListInf^[61].iCoreId:= 1;
		i_pastStAxisIdListInf^[61].iUnitId:= -1;
		i_pastStAxisIdListInf^[61].iTypeId:= TYPE_REWIND_A_II;
		i_pastStAxisIdListInf^[61].iStdId:= 54;
		
		i_pastStAxisIdListInf^[62].iAxisId:= 62;
		i_pastStAxisIdListInf^[62].iCoreId:= 1;
		i_pastStAxisIdListInf^[62].iUnitId:= -1;
		i_pastStAxisIdListInf^[62].iTypeId:= TYPE_REWIND_B_II;
		i_pastStAxisIdListInf^[62].iStdId:= 55;		
					
		i_pastStAxisIdListInf^[63].iAxisId:= 63;
		i_pastStAxisIdListInf^[63].iCoreId:= 1;
		i_pastStAxisIdListInf^[63].iUnitId:= -1;
		i_pastStAxisIdListInf^[63].iTypeId:= TYPE_CENTRAL_II;
		i_pastStAxisIdListInf^[63].iStdId:= 32;
		i_pastStAxisIdListInf^[64].iAxisId:= 64;
		i_pastStAxisIdListInf^[64].iCoreId:= 1;
		i_pastStAxisIdListInf^[64].iUnitId:= -1;
		i_pastStAxisIdListInf^[64].iTypeId:= TYPE_CENTRAL_I;
		i_pastStAxisIdListInf^[64].iStdId:= 16;
		
		
		FOR iN:=1 TO 10 BY 1 DO
			i_pastStAxisIdListInf^[iN+64].iAxisId:= iN;
			i_pastStAxisIdListInf^[iN+64].iCoreId:= 2;
			i_pastStAxisIdListInf^[iN+64].iUnitId:= iN;
			i_pastStAxisIdListInf^[iN+64].iTypeId:= TYPE_UNIT_PRN_PRESS_MASTER;
			i_pastStAxisIdListInf^[iN+64].iStdId:= 96+iN;
			i_pastStAxisIdListInf^[iN+64].iGroupId:= iN;

			i_pastStAxisIdListInf^[iN+64+10].iAxisId:= iN+10;
			i_pastStAxisIdListInf^[iN+64+10].iCoreId:= 2;
			i_pastStAxisIdListInf^[iN+64+10].iUnitId:= iN;
			i_pastStAxisIdListInf^[iN+64+10].iTypeId:= TYPE_UNIT_PRN_PRESS_G;
			i_pastStAxisIdListInf^[iN+64+10].iStdId:= 112+iN;
			i_pastStAxisIdListInf^[iN+64+10].iGroupId:= iN;
			
			i_pastStAxisIdListInf^[iN+64+20].iAxisId:= iN+20;
			i_pastStAxisIdListInf^[iN+64+20].iCoreId:= 2;
			i_pastStAxisIdListInf^[iN+64+20].iUnitId:= iN;
			i_pastStAxisIdListInf^[iN+64+20].iTypeId:= TYPE_UNIT_PRN_PRESS_M;
			i_pastStAxisIdListInf^[iN+64+20].iStdId:= -1;
			i_pastStAxisIdListInf^[iN+64+20].iGroupId:= iN;


			i_pastStAxisIdListInf^[iN+64+30].iAxisId:= iN+30;
			i_pastStAxisIdListInf^[iN+64+30].iCoreId:= 2;
			i_pastStAxisIdListInf^[iN+64+30].iUnitId:= iN;
			i_pastStAxisIdListInf^[iN+64+30].iTypeId:= TYPE_UNIT_NET_PRESS_MASTER;
			i_pastStAxisIdListInf^[iN+64+30].iStdId:= 128+iN;
			i_pastStAxisIdListInf^[iN+64+30].iGroupId:= iN + 10;

			i_pastStAxisIdListInf^[iN+64+40].iAxisId:= iN+40;
			i_pastStAxisIdListInf^[iN+64+40].iCoreId:= 2;
			i_pastStAxisIdListInf^[iN+64+40].iUnitId:= iN;
			i_pastStAxisIdListInf^[iN+64+40].iTypeId:= TYPE_UNIT_NET_PRESS_G;
			i_pastStAxisIdListInf^[iN+64+40].iStdId:= 144+iN;
			i_pastStAxisIdListInf^[iN+64+40].iGroupId:= iN + 10;
			
			i_pastStAxisIdListInf^[iN+64+50].iAxisId:= iN+50;
			i_pastStAxisIdListInf^[iN+64+50].iCoreId:= 2;
			i_pastStAxisIdListInf^[iN+64+50].iUnitId:= iN;
			i_pastStAxisIdListInf^[iN+64+50].iTypeId:= TYPE_UNIT_NET_PRESS_M;
			i_pastStAxisIdListInf^[iN+64+50].iStdId:= -1;
			i_pastStAxisIdListInf^[iN+64+50].iGroupId:= iN + 10;
		
		END_FOR			
		i_pastStAxisIdListInf^[127].iAxisId:= 63;
		i_pastStAxisIdListInf^[127].iCoreId:= 2;
		i_pastStAxisIdListInf^[127].iUnitId:= -1;
		i_pastStAxisIdListInf^[127].iTypeId:= TYPE_MASTER_II;
		i_pastStAxisIdListInf^[127].iStdId:= -1;
		i_pastStAxisIdListInf^[128].iAxisId:= 64;
		i_pastStAxisIdListInf^[128].iCoreId:= 2;
		i_pastStAxisIdListInf^[128].iUnitId:= -1;
		i_pastStAxisIdListInf^[128].iTypeId:= TYPE_MASTER_I;
		i_pastStAxisIdListInf^[128].iStdId:= -1;	
		
	END_IF
	
ELSE
	;
END_IF
KS_RstAxisListInf_V2:= xResult;