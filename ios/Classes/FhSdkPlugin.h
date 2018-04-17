#import <Flutter/Flutter.h>

extern NSString * const PushMessageReceived;
extern NSString * const PushRegistrationSuccess;
extern NSString * const PushRegistrationError;

extern NSString * const DeviceTokenNotification;

@interface FhSdkPlugin : NSObject<FlutterPlugin>

@property (strong, atomic, readwrite) NSString *alias;
@property (strong, atomic, readwrite) NSArray *categories;

@end
