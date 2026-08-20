<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>    
<%@ page import ="java.util.Date" %>
<%
	Date nowTime = new Date();
	// 캐시 헤더는 여기(include 되는 JSP)서 못 건다 — 서블릿 명세상 무시된다.
	// 최상위 레이아웃 tiles/main/main.jsp 에서 설정한다.
%>
	<script type="text/javascript">
		sessionStorage.setItem("contextPath", '<c:out value="${pageContext.request.contextPath}"/>');
	</script>
	
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="description" content="">
	<!-- Font 및 animate 추후 수정  -->
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"/>
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" />
	
	
	<!-- JQuery 관련 -->
	<script type="text/javascript" src="<c:url value='/asset/js/jquery/common.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/asset/js/jquery-3.5.1.min.js'/>"></script> 
	<script type="text/javascript" src="<c:url value='/asset/js/commonUtil.js'/>?date=<%= nowTime %>"></script> 
	<script type="text/javascript" src="<c:url value='/asset/js/app-common.js'/>?date=<%= nowTime %>"></script> 
	<%-- style.css 는 @import 로 4개를 불러오는데, @import URL 에는 캐시버스터를 붙일 수 없어
	     배포 후에도 브라우저가 옛 CSS 를 계속 썼다. 개별 link 로 풀어 각각에 ?date 를 건다.
	     순서는 style.css 의 @import 순서와 같아야 한다(뒤가 앞을 덮는다). --%>
	<%-- style.css 의 @import 에는 캐시버스터를 못 붙여 개별 link 로 풀었다. 순서 유지 필수.
	     경로는 반드시 컨텍스트 경로를 포함해야 한다(운영은 /app 아래에 배포됨).
	     c:url 은 세션 쿠키가 없을 때 `;jsessionid=...` 를 끼워 넣으므로 EL 로 직접 붙인다. --%>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/asset/css/swiper.css?date=<%= nowTime.getTime() %>"/>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/asset/css/layout.css?date=<%= nowTime.getTime() %>"/>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/asset/css/common.css?date=<%= nowTime.getTime() %>"/>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/asset/css/app-desktop.css?date=<%= nowTime.getTime() %>"/>
	<script type="text/javascript" src="<c:url value='/asset/js/plugins.min.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/asset/js/default.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/asset/js/tmpl.min.js' />"></script>

<%-- ★[2026-08-20 요청] **1시간 동안 화면을 만지지 않으면 자동 로그아웃.**
     · 서버는 이미 `web.xml <session-timeout>60</session-timeout>` 이라 1시간 뒤 세션이 죽는다.
       하지만 그건 **다음 요청을 보낼 때** 로그인 화면으로 튕기는 것이라, 켜 둔 화면은 그대로 남아 있었다.
       (남의 손이 닿을 수 있는 화면에 개인 혈당 자료가 계속 떠 있다.) ⇒ 화면 스스로 나가게 한다.
     · 여기(공통 header)는 **로그인 뒤 화면(tiles 'main')에만** 들어간다 — 로그인 화면에는 안 걸린다.
     · 서버 시간과 맞추려 60분으로 둔다. ⚠web.xml 을 고치면 아래 IDLE_MIN 도 같이 고칠 것. --%>
<script type="text/javascript">
(function(){
  var IDLE_MIN = 60;                       // 무활동 허용 시간(분) — web.xml session-timeout 과 같게
  var LIMIT = IDLE_MIN * 60 * 1000;
  var timer = null, last = 0, done = false;

  function ctx(){
    try { return CommonUtil.getContextPath(); } catch(e){ return ''; }
  }
  function bye(){
    if (done) return; done = true;
    /* 자동로그인을 꺼야 로그아웃이 유효하다 — 안 끄면 로그인 화면에서 곧바로 다시 들어온다
       (login/main.jsp 의 logout() 주석과 같은 이유). 앱이 아니면 조용히 넘어간다. */
    try { callAndroid("f102", { phone: (window._userPhone || ''), autoYn:false, saveYn:true }); } catch(e){}
    alert(IDLE_MIN + '분 동안 사용하지 않아 로그아웃되었습니다.\n다시 로그인해 주세요.');
    var go = function(){ location.href = ctx() + '/loginPage.do'; };
    try { CommonUtil.callAjax(ctx() + '/logout.do', 'POST', '', go); setTimeout(go, 1500); }  /* 응답이 없어도 나간다 */
    catch(e){ go(); }
  }
  function reset(){
    if (done) return;
    var now = +new Date();
    if (now - last < 30000) return;        // 30초 안에 또 들어온 움직임은 흘린다(마우스·스크롤이 초당 수십 번 온다)
    last = now;
    if (timer) clearTimeout(timer);
    timer = setTimeout(bye, LIMIT);
  }

  /* 사람이 화면을 만졌다고 볼 수 있는 것들. capture 로 잡아 화면 어디서 눌러도 걸린다. */
  ['click','keydown','touchstart','mousedown','mousemove','wheel','scroll','input'].forEach(function(ev){
    document.addEventListener(ev, reset, true);
  });
  /* 다른 앱·탭에 갔다가 돌아온 것도 '만진 것'으로 본다 */
  document.addEventListener('visibilitychange', function(){ if (!document.hidden) reset(); });

  last = 0; reset();                       // 화면을 연 시점부터 시작
})();
</script>
	