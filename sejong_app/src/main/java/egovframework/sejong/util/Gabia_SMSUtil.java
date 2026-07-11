package egovframework.sejong.util;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Random;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

/**
 * 가비아(Gabia) 문자 API - 휴대폰 인증번호(SMS) 발송 유틸
 *  1) 액세스 토큰 발급 : POST https://sms.gabia.com/oauth/token
 *       Header  Authorization: Basic base64(SMS_ID:API_KEY)
 *       Body    grant_type=client_credentials
 *       Resp    { "access_token": "...", ... }
 *  2) 단문(SMS) 발송   : POST https://sms.gabia.com/api/send/sms
 *       Header  Authorization: Basic base64(SMS_ID:ACCESS_TOKEN)
 *       Body    phone=수신번호 & callback=발신번호 & message=내용 & refkey=고유키
 *
 *  성공 시 인증코드/발송시각을 세션(authCode/time)에 저장 → loginCheck.do 에서 검증 (NCP_SMSUtil 과 동일 규약)
 */
@Component
public class Gabia_SMSUtil {

    private static final String TOKEN_URL = "https://sms.gabia.com/oauth/token";
    private static final String SEND_URL  = "https://sms.gabia.com/api/send/sms";

    @Value("${gabia.sms.id}")
    private String smsId;

    @Value("${gabia.sms.apiKey}")
    private String apiKey;

    @Value("${gabia.sms.sender}")
    private String sender;   // 발신번호(숫자만)

    public boolean sendSMS(String phone) {
        try {
            ServletRequestAttributes attr = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
            HttpServletRequest httpRequest = attr.getRequest();
            HttpSession session = httpRequest.getSession(true);

            // 수신번호 정규화(숫자만)
            String toPhone = (phone == null ? "" : phone.replaceAll("[^0-9]", ""));

            // 1) 액세스 토큰 발급
            String accessToken = getAccessToken();
            if (accessToken == null || accessToken.isEmpty()) {
                System.out.println("[Gabia SMS] 토큰 발급 실패 — 발송 중단");
                return false;
            }

            // 2) 발송
            String authCode = generateAuthCode();
            String message  = "[allCare] \n인증번호 : " + authCode;
            String refkey   = System.currentTimeMillis() + "" + new Random().nextInt(1000);

            String basicSend = Base64.getEncoder()
                    .encodeToString((smsId + ":" + accessToken).getBytes(StandardCharsets.UTF_8));

            StringBuilder body = new StringBuilder();
            body.append("phone=").append(enc(toPhone))
                .append("&callback=").append(enc(sender))
                .append("&message=").append(enc(message))
                .append("&refkey=").append(enc(refkey));

            HttpURLConnection con = (HttpURLConnection) new URL(SEND_URL).openConnection();
            con.setConnectTimeout(5000); con.setReadTimeout(8000);
            con.setRequestMethod("POST");
            con.setDoOutput(true);
            con.setUseCaches(false);
            con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
            con.setRequestProperty("Authorization", "Basic " + basicSend);

            try (DataOutputStream wr = new DataOutputStream(con.getOutputStream())) {
                wr.write(body.toString().getBytes(StandardCharsets.UTF_8));
                wr.flush();
            }

            int httpCode = con.getResponseCode();
            String resp = readBody(con, httpCode);
            System.out.println("[Gabia SMS] 발송 HTTP=" + httpCode + " / 응답=" + resp);

            boolean ok = isSendSuccess(httpCode, resp);
            if (ok) {
                session.setAttribute("time", Long.toString(System.currentTimeMillis()));
                session.setAttribute("authCode", authCode);
            }
            return ok;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /** 액세스 토큰 발급 */
    private String getAccessToken() {
        try {
            String basic = Base64.getEncoder()
                    .encodeToString((smsId + ":" + apiKey).getBytes(StandardCharsets.UTF_8));

            HttpURLConnection con = (HttpURLConnection) new URL(TOKEN_URL).openConnection();
            con.setConnectTimeout(5000); con.setReadTimeout(8000);
            con.setRequestMethod("POST");
            con.setDoOutput(true);
            con.setUseCaches(false);
            con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
            con.setRequestProperty("Authorization", "Basic " + basic);

            try (DataOutputStream wr = new DataOutputStream(con.getOutputStream())) {
                wr.write("grant_type=client_credentials".getBytes(StandardCharsets.UTF_8));
                wr.flush();
            }

            int httpCode = con.getResponseCode();
            String resp = readBody(con, httpCode);
            System.out.println("[Gabia SMS] 토큰 HTTP=" + httpCode + " / 응답=" + resp);
            if (httpCode != 200) return null;

            Object parsed = new JSONParser().parse(resp);
            if (parsed instanceof JSONObject) {
                Object token = ((JSONObject) parsed).get("access_token");
                return token == null ? null : token.toString();
            }
            return null;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * 발송 성공 판정. 가비아 신규 REST API 는 HTTP 200 + JSON code 를 반환.
     * 성공코드 정확값은 최초 실발송 로그로 확인 후 필요 시 조정.
     * (현재: HTTP 200 이고, code 필드가 있으면 200/0/success 계열일 때만 성공)
     */
    private boolean isSendSuccess(int httpCode, String resp) {
        if (httpCode != 200) return false;
        try {
            Object parsed = new JSONParser().parse(resp);
            if (parsed instanceof JSONObject) {
                Object code = ((JSONObject) parsed).get("code");
                if (code != null) {
                    String c = code.toString().trim();
                    return c.equals("200") || c.equals("0") || c.equalsIgnoreCase("success") || c.startsWith("2");
                }
            }
        } catch (Exception ignore) {
            // JSON 파싱 실패해도 HTTP 200 이면 접수된 것으로 간주(로그로 실제 응답 확인)
        }
        return true;
    }

    private String readBody(HttpURLConnection con, int httpCode) throws Exception {
        BufferedReader br = new BufferedReader(new InputStreamReader(
                (httpCode >= 200 && httpCode < 300) ? con.getInputStream() : con.getErrorStream(),
                StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) sb.append(line);
        br.close();
        return sb.toString();
    }

    private String enc(String s) throws Exception {
        return URLEncoder.encode(s == null ? "" : s, "UTF-8");
    }

    public String generateAuthCode() {
        Random random = new Random();
        StringBuilder code = new StringBuilder();
        for (int i = 0; i < 6; i++) code.append(random.nextInt(10));
        return code.toString();
    }
}
