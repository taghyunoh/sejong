package com.dca.sejong.common.dialog;

import android.app.Dialog;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import com.dca.sejong.R;

/**
 * 권한 거절시 보이는 다이얼로그
 */
public class PermissionDialog extends Dialog implements View.OnClickListener{

    private Button mBtPositive;
    private Context mcontext;

    private View.OnClickListener mListener;

    public PermissionDialog(Context context) {
        super(context);
        mcontext = context;
    }

    public void setListener(View.OnClickListener listener) {
        mListener = listener;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(android.view.Window.FEATURE_NO_TITLE);
        getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        setCancelable(false);

        setContentView(R.layout.dialog_permission);

        findViewById(R.id.btn_confirm).setOnClickListener(this);

    }

    @Override
    public void onClick(View view) {

        if (view.getId() == R.id.btn_confirm) {
            if (mListener != null) {
                mListener.onClick(view);
            }
            dismiss();
        }

    }
}
