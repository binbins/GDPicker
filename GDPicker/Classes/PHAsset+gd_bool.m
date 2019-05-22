//
//  PHAsset+gd_bool.m
//  GDPicker
//
//  Created by binbins on 2019/5/22.
//

#import "PHAsset+gd_bool.h"
#import <objc/runtime.h>

@implementation PHAsset (gd_bool)

static NSString *keyName = @"gd_onLoading";

- (void)setGd_onLoading:(BOOL)gd_onLoading {
    
    objc_setAssociatedObject(self, &keyName, @(gd_onLoading), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)gd_onLoading {
    return [objc_getAssociatedObject(self, &keyName) boolValue];
}



@end
