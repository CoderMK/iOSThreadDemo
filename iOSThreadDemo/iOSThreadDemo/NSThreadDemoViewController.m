//
//  NSThreadDemoViewController.m
//  iOSThreadDemo
//
//  Created by lifuheng on 2017/6/14.
//  Copyright © 2017年 Leon. All rights reserved.
//

#import "NSThreadDemoViewController.h"

@interface NSThreadDemoViewController ()

/* 显示下载图片视图 */
@property (weak, nonatomic) IBOutlet UIImageView *downloadImageView;

@end

@implementation NSThreadDemoViewController

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
    // 三种方式创建三条线程
    // 1.alloc init 方式创建线程（需要主动启动线程）
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadRun:) object:@"init"];
    
    // 设置 thread 属性，To be deprecated; use qualityOfService
    thread.threadPriority = 1.0; // 优先级，取值范围为 0.0 ~ 1.0，默认为 0.5
    thread.name = @"init";
    
    // 启动线程(线程一启动，就会调用 self 的 threadRun 方法)
    [thread start];
    
    // 2.detach 方式创建线程 (不需要主动启动)
    [NSThread detachNewThreadSelector:@selector(threadRun:) toTarget:self withObject:@"detach"];
    // detachNewThreadWithBlock: 与上述方法类似，只不过执行任务放到了 Block 中
    //    [NSThread detachNewThreadWithBlock:^{
    //        for (NSInteger i = 0; i < 100; i ++) {
    //            NSLog(@"detachBlock - %@ - %ld", [NSThread currentThread], i);
    //        }
    //    }];
    
    // 3.performSelectorInBackground 方式创建线程 (不需要主动启动)
    [self performSelectorInBackground:@selector(threadRun:) withObject:@"background"];
}

/**
 下载图片
 */
- (IBAction)downloadImage:(id)sender {
    // 开启子线程下载图片（耗时操作不占用主线程，因为 UI 控件的操作只能放在主线程中，开启子线程进行耗时操作可以同时处理 UI 控件和耗时操作。）
    [NSThread detachNewThreadWithBlock:^{
        [NSThread currentThread].name = @"downloadImage";
        // 打印当前线程信息
        NSLog(@"%@", [NSThread currentThread]);
        
        // 根据 URL 下载图片的二进制数据到本地
        NSURL *imageURL = [NSURL URLWithString:@"http://imgtu.5011.net/uploads/content/20170119/9635871484812579.jpg"];
        NSData *data = [NSData dataWithContentsOfURL:imageURL];
        
        // 转换成 UIImage
        UIImage *image = [UIImage imageWithData:data];
        
        // 回到主线程刷新 UI （刷新 UI 操作一定要回到主线程进行）
        /*
         UI 更新操作要放在主线程中的原因：
         
         1、在子线程中是不能进行 UI 更新的，而可以更新的结果只是一个幻像：因为子线程代码执行完毕了，又自动进入到了主线程，执行了子线程中的 UI 更新的函数栈，这中间的时间非常的短，就让大家误以为分线程可以更新 UI 。如果子线程一直在运行，则子线程中的 UI 更新的函数栈 主线程无法获知，即无法更新
         
         2、只有极少数的 UI 能，因为开辟线程时会获取当前环境，如点击某个按钮，这个按钮响应的方法是开辟一个子线程，在子线程中对该按钮进行 UI 更新是能及时的，如换标题，换背景图，但这没有任何意义
         */
        
        /**
         线程通信方式一
         
         @param SEL 回到主线程中要调用的方法
         @param Object 调用方法的参数
         @param waitUntilDone 是否等待调用方法执行完毕后再执行后面的代码
         */
        [self performSelectorOnMainThread:@selector(showImage:) withObject:image waitUntilDone:YES];
        
        /**
         线程通信方式二
         
         @param SEL 跳转到别的线程中中要调用的方法
         @param Thread 要跳转的线程
         @param Object 调用方法的参数
         @param waitUntilDone 是否等待调用方法执行完毕后再执行后面的代码
         */
//        [self performSelector:@selector(showImage:) onThread:[NSThread mainThread] withObject:image waitUntilDone:YES];
        
        // 线程通信方式三
//        [self.downloadImageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
    }];
}


#pragma mark - Custom
/**
 线程开启后调用此方法
 
 @param param 参数
 */
- (void)threadRun:(id)param {
    for (NSInteger i = 0; i < 10; i++) {
        NSLog(@"%@ - %@ - %ld", param, [NSThread currentThread], i);
        
        // 判断当前方法所在线程是否为主线程
//        BOOL isMainThread = [NSThread isMainThread];
        // 判断当前线程是否为主线程(number == 1 && name == main)
//        BOOL isMainThread = [[NSThread currentThread] isMainThread];
        
        // 阻塞线程 1.0s
//        [NSThread sleepForTimeInterval:1.0];
//        [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
        
        // 强制退出线程，线程一旦被强制退出就无法再次开启
//        [NSThread exit];
    }
}

/**
 更新 UI

 @param image 要显示的图片
 */
- (void)showImage:(UIImage *)image {
    self.downloadImageView.image = image;
}


@end
