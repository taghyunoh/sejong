package com.dca.sejong.common.net;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.AsyncTask;
import android.os.Build;
import android.text.TextUtils;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.ValueCallback;

import com.dca.sejong.AppApplication;
//import com.dca.sejong.BuildConfig;
import com.dca.sejong.common.utils.Logs;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.util.Iterator;
import java.util.List;
import java.util.Map;


public class HttpUtils {
    public static final String REQ_CODE = "req_code";
    public static final String REQ_MSG  = "req_msg";

    public static final String CHARSET_TYPE = "UTF-8";
    /*
     * UserAgent값을 생성해 두고 가지고 있는다.
     * */
    public static String mUserAgent;

    //현재 연결된 네트웍의 상태값.
    public enum NetState {
        NET_STATE_MOBILE,
        NET_STATE_WIFI,
        NET_STATE_ETHERNET,
        NET_STATE_OFFLINE,
        NET_STATE_NOT_SUPPORT,
    }

    /**
     * Get방식으로 웹에 접속하여 데이타 조회시 사용
     *
     * @param url      접속주소
     * @param listener 리턴받을 리스너
     */
    public static void sendHttpTask(String url, HttpSenderTask.HttpRequestListener listener) {
        new HttpSenderTask(url, listener).execute();
    }

    /**
     * POST방식으로 웹에 접속하여 데이타 조회시 사용
     *
     * @param url      접속주소
     * @param param    서버에 보낼 데이타  String 타입
     * @param listener 리턴받을 리스너
     */
    public static void sendHttpTask(String url, String param, HttpSenderTask.HttpRequestListener listener) {
        new HttpSenderTask(url, listener).execute(param);
    }

    /**
     * POST방식으로 웹에 접속하여 데이타 조회시 사용
     *
     * @param url      접속주소
     * @param param    서버에 보낼 데이타  Map타입
     * @param listener 리턴받을 리스너
     */
    public static void sendHttpTask(String url, Map<String, Object> param, HttpSenderTask.HttpRequestListener listener) {
        String strParam = "";
        try {
            strParam = mapToParamString(param);

        } catch (UnsupportedEncodingException e) {
            Logs.printException(e);
        }
        new HttpSenderTask(url, listener).executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, strParam);

    }


    /**
     * 앱에서 사용되는 User-Agent 값을 생성한다. <br>
     * baseUserAgent 값이 있는 경우 baseUserAgent에 앱전용 User-Agent값이 append된다.
     *
     * @param context
     * @param string
     * @return User-Agent 문자열
     */
    public static String makeUserAgentString(Context context, String string) {
        /*StringBuilder sb = new StringBuilder();

        if (!TextUtils.isEmpty(string)) {
            sb.append(string).append(";");
        }

        sb.append("COMPANY=").append("SkyLife");
        sb.append(";").append("DEVICE_APP_VER=").append(Utils.getVersionName(context));
        sb.append(";").append("DEVICE_OS=").append("Android");
        sb.append(";").append("DEVICE_OS_VERSION=").append(Build.VERSION.RELEASE);
        sb.append(";").append("DEVICE_MODEL=").append(Build.MODEL);
        sb.append(";").append("DEVICE_ID=").append(Utils.getUniqueID(context));
        sb.append(";");
        mUserAgent = sb.toString();

        Logs.e("makeUserAgentString : " + mUserAgent);*/

        return mUserAgent;
    }


    /**
     * Http연결시 Header에 쿠키정보를 넣어준다.
     *
     * @param url  접속주소
     * @param conn Connection정보
     */
    public static void setCooKie(String url, HttpURLConnection conn) {
        String cookieString = CookieManager.getInstance().getCookie(url);
        Logs.e("setCooKie - cookieString : " + cookieString);
        if (!TextUtils.isEmpty(cookieString)) {
            conn.setRequestProperty("Cookie", cookieString);
        }
    }

    /**
     * Http접속후 넘어오는 Cookie정보를 저장해 둔다.
     *
     * @param conn
     */
    public static void saveCookie(URLConnection conn) {
        String cookie = conn.getHeaderField("Set-Cookie");

        if (cookie != null) {
            String url = conn.getURL().toString();

            // permanent 영역에 쿠기를 즉시 동기화 한다.

            CookieManager cookieManager = CookieManager.getInstance();
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                cookieManager.setCookie(url, cookie);
                cookieManager.flush();
            } else {
                CookieSyncManager cookieSyncManager = CookieSyncManager.createInstance(AppApplication.getContext());
                cookieManager.setCookie(url, cookie);
                cookieSyncManager.sync();
            }
        }
    }

    /**
     * 쿠키정보를 Clear한다.
     */
    public static void removeCookie() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            CookieManager.getInstance().removeAllCookies(new ValueCallback<Boolean>() {
                @Override
                public void onReceiveValue(Boolean aBoolean) {
                    Logs.e("removeSessionCookies : " + aBoolean);
                }
            });
        }
        else {
            CookieSyncManager.createInstance(AppApplication.getContext());
            CookieManager cookieManager = CookieManager.getInstance();
            cookieManager.removeAllCookie();
            CookieSyncManager.getInstance().sync();
        }
    }

    /**
     * 모바일 단말기의 인터넷 접속 상태를 체크한다.
     *
     * @param context
     * @return 상태값
     */
    public static NetState checkNetworkState(Context context) {
        ConnectivityManager cm = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
        if (activeNetwork != null) {
            if (activeNetwork.isConnectedOrConnecting()) {
                if (activeNetwork.getType() == ConnectivityManager.TYPE_WIFI) {
                    // WIFI 네트워크 연결중
                    return NetState.NET_STATE_WIFI;
                } else if (activeNetwork.getType() == ConnectivityManager.TYPE_MOBILE) {
                    // 모바일 네트워크 연결중
                    return NetState.NET_STATE_MOBILE;
                } else if (activeNetwork.getType() == ConnectivityManager.TYPE_ETHERNET) {
                    // 모바일 네트워크 연결중
                    return NetState.NET_STATE_ETHERNET;
                }
            } else {
                // 네트워크 오프라인 상태.
                return NetState.NET_STATE_OFFLINE;
            }
        }
        // 네트워크 null.. 모뎀이 없는 경우??
        return NetState.NET_STATE_NOT_SUPPORT;

    }

    /**
     * Http Header 문자열을 가져온다
     *
     * @param type
     * @param conn
     * @return Header 문자열
     */
    public static String printHeader(String type, HttpURLConnection conn) {
        JSONObject jsonHeader = new JSONObject();

        Map<String, List<String>> headers = conn.getHeaderFields();
        Iterator<String> it = headers.keySet().iterator();

        while (it.hasNext()) {
            String key = it.next();
            List<String> values = headers.get(key);
            StringBuffer sb = new StringBuffer();

            for (int i = 0; i < values.size(); i++) {
                sb.append(";" + values.get(i));
            }

            if (key != null && key.length() > 0) {
                try {
                    jsonHeader.put(key, sb.toString().substring(1));
                } catch (JSONException e) {
                    Logs.printException(e);
                }
            }
        }

        try {
            jsonHeader.put("Location", conn.getURL().toString());
        } catch (JSONException e) {
            Logs.printException(e);
        }
/*        if (BuildConfig.DEBUG) {
            Logs.i("=======================================");
            Logs.i("Http Header Infomation\n ");
            Logs.i("printHeader - " + jsonHeader.toString());
            Logs.i("=======================================");
        }*/
        return jsonHeader.toString();
    }

    /**
     * Map을 파라미터 문자열 형태로 변환한다.
     *
     * @param paramMap 파라미터 Map
     * @return 파라미터 문자열 (key1=value1&key2=value2&...)
     * @throws UnsupportedEncodingException
     */
    public static String mapToParamString(Map<String, Object> paramMap) throws UnsupportedEncodingException {
        if (paramMap == null) {
            return null;
        }

        StringBuilder sb = new StringBuilder();
        int paramCnt = paramMap.size();
        int index = 0;
        for (Map.Entry<String, Object> entry : paramMap.entrySet()) {
            sb.append(entry.getKey()).append("=").append(URLEncoder.encode((String) entry.getValue(), CHARSET_TYPE));
            if (index < paramCnt - 1) {
                sb.append("&");
            }
            index++;
        }

        return sb.toString();
    }

    public static String makeReturnJsonStr(int requestCode,String msg){
        JSONObject jsonObj = new JSONObject();

        try {
            jsonObj.put(REQ_CODE,requestCode);
            jsonObj.put(REQ_MSG,msg);
            return jsonObj.toString();
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return "";
    }
}
