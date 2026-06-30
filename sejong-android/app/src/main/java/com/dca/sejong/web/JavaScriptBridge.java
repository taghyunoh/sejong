package com.dca.sejong.web;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import android.webkit.JavascriptInterface;
import android.widget.FrameLayout;

import com.dca.sejong.common.AppPreference;
import com.dca.sejong.common.Define;
import com.dca.sejong.common.utils.Logs;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;


public class JavaScriptBridge {
    private static final long MIN_CLICK_INTERVAL 			    = 600;    // ms

    public static final String CALL_NAME = "Android";
    private Context mContext;
    private Activity mActivity;

    /** UI 스레드 처리를 위한 핸들러 */
    private Handler mUiHandler;

    /**
     * Command 호출이 연속으로 발생하여 앞의 업무를 처리전에 다시 호출될 경우
     * CallBackFuncName이 변경되는 문제가 발생할수 있다.
     */
    private HashMap<Integer, String> mCallbackFuncName;
    private HashMap<Integer, String> mJsonObjectParam;
    private int mWebViewFragmentType;
    private FrameLayout mWebViewContainer;

    public JavaScriptBridge(Context context, FrameLayout webViewContainer){
        //activityReference = new WeakReference<>(activity);
        mContext = context;
        mActivity = (Activity) context;
        mWebViewContainer = webViewContainer;
        mUiHandler = new Handler(Looper.getMainLooper());
        mCallbackFuncName = new HashMap<Integer, String>();
        mJsonObjectParam = new HashMap<Integer, String>();
    }

    public JavaScriptBridge(Context context, FrameLayout webViewContainer, int webViewFragmentType) {
        mContext = context;
        mActivity = (Activity) context;
        mWebViewContainer = webViewContainer;
        mUiHandler = new Handler(Looper.getMainLooper());
        mCallbackFuncName = new HashMap<Integer, String>();
        mJsonObjectParam = new HashMap<Integer, String>();
        mWebViewFragmentType = webViewFragmentType;
    }

    public void destroyJavaScriptBrigdge(){
        //activityReference = null;
    }

    /**
     * 콜백함수를 스택으로 구성하여 여러번 호출되어도 됨.
     */
    private void setCallbackFunc(int cmd, String callBackName){
        mCallbackFuncName.put(cmd,callBackName);
        Logs.i("mCallbackFuncName size() : " + mCallbackFuncName.size());
    }

    public String getCallBackFunc(int cmd) {
        String callBackName = mCallbackFuncName.get(cmd);
        mCallbackFuncName.remove(cmd);
        Logs.i("mCallbackFuncName size() : " + mCallbackFuncName.size());
        return callBackName;
    }

    public String getCallBackFunc(int cmd, boolean clear) {
        String callBackName = mCallbackFuncName.get(cmd);
        if(clear)
            mCallbackFuncName.remove(cmd);
        Logs.i("mCallbackFuncName size() : " + mCallbackFuncName.size());
        return callBackName;
    }

    /**
     * Json 파라미더를 를 스택으로 구성하여 여러번 호출되어도 값을 저장하여 꺼내올수 있도록 구성.
     */
    public void setJsonObjecParam(int cmd, String param) {
        mJsonObjectParam.put(cmd,param);
    }

    public String getJsonObjecParam(int cmd){

        String param = mJsonObjectParam.get(cmd);
        mJsonObjectParam.remove(cmd);

        Logs.i("getJsonObjecParam size() : " + mCallbackFuncName.size());
        return param;
    }

    /**
     * 자바스크립를 실행한다.
     * @param javascript 자바스크립트 코드
     */
    public void callJavascript(String javascript) {
        Logs.e("callJavascript - loadUrl : " + javascript);
        BaseWebView webView = (BaseWebView) mWebViewContainer.getChildAt(mWebViewContainer.getChildCount() - 1);
        webView.loadUrl("javascript:" + javascript);
    }

    public void callJavascript(String javascript, HashMap<String, String> header) {
        Map<String, String> headerInfo = new HashMap<>();
        headerInfo.put("CSRF", "");

        Logs.e("callJavascript - loadUrl : " + javascript);
        BaseWebView webView = (BaseWebView) mWebViewContainer.getChildAt(mWebViewContainer.getChildCount() - 1);
        webView.loadUrl("javascript:" + javascript, header);
    }

    public void callJavascriptPost(String url, String param) {
        Logs.e("callJavascriptPost - url : " + url + " param : " + param);
        BaseWebView webView = (BaseWebView) mWebViewContainer.getChildAt(mWebViewContainer.getChildCount() - 1);
        try {
            webView.postUrl(url, URLEncoder.encode(param, "UTF-8").getBytes());
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
    }

    /**
     * 자바스크립트 함수를 호출한다.
     * @param funcName 자바스크립트 함수명
     * @param jsonObj 함수 파라미터 목록
     */
    public void callJavascriptFunc(String funcName, JSONObject jsonObj) {

        if (TextUtils.isEmpty(funcName)) return;

        String func = "";
        if (jsonObj == null) {
            func = String.format("%s()", funcName);
        } else {
            func = String.format("%s(%s)", funcName, jsonObj.toString());
        }

        Logs.e("func : " + func);
        callJavascript(func);

    }

    /**
     * 자바스크립트 함수를 호출한다.
     * @param funcName 자바스크립트 함수명
     * @param argu 함수 파라미터 스트링
     */
    public void callJavascriptFuncWithString(String funcName, String... argu) {

        if (TextUtils.isEmpty(funcName)) return;
        //if(TextUtils.isEmpty(argu) || argu.equals("")) return;

        String func = null;
        if(argu == null || argu.length == 0)
            func = String.format("%s()", funcName);
        else {
            boolean isFirst = true;
            StringBuilder sb = new StringBuilder();
            for( String arg : argu) {
                if(!isFirst)
                    sb.append(",");
                else
                    isFirst = false;

                sb.append("\'");
                sb.append(arg);
                sb.append("\'");
            }
            func = String.format("%s(%s)", funcName, sb.toString());
        }
        //Logs.e("func : " + func);
        callJavascript(func);

    }

    /**
     * JSON 요청 문자열에서 Command 구분값을 얻어온다.
     * @param json JSON 요청 문자열
     * @return Command 구분
     * }
     */
    private int getCommand(JSONObject json) {

        int api = JavaScriptCmd.CMD_UNKNOWN;
        try {
            //JSONObject header = json.getJSONObject("header");
            String cmdStr = json.getString("cmd");
            if (TextUtils.isEmpty(cmdStr)) {
                Logs.shwoToast(mContext, "안드로이드 호출 함수 번호가 없습니다.");
                return -1;
            } else {
                api = Integer.parseInt(cmdStr);
                String callbackFuncName = json.optString("callback", "");
                Logs.e("callbackFuncName : " + callbackFuncName);
                setCallbackFunc(api,callbackFuncName);
            }
        } catch (NumberFormatException | JSONException e) {
            Logs.printException(e);
        }

        return api;

    }

    /**
     * 네이티브 기능을 수행하기 위한 자바스크립트 인터페이스 메소드
     * @param jsonEncodeString json 문자열
     * {
     *  "cmd":"100",
     *  "callback":"",
     *  "data":{
     *      //각 호출 함수에 맞게 파라미터값
     *  }
     */
    @JavascriptInterface
    public void callAppFunc(String jsonEncodeString) {

        String jsonString = JavaScriptCmd.makeNewJsonString(jsonEncodeString);
        Logs.e("==============================================================================");
        Logs.e("callAppFunc - jsonString : " + jsonString);
        Logs.e("==============================================================================");

        try {
            final JSONObject json = new JSONObject(jsonString);

            mUiHandler.post(new Runnable() {
                public void run() {

                    try {
                        int cmd = getCommand(json);
                        Logs.e("callAppFunc - cmd : " + cmd);
                        switch (cmd) {
                            case JavaScriptCmd.CMD_100:
                                cmd_100_AppExit(json);
                                break;
                            case JavaScriptCmd.CMD_101:    //Not Use
                                cmd_101_getUserLoginInfo();
                                break;
                            case JavaScriptCmd.CMD_102:
                                cmd_102_SaveUserLoginInfo(json);
                                break;
                            case JavaScriptCmd.CMD_200:
                                cmd_200(json);
                                break;
                            case JavaScriptCmd.CMD_201:
                                cmd_201(json);
                                break;
                            case JavaScriptCmd.CMD_202:
                                cmd_202(json);
                                break;
                            case JavaScriptCmd.CMD_203:
                                cmd_203(json);
                                break;
                            case JavaScriptCmd.CMD_301:
                                cmd_301(json);
                                break;
                            default:
                                break;
                        }
                    } catch (JSONException e) {
                        Logs.printException(e);
                    }

                }
            });
        } catch (JSONException e) {
            Logs.printException(e);
        }
    }

    /**
     * ==============================================================================================
     * Interface Functions
     * ==============================================================================================
     */
    private void cmd_100_AppExit(JSONObject json) throws JSONException {
        //mActivity.finish();
        mActivity.finishAffinity();
        System.runFinalization();
        System.exit(0);
    }

    private void cmd_101_getUserLoginInfo() {
        String userLoginInfo = AppPreference.getUserLoginInfo();
        callJavascriptFuncWithString(getCallBackFunc(JavaScriptCmd.CMD_101), userLoginInfo);
    }

    private void cmd_102_SaveUserLoginInfo(JSONObject json) throws JSONException {
        JSONObject data = json.getJSONObject("data");
        String userLoginInfo = data.toString();
        AppPreference.setUserLoginInfo(userLoginInfo);
        //push token
        //Logs.e("Token change : " + AppApplication.isTokenChange);
        // tokenchange  = false
        //if(AppPreference.getTokenChanged()) {
        //JSONObject userInfo = new JSONObject();
        //userInfo.put("token", AppPreference.getToken());
        //AppPreference.setTokenChanged(false);
        //callJavascriptFuncWithString(getCallBackFunc(JavaScriptCmd.CMD_102), userInfo.toString());
        //Logs.e(userInfo.toString());
        //}
        /*else {
            callJavascriptFunc(getCallBackFunc(JavaScriptCmd.CMD_102), null);
        }*/

        //BaseWebView webView = (BaseWebView) mWebViewContainer.getChildAt(mWebViewContainer.getChildCount() - 1);
        //history에 어떤 데이터? preference 초기화?
        //webView.clearHistory();
        //webView.clearCache(true);
    }
    private void cmd_200(JSONObject json) {
        Logs.e("callAppFunc - jsonString : " + "cmd_200" );
    }
    private void cmd_201(JSONObject json) {
        Logs.e("callAppFunc - jsonString : " + "cmd_201");
        Intent intent = new Intent(Define.ACTION_JAVASCRIPT_CMD_201);
        mActivity.sendBroadcast(intent);
    }
    private void cmd_202(JSONObject json) throws JSONException {
        Logs.e("callAppFunc - jsonString : " + "cmd_202");
        JSONObject data = json.getJSONObject("data");
        Intent intent = new Intent(Define.ACTION_JAVASCRIPT_CMD_202);
        intent.putExtra("data",data.getString("data"));
        intent.putExtra("foodhisSeq",data.getString("foodhisSeq"));
        mActivity.sendBroadcast(intent);
    }
    private void cmd_203(JSONObject json) throws JSONException {
        Logs.e("callAppFunc - jsonString : " + "cmd_202");
        JSONObject data = json.getJSONObject("data");
        String imagePath = data.getString("data");
        Logs.e(imagePath);
        Intent intent = new Intent(Define.ACTION_JAVASCRIPT_CMD_203);
        intent.putExtra("imagePath",imagePath);
        intent.putExtra("index",data.getString("index"));
        mActivity.sendBroadcast(intent);
    }
    private void cmd_301(JSONObject json) throws JSONException {
        Logs.e("callAppFunc - jsonString : " + "cmd_301");
        Intent intent = new Intent(Define.ACTION_JAVASCRIPT_CMD_301);
        mActivity.sendBroadcast(intent);
    }
}
