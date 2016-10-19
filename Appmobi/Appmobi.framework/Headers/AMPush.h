//
//  AMPush.h
//  Appmobi
//
//  Created by iOS on 14/12/15.
//  Copyright © 2015 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AMPushAttribute;

@interface AMPush : NSObject

-(void) checkPushUser:(NSString*)user withPassword:(NSString*)password;
-(void) addPushUser:(NSString*)user withPassword:(NSString*)password withEmail:(NSString*)email;
-(void) readPushNotifications:(NSString*)notificationID;
-(void) findPushUser:(NSString*)user withEmail:(NSString*)email;
-(void) editPushUser:(NSString*)email withPassword:(NSString*)password;
-(void) editPushUser:(NSString*)email withPassword:(NSString*)password withNewUser:(NSString*)newUser;
-(void) refreshPushNotifications;
-(void) refreshUserPushNotificationsWithUser:(NSString*)user withPassword:(NSString*)password withDevice:(NSString*)device withNewerThan:(NSString*)newerThan;
-(void) sendPushNotificationWithUser:(NSString*)user withMessage:(NSString*)message withData:(NSString*)data;
-(void) sendPushUserPass;
-(void) deletePushUser;
-(void) setPushUserAttributes:(AMPushAttribute *)attribute;

#pragma mark - Push events
- (void) registerForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void) receiveRemoteNotification:(NSDictionary *)userInfo withApplicationState:(UIApplicationState)applicationState;

@end
