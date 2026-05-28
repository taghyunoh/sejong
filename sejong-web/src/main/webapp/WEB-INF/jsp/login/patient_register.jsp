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
<style>
  /* 약관 동의 영역 — SEJONG_APP login.jsp 의 agreeList 스타일을 단순화하여 이식 */
  .agree-box { border:1px solid #dee2e6; border-radius:6px; padding:12px 14px; margin-top:10px; background:#f8f9fa; }
  .agree-box h6 { margin:0 0 8px 0; font-size:14px; color:#495057; font-weight:600; }
  .agree-item { display:flex; align-items:center; justify-content:space-between; padding:6px 0; border-bottom:1px dashed #e9ecef; }
  .agree-item:last-child { border-bottom:0; }
  .agree-item .agree-link { color:#0d6efd; text-decoration:underline; cursor:pointer; font-size:15px; flex:1; }
  .agree-item .agree-link .req { color:#dc3545; margin-right:4px; font-weight:700; font-size:15px; }
  .agree-item input[type=checkbox] { width:18px; height:18px; margin:0 0 0 8px; }
  .agree-all { padding:8px 0; margin-bottom:6px; border-bottom:1px solid #ced4da; }
  .agree-all label { font-weight:700; color:#212529; cursor:pointer; }
  .sign-conts-box { display:none; margin-top:8px; padding:14px 18px; max-height:360px; overflow-y:auto; background:#fff; border:1px solid #ced4da; border-radius:4px; font-size:13px; line-height:1.65; white-space:pre-wrap; color:#333; text-align:left; }
  .sign-conts-box.open { display:block; }
  /* 약관 본문 영역의 빈 상태(준비중) placeholder — 가운데 정렬해서 안내 느낌 */
  .sign-conts-placeholder { text-align:center; color:#888; padding:18px 8px; font-size:12px; line-height:1.6; }
</style>
<script type="text/javaScript">
// 현재 펼쳐진 약관 (토글용)
var __openedTermsGb = "";

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

	// 약관 동의 검증 (3개 모두 필수) — SEJONG_APP login.jsp goJoin3() 와 동일
	if (!$("#chk_01").is(":checked")) { alert("서비스 이용약관에 동의해주세요."); return; }
	if (!$("#chk_02").is(":checked")) { alert("개인정보 수집·이용동의 항목에 동의해주세요."); return; }
	if (!$("#chk_03").is(":checked")) { alert("고유식별정보 처리동의 항목에 동의해주세요."); return; }

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

/**
 * 약관 본문 조회/토글 — SEJONG_APP 의 /getSignList.do 와 동일 시그니처.
 * 같은 termsGb 를 다시 클릭하면 닫힘 (setting.jsp 의 토글 패턴 참고).
 *
 * termsGb: 1 = 개인정보 수집·이용동의 / 2 = 고유식별정보 처리동의 / 3 = 서비스 이용약관
 */
function getSignList(termsGb) {
	var $box = $("#signContsBox");
	// 토글: 같은 약관을 다시 클릭하면 닫기
	if (__openedTermsGb === String(termsGb)) {
		$box.removeClass("open").empty();
		__openedTermsGb = "";
		return;
	}
	$.ajax({
		url:  CommonUtil.getContextPath() + "/getSignList.do",
		type: "post",
		data: JSON.stringify({ termsGb: termsGb }),
		contentType: "application/json",
		dataType: "json",
		success: function(result){
			// IsSucceed=false 도 빈 목록과 동일하게 "준비중" 표시 (T_SIGN_MST 미설정 케이스)
			var arr = (result && result.Data) ? result.Data : [];
			renderSignList(arr);
			__openedTermsGb = String(termsGb);
		},
		error: function(){
			// 네트워크/서버 오류여도 폼은 그대로 — "준비중" 안내만 표시
			renderSignList([]);
			__openedTermsGb = String(termsGb);
		}
	});
}

function renderSignList(data) {
	var $box = $("#signContsBox");
	$box.empty();
	if (!data || data.length === 0) {
		// T_SIGN_MST 에 아직 본문이 들어있지 않은 초기 상태 안내 — 데이터가 등록되면 자동으로 표시됨.
		// placeholder 는 가운데 정렬(.sign-conts-placeholder), 본문이 들어오면 좌측 정렬.
		$box.html('<div class="sign-conts-placeholder">약관 본문이 준비 중입니다.<br>운영자 등록 후 표시됩니다.</div>').addClass("open");
		return;
	}
	// 여러 행을 단순히 줄바꿈으로 연결 (SEJONG_APP 동일 — termsConts 가 본문 텍스트)
	var html = "";
	for (var i = 0; i < data.length; i++) {
		var conts = data[i].termsConts || "";
		html += $("<div/>").text(conts).html() + "\n\n";
	}
	$box.html(html).addClass("open");
}

// "전체 동의" 체크박스 → 3개 일괄 토글
function toggleAllAgree(el){
	var checked = !!el.checked;
	$("#chk_01,#chk_02,#chk_03").prop("checked", checked);
}
// 개별 변경 시 전체동의 체크 상태 동기화
$(function(){
	$("#chk_01,#chk_02,#chk_03").on("change", function(){
		var all = $("#chk_01").is(":checked") && $("#chk_02").is(":checked") && $("#chk_03").is(":checked");
		$("#chk_all").prop("checked", all);
	});
});

</script>
</head>
<body>
  <div id="login" class="container">
    <!--
      login.css 의 #login .set-pass-box { width:400px } 가 폭을 400 으로 고정하고 있어
      회원가입 화면처럼 항목 많은 폼은 좁아짐. 이 페이지에서만 inline 으로 확장.
      향후 T_SIGN_MST 약관 본문이 화면에 표시되는 것을 감안해서 넓게 잡음.
      max-width:96vw 는 모바일/좁은 창에서 화면 넘침 방지.
    -->
    <div class="set-pass-box" style="width:920px;max-width:96vw;padding:30px 48px;">
      <div class="set-pass-wrap" style="max-width:none;width:100%;">
        <h3>사용자 회원가입</h3>
        <div class="pass-box w-100">
          <!--
            상단 입력 영역 — 2개씩 행 배치 (Bootstrap row/col).
            라벨은 각 입력 위에 그대로. 이메일·신장 라인은 입력 폭이 커서 단독 행 유지.
          -->
          <div class="row g-3">
            <div class="col-6">
              <label class="mt-2">이름</label>
              <input type="text" id="userNm" class="form-control" placeholder="이름">
            </div>
            <div class="col-6">
              <label class="mt-2">전화번호 (-없이 숫자만)</label>
              <input type="text" id="phone" class="form-control" placeholder="01012345678" maxlength="11" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');">
            </div>

            <div class="col-6">
              <label class="mt-2">비밀번호 (4자 이상)</label>
              <input type="password" id="userPw" class="form-control" placeholder="비밀번호">
            </div>
            <div class="col-6">
              <label class="mt-2">비밀번호 확인</label>
              <input type="password" id="userPw2" class="form-control" placeholder="비밀번호 확인">
            </div>

            <div class="col-6">
              <label class="mt-2">생년월일 (YYYYMMDD 8자리)</label>
              <input type="text" id="birth" class="form-control" placeholder="19900101" maxlength="8" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');">
            </div>
            <div class="col-6">
              <label class="mt-2">성별</label>
              <div style="padding-top:7px;">
                <label class="me-3"><input type="radio" name="gender" value="M"> 남자</label>
                <label><input type="radio" name="gender" value="F"> 여자</label>
              </div>
            </div>

            <div class="col-12">
              <label class="mt-2">이메일 (선택)</label>
              <input type="text" id="email" class="form-control" placeholder="example@example.com">
            </div>

            <div class="col-12">
              <label class="mt-2">신장(cm) / 체중(kg) / 당뇨분류코드</label>
              <div class="d-flex" style="gap:8px;">
                <input type="text" id="height" class="form-control" placeholder="신장" maxlength="3" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');">
                <input type="text" id="weight" class="form-control" placeholder="체중" maxlength="3" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');">
                <input type="text" id="blodGb" class="form-control" placeholder="코드" maxlength="2" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');">
              </div>
            </div>
          </div>

          <!-- 약관 동의 — SEJONG_APP login.jsp 의 agreeList 와 동일 항목 (3개 모두 필수) -->
          <div class="agree-box">
            <h6>약관 동의</h6>
            <div class="agree-all">
              <label>
                <input type="checkbox" id="chk_all" onclick="toggleAllAgree(this);" style="width:18px;height:18px;vertical-align:middle;margin-right:6px;">
                전체 약관에 동의합니다.
              </label>
            </div>
            <div class="agree-item">
              <a class="agree-link" onclick="getSignList(3);"><span class="req">[필수]</span>서비스 이용약관 보기</a>
              <input type="checkbox" id="chk_01">
            </div>
            <div class="agree-item">
              <a class="agree-link" onclick="getSignList(1);"><span class="req">[필수]</span>개인정보 수집·이용동의 보기</a>
              <input type="checkbox" id="chk_02">
            </div>
            <div class="agree-item">
              <a class="agree-link" onclick="getSignList(2);"><span class="req">[필수]</span>고유식별정보 처리동의 보기</a>
              <input type="checkbox" id="chk_03">
            </div>
            <div id="signContsBox" class="sign-conts-box"></div>
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
