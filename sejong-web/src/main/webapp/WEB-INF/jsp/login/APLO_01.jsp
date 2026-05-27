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
<style>
  /* ───────────────────────────────────────────────────────
     로그인 박스 — 모든 컨텐츠가 좌측 흰박스 안에 들어오게 강하게 압축
  ─────────────────────────────────────────────────────── */
  #login .login-box {
    display: flex !important;
    align-items: stretch !important;
  }
  #login .login-wrap {
    flex: 1 1 auto;
    display: flex;
    flex-direction: column;
    justify-content: center;       /* 컨텐츠를 박스 세로 중앙에 위치 */
    padding: 14px 24px !important; /* 좌우 32→24, 위아래 24→14 (약간 좁히고 압축) */
    box-sizing: border-box;
    overflow: hidden;               /* 박스 밖으로 절대 안 나가게 */
  }
  #login .img-wrap {
    flex: 0 0 auto;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  #login .img-wrap img {
    max-height: 100%;
    height: auto;
  }

  /* 모든 컨텐츠 강하게 압축 */
  #login .login-wrap h1 {
    font-size: 16px !important;
    line-height: 1.25;
    margin: 0 0 8px 0;
    color: #1976d2;
    font-weight: 700;
    text-align: center;
  }
  #login .login-wrap .mb-3 {         /* "처음 방문하셨나요?" 배너 */
    margin-bottom: 8px !important;
    padding: 5px !important;
    font-size: 13px;
  }
  #login .login-wrap .id-box {
    margin-top: 2px;
  }
  #login .login-wrap .id-box h2 {    /* "로그인" 소제목 */
    font-size: 14px !important;
    margin: 4px 0 6px 0;
  }
  #login .login-wrap input.form-control {
    padding-top: 6px;
    padding-bottom: 6px;
    font-size: 13px;
    margin-top: 4px !important;
  }
  #login .login-wrap .id-box > div[style*="font-size:12px"] {  /* 안내문구 (※ 당구장) */
    margin-top: 6px !important;
    font-size: 13px !important;
    line-height: 1.4;
  }
  #login .login-wrap .form-check {   /* 아이디 저장 — 살짝 아래로 */
    margin-top: 14px !important;
    margin-bottom: 2px;
    font-size: 13px;
  }
  #login .login-wrap .btn-primary.btn-lg {  /* 로그인 버튼 — 위로 당김 */
    padding-top: 7px;
    padding-bottom: 7px;
    margin-top: 0 !important;
    font-size: 14px;
  }
  #login .login-wrap .set-btn-box {  /* 비밀번호 초기화/변경 — 위로 당김 */
    margin-top: 3px;
  }
  #login .login-wrap .set-btn-box .btn {
    padding-top: 4px;
    padding-bottom: 4px;
    font-size: 12px;
  }
</style>
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
	var id = $.trim($("#userId").val());
	var pw = $("#userPw").val();
	if (!id) { alert("아이디 또는 전화번호를 입력하세요."); $("#userId").focus(); return; }
	if (!pw) { alert("비밀번호를 입력하세요."); $("#userPw").focus(); return; }

	// 통합 로그인: 의료진(T_ADMIN_MST) 우선 → 환자(T_USER_TRAN) 자동 분기
	$.ajax({
		type: "post",
		url:  CommonUtil.getContextPath() + "/user/unifiedLoginAct.do",
		data: JSON.stringify({ idOrPhone: id, password: pw }),
		contentType: "application/json",
		dataType: "json",
		success: function(data) {
			if (!data.IsSucceed) {
				alert(data.Message || "로그인 실패");
				$("#userId").focus();
				return;
			}
			// ID 저장 (성공 후에만)
			try {
				if ($("#save_id").is(":checked")) {
					localStorage.setItem(SAVED_USER_ID_KEY, id);
				} else {
					localStorage.removeItem(SAVED_USER_ID_KEY);
				}
			} catch (e) {}
			// /main.do 가 세션 q_admin_yn 으로 환자/의사 화면 자동 분기
			location.href = CommonUtil.getContextPath() + "/main.do";
		},
		error: function(){ alert("로그인 요청 중 오류가 발생했습니다."); }
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

        <!-- 사용자 회원가입 안내 (상단 강조) -->
        <div class="w-100 mb-3 p-2" style="background:#eef5ff; border:1px solid #cfe2ff; border-radius:6px; text-align:center;">
          <span style="color:#333; font-size:14px;">처음 방문하셨나요?</span>
          <a href="/patient/register.do" class="btn btn-link p-0 ms-2" style="font-weight:700; font-size:15px;">사용자 회원가입 →</a>
        </div>

        <div class="id-box w-100">
          <h2>로그인</h2>
          <input name="userId" class="form-control" type="text" id="userId" placeholder="아이디 또는 전화번호" aria-label="아이디 또는 전화번호">
          <input type="password" class="form-control mt-3" id="userPw" placeholder="비밀번호" onKeypress="hitEnterKey(event);">
          <div class="mt-2" style="color:#666; font-size:12px; text-align:left;">
            ※ 의료진은 <b>아이디</b>, 사용자는 <b>전화번호</b>로 로그인하세요. 시스템이 자동으로 구분합니다.
          </div>
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
