package com.dca.sejong;

import android.content.DialogInterface;
import android.os.Bundle;

import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;

import com.dca.sejong.R;
import com.dca.sejong.common.dialog.ProgressExDialog;
import com.dca.sejong.common.utils.DialogUtil;
import com.dca.sejong.common.utils.RootUtils;

public class BaseActivity extends AppCompatActivity {

    private ProgressExDialog mProgressDialog;

    protected boolean firstCheck = true;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        //캡쳐방지.
        //().addFlags(WindowManager.LayoutParams.FLAG_SECURE);

        ActionBar supportActionBar = getSupportActionBar();

        if (supportActionBar != null) {
            supportActionBar.hide();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();

        //앱에 재 진입할 때마다 확인한다.
        if(!firstCheck) {
            if(checkRooting()) {
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
            }
        }
    }

    /**
     * 프로그레스바 출력
     */
    public void showProgressDialog() {

        if (isFinishing()||isDestroyed()) return;

        if (mProgressDialog == null) {
            mProgressDialog = new ProgressExDialog(this);
            mProgressDialog.show();
        }
    }

    /**
     *  프로그레스바 종료
     */
    public void dismissProgressDialog() {
        if(isFinishing()||isDestroyed()) return;

        if (mProgressDialog != null && mProgressDialog.isShowing()) {
            mProgressDialog.dismiss();
            mProgressDialog = null;
        }
    }

    /**
     * 기기의 루팅 여부를 판단한다.
     */
    protected boolean checkRooting(){
        if(RootUtils.isDeviceRooted()) {
            return true;
        }

        return false;
    }
}
