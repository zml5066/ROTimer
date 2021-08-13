//
//  SecondViewController.m
//  ROTimer
//
//  Created by Robert on 2021/8/13.
//

#import "SecondViewController.h"
#import "ROTimer.h"

@interface SecondViewController ()

@property (nonatomic, strong) ROTimer *timer1;

@property (nonatomic, assign) NSUInteger value1;

@property (nonatomic, assign) NSUInteger value2;

@property (nonatomic, strong) ROTimer *timer2;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    NSMutableDictionary *aa = [[NSMutableDictionary alloc] init];
    [aa setObject:@"aaaa" forKey:@"key1"];
    [aa setObject:@"bbbb" forKey:@"key2"];
    self.value1 = 0;
    self.value2 = 0;
//    self.timer1 = [ROTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTask:) userInfo:aa repeats:YES];
    __weak typeof(self)weakSelf = self;
    
    self.timer1 = [ROTimer scheduledTimerWithTimeInterval:3 repeats:YES queueType:ROTIMER_QUEUE_MAIN_QUEUE block:^(ROTimer * _Nonnull timer) {
        [weakSelf demo1:timer];
    }];
    self.timer2 =  [ROTimer scheduledTimerWithTimeInterval:3 repeats:YES queueType:ROTIMER_QUEUE_GLOBAL_QUEUE block:^(ROTimer * _Nonnull timer) {
        [weakSelf demo2:timer];
    }];
}


- (IBAction)resumeTimer:(id)sender {
    [self.timer1 resume];
    [self.timer2 resume];
}

- (IBAction)suspendTimer:(id)sender {
    [self.timer1 suspend];
    [self.timer2 suspend];
    
}

- (IBAction)destoryTimer:(id)sender {
    [self.timer1 invalidate];
    [self.timer2 invalidate];
    
}

- (void)timerTask:(ROTimer *)timer {
    [self demo1:timer];
}


- (void)demo1:(ROTimer *)timer {
    self.value1 = self.value1 + 1;
    NSLog(@"定时器运行1:%lu次----%@", (unsigned long)self.value1, timer.userInfo);
}

- (void)demo2:(ROTimer *)timer {
    self.value2 = self.value2 + 1;
    NSLog(@"定时器运行2:%lu次----%@", (unsigned long)self.value2, timer.userInfo);
}

- (void)dealloc {
    
}


@end
