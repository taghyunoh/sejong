package com.dca.sejong.splash;

import androidx.activity.OnBackPressedCallback;
import androidx.appcompat.app.AppCompatActivity;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ObjectAnimator;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.view.animation.AnticipateInterpolator;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.core.splashscreen.SplashScreen;

import com.dca.sejong.AppApplication;
import com.dca.sejong.BaseActivity;
import com.dca.sejong.MainActivity;
import com.dca.sejong.R;
import com.dca.sejong.MainActivity;
import com.dca.sejong.common.AppPreference;
import com.dca.sejong.common.Define;
import com.dca.sejong.common.dialog.PermissionDialog;
import com.dca.sejong.common.net.HttpSenderTask;
import com.dca.sejong.common.net.HttpUtils;
import com.dca.sejong.common.utils.DialogUtil;
import com.dca.sejong.common.utils.Logs;
import com.dca.sejong.common.utils.PermissionUtils;
import com.dca.sejong.common.utils.Utils;

public class SplashActivity extends BaseActivity {

    private static final String TAG = SplashActivity.class.getSimpleName();

    private Context mContext;
    private Handler mHandler;

    private long backKeyPressedTime = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        SplashScreen splashScreen = SplashScreen.installSplashScreen(this);
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);
        mContext = this;
        mHandler = new Handler();
        /*Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                checkRootingDevice();
            }
        },100);*/
        Logs.e("Test");
        getOnBackPressedDispatcher().addCallback(this, callback);
        showProgressDialog();
        //에뮬레이터 여부 확인. sdk로 시작하면 에뮬레이터
        //Logs.shwoToast(this,"android.os.Build.MODEL : " + android.os.Build.MODEL);
        checkRootingDevice();
    }
    /*@Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        Bundle extras = getIntent().getExtras();
        Logs.e("[LogoActivity onNewIntent] extras : " + extras);
        if(extras != null) {
            AppApplication.pushLinkUrl = extras.getString(Define.LINK_KEY);
            Logs.e("[LogoActivity onNewIntent] pushLinkUrl : " + AppApplication.pushLinkUrl);
        }
    }*/
    private Runnable mRunable = new Runnable() {
        @Override
        public void run() {
            startActivity(new Intent(SplashActivity.this, MainActivity.class));
            //finish();
        }
    };
    @Override
    protected void onResume() {
        super.onResume();
        /*String sha1 = getkeyHash();
        Logs.e("sha1 : " + sha1);*/
        AppApplication.setCurrentActivity(this);
    }
    OnBackPressedCallback callback = new OnBackPressedCallback(true) {
        @Override
        public void handleOnBackPressed() {
            if (System.currentTimeMillis() > backKeyPressedTime + 1500) {
                backKeyPressedTime = System.currentTimeMillis();
                Toast.makeText(SplashActivity.this, R.string.str_app_finish_confirm, Toast.LENGTH_SHORT).show();
                return;
            }
            if (System.currentTimeMillis() <= backKeyPressedTime + 1500) {
                finish();
            }
        }
    };

/*    @Override
    public void onBackPressed() {
        super.onBackPressed();
        if (System.currentTimeMillis() > backKeyPressedTime + 1500) {
            backKeyPressedTime = System.currentTimeMillis();
            Toast.makeText(this, R.string.str_app_finish_confirm, Toast.LENGTH_SHORT).show();
            return;
        }

        if (System.currentTimeMillis() <= backKeyPressedTime + 1500) {
            mHandler.removeCallbacks(mRunable);
            finish();
        }
    }*/
    /**
     * 기기의 루팅 여부를 판단한다.
     */
    void checkRootingDevice(){
        if(checkRooting()){
            dismissProgressDialog();

            DialogUtil.alertDialog(this,
                    getString(R.string.str_rooting_title),
                    getString(R.string.str_rooting_content),
                    getString(R.string.confirm),
                    new DialogInterface.OnClickListener()
                    {
                        public void onClick(DialogInterface dialog, int which)
                        {
                            finish();
                        }
                    });
        }else{
            Logs.d("checkRootingDevice result : false" );
            checkNetStatus();
            firstCheck = false;
        }
    }

    /**
     * 네트워크 상태를 체크한다.
     */
    private void checkNetStatus() {
        HttpUtils.NetState state = HttpUtils.checkNetworkState(this);
        //인터넷 상태 체크
        Logs.d("network result : " + state);
        if (state == HttpUtils.NetState.NET_STATE_OFFLINE || state == HttpUtils.NetState.NET_STATE_NOT_SUPPORT) {
            dismissProgressDialog();

            DialogUtil.alert(mContext,
                    R.drawable.icon_network,
                    getString(R.string.str_network_error_title),
                    getString(R.string.str_network_error_content),
                    getString(R.string.app_finish),
                    getString(R.string.retry),
                    new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            if(which == DialogInterface.BUTTON_NEGATIVE) {
                                dialog.dismiss();
                                checkNetStatus();
                            }
                            else {
                                finish();
                            }
                        }
                    });
        } else {
            //앱버전 체크 필요할시
            //appVersionCheck();
            permissionCheck();
            //mHandler.postDelayed(mRunable, 1000);
        }
    }
    /**
     * 기기의 퍼미션을 체크 한다.
     */
    void permissionCheck(){
        Logs.d("permissionCheck start --" );
        if (!AppPreference.getFirstRun() && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            showPermissionGuide();
        }
        else {
            goToWebMain();
        }
    }

    /**
     * 퍼미션 다이얼로그를 불러온다.
     */
    private void showPermissionGuide(){
        PermissionDialog dialog = new PermissionDialog(this);
        dialog.setListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                AppPreference.setFirstRun(true);
                PermissionUtils.requestPermission(SplashActivity.this,Define.gPermissionList, Define.REQUEST_PERMISSION);
            }
        });

        if(!isFinishing() && !isDestroyed())
            dialog.show();
    }
    public void onRequestPermissionsResult(int requestCode, @Nullable String[] permissions, @Nullable int[] grantResults) {

        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        Logs.i("onRequestPermissionsResult - requestCode : " + requestCode);

        //권한 동의여부 상관없이 무조건 webview 로 넘어감.
        goToWebMain();
    }
    /**
     * 웹뷰로 전환한다.
     * URL을 Intent로 넘겨서 받도록 한다.
     */
    void goToWebMain(){
        String url = Define.ReqUrl.URL_BASE.getReqUrl();
        String param = "";
        Intent intent = new Intent(SplashActivity.this, MainActivity.class);
        if(url != null && url.length() > 0){
            intent.putExtra("url",url);
        }
        if(param.length() > 0){
            intent.putExtra("param",param);
        }
        startActivity(intent);
        finish();;
    }
}