//
//  TestHook.m
//  TestHook
//
//  Created by bob on 2020/2/23.
//

#import "TestHook.h"
#import <objc/message.h>

#ifndef DEBUG_ELSE
#ifdef DEBUG
#define DEBUG_ELSE else __builtin_trap();
#else
#define DEBUG_ELSE
#endif
#endif

IMP test_swizzle_instance_methodWithBlock(Class c, SEL origSEL, id block) {
    NSCParameterAssert(block);
    Method origMethod = class_getInstanceMethod(c, origSEL);
    NSCParameterAssert(origMethod);
    const char *types = method_getTypeEncoding(origMethod);
    IMP newIMP = imp_implementationWithBlock(block);
    IMP oldIMP = method_getImplementation(origMethod);

    BOOL didAddMethod = class_addMethod(c, origSEL, newIMP, types);
    if (!didAddMethod) {
        /// self has method
        class_replaceMethod(c, origSEL, newIMP, types);
    }

    return oldIMP;
}

static void _test_hookedGetClass(Class class, Class statedClass) {
    NSCParameterAssert(class);
    NSCParameterAssert(statedClass);
    Method method = class_getInstanceMethod(class, @selector(class));
    IMP newIMP = imp_implementationWithBlock(^(id self) {
        return statedClass;
    });
    
    class_replaceMethod(class, @selector(class), newIMP, method_getTypeEncoding(method));
}

//
static NSString *Test_Suffix_ = @"_test_suffix_";
BOOL test_swizzle_instance(id obj, SEL originSEL, SEL swizzledSelector, Method swizzledMethod, BOOL mockProtection)
{
    Class statedCls = [obj class];
    Class baseCls = object_getClass(obj);
//    Method swizzledMethod = class_getInstanceMethod(baseCls, swizzledSelector);
    const char* swizzled_methodEncoding = method_getTypeEncoding(swizzledMethod);
    
    NSString *className = NSStringFromClass(baseCls);
    
    
    // 有前缀 说明已经isa混淆了 直接再搞
    if ([className hasSuffix:Test_Suffix_]) {
        IMP swizzledIMP = method_getImplementation(swizzledMethod);
        return class_addMethod(baseCls, originSEL, swizzledIMP, swizzled_methodEncoding);
    }
    
    if (baseCls != statedCls) {
        IMP swizzledIMP = method_getImplementation(swizzledMethod);
        return class_addMethod(baseCls, originSEL, swizzledIMP, swizzled_methodEncoding);
    }
    const char *subclassName = [className stringByAppendingString:Test_Suffix_].UTF8String;
    Class subclass = objc_getClass(subclassName);
    if (subclass == nil) {
        subclass = objc_allocateClassPair(baseCls, subclassName, 0);
        if (subclass == nil) {
#ifdef DEBUG
            __builtin_trap();
#endif
            return NO;
        }
        _test_hookedGetClass(subclass, statedCls);
        _test_hookedGetClass(object_getClass(subclass), statedCls);
        if(mockProtection) {
            id initialize_block = ^(id thisSelf) {
                /* 啥子都不做就好了 */
                // 防止像 FB 一样的 SB 在 initialize 里面判断 subClass 然后抛 exception [ 烦 ]
            };
            IMP initialize_imp = imp_implementationWithBlock(initialize_block);
            class_addMethod(object_getClass(subclass), @selector(initialize), initialize_imp, "v@:");
        }
        objc_registerClassPair(subclass);
    }
    object_setClass(obj, subclass);
    IMP swizzledIMP = method_getImplementation(swizzledMethod);
    return class_addMethod(subclass, originSEL, swizzledIMP, swizzled_methodEncoding);
}

_Nullable Method test_classHasInstanceMethod(Class _Nullable aClass, SEL _Nonnull selector) {
    NSCParameterAssert(selector != NULL && !class_isMetaClass(aClass));
    if(aClass != nil && selector != NULL && !class_isMetaClass(aClass)) {
        unsigned int length;
        Method *methodList = class_copyMethodList(aClass, &length);
        const char *selectorName = sel_getName(selector);
        for (unsigned int index = 0; index < length; index++) {
            const char *currentName = sel_getName(method_getName(methodList[index]));
            NSLog(@"InstanceMethod %s",currentName);
            if(strcmp(currentName, selectorName) == 0) {
                free(methodList);
                return class_getInstanceMethod(aClass, selector);
            }
        }
        free(methodList);
    }
    return NULL;
}

_Nullable Method test_classSearchInstanceMethodUntilClass(Class _Nullable aClass, SEL _Nonnull selector, Class _Nullable untilClassExcluded) {
    NSCParameterAssert(selector != NULL && !class_isMetaClass(aClass));
    if(aClass != nil && selector != NULL && !class_isMetaClass(aClass)) {
        Class currentClass = aClass;
        
        while(currentClass != NULL && currentClass != untilClassExcluded) {
            NSLog(@"InstanceClass %@",currentClass);
            Method currentMethod = test_classHasInstanceMethod(currentClass, selector);
            if(currentMethod) return currentMethod;
            else currentClass = class_getSuperclass(currentClass);
        }
    }
    return NULL;
}
