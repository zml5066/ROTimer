//
//  ROTimer.h
//  ROTimer
//
//  Created by Robert on 2021/8/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ROTimerQueueType) {
    /// 主队列
    ROTIMER_QUEUE_MAIN_QUEUE = 0,
    /// 全局并发队列
    ROTIMER_QUEUE_GLOBAL_QUEUE= 1,
};


@interface ROTimer : NSObject

/// YES 重复执行，NO 相反
@property (nonatomic, readonly, assign)BOOL repeats;

/// 定时器时间间隔
@property (nonatomic, readonly, assign) NSTimeInterval timeInterval;

/// YES 定时器有效，NO 相反
@property (nonatomic, readonly, assign) BOOL valid;

/// 传递的数据
@property (nullable, readonly, strong) id userInfo;

/// 队列类型
@property (nonatomic, readonly, assign) ROTimerQueueType queueType;

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
                                  queueType:(ROTimerQueueType)queueType;


/// 创建定时器，自带回调函数
/// @param ti 时间间隔
/// @param yesOrNo 是否重复
/// @param queueType 队列类型
/// @param block 回调
+ (ROTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                    repeats:(BOOL)yesOrNo
                                  queueType:(ROTimerQueueType)queueType
                                      block:(void (^)(ROTimer *timer))block;
/// 恢复定时器
- (void)resume;

// 暂停定时器
- (void)suspend;

/// 销毁定时器
- (void)invalidate;
@end

NS_ASSUME_NONNULL_END
