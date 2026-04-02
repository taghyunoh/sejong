package egovframework.sejong.options.web;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.sejong.exercise.model.ExerciseDTO;
import egovframework.sejong.login.model.UserDTO;
import egovframework.sejong.options.model.AsqDTO;
import egovframework.sejong.options.model.FaqDTO;
import egovframework.sejong.login.service.LoginService;
import egovframework.sejong.options.model.NotiDTO;
import egovframework.sejong.options.service.OptionsService;
import egovframework.sejong.util.ResponseObject;


@Controller
public class OptionsController {
	@Resource(name = "OptionsService") // 서비스 선언
	OptionsService optionsService;
	@Resource(name = "LoginService") // 서비스 선언
	LoginService loginService;
	// 공지사항 페이지 이동
	@RequestMapping("/noticePage.do")
	public String index(HttpSession session,Model model) {
		model.addAttribute("menuName","공지사항");
		return ".main/options/notice";
	}
	@RequestMapping("/notiDetail.do")
	public String notiDetail(HttpSession session,Model model,int notiSeq) {
		System.out.println(notiSeq);
		NotiDTO dto = optionsService.getNotiDetail(notiSeq);
		model.addAttribute("menuName","공지사항");
		model.addAttribute("noti",dto);
		return ".main/options/noticeDetail";
	}
	// 설정 페이지 이동
	@RequestMapping("/settingPage.do")
	public String Setting(HttpSession session,Model model) {
		model.addAttribute("menuName","설정");
		return ".main/options/setting";
	}
	// 개인정보 변경 페이지 이동
	@RequestMapping("/userSettingPage.do")
	public String userSettingPage(HttpSession session,Model model) {
		model.addAttribute("menuName","개인정보");
		return ".main/options/userSetting";
	}
	// FAQ 페이지 이동
	@RequestMapping("/faqPage.do")
	public String faqPage(HttpSession session,Model model) {
		model.addAttribute("menuName","FAQ");
		return ".main/options/faq";
	}
	// getNotiList 
	@RequestMapping(value = "/getNotiList.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getNotiList(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model) throws Exception {
		List<NotiDTO> list = optionsService.getNotiList();
		ResponseObject result = new ResponseObject();
		result.Data = list;
		result.IsSucceed = true;
		return result;
	}
	// getUserInfo 
	@RequestMapping(value = "/getUserInfo.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getUserInfo(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model) throws Exception {
		UserDTO user = (UserDTO) session.getAttribute("user");
		ResponseObject result = new ResponseObject();
		result.Data = user;
		result.IsSucceed = true;
		return result;
	}
	// updateUserInfo 
	@RequestMapping(value = "/updateUserInfo.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject updateUserInfo(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model,@RequestBody UserDTO userDto) throws Exception {
		UserDTO user = (UserDTO) session.getAttribute("user");
		userDto.setUserUuid(user.getUserUuid());
		optionsService.updateUserInfo(userDto);
		ResponseObject result = new ResponseObject();
		UserDTO updateUser = loginService.getUser(user.getPhone());
		session.setAttribute("user", updateUser);
		result.IsSucceed = true;
		return result;
	}
	// 1:1 페이지 이동
	@RequestMapping("/asqMain.do")
	public String asqMain(HttpSession session,Model model) {
		model.addAttribute("menuName","1:1문의관리");
		return ".main/asqmain/asqMain";
	}	
	//updateStep
	@RequestMapping(value = "/updateAsq.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseEntity<String> updateAsq(@RequestBody List<AsqDTO> data) {
  
		System.out.println("Insert 시작했음");
		String returnValue = "OK";

	    try {
	        for (AsqDTO dto : data) {
	             optionsService.updateAsq(dto);
	        }

	        return ResponseEntity.ok(returnValue); 
	    } catch (Exception e) {
	    	return ResponseEntity.status(500).body(e.getMessage());
	    }
	}
	//delete
	@RequestMapping(value = "/deleteAsq.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseEntity<String> deleteAsq(@RequestBody List<AsqDTO> data) {
  
		System.out.println("delete 시작했음");
		String returnValue = "OK";

	    try {
	        for (AsqDTO dto : data) {
	             optionsService.deleteAsq(dto);
	        }

	        return ResponseEntity.ok(returnValue); 
	    } catch (Exception e) {
	    	return ResponseEntity.status(500).body(e.getMessage());
	    }
	}
	// 개별운동 기간별조회   
	@RequestMapping(value = "/getAsqList.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getAsqList(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model,@RequestBody Map<String,Object> map) throws Exception {
		ResponseObject obj = new ResponseObject();
		List<AsqDTO> list = optionsService.getAsqList(map);
		obj.IsSucceed = true;
		obj.Data = list;
		return obj;
	}	
	// 개별운동 기간별조회   
	@RequestMapping(value = "/getFaqList.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getFaqList(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model,@RequestBody Map<String,Object> map) throws Exception {
		ResponseObject obj = new ResponseObject();
		List<FaqDTO> list = optionsService.getFaqList(map);
		obj.IsSucceed = true;
		obj.Data = list;
		return obj;
	}		
}
