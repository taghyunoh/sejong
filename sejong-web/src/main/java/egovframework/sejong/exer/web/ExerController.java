package egovframework.sejong.exer.web;

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

import egovframework.sejong.exer.model.ExerDTO;
import egovframework.sejong.exer.service.ExerService;
import egovframework.sejong.util.ResponseObject;


@Controller
public class ExerController {
	@Resource(name = "ExerService")
	ExerService exerService;

	// 메인 페이지 이동
	@RequestMapping("/exerMain.do")
	public String index(HttpSession session, Model model) {
		model.addAttribute("menuName","운동기록 페이지");
		return ".main/exer/exerMain";
	}

	// 운동 등록/수정 (upsert)
	@RequestMapping(value = "/updateExer.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject updateExer(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model, @ModelAttribute("DTO") ExerDTO dto) throws Exception {
		String userUuid = (String) session.getAttribute("userUuid");
		if (userUuid != null && !userUuid.isEmpty()) {
			dto.setUserUuid(userUuid);
		}
		exerService.updateExer(dto);
		ResponseObject result = new ResponseObject();
		result.Data = "Data";
		result.IsSucceed = true;
		return result;
	}

	// 운동(자연키) 운동 행 조회
	@RequestMapping(value = "/getExerDetail.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getExerDetail(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model, @RequestBody HashMap<String,Object> reqMap) throws Exception {
		List<ExerDTO> exerList = exerService.getExerData(reqMap);
		ResponseObject result = new ResponseObject();
		result.Data = exerList;
		result.IsSucceed = true;
		return result;
	}

	// 일자별 운동 요약
	@RequestMapping(value = "/getExerInfo.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getExerInfo(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model, @RequestBody HashMap<String,Object> reqMap) throws Exception {
		String userUuid = (String) session.getAttribute("userUuid");
		if (userUuid != null && !userUuid.isEmpty()) {
			reqMap.put("userUuid", userUuid);
		}
		List<HashMap<String,Object>> list = exerService.getExerInfo(reqMap);
		ResponseObject result = new ResponseObject();
		result.Data = list;
		result.IsSucceed = true;
		return result;
	}

	// 운동(자연키) 삭제
	@RequestMapping(value = "/deleteExerData.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject deleteExerData(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model, @RequestBody HashMap<String,Object> reqMap) throws Exception {
		exerService.deleteExerData(reqMap);
		ResponseObject result = new ResponseObject();
		result.Data = "Data";
		result.IsSucceed = true;
		return result;
	}
}
