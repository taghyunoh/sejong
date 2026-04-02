package egovframework.sejong.doctor.web;

import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.simple.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.sejong.blood.model.BloodDTO;
import egovframework.sejong.doctor.model.DoctorDTO;
import egovframework.sejong.doctor.model.NoticeDTO;
import egovframework.sejong.doctor.service.DoctorService;
import egovframework.sejong.user.model.UserDTO;


@Controller
public class DoctorController {

	private static final Logger log = LoggerFactory.getLogger(DoctorController.class);
		
	@Resource(name = "DoctorService") // 서비스 선언
	private DoctorService svc;
	
		// 환자정보조회 화면
		@RequestMapping(value = "/doctor/ptList.do")
		public String ptList(@ModelAttribute("DTO") DoctorDTO dto, HttpServletRequest request, Model model) throws Exception {

			try { 
				HttpSession session = request.getSession();
				session.removeAttribute("admingu");	
			}catch(Exception ex) {
				model.addAttribute("error_code", "10000"); 
			}
			return ".main/doctor/APME_01A_1";
		}  
		// 환자정보조회 탭
		@RequestMapping(value = "/tab/tabInfo.do", method = RequestMethod.POST)
		public String tabInfo(@ModelAttribute("DTO") DoctorDTO dto, HttpServletRequest request, Model model) throws Exception {
			try { 
				DoctorDTO doctor = svc.patientInfo(dto);
				DoctorDTO blood  = svc.getMostRecentDate(dto);
				
				String heightStr  = doctor.getHeight();
				String weightStr = doctor.getWeight();
				float height = Float.parseFloat(heightStr)/100;
			    float weight = Float.parseFloat(weightStr);
			    float bmi = Math.round((weight / (height * height)*100)/100.0);
				
				HttpSession session = request.getSession(); 
				session.setAttribute("t_user_uuid"   , doctor.getUser_uuid());   //사용자 UUID
				session.setAttribute("t_user_nm"   , doctor.getUser_nm());   //사용자 이름
				session.setAttribute("t_gender"   , doctor.getGender());   //사용자 성별
		        session.setAttribute("t_birth", doctor.getBirth());           // 사용자 생년월일
		        session.setAttribute("t_bmi", bmi);
		        session.setAttribute("t_end_date", blood.getCgm_dtm());
		        session.setAttribute("t_bld_val", blood.getUpt_value());
		        session.setAttribute("t_gap_val", blood.getGap_value());
	        
			}catch(Exception ex) {
				model.addAttribute("error_code", "10000"); 
			}

		//	return ".main/doctor/APME_01A_2";
			return "jsonView";

		} 
		@RequestMapping(value = "/tab/tab.do")
		public String tab(HttpServletRequest request, Model model) throws Exception {
			return ".main/doctor/APME_01A_2";
		} 
		@RequestMapping(value = "/tab/tab1.do")
		public String tab11(Model model) throws Exception {

			return ".main/doctor/tab1";

		} 
		@RequestMapping(value = "/tab/tab2.do")
		public String tab2(Model model) throws Exception {

			return ".main/doctor/tab2";

		} 
		@RequestMapping(value = "/tab/tab3.do")
		public String tab3(Model model) throws Exception {
			
			return ".main/doctor/tab3";

		} 
		@RequestMapping(value = "/tab/tab4.do")
		public String tab4(Model model) throws Exception {
			
			return ".main/doctor/tab4";

		} 

		/*
		 * 의사 정보 조회
		 */
		@RequestMapping(value="/doctor/selectPatientList.do", method = RequestMethod.POST)
		public String selectPatientList(@ModelAttribute("DTO") DoctorDTO dto, HttpServletRequest request, Model model) throws Exception {
		try {
			HttpSession session = request.getSession();
			session.removeAttribute("admingu");
			
			List<?> result = svc.selectPatientList(dto);
			model.addAttribute("resultLst", result); 
			model.addAttribute("resultCnt", result.size());  
			model.addAttribute("error_code", "0"); 
	
		}catch(Exception ex) {
			log.error(" DoctListAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
			}
			return "jsonView";
		}
	
		@RequestMapping(value = "/doctor/PatientInfo.do", method = RequestMethod.POST)
		public String PatientInfo(@ModelAttribute("DTO") DoctorDTO dto, HttpServletRequest request, Model model) throws Exception {
			try {
				DoctorDTO result = svc.patientInfo(dto);
		 
				model.addAttribute("result", result); 
				model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" PatientInfo ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
			}
			return "jsonView";
		}  	 	
		/*
		 * 환자 정보 입력
		 */
		@RequestMapping(value = "/doctor/PatientSaveAct.do")
		public String savePatient(@ModelAttribute("DTO") DoctorDTO dto, HttpServletRequest request, Model model) throws Exception {
			
//			if("".equals(dto.getClcost())   || dto.getClcost().isEmpty())   {dto.setClcost(null);}
//			if("".equals(dto.getHpcost())   || dto.getHpcost().isEmpty())	  {dto.setHpcost(null);}
//			if("".equals(dto.getDshpcost()) || dto.getDshpcost().isEmpty()) {dto.setDshpcost(null);}
//			if("".equals(dto.getWhocost())  || dto.getWhocost().isEmpty())  {dto.setWhocost(null);}
//			if("".equals(dto.getRvpt())	   || dto.getRvpt().isEmpty())	  {dto.setRvpt(null);}
//			if("".equals(dto.getMtnucost()) || dto.getMtnucost().isEmpty()) {dto.setMtnucost(null);}
//			if("".equals(dto.getChmdcost()) || dto.getChmdcost().isEmpty()) {dto.setChmdcost(null);}
			
			try {
	 
				String iud = dto.getIud();  //입력,수정, 삭제 구분
				
				String year = dto.getYear();
				String month = dto.getMonth();
				String day = dto.getDay();
				String birth = year + month + day;
				dto.setBirth(birth);
				
				if("I".equals(iud)) {
					svc.insertPatient(dto);
				}else if("U".equals(iud)) {
					svc.updatePatient(dto);
				}else if("D".equals(iud)) {
					svc.deletePatient(dto); 
				}
				model.addAttribute("error_code", "0"); 
			}catch(Exception ex) {
				log.error(" PatientSaveAct ERROR ! : "+ ex.getMessage());
				model.addAttribute("error_code", "10000"); 
				
			}
			return "jsonView";

		}
		
		
//		공지사항
//     공지사항화면
		@RequestMapping(value = "/doctor/noticeList.do")
		public String noticeList(Model model) throws Exception {
			try { 
			}catch(Exception ex) {
				model.addAttribute("error_code", "10000"); 
			}
			return ".main/doctor/APNO_01A_1";

		}  
		

		/*
		 * 공지 조회
		 */
		@RequestMapping(value="/doctor/noticeList.do", method = RequestMethod.POST)
		public String noticeList(@ModelAttribute("DTO") NoticeDTO dto, HttpServletRequest request, Model model) throws Exception {
		try {
			System.out.println("구분 : " + dto.getSearchGb());
			System.out.println("searchText  :  " + dto.getSearchText());
			List<?> result = svc.noticeList(dto);
			model.addAttribute("resultLst", result); 
			model.addAttribute("resultCnt", result.size());  
			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" NoticeListAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
			}
			return "jsonView";
		}
		@RequestMapping(value = "/doctor/noticeInfo.do", method = RequestMethod.POST)
		public String noticeInfo(@ModelAttribute("DTO") NoticeDTO dto, HttpServletRequest request, Model model) throws Exception {
			try {
				NoticeDTO result = svc.noticeInfo(dto);
		 
				model.addAttribute("result", result); 
				model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" NoticeInfo ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
			}
			return "jsonView";
		}  	 	
		//FAQ
		@RequestMapping(value = "/doctor/faq.do")
		public String faq(HttpServletRequest request, Model model) throws Exception {

			try { 
				
			}catch(Exception ex) {
				model.addAttribute("error_code", "10000"); 
			}

			return ".main/doctor/APNO_01A_3";

		}  
		@RequestMapping(value="/doctor/faqList.do", method = RequestMethod.POST)
		public String faqList(@ModelAttribute("DTO") DoctorDTO dto, HttpServletRequest request, Model model) throws Exception {
		try {

			List<?> result = svc.faqList(dto);
			model.addAttribute("resultLst", result); 
			model.addAttribute("resultCnt", result.size());  
			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" FAQListAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
			}
			return "jsonView";
		}

		@RequestMapping(value = "/doctor/faqInfo.do", method = RequestMethod.POST)
		public String faqInfo(@ModelAttribute("DTO") DoctorDTO dto, HttpServletRequest request, Model model) throws Exception {
			try {
				DoctorDTO result = svc.faqInfo(dto);
		 
				model.addAttribute("result", result); 
				model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" NoticeInfo ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
			}
			return "jsonView";
		}  	 	
		//서비스정보
		@RequestMapping(value = "/doctor/serviceInfo.do")
		public String serviceInfo(HttpServletRequest request, Model model) throws Exception {

			try { 
				
			}catch(Exception ex) {
				model.addAttribute("error_code", "10000"); 
			}

			return ".main/doctor/APNO_01A_4";

		}  
		@RequestMapping(value = "/doctor/FAHR_00.do")
		public String FAHR_00(HttpServletRequest request, Model model) throws Exception {

			return ".main/doctor/FAHR_00";

		}  
		@RequestMapping(value = "/doctor/FAHR_01F_1.do")
		public String FAHR_01F_1(HttpServletRequest request, Model model) throws Exception {

			return ".main/doctor/FAHR_01F_1";
 
		} 
}
