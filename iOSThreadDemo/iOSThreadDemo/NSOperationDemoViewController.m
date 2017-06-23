//
//  NSOperationDemoViewController.m
//  iOSThreadDemo
//
//  Created by lifuheng on 2017/6/21.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import "NSOperationDemoViewController.h"

@interface NSOperationDemoViewController ()

/* 显示下载图片视图 */
@property (weak, nonatomic) IBOutlet UIImageView *downloadImageView;

@end

@implementation NSOperationDemoViewController

#pragma mark - View Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Click
/**
 创建线程
 */
- (IBAction)createThread:(id)sender {
    // 1.NSInvocationOperation 方式
    NSInvocationOperation *operationOne = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(threadRun:) object:@"One"];
    
    // 添加监听
    [operationOne setCompletionBlock:^{
        NSLog(@"OperationOne Finished");
    }];
    
    NSInvocationOperation *operationTwo = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(threadRun:) object:@"Two"];
    
    operationTwo.completionBlock = ^{
        NSLog(@"OperationTwo Finished");
    };
    
    // 2.NSBlockOperation 方式
    NSBlockOperation *operationThree = [NSBlockOperation blockOperationWithBlock:^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"Three - %@ - %ld", [NSThread currentThread], i);
        }
    }];
    
    NSBlockOperation *operationFour = [NSBlockOperation blockOperationWithBlock:^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"Four - %@ - %ld", [NSThread currentThread], i);
        }
    }];
    
    // 追加任务
    // 只要封装的操作数大于 1 ，就会异步执行操作
    [operationFour addExecutionBlock:^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"FourAddOne - %@ - %ld", [NSThread currentThread], i);
        }
    }];
    [operationFour addExecutionBlock:^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"FourAddTwo - %@ - %ld", [NSThread currentThread], i);
        }
    }];
    
    // 默认情况下，调用了 start 方法后并不会开启一条新线程去执行操作，而是在当前线程中同步执行操作
    // 只有将 Operation 放到一个 OperationQueue 中才会异步执行操作
    [operationOne start];
    [operationTwo start];
    [operationThree start];
    [operationFour start];
}

/**
 下载图片
 */
- (IBAction)downloadImage:(id)sender {
    
    // 创建并发队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        // 打印当前线程信息
        [NSThread currentThread].name = @"downloadImage";
        NSLog(@"%@",[NSThread currentThread]);
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://imgtu.5011.net/uploads/content/20170119/9635871484812579.jpg"]];
        UIImage *image = [UIImage imageWithData:imageData];
        
        // 回到主线程刷新 UI
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.downloadImageView.image = image;
        }];
    }];
    
    // 添加操作到并发队列
    [queue addOperation:operation];
    
}

/**
 队列 Demo
 */
- (IBAction)NSOperationQueueDemo:(id)sender {
    // 创建操作数组
    NSMutableArray *operationArray = [NSMutableArray array];
    
    // 创建操作
    NSInvocationOperation *operationOne = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(threadRun:) object:@"One"];
    [operationArray addObject:operationOne];
    
    NSInvocationOperation *operationTwo = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(threadRun:) object:@"Two"];
    [operationArray addObject:operationTwo];
    
    NSBlockOperation *operationThree = [NSBlockOperation blockOperationWithBlock:^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"Three - %@ - %ld", [NSThread currentThread], i);
        }
    }];
    [operationArray addObject:operationThree];
    
    NSBlockOperation *operationFour = [NSBlockOperation blockOperationWithBlock:^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"Four - %@ - %ld", [NSThread currentThread], i);
        }
    }];
    [operationArray addObject:operationFour];
    
    // 追加任务
    [operationFour addExecutionBlock:^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"FourAddOne - %@ - %ld", [NSThread currentThread], i);
        }
    }];
    [operationFour addExecutionBlock:^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"FourAddTwo - %@ - %ld", [NSThread currentThread], i);
        }
    }];
    
    // 创建操作队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 设置队列的最大并发数
    /*
     //maxConcurrentOperationCount:同时只能执行多少个操作
     //maxConcurrentOperationCount >1 并发队列
     //maxConcurrentOperationCount == 1 串行队列(队列里面所有的任务都是串行执行的)
     //NSOperationQueueDefaultMaxConcurrentOperationCount = -1 表示不做限制
     */
    queue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    
    // 添加操作到队列
    [queue addOperations:operationArray waitUntilFinished:NO];
    
    // 暂停,不能暂停当前正处于执行状态的操作的,只能停止后面的操作,可以恢复
    [queue setSuspended:YES];
    
    // 恢复
    [queue setSuspended:NO];
    
    // 取消队列所有操作
//    [queue cancelAllOperations];
}

/**
 依赖 Demo
 */
- (IBAction)dependencyDemo:(id)sender {
    // 创建操作数组
    NSMutableArray *operationArray = [NSMutableArray array];
    
    // 创建操作
    NSInvocationOperation *operationOne = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(threadRun:) object:@"One"];
    [operationArray addObject:operationOne];
    
    NSInvocationOperation *operationTwo = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(threadRun:) object:@"Two"];
    [operationArray addObject:operationTwo];
    
    NSBlockOperation *operationThree = [NSBlockOperation blockOperationWithBlock:^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"Three - %@ - %ld", [NSThread currentThread], i);
        }
    }];
    [operationArray addObject:operationThree];
    
    // 添加依赖
    [operationThree addDependency:operationOne];
    
    // 创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperations:operationArray waitUntilFinished:NO];
}


#pragma mark - Custom
/**
 线程开启后调用此方法

 @param param 参数
 */
- (void)threadRun:(NSString *)param {
    for (NSInteger i = 0; i < 10; i++) {
        NSLog(@"%@ - %@ - %ld", param, [NSThread currentThread], i);
    }
}


@end
