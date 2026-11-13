(*@CES
Name=KS_StationOnline
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=46162c4a-8077-432f-856c-536c68fec6ca
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_StationOnline : INT //2026.5.19.103428判断站点是否在线
VAR_INPUT
	i_iStationId: INT;
	i_pstStationInf_KS: POINTER TO StStationInfo_KS;
END_VAR
VAR
	iN: INT;
END_VAR

{IMPLEMENTATION}
KS_StationOnline:= 0;
IF i_iStationId>=0 AND i_iStationId<=MAX_STATION_NUM AND
	i_pstStationInf_KS<>0 THEN
	FOR iN:= 1 TO i_pstStationInf_KS^.iStationNum BY 1 DO
		IF i_pstStationInf_KS^.aiStationId_List[iN]= i_iStationId THEN
			KS_StationOnline:= 1;//返回只=1说明正常在线
			EXIT;
		END_IF
		IF iN= i_pstStationInf_KS^.iStationNum AND
			KS_StationOnline=0 THEN//离线
			KS_StationOnline:= -2;
		END_IF
	END_FOR
ELSE
	KS_StationOnline:= -1;
END_IF