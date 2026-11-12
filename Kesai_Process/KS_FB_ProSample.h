/*
 * KS_FB_ProSample.h
 *
 *  Created on: Jul 30, 2024
 *      Author: 17500
 */

#ifndef KS_FB_PROSAMPLE_H_
#define KS_FB_PROSAMPLE_H_

#include "base.h"
#include "comm.h"

void KS_FB_ProSample(StPara_PduBroadcastUp* i_pstStPara_PduBroadcastUp,
			WORD* i_puiFineData1,
			WORD* i_puiFineData2,
			INT i_iFineSampleFlag,
			StAxisParam* i_pstStAxisParam,
			StGrpParam* i_pstStGrpParam,
			REAL i_alrBase[2],
			INT o_aiError_V[40],
			INT o_aiError_H[40],
			INT aiFineSample_Data[9],
			BYTE* i_pxOK_PosConfirmed,
			BYTE i_xOK_FromMaster,
			REAL o_alrThreshold[2],
			REAL o_alrBase_Fs[2],
			BYTE *i_pbyRSdata1,//2022.5.17.152932
			BYTE *i_pbyRSdata2,
			BYTE i_xFlag_SingleMode );

#endif /* KS_FB_PROSAMPLE_H_ */
