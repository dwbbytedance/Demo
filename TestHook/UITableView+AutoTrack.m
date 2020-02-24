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

@implementation UITableView (AutoTrack)

- (void)test_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@",self);
    NSLog(@"%@",self.class);
    NSLog(@"%@",object_getClass(self));
    ((void( *)(id, SEL, UITableView *, NSIndexPath *))objc_msgSend)(self, @selector(tableView:didSelectRowAtIndexPath:), tableView, indexPath);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id block = ^(id<AspectInfo> aspectInfo) {
            NSLog(@"instance %@", aspectInfo.instance);
            NSLog(@"arguments %@", aspectInfo.arguments);
            id<NSObject> delegate = aspectInfo.arguments.firstObject;
            BOOL res = [delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)];
            NSLog(@"%@",delegate);
            if (res) {
                NSLog(@"method:%d", test_classSearchInstanceMethodUntilClass(delegate.class, @selector(tableView:didSelectRowAtIndexPath:), [NSObject class]) != NULL);
            }
        };

        [UITableView aspect_hookSelector:@selector(setDelegate:)
                             withOptions:(AspectPositionBefore)
                              usingBlock:block
                                   error:nil];
    });
}

@end
