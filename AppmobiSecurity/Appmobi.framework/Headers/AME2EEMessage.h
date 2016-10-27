//
//  AME2EEMessage.h
//  AppMobiCloud
//
//  Created by iOS on 02/06/16.
//
//

#import <Foundation/Foundation.h>

@interface AME2EEMessage : NSObject

@property (nonatomic, strong) NSString *senderdeviceid;
@property (nonatomic, strong) NSString *sentdate;
@property (nonatomic, strong) NSString *aeskey;
@property (nonatomic, strong) NSString *signature;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *fileID;
@property (nonatomic, strong) NSString *fileName;

@end
