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
    userProfile.mAnnualGrossIncome = 120000;
    userProfile.mAnnualRetirementSavings = 7000;
    userProfile.mMaritalStatus = StatusMarried;
    userProfile.mNumberOfChildren = 0;
    userProfile.mMonthlyCarPayments = 0;
    userProfile.mMonthlyOtherFixedCosts = 840/12;
    userProfile.mMonthlyRent = 1300;
    
    kCATCalculator* calculator = [[kCATCalculator alloc] initWithUserProfile:userProfile];
    float monthlylifestyle = [calculator getMonthlyLifeStyleIncomeForRental];
    self.mCurrentLifestyleIncomeLabel.text = [NSString stringWithFormat:@"Montly lifestyle %.2f", monthlylifestyle];
    
    float result = [calculator getAnnualStateTaxesPaid];
    self.mAnnualStateTaxesLabel.text = [NSString stringWithFormat:@"Annual State Taxes: %.2f", result];
    
    result = [calculator getAnnualFederalTaxesPaid];
    self.mAnnualFederalTaxesLabel.text = [NSString stringWithFormat:@"Annual Federal Taxes: %.2f", result];
    
    result = [calculator getAnnualStateTaxableIncome];
    self.mStateTaxableIncomeIncomeLabel.text =
    [NSString stringWithFormat:@"State taxable Income: %.2f", result];
    
    result = [calculator getAnnualFederalTaxableIncome];
    self.mFederalTaxableIncomeIncomeLabel.text =
    [NSString stringWithFormat:@"Federal Taxable income: %.2f", result];
    
    result = [calculator getStateStandardDeduction];
    self.mStateDeductionsLabel.text = [NSString stringWithFormat:@"State standard deduction: %.2f", result];
    
    result = [calculator getFederalStandardDeduction];
    self.mFederalDeductionsLabel.text = [NSString stringWithFormat:@"Fed. std. deduction: %.2f", result];
    
    result = [calculator getStateExemptions];
    self.mStateExemptionsLabel.text = [NSString stringWithFormat:@"State exemptions: %.2f", result];
    
    result = [calculator getFederalExemptions];
    self.mFederalExemptionsLabel.text = [NSString stringWithFormat:@"Federal exemptions: %.2f", result];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
