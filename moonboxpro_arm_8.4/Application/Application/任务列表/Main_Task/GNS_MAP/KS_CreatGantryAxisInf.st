(*@CES
Name=KS_CreatGantryAxisInf
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=f41a9b20-4237-42b7-ab68-52a2ca659d0d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CreatGantryAxisInf : BOOL
(*获取龙门轴信息*)
VAR_INPUT
	(*输入*)
	i_pstStSysStationInf 	: POINTER TO StSysStationInf;
	(*输出*)
	i_pstStSysGantryAxisInf : POINTER TO StSysGantryAxisInf;
END_VAR
VAR
	in					: INT;
	pstStStationInf		: POINTER TO StStationInf;
	pstStGantryAxisInf	: POINTER TO StGantryAxisInf;
	(*龙门轴信息地址@索引为轴id,最大15*)
	(*每个轴2个龙门@二维数组里的1是版辊、2是网纹辊*)
	apstStGantryAxisInf	: ARRAY [1..20,1..2] OF POINTER TO StGantryAxisInf:=[40(0)];
	iGantryAxisNum		: INT := 0;(*龙门轴个数*)
	iMaxGantryAxisNum	: INT;
	iLogicAxisId		: INT;(*逻辑轴id*)
	iLogicAxisIdSuperPos: INT;(*叠加轴id*)
	iMoveType			: stEnumMoveType;(*运动类型*)
	iAxisId				: stEnumAxisId;
	iStaitonFuncId		: stEnumFuncId;
	iCoreId				: INT;
	iIndexTmp			: INT;(*数组索引*)
END_VAR
{IMPLEMENTATION}
IF i_pstStSysStationInf<>0 AND i_pstStSysGantryAxisInf<>0 THEN
	(*龙门组个数*)
	iMaxGantryAxisNum:=SIZEOF(i_pstStSysGantryAxisInf^.astGantryAxisInf)/SIZEOF(i_pstStSysGantryAxisInf^.astGantryAxisInf[1]);
	(*初始化*)
	FOR iN:=1 TO iMaxGantryAxisNum BY 1 DO
		KS_InitGantryAxisInf(ADR(i_pstStSysGantryAxisInf^.astGantryAxisInf[iN]));
	END_FOR
	(*从系统架构中找龙门轴*)
	FOR in:=1 TO i_pstStSysStationInf^.byStationNum BY 1 DO
		pstStStationInf:=ADR(i_pstStSysStationInf^.astStationInf[iN]);
		IF pstStStationInf^.xValid THEN
			iAxisId					:=pstStStationInf^.iAxisId;
			iLogicAxisId			:=pstStStationInf^.iLogicAxisId;
			iLogicAxisIdSuperPos	:=pstStStationInf^.iLogicAxisIdSuperPos;
			iMoveType				:=pstStStationInf^.iMoveType;
			iStaitonFuncId			:=pstStStationInf^.iFuncId;
			iCoreId					:=pstStStationInf^.iCoreId_LogicAxis;
			IF KS_IsUnitAxisId(iAxisId)THEN(*是色组*)
				IF iMoveType = MOVETYPE_GANTRY THEN(*龙门轴*)
					IF iStaitonFuncId = FUNCID_PRNROLLER_PRESSURE_M OR
						iStaitonFuncId = FUNCID_PRNROLLER_PRESSURE_G THEN(*印刷辊龙门*)
						iIndexTmp:=1;
					ELSE(*else都认为是网纹辊龙门*)
						iIndexTmp:=2;
					END_IF

					IF apstStGantryAxisInf[iAxisId,iIndexTmp] = 0 THEN
						iGantryAxisNum:=iGantryAxisNum+1;
						(*获取龙门轴需要的信息*)
						(*写入的结构体地址获取*)
						IF iGantryAxisNum<=iMaxGantryAxisNum THEN
							pstStGantryAxisInf:=ADR(i_pstStSysGantryAxisInf^.astGantryAxisInf[iGantryAxisNum]);
						ELSE(*超限了|退出*)
							EXIT;
						END_IF
						apstStGantryAxisInf[iAxisId,iIndexTmp]:=ADR(i_pstStSysGantryAxisInf^.astGantryAxisInf[iGantryAxisNum]);
					END_IF


					(*获取地址*)
					pstStGantryAxisInf:=apstStGantryAxisInf[iAxisId,iIndexTmp];
					IF pstStGantryAxisInf<>0 THEN(*地址合法*)
						pstStGantryAxisInf^.iAxisId:=iAxisId;
						pstStGantryAxisInf^.iCoreId:=iCoreId;(*龙门站必须是一个核|所以不用区分*)

						CASE iStaitonFuncId OF
							FUNCID_PRNROLLER_PRESSURE_M:(*版辊压力|操作侧@叠加轴id在m侧的数据里*)
								pstStGantryAxisInf^.iFuncId					:=FUNCID_PRNROLLER_GANTRY;
								pstStGantryAxisInf^.iLogicAxisId_M			:=iLogicAxisId;
								pstStGantryAxisInf^.iLogicAxisId_SuperPos	:=iLogicAxisIdSuperPos;
							FUNCID_PRNROLLER_PRESSURE_G:
								pstStGantryAxisInf^.iFuncId					:=FUNCID_PRNROLLER_GANTRY;
								pstStGantryAxisInf^.iLogicAxisId_G			:=pstStStationInf^.iLogicAxisId;
							FUNCID_NETROLLER_PRESSURE_M:(*网辊压力|操作侧@叠加轴id在m侧的数据里*)
								pstStGantryAxisInf^.iFuncId					:=FUNCID_NETROLLER_GANTRY;
								pstStGantryAxisInf^.iLogicAxisId_M			:=iLogicAxisId;
								pstStGantryAxisInf^.iLogicAxisId_SuperPos	:=iLogicAxisIdSuperPos;
							FUNCID_NETROLLER_PRESSURE_G:
								pstStGantryAxisInf^.iFuncId					:=FUNCID_NETROLLER_GANTRY;
								pstStGantryAxisInf^.iLogicAxisId_G			:=pstStStationInf^.iLogicAxisId;
						ELSE;(*不是压力的就不理会了*)
						END_CASE
					END_IF
				ELSE(*不是龙门轴不理会*);
				END_IF
			END_IF(*不是色组就不理会了*);
		END_IF
	END_FOR
	i_pstStSysGantryAxisInf^.byGantryAxisNum:=INT_TO_BYTE(iGantryAxisNum);

	(*非法值检测*)
	FOR iN:=1 TO iGantryAxisNum BY 1 DO
		pstStGantryAxisInf:=ADR(i_pstStSysGantryAxisInf^.astGantryAxisInf[iN]);
		pstStGantryAxisInf^.xValid:=TRUE;
		IF pstStGantryAxisInf^.iAxisId=-1 OR
			pstStGantryAxisInf^.iCoreId=-1 OR
			pstStGantryAxisInf^.iFuncId=FUNCID_NULL OR
			pstStGantryAxisInf^.iLogicAxisId_G=-1 OR
			pstStGantryAxisInf^.iLogicAxisId_M=-1 OR
			pstStGantryAxisInf^.iLogicAxisId_SuperPos=-1 THEN
			pstStGantryAxisInf^.xValid:=FALSE;
		END_IF
	END_FOR
END_IF


