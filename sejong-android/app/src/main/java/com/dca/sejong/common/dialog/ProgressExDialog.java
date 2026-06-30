package com.dca.sejong.common.dialog;

import android.app.Dialog;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;

import com.dca.sejong.R;

public class ProgressExDialog extends Dialog {

    public ProgressExDialog(Context context) {
        super(context);

        requestWindowFeature(android.view.Window.FEATURE_NO_TITLE);
        getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        setCancelable(false);

        getWindow().setDimAmount(0.2f);
        setContentView(R.layout.dialog_progress);



        ImageView circleView = findViewById(R.id.iv_circle);
        Animation animation = AnimationUtils.loadAnimation(context, R.anim.rotate);
        circleView.setAnimation(animation);

    }
}