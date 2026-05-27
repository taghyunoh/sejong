<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<link href="/bootstrap/css/bootstrap.css" rel="stylesheet">
<link href="/asset/css/common.css" rel="stylesheet">
<title>${sessionScope.userNm}님 — 사용자 대시보드</title>
<!-- 필수 스크립트: jQuery + commonUtil (CommonUtil.getContextPath 사용) -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<script src="/bootstrap/js/bootstrap.bundle.js"></script>
<script src="/asset/js/commonUtil.js"></script>
<script src="https://cdn.jsdelivr.net/npm/echarts/dist/echarts.min.js"></script>
<script>
  // 자체완결 페이지(raw/*) 라 헤더 tiles 가 안 붙으므로 contextPath 를 여기서 세팅
  sessionStorage.setItem("contextPath", '<c:out value="${pageContext.request.contextPath}"/>');
</script>
<style>
  body { background:#f8f9fa; }
  .card-tile { background:#fff; border-radius:8px; padding:16px; margin-bottom:12px; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
  .card-tile h5 { margin-bottom:12px; color:#0d6efd; }
  .blood-num { font-size:48px; font-weight:700; }
  .row-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:12px; }
  .btn-link-tile { background:#0d6efd; color:#fff; text-align:center; padding:18px; border-radius:8px; cursor:pointer; }
  .btn-link-tile:hover { background:#0b5ed7; }

  /* i-Sens 안내 모달 — native alert 의 스크롤 문제를 피하기 위한 커스텀 다이얼로그 */
  .isens-guide-backdrop {
    position: fixed; top:0; left:0; right:0; bottom:0;
    background: rgba(0,0,0,0.5);
    z-index: 9999;
    display: none;
    align-items: center; justify-content: center;
  }
  .isens-guide-box {
    background:#fff; border-radius:12px;
    padding: 28px 32px;
    max-width: 560px; width: 92%;
    box-shadow: 0 10px 30px rgba(0,0,0,0.25);
  }
  .isens-guide-box h4 { margin:0 0 14px 0; color:#0d6efd; font-weight:700; font-size:20px; }
  .isens-guide-box p  { margin:0 0 10px 0; font-size:15px; line-height:1.5; color:#333; }
  .isens-guide-box ol { margin:8px 0 14px 22px; padding:0; font-size:15px; line-height:1.8; color:#222; }
  .isens-guide-box ol li { margin-bottom:2px; }
  .isens-guide-note { font-size:14px; color:#666; margin-top:10px; }
  .isens-guide-actions { text-align:right; margin-top:18px; }
  .isens-guide-btn {
    background:#0d6efd; color:#fff; border:0;
    padding:10px 28px; border-radius:8px;
    font-size:15px; cursor:pointer;
  }
  .isens-guide-btn:hover { background:#0b5ed7; }
</style>
<script type="text/javaScript">
var userUuid = "${sessionScope.userUuid}";
var userNm   = "${sessionScope.userNm}";

$(function(){
	// 페이지 진입 시: 토큰 확인
	//  · 토큰 있음 → 자동 동기화(조용히) → 차트/평균 갱신
	//  · 토큰 없음 → (세션당 1회) i-Sens OAuth 자동 redirect (sejong_app과 동일 동작)
	//                · ?code= 가 붙어 돌아온 경우엔 콜백 페이지(/patient/isensCallback.do) 가 처리하므로 스킵
	//                · sessionStorage 플래그로 거부 후 무한루프 방지
	var urlParams = new URLSearchParams(window.location.search);
	loadTokenStatus(function(hasToken){
		if (hasToken) {
			syncMyBlood(true);   // ← 자동 1회 호출 (alert/confirm 없음)
			return;
		}
		// 토큰 없음 — OAuth 콜백으로 돌아온 경우엔 별도 처리 안 함
		if (urlParams.get('code') != null) {
			loadTodayBlood();
			drawChart();
			return;
		}
		// 세션당 1회만 자동 redirect (사용자가 거부 시 다음부턴 버튼만 노출)
		if (!sessionStorage.getItem("isensAskShown")) {
			sessionStorage.setItem("isensAskShown", "1");
			showIsensGuide(function(){ connectISens(); });
			return;
		}
		// 두 번째 진입부터는 빈 화면 + 연동 버튼만 노출
		loadTodayBlood();
		drawChart();
	});
});

function loadTokenStatus(cb){
	$.ajax({
		url: CommonUtil.getContextPath() + "/tokenYn.do",
		type:"post",
		dataType:"json",
		success:function(r){
			var hasToken = !!(r && r.IsSucceed);
			if (hasToken) {
				$("#tokenStatus").text("✓ i-Sens 연동됨").removeClass("text-danger").addClass("text-success");
				$("#btnConnect").hide();
				$("#btnSync").show();
			} else {
				$("#tokenStatus").text("✗ i-Sens 미연동").removeClass("text-success").addClass("text-danger");
				$("#btnConnect").show();
				$("#btnSync").hide();
			}
			if (typeof cb === 'function') cb(hasToken);
		},
		error: function(){
			if (typeof cb === 'function') cb(false);
		}
	});
}

function connectISens(){
	var redirectUri = window.location.origin + CommonUtil.getContextPath() + "/patient/isensCallback.do";
	$.ajax({
		url: CommonUtil.getContextPath() + "/getAuth.do",
		type:"post",
		data: JSON.stringify({ redirect_uri: redirectUri }),
		contentType:"application/json",
		dataType:"json",
		success:function(r){
			if (r && r.redirectUrl) {
				window.location.href = r.redirectUrl;
			} else {
				alert("i-Sens 인증 URL 생성 실패");
			}
		}
	});
}

function syncMyBlood(silent){
	// silent=true 면 confirm/alert 생략 (페이지 진입 시 자동 호출용)
	if (!silent && !confirm("내 혈당 데이터를 i-Sens에서 가져올까요?")) return;
	$("#syncMsg").text("동기화 중...").show();
	$.ajax({
		url: CommonUtil.getContextPath() + "/syncMyBlood.do",
		type:"post",
		dataType:"json",
		success:function(r){
			if (silent) {
				// 자동 호출: 결과를 상태 영역에만 표시
				$("#syncMsg").text(r && r.IsSucceed
					? "최근 동기화: " + (r.Message || "완료")
					: "자동 동기화 실패: " + (r && r.Message ? r.Message : "")
				);
			} else {
				$("#syncMsg").hide();
				alert(r.Message || (r.IsSucceed ? "동기화 완료" : "동기화 실패"));
			}
			// 성공/실패 무관하게 DB의 최신 상태로 화면 갱신
			loadTodayBlood();
			drawChart();
		},
		error: function(){
			$("#syncMsg").text("동기화 요청 오류").css("color","#dc3545");
			loadTodayBlood();
			drawChart();
		}
	});
}

function loadTodayBlood(){
	$.ajax({
		url: CommonUtil.getContextPath() + "/getTodayBlood.do",
		type:"post",
		dataType:"json",
		success:function(r){
			if (r && r.IsSucceed && r.Data && r.Data.length > 0) {
				$("#nowBlood").text(r.Data[0].UPT_VALUE + " mg/dL");
				$("#nowBloodDtm").text(formatTime(r.Data[0].CGM_DTM));
			} else {
				$("#nowBlood").text("-");
				$("#nowBloodDtm").text("데이터 없음");
			}
		}
	});
	$.ajax({
		url: CommonUtil.getContextPath() + "/getTodayBlodAvg.do",
		type:"post",
		dataType:"json",
		success:function(r){
			if (r && r.IsSucceed && r.Data) {
				$("#fastingBlood").text(Math.round(r.Data.fastBlod) || "-");
				$("#mealBlood").text(Math.round(r.Data.mealBlod) || "-");
			}
		}
	});
}

function drawChart(){
	var end = formatDate(new Date());
	var start = formatDate(new Date(Date.now() - 24*60*60*1000));
	$.ajax({
		url: CommonUtil.getContextPath() + "/getBloodChartData.do",
		type:"post",
		data: JSON.stringify({ start: start, end: end, userId: userUuid }),
		contentType:"application/json",
		dataType:"json",
		success:function(rows){
			if (!Array.isArray(rows) || rows.length === 0) {
				$("#lineChart").html('<div class="text-center text-muted p-3">최근 24시간 데이터 없음</div>');
				return;
			}
			var xs = rows.map(function(r){ return (r.DTM||"").substring(11,16); });
			var ys = rows.map(function(r){ return parseInt(r.UPT,10); });
			var chart = echarts.init(document.getElementById('lineChart'));
			chart.setOption({
				xAxis: { type:'category', data:xs },
				yAxis: { type:'value', min:0, max:300 },
				series: [{ type:'line', data:ys, smooth:true, areaStyle:{} }]
			});
		}
	});
}

function formatDate(d){
	var z=function(n){return (n<10?'0':'')+n;};
	return d.getFullYear()+'-'+z(d.getMonth()+1)+'-'+z(d.getDate())+'T'+z(d.getHours())+':'+z(d.getMinutes())+':'+z(d.getSeconds());
}
function formatTime(s){ return s ? s.replace('T',' ').substring(0,16) : ''; }

function logout(){
	if (!confirm("로그아웃 하시겠습니까?")) return;
	// 단순 GET: 서버에서 session.invalidate() 후 /login.do 로 forward
	location.href = (sessionStorage.getItem("contextPath")||"") + "/user/loginOutAct.do";
}
function goFood(){ location.href = CommonUtil.getContextPath() + "/patient/food.do"; }
function goExer(){ location.href = CommonUtil.getContextPath() + "/patient/exer.do"; }

// 케어센스 안내 모달 — native alert 의 스크롤 문제 회피용
function showIsensGuide(onConfirm){
	var $bd = $("#isensGuideBackdrop");
	$bd.css("display","flex");
	$("#isensGuideOk").off("click").one("click", function(){
		$bd.css("display","none");
		if (typeof onConfirm === "function") onConfirm();
	});
}
</script>
</head>
<body>
<div class="container py-4" style="max-width:960px;">
	<div class="d-flex justify-content-between align-items-center mb-3">
		<h3>${sessionScope.userNm}님 환영합니다</h3>
		<div>
			<span id="tokenStatus" class="me-3">…</span>
			<button id="btnConnect" class="btn btn-primary btn-sm" onclick="connectISens();" style="display:none;">i-Sens 연동</button>
			<button id="btnSync"    class="btn btn-success btn-sm" onclick="syncMyBlood(false);" style="display:none;">혈당 가져오기</button>
			<button class="btn btn-outline-secondary btn-sm ms-2" onclick="logout();">로그아웃</button>
		</div>
	</div>
	<div id="syncMsg" class="text-muted small mb-2" style="display:none;"></div>

	<div class="row-grid">
		<div class="card-tile">
			<h5>최근 혈당</h5>
			<div class="blood-num" id="nowBlood">-</div>
			<div class="text-muted" id="nowBloodDtm">-</div>
		</div>
		<div class="card-tile">
			<h5>오늘 공복 평균</h5>
			<div class="blood-num" id="fastingBlood">-</div>
			<div class="text-muted">mg/dL</div>
		</div>
		<div class="card-tile">
			<h5>오늘 식후 평균</h5>
			<div class="blood-num" id="mealBlood">-</div>
			<div class="text-muted">mg/dL</div>
		</div>
	</div>

	<div class="card-tile">
		<h5>최근 24시간 혈당 추이</h5>
		<div id="lineChart" style="height:280px;"></div>
	</div>

	<div class="row-grid">
		<div class="btn-link-tile" onclick="goFood();">🍱 식사 기록</div>
		<div class="btn-link-tile" onclick="goExer();">🏃 운동 기록</div>
		<div class="btn-link-tile" onclick="syncMyBlood(false);">🔄 혈당 가져오기</div>
	</div>
</div>

<!-- 케어센스 안내 모달 (native alert 대체) -->
<div id="isensGuideBackdrop" class="isens-guide-backdrop">
	<div class="isens-guide-box">
		<h4>케어센스 로그인 안내</h4>
		<p>혈당을 보려면 케어센스 로그인이 한 번 필요합니다.</p>
		<p style="color:#555;">처음에만 아래 순서대로 해 주세요.</p>
		<ol>
			<li>스마트폰에 "케어센스 에어" 앱 설치</li>
			<li>앱에서 회원가입 <span style="color:#888;font-size:13px;">(카카오·구글·이메일 중 편한 방법)</span></li>
			<li>앱에서 혈당기 등록</li>
			<li>다음 화면에서 가입한 방법으로 로그인</li>
		</ol>
		<p class="isens-guide-note">다음부터는 자동으로 혈당이 보입니다.</p>
		<p class="isens-guide-note">잘 모르시면 가족이나 병원에 문의해 주세요.</p>
		<div class="isens-guide-actions">
			<button id="isensGuideOk" type="button" class="isens-guide-btn">확인</button>
		</div>
	</div>
</div>
</body>
</html>
