<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="tiles" uri="http://tiles.apache.org/tags-tiles"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%
	// HTML 을 브라우저가 캐시하면 그 안에 박힌 `?date=...` 링크도 옛 값 그대로라
	// CSS/JS 캐시버스터가 무력해진다(배포해도 화면이 안 바뀌던 원인).
	// 화면 HTML 만 매번 새로 받게 하고, 정적 파일은 계속 캐시한다.
	// ※ include 되는 header.jsp 에서는 헤더를 못 건다(서블릿 명세). 최상위 레이아웃인 여기서 설정한다.
	response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
	response.setHeader("Pragma", "no-cache");
	response.setDateHeader("Expires", 0);
%>
<head>
<%-- ★[2026-08-25] viewport-fit=cover 는 **넣지 않는다**(넣었다가 되돌림).
     cover 를 주면 페이지가 시스템 바 아래까지 그려져(edge-to-edge) **앱이 하단 네비게이션 바를 덮는다.**
     안드로이드 WebView 는 env(safe-area-inset-bottom) 을 0 으로 주는 경우가 많아 보정도 안 된다.
     cover 없이 두면 뷰포트가 시스템 바를 뺀 영역으로 잡혀 네비 바가 그대로 보인다. --%>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<tiles:insertAttribute name="header" />
<%@ include file="/WEB-INF/inc/pwa-head.jsp" %>
</head>
<body>
	<div id="wrap" class="wrap">
		
		<tiles:insertAttribute name="top" />
		
		
		<tiles:insertAttribute name="content" />	
		<%-- <tiles:insertAttribute name="foot" /> --%>
		

		<tiles:insertAttribute name="foot" />
		
	</div>
</body>