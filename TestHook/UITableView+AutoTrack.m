//
//  UITableView+AutoTrack.m
//  Applog
//
//  Created by bob on 2019/1/15.
//

#import "UITableView+AutoTrack.h"
#import <objc/runtime.h>
#import <Aspects/Aspects.h>
#import "TestHook.h"

@interface Test : NSObject

@end

@implementation Test

- (id)forwardingTargetForSelector:(SEL)aSelector {
    NSLog(@"forwardingTargetForSelector: %@", NSStringFromSelector(aSelector));
    return [super forwardingTargetForSelector:aSelector];
}

@end

@implementation UITableView (AutoTrack)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id block = ^(id<AspectInfo> aspectInfo) {
            NSLog(@"instance %@", aspectInfo.instance);
            NSLog(@"arguments %@", aspectInfo.arguments);
            id delegate = aspectInfo.arguments.firstObject;
            BOOL res = [delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)];
            NSLog(@"%@",delegate);
            if (res) {
                Method swizzledMethod = class_getInstanceMethod([Test class], @selector(forwardingTargetForSelector:));
                BOOL s = test_swizzle_instance(delegate, @selector(forwardingTargetForSelector:), @selector(forwardingTargetForSelector:), swizzledMethod, YES);
                NSLog(@"test_swizzle_instance %d", s);
                
            }
        };

        [UITableView aspect_hookSelector:@selector(setDelegate:)
                             withOptions:(AspectPositionBefore)
                              usingBlock:block
                                   error:nil];
    });
}

@end
