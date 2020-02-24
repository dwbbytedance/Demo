//
//  TestHook.h
//  TestHook
//
//  Created by bob on 2020/2/23.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN

BOOL test_swizzle_instance(id obj, SEL originSEL, SEL swizzledSelector, Method swizzledMethod, BOOL mockProtection);
_Nullable Method test_classHasInstanceMethod(Class _Nullable aClass, SEL _Nonnull selector);
_Nullable Method test_classSearchInstanceMethodUntilClass(Class _Nullable aClass, SEL _Nonnull selector, Class _Nullable untilClassExcluded);
NS_ASSUME_NONNULL_END
