//
//  PeanutLabsManager.m
//
//  Created by Peanut Labs Inc on 1/10/15.
//  Copyright (c) 2015 PeanutLabs. All rights reserved.
//

#import "PeanutLabsManager.h"
#import "PlRewardsCenterViewController.h"
#import <CommonCrypto/CommonDigest.h>

@implementation PeanutLabsManager

static PeanutLabsManager *_plManagerInstance;


#pragma mark - getInstance
+ (PeanutLabsManager *)getInstance {
    if (!_plManagerInstance) {
        _plManagerInstance = [[PeanutLabsManager alloc] init];
    }
    return _plManagerInstance;
}



- (NSString *) md5:(NSString *) s {
    const char *cStr = [s UTF8String];
    unsigned char res[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), res);
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [result appendFormat:@"%02x", res[i]];
    }
    return [NSString stringWithString:result];
}



/*
 IF you're using the generation client side, you must use transaction sec key to validate reward callbacks since app key is exposed
 */
- (NSString *)generateUserId {
    if (self.endUserId == nil) {
        [NSException raise:@"Invalid End User Id" format:@"The property endUserId must be set to generate full user id."];
    }
    
    NSString *hash = [self md5:[[NSString alloc] initWithFormat:@"%@%d%@", self.endUserId, self.appId, self.appKey]];
    NSString *userGo = [hash substringWithRange:NSMakeRange(0, 10)];
    return [NSString stringWithFormat:@"%@-%d-%@", self.endUserId, self.appId, userGo];
}


- (void)openRewardsCenter {
    if (self.userId == nil) {
        self.userId = [self generateUserId];
    }
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    PlRewardsCenterViewController *rewardsCenter = [[PlRewardsCenterViewController alloc] init];
    [rootViewController presentViewController:rewardsCenter animated:YES completion:nil];
    rewardsCenter.delegate = self;
    
    if (self.delegate) { //make sure its implemented
        if ([(NSObject *)self.delegate respondsToSelector:@selector(peanutLabsManager:rewardsCenterDidOpen:)]) {
            [self.delegate peanutLabsManager:(PeanutLabsManager *)self rewardsCenterDidOpen:self.userId];
        }
    }
}

- (void)closeRewardsCenter {
    if (self.delegate) {
        if ([(NSObject *)self.delegate respondsToSelector:@selector(peanutLabsManager:rewardsCenterDidClose:)]) {
            [self.delegate peanutLabsManager:(PeanutLabsManager *)self rewardsCenterDidClose:self.userId];
        }
    }
}

@end
