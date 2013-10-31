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
        self.mStateMFJTaxTable = [self importTableFromFile:@"TaxTableStateMFJ2013"];
        self.mFederalSingleTaxTable = [self importTableFromFile:@"TaxTableFederalSingle2013"];
        self.mFederalMFJTaxTable = [self importTableFromFile:@"TaxTableFederalMFJ2013"];
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
    
    float finalAnnualStateTaxesPaid = 0;
    
    float stateTaxableIncome = [self getAnnualStateTaxableIncome];
    NSArray* taxBlockArray = nil;
    if(self.mUserProfile.mMaritalStatus == StatusMarried)
        taxBlockArray = self.mStateMFJTaxTable;
    else
        taxBlockArray = self.mStateSingleTaxTable;

    float differenceIncomeForBlock = 0;
    float applicableIncomeForBlock = 0;
    float baseIncomeForBlock = stateTaxableIncome;
    
    float upperLimitForPreviousBlock = 0;
    for (TaxBlock* currentTaxBlock in taxBlockArray)
    {
        float limitForCurrentBlock = currentTaxBlock.mUpperLimit;
        float percentageForCurrentBlock = currentTaxBlock.mPercentage;
        float fixedAmountForCurrrentBlock = currentTaxBlock.mFixedAmount;
        
        differenceIncomeForBlock = baseIncomeForBlock - upperLimitForPreviousBlock;
        
        if(differenceIncomeForBlock < limitForCurrentBlock)
            applicableIncomeForBlock = differenceIncomeForBlock;
        else
            applicableIncomeForBlock = limitForCurrentBlock;
        
        float taxForCurrentBlock = (applicableIncomeForBlock * percentageForCurrentBlock/100) + fixedAmountForCurrrentBlock;
        
        finalAnnualStateTaxesPaid += taxForCurrentBlock;
        
        upperLimitForPreviousBlock = limitForCurrentBlock;
        baseIncomeForBlock = differenceIncomeForBlock;
    }
    
    return finalAnnualStateTaxesPaid;
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
    
    float interestOnHomeMortgage = 0;
    float propertyTaxesPaid = 0;

    return interestOnHomeMortgage + propertyTaxesPaid;
}

-(float) getStateExemptions
{
    if(!self.mUserProfile)
        return 0;
    
    //float baseExemption = [self.mDeductionsAndExemptions[@"BaseExemptionCaliforniaState"] floatValue];
    if (self.mUserProfile.mMaritalStatus == StatusMarried)
        return (self.mUserProfile.mNumberOfChildren*315) + 102;
    else
        return 102;
        
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
    
    float baseDeduction = [self.mDeductionsAndExemptions[@"BaseDeductionFedral"] floatValue];
    
    if(self.mUserProfile.mMaritalStatus == StatusMarried)
        return baseDeduction * 2;
    else
        return baseDeduction;
}

-(float) getFederalItemizedDeduction
{
    if(!self.mUserProfile)
        return 0;
    
    float propertyTaxesPaid = 0;
    float interestOnHomeMortgage = 0;
    float stateTaxesPaid = [self getAnnualStateTaxesPaid];
    
    return stateTaxesPaid + propertyTaxesPaid + interestOnHomeMortgage;
}

-(float) getFederalExemptions
{
    if(!self.mUserProfile)
        return 0;
    
    float baseExemption = [self.mDeductionsAndExemptions[@"BaseExemptionFederal"] floatValue];
    if (self.mUserProfile.mMaritalStatus == StatusMarried)
    {
        return (baseExemption * 2) + (baseExemption * self.mUserProfile.mNumberOfChildren);
    }
    else
    {
        return baseExemption + (baseExemption * self.mUserProfile.mNumberOfChildren);
    }
}

-(float) getAnnualFederalTaxableIncome
{
    if(!self.mUserProfile)
        return 0;
    
    float stardardizedDeduction = [self getFederalStandardDeduction];
    float itemizedDeduction = [self getFederalItemizedDeduction];
    
    float federalDeduction = (stardardizedDeduction > itemizedDeduction) ? stardardizedDeduction : itemizedDeduction;
    float federalExemption = [self getFederalExemptions];
    
    float federalAdjustedGrossIncome = [self getAnnualAdjustedGrossIncome];
    
    float federalTaxableIncome = (federalAdjustedGrossIncome - federalDeduction - federalExemption);
    
    return federalTaxableIncome;
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
        block.mUpperLimit = [blockDict[@"limitsDifference"] floatValue];
        block.mFixedAmount = [blockDict[@"fixedAmount"] floatValue];
        block.mPercentage = [blockDict[@"percentage"] floatValue];
        
        [array addObject:block];
    }
    
    return array;
}
@end
