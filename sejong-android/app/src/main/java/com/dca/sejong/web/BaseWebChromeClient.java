package com.dca.sejong.web;

import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.graphics.Bitmap;
import android.os.Build;
import android.os.Message;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.ConsoleMessage;
import android.webkit.GeolocationPermissions;
import android.webkit.JsResult;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.widget.FrameLayout;

import androidx.core.content.ContextCompat;

import com.dca.sejong.R;
import com.dca.sejong.common.utils.DialogUtil;
import com.dca.sejong.common.utils.Logs;


/**
 * WebChromeClient Custom
 */
public class BaseWebChromeClient extends WebChromeClient {

	/**
	 * application context
	 */
    private Activity mActivity = null;
    private FrameLayout mWebViewContainer;
    private JavaScriptBridge mJsBridge;

    //video fullscreen
    private View mCustomView;
    private CustomViewCallback mCustomViewCallback;
    private int mOriginalOrientation;
    private FrameLayout mFullscreenContainer;
    private static final FrameLayout.LayoutParams COVER_SCREEN_PARAMS = new FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);

    public BaseWebChromeClient(Activity activity, FrameLayout container, JavaScriptBridge bridge){
		mActivity = activity;
        mWebViewContainer = container;
        mJsBridge = bridge;
	}

    @Override
	public boolean onConsoleMessage(ConsoleMessage cm) {
		StringBuilder message = new StringBuilder("Console: ")
				.append(cm.message())
				.append(" / SourceId: ")
				.append(cm.sourceId())
				.append(" / LineNumber: ")
				.append(cm.lineNumber());
		Logs.i("javascript >> " + message.toString());


        return true;
	}

    @Override
    public boolean onJsAlert(WebView view, String url, String message, final JsResult result) {
        Logs.e("onJsAlert : "+ message);
        DialogUtil.alertDialog(mActivity, "", message, mActivity.getString(R.string.confirm),
                new DialogInterface.OnClickListener()
                {
                    public void onClick(DialogInterface dialog, int which)
                    {
                        result.confirm();
                        dialog.dismiss();
                    }
                });
        return true;
    }

    @Override
    public boolean onJsConfirm(WebView view, String url, String message, final JsResult result) {
        Logs.e("onJsConfirm : "+ message);

        DialogUtil.alertDialog(mActivity, "", message, mActivity.getString(R.string.confirm), mActivity.getString(R.string.cancel),
                new DialogInterface.OnClickListener()
                {
                    public void onClick(DialogInterface dialog, int which)
                    {
                        result.confirm();
                        dialog.dismiss();
                    }
                },
                new DialogInterface.OnClickListener()
                {
                    public void onClick(DialogInterface dialog, int which)
                    {
                        result.cancel();
                        dialog.dismiss();
                    }
                });

        return true;
    }

    @Override
    public void onReceivedTitle(WebView view, String title) {
        Logs.i("onReceivedTitle : "+ title);

        super.onReceivedTitle(view, title);
    }

    @Override
    public boolean onCreateWindow(WebView view, boolean isDialog, boolean isUserGesture, Message resultMsg) {

        BaseWebView newWebView = new BaseWebView(mActivity);
        int webViewCnt = mWebViewContainer.getChildCount();
        newWebView.setTag(webViewCnt+1);

        BaseWebClient client = new BaseWebClient(mActivity,mWebViewContainer);
        newWebView.setWebViewClient(client);

        BaseWebChromeClient chromeClient = new BaseWebChromeClient(mActivity,mWebViewContainer,mJsBridge);
        newWebView.setWebChromeClient(chromeClient);
        newWebView.addJavascriptInterface(mJsBridge, JavaScriptBridge.CALL_NAME);

        mWebViewContainer.addView(newWebView);

        WebView.WebViewTransport transport = (WebView.WebViewTransport)resultMsg.obj;
        transport.setWebView(newWebView);
        resultMsg.sendToTarget();



        return true;
        //return super.onCreateWindow(view, isDialog, isUserGesture, resultMsg);
    }

    @Override
    public void onCloseWindow(WebView window) {
        super.onCloseWindow(window);
        Logs.i("onCloseWindow : " + window.getTag());
        mWebViewContainer.removeView(window);
    }

    //default play button
    //defualt poster 없애기?
    @Override public Bitmap getDefaultVideoPoster() {
        return Bitmap.createBitmap(10, 10, Bitmap.Config.ARGB_8888);
    }

    //video full screenonExceededDatabaseQuota
    @Override
    public void onShowCustomView(View view, CustomViewCallback callback) {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.ICE_CREAM_SANDWICH) {
            if (mCustomView != null) {
                callback.onCustomViewHidden();
                return;
            }

            mOriginalOrientation = mActivity.getRequestedOrientation();
            FrameLayout decor = (FrameLayout) mActivity.getWindow().getDecorView();
            mFullscreenContainer = new FullscreenHolder(mActivity);
            mFullscreenContainer.addView(view, COVER_SCREEN_PARAMS);
            decor.addView(mFullscreenContainer, COVER_SCREEN_PARAMS);
            mCustomView = view;
            setFullscreen(true);
            mCustomViewCallback = callback;
//          mActivity.setRequestedOrientation(requestedOrientation);

        }

        super.onShowCustomView(view, callback);
    }

    @SuppressWarnings("deprecation")
    @Override
    public void onShowCustomView(View view, int requestedOrientation, CustomViewCallback callback) {
        this.onShowCustomView(view, callback);
    }

    @Override
    public void onHideCustomView() {
        if (mCustomView == null) {
            return;
        }

        setFullscreen(false);
        FrameLayout decor = (FrameLayout) mActivity.getWindow().getDecorView();
        decor.removeView(mFullscreenContainer);
        mFullscreenContainer = null;
        mCustomView = null;
        mCustomViewCallback.onCustomViewHidden();
        mActivity.setRequestedOrientation(mOriginalOrientation);

    }

    private void setFullscreen(boolean enabled) {

        Window win = mActivity.getWindow();
        WindowManager.LayoutParams winParams = win.getAttributes();
        final int bits = WindowManager.LayoutParams.FLAG_FULLSCREEN;
        if (enabled) {
            winParams.flags |= bits;
        } else {
            winParams.flags &= ~bits;
            if (mCustomView != null) {
                mCustomView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_VISIBLE);
            }
        }
        win.setAttributes(winParams);
    }

    private static class FullscreenHolder extends FrameLayout {
        public FullscreenHolder(Context ctx) {
            super(ctx);
            setBackgroundColor(ContextCompat.getColor(ctx, android.R.color.black));
        }
        @Override
        public boolean onTouchEvent(MotionEvent evt) {
            return true;
        }
    }

    @Override
    public void onGeolocationPermissionsShowPrompt(String origin, GeolocationPermissions.Callback callback) {
        super.onGeolocationPermissionsShowPrompt(origin, callback);
        callback.invoke(origin, true, false);
    }
}