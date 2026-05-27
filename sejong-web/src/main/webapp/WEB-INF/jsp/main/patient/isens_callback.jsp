<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<link href="/bootstrap/css/bootstrap.css" rel="stylesheet">
<title>i-Sens 연동 처리</title>
<!-- jQuery + commonUtil 필수 -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<script src="/asset/js/commonUtil.js"></script>
<script>
  sessionStorage.setItem("contextPath", '<c:out value="${pageContext.request.contextPath}"/>');
</script>
<script>
$(function(){
	var code = "${code}";
	if (!code) {
		$("#msg").text("인가코드(code)가 없습니다. 다시 시도해주세요.");
		return;
	}
	var redirectUri = window.location.origin + CommonUtil.getContextPath() + "/patient/isensCallback.do";
	$.ajax({
		url: CommonUtil.getContextPath() + "/getToken.do",
		type: "post",
		data: JSON.stringify({ code: code, redirect_uri: redirectUri }),
		contentType: "application/json",
		dataType: "json",
		success: function(r){
			if (r && r.IsSucceed) {
				$("#msg").text("✓ i-Sens 연동이 완료되었습니다.");
				setTimeout(function(){ location.href = CommonUtil.getContextPath() + "/main.do"; }, 1500);
			} else {
				$("#msg").text("연동 실패: " + (r.Message || ""));
			}
		},
		error: function(){ $("#msg").text("토큰 처리 중 오류"); }
	});
});
</script>
</head>
<body>
<div class="container py-5 text-center">
	<h3>i-Sens 연동 처리 중...</h3>
	<p id="msg" class="mt-4">잠시만 기다려주세요...</p>
</div>
</body>
</html>
