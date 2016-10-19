
#import <Foundation/Foundation.h>

@interface AppMobiEvent : NSObject {
    NSString *_type;
    NSMutableDictionary *_props;
}

- (id)initWithType:(NSString*)type andProperties:(NSMutableDictionary*)properties;

@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSMutableDictionary *properties;

@end

@protocol AMEventDelegate <NSObject>

- (void)onEventReceived:(AppMobiEvent*)event;

@end
