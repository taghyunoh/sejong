package com.dca.sejong.web;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Build;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.webkit.CookieManager;
import android.webkit.WebSettings;
import android.webkit.WebView;

import com.dca.sejong.common.net.HttpUtils;
import com.dca.sejong.common.utils.Logs;

/**
 * WebView Custom
 */
@SuppressLint("NewApi")
public class BaseWebView extends WebView {
	public Context mContext;

	public BaseWebView(Context context) {
		super(context);
		if(!isInEditMode())
            init(context);
	}

	public BaseWebView(Context context, AttributeSet attrs) {
		super(context, attrs);
		if(!isInEditMode())
            init(context);
	}

	public BaseWebView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		if(!isInEditMode())
            init(context);
	}

	@Override
	public void destroy() {
		ViewParent parent = this.getParent();
		if(parent instanceof ViewGroup){
			//형식이 viewgroup이라면 삭제해라?
			((ViewGroup) parent).removeView(this);
		}

		loadUrl("about:blank");

		try{
			removeAllViews();
		}catch (Exception e){
			e.printStackTrace();
		}
		super.destroy();
	}

	public void init(Context context) {
		Logs.e("BaseWebview - init");
        mContext = context;
        setDefaultWebSettings();
	}

	public void setDefaultWebSettings() {
		//세팅가져온다?
		WebSettings settings = getSettings();

		//User Agent를 설정한다.
		String userAgent = HttpUtils.makeUserAgentString(mContext, settings.getUserAgentString());
		Logs.i("*********************************************");
		Logs.i("setDefaultWebSettings - userAgent" + userAgent);
		Logs.i("*********************************************");
		//앱으로 들어간것으로 인지시키기 위함
		settings.setUserAgentString(userAgent);
		//자바 스크립트 기능을 사용하기 위함
		settings.setJavaScriptEnabled(true);
		//캐시모드 설정 , LOAD_NO_CACHE : 캐시모드를 사용하지않고 네트워크를 통해서만 호출
		settings.setCacheMode(WebSettings.LOAD_NO_CACHE);
		//안드로이드에서 제공하는 줌 아이콘 사용 설정
		settings.setBuiltInZoomControls(true);
		//확대 축소기능 사용
		settings.setSupportZoom(true);
		//자동완성 기능 사용
        settings.setSaveFormData(false);
		//줌 컨트롤 박스 없애기
		settings.setDisplayZoomControls(false);
		//웹뷰가 wide viewport를 사용하도록 설정 , 화면사이즈를 기기에 맞춰 잡아준다?
		settings.setUseWideViewPort(true);
		//컨텐츠가 웹뷰보다 클때 스크린크기에 맞춘다.
		settings.setLoadWithOverviewMode(true);
		//이미지 리소스 자동로드
		settings.setLoadsImagesAutomatically(true);
		//웹뷰 내에서 파일 액세스 활성화 여부
		settings.setAllowFileAccess(true);
		// gps 사용여부
		settings.setGeolocationEnabled(true);
		//여러개의 윈도우를 사용할수 있도록 설정?
		settings.setSupportMultipleWindows(true);
		//자바스크립트가 창을 열수 있게 할지 여부
		settings.setJavaScriptCanOpenWindowsAutomatically(true);


		//WebView inside Browser doesn't want initial focus to be set.
		//requestFocus()로 컴포넌트 강제 호출시 focus가질 노드를 알려줄지 여부
		settings.setNeedInitialFocus(false);


		//disable content url access
		//컨텐츠 프로바이더를 이용할때 true설정
		settings.setAllowContentAccess(false);

		//HTML5 API flags
		//로컬 스토리지 사용 여부 ,팝업창 하루동안 보지않기 기능 사용등 지속적필요데이터
		settings.setDomStorageEnabled(true);
		//database 사용여부
		settings.setDatabaseEnabled(true);
		//앱 내부에서 캐시를 사용할지 여부
		settings.setCacheMode(WebSettings.LOAD_DEFAULT);

		// https로 로드된 페이지에서 http링크로된 리소스 연결할 때 block 방지
		settings.setMixedContentMode(WebSettings.MIXED_CONTENT_COMPATIBILITY_MODE);
		// 연결된 홈페이지의 컨텐츠 사이즈가 넘쳐서 확대되 보일때 사이즈를 맞춰줌
		settings.setLayoutAlgorithm(WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING);
		//웹뷰에서 글자가 커지거나 작아져서 화면이 깨지는것을 방지 100으로 강제
		settings.setTextZoom(100);

		//database 위치설정
		if(Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
			settings.setGeolocationDatabasePath(mContext.getDir("geolocation", 0).getPath());
		}

		// origin policy for file access
		//신뢰할수없는 파일 허용
		settings.setAllowUniversalAccessFromFileURLs(false);
		//신뢰할수없는 파일 허용
		settings.setAllowFileAccessFromFileURLs(false);

		//쿠키 동기화
		CookieManager cookieManager = CookieManager.getInstance();
		cookieManager.setAcceptCookie(true);

		if(Build.VERSION.SDK_INT > Build.VERSION_CODES.LOLLIPOP) {
			CookieManager.getInstance().setAcceptThirdPartyCookies(this,true);
		}

		//하드웨어 가속 옵션 활성화 , 웹뷰성능올림
		setLayerType(View.LAYER_TYPE_HARDWARE, null);

		//가로스크롤바
		setHorizontalScrollBarEnabled(true);
		//세로스크롤바
		setVerticalScrollBarEnabled(true);
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
			//컨텐츠가 화면크기 넘어갈시 가로스크롤바
			setHorizontalScrollbarOverlay(true);
			//컨텐츠가 화면크기 넘어갈시 세로스크롤바
			setVerticalScrollbarOverlay(true);
		}
		//스크롤바 false시 항상표시
		setScrollbarFadingEnabled(true);
		//디버깅 허용
		WebView.setWebContentsDebuggingEnabled(true);

		//long click block
		this.setOnLongClickListener(new OnLongClickListener() {
			@Override
			public boolean onLongClick(View v) {
				return true;
			}
		});
	}
}