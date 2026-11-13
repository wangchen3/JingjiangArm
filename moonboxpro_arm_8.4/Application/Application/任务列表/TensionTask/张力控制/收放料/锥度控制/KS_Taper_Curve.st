(*@CES
Name=KS_Taper_Curve
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=9d8a75d4-e332-49bf-ad4d-ef60c80700c3
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_Taper_Curve : LREAL(*锥度1/X算法*)(*输出当前锥度*)
(*2025.1.9.162727  增加当前卷径输入*)
(*2025.2.26.163100 bug处理*)
VAR_INPUT
	i_rDiamCurAxis_Rw:REAL;(*2025.1.9.162744+*)
	i_rTaper_Begin_Rw: REAL;(*起始锥度*)
	i_rTaper_End_Rw: REAL;(*结束锥度*)
	i_rDiamTaper_Begin_Rw: REAL;(*起始锥度-直径*)
	i_rDiamTaper_End_Rw: REAL;(*结束锥度-直径*)
END_VAR
VAR
	lrMomentSa: LREAL;(*起始力矩*)
	lrMomentEd: LREAL;(*结束力矩*)
	lrCurrentMoment: LREAL;(*当前力矩*)
	lrCurrentTaper:LREAL;
END_VAR
{IMPLEMENTATION}
lrCurrentTaper:=0;
lrMomentSa:=(i_rTaper_Begin_Rw)*i_rDiamTaper_Begin_Rw;
lrMomentEd:=(i_rTaper_End_Rw)*i_rDiamTaper_End_Rw;

(*取消该限制@2025.2.26.163020*)
(*	IF lrMomentEd< lrMomentSa THEN lrMomentEd:=lrMomentSa;END_IF*)

IF i_rDiamCurAxis_Rw<= i_rDiamTaper_Begin_Rw THEN
	(*最小卷用最大张力*)
	lrCurrentTaper:= i_rTaper_Begin_Rw;
ELSIF i_rDiamCurAxis_Rw>= i_rDiamTaper_End_Rw THEN
	(*最大卷用最小张力*)
	lrCurrentTaper:= i_rTaper_End_Rw;
ELSE
	IF ( i_rDiamTaper_End_Rw-i_rDiamTaper_Begin_Rw)<>0 THEN
		lrCurrentMoment:=lrMomentSa+(lrMomentEd-lrMomentSa)*(i_rDiamCurAxis_Rw-i_rDiamTaper_Begin_Rw)
						/(i_rDiamTaper_End_Rw-i_rDiamTaper_Begin_Rw);
	ELSE
		lrCurrentMoment:=lrMomentSa;
	END_IF

	IF i_rDiamCurAxis_Rw<>0 THEN
		lrCurrentTaper:=lrCurrentMoment/i_rDiamCurAxis_Rw;
	ELSE
		lrCurrentTaper:=i_rTaper_Begin_Rw;
	END_IF
END_IF


KS_Taper_Curve:=lrCurrentTaper;