//
//  kCATCalculator.m
//  calculator
//
//  Created by Shilpa Modi on 10/28/13.
//  Copyright (c) 2013 Kunance. All rights reserved.
//

#import "kCATCalculator.h"
#import "UserProfileObject.h"
#import "CalculatorUtilities.h"
#import "TaxBlock.h"

@interface kCATCalculator()
@property (nonatomic, strong) NSDictionary* mDeductionsAndExemptions;
@property (nonatomic, strong) NSArray* mStateSingleTaxTable;
@property (nonatomic, strong) NSArray* mStateMFJTaxTable;
@property (nonatomic, strong) NSArray* mFederalSingleTaxTable;
@property (nonatomic, strong) NSArray* mFederalMFJTaxTable;
@end

@implementation kCATCalculator

- (id) initWithUserProfile:(UserProfileObject*) userProfile
{
    self = [super init];
    if (self)
    {
        // Initialization
        self.mUserProfile = userProfile;
        self.mDeductionsAndExemptions = [CalculatorUtilities getDictionaryFromFile:@"ExemptionsAndStandardDeductions2013.plist"];
        
        self.mStateSingleTaxTable = [self importTableFromFile:@"TaxTableStateSingle2013.plist"];
    }
    
    return self;
}

-(long) getMonthlyLifeStyleIncomeForRental
{
    if(!self.mUserProfile)
        return 0;
    
    long annualStatesTaxesPaid = [self getAnnualStateTaxesPaid];
    long annualFederalTaxesPaid = [self getAnnualFederalTaxesPaid];
    
    long montlyGrossIncome = self.mUserProfile.mAnnualGrossIncome/NUMBER_OF_MONTHS_IN_YEAR;
    long monthlyStateTaxesPaid = annualStatesTaxesPaid/NUMBER_OF_MONTHS_IN_YEAR;
    long montlyFedralTaxesPaid = annualFederalTaxesPaid/NUMBER_OF_MONTHS_IN_YEAR;
    
    long totalMonthlyCosts = self.mUserProfile.mMonthlyRent + self.mUserProfile.mMonthlyCarPayments + self.mUserProfile.mMonthlyOtherFixedCosts;
    long totalMonthlyTaxesPaid = monthlyStateTaxesPaid + montlyFedralTaxesPaid;
    
    long monthlyLifestyleIncome = montlyGrossIncome - (totalMonthlyCosts + totalMonthlyTaxesPaid);
    
    return  monthlyLifestyleIncome;
}

-(long) getAnnualStateTaxesPaid
{
    if(!self.mUserProfile)
        return 0;
    
    return 0;
}

-(long) getAnnualFederalTaxesPaid
{
    if(!self.mUserProfile)
        return 0;
    
    return 0;
}

-(long) getAnnualAdjustedGrossIncome
{
    if(!self.mUserProfile)
        return 0;
    
    return (self.mUserProfile.mAnnualGrossIncome - self.mUserProfile.mAnnualRetirementSavings);
}

///////////////////StateTaxes/////////////////

-(long) getStateStandardDeduction
{
    if(!self.mUserProfile)
        return 0;
    
    long baseDeduction = [self.mDeductionsAndExemptions[@"BaseDeductionCaliforniaState"] longValue];
    
    if(self.mUserProfile.mMaritalStatus == StatusMarried)
        return baseDeduction * 2;
    else
        return baseDeduction;
}

-(long) getStateItemizedDeduction
{
    if(!self.mUserProfile)
        return 0;
    
    return 0;
}

-(long) getStateExemptions
{
    if(!self.mUserProfile)
        return 0;
    
    long baseDeduction = [self.mDeductionsAndExemptions[@"BaseExemptionCaliforniaState"] longValue];
    if (self.mUserProfile.mMaritalStatus == StatusMarried)
        return baseDeduction*2;
    else
        return baseDeduction;
        
    return 0;
}

-(long) getAnnualStateTaxableIncome
{
    if(!self.mUserProfile)
        return 0;
    
    long standardDeduction = [self getStateStandardDeduction];
    long itemizedDeduction = [self getStateItemizedDeduction];
    
    long stateDeduction = (standardDeduction > itemizedDeduction) ? standardDeduction : itemizedDeduction;
    long exemption = [self getStateExemptions];
    long adjustedAnnualGrossIncome = [self getAnnualAdjustedGrossIncome];
    
    return (adjustedAnnualGrossIncome - (stateDeduction + exemption));
}

///////////////////FederalTaxes/////////////////

-(long) getFederalStandardDeduction
{
    if(!self.mUserProfile)
        return 0;
    
    return 0;
}

-(long) getFederalItemizedDeduction
{
    if(!self.mUserProfile)
        return 0;
    
    return 0;
}

-(long) getFederalExemptions
{
    if(!self.mUserProfile)
        return 0;
    
    return 0;
}

-(long) getAnnualFederalTaxableIncome
{
    if(!self.mUserProfile)
        return 0;
    
    return 0;
}

-(NSArray*) importTableFromFile:(NSString*) fileName
{
    if(!fileName)
        return nil;
    
    NSMutableArray* array = [[NSMutableArray alloc] init];
    
    NSDictionary* tableDict = [CalculatorUtilities getDictionaryFromFile:fileName];
    for (NSDictionary* blockDict in tableDict)
    {
        TaxBlock* block = [[TaxBlock alloc] init];
        block.mUpperLimit = [blockDict[@"limit"] floatValue];
        block.mFixedAmount = [blockDict[@"fixedAmount"] floatValue];
        block.mPercentage = [blockDict[@"percentage"] floatValue];
        
        [array addObject:block];
    }
    
    return array;
}
@end
