#ifndef __KS_DEFINE_H
#define __KS_DEFINE_H
#include "stdint.h"

#ifndef NULL
#define NULL	0
#endif

#ifndef TRUE
#define TRUE	1
#endif

#ifndef FALSE
#define FALSE	0
#endif

#ifndef ABS
#define ABS(x) ((x)>=0?(x):-(x))
#endif

#ifndef MAX
#define MAX(X,Y) (X>Y ? X:Y)//取最大值
#endif

#ifndef MIN
#define MIN(X,Y) (X>Y ? Y:X)//取最小值
#endif

#define KS_GET_ARRLENTH(arr) (sizeof(arr)/sizeof(arr[0]))


#endif