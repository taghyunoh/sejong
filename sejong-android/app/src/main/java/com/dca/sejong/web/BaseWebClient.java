package com.dca.sejong.web;

import static android.net.http.SslError.SSL_UNTRUSTED;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.net.http.SslError;
import android.os.Build;
import android.text.TextUtils;
import android.webkit.SslErrorHandler;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;

import com.dca.sejong.AppApplication;
import com.dca.sejong.MainActivity;
import com.dca.sejong.common.Define;
import com.dca.sejong.common.utils.Logs;

/**
 * WebClient Custom
 */
public class BaseWebClient extends WebViewClient {

	private Context mContext;
    private Activity mActivity;
    private FrameLayout mWebViewContainer;
    private boolean mConnectAbort;


	public BaseWebClient(Activity activity, FrameLayout container) {
        mActivity = activity;
		mContext = mActivity.getBaseContext();
        mWebViewContainer = container;
	}

    @Override
    public void onPageStarted(WebView view, String url, Bitmap favicon) {
        super.onPageStarted(view, url, favicon);
        Logs.e(view.getTag() + ".onPageStarted : " + url);
        mConnectAbort = false;
        if (mActivity != null && mActivity instanceof MainActivity) {
            ((MainActivity) mActivity).showProgressDialog();
        }
    }

	@Override
	public void onPageFinished(WebView view, String url) {
		super.onPageFinished(view, url);
		Logs.e(view.getTag() + ".onPageFinished : " + url);
        if (mActivity != null && mActivity instanceof MainActivity) {
            MainActivity act = ((MainActivity) mActivity);
            act.dismissProgressDialog();
            if(mConnectAbort)
                act.setCurrentPage("");
            else {
                act.setCurrentPage(url);

                if(url.equalsIgnoreCase(Define.ReqUrl.URL_BASE.getReqUrl())) {
                    act.sendUserLoinInfo();
                }
                else if(url.contains(Define.ReqUrl.URL_MAIN.getReqUrl())) {
                    try{
                        //pushLinkUrl이 null이면 error
                        if(AppApplication.pushLinkUrl != null && !AppApplication.pushLinkUrl.equals("")) {
                            view.loadUrl(AppApplication.pushLinkUrl);
                            AppApplication.pushLinkUrl = "";
                        }
                    }catch(Exception e){
                        Logs.printException(e);
                    }

                    view.clearHistory();
                    view.clearCache(true);
                }
            }
        }
	}

    @Override
    public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
        // Handle the error
        Logs.e("onReceivedError : " + errorCode);
        Logs.e("onReceivedError : " + description);
        Logs.e("onReceivedError : " + failingUrl);
/*
        if (mActivity != null && mActivity instanceof MainActivity) {
            ((MainActivity) mActivity).dismissProgressDialog();
        }*/

        //CONNECTION관련 에러 - 서버에 접속을 못한것임.
        if(description.contains("ERR_CONNECTION_REFUSED")||
            description.contains("ERR_NAME_NOT_RESOLVED")||
            description.contains("ERR_CONNECTION_TIMED_OUT")||
            description.contains("ERR_INTERNET_DISCONNECTED")||
            description.contains("ERR_ADDRESS_UNREACHABLE")||
            description.contains("ERR_CONNECTION_ABORTED")||
            description.contains("ERR_TIMED_OUT")||
            description.contains("ERR_CONNECTION_RESET")){
            mConnectAbort = true;
        }
    }


    @Override
    public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
        Logs.e("0.shouldOverrideUrlLoading ");
        String url="";
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            url= request.getUrl().toString();
            Logs.e("0.shouldOverrideUrlLoading :" + url);
        }

        // tel일경우 아래와 같이 처리해준다.
        if (url.startsWith("tel:")) {
            Intent tel = new Intent(Intent.ACTION_DIAL, Uri.parse(url));
            tel.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            mContext.startActivity(tel);
            return true;
        }
        return checkUrlRunStoreApp(url);
        //return super.shouldOverrideUrlLoading(view, request);
    }

    @Override
    public boolean shouldOverrideUrlLoading(WebView view, String url) {
        Logs.e("1.shouldOverrideUrlLoading : " + url);
        return checkUrlRunStoreApp(url);
        //return super.shouldOverrideUrlLoading(view, url);
    }

    private boolean checkUrlRunStoreApp(String url){
        Logs.e("checkUrlRunStoreApp : " + url);
        if(!TextUtils.isEmpty(url) && url.startsWith("market://")){
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setData(Uri.parse(url));
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            mContext.startActivity(intent);
            return true;
        }

        return false;
    }

    @Override
    public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
        // Redirect to deprecated method, so you can use it in all SDK versions
        Logs.e("onReceivedError : " + error);

        if (mActivity != null && mActivity instanceof MainActivity) {
            ((MainActivity) mActivity).dismissProgressDialog();
        }

        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.M){
            onReceivedError(view, error.getErrorCode(), error.getDescription().toString(), request.getUrl().toString());
        }
    }

    @Override
    public void onReceivedHttpError(WebView view, WebResourceRequest request, WebResourceResponse errorResponse) {
        super.onReceivedHttpError(view, request, errorResponse);

        if (mActivity != null && mActivity instanceof MainActivity) {
            ((MainActivity) mActivity).dismissProgressDialog();
        }

        if (Build.VERSION.SDK_INT > 21) {
            Logs.e("onReceivedHttpError - request Url : " + request.getUrl().toString());
            Logs.e("onReceivedHttpError - errorResponse : " + errorResponse.getStatusCode());
            Logs.e("onReceivedHttpError - errorResponse : " + errorResponse.getResponseHeaders().toString());
        }
        Logs.e("onReceivedHttpError - errorResponse: " + errorResponse.toString());
    }


    @Override
    public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {
        //super.onReceivedSslError(view, handler, error);

        Logs.e("onReceivedSslError - error : " + error.toString());

        if (mActivity != null && mActivity instanceof MainActivity) {
            ((MainActivity) mActivity).dismissProgressDialog();
        }

        if (error.hasError(SSL_UNTRUSTED)) {
            if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.LOLLIPOP) {
                /*
                // Check if Cert-Domain equals the Uri-Domain
                String certDomain = SaidaUrl.getBaseWebUrl();
                String hostUrl="";
                try {
                    hostUrl = new URL(error.getUrl()).getHost();
                } catch (MalformedURLException e) {
                    Logs.printException(e);
                }
                Logs.e("onReceivedSslError - certDomain : " + certDomain);
                Logs.e("onReceivedSslError - hostUrl : " + hostUrl);
                if(certDomain.contains(hostUrl)) {
                    handler.proceed();
                }
                */
            }
        }
        else {
            super.onReceivedSslError(view, handler, error);
        }

    }
}