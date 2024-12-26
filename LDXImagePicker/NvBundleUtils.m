//
//  NvBundleUtils.m
//  LDXImagePicker
//
//  Created by Mac-Mini on 2024/12/26.
//

#import "NvBundleUtils.h"

@implementation NvBundleUtils

+ (NSBundle *)getResourceBundle {
#ifdef SWIFT_PACKAGE
    return SWIFTPM_MODULE_BUNDLE;
#else
    return [NSBundle bundleForClass:[self class]];
#endif
}

@end
