//
//  NKUI.m
//  NEXTKING
//
//  Created by King on 10/24/12.
//  Copyright (c) 2012 ZUO.COM. All rights reserved.
//

#import "NKUI.h"


@interface NKUI ()

@end

@implementation NKUI

@synthesize welcomeCalss;
@synthesize homeClass;
@synthesize needLogin;

@synthesize navigator;
@synthesize nkBackgroundView;
@synthesize currentController;

@synthesize needStoreViewControllers;
@synthesize allViewControllers;

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NKWillLogoutNotificationKey object:nil];
    
    [currentController release];
    
    [super dealloc];
}

static NKUI * _NKUI = nil;

+(id)sharedNKUI{
    
    if (!_NKUI) {
        _NKUI = [[NKUI alloc] init];
    }
    
    return _NKUI;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self.currentController viewWillAppear:animated];
    
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout) name:NKWillLogoutNotificationKey object:nil];
    }
    return self;
}

-(void)logout{
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    
    [self showWelcome];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.nkBackgroundView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, NKMainHeight-NKNavigatorHeight)] autorelease];
    self.nkBackgroundView.userInteractionEnabled = YES;
    //zuoBackgroundView.image = [UIImage imageNamed:@"background.png"];
    [self.view addSubview:nkBackgroundView];
    
    self.navigator = [NKNavigator sharedNavigator];
    [self.view addSubview:navigator];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark NaviTabAnimate

-(void)showNaviTab{
    
    [UIView animateWithDuration:[[NKConfig sharedConfig] navigatorShowAnimate]?0.3:0 animations:^{
        self.navigator.frame = CGRectMake(0, NKMainHeight-NKNavigatorHeight, 320, NKNavigatorHeight);
    }];
}

-(void)hideNaviTab{
    
    [UIView animateWithDuration:0.3 animations:^{
        self.navigator.frame = CGRectMake(0, NKMainHeight, 320, NKNavigatorHeight);
    }];
}

-(void)addTabs:(NSArray*)tab{
    [self view];
    [self.navigator addTabs:tab];
    [self showDefaultViewController];
    
}


#pragma mark Show

-(void)showWelcome{
    [self showViewControllerWithClass:welcomeCalss];
    [self hideNaviTab];
}
-(void)showDefaultViewController{
    
    // Wit Account System
    if (needLogin) {
        
        
        if ([NKMUser me]) {
            
        }
        else {
            if (![[[[NKConfig sharedConfig] accountManagerClass] sharedAccountsManager] canAutoLogin]) {
                //[self showLoginView];
            }
            else {
                [[[[NKConfig sharedConfig] accountManagerClass] sharedAccountsManager] autoLogin];
            }
        }
        
        
        
        if ([[[[NKConfig sharedConfig] accountManagerClass] sharedAccountsManager] canAutoLogin]) {
            [self showViewControllerWithClass:homeClass andIndex:0];
            [self showNaviTab];
        }
        else {
            [self showWelcome];
            
        }
        
        
        
    }
    
    else{
        [self showViewControllerWithClass:homeClass andIndex:0];
        [self showNaviTab];
    }
    
}

// Show ViewController
-(UIViewController*)showViewControllerWithClass:(Class)ControllerToShow{
    
    return [self showViewControllerWithClass:ControllerToShow andIndex:-1];
    
}

-(UIViewController*)showViewControllerWithClass:(Class)ControllerToShow andIndex:(NSInteger)index{
    
    if ([NSStringFromClass([currentController class]) isEqualToString:NSStringFromClass(ControllerToShow)]) {
        return currentController;
    }
    
    [currentController dismissModalViewControllerAnimated:NO];
    
    UIViewController *newController = nil;
    
    if (self.needStoreViewControllers&&index>=0) {
        
        if (!self.allViewControllers) {
            self.allViewControllers = [NSMutableArray arrayWithCapacity:[[self.navigator.tabSource objectAtIndex:0] count]];
            for (int i=0; i<[[self.navigator.tabSource objectAtIndex:0] count]; i++) {
                [self.allViewControllers addObject:[NSNull null]];
            }
        }
        
        if ([self.allViewControllers objectAtIndex:index] == [NSNull null]) {
            newController = [[[ControllerToShow alloc] init] autorelease];
            [self.allViewControllers replaceObjectAtIndex:index withObject:newController];
        }
        
        newController = [self.allViewControllers objectAtIndex:index];
        
    }
    else{
        newController = [[[ControllerToShow alloc] init] autorelease]; 
    }
    
    [currentController.view removeFromSuperview];
    [nkBackgroundView addSubview:newController.view];
    
    self.currentController = newController;

    
    return newController;
    
    
}

@end
