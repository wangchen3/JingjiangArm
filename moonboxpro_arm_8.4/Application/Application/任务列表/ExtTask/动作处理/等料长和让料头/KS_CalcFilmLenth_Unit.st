(*@CES
Name=KS_CalcFilmLenth_Unit
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=fbb1f091-bc6d-41b7-8c67-8721afc114f4
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CalcFilmLenth_Unit : REAL
(*计算合压色组间(i_iAxisId_1 AND i_iAxisId_2)料长|MM
有一个未合压按照固定料长输出*)
(*2024.7.30.172245 合压还是不合压都按照计算的料长输出*)
(*2025.1.4.112408 调整合压信号输入*)
VAR_INPUT
	i_iAxisId_1:INT;(*轴1*)
	i_iAxisId_2:INT;(*轴2*)
	(*调整接口@使用实际合压完成标志|2025.1.4.111522*)
	i_paxFlag_PressDne:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*实际压辊完成标志*)
	i_pstStSysParam: POINTER TO StSysParam;
	i_prFilmLenthWhenCurUnitPressDn:POINTER TO REAL;(*计算当前色在合压时距离前一色的料长@即使现在还未合压*)
END_VAR
VAR
	rFilmLenth:REAL;
	iAxisId: INT;
	iAxisId_S: INT;
	iAxisId_L: INT;
	xPressSts: BOOL;
	rFilmLenthFromPrevUnit: REAL;
	rFilmLenth_Var: REAL;
END_VAR

{IMPLEMENTATION}
IF i_paxFlag_PressDne<>0 AND
	i_pstStSysParam<>0 AND
	i_iAxisId_1>0 AND i_iAxisId_1<=MAX_UNIT_NUM AND
	i_iAxisId_2>0 AND i_iAxisId_2<=MAX_UNIT_NUM THEN
	iAxisId_S:=MIN(i_iAxisId_1,i_iAxisId_2);
	iAxisId_L:=MAX(i_iAxisId_1,i_iAxisId_2);
	FOR iAxisId:=iAxisId_S TO iAxisId_L BY 1 DO
		xPressSts:=i_paxFlag_PressDne^[iAxisId];
		
		rFilmLenthFromPrevUnit:=LREAL_TO_REAL(i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrFilmLengthFromPrevUnit);(*前一色和当前色之间的料长*)
		rFilmLenth_Var:=rFilmLenthFromPrevUnit-LREAL_TO_REAL(i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_ConstVal);(*计算可变料长值*)
		rFilmLenth_Var:=0;(*合压还是不合压都按照计算的料长输出@2024.7.30.172245*)
		IF iAxisId=iAxisId_S THEN
			rFilmLenth:=0;
			(*清零*)
			IF i_prFilmLenthWhenCurUnitPressDn<>0 THEN
				i_prFilmLenthWhenCurUnitPressDn^:=0;
			END_IF
		ELSE
			IF xPressSts THEN(*压辊合压了*)
				rFilmLenth:=rFilmLenth+rFilmLenthFromPrevUnit;
			ELSE(*未合压*)
				rFilmLenth:=rFilmLenth+rFilmLenthFromPrevUnit-rFilmLenth_Var;(*减小一个可变料长*)
			END_IF

			(*计算当前色在合压时距离前一色的料长@即使现在还未合压|2023.09.11.115742*)
			IF i_prFilmLenthWhenCurUnitPressDn<>0 THEN
				i_prFilmLenthWhenCurUnitPressDn^:=i_prFilmLenthWhenCurUnitPressDn^+rFilmLenthFromPrevUnit;
			END_IF
		END_IF
	END_FOR

END_IF
KS_CalcFilmLenth_Unit:=rFilmLenth;