package com.dca.sejong;

import android.app.Activity;
import android.app.Application;
import android.content.Context;

public class AppApplication extends Application
{
    private static Context mContext;

    public static boolean isTokenChange = false;
    public static String pushLinkUrl = "";

    private static volatile Activity currentActivity = null;

    @Override
    public void onCreate()
    {
        super.onCreate();

        mContext = getApplicationContext();
    }

    @Override
    public void onTerminate() {
        super.onTerminate();
        //asd
    }

    @Override
    protected void attachBaseContext(Context base)
    {
        super.attachBaseContext(base);
    }

    /**test s
     * custom class에서 context를 사용할 경우 가져다 쓴다.
     */
    public static Context getContext()
    {
        return mContext;
    }

    /**
     * 현재 실행중인 액티비티를 저장한다.
     * @param currentAct
     */
    public static void setCurrentActivity(Activity currentAct) {
        currentActivity = currentAct;
    }

    /**
     * 현재 실행중인 액티비티를 가져온다.
     * @return
     */
    public static Activity getCurrentActivity() {
        return currentActivity;
    }
}
