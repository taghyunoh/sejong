package egovframework.sejong.login.web;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.hsqldb.rights.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestTemplate;

import org.springframework.beans.factory.annotation.Value; // 보안설정 문제 
import org.springframework.context.annotation.PropertySource;
import org.springframework.http.MediaType;

import egovframework.sejong.food.model.FoodDTO;
import egovframework.sejong.login.model.UserDTO;
import egovframework.sejong.login.model.SjgnDTO;
import egovframework.sejong.login.service.LoginService;
import egovframework.sejong.util.NCP_SMSUtil;
import egovframework.sejong.util.ResponseObject;
import egovframework.sejong.util.SeedUtil;

@Controller
public class LoginController {
	
	private Logger logs = LogManager.getLogger(this.getClass().getSimpleName());
	
	@Resource(name = "LoginService") // 서비스 선언
	LoginService loginService;
	
	private SeedUtil seed;
	
	@Autowired
	NCP_SMSUtil smsUtil;
	
	
	// 로그인
	
	@RequestMapping(value = "/sampleAjax.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject sampleAjax(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model) throws Exception {
		ResponseObject result = new ResponseObject();
		result.Data = "Data";
		result.IsSucceed = true;
		return result;
	}
	// 메인 페이지 이동
	@RequestMapping("/index.do")
	public String index(HttpSession session) {
		System.out.println("TEST");
		//
		try {
			int i = loginService.connectionTest();
			System.out.println(i);
		} catch (Exception ex) {
			System.out.println("SQLException" + ex);
		}
		return ".main/index";
	}
	// 로그인 페이지 이동 
	//application.properties
	@Value("${kakao.javascript.key}")
    private String kakaoJsKey;
	 
	@RequestMapping("/loginPage.do") 
	public String loginPage(HttpSession session , Model model) throws Exception {
		String uuid = UUID.randomUUID().toString();
        System.out.println(uuid);
        model.addAttribute("kakaoJsKey", kakaoJsKey);
		return ".login/login";
	}
	// 메인 페이지 이동
	@RequestMapping("/mainPage.do")
	public String mainPage(HttpSession session,Model model) {
		UserDTO user = (UserDTO) session.getAttribute("user");
		model.addAttribute("gender",user.getGender());
		return ".login/main";
	}
	
	// 사용자 체크(임시 나중취소)
	/*
	@RequestMapping(value = "/loginCheck.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject loginCheck(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model, @RequestBody Map<String,String> map) throws Exception {
		ResponseObject obj = new ResponseObject();
		String phone = map.get("phone"); // 사용자 전화번호 
		int result = 0;
		if (phone != null && !phone.trim().isEmpty()) {
			result = loginService.loginCheck(phone);
			if(result > 0) {
				UserDTO user = loginService.getUser(phone);
				session.setAttribute("user", user);
				session.setAttribute("userNm", user.getUserNm());
				session.setAttribute("userUuid", user.getUserUuid());
				
				obj.IsSucceed = true;
				obj.Message = "회원정보 입력 성공";
			}else {
				obj.IsSucceed = false;
				obj.Message = "회원정보가 존재하지않습니다 회원가입하세요.";				
			}

		}else {
			obj.IsSucceed = false;
			obj.Message = "회원정보가 존재하지않습니다 회원가입하세요.";
		}
		obj.Data = result;
		return obj;
	}
	*/
	// 사용자 체크(나중 복구) 

	@RequestMapping(value = "/loginCheck.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject loginCheck(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model, @RequestBody Map<String,String> map) throws Exception {
		ResponseObject obj = new ResponseObject();
		String phone = map.get("phone"); // 사용자 전화번호 
		String authCode = map.get("authCode");// 사용자 입력 인증코드
		String sessionAuthCode = session.getAttribute("authCode").toString();
		int result = 0;
		if(authCode.equals(sessionAuthCode)) {
			result = loginService.loginCheck(phone);
			if(result > 0) {
				UserDTO user = loginService.getUser(phone);
				session.setAttribute("user", user);
				session.setAttribute("userNm", user.getUserNm());
				session.setAttribute("userUuid", user.getUserUuid());
				
			}
			obj.IsSucceed = true;
			obj.Message = "인증번호 입력 성공";
		}else {
			obj.IsSucceed = false;
			obj.Message = "인증번호를 정확히 입력 부탁드립니다.";
		}
		obj.Data = result;
		return obj;
	}

	// 사용자 체크
	@RequestMapping(value = "/autoLogin.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject autoLogin(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model, @RequestBody Map<String,String> map) throws Exception {
		ResponseObject obj = new ResponseObject();
		String phone = map.get("phone"); // 사용자 전화번호 
		int result = 0;
		result = loginService.loginCheck(phone);
		if(result > 0) {
			UserDTO user = loginService.getUser(phone);
			session.setAttribute("user", user);
			session.setAttribute("userNm", user.getUserNm());
			session.setAttribute("userUuid", user.getUserUuid());
			obj.IsSucceed = true;
		}else {
			obj.IsSucceed = false;
		}
		obj.Data = result;
		return obj;
	}
	// 인증번호 전송 
	@RequestMapping(value = "/sendSensApi.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject sendSensApi(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model,@RequestBody String phone) throws Exception {
		ResponseObject obj = new ResponseObject();
		try {
			if(session.getAttribute("time") == null) {
				smsUtil.sendSMS(phone);
				obj.IsSucceed = true;
				obj.Message = "인증번호 발송 성공하였습니다.";
				return obj;
			}
			String sessionTime = (String)session.getAttribute("time").toString();
			String timestamp = Long.toString(System.currentTimeMillis());
			// 두 타임스탬프를 long으로 변환
			long time1 = Long.parseLong(sessionTime);
			long time2 = Long.parseLong(timestamp);
			// 3분(180000밀리초) 차이가 나는지 확인
			if (Math.abs(time2 - time1) >= 3 * 60 * 1000) {
				smsUtil.sendSMS(phone);
				obj.IsSucceed = true;
				obj.Message = "인증번호 발송 성공하였습니다.";
			} else {
			    obj.IsSucceed =false;
			    obj.Message = "인증번호 전송 후 3분이 지나지 않았습니다.\n잠시 후 다시 요청 부탁드립니다.";
			}
		}catch(Exception e) {
			logs.error("Error 발생 sendSensApi :");
			e.printStackTrace();
			logs.error(e.getMessage());
			obj.IsSucceed =false;
			obj.Message ="에러 발생 관리자에게 문의 부탁드립니다.";
		}
		return obj;
	}
	//	회원정보입력 
	@RequestMapping(value = "/registerUser.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject registerUser(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model,@RequestBody UserDTO userDto) throws Exception {
		ResponseObject obj = new ResponseObject();
		try {
			loginService.registerUser(userDto);
			UserDTO user = loginService.getUser(userDto.getPhone());
			session.setAttribute("user", user);
			session.setAttribute("userNm", user.getUserNm());
			session.setAttribute("userUuid", user.getUserUuid());
			obj.IsSucceed = true;
		}catch(Exception e) {
			obj.IsSucceed = false;
		}
		obj.Data = "";
		return obj;
	}
	//회원정보수정 
	@RequestMapping(value = "/updateUser.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject updateUser(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model,@RequestBody UserDTO userDto) throws Exception {
		ResponseObject obj = new ResponseObject();
		try {
			loginService.updateUser(userDto);
			UserDTO user = loginService.getUser(userDto.getPhone());
			session.setAttribute("user", user);
			session.setAttribute("userNm", user.getUserNm());
			session.setAttribute("userUuid", user.getUserUuid());
			obj.IsSucceed = true;
		}catch(Exception e) {
			obj.IsSucceed = false;
		}
		obj.Data = "";
		return obj;
	}	
    //회원여부 전화번호 조회 
	@RequestMapping(value = "/User.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject User(HttpSession session, HttpServletRequest request,
	        HttpServletResponse response, Model model, @RequestBody UserDTO userDto) throws Exception {
	    
	    ResponseObject obj = new ResponseObject();
	    try {
	        UserDTO user = loginService.getUser(userDto.getPhone());

	        if (user != null) {
	            obj.IsSucceed = true;      // 자료 있음 → 성공
	        } else {
	            obj.IsSucceed = false;     // 자료 없음 → 실패
	        }
	    } catch (Exception e) {
	        obj.IsSucceed = false;         // 예외 발생 시 실패 처리
	        e.printStackTrace();
	    }
	    return obj;
	}	
	// 테스트유저
	@RequestMapping(value = "/testUser.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject testUser(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model) throws Exception {
		ResponseObject obj = new ResponseObject();
		UserDTO user = loginService.getUser("01036721855");
		session.setAttribute("user", user);
		session.setAttribute("userNm", user.getUserNm());
		session.setAttribute("userUuid", user.getUserUuid());
		obj.Data = user;
		return obj;
	}
	// 테스트유저2
	@RequestMapping(value = "/testUser2.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject testUser2(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model) throws Exception {
		ResponseObject obj = new ResponseObject();
		UserDTO user = loginService.getUser("01098333399");
		session.setAttribute("user", user);
		session.setAttribute("userNm", user.getUserNm());
		session.setAttribute("userUuid", user.getUserUuid());
		obj.Data = user;
		return obj;
	}
	// 테스트유저3
	@RequestMapping(value = "/testUser3.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject testUser3(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model ,@RequestBody Map<String,String> map) throws Exception {
		ResponseObject obj = new ResponseObject();
		try {
		    String email = map.get("email");
		    UserDTO user = loginService.getUserEmail(email);
		    
		    if (user != null) {
		        session.setAttribute("user", user);
		        
		        // userNm이 null일 경우 기본값 처리
		        String userNm = user.getUserNm();
		        if (userNm == null || userNm.isEmpty()) {
		        }
		        session.setAttribute("userNm", userNm);
		        session.setAttribute("userUuid", user.getUserUuid());
		        
		        obj.Data = user;
		    } else {
		    }
		} catch (Exception e) {
		    e.printStackTrace();
		}
		return obj;
	}	
	// 로그아
	@RequestMapping(value = "/logout.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject logout(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model) throws Exception {
		ResponseObject obj = new ResponseObject();
		session.removeAttribute("user");
		session.removeAttribute("userNm");
		return obj;
	}
	//Spring MV 보안설정  

	@PropertySource("classpath:application.properties")
	@Component
	public class MyClientConfig{

	    @Value("${spring.security.oauth2.client.registration.google.client-id}")
	    private String clientId;

	    @Value("${spring.security.oauth2.client.registration.google.client-secret}")
	    private String clientSecret;

	    public String getClientId() {
	        return clientId;
	    }

	    public void setClientId(String clientId) {
			this.clientId = clientId;
		}

		public void setClientSecret(String clientSecret) {
			this.clientSecret = clientSecret;
		}

		public String getClientSecret() {
	        return clientSecret;
	    }
	    @PostConstruct
	    public void print() {
	        System.out.println("✅ [MyClientConfig 초기화]");
	        System.out.println("Client ID: " + clientId);
	        System.out.println("Client Secret: " + clientSecret);
	    }
	}	
    @Autowired
    private  MyClientConfig myClientConfig;

	//구글로그인   
	@RequestMapping("/callback.do")
	public String handleCallback(@RequestParam String code, Model model) {
	    try {
	        System.out.println("구글 콜백");

	        RestTemplate restTemplate = new RestTemplate();
	        String tokenUri = "https://oauth2.googleapis.com/token";


	        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
	        params.add("code", code);
	        
            params.add("client_id", myClientConfig.getClientId());
            params.add("client_secret", myClientConfig.getClientSecret());
            
            params.add("redirect_uri", "http://localhost:8080/callback.do"); // 본인 redirect_uri
            params.add("grant_type", "authorization_code");

	        HttpHeaders headers = new HttpHeaders();
	        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
	        HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(params, headers);

	        ResponseEntity<Map> response = restTemplate.postForEntity(tokenUri, request, Map.class);
	        Map<String, Object> tokenResponse = response.getBody();
	        String accessToken = (String) tokenResponse.get("access_token");

	        HttpHeaders userHeaders = new HttpHeaders();
	        userHeaders.setBearerAuth(accessToken);
	        HttpEntity<String> userRequest = new HttpEntity<>(userHeaders);

	        String userInfoUri = "https://www.googleapis.com/oauth2/v2/userinfo";
	        ResponseEntity<Map> userInfoResponse = restTemplate.exchange(userInfoUri, HttpMethod.GET, userRequest, Map.class);

	        Map<String, Object> userInfo = userInfoResponse.getBody();
	        String email = (String) userInfo.get("email");
	        String name = (String) userInfo.get("name");

	        model.addAttribute("email1", email);
	        model.addAttribute("nickname", name);
	        
	    } catch (Exception e) {
	        e.printStackTrace();
	        model.addAttribute("error", "구글 인증 중 오류가 발생했습니다.");
	    }

	    return ".login/login";
	}
	//회원탈퇴  delete
	@RequestMapping(value = "/alldelete.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseEntity<String> deleteFood(@RequestBody List<UserDTO> data) {
  
		System.out.println("delete 시작했음");
		String returnValue = "OK";

	    try {
	        for (UserDTO dto : data) {
	        	loginService.delAllUser(dto) ;
	        	loginService.delAllFood(dto) ;
	        	loginService.delAllExer(dto) ;
	        	loginService.delAllBldcon(dto) ;
	        	loginService.delAllBldinf(dto) ;
	        	loginService.delAllPersign(dto) ;
	        }
	        return ResponseEntity.ok(returnValue); 
	    } catch (Exception e) {
	    	return ResponseEntity.status(500).body(e.getMessage());
	    }
	}
	@RequestMapping(value = "/getSignList.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getSignList(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model,@RequestBody Map<String,Object> map ) throws Exception {
		ResponseObject obj = new ResponseObject();
		List<SjgnDTO> list = loginService.getSignList(map);
		obj.IsSucceed = true;
		obj.Data = list;
		return obj;
	}	
}
