<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="tiles" uri="http://tiles.apache.org/tags-tiles"%>
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
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<tiles:insertAttribute name="header" />
<%@ include file="/WEB-INF/inc/pwa-head.jsp" %>
</head>
<body>
		<tiles:insertAttribute name="content" />	
	
</body>