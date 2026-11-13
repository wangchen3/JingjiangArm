(*@CES
Name=KS_SetRemoteEncParam
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=52359865-76ae-4a72-8575-b7942d579f0c
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_SetRemoteEncParam : INT(*异站设置函数@用于月光系列*)
(*月光宝盒异站编码器设置功能@pro也使用*)
(*<0 代表设置失败*)
(*再次设置需要复位设置完成和设置失败标志*)
(*目前异站公式解释@仅代表2025.12.4时*)
(*
异站编码器输出必须是131072,
公式是 (输入编码器分辨率 * b / a)-> DDA ->DDA后分辨率 >> n = 131072 
分辨率太大,或者减速比设置不合适会引起DDA处理溢出
DDA:按照125M(8ns)进行插值,不溢出原则是8ns时间编码器值不能>1
*)
VAR_INPUT
	i_xUseLocalEnc:BOOL;(*使用本地编码器*)
	i_iStationId:INT;(*站号@月光宝盒的*)
	i_dwMotorEncResolution:DWORD;(*电机的编码器分辨率*)
	i_uiRotateSpeed_Max:UINT;(*最大转速*)
	i_dwRemoteEnc: DWORD:=131072;(*最终异站分辨率@131072|也是套色用的使用*)
	i_pxSetDne:POINTER TO BOOL;(*设置完成*)
	i_pxSetFailed:POINTER TO BOOL;(*设置失败*)
END_VAR
VAR
	xSetDne:BOOL;(*设置完成*)
	xSetFailed:BOOL;(*设置完成*)
	iRtn: INT;
	xUpdateRtn: BOOL;(*更新返回值*)
	byStationId:BYTE;
	uiA: UINT;
	uiB: UINT;
	dwSetMotorEnc: DWORD;
	dwRemoteEnc: DWORD:=131072;(*最终异站分辨率@131072|也是套色用的使用*)
	dwSetMotorEnc_DDA	: DWORD;(*DDA后电机分辨率*)
	byRshBit			: BYTE:=5;(*DDA后编码器右移位数*)
	byUseLocalEnc		: BYTE;
	sTemp : STRING;	
	uitime:UINT:=15225;(*临时测试，不需要同步*)
	
END_VAR
{IMPLEMENTATION}
IF i_pxSetDne<>0 THEN
	xSetDne:=i_pxSetDne^;
END_IF
IF i_pxSetFailed<>0 THEN
	xSetFailed:=i_pxSetFailed^;
END_IF
dwRemoteEnc:=i_dwRemoteEnc;(*2025.12.9.192118+*)
IF dwRemoteEnc=0 THEN
	dwRemoteEnc:=131072;
END_IF
sTemp := '';
IF (NOT xSetDne) OR (NOT xSetFailed) THEN


	IF i_iStationId>=0 AND i_iStationId<USER_MAX_STATION_NUM_V1 THEN
		byStationId:=INT_TO_BYTE(i_iStationId);
		(*检查dda是否过速度*)
		KS_CheckDDA(
			125(*i_byClock_MHZ*),
			i_dwMotorEncResolution(*i_dwMotorEncResolution*),
			i_uiRotateSpeed_Max(*i_uiRotateSpeed_Max*),
			dwRemoteEnc(*i_dwRemoteEnc*),
			0.95(*i_rMaxPulsePCycle*),
			ADR(uiA)(*i_puiA*),
			ADR(uiB)(*i_puiB*),
			ADR(dwSetMotorEnc)(*i_pdwSetMotorEnc*),
			ADR(dwSetMotorEnc_DDA)(*i_pdwSetMotorEnc_DDA*),
			ADR(byRshBit)(*i_pbyRshBit*));
		(*异站参数配置*)
		(*设置dda后右移位数*)
		//iRtn:=GT_RN_UserRemoteEncWr(0,byRshBit,byStationId);
		iRtn := GTN_RN_SetCameraRemoteEncParam(
			cardIndex:= 1, 
			busIndex:= 1, 
			stationPhyId:= byStationId, 
			encIndex:= 0, 
			paramIndex:= 0, 
			paramValue:= byRshBit);
			
			sTemp := CONCAT(' StationId: ',BYTE_TO_STRING(byStationId));
			sTemp := CONCAT(sTemp,' byRshBit: ');
			sTemp := CONCAT(sTemp,BYTE_TO_STRING(byRshBit));
			sTemp := CONCAT(sTemp,' iRtn: ');
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_DEBUG,sTemp, INT_TO_STRING(iRtn));
		IF iRtn=0 THEN(*设置正常*)
			(*设置经过变比后的dda分辨率*)
			//iRtn:=GT_RN_UserRemoteEncWr(1,dwSetMotorEnc_DDA,byStationId);
			iRtn := GTN_RN_SetCameraRemoteEncParam(
				cardIndex:= 1, 
				busIndex:= 1, 
				stationPhyId:= byStationId, 
				encIndex:= 0, 
				paramIndex:= 1, 
				paramValue:= dwSetMotorEnc_DDA);
			
			sTemp := CONCAT(' StationId: ',BYTE_TO_STRING(byStationId));
			sTemp := CONCAT(sTemp,' dwSetMotorEnc_DDA: ');
			sTemp := CONCAT(sTemp,DWORD_TO_STRING(dwSetMotorEnc_DDA));
			sTemp := CONCAT(sTemp,' iRtn: ');
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_DEBUG,sTemp, INT_TO_STRING(iRtn));
		END_IF
		IF iRtn=0 THEN(*设置正常*)
			(*设置电机实际分辨率*)
			//iRtn:=GT_RN_UserRemoteEncWr(2,dwSetMotorEnc,byStationId);
			iRtn := GTN_RN_SetCameraRemoteEncParam(
				cardIndex:= 1, 
				busIndex:= 1, 
				stationPhyId:= byStationId, 
				encIndex:= 0, 
				paramIndex:= 2, 
				paramValue:= dwSetMotorEnc);
	//2026.5.12.164334			
			sTemp := CONCAT(' StationId: ',BYTE_TO_STRING(byStationId));
			sTemp := CONCAT(sTemp,' dwSetMotorEnc: ');
			sTemp := CONCAT(sTemp,DWORD_TO_STRING(dwSetMotorEnc));
			sTemp := CONCAT(sTemp,' iRtn: ');
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_DEBUG,sTemp, INT_TO_STRING(iRtn));
		END_IF
		IF iRtn=0 THEN(*设置正常*)
			(*设置变比a*)
			//iRtn:=GT_RN_UserRemoteEncWr(3,uiA,byStationId);
			iRtn := GTN_RN_SetCameraRemoteEncParam(
				cardIndex:= 1, 
				busIndex:= 1, 
				stationPhyId:= byStationId, 
				encIndex:= 0, 
				paramIndex:= 3, 
				paramValue:= uiA);
//2026.5.12.164330				
			sTemp := CONCAT(' StationId: ',BYTE_TO_STRING(byStationId));
			sTemp := CONCAT(sTemp,' uiA: ');
			sTemp := CONCAT(sTemp,UINT_TO_STRING(uiA));
			sTemp := CONCAT(sTemp,' iRtn: ');
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_DEBUG,sTemp, INT_TO_STRING(iRtn));
		END_IF
		IF iRtn=0 THEN(*设置正常*)
			(*设置变比b*)
			//iRtn:=GT_RN_UserRemoteEncWr(4,uiB,byStationId);
			iRtn := GTN_RN_SetCameraRemoteEncParam(
				cardIndex:= 1, 
				busIndex:= 1, 
				stationPhyId:= byStationId, 
				encIndex:= 0, 
				paramIndex:= 4, 
				paramValue:= uiB);
				
			sTemp := CONCAT(' StationId: ',BYTE_TO_STRING(byStationId));
			sTemp := CONCAT(sTemp,' uiB: ');
			sTemp := CONCAT(sTemp,UINT_TO_STRING(uiB));
			sTemp := CONCAT(sTemp,' iRtn: ');
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_DEBUG,sTemp, INT_TO_STRING(iRtn));
		END_IF
		(*2026.05.13.103437临时测试，不需要同步*)
		IF iRtn=0 THEN(*设置正常*)
			(*设置变比a*)
			//iRtn:=GT_RN_UserRemoteEncWr(3,uiA,byStationId);
			iRtn := GTN_RN_SetCameraRemoteEncParam(
				cardIndex:= 1, 
				busIndex:= 1, 
				stationPhyId:= byStationId, 
				encIndex:= 0, 
				paramIndex:= 7, 
				paramValue:= uitime);

		END_IF		
		
		IF iRtn=0 THEN(*设置正常*)
			(*设置为异站或者本地*)
			IF i_xUseLocalEnc THEN(*本地*)
				byUseLocalEnc:=0;
			ELSE
				byUseLocalEnc:=1;
			END_IF
			//iRtn:=GT_RN_SetYGBHRemoteEnable(byUseLocalEnc,byStationId);(*TRUE:异站|FALSE:本地*)
			iRtn := GTN_RN_SetYGBHRemoteEnable(cardIndex:= 1, busIndex:= 1, enable:= byUseLocalEnc, station_id:= byStationId);
			
			sTemp := CONCAT(' StationId: ',BYTE_TO_STRING(byStationId));
			sTemp := CONCAT(sTemp,' byUseLocalEnc: ');
			sTemp := CONCAT(sTemp,BYTE_TO_STRING(byUseLocalEnc));
			sTemp := CONCAT(sTemp,' iRtn: ');
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_DEBUG,sTemp, INT_TO_STRING(iRtn));
		END_IF


		IF iRtn=0 THEN(*设置正常*)
			xSetDne:=TRUE;
		ELSE
			xSetFailed:=TRUE;
		END_IF
		xUpdateRtn:=TRUE;
	END_IF
ELSE;
END_IF
IF i_pxSetDne<>0 THEN
	i_pxSetDne^:=xSetDne;
END_IF
IF i_pxSetFailed<>0 THEN
	i_pxSetFailed^:=xSetFailed;
END_IF

IF xUpdateRtn THEN
	KS_SetRemoteEncParam:=iRtn;
END_IF



