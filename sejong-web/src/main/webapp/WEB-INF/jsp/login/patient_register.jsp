<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<link href="/bootstrap/css/bootstrap.css" rel="stylesheet">
<link href="/asset/css/common.css" rel="stylesheet">
<link href="/css/login.css" rel="stylesheet">
<script src="/bootstrap/js/bootstrap.bundle.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<script type="text/javascript" src='/js/jqgrid_common.js'></script>
<script type="text/javascript" src='/js/jquery/common.js'></script>
<script type="text/javascript" src='/asset/js/commonUtil.js'></script>
<script type="text/javascript">
  sessionStorage.setItem("contextPath", '<c:out value="${pageContext.request.contextPath}"/>');
</script>
<title>사용자 회원가입</title>
<script type="text/javaScript">
function registerProc(){
	var dto = {
		userNm: $.trim($("#userNm").val()),
		phone : $.trim($("#phone").val()),
		userPw: $("#userPw").val(),
		birth : $.trim($("#birth").val()),
		gender: $("input[name='gender']:checked").val(),
		email : $.trim($("#email").val()),
		height: $("#height").val() ? parseInt($("#height").val(),10) : 0,
		weight: $("#weight").val() ? parseInt($("#weight").val(),10) : 0,
		blodGb: $("#blodGb").val() ? parseInt($("#blodGb").val(),10) : 0
	};
	if (!dto.userNm) { alert("이름을 입력하세요."); return; }
	if (!dto.phone)  { alert("전화번호를 입력하세요."); return; }
	if (!dto.userPw || dto.userPw.length < 4) { alert("비밀번호는 4자 이상."); return; }
	if ($("#userPw").val() !== $("#userPw2").val()) { alert("비밀번호 확인이 일치하지 않습니다."); return; }
	if (!/^\d{8}$/.test(dto.birth)) { alert("생년월일은 YYYYMMDD 8자리"); return; }
	if (!dto.gender) { alert("성별을 선택하세요."); return; }

	$.ajax({
		type: "post",
		url:  CommonUtil.getContextPath() + "/patient/registerAct.do",
		data: JSON.stringify(dto),
		contentType: "application/json",
		dataType: "json",
		success: function(data){
			alert(data.Message || (data.IsSucceed ? "회원가입 완료" : "회원가입 실패"));
			if (data.IsSucceed) {
				location.href = CommonUtil.getContextPath() + "/patient/login.do";
			}
		},
		error: function(){ alert("회원가입 요청 중 오류"); }
	});
}
</script>
</head>
<body>
  <div id="login" class="container">
    <div class="set-pass-box">
      <div class="set-pass-wrap" style="max-width:520px;">
        <h3>사용자 회원가입</h3>
        <div class="pass-box w-100">
          <label class="mt-2">이름</label>
          <input type="text" id="userNm" class="form-control" placeholder="이름">

          <label class="mt-2">전화번호 (-없이 숫자만)</label>
          <input type="text" id="phone" class="form-control" placeholder="01012345678" maxlength="11" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');">

          <label class="mt-2">비밀번호 (4자 이상)</label>
          <input type="password" id="userPw" class="form-control" placeholder="비밀번호">

          <label class="mt-2">비밀번호 확인</label>
          <input type="password" id="userPw2" class="form-control" placeholder="비밀번호 확인">

          <label class="mt-2">생년월일 (YYYYMMDD 8자리)</label>
          <input type="text" id="birth" class="form-control" placeholder="19900101" maxlength="8" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');">

          <label class="mt-2">성별</label>
          <div>
            <label class="me-3"><input type="radio" name="gender" value="M"> 남자</label>
            <label><input type="radio" name="gender" value="F"> 여자</label>
          </div>

          <label class="mt-2">이메일 (선택)</label>
          <input type="text" id="email" class="form-control" placeholder="example@example.com">

          <label class="mt-2">신장(cm) / 체중(kg) / 당뇨분류코드</label>
          <div class="d-flex" style="gap:8px;">
            <input type="text" id="height" class="form-control" placeholder="신장" maxlength="3" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');">
            <input type="text" id="weight" class="form-control" placeholder="체중" maxlength="3" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');">
            <input type="text" id="blodGb" class="form-control" placeholder="코드" maxlength="2" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');">
          </div>
        </div>

        <div class="set-btn-box w-100">
          <button type="button" class="btn btn-outline-dark" onclick="location.href='/patient/login.do';">취소</button>
          <button type="button" class="btn btn-primary" onclick="registerProc();">가입</button>
        </div>
      </div>
    </div>
  </div>
</body>
</html>
