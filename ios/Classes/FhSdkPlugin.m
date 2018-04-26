#import "FhSdkPlugin.h"

#import <Flutter/Flutter.h>

#import <FH/FH.h>
#import <FH/FHResponse.h>

NSString * const PushMessageReceived = @"push_message_received";
NSString * const PushRegistrationSuccess = @"push_registration_success";
NSString * const PushRegistrationError = @"push_registration_error";

NSString * const DeviceTokenNotification = @"DeviceTokenNotification";

@interface FhSdkPlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FhSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"fh_sdk"
      binaryMessenger:[registrar messenger]];
  FhSdkPlugin* instance = [[FhSdkPlugin alloc] init];
  instance.channel = channel;
  [registrar addMethodCallDelegate: instance channel: channel];
}

// Remove the observer once the instance is deallocated.
- (void)dealloc {
    //[self.channel setMethodCallHandler:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  // FH.init()
  if ([@"init" isEqualToString:call.method]) {
    [self handleInitCall: result];
  }
  // FH.cloudHost()
  else if ([@"getCloudUrl" isEqualToString:call.method]) {
      [self handleGetCloudUrlCall: result];
  }
  // FH.cloud()
  else if ([@"cloud" isEqualToString:call.method]) {
    [self handleCloudCall: call result: result];
  }
  // FH.auth()
  else if ([@"auth" isEqualToString:call.method]) {
    [self handleAuthCall: call result: result];
  }
  // FH.pushRegister()
  else if ([@"pushRegister" isEqualToString:call.method]) {
      [self handlePushRegisterCall: call result: result];
  }
  // FH.setPushAlias()
  else if ([@"setPushAlias" isEqualToString:call.method]) {
      [self handleSetPushAliasCall: call result: result];
  }
  // FH.setPushCategories()
  else if ([@"setPushCategories" isEqualToString:call.method]) {
      [self handleSetPushCategoriesCall: call result: result];
  }
  // Else...
  else {
    result(FlutterMethodNotImplemented);
  }
}

-(void)handleInitCall:(FlutterResult)result {
  NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  
  // Call a cloud side function when init finishes
  void (^success)(FHResponse *)=^(FHResponse * res) {
      // Initialisation is now complete, you can now make FHActRequest's
      NSLog(@"SDK init = OK");
      result(@"SUCCESS");
  };
  
  void (^failure)(id)=^(FHResponse * res){
      NSString *errorMessage = [NSString stringWithFormat:@"Error: %@", res.rawResponseAsString];
      NSLog(@"init call exception. Status = %d Response = %@", res.responseStatusCode, errorMessage);
      result([FlutterError errorWithCode:@"INIT_ERROR"
                           message:errorMessage
                           details:res.parsedResponse]);
  };

  [FH initWithSuccess:success AndFailure:failure];
}

-(void)handleGetCloudUrlCall:(FlutterResult)result {
  NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
  @try {
      NSString *cloudAppHost = [FH getCloudHost];
      NSLog(@"getCloudUrl: %@", cloudAppHost);
      result(cloudAppHost);
  }
  @catch ( NSException *e ) {
      NSString *errorMessage = [NSString stringWithFormat:@"Error: %@", [e reason]];
      NSLog(@"getCloudUrl call exception. Response = %@", errorMessage);
      result([FlutterError errorWithCode:@"CLOUDURL_ERROR"
                                 message:errorMessage
                                 details:[e reason]]);
  }
  @finally {
      NSLog(@"getCloudUrl finally area reached");
  }
}

-(void)handleCloudCall: (FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *options = call.arguments;
    
  NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"options: %@", options);
  
  // Call a cloud side function when init finishes
  void (^success)(FHResponse *)=^(FHResponse * res) {
      NSLog(@"cloud call succeded");
      result(res.rawResponseAsString);
  };
  
  void (^failure)(id)=^(FHResponse * res){
      NSDictionary *details = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [NSNumber numberWithInt:res.responseStatusCode], @"statusCode",
                               res.rawResponseAsString, @"rawResponseAsString", nil];
      NSString *errorMessage = [NSString stringWithFormat:@"Error: %@", res.rawResponseAsString];
      NSLog(@"init call exception. Status = %d Response = %@", res.responseStatusCode, errorMessage);
      result([FlutterError errorWithCode:@"CLOUD_ERROR"
                                 message:errorMessage
                                 details:details]);
  };
  
  @try {
      NSString *path = nil, *method = nil, *contentType = nil;
      NSNumber *timeout = [NSNumber numberWithInteger:25000]; // 25 sec default
      NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
      NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
      if (options && [options valueForKey:@"path"]) path = [options valueForKey:@"path"];
      if (options && [options valueForKey:@"method"]) method = [options valueForKey:@"method"];
      if (options && [options valueForKey:@"contentType"]) {
          contentType = [options valueForKey:@"contentType"];
      } else {
          contentType = @"application/json";
      }
      if (options && [options valueForKey:@"timeout"]) timeout = [options valueForKey:@"timeout"];
      
      if (options && [options valueForKey:@"headers"]) {
          [headers addEntriesFromDictionary: (NSDictionary*)[options valueForKey:@"headers"]];
      }
      [headers setValue:contentType forKey:@"contentType"];
      
      if (options && [options valueForKey:@"data"]) {
          [data addEntriesFromDictionary: (NSDictionary*)[options valueForKey:@"data"]];
      }
      
      FHCloudRequest * action = (FHCloudRequest *) [FH buildCloudRequest:path
                                                              WithMethod:method
                                                              AndHeaders:headers
                                                                  AndArgs:data];
      
      // change timeout (default value: 60s)
      action.requestTimeout = [timeout doubleValue]/1000;
      [action execAsyncWithSuccess: success AndFailure: failure];
  }
  @catch ( NSException *e ) {
      NSString *errorMessage = [NSString stringWithFormat:@"Error: %@", [e reason]];
      NSLog(@"cloud call exception. Response = %@", errorMessage);
      result([FlutterError errorWithCode:@"CLOUD_ERROR"
                                message:errorMessage
                                details:nil]);
  }
  @finally {
      NSLog(@"finally area reached");
  }
}

-(void)handleAuthCall: (FlutterMethodCall*)call result:(FlutterResult)result {
    NSLog(@"auth call with promise %@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSDictionary *options = call.arguments;
    
    NSString *authPolicy = [options valueForKey:@"authPolicy"];
    NSString *username = [options valueForKey:@"username"];
    NSString *password = [options valueForKey:@"password"];
    
    // Call a cloud side function when init finishes
    void (^success)(FHResponse *)=^(FHResponse * res) {
        NSLog(@"auth call succeded check status");
        NSLog(@"parsed response %@ type=%@",res.parsedResponse,[res.parsedResponse class]);
        if ([res responseStatusCode] != 200) {
            NSDictionary *details = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     [NSNumber numberWithInt:res.responseStatusCode], @"statusCode",
                                     res.rawResponseAsString, @"rawResponseAsString", nil];
            NSString *errorMessage = [NSString stringWithFormat:@"Error: %@", res.rawResponseAsString];
            NSLog(@"auth call authentication failed. Status = %d Response = %@", res.responseStatusCode, errorMessage);
            result([FlutterError errorWithCode:@"AUTH_ERROR"
                                       message:errorMessage
                                       details:details]);
            
        } else {
            NSLog(@"auth call authentication succeded");
            result(res.rawResponseAsString);
        }
    };
    
    void (^failure)(id)=^(FHResponse * res){
        NSDictionary *details = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 //[NSNumber numberWithInt:res.responseStatusCode], @"statusCode",
                                 res.rawResponseAsString, @"rawResponseAsString", nil];
        NSString *errorMessage = [NSString stringWithFormat:@"Error: %@", res.rawResponseAsString];
        NSLog(@"auth call exception. Status = %d Response = %@", res.responseStatusCode, errorMessage);
        result([FlutterError errorWithCode:@"AUTH_ERROR"
                                   message:errorMessage
                                   details:details]);
    };
    
    @try {
        
        if (!authPolicy || !username || !password) {
            NSString *errorMessage = [NSString stringWithFormat:@"Error authPolicy, username, password cannot empty"];
            result([FlutterError errorWithCode:@"AUTH_ERROR"
                                       message:errorMessage
                                       details:nil]);
            return;
        }
        
        
        NSLog(@"Policy: %@ username: %@", authPolicy, username);
        
        
        FHAuthRequest* authRequest = [FH buildAuthRequest];
        [authRequest authWithPolicyId:authPolicy UserId:username Password:password];
        
        [authRequest execAsyncWithSuccess:success AndFailure:failure];
    }
    @catch ( NSException *e ) {
        NSString *errorMessage = [NSString stringWithFormat:@"Error: %@", [e reason]];
        NSLog(@"cloud call exception. Response = %@", errorMessage);
        result([FlutterError errorWithCode:@"AUTH_ERROR"
                                   message:errorMessage
                                   details:nil]);
        
    }
    @finally {
        NSLog(@"finally area reached");
    }
}

-(void)handlePushRegisterCall: (FlutterMethodCall*)call result:(FlutterResult)result {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSLog(@"pushRegister call %@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSDictionary *arguments = call.arguments;
    
    NSString *alias = [arguments valueForKey:@"alias"];
    NSArray *categories = [arguments valueForKey:@"categories"];
    
    if (!alias || !categories) {
        NSString *errorMessage = @"Neither alias nor categories can be null (categories can be empty though)";
        NSLog(@"pushRegister call exception. %@", errorMessage);
        result([FlutterError errorWithCode:@"PUSH_ERROR"
                                   message:errorMessage
                                   details:nil]);
    }
        
    // Call a cloud side function when init finishes
    void (^success)(FHResponse *)=^(FHResponse * res) {
        // Listen to DeviceTokenNotification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pushMessageReceived:)
                                                     name:PushMessageReceived
                                                   object:nil];
        
        // Initialisation is now complete, you can now make FHActRequest's
        NSLog(@"pushRegister call succeded");
        result(@"SUCCESS");
    };
    
    void (^failure)(id)=^(FHResponse * res){
        NSString *errorMessage = [NSString stringWithFormat:@"Error: %@", res.rawResponseAsString];
        NSLog(@"pushRegister call exception. Status = %d Response = %@", res.responseStatusCode, errorMessage);
        result([FlutterError errorWithCode:@"PUSH_ERROR"
                                   message:errorMessage
                                   details:res.parsedResponse]);
    };
    
    FHPushConfig *config = [[FHPushConfig alloc] init];
    config.alias = alias;
    config.categories = categories;
    [FH pushRegister:nil withPushConfig:config andSuccess:success andFailure:failure];
}

-(void)pushMessageReceived:(NSNotification *)notification {
    NSLog(@"%@ pushMessageReceived %@", NSStringFromClass([self class]), [notification description]);
    //[self.channel invokeMethod:@"push_message_received" arguments:[[notification userInfo] description]];
    NSDictionary *arguments = @{ @"object" : notification.object, @"userInfo" : notification.userInfo };
    [self.channel invokeMethod:@"push_message_received" arguments:arguments];
}

-(void)handleSetPushAliasCall: (FlutterMethodCall*)call result:(FlutterResult)result {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSLog(@"setPushAlias call %@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSDictionary *arguments = call.arguments;
    
    NSString *alias = [arguments valueForKey:@"alias"];
    
    /*if (!alias) {
        NSString *errorMessage = @"Alias cannot be null";
        NSLog(@"setPushAlias call exception. %@", errorMessage);
        result([FlutterError errorWithCode:@"PUSH_ERROR"
                                   message:errorMessage
                                   details:nil]);
    }*/
    
    // Call a cloud side function when init finishes
    void (^success)(FHResponse *)=^(FHResponse * res) {
        // Listen to DeviceTokenNotification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pushMessageReceived:)
                                                     name:PushMessageReceived
                                                   object:nil];
        
        // Initialisation is now complete, you can now make FHActRequest's
        NSLog(@"setPushAlias call succeded");
        result(@"SUCCESS");
    };
    
    void (^failure)(id)=^(FHResponse * res){
        NSString *errorMessage = [NSString stringWithFormat:@"Error: %@", res.rawResponseAsString];
        NSLog(@"setPushAlias call exception. Status = %d Response = %@", res.responseStatusCode, errorMessage);
        result([FlutterError errorWithCode:@"PUSH_ERROR"
                                   message:errorMessage
                                   details:res.parsedResponse]);
    };
    
    [FH setPushAlias:alias andSuccess:success andFailure:failure];
}

-(void)handleSetPushCategoriesCall: (FlutterMethodCall*)call result:(FlutterResult)result {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSLog(@"setPushCategories call %@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSDictionary *arguments = call.arguments;
    
    NSArray *categories = [arguments valueForKey:@"categories"];
    
    /*if (!categories) {
        NSString *errorMessage = @"Categories cannot be null but can be empty";
        NSLog(@"setPushCategories call exception. %@", errorMessage);
        result([FlutterError errorWithCode:@"PUSH_ERROR"
                                   message:errorMessage
                                   details:nil]);
    }*/
    
    // Call a cloud side function when init finishes
    void (^success)(FHResponse *)=^(FHResponse * res) {
        // Listen to DeviceTokenNotification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pushMessageReceived:)
                                                     name:PushMessageReceived
                                                   object:nil];
        
        // Initialisation is now complete, you can now make FHActRequest's
        NSLog(@"setPushCategories call succeded");
        result(@"SUCCESS");
    };
    
    void (^failure)(id)=^(FHResponse * res){
        NSString *errorMessage = [NSString stringWithFormat:@"Error: %@", res.rawResponseAsString];
        NSLog(@"setPushCategories call exception. Status = %d Response = %@", res.responseStatusCode, errorMessage);
        result([FlutterError errorWithCode:@"PUSH_ERROR"
                                   message:errorMessage
                                   details:res.parsedResponse]);
    };
    
    [FH setPushCategories:categories andSuccess:success andFailure:failure];
}

@end
