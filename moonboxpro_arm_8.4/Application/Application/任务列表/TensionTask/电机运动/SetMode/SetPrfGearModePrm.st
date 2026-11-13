(*@CES
Name=SetPrfGearModePrm
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=f035424c-4733-45cb-8bf8-2e7099a0fe7e
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION SetPrfGearModePrm : INT
VAR_INPUT
	i_iCore:INT;					//前64轴核号为1，后64轴轴号为2
	i_iAxisId:INT;	
	i_iMasterIndex:INT;		//主轴索引
	i_diMasterEven:DINT;	//主轴转数
	i_diSlaveEven:DINT;		//从轴转数
	i_diMasterSlope:DINT;	//离合区
	i_xMasterType : BOOL;
END_VAR
VAR
	iRtn: INT;
	iMasterType : INT;
END_VAR

{IMPLEMENTATION}
iRtn :=  GTN_PrfGear(i_iCore,i_iAxisId,0) + iRtn;
// 设置电子齿轮运动参数
IF i_xMasterType THEN
	iMasterType := GEAR_MASTER_AXIS;
ELSE
	iMasterType := GEAR_MASTER_AXIS_OTHER;
END_IF
iMasterType := GEAR_MASTER_AXIS;
iRtn :=  GTN_SetGearMaster(
		core:= i_iCore, 
		profile:= i_iAxisId, 
		masterIndex:= i_iMasterIndex, 
		masterType:= iMasterType, 
		masterItem:= 0) + iRtn;

iRtn :=  GTN_SetGearRatio(
		core:= i_iCore, 
		profile:= i_iAxisId, 
		masterEven:= i_diMasterEven, 					//主轴转数
		slaveEven:= i_diSlaveEven, 						//对应从轴转数
		masterSlope:= i_diMasterSlope) + iRtn;

SetPrfGearModePrm:=iRtn;