(*@CES
Name=KS_FB_ExportRSFifo2File
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=280a4f81-a5dc-40a5-adea-619cfced529e
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_ExportRSFifo2File
VAR_INPUT
	i_xEn: BOOL;
	i_sPath: STRING :=  '/data/kesai/data/RS';
	i_pstStRSampFifo: POINTER TO StRSampFifo := 0;
END_VAR
VAR_OUTPUT
	//o_xEno: BOOL;
	o_iErNo: INT;(* 0表示ok/-1参数错误/-2文件创建失败/100暂时没有数据写入 *)
END_VAR
VAR
	byIDX_Wr_Tmp: BYTE;
	byIDX_Rd_Tmp: BYTE;
	sFullFname: STRING(260):= '';
	dwHdlFile: RTS_IEC_HANDLE;(* TYPE RTS_IEC_HANDLE : POINTER TO BYTE *)
	udiRtn: RTS_IEC_RESULT;(* TYPE RTS_IEC_RESULT : UDINT *)
						(* TYPE RTS_IEC_SIZE : POINTER TO BYTE *)
						(* RTS_INVALID_HANDLE: RTS_IEC_HANDLE(-1) *)
END_VAR
{IMPLEMENTATION}
IF i_xEn THEN
	IF i_pstStRSampFifo<>0 THEN
		byIDX_Wr_Tmp:= i_pstStRSampFifo^.byIDX_Wr AND BYTE#7;
		byIDX_Rd_Tmp:= i_pstStRSampFifo^.byIDX_Rd AND BYTE#7;
		IF byIDX_Wr_Tmp<>byIDX_Rd_Tmp THEN

			sFullFname:= i_sPath;
			IF RIGHT(i_sPath,1)<>'\' THEN
				sFullFname:= CONCAT(sFullFname, '\');
			END_IF
			sFullFname:= CONCAT(sFullFname, 'U');
			sFullFname:= CONCAT(sFullFname, BYTE_TO_STRING(i_pstStRSampFifo^.astStRSampData[byIDX_Rd_Tmp].byUnitNR));
			sFullFname:= CONCAT(sFullFname, '-');
			sFullFname:= CONCAT(sFullFname, UDINT_TO_STRING(i_pstStRSampFifo^.astStRSampData[byIDX_Rd_Tmp].udiTskCycleNR));
			sFullFname:= CONCAT(sFullFname, '-');
			sFullFname:= CONCAT(sFullFname, DINT_TO_STRING(i_pstStRSampFifo^.astStRSampData[byIDX_Rd_Tmp].diVel));
			sFullFname:= CONCAT(sFullFname, '@');
			sFullFname:= CONCAT(sFullFname, KS_GetTimeString(TIMEFORMAT_HYPHEN_DOT, TRUE, TRUE));
			sFullFname:= CONCAT(sFullFname, '.rs');

			dwHdlFile:= SysFileOpen(sFullFname, SysFile.AM_WRITE, ADR(udiRtn));
			IF dwHdlFile<>0 THEN
				SysFileWrite(
					dwHdlFile,
					ADR(i_pstStRSampFifo^.astStRSampData[byIDX_Rd_Tmp].abyRs_T1),
					SIZEOF(i_pstStRSampFifo^.astStRSampData[byIDX_Rd_Tmp].abyRs_T1),
					 ADR(udiRtn));
				SysFileWrite(
					dwHdlFile,
					ADR(i_pstStRSampFifo^.astStRSampData[byIDX_Rd_Tmp].abyRs_T2),
					SIZEOF(i_pstStRSampFifo^.astStRSampData[byIDX_Rd_Tmp].abyRs_T2),
					 ADR(udiRtn));
				SysFileClose(dwHdlFile);

				i_pstStRSampFifo^.byIDX_Rd:= byIDX_Rd_Tmp+1;
			ELSE
				o_iErNo:= -2;
			END_IF
		ELSE
			o_iErNo:= 100;
		END_IF
	ELSE
		o_iErNo:= -1;
	END_IF
END_IF