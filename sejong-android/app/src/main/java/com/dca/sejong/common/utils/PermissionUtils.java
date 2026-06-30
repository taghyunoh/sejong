package com.dca.sejong.common.utils;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.util.ArrayList;


public class PermissionUtils {
    public static boolean checkPermission(Activity activity, String[] pList){

        for(int i=0;i<pList.length;i++){
            int perStatus = ContextCompat.checkSelfPermission(activity, pList[i]);
            if(perStatus == PackageManager.PERMISSION_DENIED){
                return false;
            }
        }

        return true;

    }

    public static void requestPermission(Activity activity, String[] pList, int requestCode){
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            ActivityCompat.requestPermissions(activity, pList, requestCode);
        }
    }

    public static void checkRuntimePermission(Activity activity, String[] pList, int requestCode) {
        ArrayList<String> arrList = new ArrayList<String>();
        for(String permission : pList){
            if (ContextCompat.checkSelfPermission(activity, permission) != PackageManager.PERMISSION_GRANTED) {
                arrList.add(permission);
            }
        }

        String[] strArray = new String[arrList.size()];
        strArray = arrList.toArray(strArray);
        requestPermission(activity, strArray, requestCode);
    }

    /*
    1.true 일 경우
    사용자가 이전 요청에서 거부했을 경우

    2.false 일 경우
    사용자가 이전 요청에서 동의했을 경우
    '다시 묻지 않기' 체크 후 거부했을 경우
    사용자 기기에서 해당 권한에 대해 거부했을 경우
    */

    public static boolean checkNoReplyState(Activity activity,String permission){
        return ActivityCompat.shouldShowRequestPermissionRationale(activity,permission);
    }

    public static void goAppSettingsActivity(Context context){
        Uri uri = Uri.parse("package:"+ context.getPackageName());
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).setData(uri);
        context.startActivity(intent);
    }
}
