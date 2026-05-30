package egovframework.sejong.blood.web;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.codehaus.jackson.map.annotate.JsonView;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;							
import com.google.gson.JsonParser;

import egovframework.sejong.blood.model.BloodDTO;
import egovframework.sejong.blood.service.BloodService;
import egovframework.sejong.doctor.model.DoctorDTO;
import egovframework.sejong.doctor.model.NoticeDTO;
import egovframework.sejong.doctor.web.DoctorController;
import egovframework.sejong.util.ResponseObject;



@Controller
public class BloodController {

	private static final Logger log = LoggerFactory.getLogger(DoctorController.class);

	@Resource(name = "BloodService") // 서비스 선언
	BloodService bloodService;

	// i-Sens 연동 설정 (application.properties 의 ${...})
	@Value("${api.isens.cgms-url}")
	private String cgmsUrl;

	@Value("${blood.client.id}")
	private String clientId;

	@Value("${blood.client.secret}")
	private String clientSecret;

	@Value("${blood.token.url}")
	private String tokenUrl;

	@Value("${blood.sync.lookback.days:7}")
	private int syncLookbackDays;

	@Value("${blood.auth.url}")
	private String authUrl;

	// 챗봇 LLM (Google Gemini) 설정
	@Value("${api.gemini.key:}")
	private String geminiKey;

	@Value("${api.gemini.url:}")
	private String geminiUrl;

	// =====================================================================
	// i-Sens 수동 동기화 (의사용)
	//   - 환자(USER_UUID) 의 T_BLDCON_MST 토큰으로 cgms-url 호출
	//   - 마지막 CGM_DTM ~ NOW() 구간 pull (없으면 lookbackDays 일 전부터)
	//   - 401 / 만료 시 refresh_token 으로 토큰 갱신 후 1회 재시도
	//   - 응답을 BloodDTO 리스트로 파싱하여 T_BLDINF_TRAN UPSERT
	// =====================================================================
	@RequestMapping(value = "/syncPatientBlood.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject syncPatientBlood(@RequestBody HashMap<String, Object> params) {
		ResponseObject json = new ResponseObject();
		String userUuid = params != null ? (String) params.get("userUuid") : null;

		if (userUuid == null || userUuid.trim().isEmpty()) {
			json.IsSucceed = false;
			json.Message = "userUuid 가 필요합니다.";
			return json;
		}

		try {
			Map<String, Object> ctx = bloodService.getSyncContext(userUuid);
			if (ctx == null || ctx.get("accToken") == null) {
				json.IsSucceed = false;
				json.Message = "해당 환자의 i-Sens 연동 토큰이 없습니다. (앱에서 먼저 연동 필요)";
				return json;
			}

			String accessToken = (String) ctx.get("accToken");
			String refreshTokenStr = (String) ctx.get("refToken");
			Object lastDtm = ctx.get("lastCgmDtm");

			// start = 마지막 측정시각 (없으면 lookbackDays 일 전)
			String start = (lastDtm != null)
					? toIsoOffset(parseDb(lastDtm.toString()))
					: toIsoOffset(daysAgo(syncLookbackDays));
			String end = toIsoOffset(new Date());

			// 1차 호출
			String body = callCgms(start, end, accessToken);

			// 401 / 토큰 만료로 추정되는 경우 refresh 후 1회 재시도
			if (body == null && refreshTokenStr != null && !refreshTokenStr.isEmpty()) {
				String newAccessToken = refreshAndSaveToken(userUuid, refreshTokenStr);
				if (newAccessToken != null) {
					body = callCgms(start, end, newAccessToken);
				}
			}

			if (body == null) {
				json.IsSucceed = false;
				json.Message = "i-Sens 호출 실패 (토큰 만료 또는 네트워크 오류).";
				return json;
			}

			// 응답 → BloodDTO 리스트 → T_BLDINF_TRAN UPSERT
			Gson gson = new Gson();
			JsonArray arr = gson.fromJson(body, JsonArray.class);
			if (arr == null || arr.size() == 0) {
				json.IsSucceed = true;
				json.Data = 0;
				json.Message = "신규 데이터 없음 (구간 " + start + " ~ " + end + ")";
				return json;
			}

			List<BloodDTO> list = new ArrayList<>();
			for (JsonElement el : arr) {
				BloodDTO dto = gson.fromJson(el, BloodDTO.class);
				dto.setUserUuid(userUuid);
				list.add(dto);
			}
			bloodService.insertBloodData(list);

			json.IsSucceed = true;
			json.Data = list.size();
			json.Message = "동기화 완료 (" + list.size() + "건, " + start + " ~ " + end + ")";
			return json;

		} catch (Exception e) {
			log.error("syncPatientBlood ERROR: " + e.getMessage(), e);
			json.IsSucceed = false;
			json.Message = "동기화 중 오류: " + e.getMessage();
			return json;
		}
	}

	/** 환자별 i-Sens 토큰 보유 여부 */
	@RequestMapping(value = "/tokenYn.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject tokenYn(HttpSession session) {
		ResponseObject json = new ResponseObject();
		Object uuidObj = session.getAttribute("userUuid");
		if (uuidObj == null) { json.IsSucceed = false; return json; }
		int n = bloodService.tokenYn(uuidObj.toString());
		json.IsSucceed = n > 0;
		json.Data = n;
		return json;
	}

	/** 오늘 최근 혈당 (세션 환자) */
	@RequestMapping(value = "/getTodayBlood.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getTodayBlood(HttpSession session) {
		ResponseObject json = new ResponseObject();
		Object uuidObj = session.getAttribute("userUuid");
		if (uuidObj == null) { json.IsSucceed = false; return json; }
		json.Data = bloodService.getTodayBlood(uuidObj.toString());
		json.IsSucceed = true;
		return json;
	}

	/** 오늘 공복·식후 평균 (세션 환자) */
	@RequestMapping(value = "/getTodayBlodAvg.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getTodayBlodAvg(HttpSession session) {
		ResponseObject json = new ResponseObject();
		Object uuidObj = session.getAttribute("userUuid");
		if (uuidObj == null) { json.IsSucceed = false; return json; }
		String uuid = uuidObj.toString();

		// 오늘 전체 평균 (공복 시간대/식사 데이터 없을 때 공통 대체값)
		Map<String,Object> avg = bloodService.getTodayAvgBlood(uuid);
		Object avgVal = avg != null ? avg.get("avgBlood") : 0;

		// 공복 평균: 새벽 03:00~06:00. 해당 시간 데이터 없으면(0) → 전체 평균
		Map<String,Object> fast = bloodService.getTodayFastBlood(uuid);
		Object fastVal = fast != null ? fast.get("avgBlood") : null;
		if (toDouble(fastVal) <= 0) fastVal = avgVal;

		// 식후 평균: 식후 90~150분. 식사 없거나 해당 CGM 없으면(0) → 전체 평균
		Map<String,Object> meal = bloodService.getTodayMealBlood(uuid);
		Object mealVal = meal != null ? meal.get("avgBlood") : null;
		if (toDouble(mealVal) <= 0) mealVal = avgVal;

		Map<String,Object> data = new HashMap<>();
		data.put("fastBlod", fastVal);
		data.put("mealBlod", mealVal);
		json.Data = data;
		json.IsSucceed = true;
		return json;
	}

	/** avgBlood(BigDecimal/String/Number) → double (파싱 실패 시 0) */
	private double toDouble(Object o) {
		if (o == null) return 0;
		try { return Double.parseDouble(o.toString()); }
		catch (Exception e) { return 0; }
	}

	/** 환자(본인) 자가 동기화 — 세션의 userUuid 사용 */
	@RequestMapping(value = "/syncMyBlood.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject syncMyBlood(HttpSession session) {
		ResponseObject json = new ResponseObject();
		Object uuidObj = session.getAttribute("userUuid");
		if (uuidObj == null) {
			json.IsSucceed = false;
			json.Message = "로그인이 필요합니다.";
			return json;
		}
		HashMap<String, Object> p = new HashMap<>();
		p.put("userUuid", uuidObj.toString());
		return syncPatientBlood(p);
	}

	/** 환자 i-Sens 토큰 발급 콜백 페이지 — raw 단독 JSP */
	@RequestMapping(value = "/patient/isensCallback.do")
	public String isensCallback(@RequestParam(value = "code", required = false) String code,
			HttpSession session, Model model) {
		Object uuidObj = session.getAttribute("userUuid");
		model.addAttribute("code", code == null ? "" : code);
		model.addAttribute("hasSession", uuidObj != null);
		return ".raw/main/patient/isens_callback";
	}

	/** i-Sens 인가코드 → access_token 교환 후 T_BLDCON_MST 저장 (환자 세션 기반) */
	@RequestMapping(value = "/getToken.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getToken(HttpSession session, @RequestBody HashMap<String, Object> params) {
		ResponseObject res = new ResponseObject();
		Object uuidObj = session.getAttribute("userUuid");
		if (uuidObj == null) {
			res.IsSucceed = false; res.Message = "로그인이 필요합니다."; return res;
		}
		String userUuid = uuidObj.toString();
		String redirectUri = (String) params.get("redirect_uri");
		String code        = (String) params.get("code");
		if (code == null || code.isEmpty()) {
			res.IsSucceed = false; res.Message = "인가코드(code)가 없습니다."; return res;
		}

		String requestBody = "grant_type=authorization_code"
				+ "&code=" + code
				+ "&client_id=" + clientId
				+ "&client_secret=" + clientSecret
				+ "&redirect_uri=" + redirectUri;

		try {
			URL url = new URL(tokenUrl);
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("POST");
			conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
			conn.setDoOutput(true);
			conn.setConnectTimeout(10000);
			conn.setReadTimeout(20000);
			try (OutputStream os = conn.getOutputStream()) {
				os.write(requestBody.getBytes("UTF-8"));
				os.flush();
			}
			int code2 = conn.getResponseCode();
			InputStream is = (code2 >= 200 && code2 < 300) ? conn.getInputStream() : conn.getErrorStream();
			StringBuilder sb = new StringBuilder();
			try (BufferedReader in = new BufferedReader(new InputStreamReader(is, "UTF-8"))) {
				String line; while ((line = in.readLine()) != null) sb.append(line);
			}
			if (code2 < 200 || code2 >= 300) {
				res.IsSucceed = false; res.Message = "i-Sens 토큰 발급 실패: " + sb; return res;
			}
			JsonObject jr = new Gson().fromJson(sb.toString(), JsonObject.class);
			Map<String, Object> tk = new HashMap<>();
			tk.put("userUuid",      userUuid);
			tk.put("user_id",       jr.has("user_id")       ? jr.get("user_id").getAsString()       : null);
			tk.put("accessToken",   jr.has("access_token")  ? jr.get("access_token").getAsString()  : null);
			tk.put("refresh_token", jr.has("refresh_token") ? jr.get("refresh_token").getAsString() : null);
			tk.put("expires_in",    jr.has("expires_in")    ? jr.get("expires_in").getAsString()    : null);
			bloodService.insertToken(tk);
			res.IsSucceed = true;
			res.Data = "토큰 저장 완료";
			return res;
		} catch (Exception e) {
			log.error("getToken ERROR: " + e.getMessage(), e);
			res.IsSucceed = false;
			res.Message = "토큰 처리 중 오류: " + e.getMessage();
			return res;
		}
	}

	/** cgms-url GET 호출. 성공 시 응답 본문, 실패 시 null */
	private String callCgms(String start, String end, String accessToken) {
		try {
			String query = String.format("start=%s&end=%s",
					java.net.URLEncoder.encode(start, "UTF-8"),
					java.net.URLEncoder.encode(end, "UTF-8"));
			URL url = new URL(cgmsUrl + "?" + query);
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("GET");
			conn.setRequestProperty("Authorization", "Bearer " + accessToken);
			conn.setConnectTimeout(10000);
			conn.setReadTimeout(20000);

			int code = conn.getResponseCode();
			if (code == 401 || code == 403) {
				log.warn("i-Sens cgms returned {}, will try refresh", code);
				return null;
			}
			if (code < 200 || code >= 300) {
				log.warn("i-Sens cgms HTTP {}", code);
				return null;
			}

			StringBuilder sb = new StringBuilder();
			try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"))) {
				String line;
				while ((line = in.readLine()) != null) sb.append(line);
			}
			return sb.toString();
		} catch (Exception e) {
			log.error("callCgms error: " + e.getMessage(), e);
			return null;
		}
	}

	/** refresh_token 으로 access_token 재발급 후 T_BLDCON_MST 갱신. 성공 시 새 access_token, 실패 시 null */
	private String refreshAndSaveToken(String userUuid, String refreshTokenStr) {
		try {
			String requestBody = "grant_type=refresh_token"
					+ "&client_id=" + clientId
					+ "&client_secret=" + clientSecret
					+ "&refresh_token=" + refreshTokenStr;

			URL url = new URL(tokenUrl);
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("POST");
			conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
			conn.setDoOutput(true);
			conn.setConnectTimeout(10000);
			conn.setReadTimeout(20000);

			try (OutputStream os = conn.getOutputStream()) {
				os.write(requestBody.getBytes("UTF-8"));
				os.flush();
			}

			int code = conn.getResponseCode();
			InputStream is = (code >= 200 && code < 300) ? conn.getInputStream() : conn.getErrorStream();

			StringBuilder sb = new StringBuilder();
			try (BufferedReader in = new BufferedReader(new InputStreamReader(is, "UTF-8"))) {
				String line;
				while ((line = in.readLine()) != null) sb.append(line);
			}
			if (code < 200 || code >= 300) {
				log.warn("refreshToken HTTP {}: {}", code, sb);
				return null;
			}

			JsonObject jr = new Gson().fromJson(sb.toString(), JsonObject.class);
			String newAcc = jr.has("access_token") ? jr.get("access_token").getAsString() : null;
			if (newAcc == null) return null;

			Map<String, Object> upd = new HashMap<>();
			upd.put("userUuid", userUuid);
			upd.put("accessToken", newAcc);
			upd.put("refresh_token", jr.has("refresh_token") ? jr.get("refresh_token").getAsString() : refreshTokenStr);
			upd.put("expires_in",   jr.has("expires_in")   ? jr.get("expires_in").getAsString()   : null);
			bloodService.updateToken(upd);

			return newAcc;
		} catch (Exception e) {
			log.error("refreshAndSaveToken error: " + e.getMessage(), e);
			return null;
		}
	}

	// ---- 시간 포맷 헬퍼 -------------------------------------------------
	/** Date → '2025-01-27T13:45:00+09:00' (KST 고정) */
	private String toIsoOffset(Date d) {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssXXX");
		sdf.setTimeZone(TimeZone.getTimeZone("Asia/Seoul"));
		return sdf.format(d);
	}

	/** DB MAX(CGM_DTM) 결과(예: '2025-01-27T13:45:00') → Date */
	private Date parseDb(String s) {
		try {
			SimpleDateFormat[] fmts = {
				new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss"),
				new SimpleDateFormat("yyyy-MM-dd HH:mm:ss"),
				new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS")
			};
			for (SimpleDateFormat f : fmts) {
				f.setTimeZone(TimeZone.getTimeZone("Asia/Seoul"));
				try { return f.parse(s); } catch (Exception ignore) {}
			}
		} catch (Exception ignore) {}
		return daysAgo(syncLookbackDays);
	}

	private Date daysAgo(int days) {
		long now = System.currentTimeMillis();
		return new Date(now - (long) days * 24L * 60L * 60L * 1000L);
	}
	// =====================================================================
	
	// 2026-05-27 정리: /goBloodPage.do, /goBloodPage2.do 제거 (FAHR JSP 삭제됨)
	
	/** 환자가 본인 PC에서 i-Sens OAuth 시작: redirect URL 생성 */
	@RequestMapping(value = "/getAuth.do", method = RequestMethod.POST)
	public @ResponseBody Map<String, String> authorize(@RequestBody HashMap<String, Object> params) {
	    String redirectUri = params != null && params.get("redirect_uri") != null
	            ? (String) params.get("redirect_uri") : "";
	    String redirect = authUrl
	            + "?response_type=code"
	            + "&client_id=" + clientId
	            + "&redirect_uri=" + redirectUri;
	    Map<String, String> responseMap = new HashMap<>();
	    responseMap.put("redirectUrl", redirect);
	    return responseMap;
	}
	
	// (구) /getToken.do — 위쪽 환자 세션 기반 구현으로 통합되어 제거됨
	
	
	@RequestMapping(value = "/authToken.do", method = RequestMethod.GET)
	public @ResponseBody String authToken(HttpSession session, @RequestParam String accessToken, @RequestParam String goTokenUrl) {
	    System.out.println("authToken test");
	    System.out.println("authToken test :" + accessToken);
	    
	    String tokenUrl = goTokenUrl;
	    
	    try {
	        URL url = new URL(tokenUrl);
	        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
	        connection.setRequestMethod("GET");  
	        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
	        connection.setDoOutput(true);

	        int responseCode = connection.getResponseCode();
	        System.out.println("Response Code: " + responseCode);

	        InputStream inputStream = (responseCode == HttpURLConnection.HTTP_OK) ?
	            connection.getInputStream() : connection.getErrorStream();
	        
	        StringBuilder response = new StringBuilder();
	        try (BufferedReader in = new BufferedReader(new InputStreamReader(inputStream))) {
	            String inputLine;
	            while ((inputLine = in.readLine()) != null) {
	                response.append(inputLine);
	            }
	        }

	        System.out.println("Token Response: " + response.toString());
	        
	        return response.toString();

	    } catch (IOException e) {
	        e.printStackTrace();
	        return "Error occurred while requesting token: " + e.getMessage();
	    }
	}

	
	
	// 2026-05-27 정리: /creSampleData.do 제거 (FAHR JSP에서만 호출, JSP 삭제됨)
	
	
	// 2026-05-27 정리: /getData.do 제거 (FAHR JSP에서만 호출, JSP 삭제됨)
	
	
	
	// 2026-05-27 정리: /getBloodData.do 제거 (FAHR JSP에서만 호출, JSP 삭제됨)
	//findUserToken
//	@RequestMapping(value = "/getBloodUserData.do", method = RequestMethod.POST)	
//	public @ResponseBody Map<String, Object> getBloodUserData(HttpSession session,@RequestBody HashMap<String, Object> params) {
//	    //System.out.println("인가코드 + UUID  db에서 꺼내오기");
//	  
//	    DoctorDTO user = (DoctorDTO) session.getAttribute("t_user_uuid");
//	    String userId = user.getUser_uuid();
//	    
//	    List<Map<String, Object>> list = bloodService.getBloodUserData(userId);
//
//	    Map<String, Object> result = new HashMap<>();
//	    result.put("userId" , list.get(0).get("USER_UUID"));
//	    result.put("accToken" , list.get(0).get("ACC_TOKEN"));
//	
//	    return result;
//	}
	
	// 2026-05-27 정리: /showBloodData.do 제거 (FAHR JSP 삭제됨)
	/*
	@RequestMapping(value = "/showBloodData.do", method = RequestMethod.POST)
	public @ResponseBody  Map<String, Object> showBloodData(Model model, @RequestBody HashMap<String, Object> params) {
	    
	    Map<String, Object> map = new HashMap<>();
	    Map<String, Object> result = new HashMap<>();	    
	    
	    
	    map.put("user_uuid", params.get("user_uuid"));
	    map.put("start", params.get("start"));
	    map.put("end", params.get("end"));
	    	
	    List<Map<String, Object>> dataList = bloodService.showBloodData(map);	  
	    System.out.println("각종 :" + dataList.toString());
	    
	    
	    if (!dataList.isEmpty()) {
	    	
		    if(dataList.size()==1) {
		    	result.put("prevData" , 0);    
		    }else {

			    result.put("prevData" , dataList.get(1));    
		    }	    

	    	result.put("nowData" , dataList.get(0));   
	    	result.put("aveUpt", dataList.get(0).get("AVG_UPT"));
		    
		    System.out.println("@@ result :"  + result);    
	        
	              
	    } 
	
        return result;
	}
	
	*/
	// 2026-05-27 정리: /getAvgFastingBlood.do 제거 (FAHR JSP 삭제됨)
	/*
	@RequestMapping(value = "/getAvgFastingBlood.do", method = RequestMethod.POST)
	public @ResponseBody ResponseObject getAvgFastingBlood(@RequestBody HashMap<String, Object> params) {
	    //System.out.println("공복 혈당 가져오기 ");
	    ResponseObject json = new ResponseObject();
	    
	    Map<String, Object> map = new HashMap<>();
	    map.put("date", params.get("date"));
	    map.put("user_uuid", params.get("user_uuid"));
	
	    
	    String fastingBlood = bloodService.getAvgFastingBlood(map);
	    
	    if(fastingBlood != null) {
	    	json.Data = fastingBlood;
	    	json.IsSucceed = true;
	    	
	    }
	    
	
	    return json;
	}
	*/

	//getBloodChartData
	@RequestMapping(value = "/getBloodChartData.do", method = RequestMethod.POST)	
	public @ResponseBody List<Map<String, Object>> getBloodChartData(@RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));

		List<Map<String, Object>> result = bloodService.getBloodChartData(map);
	//	System.out.println("chart result"+ result);
			   
		return result;
	}
	
	//getBloodChartDataMulti 일자별 멀티 챠트구현  
	@RequestMapping(value = "/getBloodChartDataMulti.do", method = RequestMethod.POST)	
	public @ResponseBody List<Map<String, Object>> getBloodChartDataMulti(@RequestBody HashMap<String, Object> params) {
        
		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));

		List<Map<String, Object>> result = bloodService.getBloodChartDataMulti(map);
		System.out.println("multi chart result"+ result);
		
	    return result;
	}
	
	//
	@RequestMapping(value = "/drawOneMealChart.do", method = RequestMethod.POST)	
	public @ResponseBody List<Map<String, Object>> drawOneMealChart(@RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));

		List<Map<String, Object>> result = bloodService.drawOneMealChart(map);
	//	System.out.println("chart result"+ result);
			   
		return result;
	}
	
	@RequestMapping(value = "/drawBloodBarChart.do", method = RequestMethod.POST)	
	public @ResponseBody Map<String, Object> drawBloodBarChart(@RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));

		Map<String, Object> result = bloodService.drawBloodBarChart(map);
		
		return result;
	}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	//calcBlood
	@RequestMapping(value = "/calcBlood.do", method = RequestMethod.POST)	
	public @ResponseBody Map<String, Object> calcBlood(@RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));
		
		Map<String, Object> result = bloodService.calcBlood(map);	
		
		Map<String, Object> meal = bloodService.mealAvg(map);	
		System.out.println("meal:" + meal);
		result.put("avgMeal", meal);		
        //식후햘당 별도계산 
		Map<String, Object> food = bloodService.foodAvg(map);
		System.out.println("food:" + food);		
		result.put("avgFood", food);

		System.out.println("GMI~ result :" + result);
		
		return result;
	}	
	//혈당 활동 개요 
	@RequestMapping(value="/drawActionBloodChart.do", method = RequestMethod.POST)
	public @ResponseBody List<Map<String, Object>> drawActionBloodChart(@RequestBody HashMap<String, Object> params) {

		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));

		List<Map<String, Object>> result = bloodService.getActionBloodChart(map);
		
		System.out.println("drawAgpBloodChart  result :" + result);
	    return result;
	}
	//일자별 전체혈당 평균
	@RequestMapping(value="/drawWeeklyBloodChart.do", method = RequestMethod.POST)
	public @ResponseBody List<Map<String, Object>> drawWeeklyBloodChart(@RequestBody HashMap<String, Object> params) {

		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));

		List<Map<String, Object>> result = bloodService.getDaylyBloodData(map);

	    return result;
	}
	
	//요일별 범위내 시간
	@RequestMapping(value="/drawRangeChart.do", method = RequestMethod.POST)
	public @ResponseBody List<Map<String, Object>> drawRangeChart(@RequestBody HashMap<String, Object> params) {

		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));

		List<Map<String, Object>> result = bloodService.drawRangeChart(map);
		
	    return result;
	}
	//식후혈당
	@RequestMapping(value="/drawDailyMealBlood.do", method = RequestMethod.POST)
	public @ResponseBody List<Map<String, Object>> drawDailyMealBlood(@RequestBody HashMap<String, Object> params) {

		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));
	    map.put("date", params.get("date"));

		List<Map<String, Object>> post = bloodService.getPostBlood(map);
	    return post;
	}
	//요일별 평균, 전체혈당/식후혈당/공복혈당
	@RequestMapping(value="/drawDailyChart.do", method = RequestMethod.POST)
	public @ResponseBody Map<String, Object> drawDailyChart(@RequestBody HashMap<String, Object> params) {
		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));

		List<Map<String, Object>> result = bloodService.getWeeklyBloodData(map);
		List<Map<String, Object>> post = bloodService.getPostBlood(map);
		List<Map<String, Object>> fasting = bloodService.getFastingBlood(map);
		
		Map<String, Object> response = new HashMap<>();
		response.put("result", result);
		response.put("post", post);
		response.put("fasting", fasting);
    
	    return response; 
	}
	//주중,주말 평균
	@RequestMapping(value="/drawWeekHoliAvg.do", method = RequestMethod.POST)
	public @ResponseBody Map<String, Object> drawWeekHoliAvg(@RequestBody HashMap<String, Object> params) {

		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));
		
		List<Map<String, Object>> result = bloodService.getWeekHoliAvg(map);
		
		Map<String, Object> response = new HashMap<>();
		response.put("result", result);

	    return response;
	}

	// =====================================================================
	// 챗봇 자유질문 LLM(Gemini) fallback
	//   - patient_main.jsp 의 _chatResponse() 키워드 매칭 실패 시 호출
	//   - 클라이언트가 보내는 질문(q) + 선택한 날 혈당 컨텍스트(ctx)를 프롬프트로 구성
	//   - API 키 미설정/오류 시 IsSucceed=false → 화면은 기존 안내문구로 폴백
	//   - 의료 조언 책임 회피: "참고용, 진단 아님" 시스템 지시 포함
	// =====================================================================
	@RequestMapping(value = "/blood/chatAsk.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject chatAsk(@RequestBody HashMap<String, Object> params) {
		ResponseObject json = new ResponseObject();

		String q = params != null && params.get("q") != null ? params.get("q").toString().trim() : "";
		if (q.isEmpty()) {
			json.IsSucceed = false;
			json.Message = "질문이 비어 있습니다.";
			return json;
		}
		// 프롬프트 인젝션/과금 폭증 방지를 위한 길이 제한
		if (q.length() > 500) q = q.substring(0, 500);

		if (geminiKey == null || geminiKey.isEmpty() || geminiKey.startsWith("YOUR_")
				|| geminiUrl == null || geminiUrl.isEmpty()) {
			json.IsSucceed = false;
			json.Message = "LLM 미설정";   // 클라이언트는 기존 안내문구로 폴백
			return json;
		}

		// 선택한 날 혈당 요약 컨텍스트 (클라이언트 _evalCtx 에서 전달, 없으면 생략)
		String ctx = params.get("ctx") != null ? params.get("ctx").toString() : "";
		if (ctx.length() > 400) ctx = ctx.substring(0, 400);

		String systemInstruction =
			"너는 당뇨/혈당 관리를 돕는 친절한 한국어 건강 도우미야. "
			+ "사용자는 연속혈당측정(CGM)을 사용하는 환자야. "
			+ "답변은 의학적 진단이 아니라 일반적인 생활관리 참고용이며, 심한 고혈당·저혈당이나 이상 증상은 반드시 담당 의사와 상담하라고 안내해. "
			+ "답변은 200자 내외로 간결하게, 줄바꿈은 <br> 태그로 표기해. "
			+ (ctx.isEmpty() ? "" : "참고 — 사용자가 보고 있는 혈당 요약: " + ctx);

		try {
			String answer = callGemini(systemInstruction, q);
			if (answer == null || answer.trim().isEmpty()) {
				json.IsSucceed = false;
				json.Message = "LLM 응답 없음";
				return json;
			}
			json.IsSucceed = true;
			json.Data = answer.trim();
			return json;
		} catch (Exception e) {
			log.error("chatAsk ERROR: " + e.getMessage(), e);
			json.IsSucceed = false;
			json.Message = "LLM 호출 오류";
			return json;
		}
	}

	/** Gemini generateContent 호출 → 첫 후보 텍스트 반환 (실패 시 null) */
	private String callGemini(String systemInstruction, String userText) {
		try {
			Gson gson = new Gson();

			// 요청 바디 구성 (system_instruction + 단일 user turn)
			JsonObject sysPart = new JsonObject();
			sysPart.addProperty("text", systemInstruction);
			JsonArray sysParts = new JsonArray();
			sysParts.add(sysPart);
			JsonObject sysInstr = new JsonObject();
			sysInstr.add("parts", sysParts);

			JsonObject userPart = new JsonObject();
			userPart.addProperty("text", userText);
			JsonArray userParts = new JsonArray();
			userParts.add(userPart);
			JsonObject content = new JsonObject();
			content.addProperty("role", "user");
			content.add("parts", userParts);
			JsonArray contents = new JsonArray();
			contents.add(content);

			JsonObject genCfg = new JsonObject();
			genCfg.addProperty("temperature", 0.4);
			genCfg.addProperty("maxOutputTokens", 1024);
			// thinking(추론) 비활성화 — 켜두면 추론 토큰이 maxOutputTokens 를 잠식해
			// 답변이 중간에 잘림(finishReason=MAX_TOKENS). 단순 건강 Q&A 라 불필요.
			JsonObject thinkingCfg = new JsonObject();
			thinkingCfg.addProperty("thinkingBudget", 0);
			genCfg.add("thinkingConfig", thinkingCfg);

			JsonObject reqBody = new JsonObject();
			reqBody.add("system_instruction", sysInstr);
			reqBody.add("contents", contents);
			reqBody.add("generationConfig", genCfg);

			// API 키는 헤더(x-goog-api-key)로 전달 (URL 쿼리 노출 방지)
			URL url = new URL(geminiUrl);
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("POST");
			conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
			conn.setRequestProperty("x-goog-api-key", geminiKey);
			conn.setDoOutput(true);
			conn.setConnectTimeout(10000);
			conn.setReadTimeout(30000);

			try (OutputStream os = conn.getOutputStream()) {
				os.write(gson.toJson(reqBody).getBytes("UTF-8"));
				os.flush();
			}

			int code = conn.getResponseCode();
			InputStream is = (code >= 200 && code < 300) ? conn.getInputStream() : conn.getErrorStream();
			StringBuilder sb = new StringBuilder();
			try (BufferedReader in = new BufferedReader(new InputStreamReader(is, "UTF-8"))) {
				String line;
				while ((line = in.readLine()) != null) sb.append(line);
			}
			if (code < 200 || code >= 300) {
				log.warn("Gemini HTTP {} : {}", code, sb.toString());
				return null;
			}

			// 응답 파싱: candidates[0].content.parts[0].text
			JsonObject root = gson.fromJson(sb.toString(), JsonObject.class);
			JsonArray candidates = root.getAsJsonArray("candidates");
			if (candidates == null || candidates.size() == 0) return null;
			JsonObject cand = candidates.get(0).getAsJsonObject();
			JsonObject candContent = cand.getAsJsonObject("content");
			if (candContent == null) return null;
			JsonArray parts = candContent.getAsJsonArray("parts");
			if (parts == null || parts.size() == 0) return null;
			JsonElement textEl = parts.get(0).getAsJsonObject().get("text");
			return textEl != null ? textEl.getAsString() : null;

		} catch (Exception e) {
			log.error("callGemini error: " + e.getMessage(), e);
			return null;
		}
	}

}

