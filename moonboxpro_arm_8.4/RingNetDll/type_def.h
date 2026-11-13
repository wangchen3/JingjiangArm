/*
 * type_def.h
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#ifndef NULL
#define NULL (0)
#endif

#ifndef TYPE_DEF_H_
#define TYPE_DEF_H_

#ifndef		_GOOGOLTECH_RING_NET_DEBUG_
#define		_GOOGOLTECH_RING_NET_DEBUG_   TRUE
#endif

#ifndef WIN32
#define WIN32
#endif

#if defined(WINCE)  || defined (WIN32)
typedef		long								int32;
typedef		long long						int64;

typedef		unsigned long					uint32;
typedef		unsigned long long				uint64;

typedef		uint32							lpoint;
#elif defined(__WIN64)
typedef		long								int32;
typedef		long long						int64;

typedef		unsigned long					uint32;
typedef		unsigned long long				uint64;

typedef		uint64							lpoint;
#elif defined(__LINUX32)
typedef		char							int8;
#elif defined(__LINUX64)

typedef		int								int32;
typedef		long long						int64;

typedef		unsigned int					uint32;
typedef		unsigned long long				uint64;
//------------------------------------------------------------------------------------------------
typedef		uint32							lpoint;
#else

#endif

typedef		char							int8;
typedef		short							int16;

typedef		unsigned char					uint8;
typedef		unsigned short					uint16;
//------------------------------------------------------------------------------------------------
typedef		volatile int8					vint8;
typedef		volatile int16					vint16;
typedef		volatile int32					vint32;
typedef		volatile int64					vint64;

typedef		volatile uint8					vuint8;
typedef		volatile uint16					vuint16;
typedef		volatile uint32					vuint32;
typedef		volatile uint64					vuint64;
//------------------------------------------------------------------------------------------------
typedef		const int8						cint8;
typedef		const int16						cint16;
typedef		const int32						cint32;
typedef		const int64						cint64;

typedef		const uint8						cuint8;
typedef		const uint16					cuint16;
typedef		const uint32					cuint32;
typedef		const uint64					cuint64;

typedef		void*							pvoid;
typedef		lpoint							LPoint;

typedef		uint16							Uint16;
typedef		uint32							Uint32;
typedef		uint8							Uint8;
typedef		void*							HANDLE;
typedef		void*							LPVOID;
#define		TRUE							(1)
#define		FALSE							(0)

#endif /* TYPE_DEF_H_ */
