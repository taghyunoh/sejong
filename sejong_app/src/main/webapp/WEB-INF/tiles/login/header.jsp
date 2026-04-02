<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>    
<%@ page import ="java.util.Date" %>
<%
	Date nowTime = new Date();
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
	<script type="text/javascript" src='/asset/js/jquery/common.js'></script>
	<script type="text/javascript" src="<c:url value='/asset/js/jquery-3.5.1.min.js'/>"></script> 
	<script type="text/javascript" src="<c:url value='/asset/js/commonUtil.js'/>?date=<%= nowTime %>"></script> 
	<script type="text/javascript" src="<c:url value='/asset/js/app-common.js'/>"></script> 
	<link rel="stylesheet" type="text/css" href="<c:url value='/asset/css/style.css'/>"/>
	<script type="text/javascript" src="<c:url value='/asset/js/plugins.min.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/asset/js/default.js'/>"></script>
	<script type="text/javascript" src="<c:url value='/asset/js/tmpl.min.js' />"></script>