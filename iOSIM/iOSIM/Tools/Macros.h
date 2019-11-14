//
//  Macros.h
//  iOSIM
//
//  Created by CYKJ on 2019/11/12.
//  Copyright © 2019年 D. All rights reserved.
//

#ifndef Macros_h
#define Macros_h

#define WEAK_SELF    typeof(self) __weak weakSelf = self
#define STRONG_SELF  typeof(weakSelf) __strong strongSelf = weakSelf

#define SCREEN_WIDTH   ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT  ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_RATIO   (SCREEN_WIDTH / 375.0)

#undef UIColorFromRGBA_0x
#define UIColorFromRGBA_0x(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]
#define UIColorFromRGBA(R, G, B, A)   [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define kNormalTextColor   UIColorFromRGBA(119, 119, 119, 1.0)
#define kSelectTextColor   UIColorFromRGBA( 83, 178, 232, 1.0)



#define Log_ERROR_AND_RETURN(expression, log)\
if (expression) {\
NSLog(@"%@", log);\
return;\
}



#undef  DEF_SINGLETON
#define DEF_SINGLETON \
- (instancetype)sharedInstance; \
+ (instancetype)sharedInstance;

#undef  IMP_SINGLETON
#define IMP_SINGLETON \
- (instancetype)sharedInstance \
{ \
    return [[self class] sharedInstance]; \
} \
+ (instancetype)sharedInstance \
{ \
    static dispatch_once_t once; \
    static id __singleton__; \
    dispatch_once( &once, ^{ __singleton__ = [[self alloc] init]; } ); \
    return __singleton__; \
}

#endif /* Macros_h */
