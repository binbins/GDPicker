//
//  UIImage+gd_FlieName.m
//  GDPicker
//
//  Created by binbins on 2019/5/9.
//

#import "UIImage+gd_FlieName.h"
#import <objc/runtime.h>

@implementation UIImage (gd_FlieName)

static NSString *keyName = @"gd_fileName";

- (void)setGd_fileName:(NSString *)gd_fileName {
    
    objc_setAssociatedObject(self, &keyName, gd_fileName, OBJC_ASSOCIATION_COPY);
}

- (NSString *)gd_fileName {
    
    NSString *result = objc_getAssociatedObject(self, &keyName);
    return result? result : @"";
}

@end
