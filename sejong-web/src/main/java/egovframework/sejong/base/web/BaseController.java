package egovframework.sejong.base.web;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.common.net.HostAndPort;

import egovframework.sejong.base.service.BaseService;
import egovframework.util.EgovFileScrty;
import egovframework.sejong.base.model.AsqDTO;
import egovframework.sejong.base.model.CodeMdDTO;
import egovframework.sejong.base.model.CommonDTO;
import egovframework.sejong.base.model.DietDTO;
import egovframework.sejong.base.model.SugaDTO;
import egovframework.sejong.base.model.UrlpathDTO;
import egovframework.sejong.base.model.UsermDTO;
import egovframework.sejong.base.model.HospMdDTO;
import egovframework.sejong.base.model.LicworkDTO;
import egovframework.sejong.base.model.SamverDTO;
import egovframework.sejong.base.model.DiseDTO;
import egovframework.sejong.base.model.HospConDTO;
import egovframework.sejong.base.model.HospEmpDTO;
import egovframework.sejong.base.model.WvalDTO;
import egovframework.sejong.base.model.MberDTO;
import egovframework.sejong.base.model.NotiDTO;
@Controller
public class BaseController {
	private static final Logger log = LoggerFactory.getLogger(BaseController.class);
	
	@Resource(name = "BaseService") // 서비스 선언

	private BaseService svc;
	
	@RequestMapping(value = "/base/base_sugaList.do")
	public String base_sugaList(@ModelAttribute("dto") CodeMdDTO dto, ModelMap model) throws Exception {		
		try {

		}catch(Exception ex) {
			log.error(" UserListAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		return ".main/base/base_sugaList";

	}

	@RequestMapping(value= "/base/ctl_sugaList.do", method = RequestMethod.POST)
	public String ctl_sugaList(@ModelAttribute("DTO") SugaDTO dto, HttpServletRequest request, Model model) throws Exception {
	try {
        if (dto.getPageSize() == 0) dto.setPageSize(13); // 한 페이지에 15개 표시
        if (dto.getPageIndex() == 0) dto.setPageIndex(1); // 페이지 번호 기본값을 1로 설정

        // 페이지 인덱스를 0-based로 변경
        int offset = (dto.getPageIndex() - 1) * dto.getPageSize();
        dto.setPageIndex(offset); // OFFSET을 위해 pageIndex 값 수정		

        int totalCount = svc.getSugaMstCount(dto); // 전체 데이터 개수 가져오기

		List<?> result = svc.SugaMstList(dto) ;
		model.addAttribute("resultLst", result); 
		model.addAttribute("resultCnt", result.size());  
		model.addAttribute("totalCnt", totalCount); 
		model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) {
		log.error(" SugaMstDTO ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}
	@RequestMapping(value = "/base/ctl_sugaInfo.do", method = RequestMethod.POST)
	public String ctl_sugaInfo(@ModelAttribute("DTO") SugaDTO dto, HttpServletRequest request, Model model) throws Exception {
		try {
			SugaDTO result = svc.SugaMstInfo(dto);
	 
			model.addAttribute("result", result); 
			model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) {
		log.error(" SugaMstInfo ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	} 	
	@RequestMapping(value="/base/ctl_SugaSaveAct.do")
	public String sugaSaveProc(@ModelAttribute("DTO") SugaDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		try {
			String iud = dto.getIud() ;
			if("I".equals(iud)) {
				svc.insertSugaMst(dto);
			}else if("U".equals(iud)) { 
				svc.updateSugaMst(dto);
			}else if("D".equals(iud)) {
				svc.updateSugaMst(dto); 
	 
			}
			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" SugaMstDTO ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		//
		return "jsonView";
	}	
	/* 사용자 공통관리 */
	@RequestMapping(value="/base/base_commList.do")
	public String base_CommMgr(@ModelAttribute("DTO") CodeMdDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			dto.setCode_cd("CODE_GB");
			dto.setUse_yn("Y");
			dto.setCode_gb("Z");
			List <?> resultLst = svc.selectCodeDetailList(dto);
		
			model.addAttribute("codegbList", resultLst);			
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return ".main/base/base_commList";
	}		
	@RequestMapping(value="/base/base_CommMstList.do")
	public String base_CommMstList(@ModelAttribute("DTO") CodeMdDTO dto, HttpServletRequest request, ModelMap model) 	
	       throws Exception {
		try {
			//사용자 현황 조회 
			List <?> result = svc.selCommMstList(dto);
 
			model.addAttribute("resultLst", result); 
			model.addAttribute("resultCnt", result.size());  
			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" CommMstAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		//
		return "jsonView";
	}
	@RequestMapping(value="/base/CommSaveProc.do")
	public String base_CommSaveProc(@ModelAttribute("DTO") CodeMdDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		
		try {
			
			String iud = dto.getIud();  //입력,수정, 삭제 구분
			if("MI".equals(iud)) {
				dto.setUse_yn("Y");
				svc.insertCommMst(dto);
			}else if("MU".equals(iud)) { 
				svc.updateCommMst(dto);
			}else if("MD".equals(iud)) {
				dto.setUse_yn("N");
				svc.deleteCommMst(dto); 
				
			}else if("DI".equals(iud)) { 
				dto.setUse_yn("Y");
				svc.insertCommDetail(dto);
			}else if("DU".equals(iud)) {
				svc.updateCommDetail(dto);				
			}else if("DD".equals(iud)) {
				dto.setUse_yn("N");
				svc.deleteCommDetail(dto);
				 
			}
			model.addAttribute("error_code", "0"); 
		}catch(Exception ex) {
			log.error(" CommMstAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
		}
		//
		return "jsonView";
	}
	@RequestMapping(value="/base/CommMstDupChk.do")
	public String base_CommMstDupChk(@ModelAttribute("DTO") CodeMdDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		
		try {
			//사용자 현황 조회 
			String dupchk = svc.selCommMstDupChk(dto);
			System.out.println("dupchk " + dupchk);
			model.addAttribute("dupchk", dupchk);  

			model.addAttribute("error_code", "0"); 
		}catch(Exception ex) {
			log.error(" CommListAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		//
		return "jsonView";
	}	
	@RequestMapping(value="/base/CommDetailDupChk.do")
	public String base_CommDetailDupChk(@ModelAttribute("DTO") CodeMdDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		
		try {
			//사용자 현황 조회 
			String dupchk = svc.selCommDetailDupChk(dto);

			System.out.println("dupchk " + dupchk);
			model.addAttribute("dupchk", dupchk);  
			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" CommListAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		//
		return "jsonView";
	}
	@RequestMapping(value="/base/base_CommDetailList.do")
	public String base_selectCommDetailList(@ModelAttribute("DTO") CodeMdDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		try {
			//사용자 현황 조회 
			List <?> result = svc.selCommDetailList(dto);
 
			model.addAttribute("resultLst", result);  
			model.addAttribute("resultCnt", result.size());  
			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" CommListAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
		}
		//
		return "jsonView";
	}	
	/* 사용자 공통관리 */
	@RequestMapping(value="/base/base_userList.do")
	public String base_User(@ModelAttribute("DTO") UsermDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			CodeMdDTO cto = new CodeMdDTO() ;
			cto.setCode_cd("MAIN_GU");
			cto.setUse_yn("Y");
			cto.setCode_gb("Z");
			List <?> resultLst = svc.selectCodeDetailList(cto);
		
			model.addAttribute("codegbList", resultLst);		
		
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return ".main/base/base_userList";
	}
	@RequestMapping(value= "/base/ctl_userList.do", method = RequestMethod.POST)
	public String ctl_userList(@ModelAttribute("DTO") UsermDTO dto, HttpServletRequest request, Model model) throws Exception {
	try {
		List<?> result = svc.selUserList(dto) ;
		model.addAttribute("resultLst", result); 
		model.addAttribute("resultCnt", result.size());  
		model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) {
		log.error(" UsermDTO ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	
	@RequestMapping(value = "/base/userInfo.do", method = RequestMethod.POST)
	public String ctl_userInfo(@ModelAttribute("DTO") UsermDTO dto, HttpServletRequest request, Model model) throws Exception {
		try {
			UsermDTO result = svc.UserInfo(dto);
	 
			model.addAttribute("result", result); 
			model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) {
		log.error(" UsermDTO ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	} 	
	@RequestMapping(value="/base/UserSaveAct.do")
	public String base_UserSaveAct(@ModelAttribute("DTO") UsermDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		try {
			String iud = dto.getIud();  //입력,수정, 삭제 구분
			if("I".equals(iud)) {
				dto.setPass_wd(EgovFileScrty.encryptPassword(dto.getPass_wd(), dto.getUser_id()));
				
				String chkapwd = EgovFileScrty.encryptPassword(dto.getPass_wd(), dto.getUser_id());
			
			
				if(chkapwd == "") {
					model.addAttribute("error_code", "30000");
					model.addAttribute("error_msg" , "등록할 비밀번호를 입력하세요   .");
					return "jsonView";
				}
				
				String chkbpwd = EgovFileScrty.encryptPassword(dto.getAf_pass_wd(), dto.getUser_id());
					
				if ((chkbpwd == "") & (chkapwd != chkbpwd)) {
					model.addAttribute("error_code", "30000");
					model.addAttribute("error_msg" , "등록할 비밀번호와 상이합니다    .");
					return "jsonView";
				}

				//비밀번호 변경 처리			
				svc.insertUser(dto);
			}else if("U".equals(iud)) { 
				svc.updateUser(dto);
			}else if("D".equals(iud)) {
				svc.deleteUser(dto); 
			}
		
			model.addAttribute("error_code", "0"); 
		
		}catch(Exception ex) {
			log.error(" UsermDTO ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
		}
	//
		return "jsonView";
	}	
	@RequestMapping(value = "/base/getUserInfo.do", method = RequestMethod.POST)
	public String ctl_getUserInfo(@ModelAttribute("DTO") UsermDTO dto, HttpServletRequest request, Model model) throws Exception {
		try {
			String dupchk = svc.getUserInfo(dto);
			System.out.println("dupchk " + dupchk);
			model.addAttribute("dupchk", dupchk);  	 
			model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) {
		log.error(" UsermDTO ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	} 	
	//병원병상벙보 
	@RequestMapping(value = "/base/base_hospList.do")
	public String base_hospList(@ModelAttribute("dto") HospMdDTO dto, ModelMap model) throws Exception {		
		try {

		}catch(Exception ex) {
			log.error(" UserListAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		return ".main/base/base_hospList";

	}	
	@RequestMapping(value= "/base/ctl_hospList.do", method = RequestMethod.POST)
	public String ctl_hospList(@ModelAttribute("DTO") HospMdDTO dto, HttpServletRequest request, Model model) throws Exception {
	try {
		List<?> result = svc.selHospList(dto) ;
		model.addAttribute("resultLst", result); 
		model.addAttribute("resultCnt", result.size());  
		model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) {
		log.error(" HospMdDTO ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	
	@RequestMapping(value= "/base/ctl_hospsumList.do", method = RequestMethod.POST)
	public String ctl_ctl_hospsumList(@ModelAttribute("DTO") HospMdDTO dto, HttpServletRequest request, Model model) throws Exception {
	try {
		List<?> result = svc.selHospsumList(dto) ;
		model.addAttribute("resultLst", result); 
		model.addAttribute("resultCnt", result.size());  
		model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) {
		log.error(" HospMdDTO ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}		
	@RequestMapping(value = "/base/hospInfo.do", method = RequestMethod.POST)
	public String hospInfo(@ModelAttribute("DTO") HospMdDTO dto, HttpServletRequest request, Model model) throws Exception {
		try {
			HospMdDTO result = svc.HospInfo(dto);
	 
			model.addAttribute("result", result); 
			model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) {
		log.error(" HospInfo ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	} 	
	@RequestMapping(value="/base/HospSaveAct.do")
	public String hospSaveProc(@ModelAttribute("DTO") HospMdDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		try {
			String iud = dto.getIud() ;
			UUID uuid = UUID.randomUUID();
			if("MI".equals(iud)) {
				dto.setHosp_uuid(uuid.toString());
				svc.insertHosp(dto) ;
			}else if("MU".equals(iud)) { 
				if (dto.getHosp_uuid() == null || dto.getHosp_uuid().isEmpty())
				{
					log.error(" HospMdDTO ERROR ! " + dto.getHosp_uuid() );
					
  			    	dto.setHosp_uuid(uuid.toString());	
				}
				svc.updateHosp(dto);
			}else if("MD".equals(iud)) {
				svc.updateHosp(dto); 
			}
			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" HospDTO ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		//
		return "jsonView";
	}	
	
	@RequestMapping(value="/base/HospdtlSaveAct.do")
	public String HospdtlSaveAct(@ModelAttribute("DTO") HospMdDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		try {
			String iud2 = dto.getIud2();  //입력,수정, 삭제 구분			
			String year = dto.getYear();
			String month = dto.getMonth();
			String start_ym = year + month;
			dto.setStart_ym(start_ym);
			if("DI".equals(iud2)) {
				svc.insertHospDtl(dto) ;
			}else if("DU".equals(iud2)) { 
				svc.updateHospDtl(dto);
			}else if("DD".equals(iud2)) {
				svc.updateHospDtl(dto); 
			}			
			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" HospMdDTO ERROR ! : "+ ex.getMessage() + "-->" + dto.getStart_ym() );
			model.addAttribute("error_code", "10000"); 
						
		}
		//
		return "jsonView";
	}		
	
	@RequestMapping(value= "/base/ctl_hospDtlList.do", method = RequestMethod.POST)
	public String ctl_hospDtlList(@ModelAttribute("DTO") HospMdDTO dto, HttpServletRequest request, Model model) throws Exception {
	try {
		List<?> result = svc.selHospDtlList(dto) ;
		model.addAttribute("resultLst", result); 
		model.addAttribute("resultCnt", result.size());  
		model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) {
		log.error(" HospDtlDTO ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	
	@RequestMapping(value = "/base/ctl_hospChk.do" , method = RequestMethod.POST)
	public String ctl_hospChk(@ModelAttribute("DTO") HospMdDTO dto, HttpServletRequest request, Model model) 
		throws Exception {
		try {
				String dupchk = svc.HospChk(dto);
				
				model.addAttribute("dupchk", dupchk);  
				model.addAttribute("error_code", "0"); 
			}catch(Exception ex) {
				log.error(" HospMdDTO ERROR ! : "+ ex.getMessage());
				model.addAttribute("error_code", "10000"); 
							
			}
			return "jsonView";

		}  
	@RequestMapping(value= "/base/ctl_hospDtlInfo.do", method = RequestMethod.POST)
	public String ctl_hospDtlInfo(@ModelAttribute("VO") HospMdDTO dto, HttpServletRequest request, Model model) throws Exception {
	try {
		HospMdDTO result = svc.HospDtlInfo(dto) ;
		model.addAttribute("result", result); 
		model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) { 
		log.error(" HospDtlDTO ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	
	@RequestMapping(value = "/base/insertHospDtlMonList.do")
	public String insertHospMonthlyList(@ModelAttribute("DTO") HospMdDTO dto ,HttpServletRequest request, ModelMap model) throws Exception {

		try { 
			for(int i=1; i<13; i++) {
				String month = "";
				if(i<10) {
					month = "0"+i+"";
				}else {
					month = i+"";
				}
				SimpleDateFormat format = new SimpleDateFormat("yyyy");
				Date now = new Date();
				String year = format.format(now);
				String start_ym = year + month;
				dto.setStart_ym(start_ym) ;
			
			boolean chk = svc.insertHospDtlMonlyList(dto);
			if(chk)
				model.addAttribute("error_code", "0");
			else
				model.addAttribute("error_code", "10000");
			
			}
			
		}catch(Exception ex) {
			log.error("Exception error " + ex.getMessage());
			model.addAttribute("error_code", "10000");
		}
		return "jsonView";
	} 	
	@RequestMapping(value = "/base/base_diseList.do")
	public String base_diseList(@ModelAttribute("dto") HospMdDTO dto, ModelMap model) throws Exception {		
		try {

		}catch(Exception ex) {
			log.error(" UserListAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		return ".main/base/base_diseList";

	}
	@RequestMapping(value= "/base/ctl_diseList.do", method = RequestMethod.POST)
	public String ctl_diseList(@ModelAttribute("DTO") DiseDTO dto, HttpServletRequest request, Model model) throws Exception {
	try {
        if (dto.getPageSize() == 0) dto.setPageSize(13); // 한 페이지에 15개 표시
        if (dto.getPageIndex() == 0) dto.setPageIndex(1); // 페이지 번호 기본값을 1로 설정

        // 페이지 인덱스를 0-based로 변경
        int offset = (dto.getPageIndex() - 1) * dto.getPageSize();
        dto.setPageIndex(offset); // OFFSET을 위해 pageIndex 값 수정		

        int totalCount = svc.getDiseCount(dto); // 전체 데이터 개수 가져오기

		List<?> result = svc.selDiseList(dto) ;
		model.addAttribute("resultLst", result); 
		model.addAttribute("resultCnt", result.size());  
		model.addAttribute("totalCnt", totalCount); 
		model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) {
		log.error(" DiseDTO ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	
	@RequestMapping(value = "/base/ctl_DiseInfo.do", method = RequestMethod.POST)
	public String ctl_DiseInfo(@ModelAttribute("DTO") DiseDTO dto, HttpServletRequest request, Model model) throws Exception {
		try {
			DiseDTO result = svc.DiseInfo(dto);
	 
			model.addAttribute("result", result); 
			model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) {
		log.error(" SugaMstInfo ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	} 	
	@RequestMapping(value="/base/ctl_DiseSaveAct.do")
	public String hospSaveProc(@ModelAttribute("DTO") DiseDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		try {
			String iud = dto.getIud() ;
			if("I".equals(iud)) {
				svc.insertDise(dto) ;
			}else if("U".equals(iud)) { 
				svc.updateDise(dto);
			}else if("D".equals(iud)) {
				svc.updateDise(dto); 
			}
			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" DiseDTO ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		//
		return "jsonView";
	}		
	@RequestMapping(value = "/base/base_samverList.do")
	public String base_samverList(@ModelAttribute("dto") CodeMdDTO dto, ModelMap model) throws Exception {		
		try {
            dto.setCode_cd("SAMVER");
            dto.setUse_yn("Y");
			dto.setCode_gb("Z");
			List<?> resultLst = svc.selectCodeDetailList(dto);
			model.addAttribute("verList", resultLst);

			dto.setCode_cd("TBLINFO");
			dto.setCode_gb("Z");
			dto.setUse_yn("Y");
			resultLst = svc.selectCodeDetailList(dto);
		
			model.addAttribute("tblinfoList", resultLst);
			model.addAttribute("error_code", "0");
			
		}catch(Exception ex) {
			log.error(" UserListAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		return ".main/base/base_samverList";

	}	
	@RequestMapping(value= "/base/selectCodeDetailList.do")
	public String base_selCodeDetailList(@ModelAttribute("VO") CodeMdDTO VO, HttpServletRequest request, ModelMap model)
			throws Exception {  
		try {
			//사용자 현황 조회 
			List <?> result = svc.selectCodeDetailList(VO);
 
			model.addAttribute("resultLst", result);  
			model.addAttribute("resultCnt", result.size());  
			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" CodeMdDTO ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		//
		return "jsonView";
	}	
	@RequestMapping(value = "/base/selectSamVerList.do")
	public String selectSamVerList(@ModelAttribute("VO") SamverDTO VO ,HttpServletRequest request, ModelMap model) throws Exception {
		try {
			
			List<?> resultLst = svc.selectSamVerList(VO);
			model.addAttribute("resultLst", resultLst);
			model.addAttribute("resultCnt", resultLst.size());
			model.addAttribute("error_code", "0");
		}catch(Exception ex) {
			log.error("Exception error " + ex.getMessage());
			model.addAttribute("error_code", "10000");
		}
		return "jsonView";
		
	}	
	@RequestMapping(value="/base/CodeDetailDupChk.do")
	public String base_CodeDetailDupChk(@ModelAttribute("VO") CodeMdDTO VO, HttpServletRequest request, ModelMap model)
			throws Exception {  
		
		try {
			//사용자 현황 조회 
			String dupchk = svc.selectCodeDetailDupChk(VO);

			System.out.println("dupchk " + dupchk);
			model.addAttribute("dupchk", dupchk);  
			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" UserListAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		//
		return "jsonView";
	}
	@RequestMapping(value="/base/CodeSaveProc.do")
	public String CodeSaveProc(@ModelAttribute("VO") CodeMdDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		
		try {
			
			String iud = dto.getIud();  //입력,수정, 삭제 구분
			
			if("DI".equals(iud)) { 
				dto.setUse_yn("Y");
				svc.insertCommDetail(dto);
			}else if("DU".equals(iud)) {
				dto.setUse_yn("Y");
				svc.updateCommDetail(dto);				
			}else if("DD".equals(iud)) {
				dto.setUse_yn("Y");
				svc.deleteCommDetail(dto);		
			}
		
			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" UserListAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		//
		return "jsonView";
	}	
	@RequestMapping(value = "/base/selectSamVerDupchk.do")
	public String selectSamVerDupchk(@ModelAttribute("VO")SamverDTO VO ,HttpServletRequest request, ModelMap model) throws Exception {
		try { 
			String dupchk = svc.selectSamVerDupchk(VO);
			 
			model.addAttribute("dupchk", dupchk);
			model.addAttribute("error_code", "0");
			 
		}catch(Exception ex) {
			log.error("Exception error " + ex.getMessage());
			model.addAttribute("error_code", "10000");
		}
		return "jsonView";
		
	}	
	@RequestMapping(value = "/base/selectSamVerMgtView.do")
	public String selectSamVerMgtView(@ModelAttribute("VO")SamverDTO VO ,HttpServletRequest request, ModelMap model) throws Exception {
		try { 
			SamverDTO result = svc.selectSamVerMgtView(VO);
			 
			model.addAttribute("result", result);
			model.addAttribute("error_code", "0");
			 
		}catch(Exception ex) {
			log.error("Exception error " + ex.getMessage());
			model.addAttribute("error_code", "10000");
		}
		return "jsonView";
		
	}	
	@RequestMapping(value = "/base/SamVerSaveProc.do")
	public String SamVerSaveProc(@ModelAttribute("DTO")SamverDTO dto ,HttpServletRequest request, ModelMap model) throws Exception {
		try { 
			
			if("I".equals(dto.getIud() )){
				String  seq   = svc.selectSamVerMaxSeq(dto);
				String  dupchk= svc.selectSamVerDupchk(dto);
				
				if("Y".equals(dupchk)){
					model.addAttribute("error_code", "20000");
					model.addAttribute("error_msg", "해당 청구 SAM 정보는 이미 등록된 정보입니다.");
					return "jsonView";
				}
				dto.setSeq(seq);				

				boolean chk = svc.insertSamVerMgtInfo(dto);
				if(!chk) {
					model.addAttribute("error_code", "10000");
					model.addAttribute("error_msg" , "저장시 처리 실패하였습니다."); 
				}else {
					model.addAttribute("error_code", "0"); 
				}
			}else if("U".equals(dto.getIud() )){
				boolean chk = svc.updateSamVerMgtInfo(dto);
				if(!chk) {
					model.addAttribute("error_code", "10000");
					model.addAttribute("error_msg" , "저장시 처리 실패하였습니다."); 
				}else {
					model.addAttribute("error_code", "0"); 
				}
			}
			
			model.addAttribute("error_code", "0");
			 
		}catch(Exception ex) {
			log.error("Exception error " + ex.getMessage());
			model.addAttribute("error_code", "10000");
			model.addAttribute("error_msg", "저장시 처리 실패하였습니다.");
		}
		return "jsonView";
		
	}
	//가중치관리  
	@RequestMapping(value="/base/base_wvalList.do")
	public String base_wvalList(@ModelAttribute("DTO") CodeMdDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			dto.setCode_cd("WVALUE");
			dto.setUse_yn("Y");
			dto.setCode_gb("Z");
			List <?> resultLst = svc.selectCodeDetailList(dto);

			model.addAttribute("verList", resultLst);
	
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return ".main/base/base_wvalList";
	}	
	@RequestMapping(value="/base/ctl_wvalList.do")
	public String base_ctl_wvalList(@ModelAttribute("DTO") WvalDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			List <?> resultLst = svc.selectWvalueList(dto);

			model.addAttribute("resultLst", resultLst);
			model.addAttribute("resultCnt", resultLst.size());
			model.addAttribute("error_code", "0");
	
		}catch(Exception ex) {
			log.error("Exception error " + ex.getMessage());
			model.addAttribute("error_code", "10000");
			model.addAttribute("error_msg", "저장시 처리 실패하였습니다.");
		}
		return "jsonView";

	}		
	@RequestMapping(value="/base/wvalInfo.do")
	public String base_ctl_wvalInfo(@ModelAttribute("DTO") WvalDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			WvalDTO result = svc.selectWvalueInfo(dto);
			model.addAttribute("result", result);
			model.addAttribute("error_code", "0");
	
		}catch(Exception ex) {
			log.error("Exception error " + ex.getMessage());
			model.addAttribute("error_code", "10000");
			model.addAttribute("error_msg", "저장시 처리 실패하였습니다.");
		}
		
		return "jsonView";
		
	}	
	@RequestMapping(value="/base/WvalSaveAct.do")
	public String WvalSaveAct(@ModelAttribute("DTO") WvalDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		
		try {
			String iud = dto.getIud();  //입력,수정, 삭제 구분
			if("I".equals(iud)) { 
				int seq  =   svc.selectWvalueMaxSeq(dto) ;
				dto.setOrder_seq(seq)  ;  
				boolean chk = svc.insertWvalue(dto);
				if(!chk) {
					model.addAttribute("error_code", "10000");
					model.addAttribute("error_msg" , "저장시 처리 실패하였습니다."); 
				}else {
					model.addAttribute("error_code", "0"); 
				}
			}else if("U".equals(iud)) {
				svc.updateWvalue(dto);				
			}else if("D".equals(iud)) {
				svc.deleteWvalue(dto);		
			}
		
			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" WvalDTOAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		//
		return "jsonView";
	}
	
	//회원등록관리 
	@RequestMapping(value="/base/base_mbrReg.do")
	public String base_mbrReg(@ModelAttribute("DTO") MberDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			CodeMdDTO csv = new CodeMdDTO() ;
			csv.setCode_cd("EMAIL");
			csv.setUse_yn("Y");
			csv.setCode_gb("Z");
			List <?> resultLst = svc.selectCodeDetailList(csv);
			model.addAttribute("commList", resultLst);
			
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return ".main/base/base_mbrReg";
	}	
	//회원목록관리 
	@RequestMapping(value="/base/base_mbrList.do")
	public String base_mbrList(@ModelAttribute("DTO") MberDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return ".main/base/base_mbrList";
	}	

	@RequestMapping(value="/base/ctl_mbrList.do")
	public String base_ctl_mbrList(@ModelAttribute("DTO") MberDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코드구분 정보 조회
			List<?> resultLst = svc.selectMbrList(dto);

			model.addAttribute("resultLst", resultLst);
			model.addAttribute("resultCnt", resultLst.size());
			model.addAttribute("error_code", "0"); 			
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}		
	@RequestMapping(value="/base/ctl_getmbrList.do")
	public String base_ctl_getmbrList(@ModelAttribute("DTO") MberDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코드구분 정보 조회
			List<?> resultLst = svc.getMbrList(dto);

			model.addAttribute("resultLst", resultLst);
			model.addAttribute("resultCnt", resultLst.size());
			model.addAttribute("error_code", "0"); 			
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}		
	@RequestMapping(value="/base/selectMbrInfo.do")
	public String base_selectMbrInfo(@ModelAttribute("DTO") MberDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코드구분 정보 조회
			MberDTO result = svc.selectMbrInfo(dto);

			model.addAttribute("result", result);
			model.addAttribute("error_code", "0"); 			
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}		

	@RequestMapping(value="/base/MbrSaveAct.do")
	public String base_MbrSaveAct(@ModelAttribute("DTO") MberDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코드구분 정보 조회
			if ("U".equals(dto.getIud())){
                svc.updateMember(dto);
			}
			model.addAttribute("error_code", "0"); 			
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}
	
	@RequestMapping(value="/base/ctl_selCommDtlInfo.do")
	public String base_selCommDtlInfo(@ModelAttribute("DTO") CodeMdDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			List<?> resultList = svc.selCommDtlInfo(dto);

			model.addAttribute("resultList", resultList);
			model.addAttribute("resultCnt", resultList.size());
			model.addAttribute("error_code", "0"); 
	
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	
	@RequestMapping(value="/base/MberDupChk.do")
	public String baee_MberDupChk(@ModelAttribute("DTO") MberDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			String   dupchk =  svc.selMberDupChk(dto) ;
			model.addAttribute("dupchk", dupchk); 
			model.addAttribute("error_code", "0"); 
	
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}		
	@RequestMapping(value= "/base/MemberSaveAct.do")
	public String base_MemberSaveAct(@ModelAttribute("DTO") MberDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			if ("I".equals(dto.getIud())) {
				
				dto.setPass_wd(EgovFileScrty.encryptPassword(dto.getPass_wd(), dto.getHosp_cd()));
				String chkapwd = EgovFileScrty.encryptPassword(dto.getPass_wd(), dto.getHosp_cd());
	
				if(chkapwd == "") {
					model.addAttribute("error_code", "30000");
					model.addAttribute("error_msg" , "등록할 비밀번호를 입력하세요   .");
					return "jsonView";
				}
				
				String chkbpwd = EgovFileScrty.encryptPassword(dto.getAf_pass_wd(), dto.getHosp_cd());
					
				if ((chkbpwd == "") & (chkapwd != chkbpwd)) {
					model.addAttribute("error_code", "30000");
					model.addAttribute("error_msg" , "등록할 비밀번호와 상이합니다    .");
					return "jsonView";
				}
				svc.insertMember(dto);
			}
			model.addAttribute("error_code", "0"); 	
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}
	//회원관리 
	@RequestMapping(value="/base/base_notiList.do")
	public String base_notiList(@ModelAttribute("DTO") NotiDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			CodeMdDTO csv = new CodeMdDTO() ;
			csv.setCode_cd("NOTI_GB");
			csv.setUse_yn("Y");
			csv.setCode_gb("Z");
			List <?> resultLst = svc.selectCodeDetailList(csv);
			model.addAttribute("commList", resultLst);
			
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return ".main/base/base_notiList";
	}	
	@RequestMapping(value="/base/ctl_notiList.do")
	public String ctl_notiList(@ModelAttribute("DTO") NotiDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			List <?> resultLst = svc.selectNotiMstList(dto);
			model.addAttribute("resultLst", resultLst);
			model.addAttribute("resultCnt", resultLst.size());	
			model.addAttribute("error_code", "0"); 
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	
	@RequestMapping(value="/base/selectNotiMstinfo.do")
	public String selectNotiMstinfo(@ModelAttribute("DTO") NotiDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			NotiDTO result = svc.selectNotiMstinfo(dto);
			model.addAttribute("error_code", "0"); 	
			model.addAttribute("result", result);
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	
	@RequestMapping(value="/base/notiSaveAct.do")
	public String selectnotiSaveProc(@ModelAttribute("DTO") NotiDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			if ("I".equals(dto.getIud())){
				svc.insertNotiMst(dto) ;
			}else if ("U".equals(dto.getIud())){
				svc.updateNotiMst(dto) ;
			}else if ("D".equals(dto.getIud())){
				svc.deleteNotiMst(dto) ;
			}
			model.addAttribute("error_code", "0"); 	
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}
	//회원관리              
	@RequestMapping(value="/popup/base_pwdchg.do")
	public String base_pwdchg(@ModelAttribute("DTO") UsermDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  

		return ".login/base_pwdchg";
	}	
	@RequestMapping(value="/base/pwdchgAct.do")
	public String base_loginAct(@ModelAttribute("DTO") UsermDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			HttpSession session = request.getSession();
		    String q_uuid = (String) session.getAttribute("q_uuid");
		    
		    if (q_uuid != null) {
		        dto.setHosp_uuid(q_uuid);
		    }; 
			UsermDTO result = svc.UserPasswdInfo(dto);
			if(result.getUser_id() == null || result.getUser_id().toString().isEmpty()){
				model.addAttribute("error_code", "20000");
			    model.addAttribute("error_msg", "비밀번호 변경할 사용자 정보가 존재하지 않습니다.");
			    return "jsonView";			
			}
			//현재비빌번호가 맞는지 
			String chkpwd = EgovFileScrty.encryptPassword(dto.getPass_wd(), dto.getUser_id());
			
			if(!result.getPass_wd().equals(chkpwd)) {
				model.addAttribute("error_code", "30000");
				model.addAttribute("error_msg" , "현재 비밀번호를 확인하세요.!");
				return "jsonView";
			}
			//////////////////////
			if(dto.getBf_pass_wd() == "") {
				model.addAttribute("error_code", "30000");
				model.addAttribute("error_msg" , "비밀번호 변경 정보가 존재하지 않습니다.");
				return "jsonView";
			}
			dto.setEnc_pass_wd(EgovFileScrty.encryptPassword(dto.getBf_pass_wd(), dto.getUser_id()));
			//비밀번호 변경 처리			
			boolean chk = svc.UserPasswdChange(dto);
			
			if(chk) {
				model.addAttribute("error_code", "0");
				model.addAttribute("error_msg" , "");
			}else {
				model.addAttribute("error_code", "10000");
				model.addAttribute("error_msg" , "사용자 비밀번호 변경 실패하였습니다.");
			}			
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	
	
	@RequestMapping(value= "/popup/base_pwdclear.do")
	public String base_pwdclear(@ModelAttribute("DTO") UsermDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  

		return ".login/base_pwdclr";
	}
	@RequestMapping(value= "/base/pwdresetAct.do")
	public String base_pwdresetAct(@ModelAttribute("DTO") UsermDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			HttpSession session = request.getSession();
		    String q_uuid = (String) session.getAttribute("q_uuid");
		    
		    if (q_uuid != null) {
		        dto.setHosp_uuid(q_uuid);
		    }
			
			UsermDTO result = svc.UserPasswdInfo(dto);
			if(result.getUser_id() == null || result.getUser_id().toString().isEmpty()){
				model.addAttribute("error_code", "20000");
			    model.addAttribute("error_msg", "비밀번호 변경할 사용자 정보가 존재하지 않습니다.");
			    return "jsonView";			
			}
			dto.setEnc_pass_wd(EgovFileScrty.encryptPassword("1234", dto.getUser_id()));
			//비밀번호 변경 처리			
			boolean chk = svc.UserPasswdChange(dto);
			
			if(chk) {
				model.addAttribute("error_code", "0");
				model.addAttribute("error_msg" , "");
			}else {
				model.addAttribute("error_code", "10000");
				model.addAttribute("error_msg" , "사용자 비밀번호 변경 실패하였습니다.");
			}		
			
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	
	@RequestMapping(value= "/popup/base_pwdmgr.do")
	public String base_pwdsearch(@ModelAttribute("DTO") UsermDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  

		return ".login/base_pwdmgr";
	}	
	@RequestMapping(value= "/popup/base_usersearch.do")
	public String base_usersearch(@ModelAttribute("DTO") UsermDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try {
			UsermDTO result = svc.UsernmInfo(dto);
			model.addAttribute("result", result);
			model.addAttribute("error_code", "0");
		}catch(Exception ex){
			model.addAttribute("error_code", "10000"); 	
		}

		return "jsonView";
	}	
	
	//계약정보              
	@RequestMapping(value="/base/base_hospconList.do")
	public String base_hospconList(@ModelAttribute("DTO") HospConDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			CodeMdDTO csv = new CodeMdDTO() ;
			csv.setCode_cd("CONACT_GB");
			csv.setUse_yn("Y");
			csv.setCode_gb("Z");
			List <?> resultLst = svc.selectCodeDetailList(csv);
			model.addAttribute("commList", resultLst);			
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return ".main/base/base_hospconList";
	}	
	@RequestMapping(value="/base/base_hospsumconList.do")
	public String base_hospsumconList(@ModelAttribute("DTO") HospConDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			CodeMdDTO csv = new CodeMdDTO() ;
			csv.setCode_cd("CONACT_GB");
			csv.setUse_yn("Y");
			csv.setCode_gb("Z");
			List <?> resultLst = svc.selectCodeDetailList(csv);
			model.addAttribute("commList", resultLst);			
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return ".main/base/base_hospsumconList";
	}		
	//계약정보              
	@RequestMapping(value="/base/ctl_hospConList.do")
	public String base_ctl_hospConList(@ModelAttribute("DTO") HospConDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			List <?> resultLst = svc.selectHospConList(dto);
			model.addAttribute("resultLst", resultLst);
			model.addAttribute("resultCnt", resultLst.size());	
			model.addAttribute("error_code", "0"); 
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	
	//계약정보              
	@RequestMapping(value="//base/ctl_hospconInfo.do")
	public String base_ctl_hospconInfo(@ModelAttribute("DTO") HospConDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			HospConDTO  result = svc.selectHospConInfo(dto);
			model.addAttribute("result", result);
			model.addAttribute("error_code", "0"); 
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}		
	//계약정보              
	@RequestMapping(value="/base/ctl_gethospconInfo.do")
	public String base_ctl_gethospconInfo(@ModelAttribute("DTO") HospConDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			String  conyn = svc.getHospConInfo(dto);
			model.addAttribute("conyn", conyn);
			model.addAttribute("error_code", "0"); 
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	
	
	//병원정보가져오기            
	@RequestMapping(value="/base/ctl_getHospmst.do")
	public String ctl_getHospmst(@ModelAttribute("DTO") HospMdDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			HospMdDTO  result = svc.getHospmst(dto);
			model.addAttribute("result", result);
			model.addAttribute("error_code", "0"); 
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}
	
	@RequestMapping(value="/base/HospconSaveAct.do")
	public String HospconSaveAct(@ModelAttribute("DTO") HospConDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		try {
			String iud2 = dto.getIud2();  //입력,수정, 삭제 구분			
			if("DI".equals(iud2)) {
				svc.insertHospCon(dto) ;
			}else if("DU".equals(iud2)) { 
				svc.updateHospCon(dto);
			}else if("DD".equals(iud2)) {
				svc.updateHospCon(dto); 
			}			
			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		
		}
		//
		return "jsonView";
	}	
	//의약사관리              
	@RequestMapping(value="/base/base_asqList.do")
	public String base_asqList(@ModelAttribute("DTO") AsqDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return ".main/base/base_asqList";
	}
	//병원정보가져오기            
	@RequestMapping(value= "base/ctl_asqList.do")
	public String ctl_asqList(@ModelAttribute("DTO") AsqDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			List<?>  resultLst = svc.selectqstnlist(dto);
			model.addAttribute("resultLst", resultLst);
			model.addAttribute("resultCnt", resultLst.size());
			model.addAttribute("error_code", "0"); 
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	
	@RequestMapping(value= "/base/selectAnsrInfo.do")
	public String selectAnsrInfo(@ModelAttribute("DTO") AsqDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			AsqDTO  result = svc.selectqstnInfo(dto);
			model.addAttribute("result", result);
			model.addAttribute("error_code", "0"); 
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}		
	
	@RequestMapping(value="/base/asqSaveAct.do")
	public String base_asqSaveAct(@ModelAttribute("DTO") AsqDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			if ("QI".equals(dto.getIud())){
				svc.insertqstnMst(dto) ;
			}else if ("QU".equals(dto.getIud())){
				svc.updateqstnMst(dto) ;
			}else if ("AU".equals(dto.getIud())){
				svc.updateAnsrMst(dto) ;
			}else if ("D".equals(dto.getIud())){
				svc.updateqstnMst(dto) ;
			}
			model.addAttribute("error_code", "0"); 	
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	
	//가산식대관리              
	@RequestMapping(value="/base/base_dietList.do")
	public String base_dietList(@ModelAttribute("DTO") DietDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			CodeMdDTO vo = new CodeMdDTO();
			vo.setCode_gb("Z") ;
			vo.setCode_cd("GASAN_SIK");
            List<?> resultLst = svc.selectCodeDetailList(vo);
          
            model.addAttribute("error_code", "0"); 	
            model.addAttribute("commList", resultLst); 	
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return ".main/base/base_dietList";
	}	
	
	//가산식대관리       
	@RequestMapping(value= "base/ctl_dietList.do")
	public String ctl_dietList(@ModelAttribute("DTO") DietDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			List<?>  resultLst = svc.selectDietlist(dto);
			model.addAttribute("resultLst", resultLst);
			model.addAttribute("resultCnt", resultLst.size());
			model.addAttribute("error_code", "0"); 
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	
	@RequestMapping(value="/base/DietSaveProc.do")
	public String DietSaveProc(@ModelAttribute("VO") DietDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		
		try {
			
			String iud = dto.getIud();  //입력,수정, 삭제 구분
			
			if("I".equals(iud)) { 
				svc.insertDiet(dto);
			}else if("U".equals(iud)) {
				svc.updateDiet(dto);				
			}else if("D".equals(iud)) {
				svc.updateDiet(dto);		
			}
		
			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" UserListAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		//
		return "jsonView";
	}
	@RequestMapping(value= "/base/selectDietInfo.do")
	public String selectDietInfo(@ModelAttribute("DTO") DietDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			//코그구분 정보 조회
			DietDTO  result = svc.selectDietInfo(dto);
			model.addAttribute("result", result);
			model.addAttribute("error_code", "0"); 
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}		
	//의사약사관리(면허관리)              
	@RequestMapping(value="/base/base_licList.do")
	public String base_liseList(@ModelAttribute("DTO") HospEmpDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			CodeMdDTO vo = new CodeMdDTO();
			vo.setCode_gb("Z") ;
			vo.setCode_cd("LIC_TYPE");
            List<?> resultLst = svc.selectCodeDetailList(vo);
          
            model.addAttribute("error_code", "0"); 	
            model.addAttribute("commList", resultLst); 				
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return ".main/base/base_licList";
	}	
	@RequestMapping(value="/base/selectHospEmpList.do")
	public String base_selectHospEmpList(@ModelAttribute("DTO") HospEmpDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
            List<?> resultLst = svc.selectHospEmpList(dto);
          
            model.addAttribute("error_code", "0"); 	
            model.addAttribute("resultLst", resultLst); 	
            model.addAttribute("resultCnt", resultLst.size());
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	
	@RequestMapping(value="/base/selectHospEmpInfo.do")
	public String base_selectHospEmpInfo(@ModelAttribute("DTO") HospEmpDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			HospEmpDTO  result = svc.selectHospEmpInfo(dto);
 
            model.addAttribute("error_code", "0"); 	
            model.addAttribute("result", result); 	
  		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	
	@RequestMapping(value="/base/HospEmpSaveAct.do")
	public String HospEmpSaveAct(@ModelAttribute("DTO") HospEmpDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			String iud = dto.getIud();  //입력,수정, 삭제 구분
			
			if("I".equals(iud)) { 
				svc.insertHospEmp(dto);
			}else if("U".equals(iud)) {
				svc.updateHospEmp(dto);				
			}else if("D".equals(iud)) {
				svc.updateHospEmp(dto);		
			}
			model.addAttribute("error_code", "0"); 
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}		
	//의약사관리                
	@RequestMapping(value="/base/base_licworkList.do")
	public String base_docphamList(@ModelAttribute("DTO") LicworkDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			CodeMdDTO vo = new CodeMdDTO();
			vo.setCode_gb("Z") ;
			vo.setCode_cd("VAC_GB");
            List<?> resultLst = svc.selectCodeDetailList(vo);	
            model.addAttribute("error_code", "0");
            model.addAttribute("commList", resultLst); 	
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return ".main/base/base_licworkList";
	}
	//라이센스 근무일정                
	@RequestMapping(value="/base/ctl_licworkList.do")
	public String base_ctl_licworkList(@ModelAttribute("DTO") LicworkDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
            List<?> resultLst = svc.selectlicworkList(dto);
       
            model.addAttribute("error_code", "0"); 	
            model.addAttribute("resultLst", resultLst); 	
            model.addAttribute("resultCnt", resultLst.size());
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	
	@RequestMapping(value="/base/selectlicworkInfo.do")
	public String base_selectlicworkInfo(@ModelAttribute("DTO") LicworkDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			LicworkDTO  result = svc.selectlicworkInfo(dto);
 
            model.addAttribute("error_code", "0"); 	
            model.addAttribute("result", result); 	
  		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}
	@RequestMapping(value="/base/licworkSaveAct.do")
	public String licworkSaveAct(@ModelAttribute("DTO") LicworkDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			String iud = dto.getIud();  //입력,수정, 삭제 구분
			
			if("I".equals(iud)) { 
				svc.insertlicwork(dto);
			}else if("U".equals(iud)) {
				svc.updatelicwork(dto);				
			}else if("D".equals(iud)) {
				svc.updatelicwork(dto);		
			}
			model.addAttribute("error_code", "0"); 
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	
	//면허번호검색    
	@RequestMapping(value= "/base/ctl_licnmList.do", method = RequestMethod.POST)
	public String ctl_licnmList(@ModelAttribute("DTO") HospEmpDTO dto, HttpServletRequest request, Model model) throws Exception {
	try {
		List<?> resultLst = svc.selectHospEmpList(dto) ;
		model.addAttribute("error_code", "0"); 
		model.addAttribute("resultLst", resultLst); 
		model.addAttribute("resultCnt", resultLst.size());  
	}catch(Exception ex) {
		log.error(" HospMdDTO ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	
	//프로그램등록관리                 
	@RequestMapping(value="/base/base_urlpathList.do")
	public String base_UrlpathList(@ModelAttribute("DTO") UrlpathDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			CodeMdDTO vo = new CodeMdDTO();
			vo.setCode_gb("Z") ;
			vo.setCode_cd("URL_PATH");
            List<?> resultLst = svc.selectCodeDetailList(vo);	
            model.addAttribute("error_code", "0");
            model.addAttribute("commList", resultLst); 	
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return ".main/base/base_urlpathList";
	}
	//라이센스 근무일정                
	@RequestMapping(value="/base/ctl_urlpathList.do")
	public String base_ctl_UrlpathList(@ModelAttribute("DTO") UrlpathDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
            List<?> resultLst = svc.selectUrlpathList(dto);
       
            model.addAttribute("error_code", "0"); 	
            model.addAttribute("resultLst", resultLst); 	
            model.addAttribute("resultCnt", resultLst.size());
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	
	@RequestMapping(value="/base/selecturlpathInfo.do")
	public String base_selectUrlpathInfo(@ModelAttribute("DTO") UrlpathDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			UrlpathDTO  result = svc.selectUrlpathInfo(dto);
 
            model.addAttribute("error_code", "0"); 	
            model.addAttribute("result", result); 	
  		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}
	@RequestMapping(value="/base/urlpathSaveAct.do")
	public String UrlpathSaveAct(@ModelAttribute("DTO") UrlpathDTO dto, HttpServletRequest request, ModelMap model) throws Exception {  
		try { 
			String iud = dto.getIud();  //입력,수정, 삭제 구분
			
			if("I".equals(iud)) { 
				svc.insertUrlPathMst(dto) ;
			}else if("U".equals(iud)) {
				svc.updateUrlPathMst(dto);				
			}else if("D".equals(iud)) {
				svc.updateUrlPathMst(dto);		
			}
			model.addAttribute("error_code", "0"); 
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}	

}



