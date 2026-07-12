package egovframework.sejong.util;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.web.servlet.HandlerInterceptor;

/**
 * 세션(로그인) 체크 인터셉터.
 *
 * <p>로그인 후 오래 방치해 톰캣 세션이 만료되면 {@code session.getAttribute("user")} 가 null 이 되고,
 * 그 상태로 화면을 이동하거나 AJAX 를 호출하면 컨트롤러에서 NPE(500) 가 나거나 조용히 실패해
 * "프로그램 동작이 안 함" 처럼 보이던 문제를 막는다.</p>
 *
 * <p>동작:
 * <ul>
 *   <li>로그인 전 접근이 필요한 공개 URL({@link #PUBLIC_URIS}) 은 그대로 통과.</li>
 *   <li>세션에 user 가 있으면 통과.</li>
 *   <li>세션 만료/미로그인 상태에서 보호 URL 요청 시:
 *     <ul>
 *       <li>AJAX 면 HTTP 401 + {@code sessionExpired:true} JSON → 클라이언트(commonUtil.js
 *           전역 ajaxError)가 로그인 화면으로 이동.</li>
 *       <li>페이지 이동이면 서버에서 {@code /loginPage.do} 로 리다이렉트.</li>
 *     </ul>
 *     로그인 화면 진입 시 자동로그인(저장 폰번호) 이 켜져 있으면 그대로 재로그인되어 자연 복구된다.</li>
 * </ul>
 * </p>
 *
 * <p>정적 리소스(css/js/img)는 web.xml 의 servlet-mapping 이 {@code *.do} 만 DispatcherServlet 으로
 * 보내므로 애초에 이 인터셉터를 타지 않는다. 따라서 여기서는 {@code *.do} 엔드포인트만 신경 쓰면 된다.</p>
 */
public class SessionCheckInterceptor implements HandlerInterceptor {

	/** 로그인 전(비인증) 접근이 허용되어야 하는 엔드포인트 목록. 로그인/회원가입/약관/자동로그인 흐름 전체. */
	private static final Set<String> PUBLIC_URIS = new HashSet<>(Arrays.asList(
			"/index.do",        // 진입점(세션 유무에 따라 login/main 으로 분기)
			"/loginPage.do",    // 로그인 화면
			"/sendSensApi.do",  // 인증문자 발송
			"/loginCheck.do",   // 인증번호 확인(세션 생성)
			"/autoLogin.do",    // 자동로그인(세션 생성)
			"/registerUser.do", // 회원가입(세션 생성)
			"/updateUser.do",   // 가입 흐름 중 회원정보 갱신(세션 생성)
			"/User.do",         // 가입 흐름 중 전화번호 존재 확인
			"/testUser.do",     // 테스트/간편 로그인(세션 생성)
			"/testUser2.do",
			"/testUser3.do",    // 카카오 이메일 로그인(세션 생성)
			"/callback.do",     // 구글 OAuth 콜백
			"/getSignList.do",  // 로그인 화면 약관 조회
			"/alldelete.do",    // 로그인 화면 회원탈퇴
			"/sampleAjax.do"
	));

	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
			throws Exception {

		String ctx = request.getContextPath();
		String path = request.getRequestURI();
		if (ctx != null && !ctx.isEmpty() && path.startsWith(ctx)) {
			path = path.substring(ctx.length());
		}

		// 공개 URL 은 세션 검사 없이 통과
		if (PUBLIC_URIS.contains(path)) {
			return true;
		}

		HttpSession session = request.getSession(false);
		Object user = (session == null) ? null : session.getAttribute("user");
		if (user != null) {
			return true; // 로그인 상태 → 통과
		}

		// 세션 만료/미로그인
		if (isAjax(request)) {
			response.setStatus(HttpServletResponse.SC_UNAUTHORIZED); // 401
			response.setContentType("application/json;charset=UTF-8");
			response.getWriter().write(
					"{\"IsSucceed\":false,\"sessionExpired\":true,"
					+ "\"Message\":\"세션이 만료되었습니다. 다시 로그인해 주세요.\"}");
			response.getWriter().flush();
		} else {
			response.sendRedirect(ctx + "/loginPage.do");
		}
		return false;
	}

	/** jQuery $.ajax 는 same-origin 요청에 X-Requested-With 를 자동으로 붙인다. JSON 요청도 AJAX 로 간주. */
	private boolean isAjax(HttpServletRequest request) {
		if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
			return true;
		}
		String contentType = request.getContentType();
		if (contentType != null && contentType.contains("application/json")) {
			return true;
		}
		String accept = request.getHeader("Accept");
		return accept != null && accept.contains("application/json");
	}
}
