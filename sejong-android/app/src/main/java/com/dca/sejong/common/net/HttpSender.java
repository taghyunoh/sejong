package com.dca.sejong.common.net;

import android.annotation.SuppressLint;
import android.os.Build;
import android.text.TextUtils;
import android.util.Log;

import com.dca.sejong.common.utils.Logs;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import static org.apache.http.conn.ssl.SSLSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER;


public class HttpSender {


	public static final int DEFAULT_CONNECT_TIMEOUT  = 15*1000;//HTTP 연결에 대한 기본 Timeout
	public static final int DEFAULT_READ_TIMEOUT	 = 15*1000;//HTTP 연결 이후 Input Stream 읽기에 대한 기본 Timeout

	/**
	 * HTTP GET 요청을 수행한다.
	 *
	 * @param urlStr 요청 URL
	 * @return 응답 문자열
	 */
	@SuppressLint("AllowAllHostnameVerifier")
	public static String requestGet(String urlStr){
		Logs.e("requestGet - Url : " + urlStr);

		int responseCode=0;
		StringBuilder sBuilder = new StringBuilder();
		String body="";
		URL url=null;
		HttpURLConnection mConn=null;

		try{

			url = new URL(urlStr);

			if (url.getProtocol().toLowerCase().equals("https")) {
				if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.LOLLIPOP)
					trustAllHosts();

				HttpsURLConnection https = (HttpsURLConnection) url.openConnection();
				if (Build.VERSION.SDK_INT > Build.VERSION_CODES.LOLLIPOP)
					https.setHostnameVerifier(ALLOW_ALL_HOSTNAME_VERIFIER);
				else
					https.setHostnameVerifier(ALWAYS_VERIFY);

				mConn = https;
			} else {
				mConn = (HttpURLConnection) url.openConnection();
			}
			
			if(mConn != null){
				mConn.setConnectTimeout(DEFAULT_CONNECT_TIMEOUT);
				mConn.setReadTimeout(DEFAULT_READ_TIMEOUT);
				mConn.setRequestMethod("GET");
				mConn.setUseCaches(false);

				HttpUtils.setCooKie(urlStr,mConn);

				//mConn.setRequestProperty("Content-Type", "application/json;charset=utf-8");
				mConn.setRequestProperty("User-Agent", HttpUtils.mUserAgent);
				//HttpUtils.printHeader("",mConn);

				responseCode = mConn.getResponseCode();
				Logs.e("mConn.getResponseCode() : " + responseCode);
				if(responseCode != HttpURLConnection.HTTP_OK) {
					mConn.disconnect();
					return HttpUtils.makeReturnJsonStr(responseCode,body);
				}

				HttpUtils.saveCookie(mConn);

				BufferedReader br = new BufferedReader(
						new InputStreamReader(mConn.getInputStream(), HttpUtils.CHARSET_TYPE));

				for (;;){

					String line = br.readLine();

					if(line == null){
						break;
					}
					Log.e("TAG", "line : " + line);

					sBuilder.append(line).append('\n');
				}

				br.close();

				body = sBuilder.toString();

			}
		} catch(Exception e){
			Logs.printException(e);
		}

		if(mConn != null)
			mConn.disconnect();

		return HttpUtils.makeReturnJsonStr(responseCode,body.trim());
	}



	/**
	 * HTTP POST 요청을 수행한다.
	 * @param urlStr 요청 URL
	 * @param param 요청 파라미터 문자열
	 * @return 응답 문자열
	 */
	@SuppressLint("AllowAllHostnameVerifier")
	public static String requestPost(String urlStr, String param){
		Logs.e("0.requestPost - urlStr : " + urlStr);
		Logs.e("1.requestPost - param : " + param);
		int responseCode=0;
		StringBuilder sBuilder = new StringBuilder();
		String body="";
		URL url=null;
		HttpURLConnection mConn=null;

		try{

			url = new URL(urlStr);

			if (url.getProtocol().toLowerCase().equals("https")) {
				if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.LOLLIPOP)
					trustAllHosts();

				HttpsURLConnection https = (HttpsURLConnection) url.openConnection();
				if (Build.VERSION.SDK_INT > Build.VERSION_CODES.LOLLIPOP)
					https.setHostnameVerifier(ALLOW_ALL_HOSTNAME_VERIFIER);
				else
					https.setHostnameVerifier(ALWAYS_VERIFY);

				mConn = https;
			} else {
				mConn = (HttpURLConnection) url.openConnection();
			}

			if(mConn != null){
				mConn.setConnectTimeout(DEFAULT_CONNECT_TIMEOUT);
				mConn.setReadTimeout(DEFAULT_READ_TIMEOUT);
				mConn.setRequestMethod("POST");
				mConn.setUseCaches(false);
				mConn.setDoInput(true);
				mConn.setDoOutput(true);

				HttpUtils.setCooKie(urlStr,mConn);

				//이것 설정하지 말것.서버 프레임웍에서 원할 경우 추가.
				//mConn.setRequestProperty("Content-Type", "application/json;charset=utf-8");
				if (!TextUtils.isEmpty(HttpUtils.mUserAgent))
				    mConn.setRequestProperty("User-Agent", HttpUtils.mUserAgent);

				if(param != null && param.length() > 0){
					OutputStream os = mConn.getOutputStream();
					os.write(param.getBytes(HttpUtils.CHARSET_TYPE));
					os.flush();
				}

				responseCode = mConn.getResponseCode();
				Logs.e("mConn.getResponseCode() : " + responseCode);
				if(responseCode != HttpURLConnection.HTTP_OK) {
					mConn.disconnect();
					return HttpUtils.makeReturnJsonStr(responseCode,body);
				}

				HttpUtils.saveCookie(mConn);

				BufferedReader br = new BufferedReader(	new InputStreamReader(mConn.getInputStream(), HttpUtils.CHARSET_TYPE));


				for (;;){
					String line = br.readLine();

					if(line == null){
						break;
					}

					sBuilder.append(line).append('\n');
					Logs.e("mConn. loop() : " + sBuilder.toString());
				}

				br.close();
				body = sBuilder.toString();

			}
		} catch(Exception e){
			Logs.printException(e);
		} finally {
			if(mConn != null) {
				mConn.disconnect();
			}
		}

		return HttpUtils.makeReturnJsonStr(responseCode,body.trim());
	}


	// always verify the host
	static final HostnameVerifier ALWAYS_VERIFY = new HostnameVerifier() {
		public boolean verify(String hostname, SSLSession session) {
			return true;
		}
	};

	/**
	 * Trust every server
	 */
	private static void trustAllHosts() {
		// Create a trust manager
		TrustManager[] trustAllCerts = new TrustManager[] { new X509TrustManager() {
			public X509Certificate[] getAcceptedIssuers() {
				return new X509Certificate[] {};
			}

			@Override
			public void checkClientTrusted(X509Certificate[] chain,
                                           String authType) throws CertificateException {
			}

			@Override
			public void checkServerTrusted(X509Certificate[] chain,
                                           String authType) throws CertificateException {
			}
		}};

		// Install the all-trusting trust manager
		try {
			SSLContext sc = SSLContext.getInstance("TLS");
			sc.init(null, trustAllCerts, new java.security.SecureRandom());
			HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
		}
		catch (Exception e) {
			//e.printStackTrace();
		}
	}
}
