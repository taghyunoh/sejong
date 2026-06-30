package com.dca.sejong.common.utils;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.content.pm.Signature;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.util.Base64;

import androidx.core.app.NotificationManagerCompat;

//import com.dca.sejong.BuildConfig;
import com.dca.sejong.common.AppPreference;

import java.security.MessageDigest;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Calendar;
import java.util.List;
import java.util.Random;


public class Utils {


    /**
     * 앱 버전명을 가져온다.
     *
     * @param context
     * @return
     */
    public static String getVersionName(Context context) {
        String version = "";
        try {

            PackageInfo i = context.getPackageManager().getPackageInfo(context.getPackageName(), 0);

            version = i.versionName;

        } catch (PackageManager.NameNotFoundException e) {
        }

        return version;
    }

    /**
     * 앱 버전 코드를 가져온다.
     *
     * @param context
     * @return
     */
    public static int getVersionCode(Context context) {
        int code = 0;
        try {

            PackageInfo i = context.getPackageManager().getPackageInfo(context.getPackageName(), 0);

            code = i.versionCode;

            Logs.e("version code : " + code);

        } catch (PackageManager.NameNotFoundException e) {
        }

        return code;
    }

    //IMEI 또는 Android ID값을 가져온다.
    @SuppressLint("MissingPermission")
    public static String getDeivceIMEI(Context context) {
        //TelephonyManager 초기화
        TelephonyManager telephonyManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);

        Logs.e("IMEI : " + telephonyManager.getDeviceId());

        return telephonyManager.getDeviceId();
    }

    /*
    * Android ID는 android OS 8이상부터 debug,release에 따라서 달라진다. Flavor에 따라서는 변경되지 않는다.
    * 그래서 개발 디버깅을 할려고 할경우엔 devel-release를 설치하여 디버깅하는 것이 좋을 것이다.
    * */
    public static String getAndroidID(Context context){
        String androidId = Settings.Secure.getString(context.getContentResolver(),
                Settings.Secure.ANDROID_ID);

        Logs.e("androidId : " + androidId);
        return androidId;
    }


    /**
     * 유니크 ID 반환
     * @return
     */

    public static String getUniqueID(Context context) {
        String telephonyDeviceId = getDeivceIMEI(context);
        String androidDeviceId = getAndroidID(context);

        if (TextUtils.isEmpty(telephonyDeviceId)) {
            telephonyDeviceId = "NoTelephonyId";
            Logs.e("telephonyDeviceId : " + telephonyDeviceId);
        }

        // build up the uuid
        try {
            StringBuffer strBuf = new StringBuffer();
            strBuf.append(getStringIntegerHexBlocks(androidDeviceId.hashCode()))
                    .append("-")
                    .append(getStringIntegerHexBlocks(telephonyDeviceId.hashCode()));
            return strBuf.toString();
        } catch (Exception e) {
            Logs.printException(e);
            return androidDeviceId;
        }
    }

    /**
     *  Hex 문자열 반환
     * @param value
     * @return
     */
    public static String getStringIntegerHexBlocks(int value) {
        String result = "";
        String string = Integer.toHexString(value);

        int remain = 8 - string.length();
        char[] chars = new char[remain];
        Arrays.fill(chars, '0');
        string = new String(chars) + string;

        int count = 0;
        for (int i = string.length() - 1; i >= 0; i--) {
            count++;
            result = string.substring(i, i + 1) + result;
            if (count == 4) {
                result = "-" + result;
                count = 0;
            }
        }

        if (result.startsWith("-")) {
            result = result.substring(1, result.length());
        }
        return result;
    }

    /**
     * 문장 내, 같은 글자 반복 확인
     * @param target 전체문장
     * @param duplicate 반복 횟수
     * @return
     */
    public static boolean isDuplicate(String target, int duplicate) {
        for (int index = 0; index < target.length(); index++) {
            char toCheck = target.charAt(index);
            int countCheck = 0;
            boolean isStart = false;
            for (char ch: target.toCharArray()) {
                if (ch == toCheck) {
                    if (!isStart) isStart = true;
                    if (isStart) countCheck++;
                } else {
                    isStart = false;
                    countCheck = 0;
                }

                if (countCheck == duplicate)
                    return true;
            }
        }
        return false;
    }

    /**
     * 문장 내, 세숫자가 연속적인 숫자인지 확인
     * @param target 전체문장
     * @param limit 체크할 연속 숫자 길이
     * @return limit길이만큼 연속된 숫자가 있으면 true
     */
    public static boolean isContinueNum(String target, int limit) {
        int o = 0;
        int d = 0;
        int p = 0;
        int n = 0;

        // 체크할 문자길이가 최소 3자 이상이어야 함
        if (limit < 3)
            return false;

        for (int i = 0 ; i < target.length() ; i++) {
            char c = target.charAt(i);
            p = o - c;
            if (i > 0 && (p == -1 || p == 1) && (n = p == d ? n + 1 : 0) > limit - 3)
                return true;
            d = p;
            o = c;
        }

        return false;
    }

    /**
     * 0~9까지 랜덤 배열을 생성한다.
     * @return 0~9까지의 랜덤배열
     */
    public static int[] makeRandomKeypad(){
        int[] array = new int[10];

        Random rand = new Random();
        for(int i = 0; i < 10; i++) {
            int iValue = rand.nextInt(10);

            //Logs.e("makeRandomKeypad : " + i + " - " + iValue);

            array[i] = iValue;
            for(int j=0;j<i;j++){
                if(iValue == array[j]){
                    i--;

                    break;
                }
            }
        }
        return array;
    }

    //signingConfig를 변경했으면 아래 값도 반드시 변경하도록 한다.
    //private static final String SIGN_KEY_VAL = "W6qHq5GfSfbwJ1vgQmZSXeetbnw=";
    private static final String ENC_SIGN_KEY_VAL = "NXloTmpXSXN5MGZQT2x2MUhQMGNDYUxDWEpLWU54V0ZZOE10R2kzZ1JFRT0K";
    //IntroActivity.java의 onCreate에서 호출해서 간단하게 ENC_SIGN_KEY_VAL의 값을 바꿔주도록한다.
/*
    public static void makeEncSignKeyVal(Context context){
        byte[] encSignKeyVal = AES128Utils.encodeAES(SIGN_KEY_VAL).getBytes();
        String encSignKeyStr = Base64.encodeToString(encSignKeyVal,Base64.NO_WRAP);

        //앱의 Sign key가 변경된다면
        //아래 로그에서 찍히는 값으로 ENC_SIGN_KEY_VAL의 값을 변경하도록 한다.
        Logs.e("makeEncSignKeyVal - encSignKeyStr : " + encSignKeyStr);
    }
*/

    @SuppressLint("PackageManagerGetSignatures")
    public static String getAppSignKey(Activity context){

        String signatureBase64 = "";
        String packageName = context.getPackageName();
        //Logs.e("getAppSignVal-Build.VERSION.SDK_INT : " + Build.VERSION.SDK_INT);
        try {
            if(Build.VERSION.SDK_INT >= 28){
                final PackageInfo packageInfo = context.getPackageManager().getPackageInfo(packageName, PackageManager.GET_SIGNING_CERTIFICATES);
                final Signature[] signatures = packageInfo.signingInfo.getApkContentsSigners();
                final MessageDigest md = MessageDigest.getInstance("SHA");
                for (Signature signature : signatures) {
                    md.update(signature.toByteArray());
                    signatureBase64 = new String(Base64.encode(md.digest(), Base64.DEFAULT));
                    //Logs.e("getAppSignVal : " + signatureBase64);
                }
            }else{
                PackageInfo packageInfo = context.getPackageManager().getPackageInfo(context.getPackageName(), PackageManager.GET_SIGNATURES);
                final MessageDigest md = MessageDigest.getInstance("SHA");
                for(int i = 0; i < packageInfo.signatures.length; i++){
                    Signature signature = packageInfo.signatures[i];
                    md.update(signature.toByteArray());
                    signatureBase64 = new String(Base64.encode(md.digest(), Base64.DEFAULT));
                    //Logs.e("getAppSignVal : " + signatureBase64);
                }
            }
        } catch(Exception e) {
            Logs.printException(e);
        }

        signatureBase64 = signatureBase64.trim();

        return signatureBase64;


    }

    public static boolean checkHackingApp(Activity context){

/*        if(BuildConfig.IS_DEVEL){
            return false;
        }*/

        String signatureBase64 = getAppSignKey(context);

        byte[] encSignKeyVal = Base64.decode(ENC_SIGN_KEY_VAL,Base64.NO_WRAP);

        String signKeyVal = AES128Utils.decodeAES(new String(encSignKeyVal));

        //Logs.e("checkHackingApp - signKeyVal : " + signKeyVal);
        if(!signatureBase64.equals(signKeyVal)){
            return true;
        }

        return false;
    }

    public static boolean checkAppVersionUP(Context context,String server_version){
        String deviceAppVer = Utils.getVersionName(context);

        if(TextUtils.isEmpty(server_version)) return false;

        String[] serverVer = server_version.split("\\.");
        String[] appVer = deviceAppVer.split("\\.");

        int minLen = Math.min(serverVer.length,appVer.length);

        for(int i=0;i<minLen;i++){
            if(Integer.parseInt(serverVer[i]) > Integer.parseInt(appVer[i])){
                return true;
            }
        }

        //서버문자열의 길이가 더 길면 버전 높다는 뜻.
        if(serverVer.length > appVer.length) return true;

        return false;
    }

    public static boolean compareAppVersion(Context context,String server_version){
        String deviceAppVer = Utils.getVersionName(context);

        if(TextUtils.isEmpty(server_version)) return false;

        if(deviceAppVer.equalsIgnoreCase(server_version))
            return true;

        return false;
    }

    /**
     * 앱 알림 설정 여부
     * @param context
     * @return
     */
    public static boolean isNotificationsEnabled(Context context) {
        return NotificationManagerCompat.from(context).areNotificationsEnabled();
    }

    /**
     * 알림 설정 화면으로 이동
     * @param context
     */
    public static void goNotificationsSetting(Context context) {
        Intent intent = new Intent();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            intent.setAction(Settings.ACTION_APP_NOTIFICATION_SETTINGS);
            intent.putExtra(Settings.EXTRA_APP_PACKAGE, context.getPackageName());
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP){
            intent.setAction("android.settings.APP_NOTIFICATION_SETTINGS");
            intent.putExtra("app_package", context.getPackageName());
            intent.putExtra("app_uid", context.getApplicationInfo().uid);
        } else {
            intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
            intent.addCategory(Intent.CATEGORY_DEFAULT);
            intent.setData(Uri.parse("package:" + context.getPackageName()));
        }
        context.startActivity(intent);
    }

    /**
     * Google Store 이동
     * @param context
     * @param packageName
     */
    public static void goPlayStore(Context context, String packageName) {
        try {
            context.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + packageName)));
        } catch(Exception ex) {
            context.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id="+ packageName)));
        }
    }

    public static String getLauncherClassName(Context context) {
        Intent intent = new Intent(Intent.ACTION_MAIN);
        intent.addCategory(Intent.CATEGORY_LAUNCHER);
        intent.setPackage(context.getPackageName());

        List<ResolveInfo> resolveInfoList = context.getPackageManager().queryIntentActivities(intent, 0);
        if(resolveInfoList != null && resolveInfoList.size() > 0) {
            return resolveInfoList.get(0).activityInfo.name;
        }
        return "";
    }

    public static void updateIconBadgeCount(Context context, int count) {
        AppPreference.setLauncherBadge(count);
        Intent intent = new Intent("android.intent.action.BADGE_COUNT_UPDATE");

        // Component를 정의
        intent.putExtra("badge_count_package_name", context.getPackageName());
        intent.putExtra("badge_count_class_name", getLauncherClassName(context));

        // 카운트를 넣어준다.
        intent.putExtra("badge_count", count);

        if(Build.VERSION.SDK_INT > Build.VERSION_CODES.GINGERBREAD_MR1) {
            // Version이 3.1이상일 경우에는 Flags를 설정하여 준다.
            intent.setFlags(Intent.FLAG_INCLUDE_STOPPED_PACKAGES);
        }

        // send
        context.sendBroadcast(intent);
    }

    public static String fmtDate(Calendar calendar, String fmt) {
        String result = null;
        try {
            if (calendar == null) {
                return "";
            }
            SimpleDateFormat format = new SimpleDateFormat(fmt);
            result = format.format(calendar.getTime());
        } catch (Exception ex) {
            ex.printStackTrace();
            result = "";
        }
        Logs.e("Data : " + result);
        return result;
    }

    public static String customUserAgent(Context context) {
        StringBuilder sb = new StringBuilder();

        sb.append("APP_HEADER=").append("SejongHealth");
        sb.append(";").append("DEVICE_APP_VER=").append(getVersionName(context));
        sb.append(";").append("DEVICE_TYPE=").append("Mobile");
        sb.append(";").append("DEVICE_MODEL=").append(Build.MODEL);
        sb.append(";");

        return sb.toString();
    }
}
