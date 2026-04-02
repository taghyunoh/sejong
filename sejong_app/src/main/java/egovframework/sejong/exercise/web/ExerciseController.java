package egovframework.sejong.exercise.web;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.sejong.exercise.model.ExerciseDTO;
import egovframework.sejong.exercise.service.ExerciseService;
import egovframework.sejong.login.model.UserDTO;
import egovframework.sejong.util.ResponseObject;

@Controller
public class ExerciseController {
	@Resource(name = "ExerciseService") // 서비스 선언
	ExerciseService exerService;
	// 메인 페이지 이동
	@RequestMapping("/exerMain.do")
	public String index(HttpSession session,Model model) {
		session.setAttribute("menuName", "운동등록");
		model.addAttribute("menuName","운동등록");
		return ".main/exercise/exerMain";
	}

	//updateStep
	// 메인 페이지 이동
	@RequestMapping("/exerConsult.do")
	public String exerConsult(HttpSession session,Model model) {
		session.setAttribute("menuName", "운동연관 혈당분석");
		model.addAttribute("menuName","운동연관 혈당분석");
		return ".main/Exercise_Consult";
	}
	@RequestMapping(value = "/updateStep.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject updateStep(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model,@RequestBody String data) throws Exception {
		JSONParser parser = new JSONParser();
		JSONArray jsonArr = (JSONArray) parser.parse(data);
		ResponseObject obj = new ResponseObject();
		int result = 0;
		try {
			result = exerService.updateStep(jsonArr);
			obj.IsSucceed = true;
		}catch(Exception e) {
			obj.IsSucceed = false;
		}
		obj.Data = result;
		return obj;
	}
	//updateStep
	@RequestMapping(value = "/updateHealth.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseEntity<String> updateHealth(@RequestBody List<ExerciseDTO> data) {
  
		System.out.println("Insert 시작했음");
		String returnValue = "OK";

	    try {
	        for (ExerciseDTO dto : data) {
	             exerService.updateHealth(dto);
	        }

	        return ResponseEntity.ok(returnValue); 
	    } catch (Exception e) {
	    	return ResponseEntity.status(500).body(e.getMessage());
	    }
	}
	//delete
	@RequestMapping(value = "/deleteHealth.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseEntity<String> deleteHealth(@RequestBody List<ExerciseDTO> data) {
  
		System.out.println("delete 시작했음");
		String returnValue = "OK";

	    try {
	        for (ExerciseDTO dto : data) {
	             exerService.deleteHealth(dto);
	        }

	        return ResponseEntity.ok(returnValue); 
	    } catch (Exception e) {
	    	return ResponseEntity.status(500).body(e.getMessage());
	    }
	}
	// 개별운동 기간별조회   
	@RequestMapping(value = "/getExercise.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getExercise(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model,@RequestBody Map<String,Object> map) throws Exception {
		ResponseObject obj = new ResponseObject();
		List<ExerciseDTO> list = exerService.getExercise(map);
		obj.IsSucceed = true;
		obj.Data = list;
		return obj;
	}
	// 개별운동 당일조회   
	@RequestMapping(value = "/getTodayExecs.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getTodayExecs(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model) throws Exception {
		ResponseObject obj = new ResponseObject();
		UserDTO user = (UserDTO) session.getAttribute("user");
		UserDTO result = exerService.getTodayExecs(user);
		obj.IsSucceed = true;
		obj.Data = result;
		return obj;
	}
	@RequestMapping(value = "/getTodaysumExecs.do", method = RequestMethod.POST)	
	public @ResponseBody ResponseObject getChartFood(HttpSession session, @RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		UserDTO user = (UserDTO) session.getAttribute("user");
		// map.put("start", params.get("start"));
		// map.put("end", params.get("end"));
		map.put("userUuid", user.getUserUuid());
		
		List<Map<String, Object>> list = exerService.getTodaysumExecs(map);
		ResponseObject result = new ResponseObject();
		result.Data = list;
		result.IsSucceed = true;
		System.out.println(result);
			   
		return result;
	}	
	
}
