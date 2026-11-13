(*@CES
Name=KS_GetArcIdList
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=d22e29e8-5d32-4a53-8a83-de107a05006d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetArcIdList : BOOL
VAR_INPUT
	i_xEn:BOOL;(*更新列表使能标志*)
	i_iGrpAxisNum_Pu: INT; (*系的轴数量*)
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT; (*系的轴列表|已经按照升序排列了*)
	i_paxArcEnSts_Bak:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*套色使能备份值|用于检查是否套色使能切换*)
	i_pabyArcId_Bak:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*备份套色id*)
	(*系套色轴个数@可以输入0*)
	i_piGrpArcAxisNum_Pu:POINTER TO INT;	
	i_axLinkage: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_axThisUnitEna: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_axSwitchOn_CoatingPrn: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_pabyColorIdCurrent: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*色组色序*)
	
END_VAR
VAR
	iN:INT;
	iUnitId:INT;
	xArcEnSts:BOOL;(*套色使能值|用于检查是否套色使能切换*)
	axArcEnSts_Bak:ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*套色使能备份值|用于检查是否套色使能切换*)
	abyArcId_Bak:ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*备份套色id*)
	(*系套色个数*)
	iGrpArcAxisNum_Pu:INT;
	xNeedUpdate: BOOL;
	byAxisIdArcValid: BYTE;(*最后一个未更新套色id|有效的轴id*)
	iAxisIdSa_Update: INT;(*更新的起始id@后面轴的套色id都更新*)
	xArcIdLocked:BOOL;(*套色id被锁定了|在更新的时候不修改这个值*)
	xRtn: BOOL;
	xUpdateArcId_BakValue: BOOL;(*更新套色id的备份值*)
	iIndex: INT;	
END_VAR

{IMPLEMENTATION}
IF i_paxArcEnSts_Bak<>0 AND
	i_pabyArcId_Bak<>0 AND
	i_pabyColorIdCurrent<>0 THEN

	IF i_xEn THEN
		axArcEnSts_Bak:=i_paxArcEnSts_Bak^;(*获取之前的备份值*)
		abyArcId_Bak:=i_pabyArcId_Bak^;(*备份套色id*)

		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:=i_aiGrpAxisList[iN];

			xArcEnSts:=i_axThisUnitEna[iUnitId] AND(*使能了*)
				i_axLinkage[iUnitId] AND(*联动了*)
				(NOT i_axSwitchOn_CoatingPrn[iUnitId]);(*不是涂布色组*)


			IF xArcEnSts<>axArcEnSts_Bak[iUnitId] THEN(*有轴的状态发生变化了*)
				IF NOT xNeedUpdate THEN(*记录需要更新的开始轴id*)
					iAxisIdSa_Update:=iUnitId;
				END_IF
				xNeedUpdate:=TRUE;
			END_IF

			(*记录最后一个不更新套色id的轴*)
			IF NOT xNeedUpdate THEN(*还没找到需要变化的轴id*)
				IF i_pabyColorIdCurrent^[iUnitId]<>0 THEN
					byAxisIdArcValid:= i_pabyColorIdCurrent^[iUnitId];
				END_IF
			END_IF
			axArcEnSts_Bak[iUnitId]:=xArcEnSts;
		END_FOR

		IF NOT xNeedUpdate THEN(*手动更新列表@注意调用顺序*)
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iUnitId:=i_aiGrpAxisList[iN];
				xArcEnSts:=axArcEnSts_Bak[iUnitId];
				IF NOT xArcEnSts THEN(*套色不使能的时候 手动也不能输入*)
					i_pabyColorIdCurrent^[iUnitId]:=0;(*强制写0*)
				ELSE
					IF i_pabyColorIdCurrent^[iUnitId]=0 THEN(*输入了0则强制写成备份值*)
						i_pabyColorIdCurrent^[iUnitId]:=abyArcId_Bak[iUnitId];
						EXIT;(*手动修改了*)
					ELSE
						IF abyArcId_Bak[iUnitId]<>i_pabyColorIdCurrent^[iUnitId] THEN(*id被修改了*)
							xRtn:=KS_CheckArcIdValid(iUnitId,i_pabyColorIdCurrent^[iUnitId],i_pabyColorIdCurrent);
							IF xRtn THEN(*id合法@手动修改成功了|后面的列表需要同步更新*)
								xNeedUpdate:=TRUE;(*由下面逻辑生成*)
								iAxisIdSa_Update:=iUnitId;
								byAxisIdArcValid:=i_pabyColorIdCurrent^[iUnitId]-1;(*更新的时候会+1*)
							ELSE(*不合法@保持之前的*)
								i_pabyColorIdCurrent^[iUnitId]:=abyArcId_Bak[iUnitId];
							END_IF
							(*pstStAxisParam^.byColorIdCurrent 界面修改的,不在同一个任务中,防止不能抓住改变的状态
							置标志只有进入过这里才更新备份值*)
							xUpdateArcId_BakValue:=TRUE;

							EXIT;(*手动修改了*)
						END_IF
					END_IF
				END_IF
			END_FOR
		END_IF

		(*上面执行完成后axArcEnSts_Bak 中存储的每个色组是否套色的状态*)
		IF xNeedUpdate THEN(*自动更新列表了*)
			(*套色轴个数初始化*)
			IF byAxisIdArcValid<>0 THEN
				iGrpArcAxisNum_Pu:=BYTE_TO_INT(byAxisIdArcValid);
			ELSE
				iGrpArcAxisNum_Pu:=0;
			END_IF

			(*找到起始轴的索引值*)
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iUnitId:=i_aiGrpAxisList[iN];
				IF iAxisIdSa_Update = iUnitId THEN
					iIndex:=iN;
					EXIT;
				END_IF
			END_FOR

			FOR iN:=iIndex TO i_iGrpAxisNum_Pu BY 1 DO(*从变化的轴这里开始，更新后面的套色id*)
				iUnitId:=i_aiGrpAxisList[iN];
				xArcEnSts:=axArcEnSts_Bak[iUnitId];

//xArcIdLocked;(*还未处理*)

				IF xArcEnSts THEN(*套色使能了*)
					iGrpArcAxisNum_Pu:=iGrpArcAxisNum_Pu+1;
					IF NOT xArcIdLocked THEN(*套色Id未被锁定*)
						i_pabyColorIdCurrent^[iUnitId]:=INT_TO_BYTE(iGrpArcAxisNum_Pu);
					ELSE(*套色Id被锁定了|当前色序id不做修改,更新套色轴个数变量*)
						IF i_pabyColorIdCurrent^[iUnitId]>iGrpArcAxisNum_Pu THEN
							iGrpArcAxisNum_Pu:=i_pabyColorIdCurrent^[iUnitId];
						ELSE
							i_pabyColorIdCurrent^[iUnitId]:=INT_TO_BYTE(iGrpArcAxisNum_Pu);
						END_IF
					END_IF
				ELSE
					i_pabyColorIdCurrent^[iUnitId]:=0;
				END_IF
			END_FOR
		ELSE(*在不更新的时候支持手动的输入*);
		END_IF


		(*更新存储的备份值@不用做专门的备份值初始化,因为刚上电的大概率肯定会更新列表*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:=i_aiGrpAxisList[iN];
			(*pstStAxisParam^.byColorIdCurrent 界面修改的,不在同一个任务中,防止不能抓住改变的状态
			置标志只有进入过上面逻辑更新备份值*)
			IF xUpdateArcId_BakValue OR xNeedUpdate THEN(*或者更新了列表后就更新*)
				abyArcId_Bak[iUnitId]:=i_pabyColorIdCurrent^[iUnitId];
			END_IF
		END_FOR
	ELSE;(*不使能*)
	END_IF

	i_paxArcEnSts_Bak^:=axArcEnSts_Bak;(*更新备份值|en=false 全部写成false*)
	i_pabyArcId_Bak^:=abyArcId_Bak;(*备份套色id*)
END_IF


IF i_piGrpArcAxisNum_Pu<>0 THEN
	i_piGrpArcAxisNum_Pu^:=iGrpArcAxisNum_Pu;
END_IF