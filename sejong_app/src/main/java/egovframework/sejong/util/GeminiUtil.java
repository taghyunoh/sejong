package egovframework.sejong.util;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

/**
 * Gemini generateContent 공용 호출 (2026-10-30 신설 — 음식 사진 인식용).
 *
 *   · 키·주소는 혈당 챗봇(BloodController)과 똑같은 설정을 쓴다 :
 *       application.properties  api.gemini.key = ${GEMINI_API_KEY:}  /  api.gemini.url
 *     호출하는 쪽이 @Value 로 받아 넘긴다 — 키가 비어 있으면 호출하지 않고 null.
 *   · 요청 모양·헤더(x-goog-api-key)·thinkingLevel low·응답 조각 이어붙이기는
 *     BloodController.callGemini 와 같다. 여기에 더한 것 둘 :
 *       ① 사진(inline_data, base64) 을 user turn 에 함께 넣을 수 있다
 *       ② jsonMode 면 responseMimeType=application/json 으로 받아 화면이 바로 파싱한다
 *   ⚠BloodController 의 callGemini 는 손대지 않았다(챗봇 동작 보존). 새 기능만 이 클래스를 쓴다.
 */
public class GeminiUtil {
	private static final Logger log = LoggerFactory.getLogger(GeminiUtil.class);

	/** 키가 설정돼 있는가 (자리표시자 YOUR_… 는 미설정으로 본다) */
	public static boolean configured(String key, String url) {
		return key != null && !key.trim().isEmpty() && !key.startsWith("YOUR_")
				&& url != null && !url.trim().isEmpty();
	}

	/**
	 * @param imageMime   null 이면 글만 보낸다 (예: image/jpeg)
	 * @param imageBase64 data: 접두사 없는 순수 base64
	 * @param jsonMode    true 면 JSON 만 돌려주도록 요청
	 * @return 응답 본문 글(조각 이어붙임) — 실패·키 없음은 null
	 */
	public static String generate(String key, String url, String systemInstruction, String userText,
			String imageMime, String imageBase64, boolean jsonMode, int maxOutputTokens) {
		if (!configured(key, url)) return null;
		try {
			Gson gson = new Gson();

			JsonObject sysPart = new JsonObject();
			sysPart.addProperty("text", systemInstruction == null ? "" : systemInstruction);
			JsonArray sysParts = new JsonArray();
			sysParts.add(sysPart);
			JsonObject sysInstr = new JsonObject();
			sysInstr.add("parts", sysParts);

			JsonArray userParts = new JsonArray();
			if (imageMime != null && imageBase64 != null && !imageBase64.isEmpty()) {
				JsonObject inline = new JsonObject();
				inline.addProperty("mime_type", imageMime);
				inline.addProperty("data", imageBase64);
				JsonObject imgPart = new JsonObject();
				imgPart.add("inline_data", inline);
				userParts.add(imgPart);
			}
			JsonObject textPart = new JsonObject();
			textPart.addProperty("text", userText == null ? "" : userText);
			userParts.add(textPart);

			JsonObject content = new JsonObject();
			content.addProperty("role", "user");
			content.add("parts", userParts);
			JsonArray contents = new JsonArray();
			contents.add(content);

			JsonObject genCfg = new JsonObject();
			genCfg.addProperty("temperature", 0.2);
			genCfg.addProperty("maxOutputTokens", maxOutputTokens <= 0 ? 2048 : maxOutputTokens);
			JsonObject thinkingCfg = new JsonObject();
			thinkingCfg.addProperty("thinkingLevel", "low");   // Gemini 3 계열 — thinkingBudget:0 은 거부된다(챗봇과 같음)
			genCfg.add("thinkingConfig", thinkingCfg);
			if (jsonMode) genCfg.addProperty("responseMimeType", "application/json");

			JsonObject reqBody = new JsonObject();
			reqBody.add("system_instruction", sysInstr);
			reqBody.add("contents", contents);
			reqBody.add("generationConfig", genCfg);

			HttpURLConnection conn = (HttpURLConnection) new URL(url).openConnection();
			conn.setRequestMethod("POST");
			conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
			conn.setRequestProperty("x-goog-api-key", key);
			conn.setDoOutput(true);
			conn.setConnectTimeout(10000);
			conn.setReadTimeout(60000);    // 사진은 글보다 오래 걸린다
			try (OutputStream os = conn.getOutputStream()) {
				os.write(gson.toJson(reqBody).getBytes("UTF-8"));
				os.flush();
			}

			int code = conn.getResponseCode();
			InputStream is = (code >= 200 && code < 300) ? conn.getInputStream() : conn.getErrorStream();
			StringBuilder sb = new StringBuilder();
			if (is != null) {
				try (BufferedReader in = new BufferedReader(new InputStreamReader(is, "UTF-8"))) {
					String line;
					while ((line = in.readLine()) != null) sb.append(line);
				}
			}
			if (code < 200 || code >= 300) {
				log.warn("Gemini HTTP {} : {}", code, sb.toString());
				return null;
			}

			JsonObject root = gson.fromJson(sb.toString(), JsonObject.class);
			JsonArray candidates = root.getAsJsonArray("candidates");
			if (candidates == null || candidates.size() == 0) return null;
			JsonObject candContent = candidates.get(0).getAsJsonObject().getAsJsonObject("content");
			if (candContent == null) return null;
			JsonArray parts = candContent.getAsJsonArray("parts");
			if (parts == null || parts.size() == 0) return null;
			StringBuilder text = new StringBuilder();
			for (int i = 0; i < parts.size(); i++) {
				JsonElement t = parts.get(i).getAsJsonObject().get("text");
				if (t != null && !t.isJsonNull()) text.append(t.getAsString());
			}
			return text.length() == 0 ? null : text.toString();
		} catch (Exception e) {
			log.error("GeminiUtil.generate error: " + e.getMessage(), e);
			return null;
		}
	}

	/** 모델이 ```json … ``` 으로 감싸 보내는 경우를 벗긴다 */
	public static String stripFence(String s) {
		if (s == null) return null;
		String t = s.trim();
		if (t.startsWith("```")) {
			int nl = t.indexOf('\n');
			t = nl >= 0 ? t.substring(nl + 1) : t.substring(3);
			if (t.endsWith("```")) t = t.substring(0, t.length() - 3);
		}
		return t.trim();
	}
}
