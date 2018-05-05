package com.redhat.fhsdk;

import android.content.Context;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.feedhenry.sdk.FH;
import com.feedhenry.sdk.FHActCallback;
import com.feedhenry.sdk.FHResponse;
import com.feedhenry.sdk.PushConfig;
import com.feedhenry.sdk.api.FHAuthRequest;
import com.feedhenry.sdk.api.FHCloudRequest;

import org.json.fh.JSONObject;

import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.message.BasicHeader;


import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * FhSdkPlugin
 */
public class FhSdkPlugin implements MethodCallHandler {
    private final PluginRegistry.Registrar registrar;

    public FhSdkPlugin(Registrar registrar) {
        this.registrar = registrar;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "fh_sdk");
        channel.setMethodCallHandler(new FhSdkPlugin(registrar));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        // FH.init()
        if (call.method.equals("init")) {
            this.handleInitCall(result);
        }
        // FH.cloudHost()
        else if (call.method.equals("getCloudUrl")) {
            this.handleGetClourUrlCall(result);
        }
        // FH.cloud()
        else if (call.method.equals("cloud")) {
            this.handleCloudCall(call, result);
        }
        // FH.auth()
        else if (call.method.equals("auth")) {
            this.handleAuthCall(call, result);
        }
        // FH.pushRegister()
        else if (call.method.equals("pushRegister")) {
            this.handlePushRegisterCall(call, result);
        }
        else {
            result.notImplemented();
        }
    }

    private void handleInitCall (final Result result) {
        Context context = registrar.context();
        try {

            FH.init(context, new FHActCallback() {
                public void success(FHResponse pRes) {
                    // Initialisation is now complete, you can now make FHActRequest's
                    System.out.println("SDK initialised OK");
                    result.success("SUCCESS");
                }

                public void fail(FHResponse res) {
                    String errorMessage = "Error: " + res.getRawResponse();
                    System.out.println("init call exception. Response = " + res.getErrorMessage());
                    result.error("INIT_ERROR", errorMessage, res.getJson());
                }
            });
        } catch (Throwable e) {
            String errorMessage = "Exception: " + e.getMessage();
            System.out.println("init call exception. Response = " + errorMessage);
            result.error("INIT_ERROR", errorMessage, e.getCause());
        }
    }

    private void handleGetClourUrlCall (final Result result) {
        try {
            String cloudHost = FH.getCloudHost();
            System.out.println("CLOUD_URL cloudHost ==> " + cloudHost);
            result.success(cloudHost);

        } catch (Throwable e) {
            String errorMessage = "Exception: " + e.getMessage();
            System.out.println("getCloudUrl call exception. Response = " + errorMessage);
            result.error("CLOUD_URL_ERROR", errorMessage, e.getCause());
        }
    }

    private void handleCloudCall (final MethodCall call, final Result result) {
        HashMap options = (HashMap) call.arguments;

        if (options == null) {
            String errorMessage = "Wrong arguments options === null";
            System.out.println("cloud call exception. Response = " + errorMessage);
            result.error("CLOUD_ERROR", errorMessage, null);
            return;
        }

        String path = options.containsKey("path") ? (String) options.get("path") : null;
        String method = options.containsKey("method") ? (String) options.get("method") : null;
        String contentType = options.containsKey("contentType") ? (String) options.get("contentType") : "application/json";
        Integer timeout = null;
        try {
            timeout = options.containsKey("timeout") ? (Integer) options.get("timeout") : null;
        } catch (Throwable t) {
            String errorMessage = "Wrong arguments options.timeout format exception";
            System.out.println("cloud call exception. Response = " + errorMessage);
            result.error("CLOUD_ERROR", errorMessage, null);
            return;
        }

        Header[] headers = null;
        if (options.containsKey("headers")) {
            HashMap<String, String> _headers = (HashMap<String, String>) options.get("headers");
            if (_headers.size() > 0) {
                headers = new BasicHeader[_headers.size()];
                int i = 0;
                for (String key : _headers.keySet()) {
                    headers[i++] = new BasicHeader(key, _headers.get(key));
                }
            }
        }

        JSONObject data = null;
        if (options.containsKey("data")) {
            data = new JSONObject((Map)options.get("data"));
        }

        try {
            // Build the request object with request path, method, headers and data
            FHCloudRequest request = FH.buildCloudRequest(path, method, headers, data);
            // The request will be executed asynchronously
            request.executeAsync(new FHActCallback() {
                @Override
                public void success(FHResponse res) {
                    System.out.println("CLOUD res.getRawResponse ==> " + res.getRawResponse());
                    result.success(res.getRawResponse());
                    return;
                }

                @Override
                public void fail(FHResponse res) {
                    String errorMessage = "Error: " + res.getRawResponse();
                    System.out.println("cloud call exception. Response = " + res.getErrorMessage());
                    result.error("CLOUD_ERROR", errorMessage, res.getJson());
                }
            });
        } catch (Throwable e) {
            String errorMessage = "Exception: " + e.getMessage();
            System.out.println("cloud call exception. Response = " + errorMessage);
            result.error("CLOUD_ERROR", errorMessage, e.getCause());
        }
    }


    private void handleAuthCall (final MethodCall call, final Result result) {
        HashMap arguments = (HashMap) call.arguments;

        if (arguments == null) {
            String errorMessage = "Wrong arguments === null";
            System.out.println("cloud call exception. Response = " + errorMessage);
            result.error("CLOUD_ERROR", errorMessage, null);
            return;
        }

        String authPolicy = arguments.containsKey("authPolicy") ? (String) arguments.get("authPolicy") : null;
        String username = arguments.containsKey("username") ? (String) arguments.get("username") : null;
        String password = arguments.containsKey("password") ? (String) arguments.get("password") : null;

        try {
            // Build the auth object with request path, method, headers and data
            FHAuthRequest authRequest = FH.buildAuthRequest(authPolicy, username, password);
            authRequest.executeAsync(new FHActCallback() {
                @Override
                public void success(FHResponse res) {
                    System.out.println("AUTH res.getRawResponse ==> " + res.getRawResponse());
                    result.success(res.getRawResponse());
                    return;
                }

                @Override
                public void fail(FHResponse res) {
                    HashMap<String, String> details = new HashMap<>();
                    // TODO: find if this is possible... it is in iOS
                    //details.put("statusCode", "500");
                    details.put("rawResponseAsString", res.getRawResponse());
                    String errorMessage = "Error: " + res.getRawResponse();
                    System.out.println("auth call exception. Response = " + res.getErrorMessage());
                    result.error("AUTH_ERROR", errorMessage, details);
                }
            });
        } catch (Throwable e) {
            String errorMessage = "Exception: " + e.getMessage();
            System.out.println("init call exception. Response = " + errorMessage);
            result.error("CLOUD_ERROR", errorMessage, e.getCause());
        }
    }

    private void handlePushRegisterCall (final MethodCall call, final Result result) {
        HashMap arguments = (HashMap) call.arguments;

        PushConfig config = null;
        String alias = null;
        ArrayList<String> categories = null;

        try {
            if (arguments != null) {
                config = new PushConfig();
                config.setAlias(arguments.containsKey("alias") ? (String) arguments.get("alias") : null);
                config.setCategories(arguments.containsKey("categories") ? (ArrayList<String>) arguments.get("categories") : null);
            }

            FHActCallback callback = new FHActCallback() {
                public void success(FHResponse res) {
                    // Initialisation is now complete, you can now make FHActRequest's
                    System.out.println("PUSH res.getRawResponse ==> " + res.getRawResponse());
                    result.success(res.getRawResponse());
                }

                @Override
                public void fail(FHResponse res) {
                    String errorMessage = "Error: " + res.getRawResponse();
                    System.out.println("pushRegister call exception. Response = " + res.getErrorMessage());
                    result.error("PUSH_ERROR", errorMessage, res.getJson());
                }
            };
            if (config != null) {
                FH.pushRegister(config, callback);
            } else {
                FH.pushRegister(callback);
            }
        } catch (Throwable e) {
            String errorMessage = "Exception: " + e.getMessage();
            System.out.println("pushRegister call exception (check alias and categories types if in use). Response = " + errorMessage);
            result.error("PUSH_ERROR", errorMessage, e.getCause());
        }
    }


}
