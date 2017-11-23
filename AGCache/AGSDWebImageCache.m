//
//  AGSDWebImageCache.m
//  AGCache
//
//  Created by 吴书敏 on 2017/11/23.
//  Copyright © 2017年 吴书敏. All rights reserved.
//

#import "AGSDWebImageCache.h"
#import <SDWebImageDownloaderOperation.h>
#import <SDWebImageDownloader.h>

NSString *const K_AGSDWebImageCache_If_Modified_Since = @"If-Modified-Since";

NSString *const k_AGSDWebImageCache_If_None_Match = @"If-None-Match";

static NSString *const k_Last_Modified = @"Last-Modified";

static NSString *const k_ETag = @"ETag";

static NSString *const k_PlistName = @"AGSDWebImageCachePlist.plist";
static NSString *const k_AGSdWebImageCache = @"AGSDWebImageCache";


@interface AGSDWebImageCache()

@property (nonatomic, strong, nonnull) NSFileManager *fileManager;
@property (nonatomic, strong, nonnull) NSString *diskCachePath; // cache 文件路径
@property (nonatomic, strong, nonnull) NSString *plistPath; // plist 文件路径

@end

@implementation AGSDWebImageCache

+ (void)load {
    [self shareAGSDWebImageCache];
}

+ (instancetype)shareAGSDWebImageCache {
    static id once;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        once = [[self alloc] init];
    });
    return once;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self config];
        [self addSDWebImageNotification];
        [self configSDWebImageDownloadFilter];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)config {
    self.fileManager = [NSFileManager defaultManager];
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    self.diskCachePath = [cachePath stringByAppendingPathComponent:k_AGSdWebImageCache];
    
    if (![self.fileManager fileExistsAtPath:self.diskCachePath]) {
        [self.fileManager createDirectoryAtPath:self.diskCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    self.plistPath = [self.diskCachePath stringByAppendingPathComponent:k_PlistName];
    
    if (![self.fileManager fileExistsAtPath:self.plistPath]) {
        NSMutableDictionary *root = [NSMutableDictionary dictionary];
        [root writeToFile:self.plistPath atomically:YES];
    }
}

- (void)addSDWebImageNotification {
    // 收到服务器响应
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveResponseNotification:) name:SDWebImageDownloadReceiveResponseNotification object:nil];
}
// 添加 request 请求头
- (void)configSDWebImageDownloadFilter {
    // 每次请求时,添加请求头
    SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
    
    imageDownloader.headersFilter = ^SDHTTPHeadersDictionary * _Nullable(NSURL * _Nullable url, SDHTTPHeadersDictionary * _Nullable headers) {
        NSMutableDictionary *mutableDic = [headers mutableCopy];
        NSString *lastModified = [self getLastModifiedWithURLKey:url.absoluteString] == nil ? @"" : [self getLastModifiedWithURLKey:url.absoluteString];
        NSString *eTag = [self getEtagWithURLKey:url.absoluteString] == nil ? @"" : [self getEtagWithURLKey:url.absoluteString];
        [mutableDic setObject:lastModified forKey:K_AGSDWebImageCache_If_Modified_Since];
        [mutableDic setObject:eTag forKey:k_AGSDWebImageCache_If_None_Match];
        NSLog(@"----:%@ ---- :%@", lastModified, eTag);
        return mutableDic;
    };
}

#pragma mark - NSNotification

- (void)receiveResponseNotification:(NSNotification *)noti {
    // 存储 response 中的 etag  和  last_modified
    SDWebImageDownloaderOperation *operation = (SDWebImageDownloaderOperation *)noti.object;
    
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)operation.response;
    
    NSString *urlKey = operation.request.URL.absoluteString;
    NSString *lastModified = [response.allHeaderFields valueForKey:k_Last_Modified];
    NSString *etag = [response.allHeaderFields valueForKey:k_ETag];
    
    NSLog(@"----:%@ ---- :%@ --- :%ld", lastModified, etag, response.statusCode);
    [self cacheURLKey:urlKey lastModified:lastModified etag:etag];
    
}

#pragma mark - Last-Modified, Etag

- (void)cacheURLKey:(NSString *)urlKey
       lastModified:(NSString *)lastModified
               etag:(NSString *)etag {
    @synchronized (self) {
        // 读取
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:self.plistPath];
        
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:(lastModified == nil) ? @"" : lastModified forKey:k_Last_Modified];
        [info setObject:(etag == nil) ? @"" : etag forKey:k_ETag];
        [dic setObject:info forKey:urlKey];
        // 写入
        [dic writeToFile:self.plistPath atomically:YES];
    }
}

- (NSString *)getLastModifiedWithURLKey:(NSString *)urlKey {
    @synchronized (self) {
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:self.plistPath];
        NSDictionary *info = [dic objectForKey:urlKey];
        NSString *last_modified = info[k_Last_Modified];
        return last_modified == nil ? @"" : last_modified;
    }

}

- (NSString *)getEtagWithURLKey:(NSString *)urlkey {
    @synchronized (self) {
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:self.plistPath];
        NSDictionary *info = [dic objectForKey:urlkey];
        NSString *etag = info[k_ETag];
        return etag == nil ? @"" : etag;
    }
}

@end
