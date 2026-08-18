package egovframework.sejong.blood.web;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.antlr.analysis.SemanticContext.TruePredicate;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.util.UriComponentsBuilder;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;							
import com.google.gson.JsonParser;

import egovframework.sejong.blood.model.BloodDTO;
import egovframework.sejong.blood.service.BloodService;
import egovframework.sejong.login.model.UserDTO;
import egovframework.sejong.util.ResponseObject;
import freemarker.template.utility.NormalizeNewlines;

@Controller
public class BloodController {
	private static final Logger log = LoggerFactory.getLogger(BloodController.class);

	@Resource(name = "BloodService") // 서비스 선언
	BloodService bloodService;

	// 혈당 Q&A 챗봇 LLM(Gemini) 설정 — 미설정 시 클라이언트가 안내문구로 폴백
	@Value("${api.gemini.key:}")
	private String geminiKey;

	@Value("${api.gemini.url:}")
	private String geminiUrl;

    // 상수처럼 쓰고 싶은 필드
    private final String CLIENT_ID;
    private final String CLIENT_SECRET;
    private final String AUTH_URL;
    private final String TOKEN_URL;
    private final String SAMPLE_URL;
    
    public BloodController(
            @Value("${blood.client.id}") String clientId,
            @Value("${blood.client.secret}") String clientSecret ,
            @Value("${blood.auth.url}") String authUrl ,
            @Value("${blood.token.url}") String tokenUrl ,
            @Value("${blood.sample.url}") String sampleUrl
    ) {
        this.CLIENT_ID     = clientId;
        this.CLIENT_SECRET = clientSecret;
        this.AUTH_URL      = authUrl;
        this.TOKEN_URL     = tokenUrl;
        this.SAMPLE_URL    = sampleUrl;
    }	
    ///////////////////
	//회원가입
	@RequestMapping("/goRegisterPage.do")
	public String goRegisterPage(HttpSession session) {
		return ".main/register";
	}
	
	
	@RequestMapping("/goBloodPage.do")
	public String goSamplePage(HttpSession session,Model model) {
		model.addAttribute("menuName","연속혈당 측정");
		return ".main/FAHR_00";
	}
	
	@RequestMapping("/goBloodPage2.do")
	public String goBloodPage2(HttpSession session,Model model) {
		model.addAttribute("menuName","AI 종합분석(주간)");  // [2026-08-18] 홈 버튼 명칭과 통일
		return ".main/Blood_Consult";
	}
	
	@RequestMapping(value = "/register.do", method =RequestMethod.POST )
	public @ResponseBody HashMap<String, Object> register(HttpSession session, @RequestBody HashMap<String, Object> map){
	System.out.println("회원가입페이지 테스트");
		HashMap<String, Object> result = new HashMap<String, Object>();
		System.out.println(map);
		return result;
	}
	
	//원소스 getAuth
	@RequestMapping(value = "/getAuth.do", method = RequestMethod.POST)	
	public @ResponseBody Map<String, String> authorize(@RequestBody HashMap<String, Object> params) {
	    System.out.println("인가코드 받아오기 test");

	    String authUrl =  AUTH_URL +
	                            "?response_type=code" +
	                            "&client_id=" + CLIENT_ID +
	                            "&redirect_uri=" + params.get("redirect_uri");

	    Map<String, String> responseMap = new HashMap<>();
	    responseMap.put("redirectUrl", authUrl);
	    System.out.println(responseMap);
	
	    return responseMap;
	}
	//원소스 getAuth
	
	@RequestMapping(value = "/getToken.do", method = RequestMethod.POST)
	public @ResponseBody String getToken(HttpSession session,  @RequestBody HashMap<String, Object> params) {
		System.out.println("token 받아오기test");
	    
	    System.out.println(params);
	    
	    
	    String tokenUrl = TOKEN_URL;
	    
	    String redirectUri = (String) params.get("redirect_uri");
	    String code = (String)params.get("code");
	    
	    String requestBody = "grant_type=authorization_code" +
	                         "&code=" + code +
	                         "&client_id=" + CLIENT_ID +
	                         "&client_secret=" + CLIENT_SECRET +
	                         "&redirect_uri=" + redirectUri;

	    try {
	        URL url = new URL(tokenUrl);
	        HttpURLConnection connection = (HttpURLConnection) url.openConnection(); connection.setConnectTimeout(5000); connection.setReadTimeout(8000);
	        connection.setRequestMethod("POST");
	        connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
	        connection.setDoOutput(true);

	        try (OutputStream os = connection.getOutputStream()) {
	            os.write(requestBody.getBytes());
	            os.flush();
	        }

	        int responseCode = connection.getResponseCode();
	        System.out.println("Response Code: " + responseCode);

	        StringBuilder response = new StringBuilder();
	        try (BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()))) {
	            String inputLine;
	            while ((inputLine = in.readLine()) != null) {
	                response.append(inputLine);
	            }
	        }

	        /* [2026-07-11 보안] 토큰 응답 콘솔출력 제거 */
	        
	        // Gson을 사용하여 응답 파싱
	        Gson gson = new Gson();
	        JsonObject jsonResponse = gson.fromJson(response.toString(), JsonObject.class);

	        //추출
	        Map<String, Object> map = new HashMap<String, Object>();
	        map.put("accessToken",jsonResponse.get("access_token").getAsString());
	        map.put("refresh_token", jsonResponse.get("refresh_token").getAsString());
	        map.put("token_type", jsonResponse.get("token_type").getAsString());
	        map.put("expires_in", jsonResponse.get("expires_in").getAsString());
	        map.put("user_id", jsonResponse.get("user_id").getAsString());
	        UserDTO user = (UserDTO) session.getAttribute("user");
	        map.put("userUuid", user.getUserUuid());
	        //uuid 추가
	        bloodService.insertToken(map);
	        
	        
	        return jsonResponse.get("access_token").getAsString(); //response.toString();

	    } catch (Exception e) {
	        e.printStackTrace();
	        return ("Error occurred while requesting token: " + e.getMessage());
	    }
	}	
	
	
	@RequestMapping(value = "/authToken.do", method = RequestMethod.GET)
	public @ResponseBody String authToken(HttpSession session, @RequestParam String accessToken, @RequestParam String goTokenUrl) {
	    System.out.println("authToken test");
	    System.out.println("authToken test :" + accessToken);
	    
	    String tokenUrl = goTokenUrl;
	    
	    try {
	        URL url = new URL(tokenUrl);
	        HttpURLConnection connection = (HttpURLConnection) url.openConnection(); connection.setConnectTimeout(5000); connection.setReadTimeout(8000);
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

	        /* [2026-07-11 보안] 토큰 응답 콘솔출력 제거 */
	        
	        return response.toString();

	    } catch (IOException e) {
	        e.printStackTrace();
	        return "Error occurred while requesting token: " + e.getMessage();
	    }
	}

	
	
	//creSampleData
	@RequestMapping(value = "/creSampleData.do", method = RequestMethod.POST)
	public @ResponseBody ResponseEntity<String> creSampleData(HttpSession session, @RequestBody HashMap<String, Object> params) {
		System.out.println("연속 혈당 샘플 데이터 생성 test");
	    /* [2026-07-11 보안] accessToken 콘솔출력 제거 */
	    
	    String tokenUrl = SAMPLE_URL;

        try {
        
            URL url = new URL(tokenUrl);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection(); connection.setConnectTimeout(5000); connection.setReadTimeout(8000);
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            connection.setRequestProperty("Authorization", "Bearer " + params.get("accessToken"));
            connection.setDoOutput(true);

            int responseCode = connection.getResponseCode();
            System.out.println("Response Code: " + responseCode);

            
            BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            StringBuilder response = new StringBuilder();
            String inputLine;
            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            in.close();

            System.out.println("create sample Data Response: " + response);

            return ResponseEntity.status(HttpStatus.CREATED).body(response.toString());

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error creating sample data: " + e.getMessage());
        } 
        
	}	
	
	@RequestMapping(value = "/getData.do", method = RequestMethod.GET)
	public @ResponseBody ResponseEntity<String> getData(HttpSession session,@RequestParam String start, @RequestParam String end,  @RequestParam String accessToken , @RequestParam String goTokenUrl) {
		System.out.println();
		System.out.println("토큰검증 + 센서 데이터 받아오기test");
		// [2026-07-11 보안] accessToken 콘솔출력 제거 (기간만 필요시 로깅)
		System.out.println("Start: " + start + ", End: " + end);
		System.out.println();
		
	    String tokenUrl = goTokenUrl;
	    System.out.println("tokenUrl :" + tokenUrl);
	    String query = String.format("start=%s&end=%s",start, end);
	    
        try {
        
            URL url = new URL(tokenUrl + "?" + query);
            System.out.println("URL :" + url);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection(); connection.setConnectTimeout(5000); connection.setReadTimeout(8000);
            connection.setRequestMethod("GET");
            connection.setRequestProperty("Authorization", "Bearer " + accessToken);
            
            int responseCode = connection.getResponseCode();
            System.out.println("Response Code: " + responseCode);

            BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            StringBuilder response = new StringBuilder();
            String inputLine;
            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            in.close();

            System.out.println("Data Response: " + response.toString());

            return ResponseEntity.ok(response.toString());

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Error occurred while requesting sensor data: " + e.getMessage());
        } 
        
	}	
	//설정값으로 application.properties
	@Value("${api.isens.cgms-url}")
	private String cgmsUrl;
	
	@RequestMapping(value = "/getBloodData.do", method = RequestMethod.GET)
	@ResponseBody
	public ResponseObject getBloodData(HttpSession session,@RequestParam String start, @RequestParam String end, @RequestParam String accessToken 
			            , @RequestParam String goTokenUrl) {
		System.out.println();
		System.out.println(" 혈당 데이터 받아오기 test");
		// [2026-07-11 보안] accessToken 콘솔출력 제거 (기간만 필요시 로깅)
		System.out.println("Start: " + start + ", End: " + end);
		System.out.println();
		
	   // String tokenUrl = goTokenUrl; 
	     String tokenUrl =  cgmsUrl ; //application.properties 선언값 
	    
	    String query = String.format("start=%s&end=%s",start, end);
	    ResponseObject json = new ResponseObject();

    
        try {
        
            URL url = new URL(tokenUrl + "?" + query);
            System.out.println("URL : "+ url);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection(); connection.setConnectTimeout(5000); connection.setReadTimeout(8000);
            connection.setRequestMethod("GET");
            connection.setRequestProperty("Authorization", "Bearer " + accessToken);
            UserDTO user = (UserDTO) session.getAttribute("user");
           
            int responseCode = connection.getResponseCode();
            System.out.println("Response Code: " + responseCode);

            
            // [2026-07-11] 서버측 자동 갱신: access token 만료(401/403)면 refresh_token 으로 재발급 후 1회 재시도
            //   (sejong-web 방식 이식 — 클라이언트 refresh 루프/재로그인 없이 투명하게 갱신)
            if (responseCode == 401 || responseCode == 403) {
                String refTok = bloodService.refreshToken(user.getUserUuid());
                String newAcc = (refTok != null && !refTok.isEmpty()) ? refreshAndSaveToken(user.getUserUuid(), refTok) : null;
                if (newAcc == null) { json.IsSucceed = false; json.Data = "REAUTH"; return json; }  // refresh 토큰도 만료 → 재연동 필요
                connection = (HttpURLConnection) new URL(tokenUrl + "?" + query).openConnection();
                connection.setConnectTimeout(5000); connection.setReadTimeout(8000);
                connection.setRequestMethod("GET");
                connection.setRequestProperty("Authorization", "Bearer " + newAcc);
                responseCode = connection.getResponseCode();
                System.out.println("Response Code(refresh): " + responseCode);
            }
            InputStream cgmIn = (responseCode >= 200 && responseCode < 300) ? connection.getInputStream() : connection.getErrorStream();
            BufferedReader in = new BufferedReader(new InputStreamReader(cgmIn));
            StringBuilder response = new StringBuilder();
            String inputLine;
            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            in.close();
            if (responseCode < 200 || responseCode >= 300) { json.IsSucceed = false; return json; }  // 갱신 후에도 실패
            System.out.println("Blood Data Response: " + response.toString());
            String jsonResponse = response.toString();
            Gson gson = new Gson();
            JsonArray jsonArray = gson.fromJson(jsonResponse, JsonArray.class);
            
            List<BloodDTO> bloodDataList = new ArrayList<>();
            if (jsonArray != null) for (JsonElement element : jsonArray) {
                BloodDTO bloodData = gson.fromJson(element, BloodDTO.class);
                bloodData.setUserId(user.getUserUuid()); 
                bloodDataList.add(bloodData); 
                
            }
            // [2026-07-11] CGM이 0건 반환 시 빈 목록 INSERT → 'VALUES  ON DUPLICATE' 문법오류 방지 (+ IsSucceed=false로 인한 refresh 루프 차단)
            if (bloodDataList != null && !bloodDataList.isEmpty()) {
                bloodService.insertBloodData(bloodDataList);
            }
            System.out.println(bloodDataList.toString());
           
  
            json.IsSucceed = true;

            return json;

        } catch (Exception e) {
            e.printStackTrace();
            json.IsSucceed = false;
            return json;
        } 
        
	}	
	/** [2026-07-11] refresh_token 으로 access_token 재발급 + T_BLDCON_MST 저장. 성공 시 새 access_token, 실패 시 null.
	 *   getBloodData 서버측 자동 갱신에서 사용 (getToken 과 동일하게 Content-Type 지정 — 갱신 실패 원인 방지). */
	private String refreshAndSaveToken(String userUuid, String refreshTokenStr) {
		try {
			String requestBody = "grant_type=refresh_token"
					+ "&client_id=" + CLIENT_ID
					+ "&client_secret=" + CLIENT_SECRET
					+ "&refresh_token=" + refreshTokenStr;
			HttpURLConnection conn = (HttpURLConnection) new URL(TOKEN_URL).openConnection();
			conn.setConnectTimeout(5000); conn.setReadTimeout(8000);
			conn.setRequestMethod("POST");
			conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
			conn.setDoOutput(true);
			try (OutputStream os = conn.getOutputStream()) { os.write(requestBody.getBytes("UTF-8")); os.flush(); }
			int code = conn.getResponseCode();
			InputStream is = (code >= 200 && code < 300) ? conn.getInputStream() : conn.getErrorStream();
			StringBuilder sb = new StringBuilder();
			try (BufferedReader in = new BufferedReader(new InputStreamReader(is, "UTF-8"))) {
				String line; while ((line = in.readLine()) != null) sb.append(line);
			}
			if (code < 200 || code >= 300) { System.out.println("refreshAndSaveToken HTTP " + code); return null; }
			JsonObject jr = new Gson().fromJson(sb.toString(), JsonObject.class);
			String newAcc = (jr != null && jr.has("access_token")) ? jr.get("access_token").getAsString() : null;
			if (newAcc == null) return null;
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("accessToken", newAcc);
			map.put("refresh_token", jr.has("refresh_token") ? jr.get("refresh_token").getAsString() : refreshTokenStr);
			map.put("token_type",   jr.has("token_type")   ? jr.get("token_type").getAsString()   : null);
			map.put("expires_in",   jr.has("expires_in")   ? jr.get("expires_in").getAsString()   : null);
			map.put("user_id",      jr.has("user_id")      ? jr.get("user_id").getAsString()      : null);
			map.put("userUuid", userUuid);
			bloodService.insertToken(map);
			return newAcc;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	@RequestMapping(value = "/refreshToken.do", method = RequestMethod.POST)
	public @ResponseBody ResponseObject refreshToken(HttpSession session) {
		
		UserDTO user = (UserDTO) session.getAttribute("user");
		ResponseObject json = new ResponseObject();
		String refreshToken = bloodService.refreshToken(user.getUserUuid());
		
		String requestBody = "grant_type=refresh_token" +
                "&client_id=" + CLIENT_ID +
                "&client_secret=" + CLIENT_SECRET +
                "&refresh_token=" + refreshToken;
	    try {
	        URL url = new URL(TOKEN_URL);
	        HttpURLConnection connection = (HttpURLConnection) url.openConnection(); connection.setConnectTimeout(5000); connection.setReadTimeout(8000);
	        connection.setRequestMethod("POST");
	        // [2026-07-11] ★토큰 갱신 실패(→재로그인 반복)의 원인: 폼 Content-Type 누락. getToken 과 동일하게 추가.
	        connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
	        connection.setDoOutput(true);
	        try (OutputStream os = connection.getOutputStream()) {
	            os.write(requestBody.getBytes());
	            os.flush();
	        }
	        int responseCode = connection.getResponseCode();
	        System.out.println("refreshToken Response Code: " + responseCode);
	        /* [2026-07-11 보안] refresh_token 콘솔출력 제거 */
	        InputStream inputStream = (responseCode == HttpURLConnection.HTTP_OK) ?
	            connection.getInputStream() : connection.getErrorStream();
	        
	        StringBuilder response = new StringBuilder();
	        try (BufferedReader in = new BufferedReader(new InputStreamReader(inputStream))) {
	            String inputLine;
	            while ((inputLine = in.readLine()) != null) {
	                response.append(inputLine);
	            }
	        }

	        /* [2026-07-11 보안] 토큰 응답 콘솔출력 제거 */
	        // Gson을 사용하여 응답 파싱
	        Gson gson = new Gson();
	        JsonObject jsonResponse = gson.fromJson(response.toString(), JsonObject.class);
	        //추출
	        Map<String, Object> map = new HashMap<String, Object>();
	        map.put("accessToken",jsonResponse.get("access_token").getAsString());
	        map.put("refresh_token", jsonResponse.get("refresh_token").getAsString());
	        map.put("token_type", jsonResponse.get("token_type").getAsString());
	        map.put("expires_in", jsonResponse.get("expires_in").getAsString());
	        map.put("user_id", jsonResponse.get("user_id").getAsString());
	        map.put("userUuid", user.getUserUuid());
	        //uuid 추가
	        bloodService.insertToken(map);
	        json.Data = response.toString();
	        json.IsSucceed = true;
	        return json;

	    } catch (Exception e) {
	        e.printStackTrace();
	        json.IsSucceed = false;
	        return json;
	    }
	}
	//findUserToken
	@RequestMapping(value = "/getBloodUserData.do", method = RequestMethod.POST)	
	public @ResponseBody Map<String, Object> getBloodUserData(HttpSession session) {
	    //System.out.println("인가코드 + UUID  db에서 꺼내오기");
	    //System.out.println(params.get("userId"));
		UserDTO user = (UserDTO) session.getAttribute("user");
	    String userId = user.getUserUuid();
	    
	    List<Map<String, Object>> list = bloodService.getBloodUserData(userId);
	    
	    Map<String, Object> result = new HashMap<>();
	    // [2026-07-11] 토큰 미보유 사용자 방어 — 기존 list.get(0) 는 빈 리스트 시 크래시
	    if (list == null || list.isEmpty()) { result.put("userId", userId); result.put("accToken", null); return result; }
	    result.put("userId" , list.get(0).get("USER_UUID"));
	    result.put("accToken" , list.get(0).get("ACC_TOKEN"));
	
	    return result;
	}
	
	//showBloodData
	@RequestMapping(value = "/showBloodData.do", method = RequestMethod.POST)	
	public @ResponseBody  Map<String, Object> showBloodData(Model model, @RequestBody HashMap<String, Object> params) {
	    
	    Map<String, Object> map = new HashMap<>();
	    Map<String, Object> result = new HashMap<>();	    
	    
	    map.put("userId", params.get("userId"));
	    map.put("start", params.get("start"));
	    map.put("end", params.get("end"));
	    	
	    List<Map<String, Object>> dataList = bloodService.showBloodData(map);	  
	    
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
	//getAvgFastingBlood
	@RequestMapping(value = "/getAvgFastingBlood.do", method = RequestMethod.POST)	
	public @ResponseBody ResponseObject getAvgFastingBlood(@RequestBody HashMap<String, Object> params) {
	    //System.out.println("공복 혈당 가져오기 ");
	    ResponseObject json = new ResponseObject();
	    
	    Map<String, Object> map = new HashMap<>();
	    map.put("date", params.get("date"));
	    map.put("userId", params.get("userId"));
	
	    Map<String, Object>  fastingBlood = bloodService.getAvgFastingBlood(map);
	    
	    if (fastingBlood != null) {
	        json.Data = fastingBlood;
	        json.IsSucceed = true;
	    } else {
	        json.IsSucceed = false; // 실패 케이스도 명확히
	        json.Message = "데이터가 없습니다.";
	    }
	
	    return json;
	}
	
	//getAvgFastingBlood
	@RequestMapping(value = "/getAvgFasting.do", method = RequestMethod.POST)	
	public @ResponseBody ResponseObject getAvgFasting(@RequestBody HashMap<String, Object> params) {
	    //System.out.println("공복 혈당 가져오기 ");
	    ResponseObject json = new ResponseObject();
	    
	    Map<String, Object> map = new HashMap<>();
	    map.put("start", params.get("start"));
	    map.put("end", params.get("end"));
	    map.put("userId", params.get("userId"));
	
	    Map<String, Object>  fastingBlood = bloodService.getAvgFasting(map);
	    
	    if (fastingBlood != null) {
	        json.Data = fastingBlood;
	        json.IsSucceed = true;
	    } else {
	        json.IsSucceed = false; // 실패 케이스도 명확히
	        json.Message = "데이터가 없습니다.";
	    }

	    return json;
	}	
	
	//getBloodChartData
	@RequestMapping(value = "/getBloodChartData.do", method = RequestMethod.POST)	
	public @ResponseBody List<Map<String, Object>> getBloodChartData(@RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));
		
		List<Map<String, Object>> result = bloodService.getBloodChartData(map);
		System.out.println("chart result"+ result);

		return result;
	}

	// [2026-07-11] 오늘 데이터가 없을 때, 데이터가 있는 가장 마지막 측정 일시를 반환(화면 폴백용)
	@RequestMapping(value = "/getLastBloodDate.do", method = RequestMethod.POST)
	public @ResponseBody ResponseObject getLastBloodDate(@RequestBody HashMap<String, Object> params) {
		ResponseObject json = new ResponseObject();

		Map<String, Object> map = new HashMap<>();
		map.put("userId", params.get("userId"));

		String lastDtm = bloodService.getLastBloodDate(map);

		if (lastDtm != null && !lastDtm.isEmpty()) {
			json.Data = lastDtm;   // 'YYYY-MM-DDTHH:mm:ss'
			json.IsSucceed = true;
		} else {
			json.IsSucceed = false; // 데이터 자체가 전혀 없음
			json.Message = "데이터가 없습니다.";
		}

		return json;
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
	@RequestMapping(value = "/BloodLowHigh.do", method = RequestMethod.POST)	
	public @ResponseBody Map<String, Object> BloodLowHigh(@RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));
		
		Map<String, Object> result = bloodService.BloodLowHigh(map);
		
		return result;
	}
	
	//calcBlood sd
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
		System.out.println("GMI~ result :" + result);
		
		return result;
	}	
	
	@RequestMapping(value = "/tokenYn.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject tokenYn(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model) throws Exception {
		UserDTO user = (UserDTO) session.getAttribute("user");
		int count = bloodService.tokenYn(user.getUserUuid());
		ResponseObject result = new ResponseObject();
		result.Data = "Data";
		result.IsSucceed = count > 0 ? true : false;
		return result;
	}
	
	@RequestMapping(value = "/getTodayBlood.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getTodayBlood(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model) throws Exception {
		UserDTO user = (UserDTO) session.getAttribute("user");
		List<Map<String,Object>> list = bloodService.getTodayBlood(user.getUserUuid());
		ResponseObject result = new ResponseObject();
		result.Data = list;
		result.IsSucceed = true;
		return result;
	}
	
	@RequestMapping(value = "/getTodayBlodAvg.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getTodayBlodAvg(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model) throws Exception {
		UserDTO user = (UserDTO) session.getAttribute("user");
		Map<String,Object> map = bloodService.getTodayFastingBlood(user.getUserUuid());
		Map<String,Object> map2 = bloodService.getTodayMealBlood(user.getUserUuid());
		Map<String,Object> data = new HashMap<String,Object>();
		data.put("fastBlod", map.get("avgBlood"));
		data.put("mealBlod", map2.get("avgBlood"));
		ResponseObject result = new ResponseObject();
		result.Data = data;
		result.IsSucceed = true;
		return result;
	}
	@RequestMapping(value = "/getBMI.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getBMI(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model) throws Exception {
		UserDTO user = (UserDTO) session.getAttribute("user");
		Map<String,Object> map = bloodService.getBMI(user.getUserUuid());
		ResponseObject result = new ResponseObject();
		result.Data = map;
		result.IsSucceed = true;
		return result;
	}
	@RequestMapping(value = "/deleteToken.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject deleteToken(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model) throws Exception {
		UserDTO user = (UserDTO) session.getAttribute("user");
		int data = bloodService.deleteToken(user.getUserUuid());
		ResponseObject result = new ResponseObject();
		result.Data = data;
		result.IsSucceed = true;
		return result;
	}
	//analysisBlood
	@RequestMapping(value = "/analysisBlood.do", method = RequestMethod.POST)	
	public @ResponseBody Map<String, Object> analysisBlood(@RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));
		
		Map<String, Object> result = bloodService.analysisBlood(map);	
		
		System.out.println("GMI~ result :" + result);
		
		return result;
	}	
	//공복혈당  
	@RequestMapping(value = "/analfastingBlood.do", method = RequestMethod.POST)	
	public @ResponseBody Map<String, Object> analfastingBlood(@RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));
		
		Map<String, Object> result = bloodService.analfastingBlood(map);	
		
		System.out.println("GMI~ result :" + result);
		
		return result;
	}
	//식후혈당 
	@RequestMapping(value = "/analpostBlood.do", method = RequestMethod.POST)	
	public @ResponseBody Map<String, Object> analpostBlood(@RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));
		
		Map<String, Object> result = bloodService.analpostBlood(map);	
		
		System.out.println("GMI~ result :" + result);
		
		return result;
	}	
	//운동전후혈당  
	@RequestMapping(value = "/analexerBlood.do", method = RequestMethod.POST)	
	public @ResponseBody List<Map<String, Object>> analexerBlood(@RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));
		
		List<Map<String, Object>> result = bloodService.analexerBlood(map);	

		System.out.println("GMI~ list size: " + (result == null ? 0 : result.size()));
	    return result == null ? Collections.emptyList() : result;

	}
	//식후혈당   analfoodBlood
	@RequestMapping(value = "/analfoodBlood.do", method = RequestMethod.POST)	
	public @ResponseBody List<Map<String, Object>> analfoodBlood(@RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));
		map.put("gubun", params.get("onlyRise"));
		
		List<Map<String, Object>> result = bloodService.analfoodBlood(map);	

		System.out.println("GMI~ list size: " + (result == null ? 0 : result.size()));
	    return result == null ? Collections.emptyList() : result;

	}
	//오늘의 식후혈당 시간후 
	@RequestMapping(value = "/today_foodBlood.do", method = RequestMethod.POST)	
	public @ResponseBody List<Map<String, Object>> today_foodBlood(@RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));
		map.put("gubun", params.get("onlyRise"));
		
		List<Map<String, Object>> result = bloodService.today_foodBlood(map);	

		System.out.println("GMI~ list size: " + (result == null ? 0 : result.size()));
	    return result == null ? Collections.emptyList() : result;

	}	
	//오늘의 식후혈당 혈당높은순위 
	@RequestMapping(value = "/today_foodBlood_max.do", method = RequestMethod.POST)	
	public @ResponseBody List<Map<String, Object>> today_foodBlood_max(@RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));
		map.put("gubun", params.get("onlyRise"));
		
		List<Map<String, Object>> result = bloodService.today_foodBlood_max(map);	

		System.out.println("GMI~ list size: " + (result == null ? 0 : result.size()));
	    return result == null ? Collections.emptyList() : result;

	}
	//오늘의 식후혈당 시간후 
	@RequestMapping(value = "/today_exerBlood.do", method = RequestMethod.POST)	
	public @ResponseBody List<Map<String, Object>> today_exerBlood(@RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));
		map.put("gubun", params.get("onlyRise"));
		
		List<Map<String, Object>> result = bloodService.today_exerBlood(map);	

		System.out.println("GMI~ list size: " + (result == null ? 0 : result.size()));
	    return result == null ? Collections.emptyList() : result;

	}	
	//오늘의 식후혈당 혈당높은순위 
	@RequestMapping(value = "/today_exerBlood_max.do", method = RequestMethod.POST)	
	public @ResponseBody List<Map<String, Object>> today_exerBlood_max(@RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));
		map.put("gubun", params.get("onlyRise"));
		
		List<Map<String, Object>> result = bloodService.today_exerBlood_max(map);	

		System.out.println("GMI~ list size: " + (result == null ? 0 : result.size()));
	    return result == null ? Collections.emptyList() : result;
	}			
	//calcBlood sd
	@RequestMapping(value = "/avgBlood.do", method = RequestMethod.POST)	
	public @ResponseBody Map<String, Object> avgBlood(@RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));
		
		Map<String, Object> result = bloodService.avgBlood(map);	
		
		return result;
	}
	//오늘의 식후혈당 혈당높은순위 
	@RequestMapping(value = "/avgBloodlowhight.do", method = RequestMethod.POST)	
	public @ResponseBody List<Map<String, Object>> avgBloodlowhight(@RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));
		
		List<Map<String, Object>> result = bloodService.avgBloodlowhight(map);	

		System.out.println("avgBloodl~ list size: " + (result == null ? 0 : result.size()));
	    return result == null ? Collections.emptyList() : result;
	}	
	//오늘의 식후혈당 혈당높은순위 
	@RequestMapping(value = "/foodBlood_max.do", method = RequestMethod.POST)	
	public @ResponseBody List<Map<String, Object>> foodBlood_max(@RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));
		map.put("gubun", params.get("onlyRise"));
		
		List<Map<String, Object>> result = bloodService.foodBlood_max(map);	

		System.out.println("GMI~ list size: " + (result == null ? 0 : result.size()));
	    return result == null ? Collections.emptyList() : result;

	}	
	@RequestMapping(value = "/exerBlood_max.do", method = RequestMethod.POST)	
	public @ResponseBody List<Map<String, Object>> exerBlood_max(@RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));
		map.put("gubun", params.get("onlyRise"));
		
		List<Map<String, Object>> result = bloodService.exerBlood_max(map);	

		System.out.println("GMI~ list size: " + (result == null ? 0 : result.size()));
	    return result == null ? Collections.emptyList() : result;
	}
	@RequestMapping(value = "/showBloodAvgData.do", method = RequestMethod.POST)	
	public @ResponseBody Map<String, Object> showBloodAvgData(@RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));
		
		Map<String, Object> result = bloodService.showBloodAvgData(map);
		System.out.println("chart result"+ result);
			   
		return result;
	}	
	@RequestMapping(value = "/showBloodHighLow.do", method = RequestMethod.POST)	
	public @ResponseBody Map<String, Object> showBloodHighLow(@RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userId", params.get("userId"));
		
		Map<String, Object> result = bloodService.showBloodHighLow(map);
		System.out.println("chart result"+ result);

		return result;
	}

	// =====================================================================
	// 혈당 Q&A 챗봇 자유질문 LLM(Gemini) fallback
	//   - Blood_Consult.jsp 의 _chatResponse() 키워드/데이터 매칭 실패 시 호출
	//   - 클라이언트가 보내는 질문(q) + 화면 혈당지표 요약(ctx)을 프롬프트로 구성
	//   - API 키 미설정/오류 시 IsSucceed=false → 화면은 안내문구로 폴백
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
			json.Message = "LLM 미설정";   // 클라이언트는 안내문구로 폴백
			return json;
		}

		// 화면 혈당 요약 컨텍스트 (클라이언트 _chatCtxText 에서 전달, 없으면 생략)
		String ctx = params.get("ctx") != null ? params.get("ctx").toString() : "";
		if (ctx.length() > 400) ctx = ctx.substring(0, 400);

		// ═══ 프롬프트 — 기획 「AI 응답 Sample」(3차 전달자료_AI, 2026-08-13) 반영 ═══
		//   ★수치·유형 판정은 **화면(기존 자료)** 이 하고, LLM 은 **문장만** 만든다.
		//     ctx 에 TIR/TAR/TBR/CV 원값과 우리가 판정한 유형이 실려 온다(_chatCtxText).
		//     ⚠LLM 에 판정을 맡기면 같은 수치에 다른 유형이 나온다 — 그래서 「다시 계산하지 말라」고 못박는다.
		//   ★답변 골격 = 기획안의 3단계 : ①현재 상태 → ②이유/피드백 → ③유지·개선 행동.
		//     원본 샘플이 그 구조일 때 "사용자가 즉시 이해하고 행동하기에 가장 효과적"이라고 결론냈다.
		String systemInstruction =
			"너는 당뇨/혈당 관리를 돕는 친절한 한국어 건강 도우미야. "
			+ "사용자는 연속혈당측정(CGM)을 사용하는 환자야. "
			+ "답변은 의학적 진단이 아니라 일반적인 생활관리 참고용이며, 심한 고혈당·저혈당이나 이상 증상은 반드시 담당 의사와 상담하라고 안내해. "
			+ "답변은 100자 내외로 짧게, 줄바꿈은 <br> 태그로 표기해. "
			+ "혈당 상태에 대한 질문이면 현재 상태 → 그렇게 보는 이유 → 지금 할 행동 순서로 각각 한 문장씩 써. "
			+ "번호(①②③)나 머리기호 없이 자연스러운 문장으로만 써. "
			+ "아래 참고 정보는 앱이 이미 계산해 화면에 보여준 판정이야. 다시 계산하거나 바꾸지 말고 그대로 근거로 삼아. "
			+ "숫자·퍼센트·지표 이름(TIR/TAR/TBR/CV)은 답변에 쓰지 마 — 수치는 사용자 화면 표가 이미 보여주고 있어. "
			+ "판정유형별 방향 — 우수: 현재 식사·운동 유지를 격려 / 고혈당형: 식사량·탄수화물 비율 조절과 식후 걷기 / "
			+ "저혈당형: 공복 운동 회피, 운동 전후 혈당 확인, 식사 거르지 않기 / 변동형: 식사·운동 시간을 일정하게. "
			+ (ctx.isEmpty() ? "" : "참고 — 앱이 계산한 사용자 지표: " + ctx);

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
			// 추론 토큰도 maxOutputTokens 를 함께 소모하므로 넉넉히 잡는다.
			// (1024 로 두면 추론에 900+ 를 써버려 답변이 잘림 = finishReason:MAX_TOKENS)
			genCfg.addProperty("maxOutputTokens", 2048);
			// thinking(추론) 최소화 — 단순 건강 Q&A 라 깊은 추론이 불필요.
			//   ※ gemini-flash-latest 별칭이 Gemini 3 계열(gemini-3.6-flash)로 바뀌면서
			//     기존 thinkingBudget:0 은 400 INVALID_ARGUMENT 로 거부된다(추론 완전 비활성 불가).
			//     Gemini 3 부터는 thinkingLevel("low"/"high") 을 사용한다.
			JsonObject thinkingCfg = new JsonObject();
			thinkingCfg.addProperty("thinkingLevel", "low");
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

			// 응답 파싱: candidates[0].content.parts[*].text
			//   Gemini 3 는 parts 에 추론 전용 조각(text 없이 thoughtSignature 만)이 섞여 올 수 있어
			//   parts[0] 만 보면 null 이 되므로 text 가 있는 조각을 모두 이어붙인다.
			JsonObject root = gson.fromJson(sb.toString(), JsonObject.class);
			JsonArray candidates = root.getAsJsonArray("candidates");
			if (candidates == null || candidates.size() == 0) return null;
			JsonObject cand = candidates.get(0).getAsJsonObject();
			JsonObject candContent = cand.getAsJsonObject("content");
			if (candContent == null) return null;
			JsonArray parts = candContent.getAsJsonArray("parts");
			if (parts == null || parts.size() == 0) return null;
			StringBuilder text = new StringBuilder();
			for (int i = 0; i < parts.size(); i++) {
				JsonElement textEl = parts.get(i).getAsJsonObject().get("text");
				if (textEl != null && !textEl.isJsonNull()) text.append(textEl.getAsString());
			}
			return text.length() == 0 ? null : text.toString();

		} catch (Exception e) {
			log.error("callGemini error: " + e.getMessage(), e);
			return null;
		}
	}
}
