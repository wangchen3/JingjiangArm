(*@CES
Name=KS_CreatStationIdMap
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=81839476-edfc-40a3-bf0e-15a9283cc9d6
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CreatStationIdMap : BOOL
(*根据机器类型创建站id的表@根据站号分配表生成*)
(*从1号站开始的|从小到大*)
(*最大128个站*)
VAR_INPUT
	i_iMachineryType	:stEuumMachineryType;(*机器类型@不同设备生成的站列表可能不同*)
	i_piNum				:POINTER TO INT;
	i_paiList			:POINTER TO ARRAY [1..128] OF INT;(*站号从1开始的@总的站列表|需要从小到大*)
	i_piMotionNum		:POINTER TO INT;
	i_paiMotionList		:POINTER TO ARRAY [1..128] OF INT;(*站号从1开始的@运动的站列表|需要从小到大*)
END_VAR
VAR
	(*不同的机型必须要显式赋值*)
	iUnitNum		: INT:=10;(*10色@默认写的是机组式柔印+4压力电机*)
	iLenth			: INT:=128;
	iLenth_Motion	: INT:=128;
	iN				: INT;
	iIndex			: INT;
	iIndex_Motion	: INT;
	iStationId		: INT;
	byStationId		: BYTE;
	aiStationIdList	: ARRAY [1..128] OF INT:=[128(-1)];
	aiMotionStationIdList	: ARRAY [1..128] OF INT:=[128(-1)];
	byTmpL4			: BYTE;
	byTmpH4			: BYTE;
	xStationIdValid	: BOOL;
	xMotionStationIdValid: BOOL;
END_VAR
{IMPLEMENTATION}
iIndex:=0;
iIndex_Motion:=0;
iLenth:=128;
iLenth_Motion:=128;
IF i_paiList<>0 THEN
	iLenth:=SIZEOF(i_paiList^)/SIZEOF(i_paiList^[1]);
END_IF
IF i_paiMotionList<>0 THEN
	iLenth_Motion:=SIZEOF(i_paiMotionList^)/SIZEOF(i_paiMotionList^[1]);
END_IF

CASE i_iMachineryType OF
	MACHINERYTYPE_ROTOGRAVE:;(*凹印*)
	MACHINERYTYPE_FELXO_INLINE,(*机组式柔印*)
	MACHINERYTYPE_FELXO_INLINE_ONEBOTOMROLLER:(*机组式柔印@单底辊*)
		(*不同的机型必须要显式赋值*)
		iUnitNum:=10;
		FOR iN:=1 TO 255 BY 1 DO(*站号最大到255*)
			byStationId:=INT_TO_BYTE(iN);
			byTmpL4:= byStationId AND 16#0F;
			byTmpH4:= SHR(byStationId,4);
			xStationIdValid:=FALSE;
			xMotionStationIdValid:=FALSE;
			IF byTmpL4>0 AND byTmpL4<=iUnitNum THEN(*色组*)
				IF byTmpH4 <= 4 OR(*高4bit小于4是有效的@版辊网辊底辊横向*)
					(byTmpH4 >=7 AND byTmpH4 <= 10)(*压力轴*) THEN
					xStationIdValid:=TRUE;
					IF byTmpH4<>0 THEN(*都是运动的站*)
						xMotionStationIdValid:=TRUE;
					END_IF
				ELSE;
				END_IF
			ELSIF byTmpL4 = 0 THEN(*特殊轴*)
				IF byTmpH4 <= 6 THEN(*高4bit小于6是有效的*)
					xStationIdValid:=TRUE;
					xMotionStationIdValid:=TRUE;
				ELSE;
				END_IF
			ELSE;
			END_IF
			(*再在剩余的里面找找*)
			IF NOT xStationIdValid THEN
				IF byStationId>=92 AND byStationId<=99 THEN
					xStationIdValid:=TRUE;
					xMotionStationIdValid:=TRUE;
				END_IF
			END_IF
			(*所有站*)
			IF xStationIdValid THEN
				iIndex:=iIndex+1;
				IF iIndex<=iLenth THEN
					aiStationIdList[iIndex]:=BYTE_TO_INT(byStationId);
				ELSE
					iIndex:=iLenth;
				END_IF
			END_IF
			(*运动站*)
			IF xMotionStationIdValid THEN
				iIndex_Motion:=iIndex_Motion+1;
				IF iIndex_Motion<=iLenth_Motion THEN
					aiMotionStationIdList[iIndex_Motion]:=BYTE_TO_INT(byStationId);
				ELSE
					iIndex_Motion:=iLenth_Motion;
				END_IF
			END_IF
		END_FOR
	MACHINERYTYPE_FELXO_CL:;(*卫星式柔印*)
	MACHINERYTYPE_OFFSET:;(*胶印机*)
ELSE;
END_CASE

IF i_piNum<>0 THEN
	i_piNum^:=iIndex;
END_IF
IF i_paiList<>0 THEN
	i_paiList^:=aiStationIdList;
END_IF
(*色组站都是不参与运动的|剔除掉*)
IF i_piMotionNum<>0 THEN
	i_piMotionNum^:=iIndex_Motion;
END_IF
IF i_paiMotionList<>0 THEN
	i_paiMotionList^:=aiMotionStationIdList;
END_IF

KS_CreatStationIdMap:=iIndex<>0;

