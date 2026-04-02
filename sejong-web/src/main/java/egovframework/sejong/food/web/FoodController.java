package egovframework.sejong.food.web;

import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.sejong.food.service.FoodService;
import egovframework.sejong.user.model.UserDTO;
import egovframework.sejong.util.ResponseObject;


@Controller
public class FoodController {
	@Resource(name = "FoodService") // 서비스 선언
	FoodService foodService;
	
	// 메인 페이지 이동
	@RequestMapping("/foodMain.do")
	public String index(HttpSession session,Model model) {
		model.addAttribute("menuName","식사기록 페이지");
		return ".main/food/foodMain";
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
	
	// food data detail 
	// FoodLens Edit 수정을 위한 파일을 보낼때 사용 
	@RequestMapping(value = "/getFoodDetail.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getFoodDetail(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model, @RequestBody HashMap<String,Object> reqMap) throws Exception {
		HashMap<String,Object> foodMap = foodService.getFoodData(reqMap);
		ResponseObject result = new ResponseObject();
		result.Data = foodMap;
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
		foodService.insertFoodData(jsonObject);
		ResponseObject result = new ResponseObject();
		result.Data = "Data";
		result.IsSucceed = true;
		return result;
	}
}
