(*@CES
Name=KS_GetCoatingAllnf
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=cb71e24b-1db6-4b3f-8052-350591e92417
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetCoatingAllnf : bool
(*获取系轴中涂布模拟量@未做滤波(如果需要可以在获取的地方进行运算)*)
VAR_INPUT
	i_xGetCoatingAxisAI:BOOL;(*获取涂布轴ai*)
	i_xGetUnitAxisAI:BOOL;(*获取所有色组轴ai*)
	i_rPressure_Max:REAL;(*压力传感器最大值*)
	i_iGrpAxisNum_Pu: INT;(*色组轴数量|*)
	i_paiGrpAxisList: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF INT;(*系轴列表|有排序规则|*)
	i_pstStCoatingAxisInf:POINTER TO StCoatingAxisInf;
	i_pastStIOMap_AxisExtra:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_Extra_FE;
	i_paiAIAxisIdlist_Last:POINTER TO ARRAY[1..MAX_UNIT_NUM] OF INT;(*获取ai的轴id列表备份*)
	i_pabySensorType_CoatingPrn:POINTER TO ARRAY[1..MAX_UNIT_NUM] OF BYTE;(*涂布传感器类型*)
	i_abyAdjMode_CoatingPrn:ARRAY[1..MAX_UNIT_NUM] OF BYTE;
	i_palrAI_CoatingPrn:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF LREAL;
END_VAR
VAR
	iN: INT;
	iM: INT;
	iNum: INT:=0;
	aiIdlist: ARRAY [1..MAX_UNIT_NUM] OF INT:=[(-1)];
	iUnitId: INT;
	pstStIOMap_AxisExtra:POINTER TO StIOMap_Axis_Extra_FE;
	iTemp: INT;
	lrMinTemp: LREAL;
	lrMaxTemp: LREAL;
	diMinTemp: DINT;
	diMaxTemp: DINT;
	lrTemp: LREAL;
END_VAR
{IMPLEMENTATION}
IF i_pstStCoatingAxisInf<>0 AND
	i_paiGrpAxisList<>0 AND
	i_pastStIOMap_AxisExtra<>0 AND
	i_paiAIAxisIdlist_Last<>0 THEN;
ELSE
	RETURN;
END_IF

IF i_xGetCoatingAxisAI THEN(*获取涂布轴ai*)
	iNum:=i_pstStCoatingAxisInf^.byCoatingAxisNum;
	FOR iN:=1 TO i_pstStCoatingAxisInf^.byCoatingAxisNum BY 1 DO
		aiIdlist[iN]:=i_pstStCoatingAxisInf^.aiAxisIdList[iN];
	END_FOR
ELSIF i_xGetUnitAxisAI THEN(*获取所有色组轴ai*)
	iNum:=i_iGrpAxisNum_Pu;
	FOR iN:=1 TO i_pstStCoatingAxisInf^.byCoatingAxisNum BY 1 DO
		aiIdlist[iN]:=i_paiGrpAxisList^[iN];
	END_FOR
ELSE;
END_IF

FOR iN:=1 TO iNum BY 1 DO
	iUnitId:=aiIdlist[iN];
	IF iUnitId>0 AND iUnitId<=MAX_UNIT_NUM THEN
		pstStIOMap_AxisExtra:=ADR(i_pastStIOMap_AxisExtra^[iUnitId]);

		(*获取配置的类型*)
		i_pabySensorType_CoatingPrn^[iUnitId]:=0;
		IF pstStIOMap_AxisExtra^.i_byAIType_CoatingSensor<=5 THEN
			i_pabySensorType_CoatingPrn^[iUnitId]:=pstStIOMap_AxisExtra^.i_byAIType_CoatingSensor;
		END_IF

		(*获取配置的模拟值@转换未正负*)
		iTemp:=WORD_TO_INT(pstStIOMap_AxisExtra^.i_wAI_CoatingSensor);

		(*获取上下限*)
		KS_QueryRangeByAType(
							i_pabySensorType_CoatingPrn^[iUnitId],
							ADR(lrMinTemp),
							ADR(lrMaxTemp),
							ADR(diMinTemp),
							ADR(diMaxTemp));

		(*计算模拟量值*)
		i_palrAI_CoatingPrn^[iUnitId]:=KSIO_DA(iTemp,
												lrMinTemp,
												lrMaxTemp,
												diMinTemp,
												diMaxTemp);


		(*增加了张力传感器时的显示值处理2019.8.9.161738*)
		IF lrMinTemp<0 THEN lrMinTemp:=0;END_IF(*最小值是负值的传感器一般0--正模拟量值对应0--最大量*)
		lrTemp:=lrMaxTemp-lrMinTemp;
		IF lrTemp<>0 THEN;ELSE lrTemp:=10;END_IF(*按照0--10v处理*)
	
		IF i_abyAdjMode_CoatingPrn[iUnitId]=2 OR i_abyAdjMode_CoatingPrn[iUnitId]=3 THEN
		(*张力传感器调整时，将电压值转换为张力值*)
			lrTemp:=i_rPressure_Max(*pstStGrpParam^.rPressure_Max*)/lrTemp;(*默认最小压力为0*)
			i_palrAI_CoatingPrn^[iUnitId]:=(i_palrAI_CoatingPrn^[iUnitId]-lrMinTemp)*lrTemp;
		END_IF
	END_IF
END_FOR

(*寻找消失的轴*)
FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
	iUnitId:=i_paiAIAxisIdlist_Last^[iN];(*之前的轴id*)
	IF iUnitId>0 AND iUnitId<=MAX_UNIT_NUM  THEN
		IF iNum>0 THEN
			FOR iM:=1 TO iNum BY 1 DO
				IF aiIdlist[iM]=iUnitId THEN(*还在呢*)
					EXIT;
				ELSE(*已经被删除了*)
					IF iM=iNum THEN(*列表里没了*)
						i_palrAI_CoatingPrn^[iUnitId]:=0;(*复位操作的值*)
					END_IF
				END_IF
			END_FOR
		ELSE(*一个都没有 就把之前的关闭把*)
			//pstStAxisParam:=ADR(i_pastStAxisParam^[iUnitId]);
			i_palrAI_CoatingPrn^[iUnitId]:=0;(*复位操作的值*)
		END_IF
	END_IF
END_FOR

i_paiAIAxisIdlist_Last^:=aiIdlist;(*备份列表值*)