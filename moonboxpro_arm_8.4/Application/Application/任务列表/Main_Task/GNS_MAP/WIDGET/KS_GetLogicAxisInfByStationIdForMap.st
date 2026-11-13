(*@CES
Name=KS_GetLogicAxisInfByStationIdForMap
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=2d4d40f4-a928-4a47-8c3c-7c3d2312de1c
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetLogicAxisInfByStationIdForMap : INT(*返回逻辑轴id*)
(*通过站号获取逻辑轴信息@轴号和核号|基于xml文件*)
(*实际站号后面都是叠加轴*)
VAR_INPUT
	i_iStationId			:INT;
	i_iMachineryType		:stEuumMachineryType;(*机器类型@不同设备生成的站列表可能不同*)
	(*根据xml配置表获得*)
	i_piCoreId				:POINTER TO INT;(*核id*)
	i_piLogicAxisIdSuperPos	:POINTER TO INT;(*叠加轴id*)
END_VAR
VAR
	iN:INT;
	iStationIdTmp: INT;(*站id*)
	iCoreId: INT:=-1;(*核id*)
	iLogicAxisId:INT:=-1;(*逻辑轴id*)
	iLogicAxisIdSuperPos:INT:=-1;(*叠加轴id*)
	(*不同的机型必须要显式赋值*)
	(*色组数@默认写的是机组式柔印+4压力电机*)
	iUnitNum:INT:=10;
	(*核1核2分配的站个数@默认写的是机组式柔印+4压力电机*)
	byStationNum_Core1: BYTE:=53;
	byStationNum_Core2: BYTE:=40;
	iMoveStationNum: INT:=0;(*运动站个数*)
	aiMoveStationIdList: ARRAY [1..128] OF INT;(*运动站id列表*)
	aiStationIdListTmp: ARRAY [1..128] OF INT;
	iMachineryType: stEuumMachineryType;
	iLogicAxisSaIdCalcSuperAxisId: INT;(*计算叠加轴id时逻辑轴起始@不包含*)
	iLogicAxisEdIdCalcSuperAxisId: INT;(*计算叠加轴id时逻辑轴结束@包含*)
END_VAR
{IMPLEMENTATION}
IF i_iStationId>0 AND i_iStationId<=255 THEN
	iMachineryType:=i_iMachineryType;
	(*生成合理的运动站号表@该表和core1 2的逻辑轴id是有对应关系的@xml文件*)
	KS_CreatStationIdMap(iMachineryType,0, 0, ADR(iMoveStationNum), ADR(aiMoveStationIdList));
	CASE iMachineryType OF
		MACHINERYTYPE_ROTOGRAVE:;(*凹印*)
		MACHINERYTYPE_FELXO_INLINE,(*机组式柔印*)
		MACHINERYTYPE_FELXO_INLINE_ONEBOTOMROLLER:(*机组式柔印@单底辊*)
			(*不同的机型必须要显式赋值*)
			iUnitNum:=10;(*4电机压力限制最大只能10色*)
			byStationNum_Core1:=53;(*核1的实际站个数*)
			byStationNum_Core2:=40;(*核2的实际站个数*)
			(*把核1的站id取出来*)
			SysMemCpy(ADR(aiStationIdListTmp),
					ADR(aiMoveStationIdList),
					SIZEOF(aiMoveStationIdList[1])*byStationNum_Core1);
			FOR iN:=1 TO byStationNum_Core1 BY 1 DO
				iStationIdTmp:=aiStationIdListTmp[iN];
				IF iStationIdTmp = i_iStationId THEN
					iCoreId:=1;
					iLogicAxisId:=iN;
					(*叠加轴处理*)
					IF iMachineryType = MACHINERYTYPE_FELXO_INLINE_ONEBOTOMROLLER THEN
						(*默认的套色轴是底辊*)
						iLogicAxisSaIdCalcSuperAxisId:=(iUnitNum+1)*2+1;
						iLogicAxisEdIdCalcSuperAxisId:=(iUnitNum+1)*3;
					ELSE(*默认套色轴是在版辊*)
						iLogicAxisSaIdCalcSuperAxisId:=1;
						iLogicAxisEdIdCalcSuperAxisId:=iUnitNum+1;
					END_IF

					IF iN>iLogicAxisSaIdCalcSuperAxisId AND
						iN<=iLogicAxisEdIdCalcSuperAxisId THEN
						(*eg:1色版辊叠加轴;iN:=2, 叠加id=53 + 2 - 1 = 54*)
						(*eg:1色底辊叠加轴;iN:=24, 叠加id=53 + 24 - 23 = 54*)
						iLogicAxisIdSuperPos:=BYTE_TO_INT(byStationNum_Core1) + iN - iLogicAxisSaIdCalcSuperAxisId;
					END_IF
					EXIT;
				END_IF
			END_FOR

			IF iCoreId = -1 THEN(*未找到,继续找*)
				(*把核2的站id取出来*)
				SysMemSet(ADR(aiStationIdListTmp),0,SIZEOF(aiStationIdListTmp));
				SysMemCpy(ADR(aiStationIdListTmp),
						ADR(aiMoveStationIdList[byStationNum_Core1+1]),
						SIZEOF(aiMoveStationIdList[1])*byStationNum_Core2);

				FOR iN:=1 TO byStationNum_Core2 BY 1 DO
					iStationIdTmp:=aiStationIdListTmp[iN];
					IF iStationIdTmp = i_iStationId THEN
						iCoreId:=2;
						iLogicAxisId:=iN;
						(*叠加轴处理*)
						IF iN<=iUnitNum THEN
							(*eg:1色版辊M侧压力电机龙门叠加轴;iN:=1, 叠加id= 40 + 1 = 41*)
							iLogicAxisIdSuperPos:=BYTE_TO_INT(byStationNum_Core2) + iN;
						ELSIF iN>iUnitNum*3 THEN(*网辊M侧@不需要处理叠加轴*);
						ELSIF iN>iUnitNum*2 THEN(*再偏移一个版辊G侧压力电机|是网辊M侧的索引*)
							(*eg:1色网辊M侧压力电机龙门叠加轴;iN:=21, 叠加id= 40 + 21 - 10 = 51*)
							iLogicAxisIdSuperPos:=BYTE_TO_INT(byStationNum_Core2) + iN - iUnitNum;
						END_IF
						EXIT;
					END_IF
				END_FOR
			END_IF
		MACHINERYTYPE_FELXO_CL:;(*卫星式柔印*)
		MACHINERYTYPE_OFFSET:;(*胶印机*)
	ELSE;
	END_CASE
ELSE;
END_IF

IF i_piCoreId<>0 THEN
	i_piCoreId^:=iCoreId;
END_IF
IF i_piLogicAxisIdSuperPos<>0 THEN
	i_piLogicAxisIdSuperPos^:=iLogicAxisIdSuperPos;
END_IF
KS_GetLogicAxisInfByStationIdForMap:=iLogicAxisId;