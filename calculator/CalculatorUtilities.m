//
//  CalculatorUtilities.m
//  calculator
//
//  Created by Shilpa Modi on 10/28/13.
//  Copyright (c) 2013 Kunance. All rights reserved.
//

#import "CalculatorUtilities.h"

@implementation CalculatorUtilities

+(NSDictionary*) getDictionaryFromFile:(NSString*) fileName
{
    if(!fileName)
        return nil;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString* fileNamePath = [[paths objectAtIndex:0]
                          stringByAppendingPathComponent:fileName];
    
    return [[NSDictionary alloc] initWithContentsOfFile:fileNamePath];
}
@end
