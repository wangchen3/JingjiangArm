(*@CES
Name=KS_FB_DIAMONDS_SysCfg_WrRd
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=0ad9e19b-9230-4270-998c-ed4fab391ba6
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_DIAMONDS_SysCfg_WrRd
VAR_INPUT
	i_xEn : BOOL;
	i_xWr : BOOL;
	i_xRd : BOOL;
	i_iStationNum : INT;
	i_pstStWrRd_SysCfg : POINTER TO StWrRd_SysCfg;
	i_pstStSysCfgStruct : POINTER TO StSysCfgStruct;

	i_paiStationId_List : POINTER TO ARRAY [1..128] OF INT;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	iGrp : INT;
	iUnitId : INT;
	iStationId : INT;
END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	IF i_pstStWrRd_SysCfg <> 0 AND i_pstStSysCfgStruct <> 0  AND i_paiStationId_List <> 0 THEN
		IF i_xWr THEN
			i_pstStWrRd_SysCfg^.iCompanyId := i_pstStSysCfgStruct^.iCompanyId;
			i_pstStWrRd_SysCfg^.byLanguageId := i_pstStSysCfgStruct^.byLanguageId;
			i_pstStWrRd_SysCfg^.byUnitMaxNum := i_pstStSysCfgStruct^.byUnitMaxNum;
			FOR iUnitId := 1 TO MAX_UNIT_NUM BY 1 DO
				//PC
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PC_[iUnitId].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_PC_[iUnitId].dwAxisProf.0;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PC_[iUnitId].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_PC_[iUnitId].dwAxisProf.1;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PC_[iUnitId].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_PC_[iUnitId].dwAxisProf.2;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PC_[iUnitId].iSid:=	i_pstStSysCfgStruct^.astStAxisCfgStruct_PC_[iUnitId].iSid;
				//BR
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_BR_[iUnitId].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_BR_[iUnitId].dwAxisProf.0;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_BR_[iUnitId].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_BR_[iUnitId].dwAxisProf.1;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_BR_[iUnitId].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_BR_[iUnitId].dwAxisProf.2;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_BR_[iUnitId].iSid:=	i_pstStSysCfgStruct^.astStAxisCfgStruct_BR_[iUnitId].iSid;
				
				//PR
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_[iUnitId].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_[iUnitId].dwAxisProf.0;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_[iUnitId].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_[iUnitId].dwAxisProf.1;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_[iUnitId].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_[iUnitId].dwAxisProf.2;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_[iUnitId].iSid:=	i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_[iUnitId].iSid;
				
				//NR
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_[iUnitId].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_[iUnitId].dwAxisProf.0;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_[iUnitId].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_[iUnitId].dwAxisProf.1;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_[iUnitId].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_[iUnitId].dwAxisProf.2;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_[iUnitId].iSid:=	i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_[iUnitId].iSid;
				
				//PR_M
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_M_[iUnitId].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_M_[iUnitId].dwAxisProf.0;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_M_[iUnitId].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_M_[iUnitId].dwAxisProf.1;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_M_[iUnitId].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_M_[iUnitId].dwAxisProf.2;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_M_[iUnitId].iSid:=	i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_M_[iUnitId].iSid;
				
				//PR_G
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_G_[iUnitId].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_G_[iUnitId].dwAxisProf.0;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_G_[iUnitId].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_G_[iUnitId].dwAxisProf.1;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_G_[iUnitId].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_G_[iUnitId].dwAxisProf.2;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_G_[iUnitId].iSid:=	i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_G_[iUnitId].iSid;
				
				//NR_M
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_M_[iUnitId].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_M_[iUnitId].dwAxisProf.0;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_M_[iUnitId].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_M_[iUnitId].dwAxisProf.1;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_M_[iUnitId].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_M_[iUnitId].dwAxisProf.2;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_M_[iUnitId].iSid:=	i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_M_[iUnitId].iSid;
				                                       
				//NR_G                                 
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_G_[iUnitId].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_G_[iUnitId].dwAxisProf.0;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_G_[iUnitId].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_G_[iUnitId].dwAxisProf.1;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_G_[iUnitId].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_G_[iUnitId].dwAxisProf.2;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_G_[iUnitId].iSid:=	i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_G_[iUnitId].iSid;
				
				//STR_M
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_STR_M_[iUnitId].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_M_[iUnitId].dwAxisProf.0;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_STR_M_[iUnitId].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_M_[iUnitId].dwAxisProf.1;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_STR_M_[iUnitId].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_M_[iUnitId].dwAxisProf.2;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_STR_M_[iUnitId].iSid:=	i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_M_[iUnitId].iSid;
				                                       
				//STR_G                                
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_STR_G_[iUnitId].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_G_[iUnitId].dwAxisProf.0;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_STR_G_[iUnitId].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_G_[iUnitId].dwAxisProf.1;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_STR_G_[iUnitId].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_G_[iUnitId].dwAxisProf.2;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_STR_G_[iUnitId].iSid:=	i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_G_[iUnitId].iSid;
				
				//HORIZ                                
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_HORIZ_[iUnitId].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_HORIZ_[iUnitId].dwAxisProf.0;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_HORIZ_[iUnitId].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_HORIZ_[iUnitId].dwAxisProf.1;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_HORIZ_[iUnitId].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_HORIZ_[iUnitId].dwAxisProf.2;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_HORIZ_[iUnitId].iSid:=	i_pstStSysCfgStruct^.astStAxisCfgStruct_HORIZ_[iUnitId].iSid;
				//控制器|月光宝盒站号2026.5.20.140213
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_Ctl[iUnitId].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_Ctl_[iUnitId].dwAxisProf.0;
				i_pstStWrRd_SysCfg^.astStAxisCfgStruct_Ctl[iUnitId].iSid := i_pstStSysCfgStruct^.astStAxisCfgStruct_Ctl_[iUnitId].iSid;

			END_FOR
			

			//UW_I|A
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_I[1].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[1].dwAxisProf.0;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_I[1].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[1].dwAxisProf.1;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_I[1].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[1].dwAxisProf.2;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_I[1].iSid := i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[1].iSid;
			//UW_I|B
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_I[2].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[2].dwAxisProf.0;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_I[2].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[2].dwAxisProf.1;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_I[2].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[2].dwAxisProf.2;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_I[2].iSid := i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[2].iSid;
			
			//RW_I|A
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_I[1].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[1].dwAxisProf.0;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_I[1].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[1].dwAxisProf.1;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_I[1].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[1].dwAxisProf.2;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_I[1].iSid:= i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[1].iSid;
			//RW_I|B
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_I[2].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[2].dwAxisProf.0;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_I[2].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[2].dwAxisProf.1;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_I[2].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[2].dwAxisProf.2;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_I[2].iSid:= i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[2].iSid;
			
			
			//CD_I_1
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_I[1].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[1].dwAxisProf.0;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_I[1].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[1].dwAxisProf.1;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_I[1].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[1].dwAxisProf.2;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_I[1].iSid := i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[1].iSid;
			//CD_I_2
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_I[2].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[2].dwAxisProf.0;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_I[2].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[2].dwAxisProf.1;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_I[2].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[2].dwAxisProf.2;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_I[2].iSid := i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[2].iSid;

			
			//UW_II_A
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_II[1].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[1].dwAxisProf.0;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_II[1].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[1].dwAxisProf.1;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_II[1].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[1].dwAxisProf.2;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_II[1].iSid := i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[1].iSid;
			//UW_II_B
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_II[2].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[2].dwAxisProf.0;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_II[2].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[2].dwAxisProf.1;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_II[2].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[2].dwAxisProf.2;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_II[2].iSid := i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[2].iSid;

													   
			//RW_II_A                                    
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_II[1].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[1].dwAxisProf.0;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_II[1].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[1].dwAxisProf.1;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_II[1].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[1].dwAxisProf.2;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_II[1].iSid := i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[1].iSid;
			//RW_II_B                                    
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_II[2].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[2].dwAxisProf.0;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_II[2].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[2].dwAxisProf.1;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_II[2].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[2].dwAxisProf.2;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_II[2].iSid := i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[2].iSid;

													   
			//CD_II_1                                    
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_II[1].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[1].dwAxisProf.0;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_II[1].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[1].dwAxisProf.1;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_II[1].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[1].dwAxisProf.2;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_II[1].iSid := i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[1].iSid;
			//CD_II_2                                    
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_II[2].xAxisProf_Enable := i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[2].dwAxisProf.0;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_II[2].xAxisProf_MotRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[2].dwAxisProf.1;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_II[2].xAxisProf_SamRev := i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[2].dwAxisProf.2;
			i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_II[2].iSid := i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[2].iSid;

			
			
			//IF_I
			i_pstStWrRd_SysCfg^.stStAxisCfgStruct_IF_I.xAxisProf_Enable := i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_I.dwAxisProf.0;
			i_pstStWrRd_SysCfg^.stStAxisCfgStruct_IF_I.xAxisProf_MotRev := i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_I.dwAxisProf.1;
			i_pstStWrRd_SysCfg^.stStAxisCfgStruct_IF_I.xAxisProf_SamRev := i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_I.dwAxisProf.2;
			i_pstStWrRd_SysCfg^.stStAxisCfgStruct_IF_I.iSid := i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_I.iSid;

			
			//OF_I
			i_pstStWrRd_SysCfg^.stStAxisCfgStruct_OF_I.xAxisProf_Enable := i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_I.dwAxisProf.0;
			i_pstStWrRd_SysCfg^.stStAxisCfgStruct_OF_I.xAxisProf_MotRev := i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_I.dwAxisProf.1;
			i_pstStWrRd_SysCfg^.stStAxisCfgStruct_OF_I.xAxisProf_SamRev := i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_I.dwAxisProf.2;
			i_pstStWrRd_SysCfg^.stStAxisCfgStruct_OF_I.iSid := i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_I.iSid;

			
			//IF_II
			i_pstStWrRd_SysCfg^.stStAxisCfgStruct_IF_II.xAxisProf_Enable := i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_II.dwAxisProf.0;
			i_pstStWrRd_SysCfg^.stStAxisCfgStruct_IF_II.xAxisProf_MotRev := i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_II.dwAxisProf.1;
			i_pstStWrRd_SysCfg^.stStAxisCfgStruct_IF_II.xAxisProf_SamRev := i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_II.dwAxisProf.2;
			i_pstStWrRd_SysCfg^.stStAxisCfgStruct_IF_II.iSid := i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_II.iSid;

			                                         
			//OF_II                                  
			i_pstStWrRd_SysCfg^.stStAxisCfgStruct_OF_II.xAxisProf_Enable := i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_II.dwAxisProf.0;
			i_pstStWrRd_SysCfg^.stStAxisCfgStruct_OF_II.xAxisProf_MotRev := i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_II.dwAxisProf.1;
			i_pstStWrRd_SysCfg^.stStAxisCfgStruct_OF_II.xAxisProf_SamRev := i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_II.dwAxisProf.2;
			i_pstStWrRd_SysCfg^.stStAxisCfgStruct_OF_II.iSid := i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_II.iSid;

			
		END_IF
		
		IF i_xRd THEN
			i_pstStSysCfgStruct^.iCompanyId := i_pstStWrRd_SysCfg^.iCompanyId;
			i_pstStSysCfgStruct^.byLanguageId := i_pstStWrRd_SysCfg^.byLanguageId;
			i_pstStSysCfgStruct^.byUnitMaxNum := i_pstStWrRd_SysCfg^.byUnitMaxNum;
			FOR iUnitId := 1 TO MAX_UNIT_NUM BY 1 DO
				//PC
				i_pstStSysCfgStruct^.astStAxisCfgStruct_PC_[iUnitId].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PC_[iUnitId].xAxisProf_Enable ;
                i_pstStSysCfgStruct^.astStAxisCfgStruct_PC_[iUnitId].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PC_[iUnitId].xAxisProf_MotRev ;
			    i_pstStSysCfgStruct^.astStAxisCfgStruct_PC_[iUnitId].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PC_[iUnitId].xAxisProf_SamRev ;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_PC_[iUnitId].iSid :=  i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PC_[iUnitId].iSid;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_PC_[iUnitId].iUnitId := iUnitId;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_PC_[iUnitId].dwAxisProf.31 := 
						KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_PC_[iUnitId].iSid,
												i_iStationNum,
												i_paiStationId_List);
				
				//BR
				i_pstStSysCfgStruct^.astStAxisCfgStruct_BR_[iUnitId].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_BR_[iUnitId].xAxisProf_Enable ;
                i_pstStSysCfgStruct^.astStAxisCfgStruct_BR_[iUnitId].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_BR_[iUnitId].xAxisProf_MotRev ;
			    i_pstStSysCfgStruct^.astStAxisCfgStruct_BR_[iUnitId].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_BR_[iUnitId].xAxisProf_SamRev ;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_BR_[iUnitId].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_BR_[iUnitId].iSid;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_BR_[iUnitId].iUnitId := iUnitId;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_BR_[iUnitId].dwAxisProf.31 := 
						KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_BR_[iUnitId].iSid,
												i_iStationNum,
												i_paiStationId_List);
																																						
				//PR
				i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_[iUnitId].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_[iUnitId].xAxisProf_Enable ;
                i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_[iUnitId].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_[iUnitId].xAxisProf_MotRev ;
			    i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_[iUnitId].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_[iUnitId].xAxisProf_SamRev ;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_[iUnitId].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_[iUnitId].iSid;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_[iUnitId].iUnitId := iUnitId;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_[iUnitId].dwAxisProf.31 := 
						KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_[iUnitId].iSid,
												i_iStationNum,
												i_paiStationId_List);
				//NR
				i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_[iUnitId].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_[iUnitId].xAxisProf_Enable ;
                i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_[iUnitId].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_[iUnitId].xAxisProf_MotRev ;
			    i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_[iUnitId].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_[iUnitId].xAxisProf_SamRev ;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_[iUnitId].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_[iUnitId].iSid;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_[iUnitId].iUnitId := iUnitId;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_[iUnitId].dwAxisProf.31 := 
						KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_[iUnitId].iSid,
												i_iStationNum,
												i_paiStationId_List);
				//PR_M
				i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_M_[iUnitId].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_M_[iUnitId].xAxisProf_Enable ;
                i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_M_[iUnitId].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_M_[iUnitId].xAxisProf_MotRev ;
			    i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_M_[iUnitId].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_M_[iUnitId].xAxisProf_SamRev ;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_M_[iUnitId].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_M_[iUnitId].iSid;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_M_[iUnitId].iUnitId := iUnitId;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_M_[iUnitId].dwAxisProf.31 := 
						KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_M_[iUnitId].iSid,
												i_iStationNum,
												i_paiStationId_List);								
				//PR_G
				i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_G_[iUnitId].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_G_[iUnitId].xAxisProf_Enable ;
                i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_G_[iUnitId].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_G_[iUnitId].xAxisProf_MotRev ;
			    i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_G_[iUnitId].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_G_[iUnitId].xAxisProf_SamRev ;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_G_[iUnitId].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_PR_G_[iUnitId].iSid;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_G_[iUnitId].iUnitId := iUnitId;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_G_[iUnitId].dwAxisProf.31 := 
						KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_PR_G_[iUnitId].iSid,
												i_iStationNum,
												i_paiStationId_List);	

				//NR_M
				i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_M_[iUnitId].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_M_[iUnitId].xAxisProf_Enable ;
                i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_M_[iUnitId].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_M_[iUnitId].xAxisProf_MotRev ;
			    i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_M_[iUnitId].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_M_[iUnitId].xAxisProf_SamRev ;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_M_[iUnitId].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_M_[iUnitId].iSid;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_M_[iUnitId].iUnitId := iUnitId;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_M_[iUnitId].dwAxisProf.31 := 
						KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_M_[iUnitId].iSid,
												i_iStationNum,
												i_paiStationId_List);								
				//NR_G
				i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_G_[iUnitId].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_G_[iUnitId].xAxisProf_Enable ;
                i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_G_[iUnitId].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_G_[iUnitId].xAxisProf_MotRev ;
			    i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_G_[iUnitId].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_G_[iUnitId].xAxisProf_SamRev ;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_G_[iUnitId].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_NR_G_[iUnitId].iSid;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_G_[iUnitId].iUnitId := iUnitId;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_G_[iUnitId].dwAxisProf.31 := 
						KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_G_[iUnitId].iSid,
												i_iStationNum,
												i_paiStationId_List);

				//STR_M
				i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_M_[iUnitId].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_STR_M_[iUnitId].xAxisProf_Enable ;
                i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_M_[iUnitId].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_STR_M_[iUnitId].xAxisProf_MotRev ;
			    i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_M_[iUnitId].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_STR_M_[iUnitId].xAxisProf_SamRev ;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_M_[iUnitId].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_STR_M_[iUnitId].iSid;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_M_[iUnitId].iUnitId := iUnitId;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_M_[iUnitId].dwAxisProf.31 := 
						KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_NR_M_[iUnitId].iSid,
												i_iStationNum,
												i_paiStationId_List);								
				//STR_G
				i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_G_[iUnitId].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_STR_G_[iUnitId].xAxisProf_Enable ;
                i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_G_[iUnitId].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_STR_G_[iUnitId].xAxisProf_MotRev ;
			    i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_G_[iUnitId].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_STR_G_[iUnitId].xAxisProf_SamRev ;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_G_[iUnitId].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_STR_G_[iUnitId].iSid;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_G_[iUnitId].iUnitId := iUnitId;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_G_[iUnitId].dwAxisProf.31 := 
						KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_STR_G_[iUnitId].iSid,
												i_iStationNum,
												i_paiStationId_List);	

				//HORIZ
				i_pstStSysCfgStruct^.astStAxisCfgStruct_HORIZ_[iUnitId].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_HORIZ_[iUnitId].xAxisProf_Enable ;
                i_pstStSysCfgStruct^.astStAxisCfgStruct_HORIZ_[iUnitId].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_HORIZ_[iUnitId].xAxisProf_MotRev ;
			    i_pstStSysCfgStruct^.astStAxisCfgStruct_HORIZ_[iUnitId].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_HORIZ_[iUnitId].xAxisProf_SamRev ;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_HORIZ_[iUnitId].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_HORIZ_[iUnitId].iSid;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_HORIZ_[iUnitId].iUnitId := iUnitId;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_HORIZ_[iUnitId].dwAxisProf.31 := 
						KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_HORIZ_[iUnitId].iSid,
												i_iStationNum,
												i_paiStationId_List);					

				//控制器|月光宝盒站号2026.5.20.140213
				i_pstStSysCfgStruct^.astStAxisCfgStruct_Ctl_[iUnitId].dwAxisProf.0:= i_pstStWrRd_SysCfg^.astStAxisCfgStruct_Ctl[iUnitId].xAxisProf_Enable;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_Ctl_[iUnitId].iSid:= i_pstStWrRd_SysCfg^.astStAxisCfgStruct_Ctl[iUnitId].iSid;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_Ctl_[iUnitId].iUnitId := iUnitId;
				i_pstStSysCfgStruct^.astStAxisCfgStruct_Ctl_[iUnitId].dwAxisProf.31 := 
						KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_Ctl_[iUnitId].iSid,
												i_iStationNum,
												i_paiStationId_List);					

			END_FOR
			
			//UW_I_1
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[1].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_I[1].xAxisProf_Enable ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[1].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_I[1].xAxisProf_MotRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[1].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_I[1].xAxisProf_SamRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[1].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_I[1].iSid;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[1].iUnitId := -1;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[1].dwAxisProf.31 := 
					KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[1].iSid,
											i_iStationNum,
											i_paiStationId_List);
			//UW_I_2
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[2].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_I[2].xAxisProf_Enable ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[2].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_I[2].xAxisProf_MotRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[2].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_I[2].xAxisProf_SamRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[2].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_I[2].iSid;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[2].iUnitId := -1;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[2].dwAxisProf.31 := 
					KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_I[2].iSid,
											i_iStationNum,
											i_paiStationId_List);
											
			//RW_I_1
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[1].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_I[1].xAxisProf_Enable ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[1].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_I[1].xAxisProf_MotRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[1].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_I[1].xAxisProf_SamRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[1].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_I[1].iSid;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[1].iUnitId := -1;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[1].dwAxisProf.31 := 
					KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[1].iSid,
											i_iStationNum,
											i_paiStationId_List);
			//RW_I_2
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[2].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_I[2].xAxisProf_Enable ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[2].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_I[2].xAxisProf_MotRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[2].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_I[2].xAxisProf_SamRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[2].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_I[2].iSid;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[2].iUnitId := -1;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[2].dwAxisProf.31 := 
					KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_I[2].iSid,
											i_iStationNum,
											i_paiStationId_List);
											
			//CD_I_1
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[1].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_I[1].xAxisProf_Enable ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[1].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_I[1].xAxisProf_MotRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[1].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_I[1].xAxisProf_SamRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[1].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_I[1].iSid;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[1].iUnitId := -1;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[1].dwAxisProf.31 := 
					KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[1].iSid,
											i_iStationNum,
											i_paiStationId_List);
			//CD_I_2
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[2].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_I[2].xAxisProf_Enable ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[2].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_I[2].xAxisProf_MotRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[2].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_I[2].xAxisProf_SamRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[2].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_I[2].iSid;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[2].iUnitId := -1;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[2].dwAxisProf.31 := 
					KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_I[2].iSid,
											i_iStationNum,
											i_paiStationId_List);
											
			//UW_II_1
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[1].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_II[1].xAxisProf_Enable ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[1].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_II[1].xAxisProf_MotRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[1].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_II[1].xAxisProf_SamRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[1].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_II[1].iSid;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[1].iUnitId := -1;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[1].dwAxisProf.31 := 
					KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[1].iSid,
											i_iStationNum,
											i_paiStationId_List);
			//UW_II_2
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[2].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_II[2].xAxisProf_Enable ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[2].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_II[2].xAxisProf_MotRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[2].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_II[2].xAxisProf_SamRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[2].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_UW_II[2].iSid;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[2].iUnitId := -1;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[2].dwAxisProf.31 := 
					KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_UW_II[2].iSid,
											i_iStationNum,
											i_paiStationId_List);
											
			//RW_II_1
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[1].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_II[1].xAxisProf_Enable ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[1].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_II[1].xAxisProf_MotRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[1].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_II[1].xAxisProf_SamRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[1].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_II[1].iSid;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[1].iUnitId := -1;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[1].dwAxisProf.31 := 
					KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[1].iSid,
											i_iStationNum,
											i_paiStationId_List);
			//RW_II_2
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[2].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_II[2].xAxisProf_Enable ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[2].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_II[2].xAxisProf_MotRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[2].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_II[2].xAxisProf_SamRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[2].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_RW_II[2].iSid;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[2].iUnitId := -1;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[2].dwAxisProf.31 := 
					KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_RW_II[2].iSid,
											i_iStationNum,
											i_paiStationId_List);
						
					
			//CD_II_1
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[1].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_II[1].xAxisProf_Enable ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[1].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_II[1].xAxisProf_MotRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[1].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_II[1].xAxisProf_SamRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[1].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_II[1].iSid;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[1].iUnitId := -1;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[1].dwAxisProf.31 := 
					KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[1].iSid,
											i_iStationNum,
											i_paiStationId_List);
			//CD_II_2
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[2].dwAxisProf.0 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_II[2].xAxisProf_Enable ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[2].dwAxisProf.1 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_II[2].xAxisProf_MotRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[2].dwAxisProf.2 := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_II[2].xAxisProf_SamRev ;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[2].iSid := i_pstStWrRd_SysCfg^.astStAxisCfgStruct_CD_II[2].iSid;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[2].iUnitId := -1;
			i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[2].dwAxisProf.31 := 
					KS_CheckStationOnLine_(i_pstStSysCfgStruct^.astStAxisCfgStruct_CD_II[2].iSid,
											i_iStationNum,
											i_paiStationId_List);
											
			//IF_I
			i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_I.dwAxisProf.0 := i_pstStWrRd_SysCfg^.stStAxisCfgStruct_IF_I.xAxisProf_Enable ;
			i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_I.dwAxisProf.1 := i_pstStWrRd_SysCfg^.stStAxisCfgStruct_IF_I.xAxisProf_MotRev ;
			i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_I.dwAxisProf.2 := i_pstStWrRd_SysCfg^.stStAxisCfgStruct_IF_I.xAxisProf_SamRev ;
			i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_I.iSid := i_pstStWrRd_SysCfg^.stStAxisCfgStruct_IF_I.iSid;
			i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_I.iUnitId := -1;
			i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_I.dwAxisProf.31 := 
					KS_CheckStationOnLine_(i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_I.iSid,
											i_iStationNum,
											i_paiStationId_List);
											
			//OF_I
			i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_I.dwAxisProf.0 := i_pstStWrRd_SysCfg^.stStAxisCfgStruct_OF_I.xAxisProf_Enable ;
			i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_I.dwAxisProf.1 := i_pstStWrRd_SysCfg^.stStAxisCfgStruct_OF_I.xAxisProf_MotRev ;
			i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_I.dwAxisProf.2 := i_pstStWrRd_SysCfg^.stStAxisCfgStruct_OF_I.xAxisProf_SamRev ;
			i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_I.iSid := i_pstStWrRd_SysCfg^.stStAxisCfgStruct_OF_I.iSid;
			i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_I.iUnitId := -1;
			i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_I.dwAxisProf.31 := 
					KS_CheckStationOnLine_(i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_I.iSid,
											i_iStationNum,
											i_paiStationId_List);
											
			//IF_II
			i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_II.dwAxisProf.0 := i_pstStWrRd_SysCfg^.stStAxisCfgStruct_IF_II.xAxisProf_Enable ;
			i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_II.dwAxisProf.1 := i_pstStWrRd_SysCfg^.stStAxisCfgStruct_IF_II.xAxisProf_MotRev ;
			i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_II.dwAxisProf.2 := i_pstStWrRd_SysCfg^.stStAxisCfgStruct_IF_II.xAxisProf_SamRev ;
			i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_II.iSid := i_pstStWrRd_SysCfg^.stStAxisCfgStruct_IF_II.iSid;
			i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_II.iUnitId := -1;
			i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_II.dwAxisProf.31 := 
					KS_CheckStationOnLine_(i_pstStSysCfgStruct^.stStAxisCfgStruct_IF_II.iSid,
											i_iStationNum,
											i_paiStationId_List);
											
			//OF_II
			i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_II.dwAxisProf.0 := i_pstStWrRd_SysCfg^.stStAxisCfgStruct_OF_II.xAxisProf_Enable ;
			i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_II.dwAxisProf.1 := i_pstStWrRd_SysCfg^.stStAxisCfgStruct_OF_II.xAxisProf_MotRev ;
			i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_II.dwAxisProf.2 := i_pstStWrRd_SysCfg^.stStAxisCfgStruct_OF_II.xAxisProf_SamRev ;
			i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_II.iSid := i_pstStWrRd_SysCfg^.stStAxisCfgStruct_OF_II.iSid;
			i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_II.iUnitId := -1;
			i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_II.dwAxisProf.31 := 
					KS_CheckStationOnLine_(i_pstStSysCfgStruct^.stStAxisCfgStruct_OF_II.iSid,
											i_iStationNum,
											i_paiStationId_List);
		END_IF
	END_IF
ELSE
	;
END_IF