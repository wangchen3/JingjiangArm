(*@CES
Name=KS_Decouple_FDPD
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=8d9e9d6d-c0f0-4b7a-ae7f-536a8c6cd98f
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_Decouple_FDPD : BOOL
VAR_INPUT
	i_xEn:BOOL;
	i_rPI2:REAL;(*PI2*)
	i_rPI3:REAL;(*PI3*)
	i_rPI4:REAL;(*PI4*)
	i_rPI5:REAL;(*PI5*)
	i_rPI6:REAL;(*PI6*)
	i_rPI7:REAL;(*PI7*)
	i_rPI8:REAL;(*PI8*)
	i_rPI9:REAL;(*PI9*)
	i_rPI10:REAL;(*PI10*)
	i_rPI11:REAL;(*PI11*)
	i_rPI12:REAL;(*PI12*)
	i_rPI13:REAL;(*PI13*)
	i_prU2: POINTER TO REAL;(*解耦后控制器2输出*)
	i_prU3: POINTER TO REAL;(*解耦后控制器3输出*)
	i_prU4: POINTER TO REAL;(*解耦后控制器4输出*)
	i_prU5: POINTER TO REAL;(*解耦后控制器5输出*)
	i_prU6: POINTER TO REAL;(*解耦后控制器6输出*)
	i_prU7: POINTER TO REAL;(*解耦后控制器7输出*)
	i_prU8: POINTER TO REAL;(*解耦后控制器8输出*)
	i_prU9: POINTER TO REAL;(*解耦后控制器9输出*)
	i_prU10: POINTER TO REAL;(*解耦后控制器10输出*)
	i_prU11: POINTER TO REAL;(*解耦后控制器11输出*)
	i_prU12: POINTER TO REAL;(*解耦后控制器12输出*)
	i_prU13: POINTER TO REAL;(*解耦后控制器13输出*)
(*系统参数*)
	i_rC:REAL;(*版周长mm*)
	i_rV:REAL;(*运行速度m/min*)
	i_rTs:REAL;(*周期@2024.8.2.170035+*)
	i_arLength:ARRAY [1..DECOUPLD_FDPD_MAX] OF REAL;(*料长数组，下标2表示一色至二色的料长*)
	i_DecoupleDepth:INT;
	i_pastStDecoupleFDPD: POINTER TO ARRAY [1..DECOUPLD_FDPD_MAX] OF StDecoupleFDPD;
END_VAR
VAR
	arPI: ARRAY [1..DECOUPLD_FDPD_MAX] OF REAL;(*色组pi控制量*)
	arDecoupleOut:ARRAY [1..DECOUPLD_FDPD_MAX] OF REAL;(*解耦输出*)
	rtemp:REAL;(*求和中间变量*)
	icnt:INT;(*移位计数器*)
	iLast:INT;(*找到最后一个色组下标*)
	rPai:REAL:=3.1415926535;(*圆周率*)
	radius:REAL;(*版辊半径*)
	w0:REAL;(*角速度*)
	iI: INT:=0;
	iJ: INT:=0;
	(*A*)
	rA:ARRAY [1..DECOUPLD_FDPD_MAX] OF REAL;(*传递函数参数*)
	rTs:REAL:=0;(*采样时间*)
	ra0:REAL:=0;
	rb0:REAL:=0;
	(*解耦数组*)
	arDecouple: ARRAY [1..DECOUPLD_FDPD_MAX,1..DECOUPLD_FDPD_MAX] OF REAL;

END_VAR
{IMPLEMENTATION}
arPI[2]:=i_rPI2;
arPI[3]:=i_rPI3;
arPI[4]:=i_rPI4;
arPI[5]:=i_rPI5;
arPI[6]:=i_rPI6;
arPI[7]:=i_rPI7;
arPI[8]:=i_rPI8;
arPI[9]:=i_rPI9;
arPI[10]:=i_rPI10;
arPI[11]:=i_rPI11;
arPI[12]:=i_rPI12;
arPI[13]:=i_rPI13;

IF i_xEn
	AND i_pastStDecoupleFDPD<> 0
	AND ( i_rV >0)
	AND ( i_rC >0) THEN(*版周长大于0*)
	radius:=i_rC/1000.0/rPai/2.0;
	w0:=i_rV/60.0/radius;
	FOR iI:=2 TO DECOUPLD_FDPD_MAX BY 1 DO
		IF i_arLength[iI]>0 THEN
			rA[iI]:=radius*w0/i_arLength[iI];
		END_IF
	END_FOR
	(*此传递函数，举例，传入2色PI，算出的是对2色之后所有印刷色组的解耦量[2].arYk[1]，传入3色PI，算出的是对3色之后所有印刷色组的解耦量[3].arYk[1]*)
	FOR iI:=2 TO DECOUPLD_FDPD_MAX  BY 1 DO
		IF rA[iI] >0 THEN
(*			rTs:=i_rC/(i_rV*1000.0/60.0);*)
			rTs:=i_rTs;
			rb0:=rA[iI];
			(*差分计算*)
			i_pastStDecoupleFDPD^[iI].arUk[1]:=arPI[iI];
			i_pastStDecoupleFDPD^[iI].arYk[1]:=1.0/(rb0*rTs+2.0)*(-((rb0*rTs-2.0)*i_pastStDecoupleFDPD^[iI].arYk[2])+((ra0*rTs+2.0)*i_pastStDecoupleFDPD^[iI].arUk[1])+((ra0*rTs-2.0)*i_pastStDecoupleFDPD^[iI].arUk[2]));
		ELSE
			i_pastStDecoupleFDPD^[iI].arUk[1]:=0;
			i_pastStDecoupleFDPD^[iI].arYk[1]:=0;
		END_IF
	END_FOR
	iLast:=0;
	FOR iI:=3 TO DECOUPLD_FDPD_MAX  BY 1 DO(*从3色开始计数*)
		IF i_arLength[iI]>0 THEN
			iLast:=iLast+1;
		END_IF
	END_FOR
	iLast:=iLast+2;(*添加2色和1色*)
	(*解耦参数不合理，默认解耦深度4*)
	IF i_DecoupleDepth>11 THEN
		i_DecoupleDepth:=4;
	ELSIF i_DecoupleDepth=0 THEN(*按照当前印刷色组全解耦*)
		i_DecoupleDepth:=iLast-2;(*全解耦深度=印刷色组个数-2，一色二色不用解耦*)
	END_IF
	(*
	解耦数组表示iI.iJ  iI表示第几色，iJ表示前面对应解耦输出，当输入解耦深度为1时，主对角线(iI-iJ<=1)取解耦值，其余值为0
	当输入解耦深度为2时，主对角线以及次主对角线(iI-iJ<=2)取解耦值，其余值为0
	当输入解耦深度为3时，主对角线以及次主对角线以及次次对角线(iI-iJ<=3)取解耦值，其余值为0
	3.2
	4.2		4.3
	5.2		5.3 	5.4
	6.2		6.3 	6.4 	6.5 
	7.2		7.3 	7.4 	7.5 	7.6
	8.2		8.3 	8.4 	8.5 	8.6 	8.7
	9.2		9.3 	9.4 	9.5 	9.6 	9.7 	9.8
	10.2	10.3 	10.4 	10.5 	10.6 	10.7 	10.8 	10.9
	11.2	11.3 	11.4 	11.5 	11.6 	11.7 	11.8 	11.9 	11.10
	12.2	12.3 	12.4 	12.5 	12.6 	12.7 	12.8 	12.9 	12.10 	12.11
	13.2	13.3 	13.4 	13.5 	13.6 	13.7 	13.8 	13.9 	13.10 	13.11 	13.12
	*)
	FOR iI:=3 TO iLast  BY 1 DO
		FOR iJ:=2 TO iI-1  BY 1 DO
			IF iI-iJ<=i_DecoupleDepth THEN
				arDecouple[iI,iJ]:=i_pastStDecoupleFDPD^[iJ].arYk[1];
			ELSE
				arDecouple[iI,iJ]:=0;
			END_IF
		END_FOR
	END_FOR
	arDecoupleOut[2]:=arPI[2];(*2色保持原有PI输出*)
	(*其余色组按照解耦数组累计进行求和处理*)
	FOR iI:=3 TO iLast  BY 1 DO
		rtemp:=0;
		FOR iJ:=2 TO iI-1  BY 1 DO
			rtemp:=rtemp+arDecouple[iI,iJ];
		END_FOR
		arDecoupleOut[iI]:=arPI[iI]+rtemp;
	END_FOR
	(*拍数后移一位*)
	FOR iI:=1 TO DECOUPLD_FDPD_MAX BY 1 DO
		FOR icnt:=3 TO 2 BY -1 DO
			i_pastStDecoupleFDPD^[iI].arUk[icnt]:=i_pastStDecoupleFDPD^[iI].arUk[icnt-1];
			i_pastStDecoupleFDPD^[iI].arYk[icnt]:=i_pastStDecoupleFDPD^[iI].arYk[icnt-1];
		END_FOR
		i_pastStDecoupleFDPD^[iI].arUk[1]:=0;
		i_pastStDecoupleFDPD^[iI].arYk[1]:=0;
	END_FOR
ELSE
	FOR  iI:=2 TO DECOUPLD_FDPD_MAX  BY 1 DO
		arDecoupleOut[iI]:=arPI[iI];
	END_FOR
END_IF

IF  i_prU2<>0
	AND i_prU3<>0
	AND i_prU4<>0
	AND i_prU5<>0
	AND i_prU6<>0
	AND i_prU7<>0
	AND i_prU8<>0
	AND i_prU9<>0
	AND i_prU10<>0
	AND i_prU11<>0
	AND i_prU12<>0
	AND i_prU13<>0 THEN
	i_prU2^:=arDecoupleOut[2];
	i_prU3^:=arDecoupleOut[3];
	i_prU4^:=arDecoupleOut[4];
	i_prU5^:=arDecoupleOut[5];
	i_prU6^:=arDecoupleOut[6];
	i_prU7^:=arDecoupleOut[7];
	i_prU8^:=arDecoupleOut[8];
	i_prU9^:=arDecoupleOut[9];
	i_prU10^:=arDecoupleOut[10];
	i_prU11^:=arDecoupleOut[11];
	i_prU12^:=arDecoupleOut[12];
	i_prU13^:=arDecoupleOut[13];
END_IF