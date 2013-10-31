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

-(float) getTaxesForTable:(NSArray*)taxBlockArray andTaxableIncome:(float) taxableIncome
{
    if(!taxBlockArray)
        return 0;
    
    float differenceIncomeForBlock = 0;
    float applicableIncomeForBlock = 0;
    float baseIncomeForBlock = taxableIncome;
    float finalTaxesPaid = 0;

    float upperLimitForPreviousBlock = 0;
    for (TaxBlock* currentTaxBlock in taxBlockArray)
    {
        float limitForCurrentBlock = currentTaxBlock.mUpperLimit;
        float percentageForCurrentBlock = currentTaxBlock.mPercentage;
        
        differenceIncomeForBlock = baseIncomeForBlock - upperLimitForPreviousBlock;
        
        if(differenceIncomeForBlock < limitForCurrentBlock)
            applicableIncomeForBlock = differenceIncomeForBlock;
        else
            applicableIncomeForBlock = limitForCurrentBlock;
        
        if(applicableIncomeForBlock < 0)
            break;
        
        float taxForCurrentBlock = (applicableIncomeForBlock * percentageForCurrentBlock/100);
        
        finalTaxesPaid += taxForCurrentBlock;
        
        upperLimitForPreviousBlock = limitForCurrentBlock;
        baseIncomeForBlock = differenceIncomeForBlock;
    }

    return finalTaxesPaid;
}

-(float) getAnnualStateTaxesPaid
{
    if(!self.mUserProfile)
        return 0;
    
    float stateTaxableIncome = [self getAnnualStateTaxableIncome];
    NSArray* taxBlockArray = nil;
    if(self.mUserProfile.mMaritalStatus == StatusMarried)
        taxBlockArray = self.mStateMFJTaxTable;
    else
        taxBlockArray = self.mStateSingleTaxTable;

    
    return [self getTaxesForTable:taxBlockArray andTaxableIncome:stateTaxableIncome];
}

-(float) getAnnualFederalTaxesPaid
{
    if(!self.mUserProfile)
        return 0;
    
    float federalTaxableIncome = [self getAnnualFederalTaxableIncome];
    NSArray* taxBlockArray = nil;
    if(self.mUserProfile.mMaritalStatus == StatusMarried)
        taxBlockArray = self.mFederalMFJTaxTable;
    else
        taxBlockArray = self.mFederalSingleTaxTable;
    
    return [self getTaxesForTable:taxBlockArray andTaxableIncome:federalTaxableIncome];
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
    
    float finalDeduction = 0;
    
    if(self.mUserProfile.mMaritalStatus == StatusMarried)
        finalDeduction = [self.mDeductionsAndExemptions[@"MarriedDeductionCaliforniaState"] floatValue];
    else
        finalDeduction = [self.mDeductionsAndExemptions[@"SingleDeductionCaliforniaState"] floatValue];
    
    finalDeduction += (self.mUserProfile.mNumberOfChildren) * [self.mDeductionsAndExemptions[@"ChildrenDeductionCaliforniaState"] floatValue];

    return finalDeduction;
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
    
    float finalExemption = 0;
    
    if(self.mUserProfile.mMaritalStatus == StatusMarried)
        finalExemption = [self.mDeductionsAndExemptions[@"MarriedExemptionCaliforniaState"] floatValue];
    else
        finalExemption = [self.mDeductionsAndExemptions[@"SingleExemptionCaliforniaState"] floatValue];
    
    finalExemption += (self.mUserProfile.mNumberOfChildren) * [self.mDeductionsAndExemptions[@"ChildrenExemptionCaliforniaState"] floatValue];
    
    return finalExemption;
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
    
    if(self.mUserProfile.mMaritalStatus == StatusMarried)
        return [self.mDeductionsAndExemptions[@"MarriedDeductionFederal"] floatValue];
    else
        return [self.mDeductionsAndExemptions[@"SingleDeductionFederal"] floatValue];;
}

-(float) getFederalItemizedDeduction
{
    if(!self.mUserProfile)
        return 0;
    
    float stateTaxesPaid = [self getAnnualStateTaxesPaid];
    float stateItemizedDeduction = [self getStateItemizedDeduction];
    
    return stateTaxesPaid + stateItemizedDeduction;
}

-(float) getFederalExemptions
{
    if(!self.mUserProfile)
        return 0;
    
    float finalExemption = 0;
    
    if(self.mUserProfile.mMaritalStatus == StatusMarried)
        finalExemption = [self.mDeductionsAndExemptions[@"MarriedExemptionFederal"] floatValue];
    else
        finalExemption = [self.mDeductionsAndExemptions[@"SingleExemptionFederal"] floatValue];
    
    finalExemption += (self.mUserProfile.mNumberOfChildren) * [self.mDeductionsAndExemptions[@"ChildrenExemptionFederal"] floatValue];
    
    return finalExemption;
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
