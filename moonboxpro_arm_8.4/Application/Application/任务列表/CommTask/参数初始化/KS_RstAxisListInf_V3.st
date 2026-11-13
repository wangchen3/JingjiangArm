(*@CES
Name=KS_RstAxisListInf_V3
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=c78075be-04fd-4462-bf75-53f9e858ed92
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_RstAxisListInf_V3 : BOOL
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
			i_pastStAxisIdListInf^[iN].iAdjAxisId:= iN+MAX_UNIT_NUM;
			                       
			i_pastStAxisIdListInf^[MAX_UNIT_NUM+iN].iAxisId:= iN + MAX_UNIT_NUM;
			i_pastStAxisIdListInf^[MAX_UNIT_NUM+iN].iCoreId:= 1;
			i_pastStAxisIdListInf^[MAX_UNIT_NUM+iN].iUnitId:=iN;
			i_pastStAxisIdListInf^[MAX_UNIT_NUM+iN].iTypeId:= TYPE_UNIT_ADJ;
			i_pastStAxisIdListInf^[MAX_UNIT_NUM+iN].iStdId:= -1;	
			i_pastStAxisIdListInf^[MAX_UNIT_NUM+iN].iAdjAxisId:= -1;
		END_FOR
		
		i_pastStAxisIdListInf^[33].iAxisId:= 1;
		i_pastStAxisIdListInf^[33].iCoreId:= 2;
		i_pastStAxisIdListInf^[33].iUnitId:= -1;
		i_pastStAxisIdListInf^[33].iTypeId:= TYPE_INFEED_I;
		i_pastStAxisIdListInf^[33].iStdId:= 72;
		i_pastStAxisIdListInf^[33].iAdjAxisId:= -1;
		
		i_pastStAxisIdListInf^[34].iAxisId:= 2;
		i_pastStAxisIdListInf^[34].iCoreId:= 2;
		i_pastStAxisIdListInf^[34].iUnitId:= -1;
		i_pastStAxisIdListInf^[34].iTypeId:= TYPE_OUTFEED_I;
		i_pastStAxisIdListInf^[34].iStdId:= 73;	
		i_pastStAxisIdListInf^[34].iAdjAxisId:= -1;	

		i_pastStAxisIdListInf^[35].iAxisId:= 3;
		i_pastStAxisIdListInf^[35].iCoreId:= 2;
		i_pastStAxisIdListInf^[35].iUnitId:= -1;
		i_pastStAxisIdListInf^[35].iTypeId:= TYPE_UNWIND_A_I;
		i_pastStAxisIdListInf^[35].iStdId:= 64;
		i_pastStAxisIdListInf^[35].iAdjAxisId:= -1;
		
		i_pastStAxisIdListInf^[36].iAxisId:= 4;
		i_pastStAxisIdListInf^[36].iCoreId:= 2;
		i_pastStAxisIdListInf^[36].iUnitId:= -1;
		i_pastStAxisIdListInf^[36].iTypeId:= TYPE_UNWIND_B_I;
		i_pastStAxisIdListInf^[36].iStdId:= 65;	
		i_pastStAxisIdListInf^[36].iAdjAxisId:= -1;
		
		i_pastStAxisIdListInf^[37].iAxisId:= 5;
		i_pastStAxisIdListInf^[37].iCoreId:= 2;
		i_pastStAxisIdListInf^[37].iUnitId:= -1;
		i_pastStAxisIdListInf^[37].iTypeId:= TYPE_REWIND_A_I;
		i_pastStAxisIdListInf^[37].iStdId:= 66;
		i_pastStAxisIdListInf^[37].iAdjAxisId:= -1;
		
		i_pastStAxisIdListInf^[38].iAxisId:= 6;
		i_pastStAxisIdListInf^[38].iCoreId:= 2;
		i_pastStAxisIdListInf^[38].iUnitId:= -1;
		i_pastStAxisIdListInf^[38].iTypeId:= TYPE_REWIND_B_I;
		i_pastStAxisIdListInf^[38].iStdId:= 67;
		i_pastStAxisIdListInf^[38].iAdjAxisId:= -1;	

		i_pastStAxisIdListInf^[39].iAxisId:= 7;
		i_pastStAxisIdListInf^[39].iCoreId:= 2;
		i_pastStAxisIdListInf^[39].iUnitId:= -1;
		i_pastStAxisIdListInf^[39].iTypeId:= TYPE_INFEED_II;
		i_pastStAxisIdListInf^[39].iStdId:= 74;
		i_pastStAxisIdListInf^[39].iAdjAxisId:= -1;
		
		i_pastStAxisIdListInf^[40].iAxisId:= 8;
		i_pastStAxisIdListInf^[40].iCoreId:= 2;
		i_pastStAxisIdListInf^[40].iUnitId:= -1;
		i_pastStAxisIdListInf^[40].iTypeId:= TYPE_OUTFEED_II;
		i_pastStAxisIdListInf^[40].iStdId:= 75;	
		i_pastStAxisIdListInf^[40].iAdjAxisId:= -1;

		i_pastStAxisIdListInf^[41].iAxisId:= 9;
		i_pastStAxisIdListInf^[41].iCoreId:= 2;
		i_pastStAxisIdListInf^[41].iUnitId:= -1;
		i_pastStAxisIdListInf^[41].iTypeId:= TYPE_UNWIND_A_II;
		i_pastStAxisIdListInf^[41].iStdId:= 68;
		i_pastStAxisIdListInf^[41].iAdjAxisId:= -1;
		
		i_pastStAxisIdListInf^[42].iAxisId:= 10;
		i_pastStAxisIdListInf^[42].iCoreId:= 2;
		i_pastStAxisIdListInf^[42].iUnitId:= -1;
		i_pastStAxisIdListInf^[42].iTypeId:= TYPE_UNWIND_B_II;
		i_pastStAxisIdListInf^[42].iStdId:= 69;	
		i_pastStAxisIdListInf^[42].iAdjAxisId:= -1;
		
		i_pastStAxisIdListInf^[43].iAxisId:= 11;
		i_pastStAxisIdListInf^[43].iCoreId:= 2;
		i_pastStAxisIdListInf^[43].iUnitId:= -1;
		i_pastStAxisIdListInf^[43].iTypeId:= TYPE_REWIND_A_II;
		i_pastStAxisIdListInf^[43].iStdId:= 70;
		i_pastStAxisIdListInf^[43].iAdjAxisId:= -1;
		
		i_pastStAxisIdListInf^[44].iAxisId:= 12;
		i_pastStAxisIdListInf^[44].iCoreId:= 2;
		i_pastStAxisIdListInf^[44].iUnitId:= -1;
		i_pastStAxisIdListInf^[44].iTypeId:= TYPE_REWIND_B_II;
		i_pastStAxisIdListInf^[44].iStdId:= 71;
		i_pastStAxisIdListInf^[44].iAdjAxisId:= -1;	

		i_pastStAxisIdListInf^[63].iAxisId:= 31;
		i_pastStAxisIdListInf^[63].iCoreId:= 2;
		i_pastStAxisIdListInf^[63].iUnitId:= -1;
		i_pastStAxisIdListInf^[63].iTypeId:= TYPE_MASTER_II;
		i_pastStAxisIdListInf^[63].iStdId:= -1;
		i_pastStAxisIdListInf^[63].iAdjAxisId:= -1;
		
		i_pastStAxisIdListInf^[64].iAxisId:= 32;
		i_pastStAxisIdListInf^[64].iCoreId:= 2;
		i_pastStAxisIdListInf^[64].iUnitId:= -1;
		i_pastStAxisIdListInf^[64].iTypeId:= TYPE_MASTER_I;
		i_pastStAxisIdListInf^[64].iStdId:= -1;	
		i_pastStAxisIdListInf^[64].iAdjAxisId:= -1;	
	
					
	ELSIF i_byMachineMode=1 THEN(*柔印全伺服先按10色-加中心辊，横向*)
		FOR iN:=1 TO 10 BY 1 DO
			(*柔印机实轴*)
			i_pastStAxisIdListInf^[iN].iAxisId:= iN;
			i_pastStAxisIdListInf^[iN].iCoreId:= 1;
			i_pastStAxisIdListInf^[iN].iUnitId:=iN;
			i_pastStAxisIdListInf^[iN].iTypeId:= TYPE_UNIT_PRN;
			i_pastStAxisIdListInf^[iN].iStdId:= iN + 16;
			i_pastStAxisIdListInf^[iN].iAdjAxisId:= iN+40;

			i_pastStAxisIdListInf^[iN+10].iAxisId:= iN+10;
			i_pastStAxisIdListInf^[iN+10].iCoreId:= 1;
			i_pastStAxisIdListInf^[iN+10].iUnitId:=iN;
			i_pastStAxisIdListInf^[iN+10].iTypeId:= TYPE_UNIT_BOTTOM;
			i_pastStAxisIdListInf^[iN+10].iStdId:= iN+32;
			i_pastStAxisIdListInf^[iN+10].iAdjAxisId:= -1;	
		
			i_pastStAxisIdListInf^[iN+20].iAxisId:= iN+20;
			i_pastStAxisIdListInf^[iN+20].iCoreId:= 1;
			i_pastStAxisIdListInf^[iN+20].iUnitId:=iN;
			i_pastStAxisIdListInf^[iN+20].iTypeId:= TYPE_UNIT_NET;
			i_pastStAxisIdListInf^[iN+20].iStdId:= iN+48;
			i_pastStAxisIdListInf^[iN+20].iAdjAxisId:= -1;		

			i_pastStAxisIdListInf^[iN+30].iAxisId:= iN+30;
			i_pastStAxisIdListInf^[iN+30].iCoreId:= 1;
			i_pastStAxisIdListInf^[iN+30].iUnitId:= iN;
			i_pastStAxisIdListInf^[iN+30].iTypeId:= TYPE_UNIT_HORIZ;
			i_pastStAxisIdListInf^[iN+30].iStdId:= iN + 160;	
			i_pastStAxisIdListInf^[iN+30].iAdjAxisId:= -1;

			i_pastStAxisIdListInf^[iN+52].iAxisId:= iN+52;
			i_pastStAxisIdListInf^[iN+52].iCoreId:= 1;
			i_pastStAxisIdListInf^[iN+52].iUnitId:= iN;
			i_pastStAxisIdListInf^[iN+52].iTypeId:= TYPE_UNIT_ADJ;
			i_pastStAxisIdListInf^[iN+52].iStdId:= -1;	
			i_pastStAxisIdListInf^[iN+52].iAdjAxisId:= -1;	
		END_FOR
		
		i_pastStAxisIdListInf^[41].iAxisId:= 41;
		i_pastStAxisIdListInf^[41].iCoreId:= 1;
		i_pastStAxisIdListInf^[41].iUnitId:= -1;
		i_pastStAxisIdListInf^[41].iTypeId:= TYPE_UNWIND_A_I;
		i_pastStAxisIdListInf^[41].iStdId:= 64;
		i_pastStAxisIdListInf^[41].iAdjAxisId:= -1;
		
		i_pastStAxisIdListInf^[42].iAxisId:= 42;
		i_pastStAxisIdListInf^[42].iCoreId:= 1;
		i_pastStAxisIdListInf^[42].iUnitId:= -1;
		i_pastStAxisIdListInf^[42].iTypeId:= TYPE_UNWIND_B_I;
		i_pastStAxisIdListInf^[42].iStdId:= 65;
		i_pastStAxisIdListInf^[42].iAdjAxisId:= -1;	
		
		i_pastStAxisIdListInf^[43].iAxisId:= 43;
		i_pastStAxisIdListInf^[43].iCoreId:= 1;
		i_pastStAxisIdListInf^[43].iUnitId:= -1;
		i_pastStAxisIdListInf^[43].iTypeId:= TYPE_REWIND_A_I;
		i_pastStAxisIdListInf^[43].iStdId:= 66;
		i_pastStAxisIdListInf^[43].iAdjAxisId:= -1;
		
		i_pastStAxisIdListInf^[44].iAxisId:= 44;
		i_pastStAxisIdListInf^[44].iCoreId:= 1;
		i_pastStAxisIdListInf^[44].iUnitId:= -1;
		i_pastStAxisIdListInf^[44].iTypeId:= TYPE_REWIND_B_I;
		i_pastStAxisIdListInf^[44].iStdId:= 67;
		i_pastStAxisIdListInf^[44].iAdjAxisId:= -1;		
		
		i_pastStAxisIdListInf^[45].iAxisId:= 45;
		i_pastStAxisIdListInf^[45].iCoreId:= 1;
		i_pastStAxisIdListInf^[45].iUnitId:= -1;
		i_pastStAxisIdListInf^[45].iTypeId:= TYPE_UNWIND_A_II;
		i_pastStAxisIdListInf^[45].iStdId:= 68;
		i_pastStAxisIdListInf^[45].iAdjAxisId:= -1;
		
		i_pastStAxisIdListInf^[46].iAxisId:= 46;
		i_pastStAxisIdListInf^[46].iCoreId:= 1;
		i_pastStAxisIdListInf^[46].iUnitId:= -1;
		i_pastStAxisIdListInf^[46].iTypeId:= TYPE_UNWIND_B_II;
		i_pastStAxisIdListInf^[46].iStdId:= 69;
		i_pastStAxisIdListInf^[46].iAdjAxisId:= -1;	
		
		i_pastStAxisIdListInf^[47].iAxisId:= 47;
		i_pastStAxisIdListInf^[47].iCoreId:= 1;
		i_pastStAxisIdListInf^[47].iUnitId:= -1;
		i_pastStAxisIdListInf^[47].iTypeId:= TYPE_REWIND_A_II;
		i_pastStAxisIdListInf^[47].iStdId:= 70;
		i_pastStAxisIdListInf^[47].iAdjAxisId:= -1;
		
		i_pastStAxisIdListInf^[48].iAxisId:= 48;
		i_pastStAxisIdListInf^[48].iCoreId:= 1;
		i_pastStAxisIdListInf^[48].iUnitId:= -1;
		i_pastStAxisIdListInf^[48].iTypeId:= TYPE_REWIND_B_II;
		i_pastStAxisIdListInf^[48].iStdId:= 71;
		i_pastStAxisIdListInf^[48].iAdjAxisId:= -1;	

		i_pastStAxisIdListInf^[49].iAxisId:= 49;
		i_pastStAxisIdListInf^[49].iCoreId:= 1;
		i_pastStAxisIdListInf^[49].iUnitId:= -1;
		i_pastStAxisIdListInf^[49].iTypeId:= TYPE_INFEED_I;
		i_pastStAxisIdListInf^[49].iStdId:= 72;
		i_pastStAxisIdListInf^[49].iAdjAxisId:= -1;	
		
		i_pastStAxisIdListInf^[50].iAxisId:= 50;
		i_pastStAxisIdListInf^[50].iCoreId:= 1;
		i_pastStAxisIdListInf^[50].iUnitId:= -1;
		i_pastStAxisIdListInf^[50].iTypeId:= TYPE_OUTFEED_I;
		i_pastStAxisIdListInf^[50].iStdId:= 73;	
		i_pastStAxisIdListInf^[50].iAdjAxisId:= -1;	
		
		i_pastStAxisIdListInf^[51].iAxisId:= 51;
		i_pastStAxisIdListInf^[51].iCoreId:= 1;
		i_pastStAxisIdListInf^[51].iUnitId:= -1;
		i_pastStAxisIdListInf^[51].iTypeId:= TYPE_INFEED_II;
		i_pastStAxisIdListInf^[51].iStdId:= 74;
		i_pastStAxisIdListInf^[51].iAdjAxisId:= -1;
		
		i_pastStAxisIdListInf^[52].iAxisId:= 52;
		i_pastStAxisIdListInf^[52].iCoreId:= 1;
		i_pastStAxisIdListInf^[52].iUnitId:= -1;
		i_pastStAxisIdListInf^[52].iTypeId:= TYPE_OUTFEED_II;
		i_pastStAxisIdListInf^[52].iStdId:= 75;
		i_pastStAxisIdListInf^[52].iAdjAxisId:= -1;	
					
		i_pastStAxisIdListInf^[63].iAxisId:= 63;
		i_pastStAxisIdListInf^[63].iCoreId:= 1;
		i_pastStAxisIdListInf^[63].iUnitId:= -1;
		i_pastStAxisIdListInf^[63].iTypeId:= TYPE_CENTRAL_II;
		i_pastStAxisIdListInf^[63].iStdId:= 32;
		i_pastStAxisIdListInf^[63].iAdjAxisId:= -1;
		
		i_pastStAxisIdListInf^[64].iAxisId:= 64;
		i_pastStAxisIdListInf^[64].iCoreId:= 1;
		i_pastStAxisIdListInf^[64].iUnitId:= -1;
		i_pastStAxisIdListInf^[64].iTypeId:= TYPE_CENTRAL_I;
		i_pastStAxisIdListInf^[64].iStdId:= 16;
		i_pastStAxisIdListInf^[64].iAdjAxisId:= -1;
		
		
		FOR iN:=1 TO 10 BY 1 DO
			i_pastStAxisIdListInf^[iN+64].iAxisId:= iN;
			i_pastStAxisIdListInf^[iN+64].iCoreId:= 2;
			i_pastStAxisIdListInf^[iN+64].iUnitId:= iN;
			i_pastStAxisIdListInf^[iN+64].iTypeId:= TYPE_UNIT_PRN_PRESS_MASTER;
			i_pastStAxisIdListInf^[iN+64].iStdId:= 96+iN;
			//i_pastStAxisIdListInf^[iN+64].iGroupId:= iN;
			i_pastStAxisIdListInf^[iN+64].iAdjAxisId:= iN+40;

			i_pastStAxisIdListInf^[iN+64+10].iAxisId:= iN+10;
			i_pastStAxisIdListInf^[iN+64+10].iCoreId:= 2;
			i_pastStAxisIdListInf^[iN+64+10].iUnitId:= iN;
			i_pastStAxisIdListInf^[iN+64+10].iTypeId:= TYPE_UNIT_PRN_PRESS_G;
			i_pastStAxisIdListInf^[iN+64+10].iStdId:= 112+iN;
			//i_pastStAxisIdListInf^[iN+64+10].iGroupId:= iN;
			i_pastStAxisIdListInf^[iN+64+10].iAdjAxisId:= -1;
			
// 			i_pastStAxisIdListInf^[iN+64+40].iAxisId:= iN+20;
// 			i_pastStAxisIdListInf^[iN+64+40].iCoreId:= 2;
// 			i_pastStAxisIdListInf^[iN+64+40].iUnitId:= iN;
// 			i_pastStAxisIdListInf^[iN+64+40].iTypeId:= TYPE_UNIT_PRN_PRESS_M;
// 			i_pastStAxisIdListInf^[iN+64+40].iStdId:= -1;
// 			i_pastStAxisIdListInf^[iN+64+40].iGroupId:= iN;


			i_pastStAxisIdListInf^[iN+64+20].iAxisId:= iN+20;
			i_pastStAxisIdListInf^[iN+64+20].iCoreId:= 2;
			i_pastStAxisIdListInf^[iN+64+20].iUnitId:= iN;
			i_pastStAxisIdListInf^[iN+64+20].iTypeId:= TYPE_UNIT_NET_PRESS_MASTER;
			i_pastStAxisIdListInf^[iN+64+20].iStdId:= 128+iN;
			//i_pastStAxisIdListInf^[iN+64+20].iGroupId:= iN + 10;
			i_pastStAxisIdListInf^[iN+64+20].iAdjAxisId:= iN+50;

			i_pastStAxisIdListInf^[iN+64+30].iAxisId:= iN+30;
			i_pastStAxisIdListInf^[iN+64+30].iCoreId:= 2;
			i_pastStAxisIdListInf^[iN+64+30].iUnitId:= iN;
			i_pastStAxisIdListInf^[iN+64+30].iTypeId:= TYPE_UNIT_NET_PRESS_G;
			i_pastStAxisIdListInf^[iN+64+30].iStdId:= 144+iN;
			//i_pastStAxisIdListInf^[iN+64+30].iGroupId:= iN + 10;
			i_pastStAxisIdListInf^[iN+64+30].iAdjAxisId:= -1;
			
// 			i_pastStAxisIdListInf^[iN+64+50].iAxisId:= iN+50;
// 			i_pastStAxisIdListInf^[iN+64+50].iCoreId:= 2;
// 			i_pastStAxisIdListInf^[iN+64+50].iUnitId:= iN;
// 			i_pastStAxisIdListInf^[iN+64+50].iTypeId:= TYPE_UNIT_NET_PRESS_M;
// 			i_pastStAxisIdListInf^[iN+64+50].iStdId:= -1;
// 			i_pastStAxisIdListInf^[iN+64+50].iGroupId:= iN + 10;
		
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
KS_RstAxisListInf_V3:= xResult;