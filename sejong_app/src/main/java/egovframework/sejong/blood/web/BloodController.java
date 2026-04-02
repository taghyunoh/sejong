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
	@Resource(name = "BloodService") // 서비스 선언
	BloodService bloodService;

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
		model.addAttribute("menuName","혈당 연관분석");
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
	        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
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

	        System.out.println("Token Response: " + response.toString());
	        
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

	
	
	//creSampleData
	@RequestMapping(value = "/creSampleData.do", method = RequestMethod.POST)
	public @ResponseBody ResponseEntity<String> creSampleData(HttpSession session, @RequestBody HashMap<String, Object> params) {
		System.out.println("연속 혈당 샘플 데이터 생성 test");
	    System.out.println(params.get("accessToken"));
	    
	    String tokenUrl = SAMPLE_URL;

        try {
        
            URL url = new URL(tokenUrl);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
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
		System.out.println("Start: " + start + ", End: " + end + ", AccessToken: " + accessToken);
		System.out.println();
		
	    String tokenUrl = goTokenUrl;
	    System.out.println("tokenUrl :" + tokenUrl);
	    String query = String.format("start=%s&end=%s",start, end);
	    
        try {
        
            URL url = new URL(tokenUrl + "?" + query);
            System.out.println("URL :" + url);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
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
		System.out.println("Start: " + start + ", End: " + end + ", AccessToken: " + accessToken);
		System.out.println();
		
	   // String tokenUrl = goTokenUrl; 
	     String tokenUrl =  cgmsUrl ; //application.properties 선언값 
	    
	    String query = String.format("start=%s&end=%s",start, end);
	    ResponseObject json = new ResponseObject();

    
        try {
        
            URL url = new URL(tokenUrl + "?" + query);
            System.out.println("URL : "+ url);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setRequestProperty("Authorization", "Bearer " + accessToken);
            UserDTO user = (UserDTO) session.getAttribute("user");
           
            int responseCode = connection.getResponseCode();
            System.out.println("Response Code: " + responseCode);

            
            BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            StringBuilder response = new StringBuilder();
            String inputLine;
            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            in.close();
            System.out.println("Blood Data Response: " + response.toString());       
            String jsonResponse = response.toString();
            Gson gson = new Gson();
            JsonArray jsonArray = gson.fromJson(jsonResponse, JsonArray.class);
            
            List<BloodDTO> bloodDataList = new ArrayList<>();
            for (JsonElement element : jsonArray) {
                BloodDTO bloodData = gson.fromJson(element, BloodDTO.class);
                bloodData.setUserId(user.getUserUuid()); 
                bloodDataList.add(bloodData); 
                
            }
            bloodService.insertBloodData(bloodDataList);
            System.out.println(bloodDataList.toString());
           
  
            json.IsSucceed = true;

            return json;

        } catch (Exception e) {
            e.printStackTrace();
            json.IsSucceed = false;
            return json;
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
	        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
	        connection.setRequestMethod("POST");  
	        connection.setDoOutput(true);
	        try (OutputStream os = connection.getOutputStream()) {
	            os.write(requestBody.getBytes());
	            os.flush();
	        }
	        int responseCode = connection.getResponseCode();
	        System.out.println("refreshToken Response Code: " + responseCode);
	        System.out.println(refreshToken);
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
}
