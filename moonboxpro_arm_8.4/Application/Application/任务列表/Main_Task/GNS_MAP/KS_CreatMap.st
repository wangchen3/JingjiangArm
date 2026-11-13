(*@CES
Name=KS_CreatMap
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=61e29dc5-e287-4a1a-b094-66cbd5c76957
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CreatMap : BOOL
(*创建映射表@触发执行|初始化获取到了站列表后执行一次就行*)
(*对应关系参考站号定义、xml分配文件*)
(*新的架构需要同步修改KS_CreatStationIdMap\KS_GetLogicAxisInfByStationIdForMap*)
(*2026.5.20.140844 by liu.yt 调整接口为系统列表结构体*)
VAR_INPUT
	i_xEn					: BOOL;(*创建使能@事件触发*)
	i_xUseRealStation		: BOOL;(*使用实际站创建*)
	(*根据系统架构创建*)
	i_iMachineryType		: stEuumMachineryType;(*机器类型*)
(*
	i_xIsDualUwRw			: BOOL;(*双收双放机型|*)
	i_xIfOfIsGlink			: BOOL;(*收放牵是glink站*)
	i_xUwRwIsGlink			: BOOL;(*收放料是glink站*)
	i_xPrnPressureIsGlink	: BOOL;(*印刷辊的压力辊是glink站*)
	i_xNetPressureIsGlink	: BOOL;(*网纹辊的压力辊是glink站*)
*)

	(*系统中实际站信息*)
	i_byStationIdNum		: BYTE;(*站的个数*)
	//i_piStationIdList		: POINTER TO INT;(*站id列表*)
	i_pstStStationInfo_KS	: POINTER TO StStationInfo_KS;(*固高函数获取的系统站信息@2026.5.20.140838 by liu.yt*)
	(*输出列表*)
	i_pstStSysStationInf	: POINTER TO StSysStationInf;
END_VAR
VAR
	iN					: INT;
	iAxisId				: stEnumAxisId;
	piTmp				: POINTER TO INT;
	pwTmp				: POINTER TO WORD;
	iStationInflenth	: INT;
	iStationNum			: INT;(*站的个数*)
	iValidStationNum	: INT;(*有效站个数*)
	aiStationidList		: ARRAY [1..256] OF INT;
	wStationType		: WORD;(*站的类型*)
	awStationType		: ARRAY [1..256] OF WORD;(*2026.5.20.141316 by liu.yt*)
	pstStationInf		: POINTER TO StStationInf;
	iFuncId				: stEnumFuncId;(*只针对色组轴*)
	iMoveType			: stEnumMoveType;(*运动的类型也可以获取*)
	iStationId			: INT;
	iCoreId				: INT:=-1;
	iLogicAxisIdSuperPos: INT:=-1;
	iLogicAxisId		: INT:=-1;
	(*不同的机型必须要显式赋值*)
	(*色组数@默认写的是机组式柔印+4压力电机*)
	iUnitNum			: INT:=10;
	iMachineryType		: stEuumMachineryType;
END_VAR
{IMPLEMENTATION}
IF i_xEn THEN
	iStationInflenth:=SIZEOF(i_pstStSysStationInf^.astStationInf) /
						SIZEOF(i_pstStSysStationInf^.astStationInf[1]);
	iMachineryType:=i_iMachineryType;
	(*获取站列表和个数*)
	IF i_xUseRealStation THEN
		(*2026.5.20.141002 by liu.yt*)
		//iStationNum:=BYTE_TO_INT(i_byStationIdNum);
		(*piTmp:=i_piStationIdList;*)
		iStationNum:=i_pstStStationInfo_KS^.iStationNum;
		piTmp:=ADR(i_pstStStationInfo_KS^.aiStationId_List);
		pwTmp:=ADR(i_pstStStationInfo_KS^.awStation_Type);
		FOR iN:=1 TO iStationNum BY 1 DO
			(*列表获取@2026.5.20.141347 by liu.yt*)
			aiStationidList[iN]:=piTmp^;
			piTmp:=piTmp+SIZEOF(piTmp^);
			(*站类型获取@2026.5.20.141359 by liu.yt*)
			awStationType[iN]:=pwTmp^;
			pwTmp:=pwTmp+SIZEOF(pwTmp^);
		END_FOR
	ELSE
		iStationNum:=255(*iStationInflenth*);
		IF iStationNum<=255 THEN
			FOR iN:=1 TO iStationNum BY 1 DO
				aiStationidList[iN]:=iN;
			END_FOR
		END_IF
	END_IF
	(*初始化@结构体数据*)
	i_pstStSysStationInf^.byStationNum:=0;
	FOR iN:=1 TO iStationInflenth BY 1 DO
		pstStationInf:=ADR(i_pstStSysStationInf^.astStationInf[iN]);
		KS_InitStationInf(pstStationInf);
	END_FOR

	iValidStationNum:=0;
(*	IF NOT i_xIsDualUwRw THEN(*常规机型*)*)
		(*按照*)
		CASE iMachineryType OF
			MACHINERYTYPE_ROTOGRAVE:(*凹印机*);
			MACHINERYTYPE_FELXO_INLINE,(*机组式柔印*)
			MACHINERYTYPE_FELXO_INLINE_ONEBOTOMROLLER:(*机组式柔印@单底辊*)
				(*按照10色，带龙门压力，横向配置@压力轴的个数限制了最大色组数只能为10个*)
				iUnitNum:=10;(*4电机压力限制最大只能10色*)
				(*处理map*)
				FOR iN:=1 TO iStationNum BY 1 DO
					iStationId:=aiStationidList[iN];
					wStationType:=awStationType[iN];
					(*获取轴信息*)
					iAxisId:=KS_GetAxisInfByStationIdForMap(iStationId,ADR(iFuncId),ADR(iMoveType));
					(*站号在表里,就输出有效标志*)
					IF iAxisId<>AXISID_INVALID THEN
						IF iAxisId > iUnitNum AND iAxisId <= AXISID_15U THEN(*非法轴id就剔除*);
						ELSE;
							iValidStationNum:=iValidStationNum+1;
							IF iValidStationNum<=iStationInflenth THEN
								pstStationInf:=ADR(i_pstStSysStationInf^.astStationInf[iValidStationNum]);
								pstStationInf^.xValid:=TRUE;
								pstStationInf^.iAxisId:=iAxisId;
								pstStationInf^.iStationId:=iStationId;
								pstStationInf^.iFuncId:=iFuncId;
								pstStationInf^.iMoveType:=iMoveType;
								pstStationInf^.udiStationType:=WORD_TO_UDINT(wStationType);(*2026.5.20.161045 by liu.yt*)
								(*运控信息获取*)
								iLogicAxisId:=
									KS_GetLogicAxisInfByStationIdForMap(
												iStationId(*i_iStationId*),
												iMachineryType(*i_iMachineryType*),
												ADR(iCoreId)(*i_piCoreId*),
												ADR(iLogicAxisIdSuperPos)(*i_piLogicAxisIdSuperPos*));
	
								pstStationInf^.iCoreId_LogicAxis			:=iCoreId;
								pstStationInf^.iCoreId_LogicAxisSuperPos	:=iCoreId;
								pstStationInf^.iLogicAxisId					:=iLogicAxisId;
								pstStationInf^.iLogicAxisIdSuperPos			:=iLogicAxisIdSuperPos;
							ELSE;(*超过最大索引了*)
								iValidStationNum:=iStationInflenth;(*站个数最大就是数组长度*)
							END_IF
						END_IF
					END_IF
				END_FOR

			MACHINERYTYPE_FELXO_CL:(*卫星式柔印*);
			MACHINERYTYPE_OFFSET:(*胶印机*);
		ELSE;
		END_CASE
(*
	ELSE;
	END_IF
*)
	i_pstStSysStationInf^.byStationNum:=INT_TO_BYTE(iValidStationNum);
END_IF

//2025.12.27.142131 | + 机器类型搞个变量单独弄出来
g_iMachineryType := i_iMachineryType;