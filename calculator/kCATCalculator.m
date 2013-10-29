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
        
        self.mDeductionsAndExemptions = [CalculatorUtilities getDictionaryFromPlistFile:@"ExemptionsAndStandardDeductions2013"];
        
        self.mStateSingleTaxTable = [self importTableFromFile:@"TaxTableStateSingle2013"];
    }
    
    return self;
}

-(float) getMonthlyLifeStyleIncomeForRental
{
    if(!self.mUserProfile)
        return 0;
    
    float annualStatesTaxesPaid = [self getAnnualStateTaxesPaid];
    float annualFederalTaxesPaid = [self getAnnualFederalTaxesPaid];
    
    float montlyGrossIncome = self.mUserProfile.mAnnualGrossIncome/NUMBER_OF_MONTHS_IN_YEAR;
    float monthlyStateTaxesPaid = annualStatesTaxesPaid/NUMBER_OF_MONTHS_IN_YEAR;
    float montlyFedralTaxesPaid = annualFederalTaxesPaid/NUMBER_OF_MONTHS_IN_YEAR;
    
    float totalMonthlyCosts = self.mUserProfile.mMonthlyRent + self.mUserProfile.mMonthlyCarPayments + self.mUserProfile.mMonthlyOtherFixedCosts;
    float totalMonthlyTaxesPaid = monthlyStateTaxesPaid + montlyFedralTaxesPaid;
    
    float monthlyLifestyleIncome = montlyGrossIncome - (totalMonthlyCosts + totalMonthlyTaxesPaid);
    
    return  monthlyLifestyleIncome;
}

-(float) getAnnualStateTaxesPaid
{
    if(!self.mUserProfile)
        return 0;
    
    return 0;
}

-(float) getAnnualFederalTaxesPaid
{
    if(!self.mUserProfile)
        return 0;
    
    return 0;
}

-(float) getAnnualAdjustedGrossIncome
{
    if(!self.mUserProfile)
        return 0;
    
    return (self.mUserProfile.mAnnualGrossIncome - self.mUserProfile.mAnnualRetirementSavings);
}

///////////////////StateTaxes/////////////////

-(float) getStateStandardDeduction
{
    if(!self.mUserProfile)
        return 0;
    
    float baseDeduction = [self.mDeductionsAndExemptions[@"BaseDeductionCaliforniaState"] floatValue];
    
    if(self.mUserProfile.mMaritalStatus == StatusMarried)
        return baseDeduction * 2;
    else
        return baseDeduction;
}

-(float) getStateItemizedDeduction
{
    if(!self.mUserProfile)
        return 0;
    
    return 0;
}

-(float) getStateExemptions
{
    if(!self.mUserProfile)
        return 0;
    
    float baseDeduction = [self.mDeductionsAndExemptions[@"BaseExemptionCaliforniaState"] floatValue];
    if (self.mUserProfile.mMaritalStatus == StatusMarried)
        return baseDeduction*2;
    else
        return baseDeduction;
        
    return 0;
}

-(float) getAnnualStateTaxableIncome
{
    if(!self.mUserProfile)
        return 0;
    
    float standardDeduction = [self getStateStandardDeduction];
    float itemizedDeduction = [self getStateItemizedDeduction];
    
    float stateDeduction = (standardDeduction > itemizedDeduction) ? standardDeduction : itemizedDeduction;
    float exemption = [self getStateExemptions];
    float adjustedAnnualGrossIncome = [self getAnnualAdjustedGrossIncome];
    
    return (adjustedAnnualGrossIncome - (stateDeduction + exemption));
}

///////////////////FederalTaxes/////////////////

-(float) getFederalStandardDeduction
{
    if(!self.mUserProfile)
        return 0;
    
    return 0;
}

-(float) getFederalItemizedDeduction
{
    if(!self.mUserProfile)
        return 0;
    
    return 0;
}

-(float) getFederalExemptions
{
    if(!self.mUserProfile)
        return 0;
    
    return 0;
}

-(float) getAnnualFederalTaxableIncome
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
    
    NSArray* tableDict = [CalculatorUtilities getArrayFromPlistFile:fileName];
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
