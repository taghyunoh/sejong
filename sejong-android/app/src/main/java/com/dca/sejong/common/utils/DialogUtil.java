package com.dca.sejong.common.utils;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;

import com.dca.sejong.common.dialog.AppDialog;

public class DialogUtil {

    public static void alertDialog(Context context, String title, String message, String btnText, DialogInterface.OnClickListener pListener) {
        AlertDialog.Builder dialog = new AlertDialog.Builder(context);
        dialog.setCancelable(false);
        dialog.setTitle(title);
        dialog.setMessage(message);
        dialog.setPositiveButton(btnText ,pListener);
        dialog.show();
    }

    public static void alertDialog(Context context, String title, String message, String lbtn, String rbtn, DialogInterface.OnClickListener pListener, DialogInterface.OnClickListener nListener) {
        AlertDialog.Builder dialog = new AlertDialog.Builder(context);
        dialog.setCancelable(false);
        dialog.setTitle(title);
        dialog.setMessage(message);
        dialog.setPositiveButton(lbtn,pListener);
        dialog.setNegativeButton(rbtn,nListener);
        dialog.show();
    }

    public static AppDialog alert(Context context, int resId, String title, String msg, String btnPText, String btnNText, DialogInterface.OnClickListener pListener){
        return AppDialogBox(context, resId, title, msg, btnPText, btnNText, pListener);
    }

    public static AppDialog alert(Context context, String title, String msg, String btnPText, String btnNText, DialogInterface.OnClickListener pListener){
        return AppDialogBox(context, -1, title, msg, btnPText, btnNText, pListener);
    }

    public static AppDialog alert(Context context, int resId, String title, String msg, String btnText, DialogInterface.OnClickListener pListener){
        return AppDialogBox(context, resId, title, msg, null, btnText, pListener);
    }

    public static AppDialog alert(Context context, String title, String msg, String btnText, DialogInterface.OnClickListener pListener){
        return AppDialogBox(context, -1, title, msg, null, btnText, pListener);
    }

    public static AppDialog AppDialogBox(final Context context, int resId, String title, String msg, String btnPText, String btnNText, DialogInterface.OnClickListener pListener) {
        AppDialog dialog = null;
        AppDialog.Builder builder = new AppDialog.Builder(context);

        if(title != null && !title.equals(""))
            builder.setTitle(title);

        if(msg != null && !msg.equals(""))
            builder.setMessage(msg);

        if(resId != -1)
            builder.setImage(resId);

        builder.setCancelable(false);
        if(btnPText != null) builder.setBtnText(btnPText, btnNText);
        else builder.setBtnText(btnNText);

        builder.setButtonListener(new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();

                if(pListener != null)
                    pListener.onClick(dialog, which);
            }
        });

        if(context instanceof Activity && !((Activity)context).isFinishing()) {
            dialog = builder.create();
            dialog.show();
        }

        return dialog;
    }
}
