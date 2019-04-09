//
//  ViewController.m
//  Majia
//
//  Created by Macmafia on 2019/4/9.
//  Copyright © 2019 Macmafia. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *mLable;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#ifdef DEBUG
    //Debug
    _mLable.text = @"DEBUG";
#elif M_InHouse
    //InHouse
    _mLable.text = @"InHouse";
#elif M_Release
    //Release
    _mLable.text = @"Release";
#else
    //Invalid
    _mLable.text = @"默认值";
#endif
}


@end
