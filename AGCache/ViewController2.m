//
//  ViewController2.m
//  AGCache
//
//  Created by 吴书敏 on 2017/11/23.
//  Copyright © 2017年 吴书敏. All rights reserved.
//

#import "ViewController2.h"
#import "AGSDWebImageCache.h"
#import <UIImageView+WebCache.h>

@interface ViewController2 ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *myHttp = @"https://ws2.sinaimg.cn/large/006tKfTcgy1flsa8aa0ayj31kw0zlwpj.jpg";
       
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:myHttp] placeholderImage:nil options:(SDWebImageRefreshCached)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
