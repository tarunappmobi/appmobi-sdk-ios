//
//  ViewController.m
//  Appmobi
//
//  Created by iOS on 10/12/15.
//  Copyright © 2015 iOS. All rights reserved.
//

#import "ViewController.h"
#import <Appmobi/Appmobi.h>
#import "AppDelegate.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <GoogleSignIn/GoogleSignIn.h>

@interface ViewController ()<AMEventDelegate, FBSDKLoginButtonDelegate, GIDSignInDelegate, GIDSignInUIDelegate>{
    NSString *amDir;
    NSString *l_filePath;
    NSString *l_fileName;
    NSString *pushUser;
    NSString *pushPwd;
}

@property (nonatomic, strong) Appmobi *appmobi;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) FBSDKLoginButton *loginButton;
@property (strong, nonatomic) IBOutlet GIDSignInButton *signInGoogleButton;
@property (strong, nonatomic) UIView *oauthView;
@property (nonatomic, strong) NSString *deviceId;

@end

@implementation ViewController

@synthesize appmobi = _appmobi;
@synthesize activityView = _activityView;
@synthesize loginButton = _loginButton;
@synthesize signInGoogleButton = _signInGoogleButton;
@synthesize oauthView = _oauthView;
@synthesize deviceId = _deviceId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //Initialize Activity Indicator View
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:_activityView];
    _activityView.color = [UIColor grayColor];
    _activityView.center = self.view.center;
    
    [self initLibrary];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init Appmobi

- (void) initLibrary{
    //Start activity indicator
    [_activityView setHidden:NO];
    [_activityView startAnimating];
    
    self.appmobi = [Appmobi INIT];
    [_appmobi setAMEventDelegate:self];
}

#pragma mark - Event delegate

- (void)onEventReceived:(AppMobiEvent*)event{
    NSLog(@"Type : %@",event.type);
    //Ignore the app inactive event and disable activity indicator on all other event delegates
    if (![event.type isEqualToString:kAppInactive]) {
            [_activityView setHidden:YES];
            [_activityView stopAnimating];
    }
    
    if ([event.type isEqualToString:kAppmobiInitialize]){
        //[self showAlert:[event.properties objectForKey:@"message"]];
        NSLog(@"Message : %@",[event.properties objectForKey:@"message"]);
        BOOL success = [[event.properties objectForKey:@"success"] boolValue];
        if (success) {
            self.deviceId = [[event.properties objectForKey:@"deviceId"] copy];
        }
        NSString *str = [event.properties objectForKey:@"message"];
        if (str)
            [self showAlert:str];
    }
    else if ([event.type isEqualToString:kCheckPushUserCB]) {
        BOOL success = [[event.properties objectForKey:@"success"] boolValue];
        NSString *didAddPushUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"didAddPushUser"];
        if (!success) {
            if (!didAddPushUser) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"didAddPushUser"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //Start activity indicator
                [_activityView setHidden:NO];
                [_activityView startAnimating];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    AMPush *notification = [_appmobi notification];
                    [notification addPushUser:pushUser withPassword:pushPwd withEmail:[NSString stringWithFormat:@"%@%@",pushUser,@"@appmobi.com"]];
                });
            }
            else{
                NSString *str = [event.properties objectForKey:@"message"];
                if (str)
                    [self showAlert:str];
            }
        }
        else{
            NSString *str = [event.properties objectForKey:@"message"];
            if (str)
                [self showAlert:str];
        }
        
    }
    else if ([event.type isEqualToString:kPushNotificationReceiveCB]){
        NSArray *pushNotifications = [NSArray arrayWithArray:[event.properties objectForKey:kPushNotificationKey]];
        NSString *notificationIDs = @"";
        int count = 0;
        for (AMPushNotification *notification in pushNotifications) {
            NSLog(@"Message : %@", notification.message);
            NSLog(@"SecureMessage : %@", notification.secureMessage);
            [self showMessages:[NSString stringWithFormat:@"Message : %@ \n Secure Message : %@",notification.message,notification.secureMessage]];
            if (count==0)
                notificationIDs = [notificationIDs stringByAppendingString:[NSString stringWithFormat:@"%d",notification.ident]];
            else
                notificationIDs = [notificationIDs stringByAppendingString:[NSString stringWithFormat:@"|%d",notification.ident]];
            count++;
        }
        AMPush *notification = [_appmobi notification];
        [notification readPushNotifications:notificationIDs];
    }
    else if ([event.type isEqualToString:kSecureDataReadCB]){
        NSArray *arr = [event.properties objectForKey:kSecureDataKey];
        if ([arr count]) {
            for (AMSecureData *data in arr) {
                NSLog(@"Key/Data : %@/%@", data.key,data.value);
                
                NSError *error;
                [NSJSONSerialization JSONObjectWithData:[data.value dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
                if(error){
                    NSLog(@"Not a JSON object");
                }
                else{
                    NSLog(@"Is a JSON object");
                }
                
                NSString *str = [NSString stringWithFormat:@"Key/Value : %@/%@",data.key,data.value];
                if (str)
                    [self showSecureMessages:str];
            }
        }
        else{
            [self showAlert:[event.properties objectForKey:@"message"]];
        }
    }
    else if ([event.type isEqualToString:kSecureDataSaveCB]){
        BOOL success = [[event.properties objectForKey:@"success"] boolValue];
        if (success) {
            [self showAlert:[NSString stringWithFormat:@"Secure data saved : %@/%@",[event.properties objectForKey:@"key"],[event.properties objectForKey:@"value"]]];
        }
        else
            [self showAlert:[event.properties objectForKey:@"message"]];
    }
    else if ([event.type isEqualToString:kSecureDataSyncCB]){
        [self showAlert:[event.properties objectForKey:@"message"]];
    }
    else if ([event.type isEqualToString:kPushAttributeCB]){
        NSLog(@"Message : %@",[event.properties objectForKey:@"message"]);
        NSString *str = [event.properties objectForKey:@"message"];
        if (str)
            [self showAlert:str];
    }
    else if ([event.type isEqualToString:kAppInactive]){
        NSString *msg = [event.properties objectForKey:@"message"];
        NSLog(@"Message : %@",msg);
        BOOL success = [[event.properties objectForKey:@"success"] boolValue];
        if (success) {
            [self disableUIWithMessage:[msg length]?msg:@""];
        }
        else
            [self enableUI];
    }
    else if ([event.type isEqualToString:kUerInputCB]){
        BOOL isOAUTH = [[event.properties objectForKey:@"oauth"] boolValue];
        BOOL isPassphrase = [[event.properties objectForKey:@"passphrase"] boolValue];
        if (isOAUTH) {
            NSArray *providers = [NSArray arrayWithArray:[event.properties objectForKey:kOAuthProvidersKey]];
            
                _oauthView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
                _oauthView.backgroundColor = [UIColor grayColor];
                _oauthView.alpha = 0.9;
                [self.view addSubview:_oauthView];
            
            for (NSDictionary *provider in providers) {
                NSString *oauthProvider = [provider objectForKey:@"provider"];
                if ([oauthProvider isEqualToString:@"facebook"]) {
                        _loginButton = [[FBSDKLoginButton alloc] init];
                        // Optional: Place the button in the center of your view.
                        _loginButton.center = _oauthView.center;
                        _loginButton.delegate = self;
                        _loginButton.readPermissions =
                        @[@"public_profile",@"email"];
                        [_oauthView addSubview:_loginButton];
                }
                else if ([oauthProvider isEqualToString:@"google"]) {
                        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"GoogleService-Info" ofType:@"plist"]];
                        NSString *CLIENT_ID = [dictionary objectForKey:@"CLIENT_ID"];
                        [GIDSignIn sharedInstance].clientID = CLIENT_ID;
                        
                        _signInGoogleButton = [[GIDSignInButton alloc] init];
                        _signInGoogleButton.style = kGIDSignInButtonStyleStandard;
                        _signInGoogleButton.colorScheme = kGIDSignInButtonColorSchemeDark;
                        _signInGoogleButton.center = CGPointMake(_oauthView.center.x, _oauthView.center.y + 70);
                        [_oauthView addSubview:_signInGoogleButton];
                        [GIDSignIn sharedInstance].uiDelegate = self; //Google OAuth
                        [GIDSignIn sharedInstance].delegate = self; //Google OAuth
                }
            }
            //[self showAlert:@"OAuth currently not available"];
            NSLog(@"OAuth selected");
        }
        else if (isPassphrase){
            NSString *msg = [event.properties objectForKey:@"message"];
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Appmobi"
                                                  message:msg?msg:@"Passphrase"
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
             {
                 textField.placeholder = @"Passphrase";
             }];
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:@"OK"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           UITextField *txtPassphrase = alertController.textFields.firstObject;
                                           if ([txtPassphrase.text length]) {
                                               //Start activity indicator
                                               [_activityView setHidden:NO];
                                               [_activityView startAnimating];
                                               
                                               [_appmobi initializeWithPassPhrase:txtPassphrase.text];
                                           }
                                           else
                                               [self showAlert:@"Please fill all details"];
                                           
                                       }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
            [self performSelector:@selector(authenticateViaLDAP) withObject:nil afterDelay:3];
            NSLog(@"LDAP selected");
        }
    }
    else if ([event.type isEqualToString:kReadPushNotificationCB]){
        NSLog(@"%@",[event.properties objectForKey:@"message"]);
        NSString *str = [event.properties objectForKey:@"message"];
        if (str)
            [self showAlert:str];
    }
    else if ([event.type isEqualToString:kDeletePushUserCB]){
        NSLog(@"%@",[event.properties objectForKey:@"message"]);
        NSString *str = [event.properties objectForKey:@"message"];
        if (str)
            [self showAlert:str];
    }
    else if ([event.type isEqualToString:kEditPushUserCB]){
        NSLog(@"%@",[event.properties objectForKey:@"message"]);
        NSString *str = [event.properties objectForKey:@"message"];
        if (str)
            [self showAlert:str];
    }
    else if ([event.type isEqualToString:kFindPushUserCB]){
        NSLog(@"%@",[event.properties objectForKey:@"message"]);
        NSString *str = [event.properties objectForKey:@"message"];
        if (str)
            [self showAlert:str];
    }
    else if ([event.type isEqualToString:kRefreshPushNotificationsCB]){
        NSLog(@"%@",[event.properties objectForKey:@"message"]);
        NSString *str = [event.properties objectForKey:@"message"];
        if (str)
            [self showAlert:str];
    }
    else if ([event.type isEqualToString:kSendPushNotificationCB]){
        NSLog(@"%@",[event.properties objectForKey:@"message"]);
        NSString *str = [event.properties objectForKey:@"message"];
        if (str)
            [self showAlert:str];
    }
    else if ([event.type isEqualToString:kSendPushUserPasswordCB]){
        NSLog(@"%@",[event.properties objectForKey:@"message"]);
        NSString *str = [event.properties objectForKey:@"message"];
        if (str)
            [self showAlert:str];
    }
    else if ([event.type isEqualToString:kProtectionEnableCB]){
        NSString *msg = [event.properties objectForKey:@"message"];
        NSLog(@"Message : %@",msg);
        BOOL success = [[event.properties objectForKey:@"success"] boolValue];
        if (success) {
            [self disableUIWithMessage:[msg length]?msg:@""];
        }
        else
            [self enableUI];
    }
    else if ([event.type isEqualToString:kE2EERefreshUsers]){
        NSString *msg = [event.properties objectForKey:@"message"];
        NSLog(@"Message : %@",msg);
        [self showAlert:msg];
    }
    else if ([event.type isEqualToString:kE2EEGetUsers]){
        NSLog(@"%@",[event.properties objectForKey:@"message"]);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"E2EE"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        NSArray *deviceIds = (NSArray*)[event.properties objectForKey:@"users"];
        for (NSString *deviceId in deviceIds) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:deviceId
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
                                                               NSString *l_deviceId = action.title;
                                                               [self sendE2EE:l_deviceId];
                                                           }];
            [alertController addAction:action];
        }
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action) {
                                                             }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else if ([event.type isEqualToString:kE2EEGetAllData]){
        NSString *msg = [event.properties objectForKey:@"message"];
        NSLog(@"Message : %@",msg);
        NSArray *messages = [event.properties objectForKey:@"messages"];
        if ([messages count]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"E2EE"
                                                                                     message:nil
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            for (AME2EEMessage *message in messages) {
                if ([message.fileName length]) {
                    UIAlertAction *action = [UIAlertAction actionWithTitle:message.fileName
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction *action) {
                                                                       AME2EE *amE2EE = [_appmobi amE2EE];
                                                                       [amE2EE getFileWithFileId:message.fileID];
                                                                   }];
                    [alertController addAction:action];
                }
                else{
                    UIAlertAction *action = [UIAlertAction actionWithTitle:message.message
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction *action) {
                                                                       
                                                                   }];
                    action.enabled = NO;
                    [alertController addAction:action];
                }
            }
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction *action) {
                                                                 }];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
            [self showAlert:@"No messages available"];
    }
    else if ([event.type isEqualToString:kE2EEGetFile]){
        NSString *msg = [event.properties objectForKey:@"message"];
        NSLog(@"Message : %@",msg);
        [self showAlert:msg];
    }
    else{
        NSString *str = [event.properties objectForKey:@"message"];
        if (str)
            [self showAlert:str];
    }
}

#pragma mark - IB Actions

- (IBAction)checkPushUser:(id)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Appmobi"
                                          message:@"Check Push User"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Push User Name";
     }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Push User Password";
         textField.secureTextEntry = YES;
     }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *txtPushUser = alertController.textFields.firstObject;
                                   UITextField *txtPushPassword = alertController.textFields.lastObject;
                                   if ([txtPushUser.text length]&&[txtPushPassword.text length]) {
                                       //Start activity indicator
                                       [_activityView setHidden:NO];
                                       [_activityView startAnimating];
                                       
                                       pushUser = [txtPushUser.text copy];
                                       pushPwd = [txtPushPassword.text copy];
                                       
                                       AMPush *notification = [_appmobi notification];
                                       [notification checkPushUser:txtPushUser.text withPassword:txtPushPassword.text];
                                   }
                                   else
                                       [self showAlert:@"Please fill all details"];
                                   
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

- (IBAction)addPushUser:(id)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Appmobi"
                                          message:@"Add Push User"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Push User Name";
     }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Push User Password";
         textField.secureTextEntry = YES;
     }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Push User Email";
     }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *txtPushUser = alertController.textFields.firstObject;
                                   UITextField *txtPushPassword = [alertController.textFields objectAtIndex:1];
                                   UITextField *txtPushEmail = alertController.textFields.lastObject;
                                   if ([txtPushUser.text length]&&[txtPushPassword.text length]&&[txtPushEmail.text length]) {
                                       //Start activity indicator
                                       [_activityView setHidden:NO];
                                       [_activityView startAnimating];
                                       
                                       AMPush *notification = [_appmobi notification];
                                       [notification addPushUser:txtPushUser.text withPassword:txtPushPassword.text withEmail:txtPushEmail.text];
                                   }
                                   else
                                       [self showAlert:@"Please fill all details"];
                                   
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (IBAction)refreshPushNotifications:(id)sender {
    //Start activity indicator
    [_activityView setHidden:NO];
    [_activityView startAnimating];
    
    AMPush *notification = [_appmobi notification];
    [notification refreshPushNotifications];
}

- (IBAction)sendPushNotifications:(id)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Appmobi"
                                          message:@"Send Push Notification"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Push User Name";
     }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Push Message";
     }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Secure Push Message";
     }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *txtUser = alertController.textFields.firstObject;
                                   UITextField *txtMessage = [alertController.textFields objectAtIndex:1];
                                   UITextField *txtData = alertController.textFields.lastObject;
                                   if ([txtUser.text length]&&[txtMessage.text length]&&[txtData.text length]) {
                                       //Start activity indicator
                                       [_activityView setHidden:NO];
                                       [_activityView startAnimating];
                                       
                                       AMPush *notification = [_appmobi notification];
                                       [notification sendPushNotificationWithUser:txtUser.text withMessage:txtMessage.text withData:txtData.text];
                                   }
                                   else
                                       [self showAlert:@"Please fill all details"];
                                   
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (IBAction)findPushUser:(id)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Appmobi"
                                          message:@"Find Push User"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Push User Name";
     }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Push User Email";
     }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *txtPushUser = alertController.textFields.firstObject;
                                   UITextField *txtPushEmail = alertController.textFields.lastObject;
                                   if ([txtPushUser.text length]&&[txtPushEmail.text length]) {
                                       //Start activity indicator
                                       [_activityView setHidden:NO];
                                       [_activityView startAnimating];
                                       
                                       AMPush *notification = [_appmobi notification];
                                       [notification findPushUser:txtPushUser.text withEmail:txtPushEmail.text];
                                   }
                                   else
                                       [self showAlert:@"Please fill all details"];
                                   
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (IBAction)editPushUser:(id)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Appmobi"
                                          message:@"Find Push User"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Push User Email";
     }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Push User Password";
     }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *txtPushEmail = alertController.textFields.firstObject;
                                   UITextField *txtPushPwd = alertController.textFields.lastObject;
                                   if ([txtPushPwd.text length]&&[txtPushEmail.text length]) {
                                       //Start activity indicator
                                       [_activityView setHidden:NO];
                                       [_activityView startAnimating];
                                       
                                       AMPush *notification = [_appmobi notification];
                                       [notification editPushUser:txtPushEmail.text withPassword:txtPushPwd.text];
                                   }
                                   else
                                       [self showAlert:@"Please fill all details"];
                                   
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (IBAction)deletePushUser:(id)sender {
    //Start activity indicator
    [_activityView setHidden:NO];
    [_activityView startAnimating];
    
    AMPush *notification = [_appmobi notification];
    [notification deletePushUser];
}

- (IBAction)sendPushUserPassword:(id)sender {
    //Start activity indicator
    [_activityView setHidden:NO];
    [_activityView startAnimating];
    
    AMPush *notification = [_appmobi notification];
    [notification sendPushUserPass];
}

- (IBAction)setPushAttributes:(id)sender{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Appmobi"
                                          message:@"Add Push User"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"S1";
         [textField setKeyboardType:UIKeyboardTypeDefault];
     }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"S2";
         [textField setKeyboardType:UIKeyboardTypeDefault];
     }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"N1";
         [textField setKeyboardType:UIKeyboardTypeNumberPad];
     }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *txtS1 = alertController.textFields.firstObject;
                                   UITextField *txtS2 = [alertController.textFields objectAtIndex:1];
                                   UITextField *txtN1 = alertController.textFields.lastObject;
                                   if ([txtS1.text length]&&[txtS2.text length]&&[txtN1.text length]) {
                                       //Start activity indicator
                                       [_activityView setHidden:NO];
                                       [_activityView startAnimating];
                                       
                                       AMPushAttribute *attribute = [[AMPushAttribute alloc] init];
                                       attribute.s1 = txtS1.text;
                                       attribute.s2 = txtS2.text;
                                       attribute.n1 = [txtN1.text intValue];
                                       AMPush *notification = [_appmobi notification];
                                       [notification setPushUserAttributes:attribute];
                                   }
                                   else
                                       [self showAlert:@"Please fill all details"];
                                   
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(IBAction)saveSecureData:(id)sender{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Appmobi"
                                          message:@"Save Secure Data"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Secure Data Value";
         [textField setKeyboardType:UIKeyboardTypeDefault];
     }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Secure data Key";
         [textField setKeyboardType:UIKeyboardTypeDefault];
     }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Secure Data Is Master";
         [textField setKeyboardType:UIKeyboardTypeNumberPad];
     }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Secure Data Is Sync to Server";
         [textField setKeyboardType:UIKeyboardTypeNumberPad];
     }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Secure Data Is JSON";
         [textField setKeyboardType:UIKeyboardTypeNumberPad];
     }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *txtData = alertController.textFields.firstObject;
                                   UITextField *txtKey = [alertController.textFields objectAtIndex:1];
                                   UITextField *txtIsMaster = [alertController.textFields objectAtIndex:2];
                                   UITextField *txtIsSync = [alertController.textFields objectAtIndex:3];
                                   UITextField *txtIsJSON = alertController.textFields.lastObject;
                                   if ([txtData.text length]&&[txtKey.text length]&&[txtIsMaster.text length]&&[txtIsSync.text length]&&[txtIsJSON.text length]) {
                                       //Start activity indicator
                                       [_activityView setHidden:NO];
                                       [_activityView startAnimating];
                                       
                                       AMSecureController *secureCtrl = [_appmobi cloudSecure];
                                       BOOL isJSON = NO;
                                       if ([txtIsJSON.text isEqualToString:@"1"]) {
                                           isJSON = YES;
                                       }
                                       [secureCtrl saveSecureData:txtData.text withKey:txtKey.text isMasterData:txtIsMaster.text withSaveToServer:txtIsSync.text isJSON:isJSON];
                                   }
                                   else
                                       [self showAlert:@"Please fill all details"];
                                   
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(IBAction)readSecureData:(id)sender{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Appmobi"
                                          message:@"Read Secure Data"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Secure Data Key";
     }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Secure Data Is Master";
     }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *txtKey = alertController.textFields.firstObject;
                                   UITextField *txtIsMaster = alertController.textFields.lastObject;
                                   if ([txtKey.text length]&&[txtIsMaster.text length]) {
                                       //Start activity indicator
                                       [_activityView setHidden:NO];
                                       [_activityView startAnimating];
                                       
                                       AMSecureController *secureCtrl = [_appmobi cloudSecure];
                                       [secureCtrl readSecureDataWithKey:txtKey.text isMaster:txtIsMaster.text];
                                   }
                                   else
                                       [self showAlert:@"Please fill all details"];
                                   
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(IBAction)syncSecureData:(id)sender{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Appmobi"
                                          message:@"Sync Secure Data"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Secure Data Is Master";
     }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *txtIsMaster = alertController.textFields.firstObject;
                                   if ([txtIsMaster.text length]) {
                                       //Start activity indicator
                                       [_activityView setHidden:NO];
                                       [_activityView startAnimating];
                                       
                                       AMSecureController *secureCtrl = [_appmobi cloudSecure];
                                       [secureCtrl syncSecureData];
                                   }
                                   else
                                       [self showAlert:@"Please fill all details"];
                                   
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(IBAction) createPath:(id)sender{
    NSDictionary *dict = [self createFilePath];
    if ([[dict objectForKey:@"dirPath"] length]) {
        amDir = [dict objectForKey:@"dirPath"];
        l_filePath = [dict objectForKey:@"filePath"];
        l_fileName = [dict objectForKey:@"filename"];
        [self showAlert:[NSString stringWithFormat:@"File - %@ created successfully",[dict objectForKey:@"filename"]]];
    }
}

-(IBAction) encryptPath:(id)sender{
    Appmobi *appmobi = [Appmobi INIT];
    if ([amDir length]) {
        //Start activity indicator
        [_activityView setHidden:NO];
        [_activityView startAnimating];
        
        [appmobi encryptCustomPath:YES withPath:amDir];
    }
    else{
        [self showAlert:@"Please provide valid path"];
    }
}

-(IBAction) decryptPath:(id)sender{
    Appmobi *appmobi = [Appmobi INIT];
    if ([amDir length]) {
        //Start activity indicator
        [_activityView setHidden:NO];
        [_activityView startAnimating];
        
        [appmobi encryptCustomPath:NO withPath:amDir];
    }
    else{
        [self showAlert:@"Please provide valid path"];
    }
}

-(IBAction) refreshE2EEUsers:(id)sender{
    //Start activity indicator
    [_activityView setHidden:NO];
    [_activityView startAnimating];
    
    AME2EE *amE2EE = [_appmobi amE2EE];
    [amE2EE refreshE2EEUsers];
}

-(IBAction) getE2EEUsers:(id)sender{
    //Start activity indicator
    [_activityView setHidden:NO];
    [_activityView startAnimating];
    
    AME2EE *amE2EE = [_appmobi amE2EE];
    [amE2EE getE2EEUsers];
}

-(IBAction) getAllE2EEData:(id)sender{
    //Start activity indicator
    [_activityView setHidden:NO];
    [_activityView startAnimating];
    
    AME2EE *amE2EE = [_appmobi amE2EE];
    [amE2EE getAllE2EEData];
}

-(IBAction) getDeviceId:(id)sender{
    //Start activity indicator
    if ([_deviceId length]) {
        [self showAlert:_deviceId];
    }
    else
        [self showAlert:@"DeviceId not available"];
}

#pragma mark - LDAP

-(void) authenticateViaLDAP{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[self presentedViewController] isKindOfClass:[UIAlertController class]]) {
            [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
        }
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Appmobi"
                                              message:@"LDAP"
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             textField.placeholder = @"LDAP UserName";
         }];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             textField.placeholder = @"LDAP Password";
             textField.text = @"DhRFspH49DamcvwJ4RKB";
             textField.secureTextEntry = YES;
         }];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       UITextField *txtLDAPUser = alertController.textFields.firstObject;
                                       UITextField *txtLDAPPassword = alertController.textFields.lastObject;
                                       if ([txtLDAPUser.text length]&&[txtLDAPPassword.text length]) {
                                           //Start activity indicator
                                           [_activityView setHidden:NO];
                                           [_activityView startAnimating];
                                           
                                           Appmobi *appmobi = [Appmobi INIT];
                                           [appmobi initializeApp:kAppname withProjectID:kProjectID withConfigURL:kConfigURL withLDAPUsername:txtLDAPUser.text withLDAPPassword:txtLDAPPassword.text];
                                       }
                                       
                                   }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

#pragma mark - Show Secure Messages

-(void) showSecureMessages:(NSString*)msg{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[self presentedViewController] isKindOfClass:[UIAlertController class]]) {
            UIAlertController *lAlertCtrl = (UIAlertController*)[self presentedViewController];
            lAlertCtrl.message = [lAlertCtrl.message stringByAppendingString:[NSString stringWithFormat:@" \n ----------- \n %@",msg]];
        }
        else{
            UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"Appmobi" message:msg preferredStyle:UIAlertControllerStyleAlert];
            alertCtrl.view.tag = 100002;
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:@"OK"
                                           style:UIAlertActionStyleCancel
                                           handler:nil];
            [alertCtrl addAction:cancelAction];
            [self presentViewController:alertCtrl animated:YES completion:nil];
        }
    });
    
#else
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Appmobi" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
#endif
}

#pragma mark - Show Notifications

-(void) showMessages:(NSString*)msg{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[self presentedViewController] isKindOfClass:[UIAlertController class]]) {
            UIAlertController *lAlertCtrl = (UIAlertController*)[self presentedViewController];
            lAlertCtrl.message = [lAlertCtrl.message stringByAppendingString:[NSString stringWithFormat:@" \n ----------- \n %@",msg]];
        }
        else{
            UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"Appmobi" message:msg preferredStyle:UIAlertControllerStyleAlert];
            alertCtrl.view.tag = 100002;
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:@"OK"
                                           style:UIAlertActionStyleCancel
                                           handler:nil];
            [alertCtrl addAction:cancelAction];
            [self presentViewController:alertCtrl animated:YES completion:nil];
        }
    });
    
#else
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Appmobi" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
#endif
}

#pragma mark - Alert

-(void) showAlert:(NSString*)msg{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([[self presentedViewController] isKindOfClass:[UIAlertController class]]) {
            if ([[[self presentedViewController] view] tag]==100002) {
                UIAlertController *lAlertCtrl = (UIAlertController*)[self presentedViewController];
                lAlertCtrl.message = [lAlertCtrl.message stringByAppendingString:[NSString stringWithFormat:@" \n ----------- \n %@",msg]];
                return ;
            }
            else{
                [[self presentedViewController] dismissViewControllerAnimated:NO completion:nil];
            }
        }
        
        UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"Appmobi" message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:@"OK"
                                       style:UIAlertActionStyleCancel
                                       handler:nil];
        [alertCtrl addAction:cancelAction];
        [self presentViewController:alertCtrl animated:YES completion:nil];
        
    });

#else
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Appmobi" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
#endif
}

#pragma mark DisableUI

-(void) disableUIWithMessage:(NSString*)message{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x+30, self.view.frame.origin.y+30, self.view.frame.size.width-60, self.view.frame.size.height-60)];
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 50)];
        lbl.center = CGPointMake(blackView.center.x - 40, blackView.center.y - 40);
        lbl.text = message;
        [lbl setTextColor:[UIColor whiteColor]];
        lbl.numberOfLines = 0;
        lbl.textAlignment = NSTextAlignmentCenter;
        [lbl setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
        blackView.alpha = 0.7;
        [blackView setBackgroundColor:[UIColor blackColor]];
        blackView.tag = 100001;
        [blackView addSubview:lbl];
        self.view.userInteractionEnabled = NO;
        [[[UIApplication sharedApplication] keyWindow] addSubview:blackView];
    });
}

-(void) enableUI{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *blackView = (UIView*)[[[UIApplication sharedApplication] keyWindow] viewWithTag:100001];
        self.view.userInteractionEnabled = YES;
        [blackView removeFromSuperview];
    });
}

#pragma mark - E2EE SendM Message/File

-(void) sendE2EE:(NSString*)deviceId{
    if ([[self presentedViewController] isKindOfClass:[UIAlertController class]]) {
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"E2EE"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Message";
     }];

    UIAlertAction *messageAction = [UIAlertAction actionWithTitle:@"Send Message"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       UITextField *txtMessage = alertController.textFields.firstObject;
                                                       if ([txtMessage.text length]) {
                                                           //Start activity indicator
                                                           [_activityView setHidden:NO];
                                                           [_activityView startAnimating];
                                                           
                                                           AME2EE *amE2EE = [_appmobi amE2EE];
                                                           [amE2EE sendEncryptedMessage:txtMessage.text withDeviceID:deviceId];
                                                       }
                                                       else
                                                           [self showAlert:@"Please type message to send"];
                                                       
                                                   }];
    [alertController addAction:messageAction];
    
    UIAlertAction *fileAction = [UIAlertAction actionWithTitle:@"Send File"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              if ([l_filePath length]) {
                                                                  //Start activity indicator
                                                                  [_activityView setHidden:NO];
                                                                  [_activityView startAnimating];
                                                                  
                                                                  AME2EE *amE2EE = [_appmobi amE2EE];
                                                                  
                                                                      [amE2EE sendEncryptedFileWithDeviceID:deviceId WithPath:l_filePath];
                                                              }
                                                              else{
                                                                  [self showAlert:@"Please create path first"];
                                                              }
                                                              
                                                          }];
    [alertController addAction:fileAction];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                         }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Create Path

-(NSDictionary*) createFilePath{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *amDir1 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"AM"];
    
    int length = 10;
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    for (int i=0; i<length; i++) {
        NSUInteger index = arc4random_uniform((uint32_t)[letters length]);
        [randomString appendFormat: @"%C", [letters characterAtIndex: index]];
    }
    //make a file name to write the data to using the documents directory:
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.txt",
                          amDir1,randomString];
    
    //create content - four lines of text
    NSString *content = @"One\nTwo\nThree\nFour\nFive";
    NSError *err;
    [[NSFileManager defaultManager] createDirectoryAtPath:amDir1
                              withIntermediateDirectories:NO
                                               attributes:nil
                                                    error:&err];
    [content writeToFile:filePath
              atomically:NO
                encoding:NSStringEncodingConversionAllowLossy
                   error:&err];
    return [NSDictionary dictionaryWithObjectsAndKeys:amDir1,@"dirPath",randomString,@"filename", filePath, @"filePath", nil];
}

#pragma mark - Facebook Delegate

- (void)  loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
                error:(NSError *)error{
    if ([FBSDKAccessToken currentAccessToken]) {
        _oauthView.hidden = YES;
        // User is logged in, do work such as go to next view controller.
        FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
        
        //Start activity indicator
        [_activityView setHidden:NO];
        [_activityView startAnimating];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            Appmobi *appmobi = [Appmobi INIT];
            [appmobi registerOAuthWithToken:token.tokenString withProvider:FACEBOOK];
        });
    }
}

/*!
 @abstract Sent to the delegate when the button was used to logout.
 @param loginButton The button that was clicked.
 */
- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
}

#pragma mark - Google Delegate

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    NSString *accessToken = user.authentication.accessToken; // Safe to send to the server
    if ([accessToken length]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            Appmobi *appmobi = [Appmobi INIT];
            [appmobi registerOAuthWithToken:accessToken withProvider:GOOGLE];
        });
    }
    else
        [self showAlert:[error localizedDescription]];
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    // ...
}

// The sign-in flow has finished selecting how to proceed, and the UI should no longer display
// a spinner or other "please wait" element.
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error{
    NSLog(@"signInWillDispatch");
    _oauthView.hidden = YES;
    
    //Start activity indicator
    [_activityView setHidden:NO];
    [_activityView startAnimating];
}

@end
