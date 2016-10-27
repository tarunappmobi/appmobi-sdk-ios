//
//  Appmobi.h
//  Appmobi
//
//  Created by iOS on 14/12/15.
//  Copyright © 2015 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMPush.h"
#import "AMSecureController.h"
#import "AMSecureData.h"
#import "AMPushNotification.h"
#import "AMPushAttribute.h"
#import "AMEventDelegate.h"
#import "AME2EE.h"
#import "AME2EEMessage.h"

#define kAppmobiInitialize @"appMobi.initialize"

#define kCheckPushUserCB @"appMobi.notification.push.enable"
#define kAddPushUserCB @"appMobi.notification.push.enable"
#define kReadPushNotificationCB @"appMobi.notification.push.delete"
#define kPushNotificationReceiveCB @"appMobi.notification.push.receive"
#define kPushAttributeCB @"appMobi.notification.push.user.editattributes"
#define kPushNotificationKey @"AppMobiCloud.notifications"
#define kDeletePushUserCB @"appMobi.notification.push.disable"
#define kEditPushUserCB @"appMobi.notification.push.user.edit"
#define kFindPushUserCB @"appMobi.notification.push.user.find"
#define kRefreshPushNotificationsCB @"appMobi.notification.push.refresh"
#define kSendPushNotificationCB @"appMobi.notification.push.send"
#define kSendPushUserPasswordCB @"appMobi.notification.push.sendpassword"

#define kSecureDataSaveCB @"appMobi.securedata.save"
#define kSecureDataReadCB @"appMobi.securedata.read"
#define kSecureDataSyncCB @"appMobi.securedata.sync"
#define kSecureDataKey @"AppMobiCloud.securedData"

#define kUserInputCB @"appMobi.user.input"
#define kOAuthProvidersKey @"AppMobiCloud.OAuth.providers"

#define kAppInactive @"appMobi.app.inactive"

#define kProtectionEnableCB @"appmobi.protection.action"

#define kE2EERefreshUsers @"appMobi.e2ee.refreshUsers"
#define kE2EEGetUsers @"appMobi.e2ee.getUsers"
#define kE2EESendFile @"appMobi.e2ee.sendFile"
#define kE2EEGetAllData @"appMobi.e2ee.getAlldata"
#define kE2EESendMessage @"appMobi.e2ee.sendMessage"
#define kE2EEGetFile @"appMobi.e2ee.getFile"

@interface Appmobi : NSObject

typedef enum oauthProviders
{
    GOOGLE,
    FACEBOOK
} Providers;

@property (nonatomic, strong) AMPush* notification;
@property (nonatomic, strong) AMSecureController *cloudSecure;
@property (nonatomic, strong) AME2EE *amE2EE;

//Appmobi Initialize method returning Appmobi class object
+(Appmobi*) INIT;
//Parameters required
//Appname : Name of the application
//Project ID : Project ID of the application
//Config URL : Config URL of the application
//ldapUser : If Level 3 security and LDAP is selected, provide LDAP User ID
//ldapPassword : If Level 3 security and LDAP is selected, provide LDAP Password
-(void) initializeApp:(NSString*)appname withProjectID:(NSString*)projectID withConfigURL:(NSString*)configURL withLDAPUsername:(NSString*)ldapUser withLDAPPassword:(NSString*)ldapPassword;
//Initialize with Passphrase for security level 4
-(void) initializeWithPassPhrase:(NSString*)passphrase;
//Register OAuth
-(void) registerOAuthWithToken:(NSString*)token withProvider:(Providers)provider;
//Set the Appmobi Event delegate
-(void) setAMEventDelegate:(id)delegate;
//Encrypt/Decrypt custom path
-(void) encryptCustomPath:(BOOL)isEncrypt withPath:(NSString*)path;

@end
