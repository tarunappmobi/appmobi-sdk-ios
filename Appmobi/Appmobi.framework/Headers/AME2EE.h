//
//  AME2EE.h
//  Appmobi
//
//  Created by iOS on 06/10/16.
//  Copyright © 2016 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AME2EE : NSObject

-(void) refreshE2EEUsers;
-(void) getE2EEUsers;
-(void) sendEncryptedFileWithDeviceID:(NSString*)deviceID WithPath:(NSString*)path;
-(void) getAllE2EEData;
-(void) sendEncryptedMessage:(NSString*)message withDeviceID:(NSString*)deviceID;
-(void) getFileWithFileId:(NSString*)fileId;

@end
