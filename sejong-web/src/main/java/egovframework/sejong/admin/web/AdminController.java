package egovframework.sejong.admin.web;

import java.net.URLEncoder;
import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.util.HSSFColor.HSSFColorPredefined;
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.w3c.dom.ls.LSInput;

import egovframework.sejong.admin.service.AdminService;
import egovframework.sejong.admin.service.CommService;
import egovframework.sejong.admin.model.AsqDTO;
import egovframework.sejong.admin.model.AuserDTO;
import egovframework.sejong.admin.model.PatientDTO;
import egovframework.sejong.admin.model.FaqDTO;
import egovframework.sejong.admin.model.CommDTO;
import egovframework.sejong.doctor.model.NoticeDTO;
import egovframework.util.EgovFileScrty;

@Controller
public class AdminController {
	private static final Logger log = LoggerFactory.getLogger(AdminController.class);
	
	@Resource(name = "AdminService") // 서비스 선언
	private AdminService svc;
	@Resource(name = "CommService") // 서비스 선언
	private CommService codesvc;	
//	공지사항
// 공지사항화면
	@RequestMapping(value = "/admin/admin_noticeList.do")
	public String noticeList(Model model) throws Exception {
		try { 
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return ".main/admin/admin_noticeList";

	}  
	@RequestMapping(value="/admin/noticeList.do", method = RequestMethod.POST)
	public String noticeList(@ModelAttribute("DTO") NoticeDTO dto, HttpServletRequest request, Model model) throws Exception {
	try {
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
	@RequestMapping(value = "/admin/noticeInfo.do", method = RequestMethod.POST)
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
	@RequestMapping(value="/admin/noticeSaveProc.do")
	public String noticeSaveProc(@ModelAttribute("VO") NoticeDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		
		try {
			AuserDTO dvo = new AuserDTO() ;
			String  user = dto.getMod_id();
			dvo.setUser_id(user);
			AuserDTO result  = svc.auserInfo(dvo) ;
			
			if ( result == null || ("".equals(result.getUser_id()) && result.getUser_id() == null)){
				model.addAttribute("error_code", "30000");
	            model.addAttribute("error_msg" , "사용자 정보가 존재하지 않습니다.");
	            return "jsonView";
	         }
	         String chkpwd = EgovFileScrty.encryptPassword(dto.getUser_pw(), "1234"); //dvo.getUser_id()

	         if(!result.getUser_pw().equals(chkpwd)) {
	            model.addAttribute("error_code", "30000");
	            model.addAttribute("error_msg" , "현재 비밀번호를 확인하세요.!");
	            return "jsonView";
	         }
			
		
			String iud = dto.getIud() ; //입력,수정, 삭제 구분
			System.out.println(iud);
			if("I".equals(iud)) {
				dto.setUse_yn("Y");
				svc.insertNotice(dto);
			}else if("U".equals(iud)) { 
				dto.setUse_yn("Y");
				svc.updateNotice(dto);
			}else if("D".equals(iud)) {
				dto.setUse_yn("N");
				svc.deleteNotice(dto); 
		 
			}

			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" NoticeAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		//
		return "jsonView";
	}	
	// 환자정보관리 
    @RequestMapping(value = "/admin/admin_ptList.do")
	public String ptList(Model model) throws Exception {
		try { 
			CommDTO cvo = new CommDTO(); 
			cvo.setCode("CD7");
			cvo.setUse_yn("Y");

			List <?> resultLst = codesvc.selectCommDetailList(cvo);	
			model.addAttribute("cdtpList", resultLst);
			
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return ".main/admin/admin_ptList";

	}  
  
    @RequestMapping(value="/admin/selectPatientList.do", method = RequestMethod.POST)
	public String selectPatientList(@ModelAttribute("DTO") PatientDTO dto, HttpServletRequest request, Model model) throws Exception {
	try {
	
		List<?> result = svc.selectPatientList(dto);
		model.addAttribute("resultLst", result); 
		model.addAttribute("resultCnt", result.size());  
		model.addAttribute("error_code", "0"); 

	}catch(Exception ex) {
		log.error(" selectPatientList ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}
	@RequestMapping(value = "/admin/PatientInfo.do", method = RequestMethod.POST)
	public String PatientInfo(@ModelAttribute("DTO") PatientDTO dto, HttpServletRequest request, Model model) throws Exception {
		try {
			PatientDTO result = svc.patientInfo(dto);
	 
			model.addAttribute("result", result); 
			model.addAttribute("error_code", "0"); 
			
	}catch(Exception ex) {
		log.error(" PatientInfo ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}  	 	

	@RequestMapping(value = "/admin/PatientSaveAct.do")
	public String savePatient(@ModelAttribute("DTO") PatientDTO dto, HttpServletRequest request, Model model) throws Exception {
	
		try {
			String iud = dto.getIud();  //입력,수정, 삭제 구분
			
			String year  = dto.getYear();
			String month = dto.getMonth();
			String day   = dto.getDay();
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
	// 관리자의사 
    @RequestMapping(value = "/admin/admin_auserList.do")
	public String AuserList(Model model) throws Exception {
		try { 
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return ".main/admin/admin_auserList";

	}  	
    @RequestMapping(value="/admin/selectAuserList.do", method = RequestMethod.POST)
	public String selectAuserList(@ModelAttribute("DTO") AuserDTO dto, HttpServletRequest request, Model model) throws Exception {
	try {
		
		List<?> result = svc.selectAuserList(dto);
		model.addAttribute("resultLst", result); 
		model.addAttribute("resultCnt", result.size());  
		model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) {
		log.error(" AuserListAct ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}
	@RequestMapping(value = "/admin/AuserInfo.do", method = RequestMethod.POST)
	public String AuserInfo(@ModelAttribute("DTO") AuserDTO dto, HttpServletRequest request, Model model) throws Exception {
		try {
			AuserDTO result = svc.auserInfo(dto);
	 
			model.addAttribute("result", result); 
			model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) {
		log.error(" AuserInfo ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}  	 	
	/*
	 * 사용자(관리자정보 입력
	 */
	@RequestMapping(value = "/admin/AuserSaveAct.do")
	public String saveAuser(@ModelAttribute("DTO") AuserDTO dto, HttpServletRequest request, Model model) throws Exception {
	
		try {
			String iud = dto.getIud();  //입력,수정, 삭제 구분
			if("I".equals(iud)) {
				dto.setEnc_user_id(EgovFileScrty.encryptPassword(dto.getUser_id_nm(), dto.getUser_id_nm()));
				
				dto.setEnc_auser_pwd(EgovFileScrty.encryptPassword(dto.getUser_pw(), "1234"));
				
				String chkapwd = EgovFileScrty.encryptPassword(dto.getUser_pw(), "1234");
			
			
				if(chkapwd == "") {
					model.addAttribute("error_code", "30000");
					model.addAttribute("error_msg" , "등록할 비밀번호를 입력하세요   .");
					return "jsonView";
				}
				
				String chkbpwd = EgovFileScrty.encryptPassword(dto.getAf_auser_pwd(), dto.getUser_id());
					
				if ((chkbpwd == "") & (chkapwd != chkbpwd)) {
					model.addAttribute("error_code", "30000");
					model.addAttribute("error_msg" , "등록할 비밀번호와 상이합니다    .");
					return "jsonView";
				}

				//비밀번호 변경 처리			
				svc.insertAuser(dto);
			}else if("U".equals(iud)) {
				svc.updateAuser(dto);
			}else if("D".equals(iud)) {
				svc.deleteAuser(dto); 
			}
			model.addAttribute("error_code", "0"); 
		}catch(Exception ex) {
			log.error(" AuserSaveAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
			
		}
		return "jsonView";

	}
	@RequestMapping(value = "/admin/admin_faqList.do")
	public String faqList(Model model) throws Exception {
		try { 
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
	    return ".main/admin/admin_faqList";
	}  
	@RequestMapping(value="/admin/faqList.do", method = RequestMethod.POST)
	public String selectfaqList(@ModelAttribute("DTO") FaqDTO dto, HttpServletRequest request, Model model) throws Exception {
	try {
		List<?> result = svc.selectfaqList(dto);
		model.addAttribute("resultLst", result); 
		model.addAttribute("resultCnt", result.size());  
		model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) {
		log.error(" FaqListAct ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}
	@RequestMapping(value = "/admin/faqInfo.do", method = RequestMethod.POST)
	public String faqInfo(@ModelAttribute("DTO") FaqDTO dto, HttpServletRequest request, Model model) throws Exception {
		try {
			FaqDTO result = svc.faqInfo(dto);
	 
			model.addAttribute("result", result); 
			model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) {
		log.error(" FaqInfo ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	} 
	@RequestMapping(value="/admin/faqSaveProc.do")
	public String faqSaveProc(@ModelAttribute("VO") FaqDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		
		try {
			
			String iud = dto.getIud() ; //입력,수정, 삭제 구분
			System.out.println(iud);
			if("I".equals(iud)) {
				dto.setUse_yn("Y");
				svc.insertfaq(dto);
			}else if("U".equals(iud)) { 
				dto.setUse_yn("Y");
				svc.updatefaq(dto);
			}else if("D".equals(iud)) {
				dto.setUse_yn("N");
				svc.deletefaq(dto); 
		 
			}

			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" FaqAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		//
		return "jsonView";
	}	
	@RequestMapping(value="/admin/PrintExcel.do")
	public void workListPrintExcel(@ModelAttribute("DTO") PatientDTO dto, HttpServletRequest request, HttpServletResponse response)
	throws Exception {    
		try {
			
			// Excel Download 시작
			Workbook workbook = new HSSFWorkbook();
			// 테이블 헤더용 스타일
			CellStyle headStyle = workbook.createCellStyle();
			// 가는 경계선
			headStyle.setBorderTop(BorderStyle.THIN);
			headStyle.setBorderBottom(BorderStyle.THIN);
			headStyle.setBorderLeft(BorderStyle.THIN);
			headStyle.setBorderRight(BorderStyle.THIN);
		
			// 회색 배경
			headStyle.setFillForegroundColor(HSSFColorPredefined.GREY_25_PERCENT.getIndex());
			headStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
			// 데이터 가운데 정렬
			headStyle.setAlignment(HorizontalAlignment.CENTER);
			// 데이터용 경계 스타일 - 테두리
			CellStyle bodyStyle = workbook.createCellStyle();
			bodyStyle.setAlignment(HorizontalAlignment.CENTER); // 가운데 정렬
			bodyStyle.setBorderTop(BorderStyle.THIN);
			bodyStyle.setBorderBottom(BorderStyle.THIN);
			bodyStyle.setBorderLeft(BorderStyle.THIN);
			bodyStyle.setBorderRight(BorderStyle.THIN);
		
			// 행, 열, 열번호
			Row row = null;
			org.apache.poi.ss.usermodel.Cell cell = null;
			int rowNo = 0;
			String Locphone = "" ;
			// 시트 생성
			Sheet sheet = workbook.createSheet("혈당실증환자_모니터링");
			// 타이틀(제목) 
			row = sheet.createRow(rowNo++);			
			cell = row.createCell(5);  cell.setCellStyle(bodyStyle) ; cell.setCellValue("혈당실증환자 모니터링 대상자(1일 경과)");
			// 헤더 생성
			row = sheet.createRow(rowNo++);		
			cell = row.createCell(0); cell.setCellStyle(headStyle); cell.setCellValue("번호");
			cell = row.createCell(1); cell.setCellStyle(headStyle); cell.setCellValue("성명");
			cell = row.createCell(2); cell.setCellStyle(headStyle); cell.setCellValue("전화번호");
			cell = row.createCell(3); cell.setCellStyle(headStyle); cell.setCellValue("성별");
			cell = row.createCell(4); cell.setCellStyle(headStyle); cell.setCellValue("생년월일");
			cell = row.createCell(5); cell.setCellStyle(headStyle); cell.setCellValue("가입년월");
			cell = row.createCell(6); cell.setCellStyle(headStyle); cell.setCellValue("이메일");
			cell = row.createCell(7); cell.setCellStyle(headStyle); cell.setCellValue("최종검사");
			cell = row.createCell(8); cell.setCellStyle(headStyle); cell.setCellValue("검사경과일");
			cell = row.createCell(9); cell.setCellStyle(headStyle); cell.setCellValue("최종식사");
			cell = row.createCell(10); cell.setCellStyle(headStyle); cell.setCellValue("식사경과일");
			cell = row.createCell(11); cell.setCellStyle(headStyle); cell.setCellValue("가입접수일자");
			// JSON  파싱 
			// 조회결과 return type을 egovMap 아닌 service에 선언된 VO 기준으로 return 되게 처리해야 됨.
			//조회결과 처리 구분
            dto.setUser_check("Y");
	        List<?> result = svc.selectPatientList(dto); // 결과 타입 수정
	        for (Object item : result) {
	            if (item instanceof PatientDTO) { // assuming the items are of type PatientDTO
		            PatientDTO vo = (PatientDTO) item;	        
					if (vo.getPhone() != null && !vo.getPhone().isEmpty()) {
					    String phone = vo.getPhone();
					    if (phone.length() == 10 || phone.length() == 11) {
					        Locphone = String.format("%s-%s-%s", 
					            phone.substring(0, 3), 
					            phone.substring(3, phone.length() - 4), 
					            phone.substring(phone.length() - 4));
					    } else {
					        // 유효하지 않은 길이 처리
					        Locphone = "";
					    }
					} else {
					    Locphone = ""; // 전화번호가 없는 경우
					}
					if (Locphone == null || Locphone.isEmpty()) {
					    continue;
					}
					if (!"1".equals(vo.getUser_gb())) { // 문자열 비교는 equals() 사용
					    continue;
					}
					
					row = sheet.createRow(rowNo++);
					
					cell = row.createCell(0); cell.setCellStyle(bodyStyle); cell.setCellValue(rowNo - 2);
					cell = row.createCell(1); cell.setCellStyle(bodyStyle); cell.setCellValue(vo.getUser_nm());
					cell = row.createCell(2); cell.setCellStyle(bodyStyle); cell.setCellValue(Locphone);
					cell = row.createCell(3); cell.setCellStyle(bodyStyle); cell.setCellValue(vo.getGender());
					cell = row.createCell(4); cell.setCellStyle(bodyStyle); cell.setCellValue(vo.getBirth());
					cell = row.createCell(5); cell.setCellStyle(bodyStyle); cell.setCellValue(vo.getJoin_ymd());
					cell = row.createCell(6); cell.setCellStyle(bodyStyle); cell.setCellValue(vo.getEmail());
					cell = row.createCell(7); cell.setCellStyle(bodyStyle); cell.setCellValue(vo.getCgm_dtm());
					cell = row.createCell(8); cell.setCellStyle(bodyStyle); cell.setCellValue(vo.getCgm_gap());
					cell = row.createCell(9); cell.setCellStyle(bodyStyle); cell.setCellValue(vo.getEat_dtm());
					cell = row.createCell(10); cell.setCellStyle(bodyStyle); cell.setCellValue(vo.getEat_gap());
					cell = row.createCell(11); cell.setCellStyle(bodyStyle); cell.setCellValue(vo.getReg_dtm());
		         }                                                                                
			}             
	        
			//조회결과 처리 구분 End
			// 컨텐츠 타입과 파일명 지정
			response.setContentType("ms-vnd/excel"); 
			response.setHeader("Content-Disposition", "Attachment;Filename=" + URLEncoder.encode("혈당실증환자_모니터링", "UTF-8") + ".xls");
			// 엑셀 출력
			try {
				workbook.write(response.getOutputStream());
				workbook.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
						
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	@RequestMapping(value = "/admin/admin_asqList.do")
	public String asqList(Model model) throws Exception {
		try { 
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
	    return ".main/admin/admin_asqList";
	}  
	@RequestMapping(value="/admin/asqList.do", method = RequestMethod.POST)
	public String selectasqList(@ModelAttribute("DTO") AsqDTO dto, HttpServletRequest request, Model model) throws Exception {
	try {
		List<?> result = svc.selectasqList(dto);
		model.addAttribute("resultLst", result); 
		model.addAttribute("resultCnt", result.size());  
		model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) {
		log.error(" FaqListAct ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}
	@RequestMapping(value = "/admin/asqInfo.do", method = RequestMethod.POST)
	public String asqInfo(@ModelAttribute("DTO") AsqDTO dto, HttpServletRequest request, Model model) throws Exception {
		try {
			AsqDTO result = svc.asqInfo(dto);
	 
			model.addAttribute("result", result); 
			model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) {
		log.error(" asqInfo ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	} 
	@RequestMapping(value="/admin/asqSaveProc.do")
	public String asqSaveProc(@ModelAttribute("VO") AsqDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		
		try {
			
			String iud = dto.getIud() ; //입력,수정, 삭제 구분
			System.out.println(iud);
            if("U".equals(iud)) { 
				dto.setAnsrYn("Y");
				svc.updateasq(dto);
			}

			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" FaqAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		//
		return "jsonView";
	}	
}
