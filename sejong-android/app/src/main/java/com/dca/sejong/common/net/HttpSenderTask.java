package com.dca.sejong.common.net;

import android.os.AsyncTask;
import android.text.TextUtils;

import com.dca.sejong.common.utils.Logs;

import org.json.JSONException;
import org.json.JSONObject;

public class HttpSenderTask extends AsyncTask<String, Void, String> {
    private String mUrl;
    private HttpRequestListener mListener;

    public HttpSenderTask(String url, HttpRequestListener l){
        mUrl = url;
        mListener = l;
    }

    @Override
    protected String doInBackground(String... params) {
        String retString=null;

        if(params.length == 0 || TextUtils.isEmpty(params[0])){
            retString = HttpSender.requestGet(mUrl);
        }else{
            //Logs.e("HttpSenderTask : " + params[0]);
            retString = HttpSender.requestPost(mUrl,(String)params[0]);
        }

        return retString;
    }

    @Override
    protected void onPostExecute(String s) {
        super.onPostExecute(s);
        Logs.e("onPostExecute : " + s);
        try {
            JSONObject jsonObj = new JSONObject(s);
            mListener.endHttpRequest(jsonObj.optInt(HttpUtils.REQ_CODE), jsonObj.optString(HttpUtils.REQ_MSG));
        } catch (JSONException e) {
            Logs.printException(e);
            mListener.endHttpRequest(0,"");
        }


    }

    public interface HttpRequestListener{
        void endHttpRequest(int code,String ret);
    }
}
