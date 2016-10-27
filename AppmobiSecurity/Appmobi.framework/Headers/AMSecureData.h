//
//  AMSecureData.h
//  Appmobi
//
//  Created by iOS on 05/01/16.
//  Copyright © 2016 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMSecureData : NSObject

@property(nonatomic, strong) NSString *key;
@property(nonatomic, strong) NSString *value;
@property(nonatomic) int uniqueID;

@end
