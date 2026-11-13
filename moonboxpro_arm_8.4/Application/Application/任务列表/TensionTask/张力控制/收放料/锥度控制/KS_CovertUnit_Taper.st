(*@CES
Name=KS_CovertUnit_Taper
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=64151f1e-8911-4786-9206-474c18fed1e9
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CovertUnit_Taper : BOOL(*锥度单位转换|以%作为基准互相转换*)
(*如果参数出错了，则会重新处理单位变量|2022.10.16.104813*)
(*2025.1.15.152522 增加了停机张力值的处理@主要时针对收料*)
VAR_INPUT
	i_pbyUnit:POINTER TO BYTE;(*单位值|0-%|1-N|2-Mpa|参数非法按照百分比显示*)
	i_xConfirmN:BOOL;(*牛顿对应确认按钮*)
	i_xConfirmMpa:BOOL;(*Mpa对应确认按钮*)
	i_prConfirmTaperPercentMatchN:POINTER TO REAL;(*确认的百分比值-牛顿单位*)
	i_prConfirmTaperPercentMatchMpa:POINTER TO REAL;(*确认的百分比值-Mpa单位*)
	i_rConfirmTaperN: REAL;(*确认的牛顿值*)
	i_rConfirmTaperMpa: REAL;(*确认的Mpa值*)
	i_prTaperValueBegin_Hmi:POINTER TO REAL;(*界面锥度显示值-起始*)
	i_prTaperValueEnd_Hmi:POINTER TO REAL;(*界面锥度显示值-结束*)
	i_prTaperValueCur_Hmi:POINTER TO REAL;(*界面显示当前值|根据单位切换*)
	i_pbyLastUnit:POINTER TO BYTE;(*上个周期的单位选择值*)

	i_prTaperPencent_Begin:POINTER TO REAL;(*锥度起始百分比值*)
	i_prTaperPencent_End:POINTER TO REAL;(*锥度起始百分比值*)
	i_lrTaperPencent_Cur:LREAL;(*锥度起始百分比当前值*)

	(*2025.1.15.152522 增加了停机张力值的处理@主要时针对收料*)
	(*不用可以写0*)
	i_pbyInitTaper:POINTER TO BYTE;(*停机初始气压百分比*)
	i_prInitTaper_Hmi:POINTER TO REAL;(*收料初始气压显示值|根据单位切换*)

END_VAR
VAR
	lrConfirmTaperPencent: LREAL;(*确认的百分比值——和*)
	lrConfirmTaper: LREAL;(*确认的百分比对应的单位的值*)

	lrCoeff: LREAL;
END_VAR
{IMPLEMENTATION}
IF i_prConfirmTaperPercentMatchN<>0 AND
	i_prConfirmTaperPercentMatchMpa<>0 AND
	i_prTaperValueBegin_Hmi<>0 AND
	i_prTaperValueEnd_Hmi<>0 AND
	i_prTaperPencent_Begin<>0 AND
	i_pbyLastUnit<>0 AND
	i_pbyUnit<>0 AND
	i_prTaperValueCur_Hmi<>0 AND
	i_prTaperPencent_End<>0 THEN;
ELSE
	RETURN;
END_IF

(*确认对应关系|*)
IF i_xConfirmN THEN(*N确认|*)
	i_prConfirmTaperPercentMatchN^:=LREAL_TO_REAL(i_lrTaperPencent_Cur);
END_IF

IF i_xConfirmMpa THEN(*Mpa确认|*)
	i_prConfirmTaperPercentMatchMpa^:=LREAL_TO_REAL(i_lrTaperPencent_Cur);
END_IF


CASE i_pbyUnit^ OF
	1:(*单位N*)
		lrConfirmTaperPencent:=i_prConfirmTaperPercentMatchN^;
		lrConfirmTaper:=i_rConfirmTaperN;

		(*2022.10.16.104832 +*)
		IF lrConfirmTaperPencent=0 OR
			lrConfirmTaper=0 THEN
			i_pbyUnit^:=0;(*确认的系数出错了|不能切换单位*)
		END_IF
	2:(*单位Mpa*)
		lrConfirmTaperPencent:=i_prConfirmTaperPercentMatchMpa^;
		lrConfirmTaper:=i_rConfirmTaperMpa;
		(*2022.10.16.104832 +*)
		IF lrConfirmTaperPencent=0 OR
			lrConfirmTaper=0 THEN
			i_pbyUnit^:=0;(*确认的系数出错了|不能切换单位*)
		END_IF
ELSE(*单位%*)
	lrConfirmTaperPencent:=0;(*根据下面条件|使用百分比显示*)
	i_pbyUnit^:=0;
END_CASE


(*单位切换了|*)
lrCoeff:=1;
IF lrConfirmTaperPencent<>0 AND  lrConfirmTaper<>0 THEN
	lrCoeff:=(lrConfirmTaper)/lrConfirmTaperPencent;
END_IF

IF i_pbyLastUnit^ <> i_pbyUnit^ THEN(*将百分比值按照对应单位换算写入*)
	i_prTaperValueBegin_Hmi^:=LREAL_TO_REAL(lrCoeff*i_prTaperPencent_Begin^);
	i_prTaperValueEnd_Hmi^:=LREAL_TO_REAL(lrCoeff*i_prTaperPencent_End^);

	(*2025.1.15.152838+针对收料起始气压的处理输出*)
	IF i_prInitTaper_Hmi<>0 AND i_pbyInitTaper<>0 THEN
		i_prInitTaper_Hmi^:=LREAL_TO_REAL(lrCoeff*i_pbyInitTaper^);
	END_IF
ELSE
	i_prTaperPencent_Begin^:=LREAL_TO_REAL(i_prTaperValueBegin_Hmi^/lrCoeff);
	i_prTaperPencent_End^:=LREAL_TO_REAL(i_prTaperValueEnd_Hmi^/lrCoeff);
	(*最大100*)
	IF i_prTaperPencent_Begin^>100 THEN i_prTaperPencent_Begin^:=100;END_IF
	IF i_prTaperPencent_End^>100 THEN i_prTaperPencent_End^:=100;END_IF


	(*2025.1.15.152838+针对收料起始气压的处理输出*)
	IF i_prInitTaper_Hmi<>0 AND i_pbyInitTaper<>0 THEN
		i_pbyInitTaper^:=LREAL_TO_BYTE(i_prInitTaper_Hmi^/lrCoeff);
		IF i_pbyInitTaper^>100 THEN i_pbyInitTaper^:=100; END_IF
	END_IF

END_IF
(*当前值根据单位转换*)
i_prTaperValueCur_Hmi^:=LREAL_TO_REAL(lrCoeff*i_lrTaperPencent_Cur);
(*更新上个周期的单位值*)
i_pbyLastUnit^:=i_pbyUnit^;
