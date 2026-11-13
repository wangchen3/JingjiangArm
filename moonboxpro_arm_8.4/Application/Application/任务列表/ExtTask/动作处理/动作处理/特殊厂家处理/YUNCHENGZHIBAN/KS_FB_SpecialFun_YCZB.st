(*@CES
Name=KS_FB_SpecialFun_YCZB
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=b669fa9a-35d2-4a1a-8689-7d625f36155b
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_SpecialFun_YCZB
VAR_INPUT
	i_xEn							: BOOL;
	i_iGrpId: INT;
	i_iGrpAxisNum_Pu: INT;(*色组轴数量|*)
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT;(*排序好的轴id列表|*)
	i_pstStEvtReq							: POINTER TO StEvtReq;(*按钮输入操作及边沿触发描述|*)	
	i_pastStIOMap_Axis_FE					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|`````````````````````````````````````````````*)
	i_pstStSysParam: POINTER TO StSysParam;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	iN: INT;
	iUnitId: INT;
END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	IF i_iGrpAxisNum_Pu>=1 AND i_iGrpAxisNum_Pu<=MAX_UNIT_NUM AND
		(i_iGrpId=1 OR i_iGrpId=2) AND
		i_pstStEvtReq<>0 AND
		i_pstStSysParam<>0 AND
		i_pastStIOMap_Axis_FE<>0 THEN

		i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byAlarmType_NoMaterial_Uw:= 1;(*一直响铃直到按下正反转或者接料准备*)
		g_xAlarm_CutDne_Uw:=TRUE;(*接料以后响铃提示@2025.1.12.162627*)
		g_xCoolBlowerOpenByKnob:= TRUE;
		(*空转时候不允许手动色组合压@2024.12.30.103636*)
		(*2025.1.9.101053 重新调整*)
		IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Ink THEN
			FOR iN:= 1 TO i_iGrpAxisNum_Pu BY 1 DO
				iUnitId:=i_aiGrpAxisList[iN];
				i_pastStIOMap_Axis_FE^[iUnitId].i_xPress:=FALSE;(*不响应合压按钮*)
			END_FOR
		END_IF
		FOR iN:= 1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:=i_aiGrpAxisList[iN];
			i_pastStIOMap_Axis_FE^[iUnitId].o_xRsvd_DO0:= i_pastStIOMap_Axis_FE^[iUnitId].i_xRsvd_DI0;(*照明*)
			i_pastStIOMap_Axis_FE^[iUnitId].o_xRsvd_DO1:= i_pastStIOMap_Axis_FE^[iUnitId].i_xRsvd_DI1;(*版风*)
		END_FOR		
	END_IF
END_IF		