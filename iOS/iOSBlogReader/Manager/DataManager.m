//
//  DataStorage.m
//  iOSBlogReader
//
//  Created by everettjf on 16/4/9.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import "DataManager.h"
#import "AppUtil.h"
#import "DomainModel.h"
#import "AspectModel.h"
#import "FeedModel.h"
#import "FeedItemModel.h"


@interface DataManager ()
@end

@implementation DataManager

+ (DataManager *)manager{
    static DataManager *o;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        o = [DataManager new];
    });
    return o;
}

- (NSURL*)_dataPath{
    return [[AppUtil documentsDirectory] URLByAppendingPathComponent:@"blogdata.db"];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"data path = %@", [self _dataPath]);
#ifdef DEBUG
//        [[NSFileManager defaultManager]removeItemAtURL:[self _dataPath] error:nil];
#endif
        
        self.managedObjectContext = [NSManagedObject mcd_init:@"BlogModel" storePath:[self _dataPath]];
    }
    return self;
}

- (FeedModel *)findFeed:(NSUInteger)oid{
    return (id)[FeedModel mcd_find:@"oid" value:@(oid)];
}

- (void)findOrCreateFeed:(NSUInteger)oid callback:(void (^)(FeedModel * _Nullable))callback{
    [FeedModel mcd_findOrCreate:@"oid" value:@(oid) callback:^(NSManagedObject *m) {
        if(!m){
            callback(nil);
            return;
        }
        
        callback((id)m);
    }];
}

- (NSArray<FeedModel *> *)findAllFeed{
    return [FeedModel mcd_findAll];
}

- (NSArray<FeedModel *> *)findAllFeed:(NSUInteger)offset limit:(NSUInteger)limit{
    return [FeedModel mcd_findAll:offset limit:limit sort:@{
                                                            @"oid":@(NO)
                                                            }];
}

- (void)findOrCreateFeedItem:(NSString *)identifier callback:(void (^)(FeedItemModel * _Nullable))callback{
    [FeedItemModel mcd_findOrCreate:@"identifier" value:identifier callback:^(NSManagedObject *m) {
        if(!m){
            callback(nil);
            return;
        }
        callback((id)m);
    }];
}

- (FeedItemModel *)findFeedItem:(NSString *)identifier{
    return (id)[FeedItemModel mcd_find:@"identifier" value:identifier];
}

- (NSArray<FeedItemModel *> *)findAllFeedItem:(NSUInteger)offset limit:(NSUInteger)limit filter:(NSNumber *)filterFeedOid{
    NSPredicate *predicate;
    if(filterFeedOid){
        FeedModel *feed = [self findFeed:filterFeedOid.unsignedIntegerValue];
        if(!feed)return nil;
        
        predicate = [NSPredicate predicateWithFormat:@"feed = %@", feed];
    }
    
    return (id)[FeedItemModel mcd_findAll:offset
                                    limit:limit
                                     sort:@{
                                            @"date":@(NO)
                                            }
                                predicate:predicate];
}

- (NSUInteger)countFeed{
    return [FeedModel mcd_countAll];
}

- (NSUInteger)countFeedItem:(NSNumber *)filterFeedOid{
    NSPredicate *predicate;
    if(filterFeedOid){
        FeedModel *feed = [self findFeed:filterFeedOid.unsignedIntegerValue];
        if(!feed)return 0;
        
        predicate = [NSPredicate predicateWithFormat:@"feed = %@", feed];
    }
    
    return [FeedItemModel mcd_count:predicate];
}


@end
