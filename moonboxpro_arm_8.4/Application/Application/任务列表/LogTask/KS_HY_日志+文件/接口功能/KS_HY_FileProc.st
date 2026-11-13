(*@CES
Name=KS_HY_FileProc
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=f478979a-6038-403b-861a-7e2c2eb17e6a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_HY_FileProc : INT
(* 火眼系统文件处理功能接口
/ ..................................................
/ 处理的文件包含两种类别: 1).系统配置参数/2).系统参数文件
/ 操作方式: AM_WRITE/AM_READ(Owner SysFile library)
/ ..................................................
/ 返回值:
/ 0.无错误/-1.传入参数非法/-2.操作的文件类型未收录
/ -3.文件访问出现错误/-4.读写的数据长度和期望的不一致
/ -5.读取的信息校验未通过/
/ -13.第2个文件写入失败
/ ..................................................
/ 特别说明:
/ 数据操作引入内存快照的原由是因为数据读写有crc校验
/ 所以在保存完成前这片内存是不能被更新的
/ 所以单独开辟了个内存区域存放一份完整的数据
*)
VAR_INPUT
	i_iFileTyp_cfg0_para1: INT;(* 0.配置信息文件/1.系统参数文件 *)
	i_xFileOpt_falseR_trueW: BOOL;(* FALSE.读操作/TRUE.写操作 *)
	i_pstStSysCfgStruct: POINTER TO StSysCfgStruct;(* 配置信息 *)
	i_pstStSysParam: POINTER TO StSysParam;(* 系统参数 *)
	i_dwDlen: DWORD;(* 数据区域大小/不包含校验 *)
	i_dwMemSnapshot: DWORD;(* 内存快照区域/系统开机就申请好1M字节/需要能涵盖保存的数据区域 *)
	i_sFileName: STRING;(* 文件名称/FNAME_SYS_CONF/FNAME_SYS_PARAM_A/FNAME_SYS_PARAM_B *)
	i_xEnableWriteFile2: BOOL;(* 使能第2个文件的写入操作/减少一次对内存的crc操作/节省时间开销 *)
	i_sFileName_2: STRING;(* 使能第2个文件的直接写入 *)
	i_pdiErrCodeEx: POINTER TO DINT;(* 返回的具体错误代码 *)
END_VAR
VAR
	iResult: INT;(* 返回值 *)

	wChk: WORD;
	dwSum: DWORD;
	wChk_tmp: WORD;
	dwSum_tmp: DWORD;

	dwDlen_AdditionInfo: DWORD;(* 附加信息长度/默认6字节/2字节CRC/4字节累加和 *)
	dwDlen_InclChk: DWORD;(* 包含校验的长度 *)
	dwDlen_Access: DWORD;(* 实际访问的有效数据长度 *)

	dwHdlFile: RTS_IEC_HANDLE;(* TYPE RTS_IEC_HANDLE : POINTER TO BYTE *)
	udiRtn: RTS_IEC_RESULT;(* TYPE RTS_IEC_RESULT : UDINT *)
						(* TYPE RTS_IEC_SIZE : POINTER TO BYTE *)
						(* RTS_INVALID_HANDLE: RTS_IEC_HANDLE(-1) *)
	rtnSFW: __XWORD;
END_VAR

{IMPLEMENTATION}
iResult:= 0;
dwDlen_AdditionInfo:= SIZEOF(wChk) + SIZEOF(dwSum);
dwDlen_InclChk:= i_dwDlen+dwDlen_AdditionInfo;
IF i_sFileName<>'' AND
	i_dwMemSnapshot<>0 AND
	(i_dwDlen>0 AND i_dwDlen<=(16#100000-dwDlen_AdditionInfo)) THEN(* 用原始参数进行判断 *)

	IF (i_iFileTyp_cfg0_para1=0 AND i_pstStSysCfgStruct<>0) OR
		(i_iFileTyp_cfg0_para1=1 AND i_pstStSysParam<>0) THEN
		(* 文件类型和其分别对应的数据地址有效 *)

		IF i_xFileOpt_falseR_trueW THEN(* 写 *)

			(* 先把内存拍照存档/之后就不用担心原数据区域发生变化了 *)
			IF i_iFileTyp_cfg0_para1=0 THEN(* 配置信息 *)
				SysMemCpy(i_dwMemSnapshot, i_pstStSysCfgStruct, i_dwDlen);
			ELSE(* 参数信息 *)
				SysMemCpy(i_dwMemSnapshot, i_pstStSysParam, i_dwDlen);
			END_IF

			(* 我们开始生成校验信息 *)
			wChk_tmp:= KS_CRC(i_dwMemSnapshot, i_dwDlen, ADR(dwSum_tmp));
			SysMemCpy(i_dwMemSnapshot+i_dwDlen, ADR(wChk_tmp), SIZEOF(wChk_tmp));
			SysMemCpy(i_dwMemSnapshot+i_dwDlen+SIZEOF(wChk_tmp), ADR(dwSum_tmp), SIZEOF(dwSum_tmp));

			(* 创建文件 *)
			dwHdlFile:= SysFileOpen(i_sFileName, SysFile.AM_WRITE, ADR(udiRtn));
			IF dwHdlFile<>RTS_INVALID_HANDLE THEN(* 成功 *)
				rtnSFW:= SysFileWrite(dwHdlFile, i_dwMemSnapshot, dwDlen_InclChk, ADR(udiRtn));
				SysFileClose(dwHdlFile);
				IF rtnSFW=0 THEN(* 写文件出现错误/曾经出现16#29(41)的错误:ERR_DISK_FULL *)

				END_IF
			ELSE(* 文件创建失败 *)
				iResult:= -3;
				IF i_pdiErrCodeEx<>0 THEN i_pdiErrCodeEx^:= UDINT_TO_DINT(udiRtn); END_IF
			END_IF

			(* 使能第2个文件写入 *)
			IF i_xEnableWriteFile2 AND
				i_sFileName_2<>'' AND
				i_sFileName_2<>i_sFileName THEN

				dwHdlFile:= SysFileOpen(i_sFileName_2, SysFile.AM_WRITE, ADR(udiRtn));
				IF dwHdlFile<>RTS_INVALID_HANDLE THEN(* 成功 *)
					rtnSFW:= SysFileWrite(dwHdlFile, i_dwMemSnapshot, dwDlen_InclChk, ADR(udiRtn));
					SysFileClose(dwHdlFile);
					IF rtnSFW=0 THEN(* 写文件出现错误/曾经出现16#29(41)的错误:ERR_DISK_FULL *)

					END_IF
				ELSE(* 文件创建失败 *)
					iResult:= -13;
					IF i_pdiErrCodeEx<>0 THEN i_pdiErrCodeEx^:= UDINT_TO_DINT(udiRtn); END_IF
				END_IF
			END_IF

		ELSE(* 读 *)

			(* 打开文件 *)
			dwHdlFile:= SysFileOpen(i_sFileName, SysFile.AM_READ, ADR(udiRtn));
			IF dwHdlFile<>RTS_INVALID_HANDLE THEN(* 成功 *)

				(* 搬运到内存后就尽快关闭文件 *)
				dwDlen_Access:= SysFileRead(dwHdlFile, i_dwMemSnapshot, dwDlen_InclChk, ADR(udiRtn));
				SysFileClose(dwHdlFile);

				(* 开始进行内存的操作 *)
				IF dwDlen_Access=dwDlen_InclChk THEN(* 数据量有效 *)

					(* 先把文件保存的校验信息读取出来 *)
					SysMemCpy(ADR(wChk), i_dwMemSnapshot+i_dwDlen, SIZEOF(wChk));
					SysMemCpy(ADR(dwSum), i_dwMemSnapshot+i_dwDlen+SIZEOF(wChk), SIZEOF(dwSum));

					(* 我们再复算一遍校验信息 *)
					wChk_tmp:= KS_CRC(i_dwMemSnapshot, i_dwDlen, ADR(dwSum_tmp));

//2026.4.6.122232增加累加和不为0
					IF wChk=wChk_tmp AND dwSum=dwSum_tmp AND dwSum<>0 THEN(* 校验信息通过 *)

						(* 可以直接搬运到目标内存区域 *)
						IF i_iFileTyp_cfg0_para1=0 THEN
							SysMemCpy(i_pstStSysCfgStruct, i_dwMemSnapshot, i_dwDlen);
						ELSE
							SysMemCpy(i_pstStSysParam, i_dwMemSnapshot, i_dwDlen);
						END_IF
					ELSE
						iResult:= -5;
					END_IF
				ELSE(* 数据量不足或者读取时出现错误 *)
					iResult:= -4;
					IF i_pdiErrCodeEx<>0 THEN i_pdiErrCodeEx^:= UDINT_TO_DINT(udiRtn); END_IF
				END_IF
			ELSE(* 文件打开失败 *)
				iResult:= -3;
				IF i_pdiErrCodeEx<>0 THEN i_pdiErrCodeEx^:= UDINT_TO_DINT(udiRtn); END_IF
			END_IF
		END_IF
	ELSE
		iResult:= -2;
	END_IF
ELSE
	iResult:= -1;
END_IF

KS_HY_FileProc:= iResult;
