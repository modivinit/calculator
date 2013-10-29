//
//  ResultsViewController.m
//  calculator
//
//  Created by Shilpa Modi on 10/28/13.
//  Copyright (c) 2013 Kunance. All rights reserved.
//

#import "ResultsViewController.h"
#import "kCATCalculator.h"

@interface ResultsViewController ()

@end

@implementation ResultsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UserProfileObject* userProfile = [[UserProfileObject alloc] init];
    userProfile.mAnnualGrossIncome = 100000;
    userProfile.mAnnualRetirementSavings = 10000;
    userProfile.mMaritalStatus = StatusMarried;
    userProfile.mNumberOfChildren = 1;
    userProfile.mMonthlyCarPayments = 200;
    userProfile.mMonthlyOtherFixedCosts = 175;
    userProfile.mMonthlyRent = 1250;
    
    kCATCalculator* calculator = [[kCATCalculator alloc] initWithUserProfile:userProfile];
    float monthlylifestyle = [calculator getMonthlyLifeStyleIncomeForRental];
    self.mCurrentLifestyleIncomeLabel.text = [NSString stringWithFormat:@"%f", monthlylifestyle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
