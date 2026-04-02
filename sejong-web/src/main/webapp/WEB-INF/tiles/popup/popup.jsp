<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="decorator" uri="http://www.opensymphony.com/sitemesh/decorator" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/page" prefix="page" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<%@ include file="/WEB-INF/jsp/main/com/head.jsp"%>    
<meta http-equiv="X-UA-Compatible" content="ie=edge" /> 
<link href="/bootstrap/css/bootstrap.css" rel="stylesheet">   
<link href="/asset/css/common.css" rel="stylesheet">
<meta http-equiv="Cache-Control" content="no-Cache" /> 
<meta http-equiv="Pragma" content="no-Cache" /> 
<meta http-equiv="imagetoolbar" content="no" /> 
<meta name="robots" content="noindex,nofollow" />  
<title><decorator:title/></title>
<decorator:head/>
<script>
 
</script>
</head>
<body>
<form id="chkfrm" name="chkfrm" method="post"> 
	<input type="hidden" name="session" id="session" value="${sessionScope['q_user_id']}"/>
</form> 
<body>
			<decorator:body/>
 
  	
</body>
</html> 