package com.dca.sejong.web;

public class JavaScriptCmd {
	/**
	 * Web Page와의 인터페이스 함수 선언
	 */
	public static final int CMD_UNKNOWN = -1;

	public static final int CMD_100 = 100; //앱종료
	public static final int CMD_101 = 101; //로그인 정보 가저오기
	public static final int CMD_102 = 102; //로그인 정보 저장 & push token response
	public static final int CMD_200 = 200; //isens 연동
	public static final int CMD_201 = 201; //푸드렌즈 카메라 연동
	public static final int CMD_202 = 202; //푸드렌즈 상세 연동
	public static final int CMD_203 = 203; //푸드렌지 이미지 전달
	public static final int CMD_301 = 301; //헬스데이터 연동
	//public static final int CMD_303 = 303; //Bluetooth Connect
	/**
	* Web과 Interface하면 URL encoding할 경우 캐릭터 타입으로 특수문자가 들어가는 경우가
	* 발생하여 제거해주는 함수를 추가함.
	**/
	public static String makeNewJsonString(String jsonEncodeString){
		String jsonString = jsonEncodeString;
		int bodyPos = jsonString.indexOf("body");
		if(bodyPos > 0){
			String headerStr = jsonString.substring(0,bodyPos);
			String bodyStr = jsonString.substring(bodyPos,jsonString.length());

			bodyStr = bodyStr.replace("\"\"{","{");
			bodyStr = bodyStr.replace("}\"\"}","}}");

			return headerStr + bodyStr;
		}else{
			return jsonString;
		}

	}
}