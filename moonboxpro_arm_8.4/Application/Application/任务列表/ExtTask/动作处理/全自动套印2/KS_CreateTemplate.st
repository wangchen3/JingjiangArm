(*@CES
Name=KS_CreateTemplate
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=90238752-c97b-4d95-b35e-1bfe3f1964c0
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
//构建模版函数
FUNCTION KS_CreateTemplate : BOOL
VAR_INPUT
	i_bySignalType : byte;(*模版类型，1 北人标，2普通标 ，3科赛引导条标*)
	i_iMarkTypeId : INT;(*色标形式pstStGrpParam_Save^.iMarkTypeId*)
	i_iMarkArrangeMode :INT;(*顺逆序输入*)
	i_byColorIdCurrent						: BYTE;(*当前轴色序*)
	i_rGirth_PrnRoller        :REAL;(*版周*)
	//模版构建方法 要求条标直接输入起点mm与终点mm，三角标，先确定直角边的位置，斜边按照三角标高度的一半推
	i_paiModeMidPoint:POINTER TO ARRAY [1..4] OF INT;
	i_pabyModeRadius:POINTER TO ARRAY [1..4] OF BYTE;
	i_parModeStartmm: POINTER TO ARRAY [1..4] OF REAL;
	i_parModeEndmm:POINTER TO ARRAY [1..4] OF REAL;
	i_parSignalMsg:POINTER TO ARRAY [1..15] OF REAL; 
END_VAR
VAR
	iN:INT;//循环计数
	rMaxEndTemp:REAL;//记录一下最大坐标
	arStart1UMM: ARRAY [1..4] OF REAL; //mm单位 规定顺序 旗标 id 1  圆标 id 2  引导标 id 3  三角标 id 4  
	arEnd1UMM: ARRAY [1..4] OF REAL; //mm单位 规定顺序 旗标 id 1  圆标 id 2  引导标 id 3  三角标 id 4 
	arStart2UMM: ARRAY [1..4] OF REAL; //mm单位 规定顺序 旗标 id 1  圆标 id 2  引导标 id 3  三角标 id 4  
	arEnd2UMM:ARRAY [1..4] OF REAL; //mm单位 规定顺序 旗标 id 1  圆标 id 2  引导标 id 3  三角标 id 4 
	arStartMM: ARRAY [1..4] OF REAL; //mm单位 规定顺序 旗标 id 1  圆标 id 2  引导标 id 3  三角标 id 4  
	arEndMM: ARRAY [1..4] OF REAL; //mm单位 规定顺序 旗标 id 1  圆标 id 2  引导标 id 3  三角标 id 4 
	arStartMMTemp: ARRAY [1..4] OF REAL; //mm单位 用来导逆序，规定顺序 旗标 id 1  圆标 id 2  引导标 id 3  三角标 id 4  
	arEndMMTemp: ARRAY [1..4] OF REAL; //mm单位 用来导逆序，规定顺序 旗标 id 1  圆标 id 2  引导标 id 3  三角标 id 4 
	arSignalMsg:ARRAY [1..15] OF REAL; (*1旗标高度
										2 圆标高度
										3 2色引导标高度
										4 三角标高度
										5 1色旗标终点-圆标起点
										6 2色旗标终点-圆标起点
										7 1色圆标终点-引导标起点
										8 2色圆标终点-引导标起点
										9 1色引导标终点-三角标起点
										10 2色引导标终点-三角标起点
										11 2色引导标起点点-3色引导标起点
										12 1色引导标高度
*)
										
END_VAR
		
{IMPLEMENTATION}

IF 	i_parSignalMsg <> 0 AND i_rGirth_PrnRoller <> 0  THEN	
	arSignalMsg:=i_parSignalMsg^;

	CASE i_bySignalType OF 	
	1:	//科赛引导标
		//先构建1色的模版
		arStart1UMM[1]:=  arSignalMsg[1] /2.0;//旗标起点定义旗标高度一半
		arEnd1UMM[1]:= arSignalMsg[1];//旗标终点定义旗标终点
		arStart1UMM[2]:= arEnd1UMM[1] + arSignalMsg[5];//圆标起点为旗标终点+1u5
		arEnd1UMM[2]:= arStart1UMM[2] + arSignalMsg[2];
		arStart1UMM[3]:= arEnd1UMM[2] + arSignalMsg[7];
		arEnd1UMM[3]:= arStart1UMM[3] + arSignalMsg[12];
		//条标
		IF i_iMarkTypeId = MARK_TYPE_LINE THEN
			arStart1UMM[4]:= arEnd1UMM[3] + arSignalMsg[9];
			arEnd1UMM[4]:= arStart1UMM[4] + arSignalMsg[4];
		//直角边在前
		ELSIF i_iMarkTypeId = MARK_TYPE_TRAPE_VFLP OR  i_iMarkTypeId = MARK_TYPE_TRAPE_VFLN THEN
			arStart1UMM[4]:= arEnd1UMM[3] + arSignalMsg[9];
			arEnd1UMM[4]:= arStart1UMM[4] + arSignalMsg[4]/2.0;
		ELSIF  i_iMarkTypeId = MARK_TYPE_TRAPE_VBLP OR  i_iMarkTypeId = MARK_TPYE_TRAPE_VBLN THEN
		//直角边在后
			arStart1UMM[4]:= arEnd1UMM[3] + arSignalMsg[9]+arSignalMsg[4]/2.0;
			arEnd1UMM[4]:=  arEnd1UMM[3] + arSignalMsg[9]+arSignalMsg[4];
		END_IF
		//构建2色的模版
		arStart2UMM[1]:=  arSignalMsg[1] /2.0;//旗标起点定义旗标高度一半
		arEnd2UMM[1]:= arSignalMsg[1];//旗标终点定义旗标终点
		arStart2UMM[2]:= arEnd2UMM[1] + arSignalMsg[6];
		arEnd2UMM[2]:= arStart2UMM[2] + arSignalMsg[2];
		arStart2UMM[3]:= arEnd2UMM[2] + arSignalMsg[8];
		arEnd2UMM[3]:= arStart2UMM[3] + arSignalMsg[3];
		//条标
		IF i_iMarkTypeId = MARK_TYPE_LINE THEN
			arStart2UMM[4]:= arEnd1UMM[3] + arSignalMsg[10];
			arEnd2UMM[4]:= arEnd1UMM[3] + arSignalMsg[10]+(arSignalMsg[4]);
		ELSIF i_iMarkTypeId = MARK_TYPE_TRAPE_VFLP OR  i_iMarkTypeId = MARK_TYPE_TRAPE_VFLN THEN
			arStart2UMM[4]:= arEnd1UMM[3] + arSignalMsg[10];
			arEnd2UMM[4]:= arEnd1UMM[3] + arSignalMsg[10]+(arSignalMsg[4]/2.0);
		ELSIF i_iMarkTypeId = MARK_TYPE_TRAPE_VBLP OR i_iMarkTypeId = MARK_TPYE_TRAPE_VBLN THEN
		//直角边在后
			arStart2UMM[4]:= arEnd1UMM[3] + arSignalMsg[10]+arSignalMsg[4]/2.0;
			arEnd2UMM[4]:=  arEnd1UMM[3] + arSignalMsg[10]+arSignalMsg[4];
		END_IF	
		IF i_byColorIdCurrent > 0 THEN
			//根据色序选择模版
			CASE i_byColorIdCurrent OF 
				1: 
					FOR iN := 1 TO 4 BY 1 DO
						arStartMM[iN]:=arStart1UMM[iN];
						arEndMM[iN]:=arEnd1UMM[iN];
					END_FOR
				2:
					FOR iN := 1 TO 4 BY 1 DO
						arStartMM[iN]:=arStart2UMM[iN];
						arEndMM[iN]:=arEnd2UMM[iN];
					END_FOR
				ELSE
					arStartMM[1]:=arStart1UMM[1];
					arEndMM[1]:=arEnd1UMM[1];
					arStartMM[2]:=arStart1UMM[2]+(i_byColorIdCurrent-1)*(arSignalMsg[6]-arSignalMsg[5]);
					arEndMM[2]:=arEnd1UMM[2]+(i_byColorIdCurrent-1)*(arSignalMsg[6]-arSignalMsg[5]);
					arStartMM[3]:=arStart1UMM[3]+(i_byColorIdCurrent-1)*(arStart2UMM[3]-arStart1UMM[3]);
					arEndMM[3]:=arEnd1UMM[3]+(i_byColorIdCurrent-1)*(arEnd2UMM[3]-arEnd1UMM[3]);
					arStartMM[4]:=arStart1UMM[4]+(i_byColorIdCurrent-1)*(arStart2UMM[4]-arStart1UMM[4]);
					arEndMM[4]:=arEnd1UMM[4]+(i_byColorIdCurrent-1)*(arEnd2UMM[4]-arEnd1UMM[4]);
			END_CASE
		ELSE
			FOR iN := 1 TO 4 BY 1 DO
				arStartMM[iN]:=0;
				arEndMM[iN]:=0;
			END_FOR	
		END_IF
	2: //普通标
		//关于建立没有引导,只有旗标，圆标，三角标，标建立模版，要求 3,7,8,11,12均为0，9,10填写圆标到三角标的距离，模版建立方法，虚拟一个引导标，将引导标的起点和终点与三角标相同
		//先构建1色的模版
		arStart1UMM[1]:=  arSignalMsg[1] /2.0;//旗标起点定义旗标高度一半
		arEnd1UMM[1]:= arSignalMsg[1];//旗标终点定义旗标终点
		arStart1UMM[2]:= arEnd1UMM[1] + arSignalMsg[5];//圆标起点为旗标终点+1u5
		arEnd1UMM[2]:= arStart1UMM[2] + arSignalMsg[2];
		
		//条标
		IF i_iMarkTypeId = MARK_TYPE_LINE THEN
			arStart1UMM[4]:= arEnd1UMM[2] + arSignalMsg[9];
			arEnd1UMM[4]:= arStart1UMM[4] + arSignalMsg[4];
			arStart1UMM[3]:= arStart1UMM[4];
			arEnd1UMM[3]:= arEnd1UMM[4];
		//直角边在前
		ELSIF i_iMarkTypeId = MARK_TYPE_TRAPE_VFLP OR  i_iMarkTypeId = MARK_TYPE_TRAPE_VFLN THEN	
			arStart1UMM[4]:= arEnd1UMM[2] + arSignalMsg[9];
			arEnd1UMM[4]:= arStart1UMM[4] + arSignalMsg[4]/2.0;
			arStart1UMM[3]:= arStart1UMM[4];
			arEnd1UMM[3]:= arEnd1UMM[4];
		ELSIF  i_iMarkTypeId = MARK_TYPE_TRAPE_VBLP OR  i_iMarkTypeId = MARK_TPYE_TRAPE_VBLN THEN
		//直角边在后
			arStart1UMM[4]:= arEnd1UMM[2] + arSignalMsg[9]+arSignalMsg[4]/2.0;
			arEnd1UMM[4]:=  arEnd1UMM[2] + arSignalMsg[9]+arSignalMsg[4];
			arStart1UMM[3]:= arStart1UMM[4];
			arEnd1UMM[3]:= arEnd1UMM[4];
		END_IF
		//构建2色的模版
		arStart2UMM[1]:=  arSignalMsg[1] /2.0;//旗标起点定义旗标高度一半
		arEnd2UMM[1]:= arSignalMsg[1];//旗标终点定义旗标终点
		arStart2UMM[2]:= arEnd2UMM[1] + arSignalMsg[6];
		arEnd2UMM[2]:= arStart2UMM[2] + arSignalMsg[2];
		//条标
		IF i_iMarkTypeId = MARK_TYPE_LINE THEN
			arStart2UMM[4]:= arEnd2UMM[2] + arSignalMsg[10];
			arEnd2UMM[4]:= arStart2UMM[4] + arSignalMsg[4];
			arStart2UMM[3]:=arStart2UMM[4];
			arEnd2UMM[3]:= arEnd2UMM[4];
		//直角边在前
		ELSIF i_iMarkTypeId = MARK_TYPE_TRAPE_VFLP OR  i_iMarkTypeId = MARK_TYPE_TRAPE_VFLN THEN
			arStart2UMM[4]:= arEnd2UMM[2] + arSignalMsg[10];
			arEnd2UMM[4]:= arStart2UMM[4] + arSignalMsg[4]/2.0;
			arStart2UMM[3]:=arStart2UMM[4];
			arEnd2UMM[3]:= arEnd2UMM[4];
		ELSIF i_iMarkTypeId = MARK_TYPE_TRAPE_VBLP OR i_iMarkTypeId = MARK_TPYE_TRAPE_VBLN THEN
		//直角边在后
			arStart2UMM[4]:= arEnd2UMM[2] + arSignalMsg[10]+arSignalMsg[4]/2.0;
			arEnd2UMM[4]:=  arEnd2UMM[2] + arSignalMsg[10]+arSignalMsg[4];
			arStart2UMM[3]:=arStart2UMM[4];
			arEnd2UMM[3]:= arEnd2UMM[4];
		END_IF	
		IF i_byColorIdCurrent > 0 THEN
			//根据色序选择模版
			CASE i_byColorIdCurrent OF 
				1: 
					FOR iN := 1 TO 4 BY 1 DO
						arStartMM[iN]:=arStart1UMM[iN];
						arEndMM[iN]:=arEnd1UMM[iN];
					END_FOR
				2:
					FOR iN := 1 TO 4 BY 1 DO
						arStartMM[iN]:=arStart2UMM[iN];
						arEndMM[iN]:=arEnd2UMM[iN];
					END_FOR
				ELSE
					arStartMM[1]:=arStart1UMM[1];
					arEndMM[1]:=arEnd1UMM[1];
					arStartMM[2]:=arStart1UMM[2]+(i_byColorIdCurrent-1)*(arSignalMsg[6]-arSignalMsg[5]);
					arEndMM[2]:=arEnd1UMM[2]+(i_byColorIdCurrent-1)*(arSignalMsg[6]-arSignalMsg[5]);
					arStartMM[4]:=arStart1UMM[4]+(i_byColorIdCurrent-1)*(arStart2UMM[4]-arStart1UMM[4]);
					arEndMM[4]:=arEnd1UMM[4]+(i_byColorIdCurrent-1)*(arEnd2UMM[4]-arEnd1UMM[4]);
					arStartMM[3]:= arStartMM[4];
					arEndMM[3]:= arEndMM[4];		
			END_CASE
		ELSE
			FOR iN := 1 TO 4 BY 1 DO
				arStartMM[iN]:=0;
				arEndMM[iN]:=0;
			END_FOR	
		END_IF		
	3: // 3 北人标
		//先构建1色的模版
		arStart1UMM[1]:=  arSignalMsg[1] /2.0;//旗标起点定义旗标高度一半
		arEnd1UMM[1]:= arSignalMsg[1];//旗标终点定义旗标终点
		arStart1UMM[2]:= arEnd1UMM[1] + arSignalMsg[5];//圆标起点为旗标终点+1u5
		arEnd1UMM[2]:= arStart1UMM[2] + arSignalMsg[2];
		arStart1UMM[3]:= arEnd1UMM[2] + arSignalMsg[7];
		arEnd1UMM[3]:= arStart1UMM[3] + arSignalMsg[12];
		//条标
		IF i_iMarkTypeId = MARK_TYPE_LINE THEN
			arStart1UMM[4]:= arEnd1UMM[3] + arSignalMsg[9];
			arEnd1UMM[4]:= arStart1UMM[4] + arSignalMsg[4];
		//直角边在前
		ELSIF i_iMarkTypeId = MARK_TYPE_TRAPE_VFLP OR  i_iMarkTypeId = MARK_TYPE_TRAPE_VFLN THEN
			arStart1UMM[4]:= arEnd1UMM[3] + arSignalMsg[9];
			arEnd1UMM[4]:= arStart1UMM[4] + arSignalMsg[4]/2.0;
		ELSIF  i_iMarkTypeId = MARK_TYPE_TRAPE_VBLP OR  i_iMarkTypeId = MARK_TPYE_TRAPE_VBLN THEN
		//直角边在后
			arStart1UMM[4]:= arEnd1UMM[3] + arSignalMsg[9]+arSignalMsg[4]/2.0;
			arEnd1UMM[4]:=  arEnd1UMM[3] + arSignalMsg[9]+arSignalMsg[4];
		END_IF
		//构建2色的模版
		arStart2UMM[1]:=  arSignalMsg[1] /2.0;//旗标起点定义旗标高度一半
		arEnd2UMM[1]:= arSignalMsg[1];//旗标终点定义旗标终点
		arStart2UMM[2]:= arEnd2UMM[1] + arSignalMsg[6];
		arEnd2UMM[2]:= arStart2UMM[2] + arSignalMsg[2];
		arStart2UMM[3]:= arEnd2UMM[2] + arSignalMsg[8];
		arEnd2UMM[3]:= arStart2UMM[3] + arSignalMsg[3];
		//条标
		IF i_iMarkTypeId = MARK_TYPE_LINE THEN
			arStart2UMM[4]:= arEnd1UMM[3] + arSignalMsg[10];
			arEnd2UMM[4]:= arStart1UMM[4] + arSignalMsg[4];
		//直角边在前
		ELSIF i_iMarkTypeId = MARK_TYPE_TRAPE_VFLP OR  i_iMarkTypeId = MARK_TYPE_TRAPE_VFLN THEN
			arStart2UMM[4]:= arEnd2UMM[3] + arSignalMsg[10];
			arEnd2UMM[4]:= arStart2UMM[4] + arSignalMsg[4]/2.0;
		ELSIF i_iMarkTypeId = MARK_TYPE_TRAPE_VBLP OR i_iMarkTypeId = MARK_TPYE_TRAPE_VBLN THEN
		//直角边在后
			arStart2UMM[4]:= arEnd1UMM[3] + arSignalMsg[10]+arSignalMsg[4]/2.0;
			arEnd2UMM[4]:=  arEnd1UMM[3] + arSignalMsg[10]+arSignalMsg[4];
		END_IF	
		IF i_byColorIdCurrent > 0 THEN
			//根据色序选择模版
			CASE i_byColorIdCurrent OF 
				1: 
					FOR iN := 1 TO 4 BY 1 DO
						arStartMM[iN]:=arStart1UMM[iN];
						arEndMM[iN]:=arEnd1UMM[iN];
					END_FOR
				2:
					FOR iN := 1 TO 4 BY 1 DO
						arStartMM[iN]:=arStart2UMM[iN];
						arEndMM[iN]:=arEnd2UMM[iN];
					END_FOR
				ELSE
					arStartMM[1]:=arStart1UMM[1];
					arEndMM[1]:=arEnd1UMM[1];
					arStartMM[2]:=arStart1UMM[2]+(i_byColorIdCurrent-1)*(arSignalMsg[6]-arSignalMsg[5]);
					arEndMM[2]:=arEnd1UMM[2]+(i_byColorIdCurrent-1)*(arSignalMsg[6]-arSignalMsg[5]);
					arStartMM[3]:=arStart2UMM[3]-(i_byColorIdCurrent-2)*arSignalMsg[11];
					arEndMM[3]:=arEnd2UMM[3]-(i_byColorIdCurrent-2)*arSignalMsg[11];
					arStartMM[4]:=arStart2UMM[4]+(i_byColorIdCurrent-2)*(arStart2UMM[4]-arStart1UMM[4]);
					arEndMM[4]:=arEnd2UMM[4]+(i_byColorIdCurrent-2)*(arEnd2UMM[4]-arEnd1UMM[4]);
			END_CASE
		ELSE
			FOR iN := 1 TO 4 BY 1 DO
				arStartMM[iN]:=0;
				arEndMM[iN]:=0;
			END_FOR	
		END_IF
	END_CASE
	//根据顺序生成逆序模版
	IF i_iMarkArrangeMode = MARK_ARRANGE_VFOR THEN
		;//不做处理，因为本身构建是顺序的
	ELSIF i_iMarkArrangeMode = MARK_ARRANGE_VREV THEN
		FOR iN := 1 TO 4 BY 1 DO //先记录一下顺序模版
			arStartMMTemp[iN]:=arStartMM[iN];
			arEndMMTemp[iN]:=arEndMM[iN];
		END_FOR	
		rMaxEndTemp:= arEndMM[4];
		FOR iN := 1 TO 4 BY 1 DO //导出逆序
			arStartMM[iN]:=rMaxEndTemp-arEndMMTemp[4-iN+1];
			arEndMM[iN]:=rMaxEndTemp-arStartMMTemp[4-iN+1];
		END_FOR			
	END_IF	
	FOR iN := 1 TO 4 BY 1 DO  //传出中心半径
		i_paiModeMidPoint^[iN]:=REAL_TO_INT((arEndMM[iN]+arStartMM[iN])/2.0/i_rGirth_PrnRoller*MAX_ROUNDSAMPLE_NUM);
		i_pabyModeRadius^[iN]:=REAL_TO_BYTE((arEndMM[iN]-arStartMM[iN])/2.0/i_rGirth_PrnRoller*MAX_ROUNDSAMPLE_NUM);
	END_FOR
	i_parModeStartmm^:=	arStartMM;
	i_parModeEndmm^:=arEndMM;
END_IF