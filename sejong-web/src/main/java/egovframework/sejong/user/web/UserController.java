package egovframework.sejong.user.web;

import java.util.HashMap;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.sejong.user.model.UserDTO;
import egovframework.sejong.user.service.UserService;
import egovframework.util.EgovFileScrty;

import org.springframework.ui.ModelMap;

@Controller
public class UserController {

	private static final Logger log = LoggerFactory.getLogger(UserController.class);
	
	
	@Resource(name = "UserService") // 서비스 선언
	private UserService svc;

	    @GetMapping("/")
	    public String redirectToLogin() {
	    	return "redirect:https://allcare24.kr/login.do";
	    }
	    //메인화면 호출
		@RequestMapping(value = "/main.do")
		public String MainPage(HttpServletRequest request, ModelMap model) throws Exception {
			
			return ".main/main";
		}


		//최초 로그인 페이지 호출
		@RequestMapping(value = "/index.do")
		public String IndexPage(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request, ModelMap model) throws Exception {
		
			return ".login/APLO_01";
			
		}	 
		
		// 로그인 화면
		@RequestMapping(value = "/login.do")  // 두 경로를 모두 처리
		public String login(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request,ModelMap model) throws Exception {
			try { 
			}catch(Exception ex) {
				model.addAttribute("error_code", "10000"); 
			}
	
			return ".login/APLO_01";

		}  
		// test 메뉴
		@RequestMapping(value = "/test/test.do")  // 두 경로를 모두 처리
		public String testlogin(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request,ModelMap model) throws Exception {

			try { 
			}catch(Exception ex) {
				model.addAttribute("error_code", "10000"); 
			}
		
			return ".main/admin/admin_test";

		} 
		@RequestMapping(value = "/test/pagetest.do")  // 두 경로를 모두 처리
		public String pagetestlogin(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request,ModelMap model) throws Exception {

			try { 
			}catch(Exception ex) {
				model.addAttribute("error_code", "10000"); 
			}
		
			return ".main/admin/admin_page_test";

		} 		
		/* 사용자 로그인 처리 */
		@RequestMapping(value="/user/loginAct.do", method = RequestMethod.POST)
		public String UserLoginProcess(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request, Model model) throws Exception {
			
			try {  
//				HashMap<String, Object> reqMap = new HashMap<String, Object>();

				dto.setUser_id(EgovFileScrty.encryptPassword(dto.getUser_id(), dto.getUser_id()));
				
				UserDTO result = svc.userLoginCheck(dto);

				if("".equals(result.getUser_id()) && result.getUser_id() == null ) {
						model.addAttribute("error_code", "20000");
						model.addAttribute("error_msg", "사용자 ID 정보가 존재하지 않습니다."); 
					return "jsonView";
				}else {	
					byte[] salt = {};
					//String chkpwd = EgovFileScrty.encryptPassword(dto.getUser_pw(), dto.getUser_id());
					String chkpwd = EgovFileScrty.encryptPassword(dto.getUser_pw(), "1234");
					//비밀번호 초기화 여부 체크
					String resetpwd = EgovFileScrty.encryptPassword("1234", dto.getUser_id()); 
					HttpSession session = request.getSession(); 
					
					session.setAttribute("q_user_id"   , result.getUser_id());   //사용자 ID
					session.setAttribute("q_user_nm"   , result.getUser_nm());   //사용자 명
					session.setAttribute("q_admin_yn"  , result.getUser_gb()); 	// 관리자 구분 'A', 의사 : D
					session.setAttribute("q_dept_nm"   , result.getDept_nm()); 	// 진료과명
					session.setAttribute("q_user_ip"   , request.getRemoteAddr().toString()); 	// 접속IP 주소
					session.setAttribute("q_screen_id" , "login");
					session.setAttribute("admingu"     , result.getUser_gb());
					session.setAttribute("q_uuid"      , "8e17a341-a750-4bfb-9e6c-35d31a7308dd");
					
			
					if(!result.getUser_pw().equals(chkpwd)) {
						model.addAttribute("error_code", "30000");
						model.addAttribute("error_msg" , "비밀번호를 확인하세요.!");
//					}else if(!"Y".equals(result.getUseyn())) {
//						model.addAttribute("error_code", "20000");
//						model.addAttribute("error_msg" , "사용자의 사용여부가 비활성화된 상태입니다.");
					}else {
						model.addAttribute("error_code", "00000");
						model.addAttribute("error_msg" , "");
					}
				}
				
			}catch(Exception ex) {
				log.error(" LOGIN ERROR ! : "+ ex.getMessage());
				model.addAttribute("error_code", "20000");
				model.addAttribute("error_msg" , "사용자 정보가 존재하지 않습니다."); 
							
			}
			
			
			return "jsonView";
		}
		
		/* 사용자 로그아웃 처리 */
		@RequestMapping(value="/user/loginOutAct.do")
		 public String UserLogOutProcess(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request, ModelMap model) throws Exception { 
		
			HttpSession session = request.getSession(); 
			//세션 초기화 
			session.invalidate();
			 
			return "forward:/login.do";
		}

		/* 사용자 비밀번호변경 화면 */
		@RequestMapping(value="/popup/pwdchg.do")
		public String UserPwdChangePage(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request, ModelMap model)
				throws Exception {  
			 
			 
			return ".login/APLO_03";
		}
		/* 로그인한 사용자 비밀번호변경 화면 */
		@RequestMapping(value="/popup/Hpwdchg.do")
		public String UserHPwdChangePage(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request, ModelMap model)
				throws Exception {  
			 
			 
			return ".login/Hpwdchg";
		}
		/* 사용자 비밀번호 초기화 화면 */
		@RequestMapping(value="/popup/pwdclear.do")
		public String UserPwdClearPage(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request, ModelMap model)
				throws Exception {  
			 
			
			return ".login/APLO_02";
		}
		

		/* 사용자 비밀번호 초기화 처리 */
		@RequestMapping(value="/json/user/pwdresetAct.do")
		public String UserPwdResetSave(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request, ModelMap model)
				throws Exception {  
			
			try {
				
				dto.setUser_id(EgovFileScrty.encryptPassword(dto.getUser_id(), dto.getUser_id()));
				
				UserDTO result = svc.userInfo(dto);
				
				if(result == null || ("".equals(result.getUser_id()) && result.getUser_id() == null )) {
					model.addAttribute("error_code", "30000");
					model.addAttribute("error_msg" , "사용자 정보가 존재하지 않습니다.");
					return "jsonView";
				}
				dto.setEnc_user_pwd(EgovFileScrty.encryptPassword("1234", "1234"));
				//사용자 비밀번호 초기화 처리
				boolean chk = svc.userPwdReset(dto);
				if(chk) {
					model.addAttribute("error_code", "0");
					model.addAttribute("error_msg" , "");
				}else {
					model.addAttribute("error_code", "10000");
					model.addAttribute("error_msg" , "사용자 비밀번호 초기화 실패하였습니다.");
				}
			}catch(Exception ex) {
				log.error(" UserPwdResetSave ERROR ! : "+ ex.getMessage());
				model.addAttribute("error_code", "20000");
				model.addAttribute("error_msg" , "사용자 비밀번호 초기화 실패하였습니다."); 
							
			}
			//
			return "jsonView";
		}
		

		/* 사용자 비밀번호변경 처리 */
		@RequestMapping(value="/json/user/pwdchgAct.do")
		public String UserPwdChangeSave(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request, ModelMap model)
				throws Exception {  
			
			try {
				System.out.println("기존 비밀번호 : "+ dto.getUser_pw() + "     변경 비밀번호 :  "+ dto.getBf_user_pwd());
				
				dto.setUser_id(EgovFileScrty.encryptPassword(dto.getUser_id(), dto.getUser_id()));
				
				UserDTO result = svc.userInfo(dto);

				if("".equals(result.getUser_id()) || result.getUser_id().toString() == null ){ 
					model.addAttribute("error_code", "20000");
					model.addAttribute("error_msg" , "비밀번호 변경할 사용자 정보가 존재하지 않습니다.");
					return "jsonView";
				}
				String chkpwd = EgovFileScrty.encryptPassword(dto.getUser_pw(), "1234");
				
				if(!result.getUser_pw().equals(chkpwd)) {
					model.addAttribute("error_code", "30000");
					model.addAttribute("error_msg" , "현재 비밀번호를 확인하세요.!");
					return "jsonView";
				}

				if(dto.getBf_user_pwd() == "") {
					model.addAttribute("error_code", "30000");
					model.addAttribute("error_msg" , "비밀번호 변경할 사용자 정보가 존재하지 않습니다.");
					return "jsonView";
				}
				dto.setEnc_user_pwd(EgovFileScrty.encryptPassword(dto.getBf_user_pwd(), "1234"));
				//비밀번호 변경 처리			
				boolean chk = svc.userPwdChange(dto);
				
				if(chk) {
					model.addAttribute("error_code", "0");
					model.addAttribute("error_msg" , "");
				}else {
					model.addAttribute("error_code", "10000");
					model.addAttribute("error_msg" , "사용자 비밀번호 변경 실패하였습니다.");
				}
			}catch(Exception ex) {
				log.error(" UserPwdChangeSave ERROR ! : "+ ex.getMessage());
				model.addAttribute("error_code", "10000");
				model.addAttribute("error_msg" , "사용자 비밀번호 변경 실패하였습니다."); 
							
			}
			//
			return "jsonView";
		}
}
