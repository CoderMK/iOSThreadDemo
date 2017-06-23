//
//  GCDDemoViewController.m
//  iOSThreadDemo
//
//  Created by lifuheng on 2017/6/15.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import "GCDDemoViewController.h"

@interface GCDDemoViewController ()

/* 显示下载图片视图 */
@property (weak, nonatomic) IBOutlet UIImageView *downloadImageView;

@end

@implementation GCDDemoViewController

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
 串行队列同步执行
 
 不开新线程，任务串行执行
 */
- (IBAction)syncAndSerial:(id)sender {
    // 创建串行队列
    /*
     dispatch_queue_create(const char * _Nullable label, dispatch_queue_attr_t  _Nullable attr)
     label : 队列名称
     attr : 队列类型（DISPATCH_QUEUE_SERIAL == NULL : 串行队列，DISPATCH_QUEUE_CONCURRENT : 并发队列）
     */
    dispatch_queue_t queue = dispatch_queue_create("leon", NULL);
    
    /**
     同步执行函数（异步执行参数类似）
     
     @param queue 队列
     @param block 执行任务
     */
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"One - %@ - %ld", [NSThread currentThread], i);
        }
    });
    
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"Two - %@ - %ld", [NSThread currentThread], i);
        }
    });
}

/**
 并发队列同步执行
 
 不开新线程，任务串行执行
 */
- (IBAction)syncAndConcurrent:(id)sender {
    /**
     dispatch_get_global_queue(long identifier, unsigned long flags) 获取全局并发队列
     
     identifier 队列优先级（DISPATCH_QUEUE_PRIORITY_DEFAULT == 0）
     flags 保留字段，一般置 0.
     */
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"One - %@ - %ld", [NSThread currentThread], i);
        }
    });
    
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"Two - %@ - %ld", [NSThread currentThread], i);
        }
    });
}

/**
 串行队列异步执行
 
 开一条新线程，任务串行执行
 */
- (IBAction)asyncAndSerial:(id)sender {
    dispatch_queue_t queue = dispatch_queue_create("leon", NULL);
    
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"One - %@ - %ld", [NSThread currentThread], i);
        }
    });
    
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"Two - %@ - %ld", [NSThread currentThread], i);
        }
    });
    
}

/**
 并发队列异步执行
 
 开多条新线程，任务并发执行
 */
- (IBAction)asyncAndConcurrent:(id)sender {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"One - %@ - %ld", [NSThread currentThread], i);
        }
    });
    
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"Two - %@ - %ld", [NSThread currentThread], i);
        }
    });
}

/**
 下载图片
 */
- (IBAction)downloadImage:(id)sender {
    // 开启子线程异步下载图片
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread currentThread].name = @"downloadImage";
        // 打印当前线程信息
        NSLog(@"%@", [NSThread currentThread]);
        
        // 根据 URL 下载图片的二进制数据到本地
        NSURL *imageURL = [NSURL URLWithString:@"http://imgtu.5011.net/uploads/content/20170119/9635871484812579.jpg"];
        NSData *data = [NSData dataWithContentsOfURL:imageURL];
        
        // 转换成 UIImage
        UIImage *image = [UIImage imageWithData:data];
        
        // 线程通信（回到主线程刷新 UI）
        dispatch_async(dispatch_get_main_queue(), ^{
            self.downloadImageView.image = image;
        });
    });
}

/**
 队列组 Demo
 */
- (IBAction)queueGroupDemo:(id)sender {
    // 创建队列组
    dispatch_group_t group = dispatch_group_create();
    // 创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 异步执行
    dispatch_group_async(group, queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"One - %ld - %@", i, [NSThread currentThread]);
        }
    });
    
    dispatch_group_async(group, queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"Two - %ld - %@", i, [NSThread currentThread]);
        }
    });
    // 当队列组中所有任务都执行完毕会通知 group 执行 dispatch_group_notify()
    dispatch_group_notify(group, queue, ^{
        NSLog(@"所有任务已经执行完毕");
    });
}

/**
 延时执行
 */
- (IBAction)delayExcution:(id)sender {
    // 1.NSTimer
//    [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
//        NSLog(@"两秒前“延时执行”按钮被点击");
//    }];
//    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(delayEvent) userInfo:nil repeats:NO];
    
    // 2.performSelector:(nonnull SEL) withObject:(nullable id) afterDelay:(NSTimeInterval)
//    [self performSelector:@selector(delayEvent) withObject:nil afterDelay:2.0];
    
    // 3.GCD
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"两秒前“延时执行”按钮被点击");
    });
}

/**
 栅栏函数 Demo
 */
- (IBAction)barrierDemo:(id)sender {
    // 创建并发队列
    dispatch_queue_t queue = dispatch_queue_create("barrierDemoQueue", DISPATCH_QUEUE_CONCURRENT);
    
    // 异步执行
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"One - %@", [NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"Two - %@", [NSThread currentThread]);
        }
    });
    
    // 栅栏函数，该队列中前面的任务执行完才能执行后面的任务
    // 函数中的参数 queue 不能是全局并发队列
    dispatch_barrier_sync(queue, ^{
        NSLog(@"栅栏函数");
    });
    // 异步执行
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"Three - %@", [NSThread currentThread]);
        }
    });
}

/**
 快速迭代 Demo
 */
- (IBAction)applyDemo:(id)sender {
    //1.获得并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 迭代10次
    /*
     dispatch_apply(size_t iterations, dispatch_queue_t  _Nonnull queue, ^(size_t) {})
     iterations : 迭代次数
     queue : 并发队列
     block : 封装任务
     */
    dispatch_apply(100, queue, ^(size_t index) {
        // 执行 100 次代码， index 顺序不确定
        NSLog(@"%ld - %@", index, [NSThread currentThread]);
    });
}


#pragma mark - Custom
/**
 延时执行事件
 */
- (void)delayEvent {
    NSLog(@"两秒前“延时执行”按钮被点击");
}


@end
