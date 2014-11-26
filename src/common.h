#ifndef _COMMON_H
#define _COMMON_H

#ifdef DEBUG
#define SCRIBELOG(...) NSLog(__VA_ARGS__);
#else
#define SCRIBELOG(...) do {} while (0);
#endif

#endif //_COMMON_H
