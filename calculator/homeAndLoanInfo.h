//
//  homeInfo.h
//  HomeBuyer
//
//  Created by Shilpa Modi on 9/8/13.
//  Copyright (c) 2013 Kunance. All rights reserved.
//

#define NUMBER_OF_MONTHS_IN_YEAR 12

#import <Foundation/Foundation.h>
@interface homeAndLoanInfo : NSObject
@property (nonatomic) float            mHomeListPrice;
@property (nonatomic) float              mHOAFees;
@property (nonatomic) uint  mNumberOfMortgageMonths;
@property (nonatomic) float mLoanInterestRate;
@property (nonatomic) float mDownPaymentAmount;
@property (nonatomic) float mPropertyTaxRate;

-(float) getInterestAveragedOverYears:(uint)numOfYears;
-(float) getAnnualPropertyTaxes;
@end
