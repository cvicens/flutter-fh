package com.redhat.fhsdk;

import android.content.Context;
import android.content.res.AssetManager;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.feedhenry.sdk.FH;
import com.feedhenry.sdk.FHActCallback;
import com.feedhenry.sdk.FHResponse;
import com.feedhenry.sdk.api.FHCloudRequest;

import org.json.fh.JSONArray;
import org.json.fh.JSONException;
import org.json.fh.JSONObject;

import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.message.BasicHeader;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
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
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    }
    // FH.init()
    else if (call.method.equals("init")) {
      this.handleInitCall(result);
    }
    // FH.cloud()
    else if (call.method.equals("cloud")) {
        this.handleCloudCall(call, result);
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

            /*if (res.getJson() != null) {
                HashMap<String, Object> map = new HashMap<>();
                JSONObject jsonObject = res.getJson();
                Iterator iterator = jsonObject.keys();
                while (iterator.hasNext()) {
                    String key = (String) iterator.next();
                    map.put(key, jsonObject.get(key));
                }
                result.success(map);
                return;
            }

            if (res.getArray() != null) {
                ArrayList<Object> array = new ArrayList<>();
                JSONArray jsonArray = res.getArray();
                for (int i = 0; i < jsonArray.length(); i++) {
                    array.add(jsonArray.get(i));
                }
                result.success(array);
            }

            result.success(null);*/
        }

        @Override
        public void fail(FHResponse res) {
            String errorMessage = "Error: " + res.getRawResponse();
            System.out.println("init call exception. Response = " + res.getErrorMessage());
            result.error("CLOUD_ERROR", errorMessage, res.getJson());
        }
      });
    } catch (Throwable e) {
        String errorMessage = "Exception: " + e.getMessage();
        System.out.println("init call exception. Response = " + errorMessage);
        result.error("CLOUD_ERROR", errorMessage, e.getCause());
    }
  }




}
