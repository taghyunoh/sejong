package com.dca.sejong.common;
import com.dca.sejong.AppApplication;
import com.dca.sejong.common.utils.Logs;

import java.util.HashSet;
import java.util.Set;

public class AppPreference {
    //DEFINE KEY
    private static final String FIRST_RUN = "first_run";
    private static final String USER_LOGIN_INFO = "user_login_info";
    private static final String PUSH_TOKEN = "push_token";
    private static final String PUSH_LAUNCHBADGE = "launch_badge";
    private static final String COOKIE_VALUE = "cookie_value";
    private static final String TOKEN_CHANGED = "token_changed";

    //HANDLE PREFERENCE
    public static void setFirstRun(boolean complete) {
        PreferenceManager.setBoolean(AppApplication.getContext(), FIRST_RUN, complete);
    }

    public static boolean getFirstRun() {
        return PreferenceManager.getBoolean(AppApplication.getContext(), FIRST_RUN);
    }

    public static String getUserLoginInfo() {
        return PreferenceManager.getString(AppApplication.getContext(), USER_LOGIN_INFO);
    }

    public static void setUserLoginInfo(String userLoginInfo) {
        PreferenceManager.setString(AppApplication.getContext(), USER_LOGIN_INFO, userLoginInfo);
    }

    public static String getToken() {
        return PreferenceManager.getString(AppApplication.getContext(), PUSH_TOKEN);
    }

    public static void setToken(String token) {
        PreferenceManager.setString(AppApplication.getContext(), PUSH_TOKEN, token);
    }

    public static int getLauncherBadge() {
        return PreferenceManager.getInt(AppApplication.getContext(), PUSH_LAUNCHBADGE);
    }

    public static void setLauncherBadge(int count) {
        PreferenceManager.setInt(AppApplication.getContext(), PUSH_LAUNCHBADGE, count);
    }

    public static Set<String> getCookies() {
        return PreferenceManager.getHashSet(AppApplication.getContext(), COOKIE_VALUE);
    }

    public static void setCookies(HashSet<String> cookie) {
        PreferenceManager.setHashSet(AppApplication.getContext(), COOKIE_VALUE, cookie);
    }

    public static void setTokenChanged(boolean changed) {
        PreferenceManager.setBoolean(AppApplication.getContext(), TOKEN_CHANGED, changed);
    }

    public static boolean getTokenChanged() {
        return PreferenceManager.getBoolean(AppApplication.getContext(), TOKEN_CHANGED);
    }
}
