package egovframework.sejong.food.web;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.sejong.food.model.FoodDTO;
import egovframework.sejong.food.service.FoodService;
import egovframework.sejong.login.model.UserDTO;
import egovframework.sejong.util.ResponseObject;


@Controller
public class FoodController {
	@Resource(name = "FoodService") // 서비스 선언
	FoodService foodService;
	
	// 메인 페이지 이동
	@RequestMapping("/foodMain.do")
	public String index(HttpSession session,Model model) {
		session.setAttribute("menuName", "식사등록");
		model.addAttribute("menuName","식사등록");
		UserDTO user = (UserDTO) session.getAttribute("user");
		model.addAttribute("gender",user.getGender());
		return ".main/food/foodMain";
	}
	// 메인 페이지 이동
	@RequestMapping("/foodConsult.do")
	public String foodConsult(HttpSession session,Model model) {
		session.setAttribute("menuName", "식사연관 혈당분석");
		model.addAttribute("menuName","식사연관 혈당분석");
		UserDTO user = (UserDTO) session.getAttribute("user");
		model.addAttribute("gender",user.getGender());
		return ".main/Food_Consult";
	}
	
	// food data insert
	@RequestMapping(value = "/insertFoodData.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject insertFoodData(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model, @RequestBody String data) throws Exception {
		JSONParser parser = new JSONParser();
        JSONObject jsonObject = (JSONObject) parser.parse(data);
        UserDTO user = (UserDTO) session.getAttribute("user");
        jsonObject.put("userUuid", user.getUserUuid());
		foodService.insertFoodData(jsonObject);
		ResponseObject result = new ResponseObject();
		result.Data = "Data";
		result.IsSucceed = true;
		return result;
	}
	

	// getFoodInfo
	// 화면에보여지는 음식 정보 
	@RequestMapping(value = "/getFoodInfo.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getFoodInfo(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model, @RequestBody HashMap<String,Object> reqMap) throws Exception {
		UserDTO user = (UserDTO) session.getAttribute("user");
		reqMap.put("userUuid", user.getUserUuid());
		List<HashMap<String,Object>> list = foodService.getFoodInfo(reqMap);
		ResponseObject result = new ResponseObject();
		result.Data = list;
		result.IsSucceed = true;
		return result;
	}
	// food data edit
	// 푸드렌즈에서 반환받은 데이터로 수
	@RequestMapping(value = "/editFoodData.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject editFoodData(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model, @RequestBody HashMap<String,Object> reqMap) throws Exception {
		System.out.println(reqMap);
		String data = reqMap.get("data").toString();
		JSONParser parser = new JSONParser();
        JSONObject jsonObject = (JSONObject) parser.parse(data);
        foodService.deleteFoodData(reqMap);
        UserDTO user = (UserDTO) session.getAttribute("user");
        jsonObject.put("userUuid", user.getUserUuid());
        jsonObject.put("foodhisSeq", reqMap.get("foodhisSeq"));
		foodService.updateFoodData(jsonObject);
		ResponseObject result = new ResponseObject();
		result.Data = "Data";
		result.IsSucceed = true;
		return result;
	}
	
	//getChartFood
	@RequestMapping(value = "/getChartFood.do", method = RequestMethod.POST)	
	public @ResponseBody ResponseObject getChartFood(HttpSession session, @RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		UserDTO user = (UserDTO) session.getAttribute("user");
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userUuid", user.getUserUuid());
		
		List<Map<String, Object>> list = foodService.getChartFood(map);
		ResponseObject result = new ResponseObject();
		result.Data = list;
		result.IsSucceed = true;
		System.out.println(result);
			   
		return result;
	}
	// 개별운동 기간별조회   
	//updateStep
	@RequestMapping(value = "/updateFood.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseEntity<String> updateFood(@RequestBody List<FoodDTO> data) {
  
		System.out.println("Insert 시작했음");
		String returnValue = "OK";

	    try {
	        for (FoodDTO dto : data) {
	             foodService.updateFood(dto);
	        }

	        return ResponseEntity.ok(returnValue); 
	    } catch (Exception e) {
	    	return ResponseEntity.status(500).body(e.getMessage());
	    }
	}
	//delete
	@RequestMapping(value = "/deleteFood.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseEntity<String> deleteFood(@RequestBody List<FoodDTO> data) {
  
		System.out.println("delete 시작했음");
		String returnValue = "OK";

	    try {
	        for (FoodDTO dto : data) {
	             foodService.deleteFood(dto) ;
	        }

	        return ResponseEntity.ok(returnValue); 
	    } catch (Exception e) {
	    	return ResponseEntity.status(500).body(e.getMessage());
	    }
	}	
	@RequestMapping(value = "/getFoodList.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getFood(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model,@RequestBody Map<String,Object> map) throws Exception {
		ResponseObject obj = new ResponseObject();
		List<FoodDTO> list = foodService.getFoodList(map);
		obj.IsSucceed = true;
		obj.Data = list;
		return obj;
	}
	@RequestMapping(value = "/getFoodMstList.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getFoodMstList(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model,@RequestBody Map<String,Object> map) throws Exception {
		ResponseObject obj = new ResponseObject();
		List<FoodDTO> list = foodService.getFoodMstList(map);
		obj.IsSucceed = true;
		obj.Data = list;
		return obj;
	}	
	//당일 칼로리합산 
	@RequestMapping(value = "/getTodaysumFood.do", method = RequestMethod.POST)	
	public @ResponseBody ResponseObject getTodaysumFood(HttpSession session, @RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		UserDTO user = (UserDTO) session.getAttribute("user");
		map.put("start", params.get("start"));
		map.put("userUuid", user.getUserUuid());
		
		List<Map<String, Object>> list = foodService.getTodaysumFood(map);
		ResponseObject result = new ResponseObject();
		result.Data = list;
		result.IsSucceed = true;
		System.out.println(result);
			   
		return result;
	}		
}
