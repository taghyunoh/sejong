<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>    
<%@ page import ="java.util.Date" %>
<%
	Date nowTime = new Date();
	// 캐시 헤더는 여기(include 되는 JSP)서 못 건다 — 서블릿 명세상 무시된다.
	// 최상위 레이아웃 tiles/login/login.jsp 에서 설정한다.
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
	<%-- style.css 의 @import 에는 캐시버스터를 붙일 수 없어 개별 link 로 풀었다. 순서 유지 필수. --%>
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