
#import <Foundation/Foundation.h>

@interface AMPushNotification: NSObject 

@property (nonatomic) int ident;
@property (nonatomic, retain) NSString *userkey;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *secureMessage;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *target;
@property (nonatomic, retain) NSString *richurl;
@property (nonatomic, retain) NSString *richhtml;
@property (nonatomic) BOOL isrich;
@property (nonatomic) BOOL hidden;

@end