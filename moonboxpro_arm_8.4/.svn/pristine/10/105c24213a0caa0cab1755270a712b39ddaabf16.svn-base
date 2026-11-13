#ifndef KS_FB_PROSAMPLE_V2_H_
#define KS_FB_PROSAMPLE_V2_H_

#include "base.h"
#include "comm.h"

#ifdef __cplusplus
extern "C" {
#endif

void KS_FB_ProSample_V2(
    StPara_PduBroadcastUp* i_pstStPara_PduBroadcastUp,
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
    BYTE *i_pbyRSdata1,
    BYTE *i_pbyRSdata2,
    BYTE i_xFlag_SingleMode
);

#ifdef __cplusplus
}
#endif

#endif
