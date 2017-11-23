//
//  AGSDWebImageCache.h
//  AGCache
//
//  Created by 吴书敏 on 2017/11/23.
//  Copyright © 2017年 吴书敏. All rights reserved.
//  此类主要用来解决 同一 url 下, http 缓存问题.
//  缓存图片请求 response 中的  Last-Modified 和 ETag
//  使用方式 1. sd option 选择 refresh.  2. 引入该头文件即可

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * _Nonnull const  K_AGSDWebImageCache_If_Modified_Since;

FOUNDATION_EXPORT NSString * _Nonnull const  k_AGSDWebImageCache_If_None_Match;

@interface AGSDWebImageCache : NSObject

+ (instancetype _Nonnull)shareAGSDWebImageCache;

// 清除缓存

// 

@end
