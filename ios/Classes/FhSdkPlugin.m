#import "FhSdkPlugin.h"

#import <FH/FH.h>
#import <FH/FHResponse.h>

@implementation FhSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"fh_sdk"
            binaryMessenger:[registrar messenger]];
  FhSdkPlugin* instance = [[FhSdkPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  // Get platform version
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } 
  // FH.init()
  else if ([@"init" isEqualToString:call.method]) {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    
    // Call a cloud side function when init finishes
    void (^success)(FHResponse *)=^(FHResponse * res) {
        // Initialisation is now complete, you can now make FHActRequest's
        NSLog(@"SDK initialised OK");
        result(@[@"SDK initialised OK"]);
    };
    
    void (^failure)(id)=^(FHResponse * res){
        NSLog(@"Initialisation failed. Response = %@", res.rawResponse);
        result(@[@"SDK initialised OK"]);
    };
    
    [FH initWithSuccess:success AndFailure:failure];
  } 
  // FH.init()
  else if ([@"cloud" isEqualToString:call.method]) {
  }
  // Else...
  else {
    result(FlutterMethodNotImplemented);
  }
}

-(void)handleCloudCallWithOptions: (NSDictionary *) options result:(FlutterResult)result {
  NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSLog(@"options: %@", options);
    
    // Call a cloud side function when init finishes
    void (^success)(FHResponse *)=^(FHResponse * res) {
        NSLog(@"cloud call succeded");
        NSDictionary *resData = res.parsedResponse;
        
        result(@[resData]);
    };
    
    void (^failure)(id)=^(FHResponse * res){
        NSString *errorMessage = [NSString stringWithFormat:@"Error: %@", [res.error localizedDescription]];
        NSLog(@"cloud call failed. Response = %@", errorMessage);
        result(@[errorMessage]);
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
        
        //NSLog(@">>>>>>> %@ %@ %@ %@ %@", path, method, contentType, headers, data);
        
        
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
        result(@[errorMessage]);
    }
    @finally {
        NSLog(@"finally area reached");
    }
}

@end
