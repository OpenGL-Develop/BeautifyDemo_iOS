//
//  MainTestViewController.m
//  BeautifyDemo
//
//  Created by 张英堂 on 2017/7/11.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "MainTestViewController.h"
#import "MG_Beautify.h"
#import "MG_Detector.h"
#import "MG_Facepp.h"

@interface MainTestViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionView;

@end

@implementation MainTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    const char* beautyVersion = mg_beautify.GetApiVersion();
    const char* faceppVersion = mg_facepp.GetApiVersion();
    
    NSString *showString = [NSString stringWithFormat:@"facepp: %s \n beautify: %s", faceppVersion, beautyVersion];
    [self.versionView setText:showString];
    
} 

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
