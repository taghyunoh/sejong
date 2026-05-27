<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>  
<%@ page import = "java.util.*" %>
<!DOCTYPE html>
<html>
 <head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" /> 
<!-- Bootstrap CSS -->
<link href="/bootstrap/css/bootstrap.css" rel="stylesheet">
<link href="/asset/css/common.css" rel="stylesheet"> 
<link href="/css/login.css" rel="stylesheet">
<!-- 부트스트랩 js -->
<script src="/bootstrap/js/bootstrap.bundle.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<script type="text/javascript" src='/js/jqgrid_common.js'></script> 
<script type="text/javascript" src='/js/common.js'></script> 
<title>로그인</title>
<script type="text/javaScript">
/*  Main Grid  *//*서브그리드 필요*/

// ID 저장 키 (localStorage)
var SAVED_USER_ID_KEY = "sejong_saved_user_id";

$(document).ready(function(){
	// 저장된 ID 복원
	try {
		var savedId = localStorage.getItem(SAVED_USER_ID_KEY);
		if (savedId) {
			$("#userId").val(savedId);
			$("#save_id").prop("checked", true);
			$("#userPw").focus();   // ID 자동입력 → 비밀번호 포커스
		} else {
			$("#userId").focus();
		}
	} catch (e) {
		// localStorage 미지원/차단 시 무시
		$("#userId").focus();
	}
});

// ID 저장 체크박스 처리 (체크 해제 즉시 저장값 삭제)
function fnSaveIdToggle(){
	try {
		if (!$("#save_id").is(":checked")) {
			localStorage.removeItem(SAVED_USER_ID_KEY);
		}
	} catch (e) {}
}

function loginproc2(){

	if( $("#userId").val() == ""){
		alert("사용자 ID를 입력하세요.!");
		$("#userId").focus();
		return;
	}else if( $("#userPw").val() == "") {
		alert("비밀번호를 입력하세요.!");
		$("#userPw").focus();
		return;
	}
	//location.href="/com/main.do" ;

	$.ajax( {
		type : "post",
	//	CommonUtil.callAjax(CommonUtil.getContextPath() + "/user/loginAct.do", "POST", formData, function(response) {
		url : CommonUtil.getContextPath() + "/user/loginAct.do",
		data : {userId : $("#userId").val(),
			    userPw : $("#userPw").val()},
		dataType : "json",
		success : function(data) {

			if(data.error_code != "00000"){
				if(data.error_code == "20000"){
					alert(data.error_msg);
					$("#userId").focus();
				}else if(data.error_code == "10000"){   //비밀번호 초기화
					alert(data.error_msg);
					fnPwdChange();
				}
				else{
					alert(data.error_msg);
					$("#userId").focus();
				}
			}else{
				// ID 저장 처리 (로그인 성공 후에만 저장 → 잘못된 ID 입력은 보존하지 않음)
				try {
					if ($("#save_id").is(":checked")) {
						localStorage.setItem(SAVED_USER_ID_KEY, $("#userId").val());
					} else {
						localStorage.removeItem(SAVED_USER_ID_KEY);
					}
				} catch (e) {}
				//메인페이지로 이동
				location.href= CommonUtil.getContextPath() + "/main.do"
			}
		}
	//  )};
	});

}
function logout(){
	$.ajax( {
		type : "post",
		url : CommonUtil.getContextPath() + "/com/loginOut.do",
		dataType : "json",
		success : function(data) {
		}
		})
		location.reload();		
}

function hitEnterKey(e){
	
	  if(e.keyCode == 13){ 
		loginproc2();
	  }else{
	   	e.keyCode == 0;
	  	return;
	  }
}  

function fnPwdChange(){ 
	
	var popupwidth = '550';
	var popupheight = '400';  
	var url = CommonUtil.getContextPath() + "/popup/pwdchg.do";   
	 		
	var LeftPosition = (screen.width-popupwidth)/2;
	var TopPosition  = (screen.height-popupheight)/2; 
	var oPopup = window.open(url,"비밀번호변경","width="+popupwidth+",height="+popupheight+",top="+TopPosition+",left="+LeftPosition+", scrollbars=no");
	if(oPopup){oPopup.focus();}
	   
}

//비밀번호 초기화
function fnPwdClear(){ 

	var popupwidth = '550';
	var popupheight = '400'; 
	var url = "";  

	url = CommonUtil.getContextPath() + "/popup/pwdclear.do";
	 		
 	var LeftPosition = (screen.width-popupwidth)/2;
	var TopPosition  = (screen.height-popupheight)/2;

	var oPopup = window.open(url,"비밀번호변경","width="+popupwidth+",height="+popupheight+",top="+TopPosition+",left="+LeftPosition+", scrollbars=no");
	if(oPopup){oPopup.focus();}
   
}

</script>    
 
</head>

<body> 
  <div id="login" class="container">

    <div class="login-box">
      <div class="login-wrap">
        <h1>AI 기반 디지털 헬스케어 서비스 플랫폼 실증</h1>
        <div class="id-box w-100">
          <h2>병원 관리자</h2>
          <input name="userId" class="form-control" type="text" id="userId" placeholder="사용자ID" aria-label="사용자ID">
          <input type="password" class="form-control mt-3" id="userPw" placeholder="비밀번호" onKeypress="hitEnterKey(event);">
        </div>

        <!-- ID 저장 체크박스 -->
        <div class="form-check mt-2 w-100" style="text-align:left;">
          <input class="form-check-input" type="checkbox" id="save_id" onchange="fnSaveIdToggle();">
          <label class="form-check-label" for="save_id">아이디 저장</label>
        </div>

        <button type="submit" class="btn btn-primary btn-lg w-100 mt-2" onclick="javascript:loginproc2();">로그인</button>
       
        <div class="set-btn-box  w-100">
          	<button type="button" class="btn btn-outline-dark" onclick="javascript:fnPwdClear();">비밀번호 초기화</button> 
          	<button type="button" class="btn btn-outline-dark" onclick="javascript:fnPwdChange();">비밀번호 변경</button> 
        </div>
      </div>
      <div class="img-wrap">
        <img src="/asset/img/login_bg_02.png" alt="">
      </div>
    </div>
  </div>
<jsp:include page="footer.jsp"></jsp:include>
  </body>
</html>
