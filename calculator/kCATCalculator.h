//
//  kCATCalculator.h
//  calculator
//
//  Created by Shilpa Modi on 10/28/13.
//  Copyright (c) 2013 Kunance. All rights reserved.
//

#define NUMBER_OF_MONTHS_IN_YEAR 12

#import <Foundation/Foundation.h>
#import "UserProfileObject.h"

@interface kCATCalculator : NSObject
@property (nonatomic, strong) UserProfileObject* mUserProfile;

- (id) initWithUserProfile:(UserProfileObject*) userProfile;

-(float) getMonthlyLifeStyleIncomeForRental;
-(float) getAnnualStateTaxesPaid;
-(float) getAnnualFederalTaxesPaid;

-(float) getStateStandardDeduction;
-(float) getStateItemizedDeduction;
-(float) getStateExemptions;
-(float) getAnnualStateTaxableIncome;

-(float) getFederalStandardDeduction;
-(float) getFederalItemizedDeduction;
-(float) getFederalExemptions;
-(float) getAnnualFederalTaxableIncome;
@end
