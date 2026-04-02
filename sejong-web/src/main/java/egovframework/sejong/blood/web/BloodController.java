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

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.codehaus.jackson.map.annotate.JsonView;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
	
	@RequestMapping("/goBloodPage.do")
	public String goSamplePage(HttpSession session) {
		return ".main/doctor/FAHR_00";
	}
	
	@RequestMapping("/goBloodPage2.do")
	public String goBloodPage2(HttpSession session) {
		return ".main/doctor/FAHR_01F_1";
	}
	
	@RequestMapping(value = "/getAuth.do", method = RequestMethod.POST)	
	public @ResponseBody Map<String, String> authorize(@RequestBody HashMap<String, Object> params) {
	    System.out.println("인가코드 받아오기 test");

	    String authUrl = "https://accounts.i-sens.com/auth/authorize" +
	                            "?response_type=code" +
	                            "&client_id=" + params.get("client_id") +
	                            "&redirect_uri=" + params.get("redirect_uri");

	    Map<String, String> responseMap = new HashMap<>();
	    responseMap.put("redirectUrl", authUrl);
	    System.out.println(responseMap);
	
	    return responseMap;
	}
	
	@RequestMapping(value = "/getToken.do", method = RequestMethod.POST)
	public @ResponseBody String getToken(HttpSession session,  @RequestBody HashMap<String, Object> params) {
		System.out.println("token 받아오기test");
	    
	    System.out.println(params);
	    
	    
	    String tokenUrl = "https://accounts.i-sens.com/oauth2/token";
	    
	    String clientId = (String) params.get("client_id");
	    String clientSecret = (String) params.get("client_secret");
	    String redirectUri = (String) params.get("redirect_uri");
	    String code = (String)params.get("code");
	    
	    String requestBody = "grant_type=authorization_code" +
	                         "&code=" + code +
	                         "&client_id=" + clientId +
	                         "&client_secret=" + clientSecret +
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
	    
	    String tokenUrl = "https://api.i-sens.com/v1/public/samples";

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
	
	
	
	@RequestMapping(value = "/getBloodData.do", method = RequestMethod.GET)
	public @ResponseBody ResponseEntity<String> getBloodData(HttpSession session,@RequestParam String start, @RequestParam String end, @RequestParam String accessToken , @RequestParam String goTokenUrl, @RequestParam String user_uuid) {
		System.out.println();
		System.out.println(" 혈당 데이터 받아오기 test");
		System.out.println("Start: " + start + ", End: " + end + ", AccessToken: " + accessToken);
		System.out.println("user_uuid :" + user_uuid);
		System.out.println();
		
	    String tokenUrl = goTokenUrl;
	    String query = String.format("start=%s&end=%s",start, end);
	    
	 
	    
        try {
        
            URL url = new URL(tokenUrl + "?" + query);
            System.out.println("URL : "+ url);
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

    
            System.out.println("Blood Data Response: " + response.toString());
            
            
            String jsonResponse = response.toString();
            Gson gson = new Gson();
            JsonArray jsonArray = gson.fromJson(jsonResponse, JsonArray.class);
            
            List<BloodDTO> bloodDataList = new ArrayList<>();
            for (JsonElement element : jsonArray) {
                BloodDTO bloodData = gson.fromJson(element, BloodDTO.class);
                bloodData.setUser_uuid(user_uuid); 
                bloodDataList.add(bloodData); 
                
            }
            bloodService.insertBloodData(bloodDataList);
            System.out.println(bloodDataList.toString());
           

            return ResponseEntity.ok(response.toString());

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Error occurred while requesting sensor data: " + e.getMessage());
        } 
        
	}		
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
	
	//showBloodData
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
	
	//getAvgFastingBlood
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
	
	
}

