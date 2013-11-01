//
//  homeInfo.m
//  HomeBuyer
//
//  Created by Shilpa Modi on 9/8/13.
//  Copyright (c) 2013 Kunance. All rights reserved.
//

#import "homeAndLoanInfo.h"

@implementation homeAndLoanInfo

-(id) init
{
    self = [super init];
    
    if(self)
    {
        self.mHomeListPrice = 0;
        self.mHOAFees = 0;
        self.mNumberOfMortgageMonths = 0;
        self.mLoanInterestRate = 0;
        self.mDownPaymentAmount = 0;
        self.mPropertyTaxRate = 1.25;
    }
    
    return self;
}

-(float) getInterestAveragedOverYears:(uint) numberOfYears
{
    float loanBalanceAfterPrevPayment = [self getInitialLoanBalance];
    float interestPaidForThisMonth = 0;
    float principalPaidForThisMonth = 0;

    float monthlyLoanPaymentForHome = [self getMonthlyLoanPaymentForHome];
    uint numberOfMOnths = numberOfYears*NUMBER_OF_MONTHS_IN_YEAR;
    float monthlyInterestRate = self.mLoanInterestRate/NUMBER_OF_MONTHS_IN_YEAR/100;

    NSMutableArray* monthlyInterest = [[NSMutableArray alloc] init];
    
    for (int i= 0; i < numberOfMOnths; i++)
    {
        interestPaidForThisMonth = loanBalanceAfterPrevPayment * monthlyInterestRate;
        principalPaidForThisMonth = monthlyLoanPaymentForHome - interestPaidForThisMonth;
        loanBalanceAfterPrevPayment -= principalPaidForThisMonth;
        [monthlyInterest addObject:[NSNumber numberWithFloat:interestPaidForThisMonth]];
    }
    
    float averageInterestOverYears = 0;
    
    for (NSNumber* interest in monthlyInterest)
    {
        averageInterestOverYears += interest.floatValue;
    }
    
    averageInterestOverYears =  averageInterestOverYears/numberOfMOnths*12;
    
    return averageInterestOverYears;
}

-(float) getMonthlyLoanPaymentForHome
{
    float monthlyInterestRate = self.mLoanInterestRate/NUMBER_OF_MONTHS_IN_YEAR/100;
    float initialLoanBalance = [self getInitialLoanBalance];
    float numberOfMonths = self.mNumberOfMortgageMonths;
    
    double exp = pow((1+ monthlyInterestRate), numberOfMonths);
    double numerator = monthlyInterestRate * initialLoanBalance * exp;
    double denominator = exp - 1;
    
    double monthlyLoanPayment = numerator/denominator;
    
    return monthlyLoanPayment;
}

-(float) getInitialLoanBalance
{
    return self.mHomeListPrice - self.mDownPaymentAmount;
}

-(float) getAnnualPropertyTaxes
{
    return self.mHomeListPrice*self.mPropertyTaxRate/100;
}
@end
