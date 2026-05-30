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
<script src="/asset/js/blood_qa.js"></script>
<script src="https://cdn.jsdelivr.net/npm/echarts/dist/echarts.min.js"></script>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
<script src="https://cdn.jsdelivr.net/npm/flatpickr" defer></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/ko.js" defer></script>
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
			if (silent) {
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
	} else {
		$("#weekAvg").text("-");
	}
	if (typeof echarts === 'undefined') {
		$("#dailyChart").html('<div class="text-center text-danger p-3">차트 라이브러리(echarts) 로드 실패 — 네트워크/CDN 차단 여부를 확인하세요.</div>');
	} else if (present.length === 0) {
		$("#dailyChart").html('<div class="text-center text-muted p-3">최근 1주일 데이터 없음</div>');
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

		// 혈당 시간별 평균 버킷
		var buckets = {};
		rows.forEach(function(r){
			var hm = r.HM || toHM(r.DTM);
			var hh = hm.substring(0,2);
			var v  = parseInt(r.UPT,10);
			if (!hh || isNaN(v)) return;
			if (!buckets[hh]) buckets[hh] = { sum:0, cnt:0 };
			buckets[hh].sum += v; buckets[hh].cnt++;
		});

		// 식사·운동 시간(HH) 수집
		var foodMap = {}, exerMap = {};
		foodRows.forEach(function(r){
			var hh = (r.eatStime||'').substring(0,2);
			if (hh) { if (!foodMap[hh]) foodMap[hh]=[]; foodMap[hh].push(r.foodName||'식사'); }
		});
		exerRows.forEach(function(r){
			var hh = (r.exerStime||'').substring(0,2);
			if (hh) { if (!exerMap[hh]) exerMap[hh]=[]; exerMap[hh].push(r.exerName||'운동'); }
		});

		// x축 = 혈당 + 식사 + 운동 시간의 합집합 (식사·운동만 있는 시간도 표시)
		var hourSet = {};
		Object.keys(buckets).forEach(function(h){ hourSet[h]=1; });
		Object.keys(foodMap).forEach(function(h){ hourSet[h]=1; });
		Object.keys(exerMap).forEach(function(h){ hourSet[h]=1; });
		var hours = Object.keys(hourSet).sort();
		var xs = hours.map(function(h){ return h+'시'; });
		var ys = hours.map(function(h){ return buckets[h] ? Math.round(buckets[h].sum/buckets[h].cnt) : null; });

		// 식사/운동 마커 — 상단 고정 레인(y)에 배치, 해당 시간에만 표시
		// 같은 시간에 식사·운동이 겹쳐도 세로로 분리되도록 충분히 간격(FOOD 위 / EXER 아래)
		var FOOD_Y = 290, EXER_Y = 258;
		var foodPts = hours.map(function(h){ return foodMap[h] ? FOOD_Y : null; });
		var exerPts = hours.map(function(h){ return exerMap[h] ? EXER_Y : null; });
		// 식사·운동이 있는 시간에 세로 점선 표시 (마커를 타임라인에 연결)
		var eventLines = hours.filter(function(h){ return foodMap[h] || exerMap[h]; })
		                      .map(function(h){ return { xAxis: h+'시' }; });

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
					var hh=hours[params[0].dataIndex]||'';
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
			xAxis: { type:'category', data:xs, axisTick:{ alignWithLabel:true } },
			yAxis: { type:'value', min:0, max:300 },
			series: [
				{
					name:'혈당',
					type:'line', data:ys, smooth:true, areaStyle:{}, connectNulls:true,
					label:{ show:true, position:'top', formatter:function(p){ return p.value!=null ? p.value : ''; } },
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
		// 혈당 평가 패널 업데이트
		updateEvalPanel(hours, ys, foodMap, exerMap, label);
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
function pad(n){ return (n<10?'0':'')+n; }
// 현재 시간대별 차트에 표시된 날짜 추적
var _currentDayKey = null, _currentDayLabel = null;
// "2026-05-29" → "5/29" 레이블 변환
function _dayLabel(dateKey){
	var p=(dateKey||'').split('-');
	return p.length===3 ? parseInt(p[1])+'/'+parseInt(p[2]) : dateKey;
}
function localDate(d){ return d.getFullYear()+'-'+pad(d.getMonth()+1)+'-'+pad(d.getDate()); }
function fmtT(s){ if(!s||s.length<4) return s||''; return s.substring(0,2)+':'+s.substring(2,4); }
function fmtD(s){ if(!s||s.length<8) return s||''; return s.substring(0,4)+'-'+s.substring(4,6)+'-'+s.substring(6,8); }
/* HH:MM (time input) → HHMMSS (서버 전송용) */
function toHHMMSS(hhmm){ if(!hhmm) return ''; var p=hhmm.replace(':',''); return p.length>=4 ? p.substring(0,4)+'00' : ''; }
/* HH:MM:SS 현재 시각 */
function nowHHMM(){ var t=new Date(); return pad(t.getHours())+':'+pad(t.getMinutes()); }

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
			_addMsg('안녕하세요! 혈당 관련 궁금한 점을 질문해 주세요.<br>차트를 선택하면 우측 평가가 표시됩니다.', false, 'chat-intro');
		}
	});
}
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

	// ② 매칭 실패 → 서버 LLM(Gemini) fallback. "입력 중…" 표시 후 응답으로 교체
	var $typing = $('<div class="chat-bot"><span class="chat-text">…</span></div>');
	$('#chatMessages').append($typing);
	$('#chatMessages')[0].scrollTop = $('#chatMessages')[0].scrollHeight;

	$.ajax({
		url: CommonUtil.getContextPath()+'/blood/chatAsk.do',
		type:'post',
		data: JSON.stringify({ q:q, ctx:_chatCtxText() }),
		contentType:'application/json',
		dataType:'json',
		success:function(r){
			$typing.remove();
			if (r && r.IsSucceed && r.Data) _addMsg(String(r.Data), false);
			else _addMsg(_chatFallbackMsg(), false);
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
		for (var i = 0; i < BLOOD_QA.length; i++) {
			var item = BLOOD_QA[i];
			if (!item || !item.kw) continue;
			for (var j = 0; j < item.kw.length; j++) {
				if (q.indexOf(String(item.kw[j]).toLowerCase()) !== -1) {
					return item.a;
				}
			}
		}
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
$(function(){
	// 초기 인사 메시지
	_addMsg('안녕하세요! 혈당 관련 궁금한 점을 질문해 주세요.<br>차트를 선택하면 우측 평가가 표시됩니다.', false, 'chat-intro');
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
<body>
<div class="container-fluid py-4" style="max-width:1420px;margin:0 auto;padding-left:20px;padding-right:20px;">
	<div class="d-flex justify-content-between align-items-center mb-3">
		<h3>${sessionScope.userNm}님 환영합니다</h3>
		<div class="d-flex align-items-center gap-2">
			<span id="tokenStatus" class="me-1">…</span>
			<button id="btnConnect" class="btn btn-primary btn-sm" onclick="connectISens();" style="display:none;">i-Sens 연동</button>
			<button id="btnSync"    class="btn btn-success btn-sm" onclick="syncMyBlood(false);" style="display:none;">혈당 가져오기</button>
			<button class="btn btn-outline-primary btn-sm" onclick="goFood();">🍚 식사 기록</button>
			<button class="btn btn-outline-primary btn-sm" onclick="goExer();">🚴 운동 기록</button>
			<button class="btn btn-outline-secondary btn-sm" onclick="logout();">로그아웃</button>
		</div>
	</div>
	<div id="syncMsg" class="text-muted small mb-2" style="display:none;"></div>

	<div class="d-flex gap-3 align-items-start">
		<!-- 좌측: 차트/카드 -->
		<div style="flex:1;min-width:0;">
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
		<div id="rightPanel" style="width:400px;flex-shrink:0;display:flex;flex-direction:column;gap:12px;position:sticky;top:16px;overflow:hidden;">
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
					<button class="qbtn" onclick="_quickQ('오늘 혈당이 높은가요?')">높은가요?</button>
					<button class="qbtn" onclick="_quickQ('혈당 정상범위는?')">정상범위</button>
					<button class="qbtn" onclick="_quickQ('언제 제일 높았나요?')">최고시간</button>
					<button class="qbtn" onclick="_quickQ('식후혈당이란?')">식후혈당</button>
					<button class="qbtn" onclick="_quickQ('공복혈당이란?')">공복혈당</button>
					<button class="qbtn" onclick="_quickQ('운동이 혈당에 미치는 영향은?')">운동 효과</button>
					<button class="qbtn" onclick="_quickQ('오늘 혈당 추이는?')">오늘 추이</button>
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
