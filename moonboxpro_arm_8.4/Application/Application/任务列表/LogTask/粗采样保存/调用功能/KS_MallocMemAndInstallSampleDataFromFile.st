(*@CES
Name=KS_MallocMemAndInstallSampleDataFromFile
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=69c33b95-f0e0-43d2-8407-04367f5534f4
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_MallocMemAndInstallSampleDataFromFile : DWORD
VAR_INPUT
	i_sFilename_Rs_demo: STRING := '\cpac\rs.demo';
	i_sFilename_Fs_demo: STRING := '\cpac\fs.demo';
END_VAR
VAR
	iN: INT;
	dwMemHdl: DWORD;(* 内存句柄 *)
	dwFileHdl: DWORD;(* 文件句柄 *)
	diSize_Rs_demo: DINT;
	diSize_Fs_demo: DINT;
	pstStSampleDataForTest: POINTER TO StSampleDataForTest := 0;
END_VAR
{IMPLEMENTATION}
dwMemHdl:= SysMemAlloc(SIZEOF(pstStSampleDataForTest^));
pstStSampleDataForTest:= dwMemHdl;
IF pstStSampleDataForTest<>0 THEN
	(* 粗采样 *)
	diSize_Rs_demo:= SysFileGetSize(i_sFilename_Rs_demo);
	IF diSize_Rs_demo=16#10000 THEN(* 文件必须64kB *)
		dwFileHdl:= SysFileOpen(i_sFilename_Rs_demo, 'r');
		IF dwFileHdl<>0 THEN
			FOR iN:=1 TO 8 BY 1 DO
				SysFileSetPos(dwFileHdl, INT_TO_DWORD(iN-1)*8192);(* T1 *)
				SysFileRead(dwFileHdl, ADR(pstStSampleDataForTest^.abyBuf_Rs[iN-1,   1]), 4000);
				SysFileSetPos(dwFileHdl, INT_TO_DWORD(iN-1)*8192+4096);(* T2 *)
				SysFileRead(dwFileHdl, ADR(pstStSampleDataForTest^.abyBuf_Rs[iN-1,4001]), 4000);
			END_FOR
			SysFileClose(dwFileHdl);
		END_IF
	END_IF

	(* 精采样 *)
	diSize_Fs_demo:= SysFileGetSize(i_sFilename_Fs_demo);
	IF diSize_Fs_demo=16#10000 THEN(* 文件必须64kB *)
		dwFileHdl:= SysFileOpen(i_sFilename_Fs_demo, 'r');
		IF dwFileHdl<>0 THEN
			FOR iN:=1 TO 8 BY 1 DO
				SysFileSetPos(dwFileHdl, INT_TO_DWORD(iN-1)*8192);(* T1 *)
				SysFileRead(dwFileHdl, ADR(pstStSampleDataForTest^.abyBuf_Fs[iN-1,   1]), 4000);
				SysFileSetPos(dwFileHdl, INT_TO_DWORD(iN-1)*8192+4096);(* T2 *)
				SysFileRead(dwFileHdl, ADR(pstStSampleDataForTest^.abyBuf_Fs[iN-1,4001]), 4000);
			END_FOR
			SysFileClose(dwFileHdl);
		END_IF
	END_IF
END_IF
KS_MallocMemAndInstallSampleDataFromFile:= dwMemHdl;