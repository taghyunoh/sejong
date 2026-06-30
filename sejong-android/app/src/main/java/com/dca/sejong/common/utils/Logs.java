package com.dca.sejong.common.utils;

import android.content.Context;
import android.util.Log;
import android.widget.Toast;

import com.dca.sejong.BuildConfig;

public class Logs {
	private static String TAG = "Sejong Health";

	private static boolean isDebug = BuildConfig.IS_DEVEL;
	private static Toast mToast;

	/**
	 * 에러로그
	 *
	 * @param msg 내용
	 */
	public static void e(String msg){
		if(isDebug){
			Log.e(TAG,msg);
		}
	}

	/**
	 * 에러로그
	 *
	 * @param tag 태그
	 * @param msg 내용
	 */
	public static void e(String tag, String msg){
		if(isDebug){
			Log.e(tag,msg);
		}
	}

	/**
	 * 에러로그
	 *
	 * @param cls 	액티비티
	 * @param msg	메세지
	 */
	public static void e(Class cls, String msg){
		if(isDebug){
			Log.e(cls.getSimpleName(),msg);
		}
	}

	/**
	 * 디버그로그
	 * @param msg 내용
	 */
	public static void d(String msg){
		if(isDebug){
			Log.d(TAG,msg);
		}
	}

	/**
	 * 디버그로그
	 * @param tag 태그
	 * @param msg 내용
	 */
	public static void d(String tag, String msg){
		if(isDebug){
			Log.d(tag,msg);
		}
	}

	/**
	 * 인포로그
	 * @param tag 태그
	 * @param msg 내용
	 */
	public static void i(String tag, String msg){
		if(isDebug){
			Log.i(tag,msg);
		}
	}

	/**
	 * 인포로그
	 * @param msg 내용
	 */
	public static void i(String msg){
		if(isDebug){
			Log.i(TAG,msg);
		}
	}

	/**
	 * 길이가 무지 긴 인포로그 볼때 사용
	 * @param msg 내용
	 */
	public static void li(String msg){
		int maxLogSize = 1000;
		for(int i = 0; i <= msg.length() / maxLogSize; i++) {
			int start = i * maxLogSize;
			int end = (i+1) * maxLogSize;
			end = end > msg.length() ? msg.length() : end;
			if (isDebug) {
				Log.i(TAG, msg.substring(start, end));
			}
		}
	}


	/**
	 * Exeption로그
	 *
	 * @param e Exeption정보
	 */
	public static void printException(Exception e) {
		if(isDebug){
			Log.e(TAG, "printException >> " + Log.getStackTraceString(e));
		}
    }

	/**
	 * Exeption로그
	 *
	 * @param msg Exeption내용
	 */
	public static void printException(String msg) {
		if(isDebug){
			Log.e(TAG, "printException >> " + msg);
		}
	}

	/**
	 * Exeption로그
	 *
	 * @param tag 태그
	 * @param msg Exeption내용
	 */
	public static void printException(String tag, String msg) {
		if(isDebug){
			Log.e(TAG, tag + ", printException >> " + msg);
		}
	}

	/**
	 * Toast 출력
	 *
	 * @param context
	 * @param resId 문자열ID
	 */
	public static void shwoToast(Context context, int resId){
		shwoToast(context,context.getString(resId));
	}

	/**
	 * Toast 출력
	 *
	 * @param context
	 * @param msg	문자열내용
	 */
	public static void shwoToast(Context context, String msg){
		if(mToast!=null){
			mToast.cancel();
			mToast = null;
		}
		mToast = Toast.makeText(context,msg, Toast.LENGTH_LONG);
		//mToast.setGravity(Gravity.BOTTOM,0,400);
		mToast.show();
	}
}
