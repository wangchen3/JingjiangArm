(*@CES
Name=KS_FB_MEASURE_DUT
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=cbaf68c5-1803-4b5d-b906-58e4bfb16f90
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_MEASURE_DUT
VAR_INPUT
	i_xEn: BOOL;
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_iErNo: INT;

	o_MAX_UNIT_NUM: INT;
	o_MAX_STATION_NUM: INT;

	o_dwLen_StParam_Diamonds_Wr: DWORD;
	o_dwLen_StParam_Diamonds_Wr_Err: DWORD;
	o_dwLen_StParam_Diamonds_Wr_RdSam: DWORD;
	o_dwLen_StParam_Diamonds_Wr_RunSts: DWORD;
	o_dwLen_StParam_Diamonds_Wr_SysSts: DWORD;
	o_dwLen_StSts_GrpFlag: DWORD;
	o_dwLen_StSts_Modbus: DWORD;
	o_dwLen_StSts_PressRoller_Flag: DWORD;
	o_dwLen_StSts_UnitFlag: DWORD;
	o_dwLen_StSts_UnitParam: DWORD;
	o_dwLen_StSts_UnitParam_2: DWORD;
	
	o_dwLen_StParam_Diamonds_WrRd: DWORD;
	o_dwLen_StWrRd_Switch_Grp: DWORD;
	o_dwLen_StWrRd_Switch_Machine: DWORD;
	o_dwLen_StWrRd_Switch_Unit: DWORD;
	o_dwLen_StWrRd_UnitParam: DWORD;

	o_dwLen_member_stStParam_Diamonds_Wr_SysSts: DWORD;
	o_dwLen_member_stStParam_Diamonds_Wr_RdSam: DWORD;
	o_dwLen_member_astStParam_Diamonds_Wr_Err: DWORD;
	o_dwLen_member_astStParam_Diamonds_Wr_RunSts: DWORD;

END_VAR
VAR
	(*写区域*)
	pstStParam_Diamonds_Wr: POINTER TO StParam_Diamonds_Wr;

	(*写-附属一级*)
	pstStParam_Diamonds_Wr_Err: POINTER TO StParam_Diamonds_Wr_Err;
	pstStParam_Diamonds_Wr_RdSam: POINTER TO StParam_Diamonds_Wr_RdSam;
	pstStParam_Diamonds_Wr_RunSts: POINTER TO StParam_Diamonds_Wr_RunSts;
	pstStParam_Diamonds_Wr_SysSts: POINTER TO StParam_Diamonds_Wr_SysSts;
	
	(*写-附属二级*)
	pstStSts_GrpFlag: POINTER TO StSts_GrpFlag;
	pstStSts_Modbus: POINTER TO StSts_Modbus;
	pstStSts_PressRoller_Flag: POINTER TO StSts_PressRoller_Flag;
	pstStSts_UnitFlag: POINTER TO StSts_UnitFlag;
	pstStSts_UnitParam: POINTER TO StSts_UnitParam;
	pstStSts_UnitParam_2: POINTER TO StSts_UnitParam_2;


	(*读区域*)
	pstStParam_Diamonds_WrRd: POINTER TO StParam_Diamonds_WrRd;

	(*读写-附属*)
	pstStWrRd_Switch_Grp: POINTER TO StWrRd_Switch_Grp;
	pstStWrRd_Switch_Machine: POINTER TO StWrRd_Switch_Machine;
	pstStWrRd_Switch_Unit: POINTER TO StWrRd_Switch_Unit;
	pstStWrRd_UnitParam: POINTER TO StWrRd_UnitParam;
END_VAR

{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;
o_MAX_UNIT_NUM:= MAX_UNIT_NUM;
o_MAX_STATION_NUM:= MAX_STATION_NUM;

IF i_xEn THEN
	o_dwLen_StParam_Diamonds_Wr:= SIZEOF(pstStParam_Diamonds_Wr^);
	o_dwLen_StParam_Diamonds_Wr_Err:= SIZEOF(pstStParam_Diamonds_Wr_Err^);
	o_dwLen_StParam_Diamonds_Wr_RdSam:= SIZEOF(pstStParam_Diamonds_Wr_RdSam^);
	o_dwLen_StParam_Diamonds_Wr_RunSts:= SIZEOF(pstStParam_Diamonds_Wr_RunSts^);
	o_dwLen_StParam_Diamonds_Wr_SysSts:= SIZEOF(pstStParam_Diamonds_Wr_SysSts^);
	o_dwLen_StSts_GrpFlag:= SIZEOF(pstStSts_GrpFlag^);
	o_dwLen_StSts_Modbus:= SIZEOF(pstStSts_Modbus^);
	o_dwLen_StSts_PressRoller_Flag:= SIZEOF(pstStSts_PressRoller_Flag^);
	o_dwLen_StSts_UnitFlag:= SIZEOF(pstStSts_UnitFlag^);
	o_dwLen_StSts_UnitParam:= SIZEOF(pstStSts_UnitParam^);
	o_dwLen_StSts_UnitParam_2:= SIZEOF(pstStSts_UnitParam_2^);

	o_dwLen_StParam_Diamonds_WrRd:= SIZEOF(pstStParam_Diamonds_WrRd^);
	o_dwLen_StWrRd_Switch_Grp:= SIZEOF(pstStWrRd_Switch_Grp^);
	o_dwLen_StWrRd_Switch_Machine:= SIZEOF(pstStWrRd_Switch_Machine^);
	o_dwLen_StWrRd_Switch_Unit:= SIZEOF(pstStWrRd_Switch_Unit^);
	o_dwLen_StWrRd_UnitParam:= SIZEOF(pstStWrRd_UnitParam^);

	o_dwLen_member_stStParam_Diamonds_Wr_SysSts:= SIZEOF(pstStParam_Diamonds_Wr^.stStParam_Diamonds_Wr_SysSts);
	o_dwLen_member_stStParam_Diamonds_Wr_RdSam:= SIZEOF(pstStParam_Diamonds_Wr^.stStParam_Diamonds_Wr_RdSam);
	o_dwLen_member_astStParam_Diamonds_Wr_Err:= SIZEOF(pstStParam_Diamonds_Wr^.astStParam_Diamonds_Wr_Err);
	o_dwLen_member_astStParam_Diamonds_Wr_RunSts:= SIZEOF(pstStParam_Diamonds_Wr^.astStParam_Diamonds_Wr_RunSts);
END_IF
