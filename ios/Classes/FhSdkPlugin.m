#import "FhSdkPlugin.h"

#import <Flutter/Flutter.h>

#import <FH/FH.h>
#import <FH/FHResponse.h>

@implementation FhSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"fh_sdk"
            binaryMessenger:[registrar messenger]];
  FhSdkPlugin* instance = [[FhSdkPlugin alloc] init];
  [registrar addMethodCallDelegate: instance channel: channel];
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
      NSNumber *timeout;
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
      action.requestTimeout = 25.0;
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

-(void)handleCloudCallParsed: (FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *options = call.arguments;
    
  NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  NSLog(@"options: %@", options);
  
  // Call a cloud side function when init finishes
  void (^success)(FHResponse *)=^(FHResponse * res) {
      NSLog(@"cloud call succeded");
      result(res.parsedResponse);
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
      NSNumber *timeout;
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
      action.requestTimeout = 25.0;
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
                                 [NSNumber numberWithInt:res.responseStatusCode], @"statusCode",
                                 res.rawResponseAsString, @"rawResponseAsString", nil];
        NSString *errorMessage = [NSString stringWithFormat:@"Error: %@", res.rawResponseAsString];
        NSLog(@"init call exception. Status = %d Response = %@", res.responseStatusCode, errorMessage);
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

-(void)handleAuthCallParsed: (FlutterMethodCall*)call result:(FlutterResult)result {
    NSLog(@"auth call with promise %@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSDictionary *options = call.arguments;
    
    NSString *authPolicy = [options valueForKey:@"authPolicy"];
    NSString *username = [options valueForKey:@"username"];
    NSString *password = [options valueForKey:@"password"];
    
    // Call a cloud side function when init finishes
    void (^success)(FHResponse *)=^(FHResponse * res) {
        NSLog(@"auth call succeded check status");
        NSDictionary *resData = res.parsedResponse;
        
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
            result(resData);
        }
    };
    
    void (^failure)(id)=^(FHResponse * res){
        NSDictionary *details = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [NSNumber numberWithInt:res.responseStatusCode], @"statusCode",
                                 res.rawResponseAsString, @"rawResponseAsString", nil];
        NSString *errorMessage = [NSString stringWithFormat:@"Error: %@", res.rawResponseAsString];
        NSLog(@"init call exception. Status = %d Response = %@", res.responseStatusCode, errorMessage);
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

@end
