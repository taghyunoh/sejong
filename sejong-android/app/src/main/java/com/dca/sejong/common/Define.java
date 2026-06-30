package com.dca.sejong.common;

import android.Manifest;
import android.os.Environment;

import com.dca.sejong.BuildConfig;
import com.dca.sejong.common.utils.Logs;

public class Define {

    //Broadcast Action
    public static final String ACTION_JAVASCRIPT_CMD_200 = "action.javascript.cmd.200";
    public static final String ACTION_JAVASCRIPT_CMD_201 = "action.javascript.cmd.201";
    public static final String ACTION_JAVASCRIPT_CMD_202 = "action.javascript.cmd.202";
    public static final String ACTION_JAVASCRIPT_CMD_203 = "action.javascript.cmd.203";
    public static final String ACTION_JAVASCRIPT_CMD_301 = "action.javascript.cmd.301";
    public static final String ACTION_JAVASCRIPT_CMD_303 = "action.javascript.cmd.303";
    //http://175.106.92.89:8084/download/filename.pdf
    //Main Domain Url
  // public static final String DEV_SERVER     = "http://118.67.132.68:8080/app"; // 개발 서버
    public static final String DEV_SERVER     = "http://allcare24.kr/app";  // 배포서버(Gabia)
 //   public static final String DEV_SERVER      = "http://192.168.0.17:9060"; // (src병원)
 //   public static final String DEV_SERVER      = "http://172.16.11.243:8080"; // (집)
    public static final String STAGING_SERVER   = "http://175.106.92.89:8084";//스테징 서버
    public static final String OPER_SERVER      = "https://hciot.lh.or.kr/app";//운영 서버(한국 주택 공사)
    public static String outputFilePath = Environment.getExternalStoragePublicDirectory(
            Environment.DIRECTORY_DOWNLOADS + "/sejong") + "";
    public static final String LINK_KEY = "link";

    private static String mServerName = "개발서버";
    private static String mDefaultServerUrl = DEV_SERVER;

    public static void setBaseServerUrl(String name,String url){
        mServerName = name;
        mDefaultServerUrl = url;
    }

    public static String getServerName(){
        return mServerName;
    }

    public static String getSerVerUrl(){
        return mDefaultServerUrl;
    }

    public enum ReqUrl {
        URL_BASE                    ("/"),
        URL_LOGIN                   ("/login"),
        URL_MAIN                   ("/main"),
        URL_APP_VERSION             ("/getAppVLatestOne.do")
        ;

        private String mSCSUrl;

        ReqUrl() {
            Logs.e("construct");
        }

        ReqUrl(String url) {
            Logs.e("construct url : " + url);
            mSCSUrl = url;
        }

        public String getReqUrl() {
            String goUrl;
            if (BuildConfig.IS_DEVEL) {
                goUrl = new StringBuilder().append(mDefaultServerUrl).append(mSCSUrl).toString();
            } else {
                goUrl = new StringBuilder().append(OPER_SERVER).append(mSCSUrl).toString();
            }

            return goUrl;
        }
    }

    public static final int REQUEST_PERMISSION = 1000; //퍼미션 request code
    public static final int REQUEST_PHONE_PERMISSION = 1001; //Phone 퍼미션 request code
    public static final int REQUEST_CAMERA_PERMISSION = 1002; //Camera 퍼미션 request code
    public static final int REQUEST_GPS_PERMISSION = 1003; //GPS 퍼미션 request code
    public static final int REQUEST_RUNTIME_PERMISSION = 1004; //Runtime 퍼미션 request code

    public static String[] gPermissionList = new String[]{
            Manifest.permission.CAMERA
            ,Manifest.permission.READ_PHONE_STATE
            ,Manifest.permission.ACCESS_COARSE_LOCATION
            ,Manifest.permission.ACCESS_FINE_LOCATION
    };

    public static String[] gPermissionGpsList = new String[]{
            Manifest.permission.ACCESS_COARSE_LOCATION
            ,Manifest.permission.ACCESS_FINE_LOCATION
    };

    public static String[] gPermissionCameraList = new String[]{
            Manifest.permission.CAMERA
    };

    public static String[] gPermissionPhoneList = new String[]{
            Manifest.permission.READ_PHONE_STATE
    };
}
