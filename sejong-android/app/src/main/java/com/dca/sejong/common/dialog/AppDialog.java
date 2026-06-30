package com.dca.sejong.common.dialog;

import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.graphics.drawable.ColorDrawable;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.dca.sejong.R;

public class AppDialog extends Dialog {

    public AppDialog(@NonNull Context context) {
        super(context);
    }

    public AppDialog(@NonNull Context context, int themeResId) {
        super(context, themeResId);
    }

    public static class Builder {
        private Context context;

        private boolean cancelable = false;
        private String mMessage = null;
        private String mPButtonText = null;
        private String mNButtonText = null;
        private String mTitle = null;
        private int mImgResId = -1;

        private OnClickListener mButtonClickListener = null;

        public Builder(Context context) {
            this.context = context;
        }

        public Builder setTitle(String title) {
            this.mTitle = title;
            return this;
        }

        public Builder setImage(int resId) {
            this.mImgResId = resId;
            return this;
        }

        public Builder setMessage(String message) {
            this.mMessage = message;
            return this;
        }

        public Builder setBtnText(String btnText) {
            this.mNButtonText = btnText;
            return this;
        }

        public Builder setBtnText(String btnPText, String btnNText) {
            this.mPButtonText = btnPText;
            this.mNButtonText = btnNText;
            return this;
        }

        public Builder setButtonListener(OnClickListener listener) {
            this.mButtonClickListener = listener;
            return this;
        }

        public Builder setCancelable(boolean cancelable) {
            this.cancelable = cancelable;
            return this;
        }

        public Builder getBuilder() {
            return this;
        }

        public AppDialog create() {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            final AppDialog dialog = new AppDialog(context, R.style.dialog_style);
            //final DialogOneButton dialog = new DialogOneButton(context);
            final View layout = inflater.inflate(R.layout.dialog_common, null);
            dialog.addContentView(layout, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
            dialog.getWindow().setBackgroundDrawable(new ColorDrawable(android.graphics.Color.TRANSPARENT));

            TextView txtTitle = layout.findViewById(R.id.tv_title_content);
            ImageView ivIcon = layout.findViewById(R.id.iv_icon);
            TextView txtMessage = layout.findViewById(R.id.tv_msg_content);
            TextView btnPositive = layout.findViewById(R.id.btn_positive_button);
            TextView btnNegative = layout.findViewById(R.id.btn_negative_button);

            if (txtTitle != null && (mTitle != null && mTitle != "")) {
                txtTitle.setVisibility(View.VISIBLE);
                txtTitle.setText(mTitle);
            }
            else {
                txtTitle.setVisibility(View.GONE);
            }

            if (ivIcon != null && (mImgResId != -1)) {
                ivIcon.setVisibility(View.VISIBLE);
                ivIcon.setImageResource(mImgResId);
            }
            else {
                ivIcon.setVisibility(View.GONE);
            }

            if (txtMessage != null && mMessage != null) {
                txtMessage.setText(mMessage);
            }

            if (btnPositive != null && mPButtonText != null) {
                btnPositive.setText(mPButtonText);
            }
            else {
                btnPositive.setVisibility(View.GONE);
            }

            if (btnNegative != null && mNButtonText != null) {
                btnNegative.setText(mNButtonText);
            }
            else {
                btnNegative.setVisibility(View.GONE);
            }

            if(btnPositive != null && btnNegative != null) {
                if (mButtonClickListener != null) {
                    btnPositive.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            mButtonClickListener.onClick(dialog, DialogInterface.BUTTON_POSITIVE);
                        }
                    });

                    btnNegative.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            mButtonClickListener.onClick(dialog, DialogInterface.BUTTON_NEGATIVE);
                        }
                    });
                }
            }
            else if (btnNegative != null) {
                if (mButtonClickListener != null) {
                    btnNegative.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            mButtonClickListener.onClick(dialog, DialogInterface.BUTTON_NEGATIVE);
                        }
                    });
                }
            }

            // back key
            dialog.setOnKeyListener(new OnKeyListener() {
                @Override
                public boolean onKey(DialogInterface dialog, int keyCode, KeyEvent event) {
                    return keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0 && cancelable;
                }
            });

            dialog.setCancelable(cancelable);
            dialog.setCanceledOnTouchOutside(cancelable);        // 다이얼로그 영역 밖 클릭 이벤트 반응하지 않기
            return dialog;
        }
    }
}