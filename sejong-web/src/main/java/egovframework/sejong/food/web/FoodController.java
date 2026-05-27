package egovframework.sejong.food.web;

import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.sejong.food.model.FoodDTO;
import egovframework.sejong.food.service.FoodService;
import egovframework.sejong.util.ResponseObject;


@Controller
public class FoodController {
	@Resource(name = "FoodService")
	FoodService foodService;

	// 메인 페이지 이동
	@RequestMapping("/foodMain.do")
	public String index(HttpSession session, Model model) {
		model.addAttribute("menuName","식사기록 페이지");
		return ".main/food/foodMain";
	}

	// 식사 등록/수정 (upsert)
	@RequestMapping(value = "/updateFood.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject updateFood(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model, @ModelAttribute("DTO") FoodDTO dto) throws Exception {
		// 세션에 저장된 사용자 UUID 사용 (unifiedLogin 에서 setAttribute("userUuid", ...))
		String userUuid = (String) session.getAttribute("userUuid");
		if (userUuid != null && !userUuid.isEmpty()) {
			dto.setUserUuid(userUuid);
		}
		foodService.updateFood(dto);
		ResponseObject result = new ResponseObject();
		result.Data = "Data";
		result.IsSucceed = true;
		return result;
	}

	// 식사(자연키) 음식 행 조회
	@RequestMapping(value = "/getFoodDetail.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getFoodDetail(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model, @RequestBody HashMap<String,Object> reqMap) throws Exception {
		List<FoodDTO> foodList = foodService.getFoodData(reqMap);
		ResponseObject result = new ResponseObject();
		result.Data = foodList;
		result.IsSucceed = true;
		return result;
	}

	// 일자별 식사 요약
	@RequestMapping(value = "/getFoodInfo.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getFoodInfo(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model, @RequestBody HashMap<String,Object> reqMap) throws Exception {
		String userUuid = (String) session.getAttribute("userUuid");
		if (userUuid != null && !userUuid.isEmpty()) {
			reqMap.put("userUuid", userUuid);
		}
		List<HashMap<String,Object>> list = foodService.getFoodInfo(reqMap);
		ResponseObject result = new ResponseObject();
		result.Data = list;
		result.IsSucceed = true;
		return result;
	}

	// 식사(자연키) 삭제
	@RequestMapping(value = "/deleteFoodData.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject deleteFoodData(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model, @RequestBody HashMap<String,Object> reqMap) throws Exception {
		foodService.deleteFoodData(reqMap);
		ResponseObject result = new ResponseObject();
		result.Data = "Data";
		result.IsSucceed = true;
		return result;
	}
}
