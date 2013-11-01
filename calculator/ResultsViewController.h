//
//  ResultsViewController.h
//  calculator
//
//  Created by Shilpa Modi on 10/28/13.
//  Copyright (c) 2013 Kunance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultsViewController : UIViewController
@property (nonatomic) IBOutlet UILabel* mCurrentLifestyleIncomeLabel;
@property (nonatomic) IBOutlet UILabel* mAnnualStateTaxesLabel;
@property (nonatomic) IBOutlet UILabel* mAnnualFederalTaxesLabel;
@property (nonatomic) IBOutlet UILabel* mStateTaxableIncomeIncomeLabel;
@property (nonatomic) IBOutlet UILabel* mFederalTaxableIncomeIncomeLabel;
@property (nonatomic) IBOutlet UILabel* mStateDeductionsLabel;
@property (nonatomic) IBOutlet UILabel* mFederalDeductionsLabel;
@property (nonatomic) IBOutlet UILabel* mStateExemptionsLabel;
@property (nonatomic) IBOutlet UILabel* mFederalExemptionsLabel;
@property (nonatomic) IBOutlet UILabel* mFederalItemizedDeduction;
@property (nonatomic) IBOutlet UILabel* mStateItemizedDeduction;
@end
