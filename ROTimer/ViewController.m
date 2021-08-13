//
//  ViewController.m
//  ROTimer
//
//  Created by Robert on 2021/8/13.
//

#import "ViewController.h"
#import "SecondViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


- (IBAction)startTimer:(id)sender {
    SecondViewController *controller = [[SecondViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}


@end
