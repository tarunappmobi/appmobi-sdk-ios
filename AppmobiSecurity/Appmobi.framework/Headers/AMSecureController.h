//
//  AMSecureController.h
//  AppMobiCloud
//
//  Created by iOS on 28/12/15.
//
//

#import <Foundation/Foundation.h>

@interface AMSecureController : NSObject

-(void) syncSecureData;
-(void) saveSecureData:(NSString *)strData withKey:(NSString*)key isMasterData:(NSString*)isMasterData withSaveToServer:(NSString*)saveToServer isJSON:(BOOL)isJSON;
-(void) readSecureDataWithKey:(NSString*)key isMaster:(NSString*)isMaster;

@end
