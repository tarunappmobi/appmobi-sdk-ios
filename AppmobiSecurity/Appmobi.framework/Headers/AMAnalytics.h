//
//  AMAnalytics.h
//  Appmobi
//
//  Created by iOS on 16/11/16.
//  Copyright © 2016 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMAnalytics : NSObject

-(void) logCustomEvent:(NSString*)event withValue:(NSString*)value;
-(void) logPageEvent:(NSString*)page;
-(void) logMethodEvent:(NSString*)method;

@end
