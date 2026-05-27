package egovframework.sejong.base.web;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;

import egovframework.sejong.base.model.UsermDTO;
import egovframework.sejong.base.service.BaseService;
import egovframework.util.EgovFileScrty;

/**
 * 비밀번호 변경/초기화/조회 팝업 처리 컨트롤러.
 *
 * 기존 BaseController 에는 50여 개의 미사용 URL 매핑(/base/*) 이 있었으나
 * 헤더 메뉴에서 도달 불가하여 2026-05-27 정리됨. 비밀번호 관련 6개 엔드포인트만 보존.
 *
 * 호출 흐름:
 *   /popup/base_pwdchg.do   → 비밀번호 변경 팝업    (header.jsp fnPasswdChange)
 *   /popup/base_pwdclear.do → 비밀번호 초기화 팝업  (header.jsp fnPwdClear)
 *   /popup/base_pwdmgr.do   → 아이디/비번 찾기 팝업 (header.jsp fnPasswdmanager)
 *   /base/pwdchgAct.do      → 비밀번호 변경 처리 (JSON)
 *   /base/pwdresetAct.do    → 비밀번호 초기화 처리 (JSON)
 *   /popup/base_usersearch.do → 사용자 검색 (JSON)
 */
@Controller
public class BaseController {
	private static final Logger log = LoggerFactory.getLogger(BaseController.class);

	@Resource(name = "BaseService")
	private BaseService svc;

	/* 비밀번호 변경 팝업 화면 */
	@RequestMapping(value = "/popup/base_pwdchg.do")
	public String base_pwdchg(@ModelAttribute("DTO") UsermDTO dto, HttpServletRequest request, ModelMap model) throws Exception {
		return ".login/base_pwdchg";
	}

	/* 비밀번호 변경 처리 */
	@RequestMapping(value = "/base/pwdchgAct.do")
	public String base_loginAct(@ModelAttribute("DTO") UsermDTO dto, HttpServletRequest request, ModelMap model) throws Exception {
		try {
			HttpSession session = request.getSession();
			String q_uuid = (String) session.getAttribute("q_uuid");

			if (q_uuid != null) {
				dto.setHospUuid(q_uuid);
			}
			UsermDTO result = svc.UserPasswdInfo(dto);
			if (result.getUserId() == null || result.getUserId().toString().isEmpty()) {
				model.addAttribute("error_code", "20000");
				model.addAttribute("error_msg", "비밀번호 변경할 사용자 정보가 존재하지 않습니다.");
				return "jsonView";
			}
			// 현재 비밀번호가 맞는지
			String chkpwd = EgovFileScrty.encryptPassword(dto.getPassWd(), dto.getUserId());

			if (!result.getPassWd().equals(chkpwd)) {
				model.addAttribute("error_code", "30000");
				model.addAttribute("error_msg", "현재 비밀번호를 확인하세요.!");
				return "jsonView";
			}
			if (dto.getBfPassWd() == "") {
				model.addAttribute("error_code", "30000");
				model.addAttribute("error_msg", "비밀번호 변경 정보가 존재하지 않습니다.");
				return "jsonView";
			}
			dto.setEncPassWd(EgovFileScrty.encryptPassword(dto.getBfPassWd(), dto.getUserId()));
			// 비밀번호 변경 처리
			boolean chk = svc.UserPasswdChange(dto);

			if (chk) {
				model.addAttribute("error_code", "0");
				model.addAttribute("error_msg", "");
			} else {
				model.addAttribute("error_code", "10000");
				model.addAttribute("error_msg", "사용자 비밀번호 변경 실패하였습니다.");
			}
		} catch (Exception ex) {
			log.error(" pwdchgAct ERROR ! : " + ex.getMessage());
			model.addAttribute("error_code", "10000");
		}
		return "jsonView";
	}

	/* 비밀번호 초기화 팝업 화면 */
	@RequestMapping(value = "/popup/base_pwdclear.do")
	public String base_pwdclear(@ModelAttribute("DTO") UsermDTO dto, HttpServletRequest request, ModelMap model) throws Exception {
		return ".login/base_pwdclr";
	}

	/* 비밀번호 초기화 처리 (1234 로 리셋) */
	@RequestMapping(value = "/base/pwdresetAct.do")
	public String base_pwdresetAct(@ModelAttribute("DTO") UsermDTO dto, HttpServletRequest request, ModelMap model) throws Exception {
		try {
			HttpSession session = request.getSession();
			String q_uuid = (String) session.getAttribute("q_uuid");

			if (q_uuid != null) {
				dto.setHospUuid(q_uuid);
			}

			UsermDTO result = svc.UserPasswdInfo(dto);
			if (result.getUserId() == null || result.getUserId().toString().isEmpty()) {
				model.addAttribute("error_code", "20000");
				model.addAttribute("error_msg", "비밀번호 변경할 사용자 정보가 존재하지 않습니다.");
				return "jsonView";
			}
			dto.setEncPassWd(EgovFileScrty.encryptPassword("1234", dto.getUserId()));
			// 비밀번호 변경 처리
			boolean chk = svc.UserPasswdChange(dto);

			if (chk) {
				model.addAttribute("error_code", "0");
				model.addAttribute("error_msg", "");
			} else {
				model.addAttribute("error_code", "10000");
				model.addAttribute("error_msg", "사용자 비밀번호 변경 실패하였습니다.");
			}

		} catch (Exception ex) {
			log.error(" pwdresetAct ERROR ! : " + ex.getMessage());
			model.addAttribute("error_code", "10000");
		}
		return "jsonView";
	}

	/* 아이디/비밀번호 찾기 팝업 화면 */
	@RequestMapping(value = "/popup/base_pwdmgr.do")
	public String base_pwdsearch(@ModelAttribute("DTO") UsermDTO dto, HttpServletRequest request, ModelMap model) throws Exception {
		return ".login/base_pwdmgr";
	}

	/* 사용자 검색 (이름+이메일 → ID/비번 조회) */
	@RequestMapping(value = "/popup/base_usersearch.do")
	public String base_usersearch(@ModelAttribute("DTO") UsermDTO dto, HttpServletRequest request, ModelMap model) throws Exception {
		try {
			UsermDTO result = svc.UsernmInfo(dto);
			model.addAttribute("result", result);
			model.addAttribute("error_code", "0");
		} catch (Exception ex) {
			log.error(" base_usersearch ERROR ! : " + ex.getMessage());
			model.addAttribute("error_code", "10000");
		}
		return "jsonView";
	}
}
