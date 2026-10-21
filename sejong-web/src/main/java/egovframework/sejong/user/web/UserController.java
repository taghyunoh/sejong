package egovframework.sejong.user.web;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.sejong.admin.model.PatientDTO;
import egovframework.sejong.admin.service.AdminService;
import egovframework.sejong.user.model.SjgnDTO;
import egovframework.sejong.user.model.UserDTO;
import egovframework.sejong.user.service.UserService;
import egovframework.util.EgovFileScrty;

import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RequestBody;
import egovframework.sejong.util.ResponseObject;

@Controller
public class UserController {

	private static final Logger log = LoggerFactory.getLogger(UserController.class);


	@Resource(name = "UserService") // 서비스 선언
	private UserService svc;

	@Resource(name = "AdminService") // 환자(T_USER_TRAN) 처리용
	private AdminService adminSvc;

	    @GetMapping("/")
	    public String redirectToLogin() {
	    	return "redirect:https://allcare24.kr/login.do";
	    }
	    //메인화면 호출 (권한 분기: 환자 P → raw 단독 JSP, 의사/관리자 → 기존 tiles main)
		@RequestMapping(value = "/main.do")
		public String MainPage(HttpServletRequest request, ModelMap model) throws Exception {
			HttpSession session = request.getSession();
			String userGb = (String) session.getAttribute("q_admin_yn");
			if ("P".equals(userGb)) {
				return ".raw/main/patient/patient_main";
			}
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
		// 2026-05-27 정리: /test/test.do, /test/pagetest.do 제거 (대상 JSP 삭제됨)

		/* 사용자 로그인 처리 */
		@RequestMapping(value="/user/loginAct.do", method = RequestMethod.POST)
		public String UserLoginProcess(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request, Model model) throws Exception {
			
			try {  
//				HashMap<String, Object> reqMap = new HashMap<String, Object>();

				dto.setUserId(EgovFileScrty.encryptPassword(dto.getUserId(), dto.getUserId()));
				
				UserDTO result = svc.userLoginCheck(dto);

				if("".equals(result.getUserId()) && result.getUserId() == null ) {
						model.addAttribute("error_code", "20000");
						model.addAttribute("error_msg", "사용자 ID 정보가 존재하지 않습니다."); 
					return "jsonView";
				}else {	
					byte[] salt = {};
					//String chkpwd = EgovFileScrty.encryptPassword(dto.getUserPw(), dto.getUserId());
					String chkpwd = EgovFileScrty.encryptPassword(dto.getUserPw(), "1234");
					//비밀번호 초기화 여부 체크
					String resetpwd = EgovFileScrty.encryptPassword("1234", dto.getUserId()); 
					HttpSession session = request.getSession(); 
					
					session.setAttribute("q_user_id"   , result.getUserId());   //사용자 ID
					session.setAttribute("q_user_nm"   , result.getUserNm());   //사용자 명
					session.setAttribute("q_admin_yn"  , result.getUserGb()); 	// 관리자 구분 'A', 의사 : D
					session.setAttribute("q_dept_nm"   , result.getDeptNm()); 	// 진료과명
					session.setAttribute("q_user_ip"   , request.getRemoteAddr().toString()); 	// 접속IP 주소
					session.setAttribute("q_screen_id" , "login");
					session.setAttribute("admingu"     , result.getUserGb());
					session.setAttribute("q_uuid"      , "8e17a341-a750-4bfb-9e6c-35d31a7308dd");
					
			
					if(!result.getUserPw().equals(chkpwd)) {
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

		// =====================================================================
		// 환자(T_USER_TRAN, USER_GB='P') 로그인 / 회원가입
		// =====================================================================

		/** 환자 로그인 페이지 — 통합 로그인으로 리다이렉트 (호환 유지) */
		@RequestMapping(value = "/patient/login.do")
		public String patientLoginPage() {
			return "redirect:/login.do";
		}

		/**
		 * 환자 회원가입 페이지 — 웹 회원가입 막음 (2026-09-28) : 로그인 화면으로 돌려보낸다.
		 * 되살리려면 return ".raw/login/patient_register"; 로 되돌리고, patientRegisterAct 가 patientRegisterActDisabled(원래 가입 처리)를 부르게 한다.
		 */
		@RequestMapping(value = "/patient/register.do")
		public String patientRegisterPage() {
			return "redirect:/login.do";
		}

		/** 환자 로그인 처리 (전화번호 + 비밀번호) */
		@RequestMapping(value = "/patient/loginAct.do", method = RequestMethod.POST)
		@ResponseBody
		public ResponseObject patientLoginAct(@RequestBody PatientDTO dto, HttpServletRequest request) throws Exception {
			ResponseObject res = new ResponseObject();
			try {
				PatientDTO result = adminSvc.patientLoginCheck(dto);
				if (result == null || result.getUserUuid() == null) {
					res.IsSucceed = false;
					res.Message = "등록되지 않은 전화번호입니다.";
					return res;
				}
				String chkpwd = EgovFileScrty.encryptPassword(dto.getUserPw(), result.getPhone());
				if (result.getUserPw() == null || !result.getUserPw().equals(chkpwd)) {
					res.IsSucceed = false;
					res.Message = "비밀번호를 확인하세요.";
					return res;
				}
				HttpSession session = request.getSession();
				session.setAttribute("user", result);
				session.setAttribute("userNm", result.getUserNm());
				session.setAttribute("userUuid", result.getUserUuid());
				session.setAttribute("q_user_id", result.getUserUuid());
				session.setAttribute("q_user_nm", result.getUserNm());
				session.setAttribute("q_admin_yn", "P");
				session.setAttribute("q_user_ip", request.getRemoteAddr());
				session.setAttribute("q_screen_id", "patient");
				res.IsSucceed = true;
				res.Data = result.getUserUuid();
				return res;
			} catch (Exception ex) {
				log.error("patientLoginAct ERROR: " + ex.getMessage(), ex);
				res.IsSucceed = false;
				res.Message = "로그인 처리 중 오류";
				return res;
			}
		}

		/**
		 * 환자 회원가입 처리.
		 *
		 * 동작:
		 *   1) 입력 검증 & 전화번호 중복 체크
		 *   2) 비밀번호 해시 (salt = phone)
		 *   3) T_USER_TRAN INSERT — USER_UUID 는 DB 의 UUID() 로 생성
		 *   4) PHONE 으로 방금 만든 user 재조회 → USER_UUID 획득
		 *   5) T_PERSIGN_TRAN 에 동의이력 3건 — best-effort
		 *      ※ T_SIGN_MST/T_PERSIGN_TRAN 이 아직 없거나 비어있어도 가입 자체는 성공.
		 *      ※ 향후 테이블/데이터가 준비되면 자동으로 INSERT 시작.
		 *
		 * @Transactional 을 의도적으로 붙이지 않음 — 가입(T_USER_TRAN) 과 동의이력(T_PERSIGN_TRAN) 을
		 *                분리해서 약관 테이블 미설정 시에도 가입 자체는 막히지 않게 함.
		 */
		@RequestMapping(value = "/patient/registerAct.do", method = RequestMethod.POST)
		@ResponseBody
		public ResponseObject patientRegisterAct(@RequestBody PatientDTO dto, HttpServletRequest request) throws Exception {
			ResponseObject res = new ResponseObject();
			// 웹 회원가입 막음 (2026-09-28) — 페이지만 막으면 이 주소로 직접 가입할 수 있어 여기서도 거절한다.
			res.IsSucceed = false; res.Message = "웹 회원가입은 지원하지 않습니다."; return res;
		}

		private ResponseObject patientRegisterActDisabled(PatientDTO dto) throws Exception {
			ResponseObject res = new ResponseObject();
			try {
				if (dto.getPhone() == null || dto.getPhone().trim().isEmpty()) {
					res.IsSucceed = false; res.Message = "전화번호는 필수입니다."; return res;
				}
				if (dto.getUserPw() == null || dto.getUserPw().length() < 4) {
					res.IsSucceed = false; res.Message = "비밀번호는 4자 이상이어야 합니다."; return res;
				}
				int exists = adminSvc.patientExistsByPhone(dto);
				if (exists > 0) {
					res.IsSucceed = false; res.Message = "이미 등록된 전화번호입니다."; return res;
				}
				// 비밀번호 해시: salt = phone
				String encPw = EgovFileScrty.encryptPassword(dto.getUserPw(), dto.getPhone());
				dto.setUserPw(encPw);
				adminSvc.patientRegister(dto);

				// 가입 직후 PHONE 으로 USER_UUID 재조회 (UUID() 는 DB 자동생성)
				PatientDTO lookup = new PatientDTO();
				lookup.setPhone(dto.getPhone());
				PatientDTO joined = adminSvc.patientLoginCheck(lookup);

				// 약관 동의이력 저장 — best-effort. 테이블 미설정/데이터 없음에 관대.
				if (joined != null && joined.getUserUuid() != null) {
					try {
						svc.saveAllPatientAgreements(joined.getUserUuid(), joined.getUserUuid());
					} catch (Exception consentEx) {
						log.warn("동의이력 저장 실패 — 가입은 정상 진행 (T_SIGN_MST/T_PERSIGN_TRAN 미설정 가능): "
								+ consentEx.getMessage());
					}
				}

				res.IsSucceed = true;
				res.Message = "회원가입이 완료되었습니다. 로그인 해주세요.";
				return res;
			} catch (Exception ex) {
				log.error("patientRegisterAct ERROR: " + ex.getMessage(), ex);
				res.IsSucceed = false;
				res.Message = "회원가입 처리 중 오류: " + ex.getMessage();
				return res;
			}
		}

		/** 환자 본인 정보 조회 — 세션 userUuid 기준 (개인정보 변경 모달용) */
		@RequestMapping(value = "/patient/myInfo.do", method = RequestMethod.POST)
		@ResponseBody
		public ResponseObject patientMyInfo(HttpServletRequest request) throws Exception {
			ResponseObject res = new ResponseObject();
			try {
				String uuid = (String) request.getSession().getAttribute("userUuid");
				if (uuid == null || uuid.isEmpty()) { res.IsSucceed = false; res.Message = "로그인이 필요합니다."; return res; }
				PatientDTO dto = new PatientDTO();
				dto.setUserUuid(uuid);
				PatientDTO info = adminSvc.patientInfo(dto);
				if (info != null) info.setUserPw(null);   // 해시라도 화면으로 내보내지 않는다
				res.IsSucceed = true;
				res.Data = info;
				return res;
			} catch (Exception ex) {
				log.error("patientMyInfo ERROR: " + ex.getMessage(), ex);
				res.IsSucceed = false; res.Message = "조회 중 오류";
				return res;
			}
		}

		/** 환자 본인 정보 수정 — 이메일·키·몸무게만. 대상은 세션 userUuid 로 고정(클라이언트 값 무시) */
		@RequestMapping(value = "/patient/myInfoSave.do", method = RequestMethod.POST)
		@ResponseBody
		public ResponseObject patientMyInfoSave(@RequestBody PatientDTO dto, HttpServletRequest request) throws Exception {
			ResponseObject res = new ResponseObject();
			try {
				String uuid = (String) request.getSession().getAttribute("userUuid");
				if (uuid == null || uuid.isEmpty()) { res.IsSucceed = false; res.Message = "로그인이 필요합니다."; return res; }
				dto.setUserUuid(uuid);
				adminSvc.updatePatientSelf(dto);
				res.IsSucceed = true; res.Message = "저장되었습니다.";
				return res;
			} catch (Exception ex) {
				log.error("patientMyInfoSave ERROR: " + ex.getMessage(), ex);
				res.IsSucceed = false; res.Message = "저장 중 오류";
				return res;
			}
		}

		/** 환자 공지사항 — 앱(getNotiList)과 동일 조건(사용중 + 게시기간 내) */
		@RequestMapping(value = "/patient/noticeList.do", method = RequestMethod.POST)
		@ResponseBody
		public ResponseObject patientNoticeList() throws Exception {
			ResponseObject res = new ResponseObject();
			try {
				res.IsSucceed = true;
				res.Data = svc.patientNoticeList();
			} catch (Exception ex) {
				log.error("patientNoticeList ERROR: " + ex.getMessage(), ex);
				res.IsSucceed = false; res.Message = "공지사항 조회 중 오류";
			}
			return res;
		}

		/** 저혈당/고혈당 발생구간(3시간 단위) — 앱 avgBloodlowhight.do 와 동일 데이터, 대상은 세션 본인 */
		@RequestMapping(value = "/patient/timeBand.do", method = RequestMethod.POST)
		@ResponseBody
		public ResponseObject patientTimeBand(@RequestBody Map<String, String> body, HttpServletRequest request) throws Exception {
			ResponseObject res = new ResponseObject();
			try {
				String uuid = (String) request.getSession().getAttribute("userUuid");
				if (uuid == null || uuid.isEmpty()) { res.IsSucceed = false; res.Message = "로그인이 필요합니다."; return res; }
				java.util.Map<String, Object> map = new java.util.HashMap<String, Object>();
				map.put("userId", uuid);
				map.put("start", body != null ? body.get("start") : null);
				map.put("end",   body != null ? body.get("end")   : null);
				res.IsSucceed = true;
				res.Data = svc.avgBloodLowHigh(map);
			} catch (Exception ex) {
				log.error("patientTimeBand ERROR: " + ex.getMessage(), ex);
				res.IsSucceed = false; res.Message = "발생구간 조회 중 오류";
			}
			return res;
		}

		/** 주간 부가 정보 — 앱 AI 종합분석 하단과 동일: 고혈당/저혈당 구간 · 주의할음식 TOP3 · 추천운동 TOP3 (세션 본인) */
		@RequestMapping(value = "/patient/weekInsight.do", method = RequestMethod.POST)
		@ResponseBody
		public ResponseObject patientWeekInsight(@RequestBody Map<String, String> body, HttpServletRequest request) throws Exception {
			ResponseObject res = new ResponseObject();
			try {
				String uuid = (String) request.getSession().getAttribute("userUuid");
				if (uuid == null || uuid.isEmpty()) { res.IsSucceed = false; res.Message = "로그인이 필요합니다."; return res; }
				java.util.Map<String, Object> map = new java.util.HashMap<String, Object>();
				map.put("userId", uuid);
				map.put("start", body != null ? body.get("start") : null);
				map.put("end",   body != null ? body.get("end")   : null);
				java.util.Map<String, Object> out = new java.util.HashMap<String, Object>();
				try { out.put("highLow", svc.showBloodHighLow(map)); } catch (Exception e1) { log.warn("showBloodHighLow: " + e1.getMessage()); }
				try { out.put("food",    svc.foodBlood_max(map));    } catch (Exception e2) { log.warn("foodBlood_max: " + e2.getMessage()); }
				try { out.put("exer",    svc.exerBlood_max(map));    } catch (Exception e3) { log.warn("exerBlood_max: " + e3.getMessage()); }
				res.IsSucceed = true;
				res.Data = out;
			} catch (Exception ex) {
				log.error("patientWeekInsight ERROR: " + ex.getMessage(), ex);
				res.IsSucceed = false; res.Message = "주간 정보 조회 중 오류";
			}
			return res;
		}

		/** 환자 본인 약관 전체 동의 — 세션 userUuid 로 T_PERSIGN_TRAN 에 동의이력 저장
		 *  (앱은 이 테이블에 삭제만 하고 삽입을 하지 않아 이력이 비어 있었다 — 웹에서 동의를 받는다) */
		@RequestMapping(value = "/patient/agreeAll.do", method = RequestMethod.POST)
		@ResponseBody
		public ResponseObject patientAgreeAll(HttpServletRequest request) throws Exception {
			ResponseObject res = new ResponseObject();
			try {
				String uuid = (String) request.getSession().getAttribute("userUuid");
				if (uuid == null || uuid.isEmpty()) { res.IsSucceed = false; res.Message = "로그인이 필요합니다."; return res; }
				int n = svc.saveAllPatientAgreements(uuid, uuid);
				res.IsSucceed = true;
				res.Data = n;
				res.Message = n > 0 ? "동의가 저장되었습니다." : "저장할 약관이 없습니다(약관 마스터 미설정).";
				return res;
			} catch (Exception ex) {
				log.error("patientAgreeAll ERROR: " + ex.getMessage(), ex);
				res.IsSucceed = false; res.Message = "동의 저장 중 오류";
				return res;
			}
		}

		/** 환자 본인 약관 동의 내역 — 세션 userUuid 기준 */
		@RequestMapping(value = "/patient/myAgreeList.do", method = RequestMethod.POST)
		@ResponseBody
		public ResponseObject patientMyAgreeList(HttpServletRequest request) throws Exception {
			ResponseObject res = new ResponseObject();
			try {
				String uuid = (String) request.getSession().getAttribute("userUuid");
				if (uuid == null || uuid.isEmpty()) { res.IsSucceed = false; res.Message = "로그인이 필요합니다."; return res; }
				res.IsSucceed = true;
				res.Data = svc.myAgreeList(uuid);
			} catch (Exception ex) {
				log.error("patientMyAgreeList ERROR: " + ex.getMessage(), ex);
				res.IsSucceed = false; res.Message = "동의 내역 조회 중 오류";
			}
			return res;
		}

		/** 환자 전화번호 중복 체크 */
		@RequestMapping(value = "/patient/checkPhone.do", method = RequestMethod.POST)
		@ResponseBody
		public ResponseObject checkPhone(@RequestBody PatientDTO dto) throws Exception {
			ResponseObject res = new ResponseObject();
			int n = adminSvc.patientExistsByPhone(dto);
			res.IsSucceed = (n == 0);
			res.Data = n;
			return res;
		}

		/**
		 * 약관(개인정보동의/이용약관/고유식별정보) 본문 조회 — T_SIGN_MST
		 *
		 * SEJONG_APP 의 /getSignList.do 와 동일한 시그니처/응답 구조.
		 * 환자 회원가입 페이지(patient_register.jsp) 의 "약관 보기" 에서 호출.
		 *
		 * 요청  : { termsGb: 1|2|3 }
		 *   - 1 = 개인정보 수집·이용동의
		 *   - 2 = 고유식별정보 처리동의
		 *   - 3 = 서비스 이용약관
		 * 응답  : { IsSucceed: true, Data: List<SjgnDTO> }
		 */
		@RequestMapping(value = "/getSignList.do", method = RequestMethod.POST)
		@ResponseBody
		public ResponseObject getSignList(@RequestBody Map<String, Object> map) throws Exception {
			ResponseObject res = new ResponseObject();
			try {
				List<SjgnDTO> list = svc.getSignList(map);
				res.IsSucceed = true;
				res.Data = list;
			} catch (Exception ex) {
				// T_SIGN_MST 가 아직 없거나 SQL 오류 시에도 폼을 막지 않도록 빈 목록으로 정상 응답.
				// 클라이언트는 "약관이 준비 중입니다." 안내만 표시.
				log.warn("getSignList — 약관 마스터 조회 실패 (테이블 미설정 가능): " + ex.getMessage());
				res.IsSucceed = true;
				res.Data = new java.util.ArrayList<SjgnDTO>();
			}
			return res;
		}

		/**
		 * 통합 로그인 — 단일 폼에서 의료진(T_ADMIN_MST) + 환자(T_USER_TRAN) 자동 구분
		 *
		 * 입력: { idOrPhone: "kim123 또는 01012345678", password: "1234" }
		 *
		 * 알고리즘
		 *   1) T_ADMIN_MST 시도: USER_ID = SHA256(idOrPhone || idOrPhone) Base64 매칭
		 *      → 매칭되면 USER_PW = SHA256("1234" || password) 비교 → 성공 시 의사/관리자 세션
		 *   2) 1)이 실패하면 T_USER_TRAN(USER_GB='P') 시도: PHONE = idOrPhone
		 *      → 매칭되면 USER_PW = SHA256(phone || password) 비교 → 성공 시 환자 세션
		 *   3) 둘 다 실패하면 거부
		 *
		 * 세션 q_admin_yn = 'A'/'D' (의료진) 또는 'P' (환자)
		 */
		@RequestMapping(value = "/user/unifiedLoginAct.do", method = RequestMethod.POST)
		@ResponseBody
		public ResponseObject unifiedLogin(@RequestBody Map<String,String> map, HttpServletRequest request) throws Exception {
			ResponseObject res = new ResponseObject();
			String idOrPhone = map != null ? map.get("idOrPhone") : null;
			String password  = map != null ? map.get("password")  : null;
			if (idOrPhone == null || idOrPhone.trim().isEmpty()) {
				res.IsSucceed = false; res.Message = "아이디(전화번호)와 비밀번호를 입력하세요.";
				return res;
			}
			idOrPhone = idOrPhone.trim();
			HttpSession session = request.getSession();

			/* [2026-10-21] 테스트 단축 로그인 — sejong_app 의 testUser2.do 와 같은 개념.
			   아이디에 '3399GO'(대소문자 무관) 를 입력하면 테스트 환자(01098333399)로 비밀번호 검증 없이 접속(시연용).
			   ('3399' 단독은 전화번호 뒷자리와 겹쳐 오입력 위험이 있어 GO 를 붙였다) */
			if ("3399GO".equalsIgnoreCase(idOrPhone)) {
				try {
					PatientDTO tDto = new PatientDTO();
					tDto.setPhone("01098333399");
					PatientDTO t = adminSvc.patientLoginCheck(tDto);
					if (t != null && t.getUserUuid() != null) {
						session.setAttribute("user", t);
						session.setAttribute("userNm", t.getUserNm());
						session.setAttribute("userUuid", t.getUserUuid());
						session.setAttribute("q_user_id", t.getUserUuid());
						session.setAttribute("q_user_nm", t.getUserNm());
						session.setAttribute("q_admin_yn", "P");
						session.setAttribute("q_user_ip", request.getRemoteAddr());
						session.setAttribute("q_screen_id", "patient");
						res.IsSucceed = true;
						res.Data = "PATIENT";
						res.Message = "테스트 로그인";
						return res;
					}
				} catch (Exception te) {
					log.warn("테스트 단축 로그인(3399) 실패: " + te.getMessage());
				}
			}
			if (password == null || password.isEmpty()) {
				res.IsSucceed = false; res.Message = "아이디(전화번호)와 비밀번호를 입력하세요.";
				return res;
			}

			try {
				// ─── 1) 의료진(T_ADMIN_MST) 시도 ─────────────────────────
				UserDTO adminDto = new UserDTO();
				adminDto.setUserId(EgovFileScrty.encryptPassword(idOrPhone, idOrPhone));
				UserDTO admin = svc.userLoginCheck(adminDto);
				if (admin != null && admin.getUserId() != null && !admin.getUserId().isEmpty()) {
					String chkAdmin = EgovFileScrty.encryptPassword(password, "1234");
					if (admin.getUserPw() != null && admin.getUserPw().equals(chkAdmin)) {
						session.setAttribute("q_user_id", admin.getUserId());
						session.setAttribute("q_user_nm", admin.getUserNm());
						session.setAttribute("q_admin_yn", admin.getUserGb());   // A or D
						session.setAttribute("q_dept_nm", admin.getDeptNm());
						session.setAttribute("q_user_ip", request.getRemoteAddr());
						session.setAttribute("q_screen_id", "login");
						session.setAttribute("admingu", admin.getUserGb());
						res.IsSucceed = true;
						res.Data = "ADMIN";
						res.Message = "의료진 로그인 성공";
						return res;
					}
					// 의사 매칭이지만 비번 불일치 → 환자로는 시도하지 않고 즉시 거부 (보안 향상)
					res.IsSucceed = false; res.Message = "비밀번호를 확인하세요.";
					return res;
				}

				// ─── 2) 환자(T_USER_TRAN) 시도 — 전화번호 입력으로 T_USER_TRAN 인식 ───
				PatientDTO pDto = new PatientDTO();
				pDto.setPhone(idOrPhone);
				PatientDTO patient = adminSvc.patientLoginCheck(pDto);
				if (patient != null && patient.getUserUuid() != null) {
					/* [2026-10-21] 관리자 환자등록(insertPatient)은 USER_PW 를 넣지 않아 NULL —
					   그 환자도 전화번호로 개별 접속할 수 있도록, 비밀번호 미설정 계정은
					   생년월일 8자리(BIRTH, YYYYMMDD)를 최초 비밀번호로 받고 그 자리에서
					   해시(salt=전화번호)로 저장한다. 이후 로그인은 일반 검증과 동일. */
					boolean pwOk;
					if (patient.getUserPw() == null || patient.getUserPw().isEmpty()) {
						String birth = patient.getBirth() == null ? "" : patient.getBirth().replaceAll("[^0-9]", "");
						pwOk = !birth.isEmpty() && birth.equals(password.replaceAll("[^0-9]", ""));
						if (!pwOk) {
							res.IsSucceed = false;
							res.Message = "비밀번호가 설정되지 않은 계정입니다. 최초 로그인은 생년월일 8자리(YYYYMMDD)를 비밀번호로 입력하세요.";
							return res;
						}
						try {
							PatientDTO pwDto = new PatientDTO();
							pwDto.setUserUuid(patient.getUserUuid());
							pwDto.setUserPw(EgovFileScrty.encryptPassword(password, patient.getPhone()));
							adminSvc.updatePatientPw(pwDto);
						} catch (Exception pe) {
							// 저장 실패해도 이번 로그인은 진행 — 다음 로그인 때 다시 최초 절차를 탄다
							log.warn("최초 비밀번호 저장 실패(userUuid=" + patient.getUserUuid() + "): " + pe.getMessage());
						}
					} else {
						String chkPatient = EgovFileScrty.encryptPassword(password, patient.getPhone());
						pwOk = patient.getUserPw().equals(chkPatient);
					}
					if (pwOk) {
						session.setAttribute("user", patient);
						session.setAttribute("userNm", patient.getUserNm());
						session.setAttribute("userUuid", patient.getUserUuid());
						session.setAttribute("q_user_id", patient.getUserUuid());
						session.setAttribute("q_user_nm", patient.getUserNm());
						session.setAttribute("q_admin_yn", "P");
						session.setAttribute("q_user_ip", request.getRemoteAddr());
						session.setAttribute("q_screen_id", "patient");
						res.IsSucceed = true;
						res.Data = "PATIENT";
						res.Message = "환자 로그인 성공";
						return res;
					}
					res.IsSucceed = false; res.Message = "비밀번호를 확인하세요.";
					return res;
				}

				// 둘 다 매칭 없음
				res.IsSucceed = false;
				res.Message = "등록된 사용자 정보가 없습니다.";
				return res;

			} catch (Exception ex) {
				log.error("unifiedLogin ERROR: " + ex.getMessage(), ex);
				res.IsSucceed = false;
				res.Message = "로그인 처리 중 오류";
				return res;
			}
		}

		/** 환자 식사 기록 화면 — raw 단독 JSP */
		@RequestMapping(value = "/patient/food.do")
		public String patientFoodPage(HttpSession session) {
			if (session.getAttribute("userUuid") == null) return "redirect:/login.do";
			return ".raw/main/patient/patient_food";
		}

		/** 환자 운동 기록 화면 — raw 단독 JSP */
		@RequestMapping(value = "/patient/exer.do")
		public String patientExerPage(HttpSession session) {
			if (session.getAttribute("userUuid") == null) return "redirect:/login.do";
			return ".raw/main/patient/patient_exer";
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
				
				dto.setUserId(EgovFileScrty.encryptPassword(dto.getUserId(), dto.getUserId()));
				
				UserDTO result = svc.userInfo(dto);
				
				if(result == null || ("".equals(result.getUserId()) && result.getUserId() == null )) {
					model.addAttribute("error_code", "30000");
					model.addAttribute("error_msg" , "사용자 정보가 존재하지 않습니다.");
					return "jsonView";
				}
				dto.setEncUserPwd(EgovFileScrty.encryptPassword("1234", "1234"));
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
				System.out.println("기존 비밀번호 : "+ dto.getUserPw() + "     변경 비밀번호 :  "+ dto.getBfUserPwd());
				
				dto.setUserId(EgovFileScrty.encryptPassword(dto.getUserId(), dto.getUserId()));
				
				UserDTO result = svc.userInfo(dto);

				if("".equals(result.getUserId()) || result.getUserId().toString() == null ){ 
					model.addAttribute("error_code", "20000");
					model.addAttribute("error_msg" , "비밀번호 변경할 사용자 정보가 존재하지 않습니다.");
					return "jsonView";
				}
				String chkpwd = EgovFileScrty.encryptPassword(dto.getUserPw(), "1234");
				
				if(!result.getUserPw().equals(chkpwd)) {
					model.addAttribute("error_code", "30000");
					model.addAttribute("error_msg" , "현재 비밀번호를 확인하세요.!");
					return "jsonView";
				}

				if(dto.getBfUserPwd() == "") {
					model.addAttribute("error_code", "30000");
					model.addAttribute("error_msg" , "비밀번호 변경할 사용자 정보가 존재하지 않습니다.");
					return "jsonView";
				}
				dto.setEncUserPwd(EgovFileScrty.encryptPassword(dto.getBfUserPwd(), "1234"));
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
