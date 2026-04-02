<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
	<head>
		<script type="text/javascript" src="<c:url value='/js/jquery-3.5.1.min.js' />"></script>
		<meta charset="UTF-8">
		<title>로그인 페이지</title>
		<link rel="stylesheet" type="text/css" href="/css/login.css" />
	</head>
	
	<body>
		<div id="All">
	        <div id="left">
	            <div id="loginbox">
	                <div class='text'>로그인</div>
	                <div class="idpw">
	                    <input type="text" name="userid" class="outlined-basic" placeholder="ID" id="loginId">
	                    <input type="password" name="passwd" class="outlined-basic" placeholder="PW" id="loginPw">
	                    <div class="checkbox">
	                        <div><input type="checkbox" id="idck"><label for="idck"> 아이디 저장</label></div>
	                        <div><a onclick="openPopup()" class="pwlink">비밀번호 변경</a></div>
	                    </div>
	                </div>
	                <div class="btnbox">
	                    <button class="login__btn" id="loginBtn">로그인</button>
	                </div>
	            </div>
	        </div>
	        <div id="backimg"></div>
	    </div>
	</body>  
	
</html>