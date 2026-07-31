<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>  
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>  
<%@ page import = "java.util.*" %>
<%@ page import="java.lang.*" %>
  
<html>
<head>  
 <title>회원 관리</title>
<!-- 달력(일자, 월별) 사용시 추가 필요함 -->  
<script src="/js/main.js"></script>
<style>
	.search-times {
	    display: flex;
	    align-items: center;
	    gap: 20px; /* 간격 조정 */
	    font-size: 14px; /* 글자 크기 */
	}
	
	.search-times .time {
	    color: blue; /* 시간을 파란색으로 설정 */
	    font-weight: bold; /* 강조 */
	}
	
	.search-times .divider {
	    margin: 0 10px; /* 구분자(|) 양쪽 간격 */
	    color: gray; /* 구분자 색상 */
	}
  .table-responsive {
    max-height: 600px; /* 적당한 높이 설정 (10개 행 기준으로 조정) */
    overflow-y: auto; /* 수직 스크롤 활성화 */
    border: 1px solid #ccc; /* 테두리 추가 */
  }

  #infoTable thead th {
    position: sticky;
    top: 0; /* 헤더 고정 */
    background-color: #d9edf7 !important; /* 헤더 배경색 — 연한 하늘색 */
    color: #000000 !important;
    z-index: 2; /* 헤더가 데이터보다 위에 위치하도록 설정 */
  }

  table tbody tr:nth-child(even) {
    background-color: #f2f2f2; /* 짝수행 배경색 설정 (가독성 개선) */
  }
  .total-count {
    margin-right: 1rem; /* 오른쪽 여백 (옵션) */
  }
  /* 페이징 영역 */
  .grid-pager {
    display: flex; align-items: center; justify-content: center;
    gap: 4px; padding: 10px 0; flex-wrap: wrap;
    font-size: 13px;
  }
  .grid-pager .pg-btn {
    border: 1px solid #ccc; background:#fff; color:#333;
    padding: 4px 10px; min-width: 32px; cursor:pointer; border-radius:3px;
  }
  .grid-pager .pg-btn:hover:not(:disabled) { background:#eef5ff; border-color:#1976d2; }
  .grid-pager .pg-btn:disabled { color:#aaa; cursor:not-allowed; background:#f7f7f7; }
  .grid-pager .pg-btn.active { background:#1976d2; color:#fff; border-color:#1976d2; font-weight:600; }
  .grid-pager .pg-sep { margin: 0 6px; color:#888; }
  .grid-pager select { padding: 3px 6px; border:1px solid #ccc; border-radius:3px; }
  /* [2026-07-31 기획 '검색기능개선'] 검색 조건 패널 */
  .search-panel { border:1px solid #d6dee8; background:#f7f9fc; border-radius:4px; padding:10px 12px; }
  .search-panel .sp-row { display:flex; align-items:center; gap:8px; flex-wrap:wrap; margin-bottom:8px; }
  .search-panel .sp-row:last-child { margin-bottom:0; }
  .search-panel .sp-lb { font-size:13px; font-weight:600; color:#333; min-width:56px; }
  .search-panel .sp-lb2 { margin-left:14px; }
  .search-panel .sp-in { height:30px; border:1px solid #c8d2de; border-radius:3px; padding:0 8px; font-size:13px; background:#fff; }
  .search-panel .sp-kw { flex:1; min-width:220px; }
  .search-panel .sp-tilde { color:#888; }
  /* 가입일 — 달력 아이콘을 크게(클릭 쉽게) + 칸 전체가 클릭 대상 */
  .search-panel .sp-date { cursor:pointer; padding-right:4px; }
  .search-panel .sp-date::-webkit-calendar-picker-indicator { cursor:pointer; opacity:.75; transform:scale(1.15); }
  .search-panel .sp-date:hover { border-color:#1976d2; }
  .search-panel .sp-quick { height:28px; padding:0 10px; font-size:12px; background:#fff; color:#37475a;
    border:1px solid #c8d2de; border-radius:14px; cursor:pointer; }
  .search-panel .sp-quick:hover { background:#eef5ff; border-color:#1976d2; color:#1976d2; }
  .search-panel .sp-soon { font-size:12px; color:#c0392b; }
  .search-panel .sp-chk { font-size:13px; display:flex; align-items:center; gap:4px; }
  .search-panel .sp-btn { height:32px; padding:0 26px; background:#555; color:#fff; border:0; border-radius:3px;
    font-size:14px; font-weight:600; cursor:pointer; }
  .search-panel .sp-btn:hover { background:#333; }
  .search-panel .search-times { margin-left:auto; display:flex; gap:14px; font-size:13px; }
  /* 이름 클릭 = 상세(기획: 이름에 링크 표시) */
  #infoTable .nm-link { color:#1976d2; text-decoration:underline; cursor:pointer; }
</style>
<script>
var user_gubun = "" ;
$(document).ready(function () {
	$("#user_gb").prop("checked",false);
	// [2026-07-31 기획] 가입일 기본값 = 2026-06-01 ~ 오늘
	var _t = new Date();
	var _p = function(n){ return (n<10?'0':'')+n; };
	$("#fJoinFrom").val("2026-06-01");
	$("#fJoinTo").val(_t.getFullYear()+"-"+_p(_t.getMonth()+1)+"-"+_p(_t.getDate()));
	fnSearch() ;
})
</script>
<script type="text/javaScript">
// ─────────────────────────────────────────────────────────────────────
// 페이징 상태 (클라이언트 사이드)
//   _gridRows     : 서버에서 받은 전체 리스트 (resultLst)
//   _gridPage     : 현재 페이지 (1-base)
//   _gridPageSize : 페이지당 행 수
// ─────────────────────────────────────────────────────────────────────
var _gridRows = [];
var _gridPage = 1;
var _gridPageSize = 20;

//조회시작
function fnSearch() {

	 document.getElementById("regForm").reset();

	 $("#dataArea").empty();
	 _gridRows = []; _gridPage = 1;
	 _renderPager();   // 검색 직전 페이저 초기화
//	 	if($('#searchText').val() == "") {
//		alert("검색어를 입력하세요.");
//		$('#searchText').focus();
//		return; 
//	 }
 
    user_gubun = $("#user_gb").is(':checked') ? "1" : "" ;   // 체크: 실증환자(1)만 / 해제: 전체
    
    var startTime = new Date(); //조회시작시간  
    
    let millisecondsStart = startTime.getMilliseconds().toString().padStart(4, '0'); // 밀리초
    let formatted01Hour = startTime.toLocaleTimeString('en-US', { 
      hour12: false, 
      hour: '2-digit', 
      minute: '2-digit', 
      second: '2-digit'
    }) + '.' + millisecondsStart;
    
    var sendTime;
    
    // [2026-07-31] 검색구분이 '이름'일 때만 서버에 이름을 넘긴다(연락처 검색은 화면에서 거른다 — 서버 무변경)
    var _kw = ($("#searchText").val()||"").trim();
    var _gb = $("#fSearchGb").val() || "nm";
    $.ajax({
   	url : CommonUtil.getContextPath() + '/doctor/selectPatientList.do',
    type : 'post',
    data : {userNm : (_gb === "nm" ? _kw : ""),
	        userGb : user_gubun,
    	    },
    	    beforeSend: function() {
                // 송신 시간 기록
    	    	sendTime = new Date();
            },
   	dataType : "json",
   	success : function(data) {
   		if(data.error_code != "0") return;
   		if(data.resultCnt > 0 ){
   			let endTime = new Date(); //조회종료시간 
   			let millisecondsEnd = endTime.getMilliseconds().toString().padStart(4, '0');
   			let formatted12Hour = endTime.toLocaleTimeString('en-US', { 
   			  hour12: false, 
   			  hour: '2-digit', 
   			  minute: '2-digit', 
   			  second: '2-digit'
   			}) + '.' + millisecondsEnd; 
   			formatted01Hour = formatted01Hour.substring(3,13);
   			formatted12Hour = formatted12Hour.substring(3,13);
            document.getElementById('formatted01Hour').innerText = formatted01Hour;
            document.getElementById('formatted12Hour').innerText = formatted12Hour;   			
            // 시간 계산
            let queryTime = ((sendTime.getTime() - startTime.getTime()) / 1000).toFixed(2); // 조회 시간 (초)
            let sendDuration = ((endTime.getTime() - sendTime.getTime()) / 1000).toFixed(2); // 송신 시간 (초)
            let totalResponseTime = ((endTime.getTime() - startTime.getTime()) / 1000).toFixed(2); // 총 응답 시간 (초)
            
            document.getElementById('totalResponseTime').innerText = totalResponseTime;
            
            // 시분초로 포맷팅
            let formatTime = (date) => date.toLocaleTimeString();
            
    		// [2026-07-31 기획] 화면 조건(가입일·성별·연령대·검색구분) 적용 + 정렬(이름/혈당지표)
    		_rawRows = data.resultLst || [];   // 혈당지표 정렬만 바뀔 때 재조회 없이 쓰려고 원본 보관
    		_gridRows = _applyFilters(_rawRows);
    		document.getElementById("totalCount").textContent = _gridRows.length;   // 검색결과 건수
    		_gridPage = 1;
    		_renderGridPage();
	 	  }else{
	 			 _gridRows = []; _gridPage = 1;
	 			 document.getElementById("totalCount").textContent = 0;
				 $("#dataArea").append("<tr><td colspan='16'>검색된 정보가 없습니다.</td></tr>");
				 _renderPager();
		  }
      }
   });
}
// ─────────────────────────────────────────────────────────────────────
// [2026-07-31 기획 '검색기능개선'] 화면 조건 필터 + 기본 정렬(이름 가나다순)
//   서버 조회는 종전 그대로(userNm·userGb)이고, 나머지 조건은 여기서 거른다.
// ─────────────────────────────────────────────────────────────────────
// [2026-07-31] 날짜값 정규화 — joinYmd 가 'YYYY-MM-DD' 로 오는 경우가 있어(화면에 '2026년 -0월 5-일'로 깨짐)
//   숫자만 남겨 'YYYYMMDD' 8자리로 통일한다. 표시·기간필터 양쪽에서 이 값을 쓴다.
function _ymd8(v){ return String(v==null?"":v).replace(/[^0-9]/g, "").substring(0,8); }
// [2026-07-31] 가입일 칸 클릭 시 달력 열기(Chrome/Edge showPicker). 미지원이면 아이콘 클릭으로 동작.
function _openCal(el){ try{ if(el && el.showPicker) el.showPicker(); }catch(e){} }
// 기간 빠른 선택 — 이번달 / 최근3개월 / 올해 / 전체(가입일 조건 해제) 후 즉시 조회
function _setJoinRange(kind){
	var t = new Date(), p = function(n){ return (n<10?'0':'')+n; };
	var f = function(d){ return d.getFullYear()+"-"+p(d.getMonth()+1)+"-"+p(d.getDate()); };
	var from = "", to = f(t);
	if(kind === 'm')       from = f(new Date(t.getFullYear(), t.getMonth(), 1));
	else if(kind === '3m'){ var d3 = new Date(t); d3.setMonth(d3.getMonth()-3); from = f(d3); }
	else if(kind === 'y')  from = t.getFullYear()+"-01-01";
	else if(kind === 'all'){ from = ""; to = ""; }
	$("#fJoinFrom").val(from); $("#fJoinTo").val(to);
	fnSearch();
}
function _ageOf(birth){
	if(!birth || birth.length < 8) return -1;
	var y = parseInt(birth.substring(0,4),10), m = parseInt(birth.substring(4,6),10), d = parseInt(birth.substring(6,8),10);
	var c = new Date(), age = c.getFullYear() - y;
	if((c.getMonth()+1) < m) age--;
	else if((c.getMonth()+1) === m && c.getDate() < d) age--;
	return age;
}
function _applyFilters(rows){
	var from = ($("#fJoinFrom").val()||"").replace(/-/g,"");   // 'YYYYMMDD'
	var to   = ($("#fJoinTo").val()||"").replace(/-/g,"");
	var gen  = $("#fGender").val() || "";
	var band = $("#fAgeBand").val() || "";
	var gb   = $("#fSearchGb").val() || "nm";
	var kw   = ($("#searchText").val()||"").trim();

	var out = (rows||[]).filter(function(r){
		// 가입일 기간 (값 형식이 'YYYY-MM-DD'/'YYYYMMDD' 모두 올 수 있어 8자리로 통일해 비교)
		var j = _ymd8(r.joinYmd);
		if(from && j && j < from) return false;
		if(to   && j && j > to)   return false;
		// 성별
		if(gen && r.gender !== gen) return false;
		// 연령대 (70 = 70대 이상)
		if(band){
			var a = _ageOf(r.birth||"");
			if(a < 0) return false;
			if(band === "70"){ if(a < 70) return false; }
			else{ var b = parseInt(band,10); if(a < b || a >= b+10) return false; }
		}
		// 연락처 검색(이름 검색은 서버가 이미 처리)
		if(gb === "tel" && kw){ if(String(r.phone||"").indexOf(kw.replace(/-/g,"")) < 0) return false; }
		return true;
	});
	// 정렬 — 혈당지표 선택 시 그 값 기준(값 없는 회원은 항상 뒤), 아니면 이름 가나다순(기본)
	var srt = $("#fBloodIdx").val() || "";
	if(srt){
		var key = { avg:'avgBlood', tar:'tar', tbr:'tbr', gmi:'gmi' }[srt.split('_')[0]];
		var desc = (srt.split('_')[1] === 'd');
		out.sort(function(a,b){
			var x = parseFloat(a[key]), y = parseFloat(b[key]);
			var xn = isNaN(x), yn = isNaN(y);
			if(xn && yn) return String(a.userNm||"").localeCompare(String(b.userNm||""), 'ko');
			if(xn) return 1;            // 값 없는 회원은 뒤로
			if(yn) return -1;
			if(x === y) return String(a.userNm||"").localeCompare(String(b.userNm||""), 'ko');
			return desc ? (y - x) : (x - y);
		});
	}else{
		out.sort(function(a,b){ return String(a.userNm||"").localeCompare(String(b.userNm||""), 'ko'); });
	}
	return out;
}
// 혈당지표 정렬만 바뀐 경우 — 서버 재조회 없이 이미 받아온 목록을 다시 정렬해 표시
var _rawRows = [];
function _renderGridFromFilter(){
	_gridRows = _applyFilters(_rawRows);
	document.getElementById("totalCount").textContent = _gridRows.length;
	_gridPage = 1;
	_renderGridPage();
}

// ─────────────────────────────────────────────────────────────────────
// 현재 페이지 행만 렌더
// ─────────────────────────────────────────────────────────────────────
function _renderGridPage(){
	$("#dataArea").empty();
	var total = _gridRows.length;
	if (total === 0) {
		$("#dataArea").append("<tr><td colspan='16'>검색된 정보가 없습니다.</td></tr>");
		_renderPager();
		return;
	}
	var totalPages = Math.max(1, Math.ceil(total / _gridPageSize));
	if (_gridPage > totalPages) _gridPage = totalPages;
	if (_gridPage < 1) _gridPage = 1;

	var startIdx = (_gridPage - 1) * _gridPageSize;
	var endIdx   = Math.min(startIdx + _gridPageSize, total);

	var html = "";
	for (var i = startIdx; i < endIdx; i++) {
		var row = _gridRows[i];
		// 성별
		var genderText = (row.gender == "F") ? "여성" : (row.gender == "M") ? "남성" : "";
		// 만나이
		var birthYear  = row.birth.substring(0,4);
		var birthMonth = parseInt(row.birth.substring(4,6),10);
		var birthDay   = parseInt(row.birth.substring(6,8),10);
		var cd = new Date();
		var age = cd.getFullYear() - parseInt(birthYear,10);
		if ((cd.getMonth()+1) < birthMonth) age--;
		else if ((cd.getMonth()+1) === birthMonth && cd.getDate() < birthDay) age--;
		// 환자 구분
		var userText = (row.userGb == "1") ? "실증환자" : (row.userGb == "2") ? "테스트" : "";

		html += '<tr ondblclick="javascript:fnDtlSearch(\''+row.userUuid+'\');" id="row_'+row.userUuid+'">';
		html +=   "<td>" + (i+1) + "</td>";   // 전체 기준 일련번호 (페이지 넘겨도 연속)
		// 기획: 이름은 링크 표시(클릭 = 상세). 기존 더블클릭 진입도 그대로 둔다.
		html +=   '<td><span class="nm-link" onclick="event.stopPropagation();fnDtlSearch(\''+row.userUuid+'\');">'
		        + row.userNm.substring(0,1) + "*" + row.userNm.substring(2,3) + "</span></td>";
		html +=   "<td>" + row.phone.substring(0,3) + "-****-" + row.phone.substring(7,11) + "</td>";
		html +=   "<td>" + genderText + "</td>";
		html +=   "<td>" + row.birth.substring(0,4) + "년&nbsp;" + row.birth.substring(4,6) + "월&nbsp;" + row.birth.substring(6,8) + "일</td>";
		html +=   "<td>" + age + "</td>";
		html +=   "<td>" + row.dtlCodeNm + "</td>";
		html +=   "<td>" + row.height + "</td>";
		html +=   "<td>" + row.weight + "</td>";
		// 혈당지표(최근 7일) — 값 없으면 '-' (2026-07-31)
		var _bv = function(v, suf){ return (v==null || v==="") ? "-" : (v + (suf||"")); };
		html +=   "<td>" + _bv(row.avgBlood) + "</td>";
		html +=   "<td>" + _bv(row.tar, "%") + "</td>";
		html +=   "<td>" + _bv(row.tbr, "%") + "</td>";
		html +=   "<td>" + _bv(row.gmi) + "</td>";
		var _j8 = _ymd8(row.joinYmd);   // 'YYYY-MM-DD' 로 와도 깨지지 않게 8자리로 통일(2026-07-31)
		html +=   "<td>" + (_j8.length===8 ? (_j8.substring(0,4)+"년&nbsp;"+_j8.substring(4,6)+"월&nbsp;"+_j8.substring(6,8)+"일") : "") + "</td>";
		html +=   "<td>" + row.regDtm + "</td>";
		html +=   "<td>" + userText + "</td>";
		html += "</tr>";
	}
	$("#dataArea").html(html);
	_renderPager();
}

// ─────────────────────────────────────────────────────────────────────
// 페이저 UI 렌더 (1 2 3 … N 형태, 좌/우 화살표 포함)
// ─────────────────────────────────────────────────────────────────────
function _renderPager(){
	var total = _gridRows.length;
	var totalPages = Math.max(1, Math.ceil(total / _gridPageSize));
	var p = _gridPage;
	// 화면에 표시할 페이지 번호 범위 (현재 페이지 기준 앞뒤 2개)
	var WIN = 2;
	var fromP = Math.max(1, p - WIN);
	var toP   = Math.min(totalPages, p + WIN);

	var html = '';
	// 페이지 크기 선택
	html += '<span>페이지당 </span>';
	html += '<select onchange="_changePageSize(this.value)">';
	[10,20,50,100].forEach(function(n){
		html += '<option value="'+n+'" '+(n===_gridPageSize?'selected':'')+'>'+n+'</option>';
	});
	html += '</select>';
	html += '<span class="pg-sep">|</span>';
	// 처음/이전
	html += '<button class="pg-btn" '+(p<=1?'disabled':'')+' onclick="_gotoPage(1)">«</button>';
	html += '<button class="pg-btn" '+(p<=1?'disabled':'')+' onclick="_gotoPage('+(p-1)+')">‹</button>';
	// 번호
	if (fromP > 1) {
		html += '<button class="pg-btn" onclick="_gotoPage(1)">1</button>';
		if (fromP > 2) html += '<span class="pg-sep">…</span>';
	}
	for (var i = fromP; i <= toP; i++) {
		html += '<button class="pg-btn '+(i===p?'active':'')+'" onclick="_gotoPage('+i+')">'+i+'</button>';
	}
	if (toP < totalPages) {
		if (toP < totalPages-1) html += '<span class="pg-sep">…</span>';
		html += '<button class="pg-btn" onclick="_gotoPage('+totalPages+')">'+totalPages+'</button>';
	}
	// 다음/끝
	html += '<button class="pg-btn" '+(p>=totalPages?'disabled':'')+' onclick="_gotoPage('+(p+1)+')">›</button>';
	html += '<button class="pg-btn" '+(p>=totalPages?'disabled':'')+' onclick="_gotoPage('+totalPages+')">»</button>';
	// 위치 표시
	html += '<span class="pg-sep">|</span>';
	html += '<span>'+p+' / '+totalPages+' (총 '+total+'건)</span>';

	$("#gridPager").html(html);
}
function _gotoPage(n){ _gridPage = n; _renderGridPage(); }
function _changePageSize(n){ _gridPageSize = parseInt(n,10); _gridPage = 1; _renderGridPage(); }

function formatTimeWithMilliseconds(date) { const hours = String(date.getHours()).padStart(2, '0');
         const minutes = String(date.getMinutes()).padStart(2, '0'); 
         const seconds = String(date.getSeconds()).padStart(2, '0'); 
         const milliseconds = String(date.getMilliseconds()).padStart(3, '0'); 
         return `${hours}:${minutes}:${seconds}.${milliseconds}`;
}
	function fnDtlSearch(data){ 
		if(data == '' || data == null) return;
		
		 document.regForm.userUuid.value = data ;
		//row 클릭시 바탕색 변경 처리 Start 
		$("#infoTable tr").attr("class", ""); 
		$("#infoTable #"+data).attr("checked", true);
		$("#infoTable #row_"+data).attr("class", "tr-primary");
		
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/tab/tabInfo.do",
			data : {userUuid : data},
			dataType : "json",
			success : function(data) {    
			//	 window.location.href = CommonUtil.getContextPath() +  "/tab/tab.do";
				 // 페이지를 새로고침 없이 변경
			        history.pushState(null, null, CommonUtil.getContextPath() + "/main.do");  // 주소 변경(가상)
			        $("#contentArea").load(CommonUtil.getContextPath() + "/tab/tab.do");  // 콘텐츠만 업데이트	
			}
		});
	}
    // 선택 환자의 i-Sens 혈당 데이터 수동 동기화
	function fnSyncBlood() {
		var uuid = $("#userUuid").val();
		if (!uuid) {
			alert("먼저 환자 행을 클릭하여 선택하세요.");
			return;
		}
		if (!confirm("선택한 환자의 i-Sens 혈당 데이터를 동기화하시겠습니까?")) return;

		$.ajax({
			type: "post",
			url: CommonUtil.getContextPath() + "/syncPatientBlood.do",
			data: JSON.stringify({ userUuid: uuid }),
			contentType: "application/json",
			dataType: "json",
			success: function(data) {
				if (data.IsSucceed) {
					alert(data.Message || ("동기화 완료: " + data.Data + " 건"));
				} else {
					alert("동기화 실패: " + (data.Message || ""));
				}
			},
			error: function(xhr, status, error) {
				alert("동기화 요청 중 오류가 발생했습니다.");
				console.error(status, error);
			}
		});
	}

    // 버튼 클릭 시 특정 JSP를 불러오는 함수
	function loadAdminResp() {
	    $.ajax({
	        type: "post",
	        url: CommonUtil.getContextPath() + "/admin/admin_resp.do",
	        dataType: "html", // JSP 화면 호출에 적합한 데이터 유형
	        success: function(response) {
	            // 호출한 JSP 화면을 특정 영역에 삽입
	            $("#targetElement").html(response);
	        },
	        error: function(xhr, status, error) {
	            console.error("Error loading JSP: ", error);
	        }
	    });
	}
</script>
</head>
<body>  
    <div class="tab-pane">  
      <div class="content-body">
      
	   <div class="tab-content">
		<div class="content-wrap">  
		
		<div class="flex-left-right mb-10">
			<div class="patient-info">
				<div class="info-name">회원관리</div>
			</div>
		</div>
		
        <%-- [2026-07-31 기획 '검색기능개선'] 가입일 기간 + 성별·연령대·혈당지표 + 검색구분/검색어.
             · 가입일·성별·연령대·연락처는 서버 응답을 화면에서 거른다(서버 조회는 종전 파라미터 그대로).
             · 혈당지표(평균혈당·TAR·TBR·GMI ▲▼)는 목록 쿼리에 최근 7일 CGM 집계를 붙여 정렬한다.
             · 가입일 기본 = 2026-06-01 ~ 오늘  · 기본 정렬 = 이름 가나다순 --%>
        <section class="top-pannel">
          <div class="search-panel">
            <div class="sp-row">
              <%-- 가입일 — 칸 아무 데나 클릭해도 달력이 열린다(showPicker, 미지원 브라우저는 아이콘 클릭) --%>
              <label class="sp-lb">가입일</label>
              <input type="date" id="fJoinFrom" class="sp-in sp-date" onclick="_openCal(this)" onfocus="_openCal(this)">
              <span class="sp-tilde">~</span>
              <input type="date" id="fJoinTo" class="sp-in sp-date" onclick="_openCal(this)" onfocus="_openCal(this)">
              <%-- 자주 쓰는 기간 빠른 선택 --%>
              <button type="button" class="sp-quick" onclick="_setJoinRange('m')">이번달</button>
              <button type="button" class="sp-quick" onclick="_setJoinRange('3m')">최근3개월</button>
              <button type="button" class="sp-quick" onclick="_setJoinRange('y')">올해</button>
              <button type="button" class="sp-quick" onclick="_setJoinRange('all')">전체</button>
              <%-- 혈당지표 = 최근 7일 CGM 집계 기준 정렬(평균혈당·고혈당·저혈당·GMI 각 ▲▼) --%>
              <label class="sp-lb sp-lb2">혈당지표</label>
              <select id="fBloodIdx" class="sp-in" onchange="_renderGridFromFilter()">
                <option value="">전체(이름순)</option>
                <option value="avg_d">평균혈당 ▼ 높은순</option>
                <option value="avg_a">평균혈당 ▲ 낮은순</option>
                <option value="tar_d">고혈당(TAR) ▼ 높은순</option>
                <option value="tar_a">고혈당(TAR) ▲ 낮은순</option>
                <option value="tbr_d">저혈당(TBR) ▼ 높은순</option>
                <option value="tbr_a">저혈당(TBR) ▲ 낮은순</option>
                <option value="gmi_d">GMI ▼ 높은순</option>
                <option value="gmi_a">GMI ▲ 낮은순</option>
              </select>
            </div>
            <div class="sp-row">
              <label class="sp-lb">성별</label>
              <select id="fGender" class="sp-in"><option value="">전체</option><option value="M">남성</option><option value="F">여성</option></select>
              <label class="sp-lb sp-lb2">연령대</label>
              <select id="fAgeBand" class="sp-in">
                <option value="">전체</option><option value="20">20대</option><option value="30">30대</option>
                <option value="40">40대</option><option value="50">50대</option><option value="60">60대</option><option value="70">70대 이상</option>
              </select>
              <label class="sp-lb sp-lb2">검색구분</label>
              <select id="fSearchGb" class="sp-in"><option value="nm">이름</option><option value="tel">연락처</option></select>
              <input type="text" name="searchText" id="searchText" class="sp-in sp-kw" placeholder="검색어를 입력하세요."
                     onkeypress="if( event.keyCode == 13 ){fnSearch();}">
            </div>
            <div class="sp-row sp-btnrow">
              <label class="sp-chk"><input class="form-check-input" type="checkbox" name="user_gb" onchange="fnSearch()" id="user_gb" value="Y"> 실증환자만</label>
              <button type="button" class="sp-btn" onclick="javascript:fnSearch();">조회</button>
              <span class="total-count">검색결과: <span id="totalCount">0</span>명</span>
              <div class="search-times" style="text-align: right; white-space: nowrap;">
                <span>조회분초: <span id="formatted01Hour" class="time">--:--</span></span>
                <span>조회종료: <span id="formatted12Hour" class="time">--:--</span></span>
                <span>소요시간: <span id="totalResponseTime" class="time">0</span>초</span>
              </div>
            </div>
          </div>
        </section>
       
        <section class="main-pannel">
          <div class="main-left w-100">
            <header class="main-hd">
              <h2></h2>
            </header>
            <div class="main-content">
              <!-- 테이블 샘플 -->
              <div class="table-responsive">
                <table id="infoTable" class="table table-bordered">
                  <colgroup>
                  	<col style="width: 50px">
                    <col style="width: 100px">
                    <col style="width: 100px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 100px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <%-- 혈당지표 4열 추가(2026-07-31) --%>
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 70px">
                    <col style="width: 180px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th>번호</th>
                      <th>이름</th>
                      <th>연락처</th>
                      <th>성별</th>
                      <th>생년월일</th>
                      <th>나이</th>
                      <th>당뇨구분</th>
                      <th>신장(cm)</th>     
                      <th>몸무게(kg)</th>                   
                      <%-- [2026-07-31] 혈당지표(최근 7일 CGM 집계) — 정렬 기준으로 쓰므로 값도 함께 보여준다 --%>
                      <th>평균혈당</th>
                      <th>고혈당<br>(TAR%)</th>
                      <th>저혈당<br>(TBR%)</th>
                      <th>GMI</th>
                      <th>가입일</th>
                      <th>가입접수일시</th>
                      <th>환자구분</th>
                    </tr>
                  </thead>
                  <tbody id="dataArea">
        			<tr>
        				<td colspan="8">&nbsp;</td>
        			</tr>
                  </tbody>
                </table>
              </div>
              <!-- 페이저 영역 -->
              <div id="gridPager" class="grid-pager"></div>
            </div>
          </div>
        </section>
        </div>
        </div>
      </div>
  <form:form commandName="DTO" id="regForm" name="regForm" method="post"> 
   <input type="hidden" name="userUuid" id="userUuid" value="${sessionScope['t_user_uuid']}"/>
  </form:form>
  </div>
<!-- Modal -->
<div class="modal fade" id="responseTimeModal" tabindex="-1" role="dialog" aria-labelledby="responseTimeModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="responseTimeModalLabel">혈당실증대상자결과(100건)</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body" id="responseTimeMessage">
			    <p>조회시작 시간: <span id="formatted01Hour"></span> </p>
			    <p>수신 시간: <span id="formatted12Hour"></span> </p>
			    <p>응답소요 시간: <span id="totalResponseTime">0</span> 초</p>
			</div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

</body>
</html>
