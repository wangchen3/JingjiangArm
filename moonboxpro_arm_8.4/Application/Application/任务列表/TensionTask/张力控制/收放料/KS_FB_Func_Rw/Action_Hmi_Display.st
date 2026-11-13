(*@CES
Name=Action_Hmi_Display
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=4c880fbf-3690-4704-b3d4-7564e3cf9ab7
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*2026.05.20.224949 针对天枢的通讯机制金刚到天枢数据做时延处理 by liu.yt*)
IF xParaInit OR(*开机初始化*)
	xLastCutOnTop<>io_xCutOnTop THEN (*上下裁刀切换了*)
	(*需要上行|一定时间里禁止下行数据更新*)
	xUpdateUpLoadData:=TRUE;
	fbTon_UpLoadData(IN:=FALSE);
END_IF
fbTon_UpLoadData(IN:=xUpdateUpLoadData,PT:=T#1000MS);
IF fbTon_UpLoadData.Q THEN
	xUpdateUpLoadData:=FALSE;
END_IF
(*END*)

//2026.05.20.212619 增加处理
(*界面显示裁切相关时间变量处理*)
pstStTimeSet_DnCut_UpCut:=ADR(io_astStTimeSet_DnCut_UpCut[BOOL_TO_INT(io_xCutOnTop)]);
IF xParaInit OR(*开机初始化*)
	xLastCutOnTop<>io_xCutOnTop THEN(*裁刀换了*)
	io_stStTimeSet_DnCut_UpCut_Hmi:=pstStTimeSet_DnCut_UpCut^;
END_IF

io_stStTimeSet_DnCut_UpCut_Hmi.rStepVariation4ChangeDis:=pstStTimeSet_DnCut_UpCut^.rStepVariation4ChangeDis;(*只显示*)

(*都是金刚通讯实现机制惹的祸@2026.05.21.110637*)
IF NOT xUpdateUpLoadData THEN(*2026.05.20.225458+条件*)
	pstStTimeSet_DnCut_UpCut^:=io_stStTimeSet_DnCut_UpCut_Hmi;
ELSE(*更新本地变量@2026.05.21.110551+*)
	io_stStTimeSet_DnCut_UpCut_Hmi:=pstStTimeSet_DnCut_UpCut^;
END_IF
//END

xLastCutOnTop:=io_xCutOnTop;
xParaInit:=FALSE;