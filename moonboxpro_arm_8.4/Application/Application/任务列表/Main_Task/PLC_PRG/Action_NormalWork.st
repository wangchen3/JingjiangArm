(*@CES
Name=Action_NormalWork
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=0c2cac26-0e9d-4da9-87e4-715d51ed9cb2
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*主任务--2025.5.29.091257--*)
aliTime_Value[1]:= LTIME();
Action_Normal_Update_HMIBtn();
Action_Normal_Input();
aliTime_Value[2]:= LTIME();
Action_Normal_Act();
aliTime_Value[7]:= LTIME();
Action_Normal_Output();
aliTime_Value[9]:= LTIME();


aliTime_Value[11]:= aliTime_Value[2]-aliTime_Value[1];
aliTime_Value[12]:= aliTime_Value[3]-aliTime_Value[2];
aliTime_Value[13]:= aliTime_Value[4]-aliTime_Value[3];
aliTime_Value[14]:= aliTime_Value[5]-aliTime_Value[4];
aliTime_Value[15]:= aliTime_Value[6]-aliTime_Value[5];
aliTime_Value[16]:= aliTime_Value[7]-aliTime_Value[6];
aliTime_Value[17]:= aliTime_Value[8]-aliTime_Value[7];
aliTime_Value[18]:= aliTime_Value[9]-aliTime_Value[8];
aliTime_Value[19]:= aliTime_Value[9]-aliTime_Value[1];
g_dwNormalWorkRunNum:= g_dwNormalWorkRunNum+1;