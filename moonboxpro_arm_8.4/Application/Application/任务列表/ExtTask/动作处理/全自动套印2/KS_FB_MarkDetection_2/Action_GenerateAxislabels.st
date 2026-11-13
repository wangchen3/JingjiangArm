(*@CES
Name=Action_GenerateAxislabels
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=4b2ea286-6bc4-4779-b4c0-0467e291bff5
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*轴列表与轴关系*)
(*2023.6.19.105825生成全自动套印轴列表@Liu.yt*)
// o_byAxisNum_AutoAdj:=0;
// FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
// 	o_aiAxisList_AutoAdj[iN]:=-1;
// 	IF iN<=i_iGrpAxisNum_Pu THEN
// 		iAxisId:= i_paiGrpAxisList^[iN];
// 		pstStUnitParam_Save:= ADR(i_pstStsysParam^.astStUnitParam_Save[iAxisId]);
// 		pstStUnitParam_UnSave:=ADR(i_pstStsysParam^.astStUnitParam_UnSave[iAxisId]);
// 		pstStRSV_UnitParam_UnSave:=ADR(i_pstStsysParam^.astStRSV_UnitParam_UnSave[iAxisId]);
// 		pstStRSV_UnitParam_Save:=ADR(i_pstStsysParam^.astStRSV_UnitParam_Save[iAxisId]);
// 		
// 		IF pstStUnitParam_Save^.xLinkage AND
// 			pstStUnitParam_Save^.xEnable_arc AND
// 			pstStUnitParam_UnSave^.byColorIdCurrent>0 THEN(*最后一色有效-参与印刷-控制压辊合压-否则最后一色直接不进入一键对版*)
// 			o_byAxisNum_AutoAdj:=o_byAxisNum_AutoAdj+1;
// 			IF o_byAxisNum_AutoAdj<=MAX_UNIT_NUM THEN
// 				o_aiAxisList_AutoAdj[o_byAxisNum_AutoAdj]:=iAxisId;
// 			END_IF
// 		END_IF
// 	END_IF
// END_FOR
rMachineryFilmLenth:=0;
FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
	pstStUnitParam_Save:= ADR(i_pstStsysParam^.astStUnitParam_Save[iN]);
	pstStUnitParam_UnSave:=ADR(i_pstStsysParam^.astStUnitParam_UnSave[iN]);
	o_aiAxisList_AutoAdj[iN]:=BYTE_TO_INT(pstStGrpParam_UnSave^.abyGrpArcAxisList[iN]);	
	//rMachineryFilmLenth:=rMachineryFilmLenth+arFilmLengthFromPrevPressUnit[iN];
	abyRapidAdjustStep[iN]:=pstStUnitParam_UnSave^.byRapidAdjustStep;
END_FOR
o_byAxisNum_AutoAdj:=  pstStGrpParam_UnSave^.byGrpArcAxisNum ;
pstStUnitParam_Save:= ADR(i_pstStsysParam^.astStUnitParam_Save[o_byAxisNum_AutoAdj]);
(*2026.05.24.145550||wang.xy 计算等待时间，按照整个色组数-最后一个印刷轴 +2个机组料长，机组料长按照最后一个印刷色组的料长算*)
rMachineryFilmLenth:=(i_iGrpAxisNum_Pu-o_byAxisNum_AutoAdj+2)*pstStUnitParam_Save^.rFilmLengthFromPrevPressUnit;
(*2026.05.21.110304||测试用，结束需要删除wang.xy*)
// o_aiAxisList_AutoAdj[4]:=-1;
// o_byAxisNum_AutoAdj:=3;



(* 计算前后轴关系 *)
FOR iN := 1 TO o_byAxisNum_AutoAdj BY 1 DO
	iAxisId := o_aiAxisList_AutoAdj[iN];
	aiAxisId_Before[iAxisId] := -1;
	IF iN > 1 THEN
		aiAxisId_Before[iAxisId] := o_aiAxisList_AutoAdj[iN-1];
	END_IF
	
	aiAxisId_After[iAxisId] := -1;
	IF iN < o_byAxisNum_AutoAdj THEN
		aiAxisId_After[iAxisId] := o_aiAxisList_AutoAdj[iN+1];
	END_IF
END_FOR

