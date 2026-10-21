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
<script src="/asset/js/ui-message.js"></script>
<script src="/asset/js/blood_qa.js?v=<%= System.currentTimeMillis() %>"></script>
<script src="https://cdn.jsdelivr.net/npm/echarts/dist/echarts.min.js"></script>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
<script src="https://cdn.jsdelivr.net/npm/flatpickr" defer></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/ko.js" defer></script>
<%-- 모바일 접속 QR 생성용 (설정 모달에서만 사용 — defer 로 로드) --%>
<script src="https://cdn.jsdelivr.net/npm/qrcode-generator@1.4.4/qrcode.js" defer></script>
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
  .btn-row { display:flex; justify-content:center; gap:12px; flex-wrap:wrap; }
  .btn-row .btn-link-tile { width:210px; padding:14px; }

  /* i-Sens 안내 모달 — native alert 의 스크롤 문제를 피하기 위한 커스텀 다이얼로그 */
  /* Flatpickr 팝업 소형화 */
  .flatpickr-calendar { font-size:12px !important; width:266px !important; }
  .flatpickr-day { height:32px !important; line-height:32px !important; font-size:12px !important; }
  .flatpickr-months .flatpickr-month { height:34px !important; }
  .flatpickr-current-month { font-size:13px !important; padding-top:7px !important; }
  .flatpickr-weekday { font-size:11px !important; }
  /* Flatpickr 시간 picker */
  .flatpickr-time { height:44px !important; }
  .flatpickr-time input { font-size:20px !important; font-weight:600 !important; }
  .flatpickr-time .flatpickr-time-separator { font-size:20px !important; line-height:44px !important; }
  .numInputWrapper span { padding:0 2px !important; }
  /* 우측 평가/채팅 패널 */
  .chat-user { position:relative; background:#0d6efd; color:#fff; border-radius:14px 14px 0 14px; padding:9px 13px; align-self:flex-end; max-width:88%; font-size:15px; line-height:1.5; word-break:break-word; }
  .chat-bot  { position:relative; background:#fff; color:#222; border:1px solid #dee2e6; border-radius:14px 14px 14px 0; padding:9px 13px; align-self:flex-start; max-width:92%; font-size:15px; line-height:1.5; word-break:break-word; }
  /* 메시지 삭제 버튼 (× ) — 항상 보이되 흐리게, hover 시 진하게 (터치기기 대응) */
  .chat-del { position:absolute; top:-7px; right:-7px; width:20px; height:20px; line-height:18px; text-align:center; border:none; border-radius:50%; background:#dc3545; color:#fff; font-size:13px; cursor:pointer; padding:0; opacity:0.45; transition:opacity .15s; box-shadow:0 1px 2px rgba(0,0,0,0.3); }
  .chat-user:hover .chat-del, .chat-bot:hover .chat-del { opacity:1; }
  /* 상단 인사말 — 우측까지 꽉 채워 2줄로 표시 */
  .chat-intro { max-width:100% !important; align-self:stretch !important; font-size:13.5px !important; }

  /* 토스트·확인모달 스타일은 공통 ui-message.js 가 자동 주입 */
  .eval-row  { display:flex; justify-content:space-between; margin-bottom:5px; font-size:15px; }
  .qbtn      { font-size:13px; padding:3px 10px; border-radius:10px; cursor:pointer; border:1px solid #ccc; background:#fff; color:#555; }
  .qbtn:hover{ background:#f0f4ff; color:#0d6efd; border-color:#0d6efd; }

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

  /* ── 좌측 사이드바 메뉴 ── */
  .side-nav { position:fixed; left:0; top:0; bottom:0; width:200px; background:#fff; border-right:1px solid #e3e6ea;
    box-shadow:2px 0 8px rgba(0,0,0,0.05); z-index:1030; display:flex; flex-direction:column; padding:16px 0; }
  .side-nav .sn-brand { font-size:16px; font-weight:700; color:#0d6efd; padding:6px 20px 14px; border-bottom:1px solid #eef0f2;
    margin-bottom:8px; display:flex; align-items:center; gap:8px; }
  .side-nav .sn-item { display:flex; align-items:center; gap:11px; padding:11px 20px; font-size:14.5px; font-weight:500;
    color:#3c4043; cursor:pointer; border:0; background:none; width:100%; text-align:left; transition:all .12s;
    border-left:3px solid transparent; }
  .side-nav .sn-item:hover { background:#f1f6ff; color:#0d6efd; border-left-color:#0d6efd; }
  .side-nav .sn-item .sn-ico { font-size:18px; line-height:1; width:22px; text-align:center; }
  .side-nav .sn-sep { height:1px; background:#eef0f2; margin:8px 16px; }
  /* 사이드바 폭만큼 본문을 우측으로 밀어줌 */
  body.has-side-nav { padding-left:200px; }
  @media (max-width:1320px){ .side-nav { width:168px; } body.has-side-nav { padding-left:168px; } }
  @media (max-width:980px){ .side-nav { display:none; } body.has-side-nav { padding-left:0; } }
  /* FAQ 아코디언 */
  #faqList .accordion-button:not(.collapsed) { background:#eef4ff; color:#0d6efd; box-shadow:none; }
  #faqList .accordion-button:focus { box-shadow:none; }
  /* 뷰 전환용 — 이 파일에는 .hidden 정의가 원래 없었다(다른 JSP 클래스라 착각 주의) */
  .hidden { display:none !important; }
  /* AI 종합분석 화면 — 웹 비율 2단(좌=연속혈당 24시간 / 우=주간 분석), 980px 이하 세로 쌓기 */
  /* 좌우 전체 폭 사용 + 각 컬럼 독립 스크롤 [2026-10-21 요청 「좌우 공간 채우고 좌우 별도 동작」] */
  .ai-cols { display:flex; gap:24px; align-items:stretch; height:calc(100vh - 70px); width:100%; box-sizing:border-box; }
  /* [2026-10-21 「영역은 유지하고 내용만 좌우 조금 축소」] 컬럼 안쪽에 스크롤바 자리(scrollbar-gutter)와
     좌우 여백을 두어 차트 우측 라벨·버튼·단위 글자가 잘리지 않게. 카드 안쪽 여백도 한 단계 줄임 */
  .ai-cols > .ai-col { flex:1 1 0; min-width:0; overflow-y:auto; overflow-x:hidden; scrollbar-gutter:stable; padding:2px 14px 24px 6px; }
  .ai-cols .card-tile { padding:18px 20px; }
  #viewAi { overflow-x:hidden; }
  @media (max-width:980px){ .ai-cols { flex-direction:column; gap:12px; height:auto; } .ai-cols > .ai-col { overflow:visible; width:100%; } }
  /* 앱 FAHR_00 하단 문장 블록 — 파란 테두리 박스 안에 문장·회색 설명박스 (⚠ .line 은 공통 CSS 와 충돌해 .tl 사용) */
  .ai-trend { border:1.5px solid #4a6fb5; border-radius:10px; padding:12px 14px; margin-top:12px; background:#fff; }
  .ai-trend .tl  { font-size:17px; color:#555; padding:10px 2px; border-bottom:1px solid #f1f3f4; }
  .ai-trend .tl:last-child { border-bottom:0; }
  .ai-trend .st  { font-size:19px; font-weight:800; color:#111; }
  .ai-trend .box { background:#f5f5f5; border:1px solid #e0e0e0; border-radius:10px; padding:12px 18px; margin:8px 0 10px; font-size:17px; color:#000; line-height:1.45; }
  /* 앱 Blood_Consult 하단: 범례·구간·TOP3 그리드 */
  .ai-legend { display:flex; gap:14px; justify-content:center; font-size:12.5px; color:#444; margin-top:4px; }
  .ai-legend i { display:inline-block; width:12px; height:12px; border-radius:2px; vertical-align:-1px; margin-right:3px; }
  .ai-range4 { grid-template-columns:repeat(4,1fr); }
  .ai-line { font-size:15px; font-weight:700; color:#2d303f; padding:6px 0; }
  .ai-line span { font-weight:400; color:#666; }
  .ai-cardhead { display:flex; justify-content:space-between; align-items:center; margin-bottom:6px; }
  .ai-grid4 { display:grid; grid-template-columns:0.8fr 2fr 1fr 1.2fr; gap:8px; padding:8px 2px; border-bottom:1px dashed #eee; font-size:14px; color:#333; }
  .ai-grid4.head { font-weight:700; color:#345; border-bottom:1px solid #dde3ec; }
  /* 앱과 동일한 기준·단위 라벨 줄 */
  .ai-unit { display:flex; justify-content:space-between; font-size:12px; color:#8a98a8; margin:2px 2px 6px; }
  /* 앱과 동일한 구간 버튼(3/6/12/24시간)·주간 이동(◀▶) */
  .ai-range { display:grid; grid-template-columns:repeat(4,1fr); gap:8px; margin:4px 0 8px; }
  .ai-range button { border:1px solid #bcd3f5; background:#fff; color:#5b8def; border-radius:8px;
    padding:6px 0; font-weight:700; font-size:13.5px; cursor:pointer; }
  .ai-range button.on { background:#1f7aed; border-color:#1f7aed; color:#fff; }
  .ai-weeknav { display:flex; align-items:center; justify-content:center; gap:12px; margin:2px 0 8px; }
  .ai-weeknav button { border:1px solid #dbe3ec; background:#fff; border-radius:8px; padding:2px 10px;
    cursor:pointer; color:#345; font-size:13px; }
  .ai-weeknav span { font-weight:700; font-size:14.5px; color:#2d303f; }
  .ai-daynav { display:flex; align-items:center; justify-content:center; gap:14px; margin:6px 0 2px; }
  .ai-daynav button { border:0; background:none; cursor:pointer; color:#345; font-size:14px; padding:2px 8px; }
  .ai-daynav span { font-weight:700; font-size:15px; color:#2d303f; }
  /* 앱 연속혈당 상단 띠: 시작값 → 변화량 → 최근값 */
  .ai24-head { display:grid; grid-template-columns:1fr 1fr 1fr; align-items:center; text-align:center;
    background:#e9f2fb; border-radius:10px; padding:10px 6px; margin:2px 0 6px; }
  .ai24-head .v { font-size:34px; font-weight:800; color:#1f6f3a; line-height:1.1; }
  .ai24-head .v.light { color:#4fae7a; }
  .ai24-head .d { font-size:22px; font-weight:800; color:#2e7d32; }
  .ai24-head .t { font-size:12.5px; color:#4a5568; margin-top:2px; }
  /* [2026-10-21 요청] 모든 팝업 상단 바를 연한 하늘색으로 — 각 모달의 인라인 그라데이션을 공통으로 덮어쓴다 */
  .modal .modal-header { background:linear-gradient(135deg,#cfe5fa 0%,#b3d4f3 100%) !important; border-bottom:1px solid #9fc4e8 !important; }
  .modal .modal-header .modal-title { color:#1f3b63 !important; }
  .modal .modal-header .text-white-50, .modal .modal-header p { color:#4a6b8f !important; }
  .modal .modal-header .btn-close { filter:none !important; opacity:.6; }
  /* 앱 login.jsp 약관동의 목록(.agreeList) 대응 */
  .agree-list { border:1px solid #e5e8ec; border-radius:10px; overflow:hidden; }
  .agree-item { display:flex; justify-content:space-between; align-items:center; padding:13px 14px; border-bottom:1px solid #eef0f2; font-size:15px; background:#fff; }
  .agree-item:last-child { border-bottom:0; }
  .agree-item.all { font-weight:800; color:#2b6fff; background:#f5f8ff; border-bottom:2px solid #dde3ec; }
  .agree-item a { color:#2d303f; text-decoration:none; }
  .agree-item a:hover { color:#0d6efd; }
  .agree-item input[type=checkbox] { width:20px; height:20px; accent-color:#0d6efd; cursor:pointer; }
  .agree-right { display:flex; align-items:center; gap:10px; }
  /* 앱 가이드 머리띠 + 점선 박스 */
  .ai-sechead { margin:0 0 10px; padding:6px 10px; background:#8ca6db; color:#fff; border-radius:6px; font-size:14px; font-weight:800; }
  .ai-dashbox { border:1.5px dashed #4a6fb5; border-radius:8px; padding:10px 12px; background:#fff; }
  .ai-grid3 { display:grid; grid-template-columns:repeat(3,1fr); gap:8px; margin-bottom:10px; }
  .ai-cell { text-align:center; background:#f8fafc; border:1px solid #eef2f7; border-radius:10px; padding:8px 4px; }
  .ai-cell .lb { font-size:13px; color:#6b7280; }
  .ai-cell .v  { font-size:28px; font-weight:800; }
  .ai-cell .u  { font-size:11px; color:#9aa1ac; }
  /* 좌측 메뉴 활성(현재 화면) 표시 — 세부혈당그래프는 모달이 아니라 메뉴 우측 본문 전환 뷰 */
  .side-nav .sn-item.active { background:#eef4ff; color:#0d6efd; border-left-color:#0d6efd; font-weight:700; }
  #viewDetail .dv-topbar { display:flex; align-items:center; gap:10px; padding:10px 16px;
    background:#fff; border-bottom:1px solid #e3e6ea; position:sticky; top:0; z-index:5; }

  /* ── 모바일 대응 (전화번호 로그인 개별 화면 전용 — 의사·관리자 화면과 무관) ──
     980px 이하: 사이드바가 숨으므로 우측 평가·Q&A 패널을 본문 아래로 쌓고,
     상단 버튼은 줄바꿈 허용. 케어센스 설정은 ⚙ 설정 모달로 모바일에서도 조작 가능. */
  @media (max-width:980px){
    .layout-cols { flex-direction:column !important; }
    #rightPanel { width:100% !important; position:static !important; overflow:visible !important; }
    .topbar-actions { flex-wrap:wrap; justify-content:flex-end; row-gap:6px; }
    .blood-num { font-size:34px; }
  }
  @media (max-width:560px){
    .row-grid { gap:8px; }
    .card-tile { padding:12px; }
    .container-fluid.py-4 { padding-top:12px !important; }
    h3 { font-size:20px; }
  }
  /* 설정 모달 QR */
  #settingsQr { display:flex; justify-content:center; padding:8px 0 4px; }
  #settingsQr canvas { border:1px solid #e5e7eb; border-radius:8px; }
  #settingsQrUrl { word-break:break-all; text-align:center; color:#0d6efd; font-size:12.5px; }
</style>
<script type="text/javaScript">
var userUuid = "${sessionScope.userUuid}";
var userNm   = "${sessionScope.userNm}";


/* ui-message.js 미로딩(404 등) 대비 안전망 — 로드되면 이 블록은 자동 스킵 */
if (typeof window._toast !== 'function') { window._toast = function(m){ alert(String(m).replace(/<br\s*\/?>/gi,'\n').replace(/<[^>]*>/g,'')); }; }
if (typeof window._confirmBox !== 'function') { window._confirmBox = function(o){ o=o||{}; var m=String(o.msg||'진행할까요?').replace(/<br\s*\/?>/gi,'\n').replace(/<[^>]*>/g,''); if(confirm(m)){ if(o.onOk)o.onOk(); } else { if(o.onCancel)o.onCancel(); } }; }
if (typeof window._alertBox !== 'function') { window._alertBox = function(m,o){ o=o||{}; alert(String(m).replace(/<br\s*\/?>/gi,'\n').replace(/<[^>]*>/g,'')); if(o.onOk)o.onOk(); }; }

$(function(){
	// 페이지 진입 시: 토큰 확인
	//  · 토큰 있음 → 자동 동기화(조용히) → 차트/평균 갱신
	//  · 토큰 없음 → (세션당 1회) i-Sens OAuth 자동 redirect (sejong_app과 동일 동작)
	//                · ?code= 가 붙어 돌아온 경우엔 콜백 페이지(/patient/isensCallback.do) 가 처리하므로 스킵
	//                · sessionStorage 플래그로 거부 후 무한루프 방지
	var urlParams = new URLSearchParams(window.location.search);
	loadTokenStatus(function(hasToken){
		// ① DB에 있는 데이터로 화면 즉시 렌더 (i-Sens 외부 동기화를 기다리지 않음 → 빠르게 표시)
		loadTodayBlood();
		drawChart();
		loadDayStatus();   // [앱 홈 카드 대응] 최근 24시간 양호/주의

		// ② 토큰 있으면 i-Sens 동기화를 백그라운드로 실행 → 완료 시 내부에서 화면 재갱신
		if (hasToken) {
			syncMyBlood(true);   // alert/confirm 없음, 끝나면 loadTodayBlood+drawChart 재호출
			return;
		}
		// 토큰 없음 — OAuth 콜백으로 돌아온 경우엔 별도 처리 안 함 (이미 ①에서 렌더)
		if (urlParams.get('code') != null) {
			return;
		}
		// 세션당 1회만 자동 redirect (사용자가 거부 시 다음부턴 버튼만 노출)
		if (!sessionStorage.getItem("isensAskShown")) {
			sessionStorage.setItem("isensAskShown", "1");
			showIsensGuide(function(){ connectISens(); });
			return;
		}
		// 두 번째 진입부터는 ①에서 그린 화면 유지 + 연동 버튼만 노출
	});

	/* ── 자동 갱신: 5분마다 혈당 데이터 동기화 ── */
	function _autoRefresh(){
		loadTokenStatus(function(hasToken){
			if(hasToken) syncMyBlood(true);
			else { loadTodayBlood(); drawChart(); }
		});
	}
	// 5분 주기 자동 갱신
	setInterval(_autoRefresh, 5 * 60 * 1000);

	// 탭이 다시 활성화될 때 즉시 갱신 (다른 탭에 있다가 돌아올 때)
	$(document).on('visibilitychange', function(){
		if(document.visibilityState === 'visible'){
			_autoRefresh();
		}
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
				$("#tokenStatus, #tokenStatus2").text("✓ i-Sens 연동됨").removeClass("text-danger").addClass("text-success");
				$("#btnConnect, #btnConnect2").hide();
				$("#btnSync, #btnSync2").show();
			} else {
				$("#tokenStatus, #tokenStatus2").text("✗ i-Sens 미연동").removeClass("text-success").addClass("text-danger");
				$("#btnConnect, #btnConnect2").show();
				$("#btnSync, #btnSync2").hide();
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
				_toast("i-Sens 인증 URL 생성 실패", 'err');
			}
		}
	});
}

function syncMyBlood(silent){
	// silent=true 면 확인창 없이 바로 동기화 (페이지 진입 시 자동 호출용)
	if (silent) { _doSyncMyBlood(true); return; }
	_confirmBox({
		icon:'🔄', okText:'가져오기', okColor:'blue',
		msg:'내 혈당 데이터를 i-Sens에서 가져올까요?',
		onOk:function(){ _doSyncMyBlood(false); }
	});
}
function _doSyncMyBlood(silent){
	$("#syncMsg").text("동기화 중...").show();
	$.ajax({
		url: CommonUtil.getContextPath() + "/syncMyBlood.do",
		type:"post",
		dataType:"json",
		success:function(r){
			// 토큰 만료(재연동 필요) → 안내 + "케어센스 재로그인" 버튼 노출
			if (r && !r.IsSucceed && r.Data === 'REAUTH') {
				$("#tokenStatus").text("✗ i-Sens 토큰 만료").removeClass("text-success").addClass("text-danger");
				$("#btnSync").hide();
				$("#syncMsg").html('⚠ 케어센스 토큰이 만료되었습니다. '
					+ '<button type="button" class="btn btn-sm btn-danger ms-1" onclick="connectISens()">케어센스 재로그인</button>').show();
				if (!silent) _toast('케어센스 재로그인이 필요합니다.', 'err');
			} else if (silent) {
				// 자동 호출: 결과를 상태 영역에만 표시
				$("#syncMsg").text(r && r.IsSucceed
					? "최근 동기화: " + (r.Message || "완료")
					: "자동 동기화 실패: " + (r && r.Message ? r.Message : "")
				);
			} else {
				$("#syncMsg").hide();
				_toast(r.Message || (r.IsSucceed ? "동기화 완료" : "동기화 실패"), (r && r.IsSucceed) ? 'ok' : 'err');
			}
			// 성공/실패 무관하게 DB의 최신 상태로 화면 갱신
			loadTodayBlood();
			drawChart();
			loadDayStatus();
		},
		error: function(){
			$("#syncMsg").text("동기화 요청 오류").css("color","#dc3545");
			loadTodayBlood();
			drawChart();
		}
	});
}

/* ── [앱 홈 카드 대응] 최근 24시간 혈당지표 '양호/주의' 판정 ──
   마지막 측정 시점부터 거꾸로 24시간 구간의 측정값으로 TIR(70~180 비율)·저혈당 비율을 계산.
   양호 = TIR 70% 이상이면서 저혈당(<70) 4% 미만 — 대한당뇨병학회 권장 기준의 단순판(참고용).
   마지막 측정이 오늘이 아니면 앱과 같은 문구로 '이후 측정값 없음'을 함께 보여준다. */
function loadDayStatus(){
	$.ajax({
		url: CommonUtil.getContextPath()+'/getLastBloodDay.do', type:'post', dataType:'json',
		success:function(r){
			var row = (r && r.IsSucceed && r.Data) ? r.Data : null;
			var lastKey = row ? String(row.date2) : null;
			if(!lastKey){
				$('#dayStatusText').text('혈당 측정값이 아직 없습니다');
				$('#dayStatusSub').text('혈당기(CGM)를 착용하면 측정값이 표시됩니다');
				return;
			}
			var pd = new Date(lastKey); pd.setDate(pd.getDate()-1);
			var prevKey = formatDay(pd);
			$.when(
				$.ajax({ url:CommonUtil.getContextPath()+'/getBloodChartData.do', type:'post',
					data:JSON.stringify({ end:lastKey, userId:userUuid }), contentType:'application/json', dataType:'json' }),
				$.ajax({ url:CommonUtil.getContextPath()+'/getBloodChartData.do', type:'post',
					data:JSON.stringify({ end:prevKey, userId:userUuid }), contentType:'application/json', dataType:'json' })
			).done(function(aRes, bRes){
				var cur = Array.isArray(aRes[0]) ? aRes[0] : [];
				var prv = Array.isArray(bRes[0]) ? bRes[0] : [];
				var lastHM = cur.length ? (cur[cur.length-1].HM || toHM(cur[cur.length-1].DTM)) : '00:00';
				var pts = [];
				cur.forEach(function(x){ var v=parseInt(x.UPT,10); if(!isNaN(v)) pts.push(v); });
				// 전일(前日)은 마지막 측정 시각 이후 구간만 포함 → 정확히 '마지막 측정 기준 24시간'
				prv.forEach(function(x){
					var hm = x.HM || toHM(x.DTM);
					if(hm > lastHM){ var v=parseInt(x.UPT,10); if(!isNaN(v)) pts.push(v); }
				});
				if(!pts.length){
					$('#dayStatusText').text('혈당 측정값이 아직 없습니다');
					$('#dayStatusSub').text('혈당기(CGM)를 착용하면 측정값이 표시됩니다');
					return;
				}
				var inR  = pts.filter(function(v){ return v>=70 && v<=180; }).length;
				var low  = pts.filter(function(v){ return v<70; }).length;
				var tir  = Math.round(inR*100/pts.length);
				var good = tir>=70 && (low*100/pts.length)<4;
				$('#dayStatusText').html('최근 24시간 혈당지표는 <span style="color:'
					+(good?'#7CFC9A':'#ffd166')+';">&lsquo;'+(good?'양호':'주의')+'&rsquo;</span> 입니다');
				var today = formatDay(new Date());
				$('#dayStatusSub').html(lastKey < today
					? lastKey+' 이후 발생한 혈당 측정값이 없습니다 (마지막 측정 24시간 기준 상태입니다)'
					: '목표범위(70~180) 유지 '+tir+'% · 측정 '+pts.length+'건 기준');
			}).fail(function(){
				$('#dayStatusText').text('최근 24시간 지표를 불러오지 못했습니다');
				$('#dayStatusSub').text('');
			});
		},
		error:function(){
			$('#dayStatusText').text('최근 24시간 지표를 불러오지 못했습니다');
			$('#dayStatusSub').text('');
		}
	});
}

/* ── 🤖 AI 종합분석(주간) 전용 화면 ──
   앱 홈 카드의 두 항목(혈당 지표 확인 + AI 종합분석·코칭)을 한 화면에 담는다.
   (종전에는 세부그래프의 AI 분석 탭으로 보냈는데 세부혈당그래프 메뉴와 같은 화면이라 혼란 — 분리)
   기간 = 마지막 측정일 기준 7일, 기준 = 연령별(만 65세↑ 고령 50/50/1, 그 외 표준 70/25/4) */
function openAiAnalysis(){
	_showView('ai');
	_loadAiView();    // 우측: AI 종합분석(주간) + 가이드
	_loadAi24();      // 좌측: 연속혈당 측정(현재시점 24시간 기준)
}
/* ★[2026-10-21] 지표는 화면 계산이 아니라 서버 calcBlood.do 로 — 앱(연속혈당 측정·AI 종합분석)과
   같은 SQL 정의(공복=03~05시, 식후=끼니별 +2h 첫 측정, TIR 반올림)라서 수치가 앱과 1:1로 일치한다. */
var _aiWeekEnd = null, _aiLatestEnd = null;   // 주간 창의 끝 날짜 — ◀▶ 로 7일씩 이동
function _loadAiView(){
	$('#aiMetricBox').html('<div class="text-center text-muted py-3">지표 계산 중…</div>');
	$('#aiCoachBox').html('<div class="text-center text-muted py-3">분석 중…</div>');
	$('#aiBasisNote').html('');
	if (_aiWeekEnd){ _aiWeekRun(_aiWeekEnd); return; }
	$.ajax({ url:CommonUtil.getContextPath()+'/getLastBloodDay.do', type:'post', dataType:'json',
		success:function(lr){
			var lrow = (lr && lr.IsSucceed && lr.Data) ? lr.Data : null;
			_aiLatestEnd = lrow ? String(lrow.date2) : formatDay(new Date());
			_aiWeekEnd = _aiLatestEnd;
			_aiWeekRun(_aiWeekEnd);
		},
		error:function(){ _aiWeekRun(formatDay(new Date())); }
	});
}
function _aiWeekMove(dir){
	var d = new Date(_aiWeekEnd || formatDay(new Date()));
	d.setDate(d.getDate() + dir*7);
	var k = formatDay(d);
	if (_aiLatestEnd && k > _aiLatestEnd) k = _aiLatestEnd;   // 최신 주 이후(미래)로는 못 감
	if (k === _aiWeekEnd) return;
	_aiWeekEnd = k;
	_loadAiView();
}
function _aiWeekRun(endKey){
	var endD = new Date(endKey), days = [];
	for (var i=6; i>=0; i--) days.push(formatDay(new Date(endD.getTime()-i*864e5)));
	$('#aiPeriod').text(days[0]+' ~ '+days[6]);
	$('#aiPeriod2').text(days[0].replace(/-/g,'.')+' ~ '+days[6].replace(/-/g,'.'));
	_aiBandRange(7);                    // 발생구간 차트(기본 7일, 버튼으로 당일/14/30일)
	_loadAiInsight(days[0], days[6]);   // 고/저혈당 구간 · 음식 TOP3 · 운동 TOP3
	$.when(
		$.ajax({ url:CommonUtil.getContextPath()+'/calcBlood.do', type:'post',
			data:JSON.stringify({ start:days[0], end:days[6], userId:userUuid }), contentType:'application/json', dataType:'json' }),
		$.ajax({ url:CommonUtil.getContextPath()+'/patient/myInfo.do', type:'post', dataType:'json' })
	).done(function(cRes, iRes){
		var c = cRes[0] || {};
		var avg = Math.round(c.AvgBlood || 0);
		if (!avg){
			$('#aiAvgW,#aiFastW,#aiMealW').text('-');
			$('#aiMetricBox').html('<div class="text-center text-muted py-3">이 기간에는 측정 데이터가 없습니다.</div>');
			$('#aiCoachBox').html('');
			return;
		}
		var fast = Math.round(c.FASTING || 0) || avg;                          // 공복 — 03~05시 창, 없으면 기간 평균
		var meal = Math.round((c.avgMeal && c.avgMeal.avgBlood) || 0) || avg;  // 식후 — 끼니 없으면 기간 평균(앱과 동일 폴백)
		var gmi = c.GMI, tir = Math.round(c.TIR||0), tar = (c.TAR!=null?c.TAR:0), tbr = (c.TBR!=null?c.TBR:0), cv = (c.CV!=null?c.CV:0);
		$('#aiAvgW').text(avg); $('#aiFastW').text(fast); $('#aiMealW').text(meal);
		var info = iRes[0], birth = (info && info.IsSucceed && info.Data) ? String(info.Data.birth||'') : '';
		var age = null;
		if (/^[0-9]{8}$/.test(birth)){
			var t=new Date(), by=+birth.substring(0,4), bm=+birth.substring(4,6), bd=+birth.substring(6,8);
			age = t.getFullYear()-by - ((t.getMonth()+1<bm || (t.getMonth()+1===bm && t.getDate()<bd))?1:0);
		}
		var elderly = age!=null && age>=65;
		var C = elderly ? { tir:50, tar:50, tbr:1, note:'고령 기준 적용 (TIR 50% 이상·TAR 50% 미만·TBR 1% 미만)' }
		                : { tir:70, tar:25, tbr:4, note:'표준 기준 적용 (TIR 70% 이상·TAR 25% 미만·TBR 4% 미만)' };
		var OK='#2e7d32', WARN='#e67e22';
				var row = function(lb, hint, val, ok, plain){
					return '<div style="display:flex;justify-content:space-between;align-items:center;padding:9px 2px;border-bottom:1px solid #eef2f7;">'
					 + '<div><b style="font-size:15px;">'+lb+'</b><div class="text-muted" style="font-size:12px;">'+hint+'</div></div>'
					 + '<div style="font-size:20px;font-weight:800;color:'+(plain ? '#2d303f' : (ok ? OK : WARN))+';">'+val+'</div></div>';
				};
				$('#aiMetricBox').html(
					  row('GMI지수(%)', '혈당 관리지표(참고사항)', (Number(gmi)||0).toFixed(1)+'%', true, true)
					+ row('목표혈당 유지시간(TIR)', '권장: '+C.tir+'% 이상', tir+'%', tir>=C.tir)
					+ row('고혈당 시간(TAR)', '권장: '+C.tar+'% 미만', (Number(tar)||0).toFixed(1)+'%', tar<C.tar)
					+ row('저혈당 시간(TBR)', '권장: '+C.tbr+'% 미만', (Number(tbr)||0).toFixed(1)+'%', tbr<C.tbr)
					+ row('혈당변동성(CV)', '권장: 36% 이하', (Number(cv)||0).toFixed(1)+'%', cv<=36)
				);
				var head='', tips=[];
				if (tar>=C.tar){ head='지난 일주일 동안 고혈당 시간이 다소 길었습니다.'; tips=['식사량을 줄이세요.','탄수화물 비율을 줄이세요.','식후 20~30분 걷기를 실천해 보세요.']; }
				else if (tbr>=C.tbr){ head='지난 일주일 동안 저혈당이 발생했습니다.'; tips=['공복 상태의 운동을 피하세요.','식사를 거르지 말고 규칙적으로 하세요.','저혈당 증상이 느껴지면 즉시 당분을 섭취하세요.']; }
				else if (cv>36){ head='지난 일주일 동안 혈당 변동 폭이 큰 편이었습니다.'; tips=['식사 시간을 규칙적으로 유지하세요.','과식과 결식을 피하세요.','가벼운 활동을 꾸준히 이어가세요.']; }
				else { head='지난 일주일 혈당이 안정적으로 관리되고 있습니다.'; tips=['현재 생활습관을 그대로 유지하세요.','꾸준한 측정과 기록을 계속해 주세요.']; }
				$('#aiCoachBox').html(
					'<div style="font-size:15px;line-height:1.9;">'
					+ '최근 일주일 지표 분석입니다.'
					+ '<br>• TIR(목표혈당 유지시간) <b>'+tir+'%</b> → '+(tir>=C.tir ? '충족&nbsp;👍' : '<b style="color:'+WARN+'">미달</b>')
					+ '<br>• TAR(고혈당 시간) <b>'+tar+'%</b> → '+(tar<C.tar ? '충족' : '<b style="color:'+WARN+'">초과</b>')
					+ '<br>• TBR(저혈당 시간) <b>'+tbr+'%</b> → '+(tbr<C.tbr ? '충족' : '<b style="color:'+WARN+'">초과</b>')
					+ '<br><br><b>AI 코칭</b><br>' + head
					+ '<ul style="margin:6px 0 0;padding-left:18px;">'+tips.map(function(s){ return '<li>'+s+'</li>'; }).join('')+'</ul>'
					+ '</div>'
				);
				// 앱과 동일: 각주는 점선 박스 안 코칭 끝에 "※ 65세 · 당뇨병 전단계 — 고령 기준 적용 (…)" (별도 학회 문구 없음)
				var gbMap = { '1':'1형 당뇨병', '2':'2형 당뇨병', '3':'당뇨병 전단계', '4':'임신성 당뇨병', '9':'기타' };
				var gbNm = (info && info.Data) ? (gbMap[String(info.Data.blodGb||'')] || '') : '';
				$('#aiCoachBox').append('<div style="font-size:13.5px;color:#555;margin-top:8px;line-height:1.55;">※ '
					+ (age!=null ? age+'세' : '') + (gbNm ? ' · '+gbNm : '') + (age!=null||gbNm ? ' — ' : '') + C.note + '</div>');
				$('#aiBasisNote').html('');
	}).fail(function(){
		$('#aiMetricBox').html('<div class="text-center text-danger py-3">지표 조회에 실패했습니다.</div>');
		$('#aiCoachBox').html('');
	});
}

/* 좌측 — 연속혈당 측정(앱 화면 대응): 최근 혈당 + 오늘 공복·식후 평균 + 마지막 측정 기준 24시간 지표 */
var _ai24Day = null;   // 연속혈당 측정 기준일 — ◀▶ 로 하루씩 이동 (앱 FAHR_00 과 동일)
function _loadAi24(){
	if (_ai24Day){ _ai24Run(_ai24Day); return; }
	$.ajax({ url:CommonUtil.getContextPath()+'/getLastBloodDay.do', type:'post', dataType:'json',
		success:function(lr){
			var lrow = (lr && lr.IsSucceed && lr.Data) ? lr.Data : null;
			_ai24Day = lrow ? String(lrow.date2) : formatDay(new Date());   // 최종 측정일(없으면 오늘)
			_ai24Run(_ai24Day);
		},
		error:function(){ _ai24Day = formatDay(new Date()); _ai24Run(_ai24Day); }
	});
}
function _ai24Move(dir){
	var d = new Date(_ai24Day || formatDay(new Date()));
	d.setDate(d.getDate() + dir);
	var k = formatDay(d), today = formatDay(new Date());
	if (k > today) k = today;          // 오늘 이후로는 못 감
	if (k === _ai24Day) return;
	_ai24Day = k;
	_ai24Run(k);
}
function _ai24Run(lastKey){
	$('#aiMetricBox24').html('<div class="text-center text-muted py-3">지표 계산 중…</div>');
	var pd = new Date(lastKey); pd.setDate(pd.getDate()-1);
	var prevKey = formatDay(pd);
	// 앱과 동일한 날짜 표기 "2026년 10월 7일 (화)" + 당일 측정 없음 안내
	var kp = lastKey.split('-'), WD = ['일','월','화','수','목','금','토'];
	$('#ai24DateTxt').text(parseInt(kp[0])+'년 '+parseInt(kp[1])+'월 '+parseInt(kp[2])+'일 ('+WD[new Date(lastKey).getDay()]+')');
	$('#aiDateNote').text(lastKey < formatDay(new Date()) ? '당일 혈당 측정이 없어 최종 측정일을 표시합니다.' : '');
	// 평균·공복·식후·지표는 calcBlood(기준일)에서 한 번에 — 앱과 같은 SQL 정의
	$.when(
				$.ajax({ url:CommonUtil.getContextPath()+'/getBloodChartData.do', type:'post',
					data:JSON.stringify({ end:lastKey, userId:userUuid }), contentType:'application/json', dataType:'json' }),
				$.ajax({ url:CommonUtil.getContextPath()+'/getBloodChartData.do', type:'post',
					data:JSON.stringify({ end:prevKey, userId:userUuid }), contentType:'application/json', dataType:'json' }),
				$.ajax({ url:CommonUtil.getContextPath()+'/calcBlood.do', type:'post',
					data:JSON.stringify({ start:lastKey, end:lastKey, userId:userUuid }), contentType:'application/json', dataType:'json' }),
				$.ajax({ url:CommonUtil.getContextPath()+'/patient/myInfo.do', type:'post', dataType:'json' })
			).done(function(aRes, bRes, cRes, iRes){
				var cur = Array.isArray(aRes[0]) ? aRes[0] : [], prv = Array.isArray(bRes[0]) ? bRes[0] : [];
				var lastHM = cur.length ? (cur[cur.length-1].HM || toHM(cur[cur.length-1].DTM)) : '00:00';
				// 24시간 창을 시간순으로: 전일(마지막 측정시각 이후) → 당일. m = 마지막 측정으로부터 몇 분 전인지
				var hmMin = function(hm){ return (parseInt(hm.substring(0,2),10)||0)*60 + (parseInt(hm.substring(3,5),10)||0); };
				var lastMin = hmMin(lastHM);
				var cpts = [];
				if (cur.length){   // 그날 측정이 없으면 전일 데이터로 창을 채우지 않는다(다른 날 자료로 오인 방지)
					prv.forEach(function(x){ var hm=x.HM||toHM(x.DTM); if(hm>lastHM){ var v=parseInt(x.UPT,10); if(!isNaN(v)) cpts.push({hm:hm, v:v, m:(1440-hmMin(hm))+lastMin}); } });
					cur.forEach(function(x){ var hm=x.HM||toHM(x.DTM); var v=parseInt(x.UPT,10); if(!isNaN(v)) cpts.push({hm:hm, v:v, m:lastMin-hmMin(hm)}); });
				}
				if (!cpts.length){
					$('#ai24First,#ai24Last,#aiAvg24,#aiFast24,#aiMeal24,#ai24Status,#ai24GmiTxt,#ai24TirTxt').text('-');
					$('#ai24StatusName').text('-');
					$('#ai24FirstT,#ai24LastT').text('-'); $('#ai24Delta').html('&rarr; 0');
					window._ai24pts = []; _renderAi24Chart(24);
					$('#aiMetricBox24').html('<div class="text-center text-muted py-3">이 날은 측정 데이터가 없습니다.</div>');
					return;
				}
				// 상단 헤더(앱과 동일): 창 시작값·시각 → 변화량(5분당) → 최근값·시각
				var fmtKT = function(hm){ var h=parseInt(hm.substring(0,2),10), mm=hm.substring(3,5); return (h<12?'오전 ':'오후 ')+(h%12||12)+':'+mm; };
				// 앱 showBloodData 와 동일: 좌측 = 직전 측정(prev), 우측 = 최근 측정(now), 가운데 = now-prev (5분당)
				var l=cpts[cpts.length-1], p=cpts.length>1?cpts[cpts.length-2]:l, f=p;
				// 앱 applyTrend30 과 동일: 최근값 vs 30분 전(±10분 근사) 변화로 '현재 혈당 변화' 상태·설명
				(function(){
					var past=null, best=11;
					cpts.forEach(function(q){ var d=Math.abs(q.m-30); if(d<best){ best=d; past=q; } });
					var st, nm, col;
					if(!past){ st='알 수 없음'; nm='혈당값 변화의 속도와 방향을 계산할 수 없습니다'; col='#6c757d'; }
					else {
						var delta=l.v-past.v, a=Math.abs(delta), dir=delta>=0?'증가':'감소';
						if(a<=30){ st='안정적'; nm='혈당이 지난 30분 동안 30 mg/dL 이하로 증가 또는 감소하고 있습니다'; }
						else if(a<=60){ st='서서히 '+dir; nm='혈당이 지난 30분 동안 31~60 mg/dL '+dir+'하고 있습니다'; }
						else if(a<=90){ st=dir; nm='혈당이 지난 30분 동안 61~90 mg/dL '+dir+'하고 있습니다'; }
						else { st='빠르게 '+dir; nm='혈당이 지난 30분 동안 91 mg/dL 이상 '+dir+'하고 있습니다'; }
						nm += ' (최근 30분 '+(delta>0?'+':'')+delta+' mg/dL)';
						col = a<=30 ? '#2f9e63' : delta>0 ? '#dc3545' : '#0d6efd';
					}
					$('#ai24Status').text(st).css('color', col);
					$('#ai24StatusName').text(nm);
				})();
				$('#ai24First').text(f.v); $('#ai24FirstT').text(fmtKT(f.hm));
				$('#ai24Last').text(l.v);  $('#ai24LastT').text(fmtKT(l.hm));
				var dv = l.v - p.v;
				$('#ai24Delta').html((dv>0 ? '&#8599; +' : dv<0 ? '&#8600; ' : '&rarr; ') + dv);
				// 그래프: 구간 버튼(3/6/12/24시간)으로 창 전환 — 앱과 동일
				window._ai24pts = cpts;
				_renderAi24Chart(24);
				$('#aiRangeBtns button').removeClass('on').filter('[data-h="24"]').addClass('on');
				$('#aiRangeBtns button').off('click.ai').on('click.ai', function(){
					$('#aiRangeBtns button').removeClass('on'); $(this).addClass('on');
					_renderAi24Chart(parseInt($(this).attr('data-h'), 10) || 24);
				});
				// 지표·평균: 서버 calcBlood(마지막 측정일 기준) — 앱 '연속혈당 측정'과 같은 수치
				var c = cRes[0] || {};
				var avg  = Math.round(c.AvgBlood || 0);
				var fast = Math.round(c.FASTING || 0) || (avg || '-');
				var meal = Math.round((c.avgMeal && c.avgMeal.avgBlood) || 0) || (avg || '-');
				var gmi = c.GMI, tir = Math.round(c.TIR||0), tar = (c.TAR!=null?c.TAR:0), tbr = (c.TBR!=null?c.TBR:0), cv = (c.CV!=null?c.CV:0);
				$('#aiAvg24').text(avg || '-');
				$('#aiFast24').text(fast);
				$('#aiMeal24').text(meal);
				$('#ai24GmiTxt').text((Number(gmi)||0).toFixed(1)+' %');
				$('#ai24TirTxt').text(tir+' %');
				// 연령 기준 (주간 화면과 동일 규칙)
				var info=iRes[0], birth=(info&&info.IsSucceed&&info.Data)?String(info.Data.birth||''):'';
				var age=null;
				if (/^[0-9]{8}$/.test(birth)){
					var t=new Date(), by=+birth.substring(0,4), bm=+birth.substring(4,6), bd=+birth.substring(6,8);
					age = t.getFullYear()-by - ((t.getMonth()+1<bm || (t.getMonth()+1===bm && t.getDate()<bd))?1:0);
				}
				var eld = age!=null && age>=65;
				var C = eld ? {tir:50,tar:50,tbr:1} : {tir:70,tar:25,tbr:4};
				var OK='#2e7d32', WARN='#e67e22';
				var row = function(lb, hint, val, ok, plain){
					return '<div style="display:flex;justify-content:space-between;align-items:center;padding:9px 2px;border-bottom:1px solid #eef2f7;">'
					 + '<div><b style="font-size:15px;">'+lb+'</b><div class="text-muted" style="font-size:12px;">'+hint+'</div></div>'
					 + '<div style="font-size:20px;font-weight:800;color:'+(plain ? '#2d303f' : (ok ? OK : WARN))+';">'+val+'</div></div>';
				};
				$('#aiMetricBox24').html(
					  row('GMI지수(%)', '혈당 관리지표(참고사항)', (Number(gmi)||0).toFixed(1)+'%', true, true)
					+ row('목표혈당 유지시간(TIR)', '권장: '+C.tir+'% 이상', tir+'%', tir>=C.tir)
					+ row('고혈당 시간(TAR)', '권장: '+C.tar+'% 미만', (Number(tar)||0).toFixed(1)+'%', tar<C.tar)
					+ row('저혈당 시간(TBR)', '권장: '+C.tbr+'% 미만', (Number(tbr)||0).toFixed(1)+'%', tbr<C.tbr)
					+ row('혈당변동성(CV)', '권장: 36% 이하', (Number(cv)||0).toFixed(1)+'%', cv<=36)
				);
	}).fail(function(){
		$('#aiMetricBox24').html('<div class="text-center text-danger py-3">지표 조회에 실패했습니다.</div>');
	});
}

/* 발생구간 기간 버튼(당일/7/14/30일) — 주간 창의 끝 날짜 기준으로 N일 */
function _aiBandRange(daysN){
	var endKey = _aiWeekEnd || formatDay(new Date());
	var d = new Date(endKey); if (daysN > 0) d.setDate(d.getDate() - (daysN - 1));
	$('#aiBandBtns button').removeClass('on').filter('[data-days="'+daysN+'"]').addClass('on');
	_loadAiBand(formatDay(d), endKey);
}
$(document).on('click', '#aiBandBtns button', function(){ _aiBandRange(parseInt($(this).attr('data-days'), 10) || 0); });

/* 고혈당/저혈당 구간 · 주의할음식 TOP3 · 추천운동 TOP3 — 앱 showBloodHighLow/foodBlood_max/exerBlood_max 그대로 */
function _loadAiInsight(startKey, endKey){
	$('#aiHighZone,#aiLowZone').text('…');
	$('#aiFoodRows,#aiExerRows').html('<div class="ai-grid4" style="grid-template-columns:1fr;text-align:center;color:#999;">불러오는 중…</div>');
	$.ajax({
		url: CommonUtil.getContextPath()+'/patient/weekInsight.do', type:'post',
		data:JSON.stringify({ start:startKey, end:endKey }), contentType:'application/json', dataType:'json',
		success:function(r){
			var d = (r && r.IsSucceed && r.Data) ? r.Data : {};
			var hl = d.highLow || {};
			$('#aiHighZone').text(hl.High_Value || '-');
			$('#aiLowZone').text(hl.Low_Value || '-');
			var safe = function(v){ return (v===null||v===undefined||v==='') ? '-' : String(v); };
			var trunc = function(s,n){ s=safe(s); return s.length>n ? s.substring(0,n)+'…' : s; };
			var num = function(x){ if(x===null||x===undefined||x==='') return null; var n=Number(x); return isFinite(n)?n:null; };
			var bigger = function(a,b){ var p=num(a), q=num(b); if(p===null&&q===null) return safe(b); var m=Math.max(p===null?-Infinity:p, q===null?-Infinity:q); return isFinite(m)?String(m):'-'; };
			var none = '<div class="ai-grid4" style="grid-template-columns:1fr;text-align:center;color:#999;">자료없음</div>';
			var food = Array.isArray(d.food) ? d.food : [];
			$('#aiFoodRows').html(food.length ? food.map(function(it){
				return '<div class="ai-grid4"><span>'+safe(it.RN)+'</span><span title="'+safe(it.FOOD_NAME)+'">'+trunc(it.FOOD_NAME,8)+'</span><span>'+safe(it.FOOD_CNT)+'</span><span>'+bigger(it.PRE_VALUE, it.DELTA_2H)+'</span></div>';
			}).join('') : none);
			var exer = Array.isArray(d.exer) ? d.exer : [];
			$('#aiExerRows').html(exer.length ? exer.map(function(it){
				return '<div class="ai-grid4"><span>'+safe(it.RN)+'</span><span title="'+safe(it.EXER_NAME)+'">'+trunc(it.EXER_NAME,8)+'</span><span>'+safe(it.MINUTES_DIFF)+'</span><span>'+bigger(it.PRE_VALUE, it.DELTA_15M)+'</span></div>';
			}).join('') : none);
		},
		error:function(){ $('#aiHighZone,#aiLowZone').text('-'); $('#aiFoodRows,#aiExerRows').html('<div class="ai-grid4" style="grid-template-columns:1fr;text-align:center;color:#c00;">조회 실패</div>'); }
	});
}

/* 저혈당/고혈당 발생구간(3시간 단위) — 앱 Blood_Consult 하단 차트와 동일 데이터(avgBloodlowhight 포팅) */
function _loadAiBand(startKey, endKey){
	$.ajax({
		url: CommonUtil.getContextPath()+'/patient/timeBand.do', type:'post',
		data:JSON.stringify({ start:startKey, end:endKey }), contentType:'application/json', dataType:'json',
		success:function(r){
			var rows = (r && r.IsSucceed && r.Data) ? r.Data : [];
			var ORDER = ['오전12','오전3','오전6','오전9','오후12','오후3','오후6','오후9'];
			var by = {};
			rows.forEach(function(x){ by[x.HOUR_LABEL] = x; });
			var low=[], nor=[], hi=[];
			ORDER.forEach(function(k){
				var d = by[k] || {};
				low.push(Number(d.LOW_PCT)||0); nor.push(Number(d.NORMAL_PCT)||0); hi.push(Number(d.HIGH_PCT)||0);
			});
			var dom = document.getElementById('aiBandChart');
			if (!dom || typeof echarts === 'undefined') return;
			var old = echarts.getInstanceByDom(dom); if (old) old.dispose();
			if (!rows.length){ dom.innerHTML = '<div class="text-center text-muted py-4">이 기간에는 측정값이 없습니다.</div>'; return; }
			dom.innerHTML = '';
			var ch = echarts.init(dom);
			ch.setOption({
				tooltip:{ trigger:'axis', formatter:function(ps){
					var t = ps[0].axisValue;
					ps.forEach(function(p){ t += '<br>'+p.marker+p.seriesName+' '+p.value+'%'; });
					return t;
				}},
				grid:{ left:40, right:20, top:18, bottom:24 },
				xAxis:{ type:'category', data:ORDER, axisLabel:{ fontSize:11 } },
				yAxis:{ type:'value', min:0, max:100, axisLabel:{ formatter:'{value}%' } },
				series:[
					{ name:'저', type:'bar', stack:'b', data:low, itemStyle:{ color:'#FF0000' }, barMaxWidth:36,
					  label:{ show:true, position:'inside', fontSize:10, formatter:function(p){ return p.value>=6 ? p.value+'%' : ''; } } },
					{ name:'정상', type:'bar', stack:'b', data:nor, itemStyle:{ color:'#6CC070' },
					  label:{ show:true, position:'inside', fontSize:10, color:'#fff', fontWeight:700, formatter:function(p){ return p.value>=8 ? p.value+'%' : ''; } } },
					{ name:'고', type:'bar', stack:'b', data:hi, itemStyle:{ color:'#F0B24B' },
					  label:{ show:true, position:'top', fontSize:10, color:'#b8860b', formatter:function(p){ return p.value>0 ? p.value+'%' : ''; } } }
				]
			});
		}
	});
}

/* 24시간 차트 렌더 — hours(3/6/12/24) 구간만 표시. 데이터는 _loadAi24 가 채운 window._ai24pts */
function _renderAi24Chart(hours){
	var all = window._ai24pts || [];
	var cpts = all.filter(function(p){ return p.m <= hours*60; });
	var dom24 = document.getElementById('aiChart24');
	if (!dom24 || typeof echarts === 'undefined') return;
	var old24 = echarts.getInstanceByDom(dom24); if (old24) old24.dispose();
	if (!cpts.length){ dom24.innerHTML = '<div class="text-center text-muted py-4">이 구간에는 측정값이 없습니다.</div>'; return; }
	dom24.innerHTML = '';
	var xs = cpts.map(function(p){ return p.hm; });
	var maxV = Math.max.apply(null, cpts.map(function(p){ return p.v; }));
	var ch24 = echarts.init(dom24);
	ch24.setOption({
		tooltip:{ trigger:'axis' },
		grid:{ left:40, right:44, top:14, bottom:26 },   // right 44: 70/180 기준선 라벨이 잘리지 않게
		xAxis:{ type:'category', data:xs, axisTick:{ alignWithLabel:true },
			axisLabel:{ interval:function(i){ return i===0 || (xs[i]||'').substring(0,2)!==(xs[i-1]||'').substring(0,2); },
			            formatter:function(v){ return String(v).substring(0,2)+'시'; } } },
		// 앱 차트와 같은 축(54·70·100·140·180) — 값이 180 을 넘으면 그만큼 위로 확장
		yAxis:{ type:'value', min:40, max:Math.max(200, maxV+10), interval:40 },
		series:[{ name:'혈당', type:'line', data:cpts.map(function(p){ return p.v; }), smooth:true, symbol:'none',
			areaStyle:{ opacity:0.15 },
			markLine:{ silent:true, symbol:'none', label:{ position:'end', formatter:'{c}' },
				data:[ { yAxis:180, lineStyle:{ type:'dashed', color:'#f0b429' } },
				       { yAxis:70,  lineStyle:{ type:'dashed', color:'#e84c7d' } } ] }
		}]
	});
}

function loadTodayBlood(){
	$.ajax({
		url: CommonUtil.getContextPath() + "/getTodayBlood.do",
		type:"post",
		dataType:"json",
		success:function(r){
			if (r && r.IsSucceed && r.Data && r.Data.length > 0) {
				$("#nowBlood").text(r.Data[0].UPT_VALUE);
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

// 최근 1주일 대시보드: ① 주간 평균 숫자 ② 일자별 평균 막대(클릭 가능) ③ 클릭 시 시간대별 추이
function drawChart(){
	var today = new Date();
	var startD = new Date(Date.now() - 6*24*60*60*1000); // 오늘 포함 7일
	var start = formatDay(startD) + 'T00:00:00';
	var end   = formatDay(today)  + 'T23:59:59';

	// ① 최근 1주일 평균
	$.ajax({
		url: CommonUtil.getContextPath() + "/calcBlood.do",
		type:"post",
		data: JSON.stringify({ start: start, end: end, userId: userUuid }),
		contentType:"application/json",
		dataType:"json",
		success:function(r){ /* 평균은 일별 차트 데이터 기준으로 계산 */ },
		error:function(xhr){ }
	});

	// ② 일자별 평균 막대
	$.ajax({
		url: CommonUtil.getContextPath() + "/drawWeeklyBloodChart.do",
		type:"post",
		data: JSON.stringify({ start: start, end: end, userId: userUuid }),
		contentType:"application/json",
		dataType:"json",
		success:function(rows){
			drawDailyChart(rows);
		},
		error:function(xhr){
			$("#dailyChart").html('<div class="text-center text-danger p-3">일자별 조회 실패 (HTTP '+(xhr&&xhr.status)+')</div>');
		}
	});
}

function drawDailyChart(rows){
	rows = Array.isArray(rows) ? rows : [];
	// 조회결과를 날짜(date2)로 인덱싱
	var byDate = {};
	rows.forEach(function(r){ byDate[r.date2] = Math.round(parseFloat(r.avgBlood)||0); });

	// 현재일자 기준 7일 축 생성 (오늘-6 ~ 오늘) → 그래프 우측 끝이 항상 오늘
	var labels = [], dateKeys = [], vals = [];
	for (var i = 6; i >= 0; i--) {
		var d = new Date(Date.now() - i*24*60*60*1000);
		var key = formatDay(d);
		dateKeys.push(key);
		labels.push((d.getMonth()+1)+'/'+d.getDate());   // '5/29'
		vals.push(byDate.hasOwnProperty(key) ? byDate[key] : null);
	}

	var present = vals.filter(function(v){ return v !== null && v > 0; });
	// 화면 표시된 일별 평균 기준으로 주간 평균 계산
	if (present.length > 0) {
		var wAvg = Math.round(present.reduce(function(a,b){return a+b;},0) / present.length);
		$("#weekAvg").text(wAvg);
		// 챗봇 "최근 1주일" 질문용 주간 통계 저장 (일별 평균 기준)
		window._weekStats = { avg: wAvg, max: Math.max.apply(null, present), min: Math.min.apply(null, present), days: present.length };
	} else {
		$("#weekAvg").text("-");
		window._weekStats = null;
	}
	if (typeof echarts === 'undefined') {
		$("#dailyChart").html('<div class="text-center text-danger p-3">차트 라이브러리(echarts) 로드 실패 — 네트워크/CDN 차단 여부를 확인하세요.</div>');
	} else if (present.length === 0) {
		// 최근 1주일 데이터 없음 — 가장 최근 측정일 1건을 좌측 끝에 표시(사용자가 마지막 측정일 확인 가능)
		_drawLastDayFallback(labels, dateKeys);
		return;
	} else {
		var maxV = Math.max.apply(null, present);
		var minV = Math.min.apply(null, present);

		// 선택 날짜 결정: 기존 선택 유지 > 데이터 있는 최근일
		var selKey = null, selLabel = null;
		if (_currentDayKey && dateKeys.indexOf(_currentDayKey) !== -1) {
			selKey = _currentDayKey; selLabel = _currentDayLabel || _dayLabel(_currentDayKey);
		} else {
			for (var i = dateKeys.length - 1; i >= 0; i--) {
				if (byDate.hasOwnProperty(dateKeys[i]) && byDate[dateKeys[i]] > 0) {
					selKey = dateKeys[i]; selLabel = labels[i]; break;
				}
			}
		}

		// 막대 데이터 생성 — 선택된 날짜는 진한 테두리로 강조
		function _buildBars(hlKey){
			return vals.map(function(v, idx){
				if (v === null) return { value:null };
				var color = (v===maxV) ? '#dc3545' : (v===minV) ? '#f5c518' : '#0d6efd';
				var st = { color:color };
				if (dateKeys[idx] === hlKey) {
					st.borderColor = '#1a237e'; st.borderWidth = 3;
					st.shadowBlur = 6; st.shadowColor = 'rgba(26,35,126,0.45)';
				}
				return { value:v, itemStyle:st };
			});
		}

		var dailyDom = document.getElementById('dailyChart');
		var prevDaily = echarts.getInstanceByDom(dailyDom);
		if (prevDaily) prevDaily.dispose();
		$("#dailyChart").empty();
		var chart = echarts.init(dailyDom);
		chart.setOption({
			tooltip: { trigger:'axis', formatter:function(params){
					var p=params[0];
					if(!p||p.value==null) return '';
					var sel = (dateKeys[p.dataIndex]===_currentDayKey) ? ' <small style="color:#1a237e;">(선택됨)</small>' : '';
					return p.axisValue+sel+'<br/>혈당: <b>'+p.value+' mg/dL</b>';
				}},
			grid: { left:34, right:6, top:20, bottom:30 },
			xAxis: { type:'category', data:labels },
			yAxis: { type:'value', min:0, max:300 },
			series: [{ type:'bar', data:_buildBars(selKey), barMaxWidth:58,
				label:{ show:true, position:'top', formatter:function(p){ return p.value!=null?p.value:''; } } }]
		});
		chart.off('click');
		chart.on('click', function(params){
			if (vals[params.dataIndex] == null) return;   // 데이터 없는 날 클릭 무시
			var k = dateKeys[params.dataIndex], lbl = labels[params.dataIndex];
			chart.setOption({ series: [{ data: _buildBars(k) }] });  // 상단 선택 막대 재강조
			loadDayChart(k, lbl);
		});

		if (selKey) { loadDayChart(selKey, selLabel); return; }
	}

	// (차트 미표시: echarts 없음 / 데이터 없음) — 선택 날짜만 결정해 하단 로드
	if (_currentDayKey && dateKeys.indexOf(_currentDayKey) !== -1) {
		loadDayChart(_currentDayKey, _currentDayLabel || _dayLabel(_currentDayKey));
		return;
	}
	var defaultKey = null, defaultLabel = null;
	for (var i = 0; i < dateKeys.length; i++) {
		var k = dateKeys[dateKeys.length - 1 - i]; // 최신 날짜부터 역순
		if (byDate.hasOwnProperty(k) && byDate[k] > 0) {
			defaultKey   = k;
			defaultLabel = labels[dateKeys.length - 1 - i];
			break;
		}
	}
	if (!defaultKey) { // 1주일 전체 데이터 없으면 오늘 날짜 유지
		var today = new Date();
		defaultKey   = formatDay(today);
		defaultLabel = (today.getMonth()+1)+'/'+today.getDate();
	}
	loadDayChart(defaultKey, defaultLabel);
}

// 최근 1주일에 데이터가 전혀 없을 때: 가장 최근 측정일 1건을 차트 좌측 끝에 표시.
//  · 우측 7일(오늘-6 ~ 오늘)은 비워두고, 그 왼쪽에 마지막 측정일 막대를 1개 붙임
//  · 막대를 클릭하지 않아도 그 날짜의 시간대별 차트(하단)까지 자동으로 그려줌
function _drawLastDayFallback(weekLabels, weekDateKeys){
	$.ajax({
		url: CommonUtil.getContextPath() + "/getLastBloodDay.do",
		type:"post", dataType:"json",
		success:function(r){
			var row     = (r && r.IsSucceed && r.Data) ? r.Data : null;
			var lastKey = row ? String(row.date2) : null;            // 'YYYY-MM-DD'
			var lastVal = row ? Math.round(parseFloat(row.avgBlood)||0) : 0;

			// 과거 데이터조차 없음 → 기존 '데이터 없음' 안내 + 오늘(빈) 시간대 차트
			if (!lastKey || lastVal <= 0) {
				$("#dailyChart").html('<div class="text-center text-muted p-3">최근 1주일 데이터 없음</div>');
				var t = new Date();
				loadDayChart(formatDay(t), (t.getMonth()+1)+'/'+t.getDate());
				return;
			}

			var lastLabel = _dayLabel(lastKey);                      // '5/20'
			var labels   = [lastLabel].concat(weekLabels);           // 좌측 끝 = 마지막 측정일
			var vals     = [lastVal].concat(weekLabels.map(function(){ return null; }));

			// 주간 평균/통계는 이 1건 기준으로 표시
			$("#weekAvg").text(lastVal);
			window._weekStats = { avg:lastVal, max:lastVal, min:lastVal, days:1 };

			if (typeof echarts === 'undefined') {
				$("#dailyChart").html('<div class="text-center text-danger p-3">차트 라이브러리(echarts) 로드 실패</div>');
			} else {
				var dom = document.getElementById('dailyChart');
				var prev = echarts.getInstanceByDom(dom);
				if (prev) prev.dispose();
				$("#dailyChart").empty();
				var chart = echarts.init(dom);
				chart.setOption({
					tooltip:{ trigger:'axis', formatter:function(p){
							var x = p && p[0];
							if(!x || x.value==null) return '';
							return x.axisValue+' <small style="color:#888;">(최근 측정)</small><br/>혈당: <b>'+x.value+' mg/dL</b>';
						}},
					grid:{ left:34, right:6, top:20, bottom:30 },
					xAxis:{ type:'category', data:labels },
					yAxis:{ type:'value', min:0, max:300 },
					series:[{ type:'bar', barMaxWidth:58,
						data: vals.map(function(v){
							if (v == null) return { value:null };
							// 마지막 측정일 막대는 강조(진한 테두리)
							return { value:v, itemStyle:{ color:'#0d6efd', borderColor:'#1a237e', borderWidth:3,
								shadowBlur:6, shadowColor:'rgba(26,35,126,0.45)' } };
						}),
						label:{ show:true, position:'top', formatter:function(p){ return p.value!=null?p.value:''; } } }]
				});
			}
			// 하단 시간대별 차트도 마지막 측정일로 자동 표시
			loadDayChart(lastKey, lastLabel);
		},
		error:function(){
			$("#dailyChart").html('<div class="text-center text-muted p-3">최근 1주일 데이터 없음</div>');
		}
	});
}

function loadDayChart(dateKey, label){
	_currentDayKey = dateKey;
	_currentDayLabel = label || _dayLabel(dateKey);
	$("#dayChartTitle").text(label + " 시간대별 혈당 추이");
	if (typeof echarts === 'undefined') {
		$("#lineChart").html('<div class="text-center text-danger p-3">차트 라이브러리(echarts) 로드 실패</div>');
		return;
	}
	var lineDom = document.getElementById('lineChart');
	var prev = echarts.getInstanceByDom(lineDom);
	if (prev) prev.dispose();

	var dc = dateKey.replace(/-/g,''); // YYYYMMDD

	$.when(
		$.ajax({ url:CommonUtil.getContextPath()+"/getBloodChartData.do", type:"post",
			data:JSON.stringify({ end:dateKey, userId:userUuid }), contentType:"application/json", dataType:"json" }),
		$.ajax({ url:CommonUtil.getContextPath()+"/getFoodInfo.do", type:"post",
			data:JSON.stringify({ userUuid:userUuid, eatDate:dc }), contentType:"application/json", dataType:"json" }),
		$.ajax({ url:CommonUtil.getContextPath()+"/getExerInfo.do", type:"post",
			data:JSON.stringify({ userUuid:userUuid, exerDate:dc }), contentType:"application/json", dataType:"json" })
	).done(function(bRes, fRes, eRes){
		var rows     = Array.isArray(bRes[0]) ? bRes[0] : [];
		var foodRows = (fRes[0]&&fRes[0].Data) ? fRes[0].Data : [];
		var exerRows = (eRes[0]&&eRes[0].Data) ? eRes[0].Data : [];
		// 날짜 필터는 서버(getFoodInfo/getExerInfo 의 EAT_DATE/EXER_DATE 조건)에서 이미 적용됨.
		// 클라이언트 재필터(r.eatDate === dc)는 DATE 컬럼이 "2026-05-29"/epoch 로 와서 형식 불일치로
		// 식사·운동이 전부 사라지는 버그가 있어 제거함.

		// ★원본 측정값을 그대로 그린다(2026-08-15) — 종전 '시간별 평균 1점' 방식은 실제 측정과 값이 달라
		//   (예: 12시대 실측 103→183 인데 그래프엔 평균 154 만 표시) "그래프가 실제 혈당과 안 맞다"는 문의가 있었다.
		//   5분 간격 원본을 전부 찍고 축 라벨만 시(時) 단위로 표시. (하단 평가 패널은 종전대로 시간별 평균 사용)
		var pts = [];
		var buckets = {};
		rows.forEach(function(r){
			var hm = r.HM || toHM(r.DTM);
			var hh = hm.substring(0,2);
			var v  = parseInt(r.UPT,10);
			if (!hh || isNaN(v)) return;
			pts.push({ hm:hm, v:v });
			if (!buckets[hh]) buckets[hh] = { sum:0, cnt:0 };
			buckets[hh].sum += v; buckets[hh].cnt++;
		});

		// 식사·운동 시간(HH) 수집 (+ 마커 배치용 대표 시각)
		var foodMap = {}, exerMap = {}, foodTm = {}, exerTm = {};
		foodRows.forEach(function(r){
			var t = String(r.eatStime||''); var hh = t.substring(0,2);
			if (hh) { if (!foodMap[hh]) foodMap[hh]=[]; foodMap[hh].push(r.foodName||'식사'); if(!(hh in foodTm)) foodTm[hh]=t; }
		});
		exerRows.forEach(function(r){
			var t = String(r.exerStime||''); var hh = t.substring(0,2);
			if (hh) { if (!exerMap[hh]) exerMap[hh]=[]; exerMap[hh].push(r.exerName||'운동'); if(!(hh in exerTm)) exerTm[hh]=t; }
		});

		// 측정이 없는 시간에 식사·운동만 있으면 표식 자리(HH:00, 값 없음)를 만들어 준다
		var haveHour = {};
		pts.forEach(function(p){ haveHour[p.hm.substring(0,2)] = 1; });
		Object.keys(foodMap).concat(Object.keys(exerMap)).forEach(function(hh){
			if (!haveHour[hh]) { pts.push({ hm: hh+':00', v:null }); haveHour[hh]=1; }
		});
		pts.sort(function(a,b){ return a.hm.localeCompare(b.hm); });

		var xs = pts.map(function(p){ return p.hm; });    // 'HH:MM'
		var ys = pts.map(function(p){ return p.v; });

		// 평가 패널용 시간별 평균(종전 그대로)
		var hours = Object.keys(haveHour).sort();
		var evalYs = hours.map(function(h){ return buckets[h] ? Math.round(buckets[h].sum/buckets[h].cnt) : null; });

		// 식사/운동 마커 — 기록 시각과 가장 가까운 측정 시점에 배치
		// 같은 시간에 식사·운동이 겹쳐도 세로로 분리되도록 충분히 간격(FOOD 위 / EXER 아래)
		var evMin = function(t){ return parseInt(t.substring(0,2),10)*60 + (parseInt(t.substring(2,4),10)||0); };   // 'HHMM…'
		var hmMin = function(hm){ return parseInt(hm.substring(0,2),10)*60 + (parseInt(hm.substring(3,5),10)||0); }; // 'HH:MM'
		var nearestIdx = function(t){
			var m = evMin(t), best = -1, bd = 1e9;
			for (var i=0;i<xs.length;i++){ var d = Math.abs(hmMin(xs[i])-m); if (d < bd){ bd = d; best = i; } }
			return best;
		};
		var FOOD_Y = 290, EXER_Y = 258;
		var foodPts = xs.map(function(){ return null; });
		var exerPts = xs.map(function(){ return null; });
		// 식사·운동이 있는 시점에 세로 점선 표시 (마커를 타임라인에 연결)
		var eventLines = [];
		Object.keys(foodTm).forEach(function(hh){ var i=nearestIdx(foodTm[hh]); if(i>=0){ foodPts[i]=FOOD_Y; eventLines.push({ xAxis: xs[i] }); } });
		Object.keys(exerTm).forEach(function(hh){ var i=nearestIdx(exerTm[hh]); if(i>=0){ exerPts[i]=EXER_Y; eventLines.push({ xAxis: xs[i] }); } });

		if (!rows.length && !foodRows.length && !exerRows.length) {
			$("#lineChart").html('<div class="text-center text-muted p-3">'+label+' 데이터 없음</div>');
			return;
		}
		$("#lineChart").empty();

		var chart = echarts.init(lineDom);
		chart.setOption({
			tooltip: {
				trigger:'axis',
				formatter: function(params){
					if(!params||!params.length) return '';
					var hh=String(params[0].axisValue||'').substring(0,2);
					var bv=null;
					params.forEach(function(p){ if(p.seriesName==='혈당'&&p.value!=null) bv=p.value; });
					var txt=params[0].axisValue+'<br/>혈당: <b>'+(bv!=null?bv+' mg/dL':'기록 없음')+'</b>';
					if(foodMap[hh]) txt+='<br/>🍚 식사: '+foodMap[hh].join(', ');
					if(exerMap[hh]) txt+='<br/>🚴 운동: '+exerMap[hh].join(', ');
					return txt;
				}
			},
			legend: { show:false },
			grid: { left:40, right:16, top:20, bottom:30 },
			xAxis: { type:'category', data:xs, axisTick:{ alignWithLabel:true },
				// 5분 간격 원본이라 라벨은 각 시(時)의 첫 측정에만 'HH시'로 표시
				axisLabel:{ interval:function(i){ return i===0 || (xs[i]||'').substring(0,2)!==(xs[i-1]||'').substring(0,2); },
				            formatter:function(v){ return String(v).substring(0,2)+'시'; } } },
			yAxis: { type:'value', min:0, max:300 },
			series: [
				{
					name:'혈당',
					type:'line', data:ys, smooth:true, areaStyle:{}, connectNulls:true,
					symbol:'circle', symbolSize:3,
					// 원본 전체를 찍으므로 점마다 숫자 라벨은 생략 — 값은 툴팁·최고/최저 마커로 확인
					label:{ show:false },
					markPoint: { data:[
						{ type:'max', name:'최고', itemStyle:{ color:'#dc3545' } },
						{ type:'min', name:'최저', itemStyle:{ color:'#f5c518' } }
					]},
					markLine: {
						silent:true, symbol:'none',
						lineStyle:{ type:'dashed', color:'#c0c4cc', width:1 },
						label:{ show:false },
						data: eventLines
					}
				},
				{ name:'식사', type:'scatter', data:foodPts, symbolSize:1,
				  label:{ show:true, formatter:'🍚', fontSize:20, position:'inside' } },
				{ name:'운동', type:'scatter', data:exerPts, symbolSize:1,
				  label:{ show:true, formatter:'🚴', fontSize:20, position:'inside' } }
			]
		});
		// 혈당 평가 패널 업데이트 — 종전대로 시간별 평균(evalYs) 기준
		updateEvalPanel(hours, evalYs, foodMap, exerMap, label);
	}).fail(function(xhr){
		$("#lineChart").html('<div class="text-center text-danger p-3">시간대별 조회 실패 (HTTP '+(xhr&&xhr.status)+')</div>');
	});
}

function formatDate(d){
	var z=function(n){return (n<10?'0':'')+n;};
	return d.getFullYear()+'-'+z(d.getMonth()+1)+'-'+z(d.getDate())+'T'+z(d.getHours())+':'+z(d.getMinutes())+':'+z(d.getSeconds());
}
function formatDay(d){
	var z=function(n){return (n<10?'0':'')+n;};
	return d.getFullYear()+'-'+z(d.getMonth()+1)+'-'+z(d.getDate());
}
// DTM 값(숫자 epoch / 'YYYY-MM-DD HH:MM:SS' / ISO 문자열)을 'HH:MM' 으로 변환
function toHM(v){
	if (v == null) return '';
	var z=function(n){return (n<10?'0':'')+n;};
	if (typeof v === 'number') { var d=new Date(v); return z(d.getHours())+':'+z(d.getMinutes()); }
	var s = String(v);
	var m = s.match(/(\d{2}):(\d{2})/);
	return m ? (m[1]+':'+m[2]) : s;
}
function formatTime(s){ return s ? s.replace('T',' ').substring(0,16) : ''; }

/* ── ⚙ 설정 모달: 케어센스 연동 + 모바일 접속 QR ──
   사이드바가 숨는 모바일에서도 상단 ⚙ 버튼으로 열 수 있다(= 모바일 설정 기능). */
function openSettings(){
	loadTokenStatus();          // 모달 안 상태(#tokenStatus2 등)도 같이 갱신됨
	_renderLoginQr();
	// ⚠ new bootstrap.Modal 로 매번 새로 만들면 인스턴스가 중복돼
	//   두 번째 열기부터 백드롭만 남고 본체가 안 뜬다 — getOrCreateInstance 필수
	bootstrap.Modal.getOrCreateInstance(document.getElementById('settingsModal')).show();
}
/* 모바일 앱(PWA) 설치 안내 페이지를 QR로 그려준다 — 인쇄 배포용 QR과 같은 주소.
   휴대폰 카메라로 찍으면 allCare 설치 화면이 열린다. (토큰·개인정보는 담지 않는다) */
function _renderLoginQr(){
	var box = document.getElementById('settingsQr');
	if (!box || box.getAttribute('data-done') === '1') return;
	var url = 'https://allcare24.kr/app/install.html';
	$('#settingsQrUrl').text(url);
	if (typeof qrcode === 'undefined') {
		box.innerHTML = '<div class="text-muted small">QR 라이브러리를 불러오지 못했습니다(네트워크 확인).</div>';
		return;
	}
	try {
		var qr = qrcode(0, 'M');   // typeNumber 0 = 자동
		qr.addData(url); qr.make();
		var count = qr.getModuleCount(), margin = 4;
		var cell  = Math.max(1, Math.floor(190 / (count + margin*2)));
		var px    = cell * (count + margin*2);
		var cv = document.createElement('canvas'); cv.width = px; cv.height = px;
		var ctx = cv.getContext('2d');
		ctx.fillStyle = '#fff'; ctx.fillRect(0, 0, px, px);
		ctx.fillStyle = '#000';
		for (var r = 0; r < count; r++) for (var c = 0; c < count; c++)
			if (qr.isDark(r, c)) ctx.fillRect((c+margin)*cell, (r+margin)*cell, cell, cell);
		box.innerHTML = ''; box.appendChild(cv);
		box.setAttribute('data-done', '1');
	} catch(e) {
		box.innerHTML = '<div class="text-muted small">QR 생성 실패: ' + (e && e.message ? e.message : e) + '</div>';
	}
}

/* 동의하기 — 앱 가입 검증과 동일(항목별 미체크 안내) 후 저장, 저장되면 내역을 다시 그린다 */
function agreeAllTerms(){
	var need = [ {gb:'3', msg:'서비스 이용약관에 동의해주세요.'}, {gb:'1', msg:'개인정보 수집 이용동의 항목에 동의해주세요.'}, {gb:'2', msg:'고유식별정보 처리동의 항목에 동의해주세요.'} ];
	for (var i=0; i<need.length; i++){
		var $c = $('.agChk[data-gb="'+need[i].gb+'"]');
		if ($c.length && !$c.prop('checked')){ _alertBox(need[i].msg, { icon:'⚠️' }); return; }
	}
	_confirmBox({
		icon:'📝', okText:'동의', okColor:'blue',
		msg:'서비스 이용약관 · 개인정보 수집·이용 · 고유식별정보 처리에<br>모두 동의하시겠습니까?',
		onOk:function(){
			$.ajax({ url:CommonUtil.getContextPath()+'/patient/agreeAll.do', type:'post', dataType:'json',
				success:function(r){
					if (r && r.IsSucceed){ _toast(r.Message || '동의가 저장되었습니다.', 'ok'); openAgreeList(); }
					else _toast((r && r.Message) || '저장 실패', 'err');
				},
				error:function(){ _toast('저장 요청 오류', 'err'); }
			});
		}
	});
}

/* ── 📝 개인정보 약관 동의 내역 — T_PERSIGN_TRAN(본인) ── */
function openAgreeList(){
	$('#termsTitle').text('📝 약관동의');
	$('#termsBody').html('<div class="text-center text-muted py-4">불러오는 중…</div>');
	bootstrap.Modal.getOrCreateInstance(document.getElementById('termsModal')).show();
	$.ajax({
		url: CommonUtil.getContextPath()+'/patient/myAgreeList.do', type:'post', dataType:'json',
		success:function(r){
			var rows = (r && r.IsSucceed && r.Data) ? r.Data : [];
			/* 앱 login.jsp 「약관동의」 블록과 같은 구성: [전체 동의] + 서비스 이용약관 / 개인정보 수집·이용동의 / 고유식별정보 처리동의
			   (항목명 클릭 = 내용 보기, 우측 체크박스). 이미 동의한 항목은 체크·잠금 + 동의 일시 표시. */
			var TERMS = [ {gb:'3', nm:'서비스 이용약관'}, {gb:'1', nm:'개인정보 수집·이용동의'}, {gb:'2', nm:'고유식별정보 처리동의'} ];
			var latest = {};
			rows.forEach(function(d){ var g=String(d.termsGb||''); if(!latest[g]) latest[g]=d; });   // 최신순 → 첫 행이 최신
			var agreedAll = TERMS.every(function(t){ var d=latest[t.gb]; return d && d.agreeYn==='Y'; });
			var h = '<div class="agree-list">'
			      + '<div class="agree-item all"><span>전체 동의</span><input type="checkbox" id="agChkAll" '+(agreedAll?'checked disabled':'')+'></div>';
			TERMS.forEach(function(t){
				var d = latest[t.gb], done = d && d.agreeYn==='Y';
				h += '<div class="agree-item">'
				   + '<a href="javascript:void(0)" onclick="openTerms('+t.gb+',\''+t.nm+'\');">'+t.nm+' <span class="text-muted">&rsaquo;</span></a>'
				   + '<span class="agree-right">'+(done ? '<small class="text-muted">동의 '+(d.agreeDtm||'')+'</small>' : '')
				   + '<input type="checkbox" class="agChk" data-gb="'+t.gb+'" '+(done?'checked disabled':'')+'></span>'
				   + '</div>';
			});
			h += '</div>';
			if (agreedAll){
				h += '<div class="text-center" style="color:#2e7d32;font-weight:700;padding:14px 0 4px;">✅ 모든 약관에 동의하셨습니다.</div>';
			} else {
				h += '<div class="text-muted" style="font-size:12.5px;margin:10px 0;">항목명을 누르면 내용을 볼 수 있습니다. 모두 체크한 뒤 [동의하기]를 눌러 주세요.</div>'
				   + '<div class="text-end"><button type="button" id="agSubmit" class="btn btn-primary btn-sm px-4" onclick="agreeAllTerms();">동의하기</button></div>';
			}
			$('#termsBody').html(h);
			// [전체 동의] ↔ 개별 체크 동기화 (앱 toggleAllAgree / syncAgreeAll 과 동일)
			$('#agChkAll').on('change', function(){ $('.agChk:not(:disabled)').prop('checked', this.checked); });
			$('.agChk').on('change', function(){ $('#agChkAll').prop('checked', $('.agChk').length === $('.agChk:checked').length); });
		},
		error:function(){ $('#termsBody').html('<div class="text-center text-danger py-4">동의 내역을 불러오지 못했습니다.</div>'); }
	});
}

/* ── 📜 약관 보기 — 앱 설정의 getSignList(3=이용약관/1=개인정보/2=민감정보)와 동일 ── */
function openTerms(gb, title){
	// 본문은 별도 모달(#termsViewModal)에 — 약관동의 목록(#termsModal) 위에 겹쳐 뜨고, 닫으면 목록으로 돌아온다
	$('#termsViewTitle').text('📜 ' + title);
	$('#termsViewBody').html('<div class="text-center text-muted py-4">불러오는 중…</div>');
	bootstrap.Modal.getOrCreateInstance(document.getElementById('termsViewModal')).show();
	$.ajax({
		url: CommonUtil.getContextPath()+'/getSignList.do',
		type:'post', data:JSON.stringify({ termsGb: gb }), contentType:'application/json', dataType:'json',
		success:function(r){
			var rows = (r && r.Data) ? r.Data : [];
			if (!rows.length){
				$('#termsViewBody').html('<div class="text-center text-muted py-4">등록된 약관 내용이 없습니다.</div>');
				return;
			}
			// 약관 본문은 T_SIGN_MST 에 문단 단위 여러 행으로 저장돼 있다 — 순서대로 이어붙임
			$('#termsViewBody').html(rows.map(function(d){
				return '<p style="margin:0 0 8px;">' + _faqEsc(d.termsConts||'') + '</p>';
			}).join(''));
		},
		error:function(){ $('#termsViewBody').html('<div class="text-center text-danger py-4">약관을 불러오지 못했습니다.</div>'); }
	});
}

function logout(){
	_confirmBox({
		icon:'🔓', okText:'로그아웃', okColor:'blue',
		msg:'로그아웃 하시겠습니까?',
		onOk:function(){
			// 단순 GET: 서버에서 session.invalidate() 후 /login.do 로 forward
			location.href = (sessionStorage.getItem("contextPath")||"") + "/user/loginOutAct.do";
		}
	});
}
/* ── 공통 헬퍼 ── */
function pad(n){ 
	return (n<10?'0':'')+n; 
}
// 현재 시간대별 차트에 표시된 날짜 추적
var _currentDayKey = null, _currentDayLabel = null;
// "2026-05-29" → "5/29" 레이블 변환
function _dayLabel(dateKey){
	var p=(dateKey||'').split('-');
	return p.length===3 ? parseInt(p[1])+'/'+parseInt(p[2]) : dateKey;
}
function localDate(d){ 
	return d.getFullYear()+'-'+pad(d.getMonth()+1)+'-'+pad(d.getDate()); 
}
function fmtT(s){ 
	if(!s||s.length<4) return s||''; 
	return s.substring(0,2)+':'+s.substring(2,4); 
}
function fmtD(s){ 
	if(!s||s.length<8) 
		return s||''; 
	return s.substring(0,4)+'-'+s.substring(4,6)+'-'+s.substring(6,8); 
}
/* HH:MM (time input) → HHMMSS (서버 전송용) */
function toHHMMSS(hhmm){ 
	if(!hhmm) 
		return ''; 
	var p=hhmm.replace(':',''); 
	return p.length>=4 ? p.substring(0,4)+'00' : ''; 
}
/* HH:MM:SS 현재 시각 */
function nowHHMM(){
	var t=new Date(); 
	return pad(t.getHours())+':'+pad(t.getMinutes()); 
}

/* ── 식사 기록 모달 ── */
function goFood(){
	_initFoodPicker();
	var t = new Date();
	$('#mFoodDate').val(localDate(t));
	$('#mFoodStime').val(nowHHMM());
	$('#mFoodEtime,#mFoodName,#mFoodDanwi,#mFoodAcnt').val('');
	loadFoodList();
	new bootstrap.Modal(document.getElementById('foodModal')).show();
}
function saveFood(){
	var dto = {
		userUuid: userUuid,
		eatDate:  $('#mFoodDate').val(),
		eatStime: toHHMMSS($('#mFoodStime').val()),
		eatEtime: toHHMMSS($('#mFoodEtime').val()),
		foodName: $.trim($('#mFoodName').val()),
		foodDanwi:$.trim($('#mFoodDanwi').val()),
		foodAcnt: $.trim($('#mFoodAcnt').val())
	};
	if (!dto.foodName){ _toast('음식명을 입력하세요.', 'warn'); return; }
	if (!dto.eatStime||dto.eatStime.length!==6){ _toast('시작시간을 선택하세요.', 'warn'); return; }
	$.ajax({
		url: CommonUtil.getContextPath()+'/updateFood.do',
		type:'post', data:$.param(dto), dataType:'json',
		success:function(r){
			if(r.IsSucceed){
				$('#mFoodName').val('');
				loadFoodList();
				// 저장한 날짜로 시간대별 차트 즉시 갱신
				var k=dto.eatDate, lbl=_dayLabel(k);
				loadDayChart(k, lbl);
				// 막대 차트도 갱신 (주간 평균 반영)
				drawChart();
				_toast('식사 기록을 저장했어요', 'ok');
			} else _toast('저장 실패', 'err');
		}
	});
}
function loadFoodList(){
	$('#mFoodList').html('<tr><td colspan="6" class="text-center text-muted py-2">불러오는 중…</td></tr>');
	$.ajax({
		url: CommonUtil.getContextPath()+'/getFoodInfo.do',
		type:'post', data:JSON.stringify({userUuid:userUuid}),
		contentType:'application/json', dataType:'json',
		success:function(r){
			var rows = r&&r.Data ? r.Data : [];
			if(!rows.length){ $('#mFoodList').html('<tr><td colspan="6" class="text-center text-muted py-3">기록 없음</td></tr>'); return; }
			var h='';
			rows.forEach(function(row){
				var d=row.eatDate||'', s=row.eatStime||'';
				h+='<tr>'
				 +'<td>'+fmtD(d)+'</td>'
				 +'<td>'+fmtT(s)+'</td>'
				 +'<td>'+(row.eatEtime?fmtT(row.eatEtime):'-')+'</td>'
				 +'<td>'+(row.foodName||'')+'</td>'
				 +'<td class="text-end">'+(row.foodCnt||0)+'</td>'
				 +'<td class="text-center"><button class="btn btn-outline-danger btn-sm py-0 px-2" style="font-size:12px;" onclick="delFood(\''+d+'\',\''+s+'\')">삭제</button></td>'
				 +'</tr>';
			});
			$('#mFoodList').html(h);
		}
	});
}
function delFood(eatDate, eatStime){
	_confirmBox({
		icon:'🍚', okText:'삭제',
		msg:fmtD(eatDate)+' '+fmtT(eatStime)+'<br>식사 기록을 삭제할까요?',
		onOk:function(){
			$.ajax({
				url: CommonUtil.getContextPath()+'/deleteFoodData.do',
				type:'post',
				data: JSON.stringify({userUuid:userUuid, eatDate:eatDate, eatStime:eatStime}),
				contentType:'application/json', dataType:'json',
				success:function(r){
					if(r.IsSucceed){
						loadFoodList();
						if(_currentDayKey) loadDayChart(_currentDayKey, _currentDayLabel);
						_toast('삭제했어요', 'ok');
					} else _toast('삭제 실패', 'err');
				}
			});
		}
	});
}

/* ── 운동 기록 모달 ── */
function goExer(){
	_initExerPicker();
	var t = new Date();
	$('#mExerDate').val(localDate(t));
	$('#mExerStime').val(nowHHMM());
	$('#mExerEtime,#mExerName,#mExerCnt').val('');
	$('#mExerInt').val('M');
	loadExerList();
	new bootstrap.Modal(document.getElementById('exerModal')).show();
}
function saveExer(){
	var dto = {
		userUuid: userUuid,
		exerDate: $('#mExerDate').val(),
		exerStime:toHHMMSS($('#mExerStime').val()),
		exerEtime:toHHMMSS($('#mExerEtime').val()),
		exerName: $.trim($('#mExerName').val()),
		exerInt:  $('#mExerInt').val(),
		exerCnt:  $('#mExerCnt').val() ? parseInt($('#mExerCnt').val(),10) : 0
	};
	if (!dto.exerName){ _toast('운동명을 입력하세요.', 'warn'); return; }
	if (!dto.exerStime||dto.exerStime.length!==6){ _toast('시작시간을 선택하세요.', 'warn'); return; }
	$.ajax({
		url: CommonUtil.getContextPath()+'/updateExer.do',
		type:'post', data:$.param(dto), dataType:'json',
		success:function(r){
			if(r.IsSucceed){
				$('#mExerName').val('');
				loadExerList();
				// 저장한 날짜로 시간대별 차트 즉시 갱신
				var k=dto.exerDate, lbl=_dayLabel(k);
				loadDayChart(k, lbl);
				drawChart();
				_toast('운동 기록을 저장했어요', 'ok');
			} else _toast('저장 실패', 'err');
		}
	});
}
function loadExerList(){
	$('#mExerList').html('<tr><td colspan="6" class="text-center text-muted py-2">불러오는 중…</td></tr>');
	$.ajax({
		url: CommonUtil.getContextPath()+'/getExerInfo.do',
		type:'post', data:JSON.stringify({userUuid:userUuid}),
		contentType:'application/json', dataType:'json',
		success:function(r){
			var rows = r&&r.Data ? r.Data : [];
			if(!rows.length){ $('#mExerList').html('<tr><td colspan="6" class="text-center text-muted py-3">기록 없음</td></tr>'); return; }
			var h='';
			rows.forEach(function(row){
				var d=row.exerDate||'', s=row.exerStime||'';
				h+='<tr>'
				 +'<td>'+fmtD(d)+'</td>'
				 +'<td>'+fmtT(s)+'</td>'
				 +'<td>'+(row.exerEtime?fmtT(row.exerEtime):'-')+'</td>'
				 +'<td>'+(row.exerName||'')+'</td>'
				 +'<td class="text-end">'+(row.totalCnt||0)+'</td>'
				 +'<td class="text-center"><button class="btn btn-outline-danger btn-sm py-0 px-2" style="font-size:12px;" onclick="delExer(\''+d+'\',\''+s+'\')">삭제</button></td>'
				 +'</tr>';
			});
			$('#mExerList').html(h);
		}
	});
}
function delExer(exerDate, exerStime){
	_confirmBox({
		icon:'🚴', okText:'삭제',
		msg:fmtD(exerDate)+' '+fmtT(exerStime)+'<br>운동 기록을 삭제할까요?',
		onOk:function(){
			$.ajax({
				url: CommonUtil.getContextPath()+'/deleteExerData.do',
				type:'post',
				data: JSON.stringify({userUuid:userUuid, exerDate:exerDate, exerStime:exerStime}),
				contentType:'application/json', dataType:'json',
				success:function(r){
					if(r.IsSucceed){
						loadExerList();
						if(_currentDayKey) loadDayChart(_currentDayKey, _currentDayLabel);
						_toast('삭제했어요', 'ok');
					} else _toast('삭제 실패', 'err');
				}
			});
		}
	});
}

/* ── Flatpickr: 모달 첫 오픈 시 초기화 (페이지 로드 지연 방지) ── */
var _fpInit = { food:false, exer:false };
var _markerClicked = false; // 마커 클릭 팝업 표시 중 document click 무시용
function _initFoodPicker(){
	if (_fpInit.food || typeof flatpickr === 'undefined') return;
	_fpInit.food = true;
	flatpickr('#mFoodDate',  { locale:'ko', dateFormat:'Y-m-d', allowInput:true });
	var tp = { enableTime:true, noCalendar:true, dateFormat:'H:i', time_24hr:true };
	flatpickr('#mFoodStime', tp);
	flatpickr('#mFoodEtime', tp);
}
function _initExerPicker(){
	if (_fpInit.exer || typeof flatpickr === 'undefined') return;
	_fpInit.exer = true;
	flatpickr('#mExerDate',  { locale:'ko', dateFormat:'Y-m-d', allowInput:true });
	var tp = { enableTime:true, noCalendar:true, dateFormat:'H:i', time_24hr:true };
	flatpickr('#mExerStime', tp);
	flatpickr('#mExerEtime', tp);
}

/* ══════════════════════════════════════
   자주하는 질문 (FAQ)  —  /admin/faqList.do (T_FAQ_TRAN) 재사용
══════════════════════════════════════ */
function openFaq(){
	new bootstrap.Modal(document.getElementById('faqModal')).show();
	if (window._faqAll) renderFaq(window._faqAll);   // 이미 로드됨 → 즉시 표시
	else loadFaqList();
}
function loadFaqList(){
	$('#faqList').html('<div class="text-center text-muted py-4">불러오는 중…</div>');
	$.ajax({
		url: CommonUtil.getContextPath()+'/admin/faqList.do',
		type:'post', data:{ searchGb:'ALL', searchText:'' }, dataType:'json',
		success:function(r){
			var rows = (r && r.resultLst) ? r.resultLst : [];
			// 사용중(USE_YN!=='N') FAQ만 노출
			window._faqAll = rows.filter(function(x){ return (x.useYn||'Y') !== 'N'; });
			$('#faqSearch').val('');
			renderFaq(window._faqAll);
		},
		error:function(){ $('#faqList').html('<div class="text-center text-danger py-4">FAQ를 불러오지 못했습니다.</div>'); }
	});
}
function _faqGbLabel(gb){ return gb==='T'?'공통':gb==='A'?'앱':gb==='W'?'웹':'기타'; }
function _faqGbColor(gb){ return gb==='T'?'#6c757d':gb==='A'?'#198754':gb==='W'?'#0d6efd':'#adb5bd'; }
function _faqEsc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function renderFaq(rows){
	if(!rows || !rows.length){ $('#faqList').html('<div class="text-center text-muted py-4">등록된 FAQ가 없습니다.</div>'); return; }
	var h='<div class="accordion" id="faqAcc">';
	rows.forEach(function(d, i){
		var gb=d.faqGb||'';
		h+='<div class="accordion-item border-0 mb-2 shadow-sm" style="border-radius:10px;overflow:hidden;">'
		 +'<h2 class="accordion-header">'
		 +'<button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faqC'+i+'" style="font-size:14.5px;font-weight:600;">'
		 +'<span style="display:inline-block;min-width:34px;text-align:center;font-size:11px;font-weight:700;color:#fff;background:'+_faqGbColor(gb)+';border-radius:6px;padding:2px 6px;margin-right:10px;">'+_faqGbLabel(gb)+'</span>'
		 +_faqEsc(d.qstnConts)
		 +'</button></h2>'
		 +'<div id="faqC'+i+'" class="accordion-collapse collapse" data-bs-parent="#faqAcc">'
		 +'<div class="accordion-body" style="font-size:14px;line-height:1.7;color:#333;white-space:pre-wrap;">'+_faqEsc(d.ansrConts)+'</div>'
		 +'</div></div>';
	});
	h+='</div>';
	$('#faqList').html(h);
}
function _faqFilter(){
	if(!window._faqAll) return;
	var q=$.trim($('#faqSearch').val()).toLowerCase();
	if(!q){ renderFaq(window._faqAll); return; }
	renderFaq(window._faqAll.filter(function(d){
		return (String(d.qstnConts||'').toLowerCase().indexOf(q)!==-1)
		    || (String(d.ansrConts||'').toLowerCase().indexOf(q)!==-1);
	}));
}

/* ══════════════════════════════════════
   📢 공지사항 — /admin/noticeList.do (T_NOTICE) 재사용 (FAQ 와 같은 패턴)
══════════════════════════════════════ */
function openNotice(){
	bootstrap.Modal.getOrCreateInstance(document.getElementById('noticeModal')).show();
	loadNoticeList();
}
function loadNoticeList(){
	$('#noticeList').html('<div class="text-center text-muted py-4">불러오는 중…</div>');
	$.ajax({
		/* ⚠/admin/noticeList.do 는 날짜 파라미터 필수 + 관리자 조인이라 환자 화면에선 0건.
		   앱(getNotiList)과 같은 조건의 전용 API 사용 [2026-10-21] */
		url: CommonUtil.getContextPath()+'/patient/noticeList.do',
		type:'post', dataType:'json',
		success:function(r){
			var rows = (r && r.IsSucceed && r.Data) ? r.Data : [];
			if(!rows.length){ $('#noticeList').html('<div class="text-center text-muted py-4">등록된 공지사항이 없습니다.</div>'); return; }
			var h='<div class="accordion" id="ntAcc">';
			rows.forEach(function(d, i){
				var dt = String(d.regDtm||'').replace('T',' ').substring(0,10);
				h+='<div class="accordion-item border-0 mb-2 shadow-sm" style="border-radius:10px;overflow:hidden;">'
				 +'<h2 class="accordion-header">'
				 +'<button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#ntC'+i+'" style="font-size:14.5px;font-weight:600;">'
				 +'<span class="text-muted me-2" style="font-size:12px;">'+dt+'</span>'+_faqEsc(d.title)
				 +'</button></h2>'
				 +'<div id="ntC'+i+'" class="accordion-collapse collapse" data-bs-parent="#ntAcc">'
				 +'<div class="accordion-body" style="font-size:14px;line-height:1.7;color:#333;white-space:pre-wrap;">'+_faqEsc(d.expln)+'</div>'
				 +'</div></div>';
			});
			h+='</div>';
			$('#noticeList').html(h);
		},
		error:function(){ $('#noticeList').html('<div class="text-center text-danger py-4">공지사항을 불러오지 못했습니다.</div>'); }
	});
}

/* ══════════════════════════════════════
   👤 개인정보 변경 — /patient/myInfo.do · myInfoSave.do (이메일·키·몸무게만 수정)
══════════════════════════════════════ */
function openMyInfo(){
	bootstrap.Modal.getOrCreateInstance(document.getElementById('myInfoModal')).show();
	$.ajax({
		url: CommonUtil.getContextPath()+'/patient/myInfo.do', type:'post', dataType:'json',
		success:function(r){
			var d = (r && r.IsSucceed && r.Data) ? r.Data : {};
			$('#miNm').val(d.userNm||'');
			$('#miPhone').val(d.phone||'');
			var b = String(d.birth||'');
			$('#miBirth').val(b.length===8 ? b.substring(0,4)+'-'+b.substring(4,6)+'-'+b.substring(6,8) : b);
			$('#miGender').val(d.gender==='F' ? '여성' : d.gender==='M' ? '남성' : '');
			$('#miEmail').val(d.email||'');
			$('#miHeight').val(d.height||'');
			$('#miWeight').val(d.weight||'');
			$('#miBlodGb').val(String(d.blodGb||0));
		},
		error:function(){ _toast('내 정보를 불러오지 못했습니다.', 'err'); }
	});
}
function saveMyInfo(){
	var email = $.trim($('#miEmail').val());
	if (email && !/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/.test(email)){
		_toast('이메일 형식이 올바르지 않습니다.', 'warn'); $('#miEmail').focus(); return;
	}
	var dto = {
		email:  email,
		height: parseInt($('#miHeight').val(), 10) || 0,
		weight: parseInt($('#miWeight').val(), 10) || 0,
		blodGb: parseInt($('#miBlodGb').val(), 10) || 0
	};
	$.ajax({
		url: CommonUtil.getContextPath()+'/patient/myInfoSave.do',
		type:'post', data:JSON.stringify(dto), contentType:'application/json', dataType:'json',
		success:function(r){
			if(r && r.IsSucceed){
				_toast('저장했어요', 'ok');
				bootstrap.Modal.getOrCreateInstance(document.getElementById('myInfoModal')).hide();
			} else _toast((r && r.Message) || '저장 실패', 'err');
		},
		error:function(){ _toast('저장 요청 오류', 'err'); }
	});
}

/* ══════════════════════════════════════
   세부혈당그래프 — 의사용 APME_01A_2(개요/AGP/혈당그래프/통계) 재사용
   · /tab/tabInfo.do 로 본인 정보를 세션(t_*)에 세팅 → /tab/tab.do 새 창
══════════════════════════════════════ */
// iframe 내부(동일 출처)에 상단 공통 헤더(allCare 바) 숨김 CSS 주입 — 동적 렌더 대비 최대 2초 반복
function _dgHideHeader(frame){
	var tries = 0;
	(function inject(){
		try {
			var doc = frame.contentDocument || (frame.contentWindow && frame.contentWindow.document);
			if (doc && doc.body && !doc.getElementById('_dgHideStyle')) {
				var st = doc.createElement('style');
				st.id = '_dgHideStyle';
				st.textContent = '.gnb-container,#header{display:none!important;}'
					+ ' html,body,#wrap,#contents{margin:0!important;padding-top:0!important;}'
					+ ' #printableArea,.content-body{padding-top:6px!important;}';
				(doc.head || doc.documentElement).appendChild(st);
			}
		} catch(e){}
		if (++tries < 20) setTimeout(inject, 100);
	})();
}
/* [2026-10-21] 풀스크린 모달 → 메뉴 우측 본문 전환 뷰로 변경.
   개인(환자) 화면에서는 모달 오버레이가 어색하다는 지적 — 좌측 메뉴를 그대로 두고
   본문만 홈 ↔ 세부그래프로 바뀌는 일반 페이지처럼 동작한다. */
function openDetailGraph(){
	// 1) 본인 정보를 세션(t_*)에 세팅 → 2) 본문 iframe 으로 APME_01A_2(/tab/tab.do) 로드 → 3) 뷰 전환
	$.ajax({
		url: CommonUtil.getContextPath()+'/tab/tabInfo.do',
		type:'post', data:{ userUuid: userUuid }, dataType:'json',
		success:function(){
			// 래핑 버전(데이터 정상) + embed=1(서버측 헤더 미렌더). 클라이언트측에서도 헤더 숨김 주입(이중 보장)
			// 깜빡임 방지: 헤더 제거 전까지 iframe 을 숨겨두고, load 시점에 헤더 제거 후 표시
			var $f = $('#detailInlineFrame');
			if (!$f.attr('src') || $f.attr('src') === 'about:blank') {
				$f.css('visibility','hidden');
				$f.off('load.dg').on('load.dg', function(){
					_dgHideHeader(this);              // load 시점 = DOM 완성 → 즉시 헤더 숨김
					$(this).css('visibility','visible');
				});
				$f.attr('src', CommonUtil.getContextPath()+'/tab/tab.do?embed=1');
			}
			_showView('detail');
		},
		error:function(){
			_alertBox('세부 혈당 그래프를 여는 중 오류가 발생했습니다.', { icon:'⚠️', okColor:'red' });
		}
	});
}
function showHomeView(){ _showView('home'); }
function _showView(v){
	$('#viewHome').toggleClass('hidden', v !== 'home');
	$('#viewDetail').toggleClass('hidden', v !== 'detail');
	$('#viewAi').toggleClass('hidden', v !== 'ai');
	$('#snHome').toggleClass('active', v === 'home');
	$('#snDetail').toggleClass('active', v === 'detail');
	$('#snAi').toggleClass('active', v === 'ai');
	try{ window.scrollTo(0, 0); }catch(e){}
}

/* ══════════════════════════════════════
   1:1 문의 (질의응답)  —  /patient/myAsq*.do (T_ASQ_TRAN, 세션 userUuid)
══════════════════════════════════════ */
function openAsq(){
	new bootstrap.Modal(document.getElementById('asqModal')).show();
	loadAsqList();
}
function loadAsqList(){
	$('#asqList').html('<div class="text-center text-muted py-4">불러오는 중…</div>');
	$.ajax({
		url: CommonUtil.getContextPath()+'/patient/myAsqList.do',
		type:'post', dataType:'json',
		success:function(r){ renderAsq((r && r.resultLst) ? r.resultLst : []); },
		error:function(){ $('#asqList').html('<div class="text-center text-danger py-4">문의 내역을 불러오지 못했습니다.</div>'); }
	});
}
function saveAsq(){
	var conts = $.trim($('#asqInput').val());
	if(!conts){ _alertBox('문의 내용을 입력하세요.', { icon:'💬' }); return; }
	$.ajax({
		url: CommonUtil.getContextPath()+'/patient/myAsqSave.do',
		type:'post', data:{ qstnConts:conts }, dataType:'json',
		success:function(r){
			if(r && r.error_code==='0'){ $('#asqInput').val(''); loadAsqList(); _alertBox('문의가 등록되었습니다.', { icon:'✅' }); }
			else _alertBox('등록에 실패했습니다. 다시 시도해 주세요.', { icon:'⚠️', okColor:'red' });
		},
		error:function(){ _alertBox('시스템 오류입니다. 다시 시도해 주세요.', { icon:'⚠️', okColor:'red' }); }
	});
}
function delAsq(seq){
	_confirmBox({
		icon:'💬', okText:'삭제',
		msg:'이 문의를 삭제할까요?',
		onOk:function(){
			$.ajax({
				url: CommonUtil.getContextPath()+'/patient/myAsqDelete.do',
				type:'post', data:{ asqSeq:seq }, dataType:'json',
				success:function(r){
					if(r && r.error_code==='0'){ loadAsqList(); _alertBox('삭제되었습니다.', { icon:'🗑️' }); }
					else _alertBox('삭제에 실패했습니다. 다시 시도해 주세요.', { icon:'⚠️', okColor:'red' });
				},
				error:function(){ _alertBox('시스템 오류입니다. 다시 시도해 주세요.', { icon:'⚠️', okColor:'red' }); }
			});
		}
	});
}
function _asqYmd(s){ s=String(s==null?'':s); return s.replace('T',' ').substring(0,16); }
function renderAsq(rows){
	if(!rows || !rows.length){ $('#asqList').html('<div class="text-center text-muted py-4">등록된 문의가 없습니다.</div>'); return; }
	var h='<div class="accordion" id="asqAcc">';
	rows.forEach(function(d, i){
		var answered = (d.ansrYn==='Y' && d.ansrConts && $.trim(d.ansrConts)!=='');
		var badge = answered
			? '<span style="font-size:11px;font-weight:700;color:#fff;background:#198754;border-radius:6px;padding:2px 7px;margin-right:10px;">답변완료</span>'
			: '<span style="font-size:11px;font-weight:700;color:#fff;background:#adb5bd;border-radius:6px;padding:2px 7px;margin-right:10px;">답변대기</span>';
		var ansHtml = answered
			? '<div style="margin-top:10px;padding:10px 12px;background:#eef4ff;border-radius:8px;font-size:14px;line-height:1.7;white-space:pre-wrap;"><b style="color:#0d6efd;">답변</b><br>'+_faqEsc(d.ansrConts)+'</div>'
			: '<div style="margin-top:10px;font-size:13px;color:#888;">아직 답변이 등록되지 않았습니다.</div>';
		h+='<div class="accordion-item border-0 mb-2 shadow-sm" style="border-radius:10px;overflow:hidden;">'
		 +'<h2 class="accordion-header">'
		 +'<button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#asqC'+i+'" style="font-size:14.5px;font-weight:600;">'
		 +badge+'<span style="flex:1;overflow:hidden;text-overflow:ellipsis;">'+_faqEsc(d.qstnConts)+'</span>'
		 +'</button></h2>'
		 +'<div id="asqC'+i+'" class="accordion-collapse collapse" data-bs-parent="#asqAcc">'
		 +'<div class="accordion-body" style="font-size:14px;line-height:1.7;color:#333;">'
		 +'<div class="text-muted small mb-1">'+_asqYmd(d.qstnYmd)+'</div>'
		 +'<div style="white-space:pre-wrap;">'+_faqEsc(d.qstnConts)+'</div>'
		 +ansHtml
		 +'<div class="text-end mt-2"><button class="btn btn-outline-danger btn-sm py-0 px-3" style="font-size:12px;" onclick="delAsq(\''+_faqEsc(d.asqSeq)+'\')">삭제</button></div>'
		 +'</div></div></div>';
	});
	h+='</div>';
	$('#asqList').html(h);
}

/* ══════════════════════════════════════
   혈당 평가 패널
══════════════════════════════════════ */
var _evalCtx = { hours:[], ys:[], foodMap:{}, exerMap:{}, label:'' };

function updateEvalPanel(hours, ys, foodMap, exerMap, label){
	_evalCtx = { hours:hours, ys:ys, foodMap:foodMap, exerMap:exerMap, label:label };
	var vals = ys.filter(function(v){ return v!=null&&!isNaN(v); });
	if (!vals.length){
		$('#evalContent').html('<div class="text-muted text-center small py-2">데이터 없음</div>');
		return;
	}
	var avg  = Math.round(vals.reduce(function(a,b){return a+b;},0)/vals.length);
	var max  = Math.max.apply(null,vals);
	var maxH = hours[ys.indexOf(max)];
	var min  = Math.min.apply(null,vals);
	var minH = hours[ys.indexOf(min)];
	var inR  = vals.filter(function(v){return v>=70&&v<=180;}).length;
	var pct  = Math.round(inR/vals.length*100);
	var highs= vals.filter(function(v){return v>180;}).length;
	var lows = vals.filter(function(v){return v<70;}).length;

	function badge(v){
		if(v<70)   return '<span style="background:#f8d7da;color:#842029;border-radius:4px;padding:1px 6px;font-size:11px;">저혈당</span>';
		if(v<=140) return '<span style="background:#d1e7dd;color:#0f5132;border-radius:4px;padding:1px 6px;font-size:11px;">정상</span>';
		if(v<=180) return '<span style="background:#fff3cd;color:#664d03;border-radius:4px;padding:1px 6px;font-size:11px;">주의</span>';
		return '<span style="background:#f8d7da;color:#842029;border-radius:4px;padding:1px 6px;font-size:11px;">고혈당</span>';
	}
	var trend='';
	if(vals.length>=3){
		var last=vals[vals.length-1], prev=vals[vals.length-3];
		trend=last>prev+5?'📈 상승 추세':last<prev-5?'📉 하강 추세':'➡️ 안정적';
	}
	var mKeys=Object.keys(foodMap).sort(), eKeys=Object.keys(exerMap).sort();
	var h='<div style="font-size:15px;line-height:1.9;">';
	h+='<div class="eval-row"><span class="text-muted">평균</span><span><b>'+avg+'</b> mg/dL '+badge(avg)+'</span></div>';
	h+='<div class="eval-row"><span class="text-muted">최고</span><span><b>'+max+'</b> mg/dL <small class="text-muted">('+maxH+'시)</small></span></div>';
	h+='<div class="eval-row"><span class="text-muted">최저</span><span><b>'+min+'</b> mg/dL <small class="text-muted">('+minH+'시)</small></span></div>';
	h+='<hr style="margin:6px 0;">';
	h+='<div class="eval-row"><span class="text-muted">목표범위(70~180)</span><span><b>'+pct+'%</b></span></div>';
	if(highs) h+='<div class="eval-row"><span class="text-muted">고혈당(&gt;180)</span><span style="color:#dc3545;"><b>'+highs+'</b>회</span></div>';
	if(lows)  h+='<div class="eval-row"><span class="text-muted">저혈당(&lt;70)</span><span style="color:#fd7e14;"><b>'+lows+'</b>회</span></div>';
	if(trend) h+='<div class="text-secondary small mt-1">'+trend+'</div>';
	if(mKeys.length) h+='<div class="text-secondary small">🍚 식사: '+mKeys.map(function(k){return k+'시';}).join(', ')+'</div>';
	if(eKeys.length) h+='<div class="text-secondary small">🚴 운동: '+eKeys.map(function(k){return k+'시';}).join(', ')+'</div>';
	h+='</div>';
	$('#evalContent').html(h);
}

/* ══════════════════════════════════════
   Q&A 채팅
══════════════════════════════════════ */
function _quickQ(q){ $('#chatInput').val(q); sendChat(); }

function _addMsg(txt, isUser, extraCls){
	var $box=$('#chatMessages');
	var cls = (isUser?'chat-user':'chat-bot') + (extraCls ? (' '+extraCls) : '');
	var $msg=$('<div class="'+cls+'"></div>');
	if (isUser) {
		// 삭제 버튼은 질문(사용자 메시지)에만 — 삭제 시 바로 뒤 답변(.chat-bot)도 함께 제거
		$msg.html('<span class="chat-text">'+txt+'</span>'
		        + '<button type="button" class="chat-del" title="질문·답변 삭제">&times;</button>');
		$msg.children('.chat-del').on('click', function(){
			var $next = $msg.next('.chat-bot');   // 이 질문에 종속된 답변
			$msg.remove();
			if ($next.length) $next.remove();
		});
	} else {
		// 답변은 질문에 종속 — 자체 삭제 버튼 없음
		$msg.html('<span class="chat-text">'+txt+'</span>');
	}
	$box.append($msg);
	$box[0].scrollTop=$box[0].scrollHeight;
}
// _toast / _confirmBox / _alertBox 는 공통 /asset/js/ui-message.js 에서 제공

// 대화 전체 삭제 후 인사말만 다시 표시
function _clearChat(){
	_confirmBox({
		icon:'🗑️',
		msg:'대화 내용을 모두 지울까요?',
		okText:'삭제',
		onOk:function(){
			$('#chatMessages').empty();
			_addMsg('안녕하세요! 혈당 관련 궁금한 점을 질문해 주세요.', false, 'chat-intro');
			_chatIntroAnalysis();   // 주간 지표 분석 다시 게시(캐시 재사용)
		}
	});
}
// 동일 질문 캐시: { '질문|혈당컨텍스트' : '성공답변' } — 같은 질문 반복 시 서버 재호출 방지
var _chatCache = {};
function sendChat(){
	var q=$.trim($('#chatInput').val()); if(!q) return;
	$('#chatInput').val('');
	_addMsg(q,true);

	// ① 로컬 키워드/데이터 즉답 (혈당 데이터 질문 + blood_qa.js 매칭)
	var local = _chatResponse(q);
	if (local != null) {
		setTimeout(function(){ _addMsg(local,false); },280);
		return;
	}

	// ②-0 동일 질문 캐시: 같은 질문 + 같은 혈당 컨텍스트면 서버 재호출 없이 이전 답 재사용
	//      (반복 질문 시 LLM 한도/오류로 폴백 뜨던 문제 방지)
	var _ctxText  = _chatCtxText();
	var _cacheKey = q.toLowerCase() + '|' + _ctxText;
	if (_chatCache[_cacheKey]) {
		setTimeout(function(){ _addMsg(_chatCache[_cacheKey], false); }, 200);
		return;
	}

	// ② 매칭 실패 → 서버 LLM(Gemini) fallback. "입력 중…" 표시 후 응답으로 교체
	var $typing = $('<div class="chat-bot"><span class="chat-text">…</span></div>');
	$('#chatMessages').append($typing);
	$('#chatMessages')[0].scrollTop = $('#chatMessages')[0].scrollHeight;

	$.ajax({
		url: CommonUtil.getContextPath()+'/blood/chatAsk.do',
		type:'post',
		data: JSON.stringify({ q:q, ctx:_ctxText }),
		contentType:'application/json',
		dataType:'json',
		success:function(r){
			$typing.remove();
			if (r && r.IsSucceed && r.Data) {
				var _ans = String(r.Data);
				_chatCache[_cacheKey] = _ans;   // 성공 답변만 캐시 → 다음 동일 질문은 즉시 재사용
				_addMsg(_ans, false);
			} else {
				_addMsg(_chatFallbackMsg(), false);
			}
		},
		error:function(){
			$typing.remove();
			_addMsg(_chatFallbackMsg(), false);
		}
	});
	
}
function _chatResponse(q){
	var ctx=_evalCtx;
	var vals=ctx.ys.filter(function(v){return v!=null&&!isNaN(v);});
	var avg =vals.length?Math.round(vals.reduce(function(a,b){return a+b;},0)/vals.length):null;
	var max =vals.length?Math.max.apply(null,vals):null;
	var min =vals.length?Math.min.apply(null,vals):null;
	var maxH=max!=null?ctx.hours[ctx.ys.indexOf(max)]:null;
	var pct =vals.length?Math.round(vals.filter(function(v){return v>=70&&v<=180;}).length/vals.length*100):null;
	var lbl =ctx.label?ctx.label+'':'선택한 날';
	var hasData=vals.length>0;
	var o=q; q=q.toLowerCase();

	/* ── 최근 1주일(주간) 질문 — 선택일 평균보다 먼저 가로채 주간 데이터로 답 ── */
	if(/(최근\s*1?\s*주|1주일|일주일|주간|이번\s*주|한\s*주|일주)/.test(q)){
		var ws = window._weekStats;
		if (ws && ws.avg != null) {
			var wStat = ws.avg<=140 ? '양호한 상태입니다 👍'
			          : ws.avg<=180 ? '관리가 필요합니다.'
			          : '<span style="color:#dc3545;">고혈당 주의</span>가 필요합니다.';
			return '최근 1주일 일별 평균 혈당: <b>'+ws.avg+' mg/dL</b><br>'
			     + '최고 일평균 <b>'+ws.max+'</b> · 최저 일평균 <b>'+ws.min+'</b> mg/dL ('+ws.days+'일 기준)<br>'
			     + wStat + '<br><small>※ 일반 참고용이며 진단이 아닙니다. 이상 증상은 담당 의사와 상담하세요.</small>';
		}
		return '최근 1주일 혈당 데이터가 아직 없어요.<br>상단 <b>혈당 가져오기</b>로 데이터를 동기화한 뒤 다시 물어봐 주세요.';
	}

	/* ── 식후(식사 후) 혈당 — 선택일 식사 시각 2시간 후 혈당을 데이터로 답 ── */
	if(/(식후|식사\s*후|식사후|밥\s*먹고|먹은\s*후)/.test(q) && hasData){
		var fm = ctx.foodMap || {};
		var mealHours = Object.keys(fm).sort();
		var gAt = function(h){ if(h<0||h>23) return null; var k=(h<10?'0':'')+h; var ix=ctx.hours.indexOf(k); return (ix>=0 && ctx.ys[ix]!=null)?ctx.ys[ix]:null; };
		if (mealHours.length === 0) {
			return lbl+'에 기록된 식사 시각이 없어 식후 혈당을 계산할 수 없어요.<br>식사를 기록하면 끼니별 식후 혈당을 분석해 드릴게요.';
		}
		var lines = [], peaks = [];
		mealHours.forEach(function(mh){
			var hN = parseInt(mh,10);
			var post = gAt(hN+2); if(post==null) post=gAt(hN+1);
			if (post!=null){
				var meal=(fm[mh]||['식사']).join(',');
				var tag = post>180?'<span style="color:#dc3545;">고혈당</span>':post>140?'약간 높음':'정상';
				lines.push(mh+'시 '+meal+' → 2시간 후 약 <b>'+post+' mg/dL</b> ('+tag+')');
				peaks.push(post);
			}
		});
		if (lines.length === 0){
			return lbl+' 식사 후 2시간 혈당 데이터가 부족해요. (식사 시각 전후 측정값 필요)';
		}
		var pk = Math.max.apply(null, peaks);
		var tip = pk>180 ? '식후 고혈당이 보입니다. 정제 탄수화물을 줄이고 식후 30분 걷기를 권장합니다.'
		        : pk>140 ? '식후 혈당이 다소 올라갑니다. 채소·단백질 먼저 먹기와 식후 걷기가 도움이 됩니다.'
		        : '식후 혈당이 목표(식후 2시간 140 이하) 안에서 잘 관리되고 있습니다 👍';
		return lbl+' 식후 혈당:<br>• '+lines.join('<br>• ')+'<br>'+tip+'<br><small>※ 일반 참고용이며 진단이 아닙니다.</small>';
	}

	/* ── 공복 / 끼니 시간대(아침·점심·저녁) 혈당 — '내 데이터' 의도일 때만 선택일 데이터로 답 ──
	   (단순 지식 질문 "공복혈당 정상수치?" 등은 가드에 안 걸려 교과서 답으로 넘어감) */
	var _dataIntent = /(어때|어땠|어떤|어떻|얼마|몇|상태|관리|괜찮|높|낮|변화|좋아|나빠|문제)/.test(q);
	if(hasData && _dataIntent){
		var gAt2 = function(h){ if(h<0||h>23) return null; var k=(h<10?'0':'')+h; var ix=ctx.hours.indexOf(k); return (ix>=0 && ctx.ys[ix]!=null)?ctx.ys[ix]:null; };

		// 공복(기상 직후) 혈당: 첫 식사 이전 가장 이른 측정값
		if(/(공복|기상|자고\s*일어|일어나|아침\s*공복)/.test(q)){
			var fmk = Object.keys(ctx.foodMap||{}).sort();
			var firstMeal = fmk.length ? parseInt(fmk[0],10) : 9;
			var fast=null, fastH=null;
			for(var h=4; h<firstMeal; h++){ var gv=gAt2(h); if(gv!=null){ fast=gv; fastH=h; break; } }
			if(fast==null){ for(var h2=4; h2<=9; h2++){ var gv2=gAt2(h2); if(gv2!=null){ fast=gv2; fastH=h2; break; } } }
			if(fast!=null){
				var ftag = fast<100?'정상':fast<126?'공복혈당장애':'<span style="color:#dc3545;">높음</span>';
				return lbl+' 공복 혈당(약 '+fastH+'시): <b>'+fast+' mg/dL</b> ('+ftag+')<br>'
				     +(fast<100?'공복 혈당이 정상 범위입니다 👍':fast<126?'공복혈당장애 구간이에요. 늦은 저녁 식사를 줄여보세요.':'공복 고혈당이 보입니다. 담당 의사와 상담을 권장합니다.')
				     +'<br><small>※ 일반 참고용이며 진단이 아닙니다.</small>';
			}
			return lbl+' 기상 직후(공복) 측정값이 없어 공복 혈당을 계산할 수 없어요.';
		}

		// 아침/점심/저녁 시간대 평균·최고
		var periods = [
			{ re:/(아침|조식|오전)/,        name:'아침', s:5,  e:10 },
			{ re:/(점심|중식|낮)/,          name:'점심', s:11, e:15 },
			{ re:/(저녁|석식|밤|야간)/,     name:'저녁', s:17, e:22 }
		];
		for(var pi=0; pi<periods.length; pi++){
			var P=periods[pi];
			if(P.re.test(q)){
				var pv=[]; for(var hh=P.s; hh<=P.e; hh++){ var g=gAt2(hh); if(g!=null) pv.push(g); }
				if(pv.length){
					var pavg=Math.round(pv.reduce(function(a,b){return a+b;},0)/pv.length);
					var pmax=Math.max.apply(null,pv);
					var ptag=pavg>180?'<span style="color:#dc3545;">고혈당</span>':pavg>140?'약간 높음':'정상';
					return lbl+' '+P.name+' 시간대 혈당: 평균 <b>'+pavg+'</b> · 최고 <b>'+pmax+'</b> mg/dL ('+ptag+')<br>'
					     +(pmax>180?'식후 고혈당이 보입니다. 식후 30분 걷기를 권장합니다.':pavg>140?'다소 높습니다. 탄수화물 양·식사 속도를 조절해 보세요.':'잘 관리되고 있습니다 👍')
					     +'<br><small>※ 일반 참고용이며 진단이 아닙니다.</small>';
				}
				return lbl+' '+P.name+' 시간대 혈당 데이터가 없어요.';
			}
		}
	}

	/* ── 현재 데이터 기반 질문 ── */
	if(/(높|위험|고혈당)/.test(q)&&/(오늘|현재|지금)/.test(q)&&hasData){
		if(avg>180) return lbl+' 평균 <b>'+avg+' mg/dL</b>로 <span style="color:#dc3545;">고혈당</span>입니다.<br>충분한 수분 섭취를 하고 담당 의사에게 상담하세요.';
		if(avg>140) return lbl+' 평균 <b>'+avg+' mg/dL</b>로 다소 높습니다.<br>식후 30분 걷기와 탄수화물 줄이기를 권장합니다.';
		return lbl+' 평균 <b>'+avg+' mg/dL</b>로 정상 범위입니다 👍<br>현재 관리를 잘 유지하고 있습니다.';
	}
	if(/(최고|제일 높|가장 높)/.test(q)&&hasData){
		return lbl+' 최고 혈당: <b>'+max+' mg/dL</b> ('+maxH+'시)<br>'+(max>180?'고혈당 주의 구간입니다.':max>140?'식후 상승으로 보입니다.':'정상 범위 내 최고치입니다.');
	}
	if(/(최저|제일 낮|가장 낮)/.test(q)&&hasData){
		return lbl+' 최저 혈당: <b>'+min+' mg/dL</b><br>'+(min<70?'<span style="color:#fd7e14;">저혈당 위험</span>: 즉시 당분(사탕·주스)을 섭취하세요.':min<90?'공복 수준의 낮은 혈당입니다.':'정상 범위입니다.');
	}
	if(/평균/.test(q)&&hasData){
		return lbl+' 평균: <b>'+avg+' mg/dL</b><br>목표범위(70~180) 내 비율: <b>'+pct+'%</b><br>'+(avg<=140?'양호한 상태입니다.':avg<=180?'관리가 필요합니다.':'고혈당 주의가 필요합니다.');
	}
	if(/(추이|변화|트렌드)/.test(q)&&hasData){
		var last=vals[vals.length-1], first=vals[0], diff=last-first;
		return lbl+' 혈당: '+first+'→'+last+' mg/dL '+(diff>0?'(+'+diff+' ↑ 상승)':'('+diff+' ↓ 하강)')+'<br>목표범위 내: <b>'+pct+'%</b>';
	}

	/* ── 일반 건강 지식: 데이터 파일(blood_qa.js)의 BLOOD_QA 에서 키워드 매칭 ──
	   답변 추가/수정은 blood_qa.js 만 편집하면 됨 (이 코드 수정 불필요) */
	if (typeof BLOOD_QA !== 'undefined' && BLOOD_QA.length) {
		// 점수제 매칭: 첫 매칭이 아니라, 일치한 키워드 길이 합(구체적일수록 가중)으로 점수화해
		// 가장 잘 맞는 1개만 선택. 1등이 2등보다 뚜렷이 앞설 때만 사용하고,
		// 점수가 비슷(애매)하거나 약하면 null → 서버 LLM 이 의도 파악 (엉뚱한 고정답 방지)
		var bestItem = null, bestScore = 0, bestMaxLen = 0, secondScore = 0;
		for (var i = 0; i < BLOOD_QA.length; i++) {
			var item = BLOOD_QA[i];
			if (!item || !item.kw) continue;
			var score = 0, maxLen = 0;
			for (var j = 0; j < item.kw.length; j++) {
				var kw = String(item.kw[j]).toLowerCase();
				if (kw && q.indexOf(kw) !== -1) {
					score += kw.length;              // 긴(구체적) 키워드일수록 가중
					if (kw.length > maxLen) maxLen = kw.length;
				}
			}
			if (score > bestScore)        { secondScore = bestScore; bestItem = item; bestScore = score; bestMaxLen = maxLen; }
			else if (score > secondScore) { secondScore = score; }
		}
		// 신뢰 조건: 가장 긴 일치 키워드 2자 이상 + 2등과 점수 차 2 이상(키워드 1개 이상 우위)일 때만 채택
		if (bestItem && bestMaxLen >= 2 && bestScore >= secondScore + 2) {
			return bestItem.a;
		}
		// 그 외(약하거나 애매하게 여러 항목이 비슷) → null → LLM 으로 위임
	}

	/* ── 특정 음식 질문(짬뽕·라면 등 키워드 없는 음식) — 전용 답 없을 때 일반 음식 가이드로 답 ──
	   "X 먹어도 돼요?" / "X은 혈당에 어떤가요/좋은가요" 패턴. (운동·스트레스 등은 위 BLOOD_QA 에서 이미 처리됨) */
	if(/(먹어도|먹으면|먹는\s*게|먹는\s*건|드셔도|섭취해도|혈당에\s*(어떤|좋|나쁘|괜찮|영향|올라|안\s*좋))/.test(q)){
		return '특정 음식과 혈당 (일반 가이드):<br>'
		     + '• 흰쌀·면류·빵 등 <b>정제 탄수화물</b>과 단 음식은 혈당을 빠르게 올립니다.<br>'
		     + '• <b>채소·단백질을 먼저</b> 먹고 천천히(20분 이상) 드세요.<br>'
		     + '• 탄수화물은 양을 줄이고 잡곡·통곡물로 바꾸면 좋습니다.<br>'
		     + '• 식후 <b>30분 걷기</b>로 식후 혈당 상승을 완화하세요.<br>'
		     + '<small>※ 일반 참고용이며 음식별 반응은 개인차가 있습니다.</small>';
	}

	/* ── 매칭 실패 시 ──
	   로컬(키워드/데이터) 답변이 없으면 null 반환 → sendChat() 이 서버 LLM(Gemini) 으로 fallback */
	return null;
}
// LLM·매칭 모두 실패했을 때 보여줄 안내 문구
function _chatFallbackMsg(){
	return '죄송해요, 지금은 답변을 가져오지 못했어요 😅<br><br>이런 질문을 해보세요:<br>• "자기 몇 시간 전까지 식사하는게 좋아요?"<br>• "오늘 혈당이 높은가요?"<br>• "저혈당 증상과 대처법은?"<br>• "수영·자전거 운동이 혈당에 좋아요?"<br>• "스트레스와 혈당의 관계는?"';
}
// 현재 선택된 날 혈당 요약 — LLM 프롬프트 컨텍스트로 전달
function _chatCtxText(){
	var ctx=_evalCtx;
	var vals=ctx.ys.filter(function(v){return v!=null&&!isNaN(v);});
	if(!vals.length) return '';
	var avg=Math.round(vals.reduce(function(a,b){return a+b;},0)/vals.length);
	var max=Math.max.apply(null,vals), min=Math.min.apply(null,vals);
	var pct=Math.round(vals.filter(function(v){return v>=70&&v<=180;}).length/vals.length*100);
	return (ctx.label||'선택한 날')+' 평균 '+avg+' / 최고 '+max+' / 최저 '+min+' mg/dL, 목표범위(70~180) '+pct+'%';
}
/* ── [앱 챗봇과 동일] 인사 아래 '최근 일주일 지표 분석' + AI 코칭 1회 게시 ──
   앱(Blood_Consult) 첫 인사 분석과 같은 내용·표기. 기준은 나이로 단순화:
   만 65세 이상 = 고령 기준(TIR 50%↑·TAR 50%↓·TBR 1%↓), 그 외 표준(70/25/4). */
var _chatIntroDone = false;
function _chatIntroAnalysis(){
	if (window._chatIntroMsg){ _addMsg(window._chatIntroMsg, false); return; }
	if (_chatIntroDone) return;
	_chatIntroDone = true;
	// 앱(adjustToLastDataDate)과 동일 — 기간은 '마지막 측정일 기준 7일' (오늘 기준이면 공백 기간에 분석이 사라짐)
	$.ajax({ url:CommonUtil.getContextPath()+'/getLastBloodDay.do', type:'post', dataType:'json',
		success:function(lr){
			var lrow = (lr && lr.IsSucceed && lr.Data) ? lr.Data : null;
			var endKey = lrow ? String(lrow.date2) : formatDay(new Date());
			_chatIntroAnalysisRun(endKey);
		},
		error:function(){ _chatIntroAnalysisRun(formatDay(new Date())); }
	});
}
function _chatIntroAnalysisRun(endKey){
	var endD = new Date(endKey);
	var days = [];
	for (var i=6; i>=0; i--) days.push(formatDay(new Date(endD.getTime()-i*864e5)));
	var reqs = days.map(function(k){
		return $.ajax({ url:CommonUtil.getContextPath()+'/getBloodChartData.do', type:'post',
			data:JSON.stringify({ end:k, userId:userUuid }), contentType:'application/json', dataType:'json' });
	});
	reqs.push($.ajax({ url:CommonUtil.getContextPath()+'/patient/myInfo.do', type:'post', dataType:'json' }));
	$.when.apply($, reqs).done(function(){
		var args = arguments, pts = [];
		for (var d=0; d<days.length; d++){
			var rows = Array.isArray(args[d][0]) ? args[d][0] : [];
			rows.forEach(function(r){ var v=parseInt(r.UPT,10); if(!isNaN(v)) pts.push(v); });
		}
		if (!pts.length) return;   // 주간 데이터 없으면 분석 생략(인사만)
		var info  = args[days.length][0];
		var birth = (info && info.IsSucceed && info.Data) ? String(info.Data.birth||'') : '';
		var age = null;
		if (/^[0-9]{8}$/.test(birth)){
			var t=new Date(), by=+birth.substring(0,4), bm=+birth.substring(4,6), bd=+birth.substring(6,8);
			age = t.getFullYear()-by - ((t.getMonth()+1<bm || (t.getMonth()+1===bm && t.getDate()<bd))?1:0);
		}
		var elderly = age!=null && age>=65;
		var C = elderly ? { tir:50, tar:50, tbr:1, note:'고령 기준 적용 (TIR 50% 이상·TAR 50% 미만·TBR 1% 미만)' }
		                : { tir:70, tar:25, tbr:4, note:'표준 기준 적용 (TIR 70% 이상·TAR 25% 미만·TBR 4% 미만)' };
		var n = pts.length;
		var tir = Math.round(pts.filter(function(v){ return v>=70&&v<=180; }).length*1000/n)/10;
		var tar = Math.round(pts.filter(function(v){ return v>180; }).length*1000/n)/10;
		var tbr = Math.round(pts.filter(function(v){ return v<70; }).length*1000/n)/10;
		var ln = function(s){ return '<span style="display:block; word-break:keep-all;">'+s+'</span>'; };
		var ok = function(b,g){ return b ? ('충족'+(g?'&nbsp;👍':'')) : '<b style="color:#e67e22">'+(g?'미달':'초과')+'</b>'; };
		var L = [ln('최근 일주일 지표 분석입니다.')];
		L.push(ln('• TIR(목표혈당 유지시간) <b>'+tir+'%</b> → '+ok(tir>=C.tir, true)));
		L.push(ln('• TAR(고혈당 시간) <b>'+tar+'%</b> → '+ok(tar<C.tar, false)));
		L.push(ln('• TBR(저혈당 시간) <b>'+tbr+'%</b> → '+ok(tbr<C.tbr, false)));
		var head='', tips=[];
		if (tar>=C.tar){ head='지난 일주일 동안 고혈당 시간이 다소 길었습니다.'; tips=['식사량을 줄이세요.','탄수화물 비율을 줄이세요.','식후 20~30분 걷기를 실천해 보세요.']; }
		else if (tbr>=C.tbr){ head='지난 일주일 동안 저혈당이 발생했습니다.'; tips=['공복 상태의 운동을 피하세요.','식사를 거르지 말고 규칙적으로 하세요.','저혈당 증상이 느껴지면 즉시 당분을 섭취하세요.']; }
		else { head='지난 일주일 혈당이 안정적으로 관리되고 있습니다.'; tips=['현재 생활습관을 그대로 유지하세요.','꾸준한 측정과 기록을 계속해 주세요.']; }
		L.push(ln('<br><b>AI 코칭</b>'));
		L.push(ln(head));
		tips.forEach(function(s){ L.push(ln(s)); });
		var note = (age!=null ? '※ 만 '+age+'세 — ' : '※ ') + C.note;
		var msg = L.join('') + '<small>'+note+'<br>※ 대한당뇨병학회 관리지표 기준</small>';
		window._chatIntroMsg = msg;
		_addMsg(msg, false);
	});
}

$(function(){
	// 초기 인사 메시지 + 주간 지표 분석(앱 챗봇과 동일)
	_addMsg('안녕하세요! 혈당 관련 궁금한 점을 질문해 주세요.', false, 'chat-intro');
	_chatIntroAnalysis();
});

/* ── 마커 팝업 바깥 클릭 시 닫기 ── */
$(document).on('click', function(e){
	if (_markerClicked) return;
	if (!$(e.target).closest('#markerPopup').length) $('#markerPopup').hide();
});
/* ── 모달 스택 처리 (복수 모달 z-index 충돌 방지) ── */
$(document).on('show.bs.modal', '.modal', function(){
	var zIndex = 1055 + 10 * $('.modal.show').length;
	$(this).css('z-index', zIndex);
	setTimeout(function(){
		$('.modal-backdrop').not('.modal-stack').last()
			.css('z-index', zIndex - 1).addClass('modal-stack');
	}, 0);
});
$(document).on('hidden.bs.modal', '.modal', function(){
	if ($('.modal.show').length) $('body').addClass('modal-open');
});
/* (세부혈당그래프 풀스크린 모달 보정 핸들러는 본문 전환 뷰 #viewDetail 로 대체되며 제거됨) */

/* ── 우측 패널 높이: 좌측 컬럼 하단 기준으로 맞춤 (다변 스크롤) ── */
function _syncRightPanel(){
	var $left  = $('#rightPanel').parent().find('div:first');
	var $panel = $('#rightPanel');
	var leftH  = $left.outerHeight(true) || 0;
	var winH   = $(window).height();
	// 좌측 컬럼 높이와 (뷰포트 - sticky top - 하단 여백) 중 작은 값 사용
	var panelH = Math.min(leftH, winH - 32);
	$panel.css('height', Math.max(panelH, 300) + 'px');
}
$(window).on('load resize', _syncRightPanel);
// 차트 로드 후 재계산 (ECharts 렌더 후 높이 확정)
var _origDrawChart = drawChart;
drawChart = function(){ _origDrawChart.apply(this, arguments); setTimeout(_syncRightPanel, 600); };

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
<body class="has-side-nav">
<!-- ══════════════════════════════════════════════
     좌측 사이드바 메뉴
══════════════════════════════════════════════ -->
<nav class="side-nav">
	<div class="sn-brand">🩸 혈당 관리</div>
	<%-- 주 기능(홈·그래프·설정)을 위에, 보조 기능(FAQ·문의)은 하단으로 분리 [2026-10-21 요청] --%>
	<button type="button" class="sn-item active" id="snHome" onclick="showHomeView();">
		<span class="sn-ico">🏠</span><span>내 혈당 홈</span>
	</button>
	<button type="button" class="sn-item" id="snDetail" onclick="openDetailGraph();">
		<span class="sn-ico">📈</span><span>세부혈당그래프</span>
	</button>
	<%-- 앱 홈 카드의 두 항목(혈당 지표 확인 + AI 종합분석)을 담은 별도 화면 --%>
	<button type="button" class="sn-item" id="snAi" onclick="openAiAnalysis();">
		<span class="sn-ico">🤖</span><span>AI 종합분석</span>
	</button>
	<%-- 모바일 앱 하단 탭(식사등록·운동등록)과 동일 구성 — 이미 있는 기록 모달을 메뉴에서도 연다 --%>
	<button type="button" class="sn-item" onclick="goFood();">
		<span class="sn-ico">🍚</span><span>식사 기록</span>
	</button>
	<button type="button" class="sn-item" onclick="goExer();">
		<span class="sn-ico">🚴</span><span>운동 기록</span>
	</button>
	<%-- 앱 바로가기(개인정보 변경·설정) 대응 --%>
	<button type="button" class="sn-item" onclick="openMyInfo();">
		<span class="sn-ico">👤</span><span>개인정보 변경</span>
	</button>
	<button type="button" class="sn-item" onclick="openAgreeList();">
		<span class="sn-ico">📝</span><span>개인정보 약관 동의</span>
	</button>
	<button type="button" class="sn-item" onclick="openSettings();">
		<span class="sn-ico">⚙️</span><span>설정 · 모바일 QR</span>
	</button>
	<div class="sn-sep" style="margin-top:auto;"></div>
	<%-- 앱 바로가기(공지사항·FAQ·문의) 대응 --%>
	<button type="button" class="sn-item" onclick="openNotice();">
		<span class="sn-ico">📢</span><span>공지사항</span>
	</button>
	<button type="button" class="sn-item" onclick="openFaq();">
		<span class="sn-ico">❓</span><span>자주하는 질문</span>
	</button>
	<button type="button" class="sn-item" onclick="openAsq();">
		<span class="sn-ico">💬</span><span>질의응답관리</span>
	</button>
	<!-- 추가 기능 메뉴는 여기에 -->
</nav>

<div id="viewHome" class="container-fluid py-4" style="max-width:1820px;margin:0 auto;padding-left:16px;padding-right:16px;">
	<div class="d-flex justify-content-between align-items-center mb-3">
		<h3>${sessionScope.userNm}님 환영합니다</h3>
		<div class="d-flex align-items-center gap-2 topbar-actions">
			<span id="tokenStatus" class="me-1">…</span>
			<button id="btnConnect" class="btn btn-primary btn-sm" onclick="connectISens();" style="display:none;">i-Sens 연동</button>
			<button id="btnSync"    class="btn btn-success btn-sm" onclick="syncMyBlood(false);" style="display:none;">혈당 가져오기</button>
			<button class="btn btn-outline-primary btn-sm" onclick="goFood();">🍚 식사 기록</button>
			<button class="btn btn-outline-primary btn-sm" onclick="goExer();">🚴 운동 기록</button>
			<%-- 모바일(사이드바 숨김)에서도 케어센스 설정·QR 에 닿도록 상단에 ⚙ 버튼 --%>
			<button class="btn btn-outline-secondary btn-sm" onclick="openSettings();">⚙ 설정·QR</button>
			<button class="btn btn-outline-secondary btn-sm" onclick="logout();">로그아웃</button>
		</div>
	</div>
	<div id="syncMsg" class="text-muted small mb-2" style="display:none;"></div>

	<div class="d-flex gap-3 align-items-start layout-cols">
		<!-- 좌측: 차트/카드 -->
		<div style="flex:1;min-width:0;">
			<!-- [앱 홈 카드 대응] 최근 24시간 혈당지표 '양호/주의' + 바로가기.
			     AI 종합분석은 세부그래프 AI 분석 탭으로 연결(중복 구현 없음). 챗봇은 우측 Q&A가 이미 있어 제외 -->
			<%-- 기능 진입은 좌측 메뉴(세부혈당그래프·AI 종합분석)로 분리 — 카드는 상태 요약만 --%>
			<div class="card-tile" id="dayStatusCard" style="background:linear-gradient(135deg,#0d3b66 0%,#1d5fa8 100%);color:#fff;">
				<div id="dayStatusText" style="font-size:17px;font-weight:700;">최근 24시간 혈당지표를 계산 중입니다…</div>
				<div id="dayStatusSub" class="mt-1" style="font-size:13px;color:#cfe2ff;"></div>
			</div>
			<div class="row-grid">
				<div class="card-tile">
					<h5>최근 혈당</h5>
					<div class="blood-num" id="nowBlood">-</div>
					<div class="text-muted">mg/dL</div>
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
				<div class="d-flex justify-content-between align-items-center mb-2">
					<h5 class="mb-0">최근 1주일 혈당</h5>
					<div>
						<span class="text-muted me-1">평균</span>
						<span id="weekAvg" style="font-size:28px;font-weight:700;color:#0d6efd;">-</span>
						<span class="text-muted">mg/dL</span>
					</div>
				</div>
				<div class="text-muted small mb-1">막대를 클릭하면 해당 날짜의 시간대별 추이를 볼 수 있습니다.
					<span style="color:#dc3545;">■</span> 최고 · <span style="color:#f5c518;">■</span> 최저</div>
				<div id="dailyChart" style="height:270px;"></div>
			</div>
			<div class="card-tile">
				<h5 id="dayChartTitle">시간대별 혈당 추이</h5>
				<div class="text-muted small mb-1" style="font-size:13px;">
					<span style="color:#0d6efd;">━</span> 혈당
					&nbsp;·&nbsp; 🍚 식사
					&nbsp;·&nbsp; 🚴 운동
					&nbsp;·&nbsp; <span style="color:#c0c4cc;">┊</span> 식사·운동 시각
				</div>
				<div id="lineChart" style="height:300px;"></div>
			</div>
		</div>

		<!-- 우측: 혈당 평가 + Q&A (높이는 JS로 좌측 컬럼에 맞춤) -->
		<div id="rightPanel" style="width:460px;flex-shrink:0;display:flex;flex-direction:column;gap:12px;position:sticky;top:16px;overflow:hidden;">
			<!-- 혈당 평가 (고정) -->
			<div class="card-tile" style="padding:16px 18px;flex-shrink:0;">
				<h5 style="font-size:17px;margin-bottom:12px;">📊 혈당 평가</h5>
				<div id="evalContent" style="font-size:15px;line-height:1.8;">
					<div class="text-muted text-center small py-3">차트를 선택하면<br>평가가 표시됩니다</div>
				</div>
			</div>
			<!-- Q&A (남은 공간 채우고, 채팅만 스크롤) -->
			<div class="card-tile" style="padding:16px 18px;flex:1;min-height:0;display:flex;flex-direction:column;overflow:hidden;">
				<div class="d-flex justify-content-between align-items-center" style="flex-shrink:0;margin-bottom:8px;">
					<h5 style="font-size:17px;margin:0;">💬 혈당 Q&A</h5>
					<button type="button" class="btn btn-link btn-sm text-muted p-0" style="font-size:13px;text-decoration:none;" onclick="_clearChat();">🗑 전체 삭제</button>
				</div>
				<div id="chatMessages" style="flex:1;min-height:0;overflow-y:auto;display:flex;flex-direction:column;gap:6px;padding:8px;background:#f8f9fa;border-radius:8px;margin-bottom:8px;"></div>
				<div class="d-flex gap-1 mb-2" style="flex-shrink:0;">
					<input type="text" id="chatInput" class="form-control form-control-sm" placeholder="질문을 입력하세요…" onkeypress="if(event.key==='Enter')sendChat();">
					<button class="btn btn-primary btn-sm px-3" onclick="sendChat();">전송</button>
				</div>
				<div class="d-flex flex-wrap gap-1" style="flex-shrink:0;">
					<%-- 앱 챗봇과 동일한 질문 버튼 6종 [2026-10-21] --%>
					<button class="qbtn" onclick="_quickQ('주간 평균혈당 어때요?')">주간평균혈당</button>
					<button class="qbtn" onclick="_quickQ('공복 평균혈당 어때요?')">공복평균혈당</button>
					<button class="qbtn" onclick="_quickQ('주간 최고혈당 알려줘')">주간 최고혈당</button>
					<button class="qbtn" onclick="_quickQ('주간 최저혈당 알려줘')">주간 최저혈당</button>
					<button class="qbtn" onclick="_quickQ('음식 추천해줘')">음식추천</button>
					<button class="qbtn" onclick="_quickQ('운동 추천해줘')">운동추천</button>
				</div>
			</div>
		</div>
	</div>
</div>

<!-- ══════════════════════════════════════════════
     세부 혈당 그래프 — 메뉴 우측 본문 전환 뷰 (APME_01A_2 를 iframe 으로 로드)
     풀스크린 모달이 개인 화면에서 어색하다는 지적으로 일반 페이지 전환처럼 구성
══════════════════════════════════════════════ -->
<div id="viewDetail" class="hidden">
	<div class="dv-topbar">
		<button type="button" class="btn btn-outline-secondary btn-sm" onclick="showHomeView();">← 내 혈당 홈</button>
		<b style="font-size:15px;color:#0d6efd;">📈 세부 혈당 그래프</b>
	</div>
	<iframe id="detailInlineFrame" src="about:blank" title="세부 혈당 그래프"
	        style="display:block;width:100%;height:calc(100vh - 55px);border:0;background:#fff;"></iframe>
</div>

<!-- ══════════════════════════════════════════════
     🤖 AI 종합분석(주간) — 앱 홈 카드의 '혈당 지표 확인' + 'AI 종합분석' 두 내용을 담은 별도 화면
══════════════════════════════════════════════ -->
<div id="viewAi" class="hidden">
	<div class="dv-topbar">
		<button type="button" class="btn btn-outline-secondary btn-sm" onclick="showHomeView();">← 내 혈당 홈</button>
		<b style="font-size:15px;color:#0d6efd;">🤖 AI 종합분석</b>
		<span id="aiPeriod" class="text-muted" style="font-size:12.5px;"></span>
	</div>
	<%-- 웹 화면 비율 2단: 좌=연속혈당 측정(24시간) / 우=AI 종합분석(주간)+생활습관 가이드 --%>
	<div style="padding:12px 16px 0;">
		<div class="ai-cols">
			<!-- 좌: 앱 '연속혈당 측정' 화면 대응 — 현재시점 24시간 기준 -->
			<div class="ai-col">
			<div class="card-tile" style="margin-bottom:0;">
				<h5>🩸 연속혈당 측정 <span class="text-muted" style="font-size:12.5px;font-weight:400;">· 현재시점 24시간 기준</span></h5>
				<%-- 앱 상단과 동일: [시작값·시각] → [변화량 mg/dL/5분] [최근값·시각] --%>
				<div class="ai24-head">
					<div class="c"><div class="v light" id="ai24First">-</div><div class="t" id="ai24FirstT">-</div></div>
					<div class="c"><div class="d" id="ai24Delta">&rarr; 0</div><div class="t">mg/dL/5분</div></div>
					<div class="c"><div class="v" id="ai24Last">-</div><div class="t" id="ai24LastT">-</div></div>
				</div>
				<%-- 앱과 동일한 일 단위 이동 ◀ 2026년 10월 7일 (화) ▶ --%>
				<div class="ai-daynav">
					<button type="button" onclick="_ai24Move(-1);" aria-label="이전 날">&#9664;</button>
					<span id="ai24DateTxt">-</span>
					<button type="button" onclick="_ai24Move(1);" aria-label="다음 날">&#9654;</button>
				</div>
				<div id="aiDateNote" style="font-size:12.5px;color:#1f5fbf;text-align:center;font-weight:600;min-height:18px;"></div>
				<%-- 앱과 동일한 구간 버튼 + 24시간 혈당 그래프 --%>
				<div class="ai-range" id="aiRangeBtns">
					<button type="button" data-h="3">3시간</button>
					<button type="button" data-h="6">6시간</button>
					<button type="button" data-h="12">12시간</button>
					<button type="button" data-h="24" class="on">24시간</button>
				</div>
				<div id="aiChart24" style="height:230px;margin-bottom:8px;"></div>
				<div class="ai-unit"><span>현재시점 24시간 기준</span><span>단위: mg/dL</span></div>
				<div class="ai-grid3">
					<div class="ai-cell"><div class="lb">평균 혈당</div><div class="v" id="aiAvg24" style="color:#2e7d32;">-</div><div class="u">mg/dL</div></div>
					<div class="ai-cell"><div class="lb">공복 평균</div><div class="v" id="aiFast24" style="color:#7b2d8e;">-</div><div class="u">mg/dL</div></div>
					<div class="ai-cell"><div class="lb">식후 평균</div><div class="v" id="aiMeal24" style="color:#e07b00;">-</div><div class="u">mg/dL</div></div>
				</div>
				<div id="aiMetricBox24"></div>
				<%-- 앱 FAHR_00 하단 문장 블록(현재 혈당 변화 · 설명 · GMI · TIR)과 동일 --%>
				<div class="ai-trend">
					<div class="tl">현재 혈당 변화가 <b id="ai24Status" class="st">-</b> 입니다</div>
					<div class="box" id="ai24StatusName">-</div>
					<div class="tl">• GMI수치(혈당관리지표)는 <b id="ai24GmiTxt">-</b> 입니다</div>
					<div class="tl">• TIR(목표범위 내 머문 비율)은 (일반적으로 70~180 mg/dl) <b id="ai24TirTxt">-</b> 입니다</div>
				</div>
			</div>
			</div>
			<!-- 우: 앱 'AI 종합분석(주간)' 화면 대응 -->
			<div class="ai-col">
				<div class="card-tile" style="margin-bottom:8px;">
					<h5>🤖 AI 종합분석(주간)</h5>
					<%-- 앱과 동일한 기간 이동 ◀ 2026.10.01 ~ 2026.10.07 ▶ --%>
					<div class="ai-weeknav">
						<button type="button" onclick="_aiWeekMove(-1);" aria-label="이전 일주일">&#9664;</button>
						<span id="aiPeriod2"></span>
						<button type="button" onclick="_aiWeekMove(1);" aria-label="다음 일주일">&#9654;</button>
					</div>
					<div class="ai-unit"><span>현재일 기준 이전 일주일</span><span>단위: mg/dL</span></div>
					<div class="ai-grid3">
						<div class="ai-cell"><div class="lb">평균 혈당</div><div class="v" id="aiAvgW" style="color:#2e7d32;">-</div><div class="u">mg/dL</div></div>
						<div class="ai-cell"><div class="lb">공복 평균</div><div class="v" id="aiFastW" style="color:#7b2d8e;">-</div><div class="u">mg/dL</div></div>
						<div class="ai-cell"><div class="lb">식후 평균</div><div class="v" id="aiMealW" style="color:#e07b00;">-</div><div class="u">mg/dL</div></div>
					</div>
					<div id="aiMetricBox"></div>
				</div>
				<div class="card-tile" style="margin-bottom:8px;">
					<%-- 앱과 동일: 파란 머리띠 + 점선 박스 --%>
					<div class="ai-sechead">* 혈당지표 분석 기반 생활습관 가이드</div>
					<div id="aiCoachBox" class="ai-dashbox"></div>
				</div>
				<%-- 앱 AI 종합분석 하단과 동일: 저혈당/고혈당 발생구간(3시간 단위) --%>
				<div class="card-tile" style="margin-bottom:8px;">
					<h5>* 저혈당/고혈당 발생구간(시간)</h5>
					<%-- 앱과 동일: 당일/7일/14일/30일 (기본 7일) --%>
					<div class="ai-range ai-range4" id="aiBandBtns">
						<button type="button" data-days="0">당일</button>
						<button type="button" data-days="7" class="on">7일</button>
						<button type="button" data-days="14">14일</button>
						<button type="button" data-days="30">30일</button>
					</div>
					<div id="aiBandChart" style="height:220px;"></div>
					<div class="ai-legend">
						<span><i style="background:#6CC070"></i>정상 (70~180)</span>
						<span><i style="background:#F0B24B"></i>고 (180이상)</span>
						<span><i style="background:#FF0000"></i>저 (70미만)</span>
					</div>
				</div>
				<%-- 앱과 동일: 고혈당/저혈당 구간 · 주의할음식 TOP3 · 추천운동 TOP3 --%>
				<div class="card-tile" style="margin-bottom:8px;">
					<div class="ai-line">* 고혈당 구간: <span id="aiHighZone">-</span></div>
					<div class="ai-line">* 저혈당 구간: <span id="aiLowZone">-</span></div>
				</div>
				<div class="card-tile" style="margin-bottom:8px;">
					<div class="ai-cardhead"><h5 style="margin:0;">* 주의할음식 TOP3(주간)</h5><span class="text-muted" style="font-size:12px;">단위 : mg/dL</span></div>
					<div class="ai-grid4 head"><span>순위</span><span>음식종류</span><span>식사량</span><span>혈당변동폭</span></div>
					<div id="aiFoodRows"></div>
				</div>
				<div class="card-tile" style="margin-bottom:8px;">
					<div class="ai-cardhead"><h5 style="margin:0;">* 추천운동 TOP3(주간)</h5><span class="text-muted" style="font-size:12px;">단위 : mg/dL</span></div>
					<div class="ai-grid4 head"><span>순위</span><span>운동종류</span><span>운동(분)</span><span>혈당변동폭</span></div>
					<div id="aiExerRows"></div>
				</div>
				<%-- 앱 하단 [참조링크] 카드와 동일 (헤더 클릭으로 접기/펼치기) --%>
				<div class="card-tile" style="margin-bottom:8px;padding:12px 24px;">
					<div class="ai-cardhead" style="cursor:pointer;margin:0;" onclick="$('#aiRefBody').toggle(); $('#aiRefCaret').text($('#aiRefBody').is(':visible')?'▾':'▸');">
						<b style="color:#1f4fbf;font-size:15px;">[참조링크]</b><span id="aiRefCaret" class="text-muted">▾</span>
					</div>
					<div id="aiRefBody" style="padding-top:6px;line-height:2;font-size:14.5px;">
						💡 <a href="https://www.diabetes.or.kr/" target="_blank" rel="noopener" style="color:#1f4fbf;">대한당뇨병학회 바로가기</a><br>
						💡 <a href="https://www.youtube.com/channel/UCsVB1GWF-NH-RTxJax8XA_Q/featured?view_as=subscriber" target="_blank" rel="noopener" style="color:#1f4fbf;">당뇨병의정석 (YouTube)</a>
					</div>
				</div>
				<div id="aiBasisNote" class="hidden"></div>
			</div>
		</div>
	</div>
</div>

<!-- ══════════════════════════════════════════════
     ⚙ 설정 모달 — 케어센스(i-Sens) 연동 + 모바일 접속 QR
     (모바일에서는 사이드바가 숨으므로 상단 ⚙ 버튼으로 연다)
══════════════════════════════════════════════ -->
<div class="modal fade" id="settingsModal" tabindex="-1" aria-hidden="true">
  <%-- 세로로 긴 모달이라 가운데 정렬(-centered)이면 낮은 해상도에서 아래(QR)가 잘린다
       → 위쪽 붙임 + 넘치면 모달 안에서 스크롤(-scrollable) --%>
  <div class="modal-dialog modal-dialog-scrollable" style="max-width:420px;margin-top:14px;">
    <div class="modal-content border-0 shadow-lg" style="border-radius:16px;overflow:hidden;">
      <div class="modal-header border-0 px-4 pt-4 pb-3" style="background:linear-gradient(135deg,#0d6efd 0%,#6610f2 100%);">
        <h5 class="modal-title fw-bold text-white mb-0" style="font-size:1.1rem;">⚙ 설정</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body px-4 py-4" style="background:#f8f9fc;">
        <!-- 케어센스 연동 -->
        <div class="card border-0 shadow-sm mb-3" style="border-radius:12px;">
          <div class="card-body p-3">
            <h6 class="fw-semibold mb-2">🩸 케어센스(i-Sens) 연동</h6>
            <div class="d-flex align-items-center gap-2 flex-wrap">
              <span id="tokenStatus2" class="small">…</span>
              <button id="btnConnect2" class="btn btn-primary btn-sm" onclick="connectISens();" style="display:none;">연동하기</button>
              <button id="btnSync2"    class="btn btn-success btn-sm" onclick="syncMyBlood(false);" style="display:none;">혈당 가져오기</button>
            </div>
            <div class="text-muted mt-2" style="font-size:12.5px;">
              연동하면 케어센스 혈당이 자동으로 들어옵니다. 토큰이 만료되면 다시 연동해 주세요.
            </div>
          </div>
        </div>
        <!-- 모바일 접속 QR -->
        <div class="card border-0 shadow-sm" style="border-radius:12px;">
          <div class="card-body p-3">
            <h6 class="fw-semibold mb-1">📱 모바일 앱 설치</h6>
            <div class="text-muted mb-1" style="font-size:12.5px;">
              휴대폰 카메라로 아래 QR을 찍으면 <b>allCare 앱 설치 화면</b>이 열립니다.<br>
              홈 화면에 아이콘을 만들면 다음부터는 QR 없이 아이콘으로 바로 열려요.
            </div>
            <div id="settingsQr"></div>
            <div id="settingsQrUrl"></div>
          </div>
        </div>
        <!-- 약관 (앱 설정 화면과 동일 구성 — T_SIGN_MST, /getSignList.do 재사용) -->
        <div class="card border-0 shadow-sm mt-3" style="border-radius:12px;">
          <div class="card-body p-3">
            <h6 class="fw-semibold mb-2">📜 약관</h6>
            <div class="list-group list-group-flush">
              <button type="button" class="list-group-item list-group-item-action px-1 py-2" onclick="openTerms(3,'서비스 이용약관');">서비스 이용약관 &rsaquo;</button>
              <button type="button" class="list-group-item list-group-item-action px-1 py-2" onclick="openTerms(1,'개인정보 취급방침');">개인정보 취급방침 &rsaquo;</button>
              <button type="button" class="list-group-item list-group-item-action px-1 py-2" onclick="openTerms(2,'민감정보 취급방침');">민감정보 취급방침 &rsaquo;</button>
              <button type="button" class="list-group-item list-group-item-action px-1 py-2" onclick="openAgreeList();">개인정보 약관 동의 내역 &rsaquo;</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════════
     📜 약관 본문 모달 — 약관동의 목록·설정 모달 위에 겹쳐 뜸(modal-stack z-index). 닫으면 아래 목록으로 복귀.
     높이를 줄이고(최대 72vh) 본문은 안에서 스크롤 [2026-10-21 요청]
══════════════════════════════════════════════ -->
<div class="modal fade" id="termsViewModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg" style="margin-top:40px;">
    <div class="modal-content border-0 shadow-lg" style="border-radius:16px;overflow:hidden;max-height:72vh;display:flex;flex-direction:column;">
      <div class="modal-header border-0 px-4 pt-3 pb-2" style="background:linear-gradient(135deg,#0d6efd 0%,#6610f2 100%);flex:0 0 auto;">
        <h5 class="modal-title fw-bold text-white mb-0" id="termsViewTitle" style="font-size:1.05rem;">약관</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body px-4 py-3" style="background:#fff;overflow-y:auto;flex:1 1 auto;min-height:0;">
        <div id="termsViewBody" style="font-size:13.5px;line-height:1.65;color:#333;white-space:pre-wrap;"></div>
      </div>
      <div class="modal-footer border-0 py-2 px-4" style="flex:0 0 auto;">
        <button type="button" class="btn btn-outline-secondary btn-sm px-4" data-bs-dismiss="modal">닫기</button>
      </div>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════════
     📝 약관동의 / 동의내역 모달 (설정 모달 위에 겹쳐 뜸 — modal-stack 핸들러가 z-index 처리)
══════════════════════════════════════════════ -->
<div class="modal fade" id="termsModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-scrollable" style="margin-top:14px;">
    <div class="modal-content border-0 shadow-lg" style="border-radius:16px;overflow:hidden;">
      <div class="modal-header border-0 px-4 pt-4 pb-3" style="background:linear-gradient(135deg,#0d6efd 0%,#6610f2 100%);">
        <h5 class="modal-title fw-bold text-white mb-0" id="termsTitle" style="font-size:1.1rem;">약관</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body px-4 py-4" style="background:#fff;">
        <div id="termsBody" style="font-size:14px;line-height:1.75;color:#333;white-space:pre-wrap;"></div>
      </div>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════════
     📢 공지사항 모달
══════════════════════════════════════════════ -->
<div class="modal fade" id="noticeModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-scrollable" style="margin-top:14px;">
    <div class="modal-content border-0 shadow-lg" style="border-radius:16px;overflow:hidden;">
      <div class="modal-header border-0 px-4 pt-4 pb-3" style="background:linear-gradient(135deg,#0d6efd 0%,#6610f2 100%);">
        <h5 class="modal-title fw-bold text-white mb-0" style="font-size:1.1rem;">📢 공지사항</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body px-4 py-4" style="background:#f8f9fc;">
        <div id="noticeList"></div>
      </div>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════════
     👤 개인정보 변경 모달 — 이메일·키·몸무게만 수정 가능
══════════════════════════════════════════════ -->
<div class="modal fade" id="myInfoModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-scrollable" style="max-width:420px;margin-top:14px;">
    <div class="modal-content border-0 shadow-lg" style="border-radius:16px;overflow:hidden;">
      <div class="modal-header border-0 px-4 pt-4 pb-3" style="background:linear-gradient(135deg,#0d6efd 0%,#6610f2 100%);">
        <h5 class="modal-title fw-bold text-white mb-0" style="font-size:1.1rem;">👤 개인정보 변경</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body px-4 py-4" style="background:#f8f9fc;">
        <div class="card border-0 shadow-sm" style="border-radius:12px;">
          <div class="card-body p-3">
            <div class="row g-2">
              <div class="col-6"><label class="form-label small text-muted mb-1">이름</label>
                <input type="text" id="miNm" class="form-control form-control-sm" readonly></div>
              <div class="col-6"><label class="form-label small text-muted mb-1">전화번호</label>
                <input type="text" id="miPhone" class="form-control form-control-sm" readonly></div>
              <div class="col-6"><label class="form-label small text-muted mb-1">생년월일</label>
                <input type="text" id="miBirth" class="form-control form-control-sm" readonly></div>
              <div class="col-6"><label class="form-label small text-muted mb-1">성별</label>
                <input type="text" id="miGender" class="form-control form-control-sm" readonly></div>
              <div class="col-12"><label class="form-label small mb-1">이메일</label>
                <input type="email" id="miEmail" class="form-control form-control-sm" placeholder="example@mail.com"></div>
              <div class="col-6"><label class="form-label small mb-1">키(cm)</label>
                <input type="number" id="miHeight" class="form-control form-control-sm" min="0" max="250"></div>
              <div class="col-6"><label class="form-label small mb-1">몸무게(kg)</label>
                <input type="number" id="miWeight" class="form-control form-control-sm" min="0" max="300"></div>
              <div class="col-12"><label class="form-label small mb-1">당뇨 유형</label>
                <select id="miBlodGb" class="form-select form-select-sm">
                  <option value="0">미지정</option>
                  <option value="1">1형 당뇨병</option>
                  <option value="2">2형 당뇨병</option>
                  <option value="3">당뇨병 전단계</option>
                  <option value="4">임신성 당뇨병</option>
                  <option value="9">기타</option>
                </select></div>
            </div>
            <div class="text-muted mt-2" style="font-size:12px;">이름·전화번호·생년월일·성별 변경은 병원에 문의해 주세요.</div>
            <div class="text-end mt-3">
              <button type="button" class="btn btn-primary btn-sm px-4" onclick="saveMyInfo();">저장</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════════
     식사 기록 모달
══════════════════════════════════════════════ -->
<div class="modal fade" id="foodModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static" data-bs-keyboard="false">
  <div class="modal-dialog modal-lg modal-dialog-scrollable">
    <div class="modal-content border-0 shadow-lg" style="border-radius:16px;overflow:hidden;">
      <div class="modal-header border-0 px-4 pt-4 pb-3" style="background:linear-gradient(135deg,#0d6efd 0%,#6610f2 100%);">
        <div>
          <h5 class="modal-title fw-bold text-white mb-0" style="font-size:1.15rem;">🍚 식사 기록</h5>
          <p class="text-white-50 small mb-0 mt-1">식사 내역을 기록하고 전체 이력을 확인하세요</p>
        </div>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body px-4 pt-3 pb-4" style="background:#f8f9fc;">
        <!-- 입력 폼 -->
        <div class="card border-0 shadow-sm mb-4" style="border-radius:12px;">
          <div class="card-body p-4">
            <h6 class="fw-semibold text-muted mb-3 d-flex align-items-center gap-2">
              <span style="width:6px;height:18px;background:#0d6efd;border-radius:3px;display:inline-block;"></span>새 기록 추가
            </h6>
            <div class="row g-3">
              <div class="col-md-4">
                <label class="form-label small fw-semibold text-secondary">식사일자</label>
                <input type="date" id="mFoodDate" class="form-control form-control-sm rounded-2">
              </div>
              <div class="col-md-4">
                <label class="form-label small fw-semibold text-secondary">시작시간 <small class="fw-normal text-muted">(HHMMSS)</small></label>
                <input type="text" id="mFoodStime" class="form-control form-control-sm rounded-2" placeholder="시작시간 선택" readonly>
              </div>
              <div class="col-md-4">
                <label class="form-label small fw-semibold text-secondary">종료시간 <small class="fw-normal text-muted">(선택)</small></label>
                <input type="text" id="mFoodEtime" class="form-control form-control-sm rounded-2" placeholder="종료시간 선택 (선택)">
              </div>
              <div class="col-md-6">
                <label class="form-label small fw-semibold text-secondary">음식명</label>
                <input type="text" id="mFoodName" class="form-control form-control-sm rounded-2" placeholder="예: 김치찌개" lang="ko" inputmode="text" style="ime-mode:active;">
              </div>
              <div class="col-md-3">
                <label class="form-label small fw-semibold text-secondary">단위</label>
                <input type="text" id="mFoodDanwi" class="form-control form-control-sm rounded-2" placeholder="공기 / g / 개">
              </div>
              <div class="col-md-3">
                <label class="form-label small fw-semibold text-secondary">개수</label>
                <input type="text" id="mFoodAcnt" class="form-control form-control-sm rounded-2" placeholder="1">
              </div>
            </div>
            <div class="text-end mt-3">
              <button class="btn btn-primary btn-sm px-4 rounded-pill" onclick="saveFood();">저장</button>
            </div>
          </div>
        </div>
        <!-- 전체 기록 -->
        <div class="card border-0 shadow-sm" style="border-radius:12px;">
          <div class="card-body p-0">
            <div class="px-4 pt-3 pb-2 border-bottom d-flex align-items-center gap-2">
              <span style="width:6px;height:18px;background:#6610f2;border-radius:3px;display:inline-block;"></span>
              <h6 class="fw-semibold text-muted mb-0">전체 기록</h6>
            </div>
            <div style="max-height:210px;overflow-y:auto;">
              <table class="table table-sm table-hover align-middle mb-0">
                <thead class="table-light" style="position:sticky;top:0;z-index:1;">
                  <tr><th class="ps-4">날짜</th><th>시작</th><th>종료</th><th>음식</th><th class="text-end">개수</th><th class="text-center pe-2"></th></tr>
                </thead>
                <tbody id="mFoodList">
                  <tr><td colspan="5" class="text-center text-muted py-3">불러오는 중…</td></tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════════
     운동 기록 모달
══════════════════════════════════════════════ -->
<div class="modal fade" id="exerModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static" data-bs-keyboard="false">
  <div class="modal-dialog modal-lg modal-dialog-scrollable">
    <div class="modal-content border-0 shadow-lg" style="border-radius:16px;overflow:hidden;">
      <div class="modal-header border-0 px-4 pt-4 pb-3" style="background:linear-gradient(135deg,#198754 0%,#20c997 100%);">
        <div>
          <h5 class="modal-title fw-bold text-white mb-0" style="font-size:1.15rem;">🚴 운동 기록</h5>
          <p class="text-white-50 small mb-0 mt-1">운동 내역을 기록하고 전체 이력을 확인하세요</p>
        </div>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body px-4 pt-3 pb-4" style="background:#f8f9fc;">
        <!-- 입력 폼 -->
        <div class="card border-0 shadow-sm mb-4" style="border-radius:12px;">
          <div class="card-body p-4">
            <h6 class="fw-semibold text-muted mb-3 d-flex align-items-center gap-2">
              <span style="width:6px;height:18px;background:#198754;border-radius:3px;display:inline-block;"></span>새 기록 추가
            </h6>
            <div class="row g-3">
              <div class="col-md-4">
                <label class="form-label small fw-semibold text-secondary">운동일자</label>
                <input type="date" id="mExerDate" class="form-control form-control-sm rounded-2">
              </div>
              <div class="col-md-4">
                <label class="form-label small fw-semibold text-secondary">시작시간 <small class="fw-normal text-muted">(HHMMSS)</small></label>
                <input type="text" id="mExerStime" class="form-control form-control-sm rounded-2" placeholder="시작시간 선택" readonly>
              </div>
              <div class="col-md-4">
                <label class="form-label small fw-semibold text-secondary">종료시간 <small class="fw-normal text-muted">(선택)</small></label>
                <input type="text" id="mExerEtime" class="form-control form-control-sm rounded-2" placeholder="종료시간 선택 (선택)">
              </div>
              <div class="col-md-5">
                <label class="form-label small fw-semibold text-secondary">운동명</label>
                <input type="text" id="mExerName" class="form-control form-control-sm rounded-2" placeholder="예: 산책" lang="ko" inputmode="text" style="ime-mode:active;">
              </div>
              <div class="col-md-4">
                <label class="form-label small fw-semibold text-secondary">강도</label>
                <select id="mExerInt" class="form-select form-select-sm rounded-2">
                  <option value="">선택</option>
                  <option value="L">약함</option>
                  <option value="M" selected>보통</option>
                  <option value="H">강함</option>
                </select>
              </div>
              <div class="col-md-3">
                <label class="form-label small fw-semibold text-secondary">걸음수/횟수</label>
                <input type="text" id="mExerCnt" class="form-control form-control-sm rounded-2" placeholder="3000" onkeyup="this.value=this.value.replace(/[^0-9]/g,'');">
              </div>
            </div>
            <div class="text-end mt-3">
              <button class="btn btn-success btn-sm px-4 rounded-pill" onclick="saveExer();">저장</button>
            </div>
          </div>
        </div>
        <!-- 전체 기록 -->
        <div class="card border-0 shadow-sm" style="border-radius:12px;">
          <div class="card-body p-0">
            <div class="px-4 pt-3 pb-2 border-bottom d-flex align-items-center gap-2">
              <span style="width:6px;height:18px;background:#20c997;border-radius:3px;display:inline-block;"></span>
              <h6 class="fw-semibold text-muted mb-0">전체 기록</h6>
            </div>
            <div style="max-height:210px;overflow-y:auto;">
              <table class="table table-sm table-hover align-middle mb-0">
                <thead class="table-light" style="position:sticky;top:0;z-index:1;">
                  <tr><th class="ps-4">날짜</th><th>시작</th><th>종료</th><th>운동</th><th class="text-end">횟수</th><th class="text-center pe-2"></th></tr>
                </thead>
                <tbody id="mExerList">
                  <tr><td colspan="5" class="text-center text-muted py-3">불러오는 중…</td></tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════════
     자주하는 질문 (FAQ) 모달
══════════════════════════════════════════════ -->
<div class="modal fade" id="faqModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static" data-bs-keyboard="false">
  <div class="modal-dialog modal-lg modal-dialog-scrollable">
    <div class="modal-content border-0 shadow-lg" style="border-radius:16px;overflow:hidden;">
      <div class="modal-header border-0 px-4 pt-4 pb-3" style="background:linear-gradient(135deg,#0d6efd 0%,#0aa2c0 100%);">
        <div>
          <h5 class="modal-title fw-bold text-white mb-0" style="font-size:1.15rem;">❓ 자주하는 질문</h5>
          <p class="text-white-50 small mb-0 mt-1">궁금한 점을 빠르게 확인하세요</p>
        </div>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body px-4 pt-3 pb-4" style="background:#f8f9fc;">
        <div class="input-group input-group-sm mb-3">
          <span class="input-group-text bg-white">🔍</span>
          <input type="text" id="faqSearch" class="form-control" placeholder="질문 검색…" onkeyup="_faqFilter();">
        </div>
        <div id="faqList">
          <div class="text-center text-muted py-4">불러오는 중…</div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════════
     1:1 문의 (질의응답) 모달 — sejong_app ASQ 참조
══════════════════════════════════════════════ -->
<div class="modal fade" id="asqModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static" data-bs-keyboard="false">
  <div class="modal-dialog modal-lg modal-dialog-scrollable">
    <div class="modal-content border-0 shadow-lg" style="border-radius:16px;overflow:hidden;">
      <div class="modal-header border-0 px-4 pt-4 pb-3" style="background:linear-gradient(135deg,#6610f2 0%,#0d6efd 100%);">
        <div>
          <h5 class="modal-title fw-bold text-white mb-0" style="font-size:1.15rem;">💬 1:1 문의</h5>
          <p class="text-white-50 small mb-0 mt-1">궁금한 점을 남기시면 답변해 드립니다</p>
        </div>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body px-4 pt-3 pb-4" style="background:#f8f9fc;">
        <!-- 문의 등록 -->
        <div class="card border-0 shadow-sm mb-4" style="border-radius:12px;">
          <div class="card-body p-4">
            <h6 class="fw-semibold text-muted mb-2 d-flex align-items-center gap-2">
              <span style="width:6px;height:18px;background:#6610f2;border-radius:3px;display:inline-block;"></span>새 문의 등록
            </h6>
            <div class="small text-secondary mb-2" style="background:#f0f0f5;border-radius:8px;padding:9px 12px;line-height:1.5;">
              진료와 관련된 내용은 답변이 제한되며, 진료 시 의료진과 상담하셔야 합니다.<br>
              실증·체험 진행과 관련한 문의만 가능합니다.
            </div>
            <textarea id="asqInput" class="form-control form-control-sm rounded-2" rows="4"
              placeholder="문의 내용을 입력하세요." lang="ko" inputmode="text" style="ime-mode:active;resize:none;"></textarea>
            <div class="text-end mt-3">
              <button class="btn btn-primary btn-sm px-4 rounded-pill" onclick="saveAsq();">등록</button>
            </div>
          </div>
        </div>
        <!-- 내 문의 이력 -->
        <h6 class="fw-semibold text-muted mb-2 d-flex align-items-center gap-2">
          <span style="width:6px;height:18px;background:#0d6efd;border-radius:3px;display:inline-block;"></span>내 문의 이력
        </h6>
        <div id="asqList">
          <div class="text-center text-muted py-4">불러오는 중…</div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- (세부 혈당 그래프 풀스크린 모달은 2026-10-21 본문 전환 뷰 #viewDetail 로 대체·제거) -->

<!-- 식사/운동 마커 클릭 팝업 -->
<!-- markerPopup 제거 (axis 툴팁에 통합) -->
<!-- 확인 다이얼로그(#confirmBackdrop)는 공통 ui-message.js 가 자동 주입 -->

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
