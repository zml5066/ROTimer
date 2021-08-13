//
//  ROTimer.m
//  ROTimer
//
//  Created by Robert on 2021/8/13.
//

#import "ROTimer.h"

#define ROLock(...) \
   dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER); \
   __VA_ARGS__; \
   dispatch_semaphore_signal(_semaphore);

@interface ROTimer() {
    
    /// YES 重复执行，NO 相反
    BOOL _repeats;

    /// 定时器时间间隔
    NSTimeInterval _timeInterval;
    
    /// YES 定时器有效，NO 相反
    BOOL _valid;
    
    /// 传递的数据
    id _userInfo;
    
    /// 接收者 用__weak主要防止循环引用
    __weak id _target;
    
    /// 执行任务的方法
    SEL _selector;
    
    /// source定时器
    dispatch_source_t _sourceTimer;
    
    /// 信号量
    dispatch_semaphore_t _semaphore;
    
    /// 标志定时器是否正在运行，YES是，NO 相反
    BOOL _running;
    
    /// 队列
    dispatch_queue_t _queue;
    
    // 队列类型
    ROTimerQueueType _queueType;
}
@end

@implementation ROTimer

#pragma mark 公开方法
/// 创建定时器
/// @param ti 时间间隔
/// @param aTarget 接收
/// @param aSelector 方法
/// @param userInfo 数据
/// @param yesOrNo 是否重复
/// @param queueType 队列类型
+ (ROTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                     target:(id)aTarget
                                   selector:(SEL)aSelector
                                   userInfo:(nullable id)userInfo
                                    repeats:(BOOL)yesOrNo
                                  queueType:(ROTimerQueueType)queueType {
    return [[ROTimer alloc] initTimerWithDelayTime:0 timeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo queueType:(ROTimerQueueType)queueType];
}

/// 创建定时器，自带回调函数
/// @param ti 时间间隔
/// @param yesOrNo 是否重复
/// @param queueType 队列类型
/// @param block 回调
+ (ROTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                    repeats:(BOOL)yesOrNo
                                  queueType:(ROTimerQueueType)queueType
                                      block:(void (^)(ROTimer *timer))block {
    return [[ROTimer alloc] initTimerWithDelayTime:0 timeInterval:ti target:self selector:@selector(execTaskWithTimer:) userInfo:[block copy] repeats:yesOrNo
                                         queueType:(ROTimerQueueType)queueType];
}

/// 恢复定时器
- (void)resume {
    if (_running) return;
    if (_sourceTimer) {
        dispatch_resume(_sourceTimer);
        _running = YES;
    }
}

// 暂停定时器
- (void)suspend {
    if (!_running) return;
    if (_sourceTimer) {
        dispatch_suspend(_sourceTimer);
        _running = NO;
    }
}

/// 销毁定时器
- (void)invalidate {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    if (_valid) {
        if (!_running){
            dispatch_resume(_sourceTimer);
        }
        dispatch_source_cancel(_sourceTimer);
        _sourceTimer = nil;
        _target = nil;
        _userInfo = nil;
        _valid = NO;
    }
    dispatch_semaphore_signal(_semaphore);
}



#pragma mark 私有方法
- (instancetype)initTimerWithDelayTime:(NSTimeInterval)delayTime
                          timeInterval:(NSTimeInterval)ti
                                target:(id)aTarget
                              selector:(SEL)aSelector
                              userInfo:(nullable id)userInfo
                               repeats:(BOOL)yesOrNo
                             queueType:(ROTimerQueueType)queueType {
    self = [super init];
    if (self) {
        _queueType = queueType;
        _valid = YES;
        _timeInterval = ti;
        _target = aTarget;
        _selector = aSelector;
        _userInfo = userInfo;
        _repeats = yesOrNo;
        switch (_queueType) {
            case ROTIMER_QUEUE_MAIN_QUEUE:
                _queue = dispatch_get_main_queue();
                break;
            case ROTIMER_QUEUE_GLOBAL_QUEUE:
                _queue = dispatch_get_global_queue(0, 0);
                break;
            default:
                break;
        }
        _semaphore = dispatch_semaphore_create(1);
        __weak typeof(self)weakSelf = self;
        _sourceTimer =  dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
        dispatch_source_set_timer(_sourceTimer, dispatch_time(DISPATCH_TIME_NOW, delayTime * NSEC_PER_SEC), _timeInterval * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(_sourceTimer, ^{
            [weakSelf fire];
        });
    }
    return self;
}


/// 启动
- (void)fire {
    if (!_valid) return;
    ROLock(id target = _target;)
    if (!target) {
        [self invalidate];
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:_selector withObject:self];
#pragma clang diagnostic pop
        if (!_repeats) {
            [self invalidate];
        }
    }
}

/// 定时器任务回调
/// @param timer 定时器
+ (void)execTaskWithTimer:(ROTimer *)timer {
    dispatch_async(dispatch_get_main_queue(), ^{
        void (^block)(ROTimer *) = [timer userInfo];
        if (block) block(timer);
   });

}

- (id)userInfo {
    ROLock(id ui = _userInfo) return ui;
}

- (BOOL)repeats {
    ROLock(BOOL re = _repeats) return re;
}

- (NSTimeInterval)timeInterval {
    ROLock(NSTimeInterval ti = _timeInterval) return ti;
}

- (BOOL)isValid {
    ROLock(BOOL va = _valid) return va;
}


- (void)dealloc {
    [self invalidate];
}

@end
