(*@CES
Name=KS_InitEstPara
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=ee2b4dc0-cfeb-471c-b1f7-6492871368b6
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_InitEstPara : BOOL(*初始化估计参数*)
VAR_INPUT
	i_rInitRadius:REAL:=200;(*估计卷半径初始值-mm*)
	i_rInitThickNess:REAL:=0;(*估计厚度初始值*)
	i_parPh:POINTER TO ARRAY [1..3,1..3] OF REAL;(*矩阵地址3X3*)
	i_parXh:POINTER TO ARRAY [1..3] OF REAL;(*矩阵1x3-Xh[1]为估计的卷径(半径-mm),Xh[2]为估计的厚度,Xh[3]为估计的张力 *)
END_VAR
VAR
	(*初始取值*)
	(*估计算法使用了矩阵计算|下面数组实际是矩阵定义*)
	arPh:ARRAY [1..3,1..3] OF REAL:=[1,0,0,0,1,0,0,0,0];
END_VAR
{IMPLEMENTATION}
IF i_parPh<>0 AND
	i_parXh<>0 THEN
	(*进行初始化*)
	i_parPh^:=arPh;
	i_parXh^[1]:=i_rInitRadius;
	i_parXh^[2]:=i_rInitThickNess;
	i_parXh^[3]:=0;
END_IF