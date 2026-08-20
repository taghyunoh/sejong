<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Date nowTime = new Date();
    SimpleDateFormat sfDate = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat sfTime = new SimpleDateFormat("HH:mm");
    String todayDate  = sfDate.format(nowTime);
    Calendar cal = Calendar.getInstance();
    cal.setTime(nowTime);
    cal.add(Calendar.HOUR_OF_DAY, -1);
    Date preTime = cal.getTime();
    String preTimeStr = sfTime.format(preTime);
    String nowTimeStr = sfTime.format(nowTime);
    String endDate    = sfDate.format(nowTime);
    cal.setTime(nowTime);
    cal.add(Calendar.DATE, -6);
    String startDate = sfDate.format(cal.getTime());
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <%@ include file="/WEB-INF/inc/pwa-head.jsp" %>
  <title>식사 기록</title>
  <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.7/main.min.css" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
  <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.7/main.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
  <%-- [주의] 여기서 jQuery 를 다시 싣지 말 것.
       레이아웃(tiles/main/header.jsp)이 jQuery 3.5.1 을 먼저 싣고 그 위에 commonUtil.js 가
       전역 $(document).ajaxError 를 걸어 둔다(세션 만료 401 → 로그인 화면 이동).
       여기서 CDN jQuery 를 또 실으면 window.$ 가 통째로 교체되어 그 핸들러가 사라지고,
       세션이 만료돼도 로그인으로 못 돌아간 채 "시스템오류" 알림만 뜬다(2026-08-13 장애).
       fullcalendar·flatpickr 는 jQuery 에 의존하지 않으므로 위 두 줄만으로 충분하다. --%>
  <link href="${pageContext.request.contextPath}/asset/css/comm_style.css?date=<%= nowTime %>" rel="stylesheet">
<!-- Select2 라이브러리 예시 -->

<style>
/* 입력 폼 여백 축소 */
#foodForm .input-group { margin: 6px 0; }

/* 라벨 크기 축소 */
#foodForm label {
  font-size: 13px;
  line-height: 1.2;
}
/* 인풋(날짜/시간/텍스트/숫자) 크기 축소 */
#foodForm input[type="date"],
#foodForm input[type="time"],
#foodForm input[type="text"],
#foodForm input[type="number"],
#foodForm input[type="search"] {
  width: 100%;
  height: 36px;          /* 기본보다 작게 */
  padding: 6px 10px;
  /* [함정] 16px 미만으로 내리지 말 것 — iOS Safari 는 글자가 16px 보다 작은
     입력칸을 탭하면 읽으라고 화면을 통째로 확대하고, 입력이 끝나도 원래
     배율로 돌려주지 않는다(사용자가 매번 손으로 축소해야 했던 원인).
     칸을 작게 보이려면 글자가 아니라 height/padding 으로 줄인다. */
  font-size: 16px;
  border-radius: 8px;
  box-sizing: border-box;
}

/* 인라인 검색창 내부 버튼도 축소 */
#foodInlineSearch .btn-search-sm,
#foodInlineSearch .btn-close-sm {
  height: 28px;
  padding: 0 8px;
  font-size: 12px;
}

/* 검색 버튼 (음식검색) 크기 축소 */
#foodForm .btn-search {
  height: 36px;
  padding: 0 10px;
  font-size: 14px;
  border-radius: 8px;
}

/* 입력 버튼 축소 */
#foodForm button[type="button"] {
  height: 36px;
  padding: 0 12px;
  font-size: 14px;
  border-radius: 8px;
}

/* 테이블도 컴팩트하게 */
.food-table th,
.food-table td {
  padding: 6px;
  font-size: 14px;
}
/* 기간 필터 날짜칸. 폭·여백·정렬은 comm_style.css 의 `.date-range input[type="date"]`
   가 flex 로 관리한다(안드로이드에서 끝이 잘리던 문제) — 여기서 고정 width 를
   다시 주지 말 것. 글자 크기만 16px 로 못박는다(12px 이면 iOS 가 화면을 확대한다). */
.date-input {
    font-size: 16px !important;
}
/* 예전에 있던 `#historyTab / #inputTab { margin-left: -9px }` 를 제거했다.
   본문을 왼쪽으로 끌어당겨 좌우가 어긋났고, id 선택자라
   comm_style.css 의 `.tab-content` 정렬 규칙까지 눌러버렸다.
   좌우 여백은 이제 comm_style.css 의 .tab-content 가 탭 바와 함께 관리한다. */


/* 패널 전체 흰 배경 */
.inline-search__body {
  background-color: #ffffff;  /* 흰색 바탕 */
  color: #000000;             /* 검은 글씨 */
}

/* 테이블 셀 기본 글씨색 */
.inline-search__table th,
.inline-search__table td {
  color: #000000;   /* 검은 글씨 */
  background-color: #000000;  /* 흰 배경 */
  padding: 6px 8px;
  font-size: 14px;
}

/* 좌측(음식명) 열 폭 조정 */
.inline-search__table th:nth-child(2),
.inline-search__table td:nth-child(2) {
  width: 50% !important;   /* 원래 60% → 50%로 줄임 */
  text-align: left;        /* 좌측 정렬 */
}

.inline-search__body {
  position: fixed;
  top: 60px;          /* 상단에서 60px 아래 (원하는 값으로 조정) */
  left: 50%;
  transform: translateX(-50%); /* 가로 가운데 정렬 */
  width: 90%;         /* 폭은 화면의 90% 정도 */
  max-height: 300px;  /* 검색결과 스크롤 가능 */
  overflow-y: auto;
  background-color: #fff;  /* 흰 바탕 */
  border: 1px solid #ccc;
  border-radius: 8px;
  z-index: 9999;      /* 최상단 보이도록 */
}
.inline-search__meta {
  display: none !important;
}
/* 식사명칭( foodName )만 좌측 정렬 */
td.food-name {
  text-align: left;
  padding-left: 6px; /* 필요 없으면 제거 가능 */
}

/* 특정 테이블에만 적용하고 싶으면 이렇게 범위 좁히기 */
#foodList td.food-name,
#todayfoodList td.food-name {
  text-align: left;
}
/* 자동완성 드롭다운 */
.autosuggest { position: absolute; left: 0; right: 0; top: 100%; margin-top: 4px; border: 1px solid #ccc; border-radius: 8px; background: #fff; max-height: 240px; overflow-y: auto; z-index: 9999; display: none; }
.autosuggest__item { padding: 8px 10px; font-size: 14px; cursor: pointer; }
/* 목록 맨 위 「✕ 닫기」 — 고르는 줄과 구분되게 작고 흐리게, 스크롤해도 위에 붙어 있다(2026-08-20) */
.autosuggest__close { position: sticky; top: 0; z-index: 1; background: #fafafa; border-bottom: 1px solid #eee;
  padding: 7px 10px; font-size: 12.5px; color: #8a8f96; text-align: left; cursor: pointer; user-select: none; }
.autosuggest__close:active { background: #f0f0f0; }
.autosuggest__item:focus, .autosuggest__item:hover { background: #f2f2f2; outline: none; }
.food-wrap {
  position: relative;
  max-height: 300px;   /* 스크롤 제한 높이 */
  overflow-y: auto;
  border: 1px solid #ccc;
}
/* 모바일에서만 세로 스크롤 */
@media (max-width: 768px) {
  .food-table-wrap {
    max-height: 400px;   /* 원하는 높이 */
    overflow-y: auto;    /* 세로 스크롤 활성화 */
    border: 1px solid #ccc;
  }
}
.custom-select {
  position: relative;
}

.custom-select-options {
  display: none;
  position: absolute;
  left: 0; right: 0;
  background: #fff;
  border: 1px solid #ccc;
  border-radius: 6px;
  z-index: 9999;
  pointer-events: auto;
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);

  /* ✅ flex로 가로 정렬 */
  display: flex;
  flex-wrap: nowrap; /* 줄바꿈 없이 한 줄로 */
  overflow-x: auto;  /* 스크롤 가능 */
  max-width: 100%;
  white-space: nowrap; /* 텍스트 줄바꿈 방지 */
  padding: 4px;
}

.custom-select.open .custom-select-options {
  display: flex; /* 열릴 때도 flex 유지 */
}
/* dropup일 때 위로 */
.dropup .custom-select-options {
  bottom: 100%;
  top: auto;
}

/* 각 옵션 스타일 */
.custom-select-options [role="option"] {
  display: inline-flex; /* 또는 inline-block */
  padding: 6px 12px;
  cursor: pointer;
  border-radius: 4px;
  margin-right: 6px; /* 옵션 간 간격 */
  background: #f9f9f9;
  flex: 0 0 auto; /* 크기 고정 */
}
.custom-select-options [role="option"]:hover {
  background: #e9e9e9;
}

</style>
</head>
<body>
<div class="contents">
  <div class="lyInner">
    <div class="tab-menu">
      <button class="tab-btn active" onclick="showTab(event, 'historyTab')">식사 이력</button>
      <button class="tab-btn" onclick="showTab(event, 'inputTab')">식사 등록</button>
    </div>

    <section id="historyTab" class="tab-content active">
 	   <div class="date-range">
			<input type="date" id="startDt" class="date-input" value="<%= startDate %>" />
			<span>-</span>
			<input type="date" id="endDt" class="date-input" value="<%= endDate %>" />
			<button type="button" onclick="getFoodList(1)" style="
			  width: 30px;  height: 30px; padding: 0;  border: 1px solid #ccc;  background-color: white;
			  cursor: pointer;  display: flex;  align-items: center; justify-content: center; ">
			  <i class="fas fa-search" style="font-size: 12px;"></i>
			</button>
	   </div>     
	    <div class="food-table-wrap">
	      <table class="food-table">
	        <thead><tr><th>식사일자</th><th>식사시간</th><th>식사종류</th><th>식사량</th><th></th></tr></thead>
	        <tbody id="foodList"></tbody>
	      </table>
	     </div>  
    </section>

    <section id="inputTab" class="tab-content">
      <form id="foodForm">
        <input type="hidden" id="userUuid" value="${sessionScope.userUuid}">  
        <input type="hidden" id="foodMseq" value="">  
        <input type="hidden" id="foodCnt"  value="1">  
        <div class="input-group">
          <label for="eatDate">식사일자</label>
          <input type="date" id="eatDate" name="eatDate" value="<%= todayDate %>" required>
        </div>
        <div class="input-group">
          <label for="eatStime">시작시간</label>
          <input type="time" id="eatStime" name="eatStime" value="<%= nowTimeStr %>" required>
        </div>
        <div class="input-group" style="position:relative;">
		  <label for="foodName">식사종류</label>
		  <input type="text" id="foodName" name="foodName" placeholder="음식명 입력" required autocomplete="off">
		  <!-- 자동완성 목록 -->
		  <ul id="foodSuggest" class="autosuggest" role="listbox" aria-label="음식 자동완성"></ul>
		</div>
		<div class="input-group">	
		  <label for="foodAcnt">식사량</label>
		  <div class="custom-select dropup">
		    <input type="text" id="foodAcnt" name="foodAcnt" 
		           placeholder="식사량입력" 
		           value="1"   
		           required autocomplete="off">
		    <div class="custom-select-options" role="listbox" style="display:none;">
		      <div role="option">1</div>
		      <div role="option">2</div>
		      <div role="option">3</div>
		      <div role="option">1/2</div>
		      <div role="option">1/3</div>
		    </div>
		  </div>
		</div>

        <button type="button" onclick="saveFood()">입력</button>
      </form>
	      <table class="food-table">
	        <thead><tr><th>식사일자</th><th>식사시간</th><th>식사종류</th><th>식사량</th><th></th></tr></thead>
	        <tbody id="todayfoodList"></tbody>
	      </table>
    </section> 
  </div>
</div>

<script>
let foodData = [];

/* [필수] 서버 호출은 반드시 이 접두사를 붙인다.
   로컬은 루트(/)에 배포되지만 운영은 컨텍스트 `/app` 아래에 있다(allcare24.kr/app/).
   그래서 "/updateFood.do" 처럼 루트 절대경로로 부르면 운영에서는 이 앱이 아니라
   도메인 루트의 다른 앱(sejong-web)으로 요청이 가고, 그쪽이 404/500 을 내면
   앞단 nginx 가 외부 오류페이지(errdoc.gabia.net)로 302 시킨다.
   → XHR 이 다른 출처로 리다이렉트되어 브라우저가 차단 = status 0
     ("서버에 연결하지 못했습니다"). ***로컬에서만 멀쩡한 이유가 이것이다.*** (2026-08-13 장애) */
const CTX = "${pageContext.request.contextPath}";

/* ========== 공통 유틸 ========== */
function hhmmToHHMMSS(v){
  if(!v) return "";
  const s = v.substring(0,5).replace(":",""); // "HHmm"
  if (s.length !== 4) return "";
  return s + "00"; // "HHmmss"
}
function pickHHMM(elId){
  const el = document.getElementById(elId);
  if(!el) return "";
  return hhmmToHHMMSS(el.value || "");
}

/* 실패 원인을 사용자에게 그대로 알린다.
   종전에는 상태코드·서버 메시지를 버리고 "시스템오류" 한 줄만 띄워, 세션 만료인지
   저장 실패인지 화면만 보고는 구분할 수 없었다(2026-08-13 원인 추적에 애먹은 이유).
   401 = 세션 만료 → 알림 확인 후 commonUtil.js 전역 핸들러가 로그인 화면으로 보낸다. */
function ajaxFailMsg(xhr, what) {
  if (xhr && xhr.status === 401) {
    return "로그인이 만료되었습니다.\n다시 로그인한 뒤 " + what + "해 주세요.";
  }
  var detail = "";
  if (xhr) {
    if (xhr.responseJSON && xhr.responseJSON.Message) detail = xhr.responseJSON.Message;
    else if (xhr.responseText) detail = xhr.responseText;
  }
  detail = String(detail).replace(/<[^>]*>/g, " ").replace(/\s+/g, " ").trim().substring(0, 200);
  if (xhr && xhr.status === 0) detail = "서버에 연결하지 못했습니다. 통신 상태를 확인해 주세요.";
  return what + "하지 못했습니다."
       + (xhr && xhr.status ? " (오류 " + xhr.status + ")" : "")
       + (detail ? "\n" + detail : "");
}

/* ========== 저장/삭제/조회 ========== */
function saveFood() {
  // 자동완성으로 고른 음식이면 마스터 연결(foodMseq)로 칼로리 자동 집계, 직접입력이면 기본값 '1'
  var _mseq = document.getElementById("foodMseq").value;
  if(!_mseq || _mseq === "undefined") _mseq = "1";
  const data = {
    userUuid : document.getElementById("userUuid").value,
    eatDate  : document.getElementById("eatDate").value,
    eatStime : pickHHMM("eatStime"),
    // 종료시간 입력칸(eatEtime)이 있으면 그것을 사용, 없으면 시작시간과 동일
    eatEtime : (document.getElementById("eatEtime") ? pickHHMM("eatEtime") : pickHHMM("eatStime")),
    foodName : document.getElementById("foodName").value,
    foodCnt  : document.getElementById("foodCnt").value,
    foodAcnt : document.getElementById("foodAcnt").value,
    foodMseq : _mseq
  };

  if (!data.eatDate) { alert("식사일자를 입력하세요."); return; }
  if (!data.foodName) { alert("식사종류를 입력하세요."); return; }
  if (!data.foodAcnt) { alert("식사량을 입력하세요."); return; }

  if (confirm("입력하시겠습니까?")) {
    $.ajax({
      url: CTX + "/updateFood.do",
      type: "POST",
      contentType: "application/json",
      data: JSON.stringify([data]),
      success: function(){
        alert("식사기록이 저장되었습니다.");
        document.getElementById("foodName").value = "";
        document.getElementById("foodCnt").value  = "1";
        document.getElementById("foodAcnt").value = "1";
        document.getElementById("foodMseq").value = "";
        getFoodList("2");
      },
      error: function(xhr){ alert(ajaxFailMsg(xhr, "식사기록을 저장")); }
    });
  }
}

function delExercise(foodSeq, rowElement) {
  const data = { userUuid: document.getElementById("userUuid").value, foodSeq };
  $.ajax({
    url: CTX + "/deleteFood.do",
    type: "POST",
    contentType: "application/json",
    data: JSON.stringify([data]),
    success: function(){
      alert("식사기록이 삭제되었습니다.");
      if (rowElement) { rowElement.remove(); getFoodList("1"); getFoodList("2"); }
    },
    error: function(xhr){ alert(ajaxFailMsg(xhr, "식사기록을 삭제")); }
  });
}

function filterByDate() {
  const filter = document.getElementById("filterDate")?.value;
  if (!filter) return renderFoodList([], "1");
  const filtered = foodData.filter(item => item.date === filter);
  renderFoodList(filtered, "1");
}

function showTab(event, tabId) {
  document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
  document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
  document.getElementById(tabId).classList.add('active');
  event.target.classList.add('active');

  if (tabId === "inputTab") {
    getFoodList("2");
    renderFoodList([], "2");
  } else {
    getFoodList("1");
    renderFoodList([], "1");
  }
}

function getFoodList(gubun) {
  let param;
  if (gubun == "1") {
    param = {
      userUuid: document.getElementById("userUuid").value,
      startDt : document.getElementById("startDt").value,
      endDt   : document.getElementById("endDt").value
    };
  } else if (gubun == "2") {
    param = {
      userUuid: document.getElementById("userUuid").value,
      startDt : document.getElementById("eatDate").value,
      endDt   : document.getElementById("eatDate").value
    };
  }

  if ((param.startDt > param.endDt) && (gubun === "1")) {
    alert("종료일자가 시작일자보다 커야 합니다.");
    document.getElementById("endDt").focus();
    return;
  }

  fetch(CTX + '/getFoodList.do', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(param)
  })
  .then(r => r.json())
  .then(result => {
    if (result.IsSucceed) 
    	renderFoodList(result.Data, gubun);
    else alert('식사 기록을 불러오는 데 실패했습니다.');
  })
  .catch(console.error);
}

function renderFoodList(data, gubun) {
	  let lastDate = '';
	  let list ;
	  
	  if (gubun == "1") {
	     list = document.getElementById("foodList");
	  } else if (gubun == "2"){
	    list = document.getElementById("todayfoodList");  
	  }

	  list.innerHTML = '';

	  (data || []).forEach(item => {
	    const tr = document.createElement('tr');
	    tr.setAttribute('data-exer-seq', item.foodSeq);

	    // 날짜
	    const tdDate = document.createElement('td');
	    if (item.eatDate !== lastDate) {
	      tdDate.textContent = item.eatDate || '';
	      lastDate = item.eatDate;
	    } else {
	      tdDate.textContent = ' ';
	    }

	    // 시간
	    const tdTime = document.createElement('td');
	    tdTime.textContent = (item.eatStime
	      ? item.eatStime.substring(0, 2) + ':' + item.eatStime.substring(2, 4)
	      : '');

	    // 식사명칭 (foodName) — 좌측정렬 전용 클래스 추가
	    const tdType = document.createElement('td');
	    tdType.classList.add('food-name');
	    const name = item.foodName || '';
	    if (name.length > 5) {
	      tdType.textContent = name.substring(0, 5) + '…';
	      tdType.setAttribute('data-tooltip', name);
	      tdType.classList.add('has-tooltip');
	    } else {
	      tdType.textContent = name;
	    }

	    // 식사량
	    const tdCnt = document.createElement('td');
	    tdCnt.textContent = item.foodAcnt;

	    // 삭제
	    const tdDelete = document.createElement('td');
	    tdDelete.textContent = '🗑️';
	    tdDelete.style.cursor = 'pointer';
	    tdDelete.title = '삭제';
	    tdDelete.onclick = function () {
	      if (confirm(`${item.foodName} 식사기록을 삭제하시겠습니까?`)) {
	        const currentRow = this.closest('tr');
	        delExercise(item.foodSeq, currentRow);
	      }
	    };

	    tr.appendChild(tdDate);
	    tr.appendChild(tdTime);
	    tr.appendChild(tdType);
	    tr.appendChild(tdCnt);
	    tr.appendChild(tdDelete);
	    list.appendChild(tr);
	  });
	}


/* ========== 옵션 드롭다운(식사추가) ========== */
function initCustomSelect(){
  document.querySelectorAll('.custom-select-options div')?.forEach(option => {
    option.addEventListener('click', function () {
      const input = this.closest('.custom-select')?.querySelector('input');
      if (input) {
        input.value = this.textContent;
        this.parentElement.style.display = 'none';
      }
    });
  });
}

/* ========== 인라인 음식 자동완성(입력 즉시 조회) ========== */
function initFoodAutosuggest(){
  const inputName = document.getElementById('foodName');
  const listbox   = document.getElementById('foodSuggest');
  const seqEl     = document.getElementById('foodMseq');
  if (!inputName || !listbox) return;

  const MIN_LEN = 1;   // 1글자부터 검색(입력할 때마다)
  const WAIT_MS = 150;

  let timer = null;
  let lastController = null;
  let suppressSuggestOnce = false;   // ✅ 선택 직후 자동완성 1회 무시

  function showList(items){
    listbox.innerHTML = '';
    if (!items || !items.length){
      listbox.style.display = 'none';
      return;
    }
    /* ★[2026-08-20] 목록 맨 위에 **「입력내용 적용」** 줄을 둔다.
       왜 : 목록에 없는 음식을 적었을 때 **내가 친 그대로 쓰고 목록을 닫는 길**이 없었다.
            (바깥을 눌러 닫는 것을 모르는 분이 많고, 목록이 화면을 덮으면 누를 자리도 마땅치 않다.)
       ★고른 음식이 아니라 **직접 입력**이므로 마스터 연결(foodMseq)을 **비운다** —
         안 비우면 앞서 고른 음식의 코드가 남아 **엉뚱한 칼로리로 집계된다.**
         저장 쪽은 코드가 없으면 기본값('1')을 쓰므로 그대로 저장된다(saveFood 주석 참고).
       ⚠고르는 줄과 헷갈리지 않게 글자를 작고 흐리게, 위에 붙여 둔다. */
    const cls = document.createElement('li');
    cls.className = 'autosuggest__close';
    cls.setAttribute('role','presentation');
    cls.textContent = '✓  입력내용 적용';
    const applyTyped = (e)=>{
      e.preventDefault(); e.stopPropagation();
      if (seqEl) seqEl.value = '';        // 직접 입력 — 마스터 연결 해제
      suppressSuggestOnce = true;         // 닫은 직후 목록이 다시 뜨지 않게
      hideList();
      setTimeout(()=>{ inputName.blur(); }, 30);
    };
    cls.addEventListener('mousedown', applyTyped);
    cls.addEventListener('touchstart', applyTyped, {passive:false});
    listbox.appendChild(cls);

    items.forEach((it, idx)=>{
      const li = document.createElement('li');
      li.className = 'autosuggest__item';
      li.setAttribute('role','option');
      li.setAttribute('tabindex','0');
      li.dataset.index = String(idx);
      li.textContent = it.name;

      // ✅ click 대신 mousedown 사용 (모바일/안드로이드 안정)
      li.addEventListener('mousedown', (e)=>{
        e.preventDefault(); e.stopPropagation();
        selectItem(it);
      });
      li.addEventListener('keydown', (e)=>{ if(e.key==='Enter'){ selectItem(it); } });
      listbox.appendChild(li);
    });
    listbox.style.display = 'block';
  }

  function hideList(){ listbox.style.display = 'none'; }

  function mapItem(row){
    const name = row.foodName || row.FOOD_NAME || row.name || row.NAME || '';
    let seq    = row.FOOD_SEQ || row.foodSeq || row.food_seq || row.seq || row.SEQ || row.id || row.ID;
    if (seq === '' || seq === null || typeof seq === 'undefined') seq = undefined;
    return { name: String(name), seq };
  }

  function selectItem(it){
    // ✅ 선택 직후 자동완성 1회 무시
    suppressSuggestOnce = true;

    inputName.value = it.name || '';
    if (seqEl && typeof it.seq !== 'undefined') seqEl.value = it.seq;

    hideList();

    // 필요시 키보드/자동검색창 방지
    setTimeout(()=>{ inputName.blur(); }, 30);
  }

  function search(q){
    if (lastController) lastController.abort();
    lastController = new AbortController();
    return fetch(CTX + '/getFoodMstList.do', {
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ findData: q }),
      signal: lastController.signal
    })
    .then(r=>r.json())
    .then(p=>{
      const list = p.data || p.Data || p.list || p.items || [];
      return Array.isArray(list) ? list.map(mapItem) : [];
    })
    .catch(err=> (err && err.name === 'AbortError') ? [] : []);
  }

  const debounced = (fn, ms)=> function(...args){
    clearTimeout(timer);
    timer = setTimeout(()=>fn.apply(this,args), ms);
  };

  const fire = debounced(async ()=>{
    // ✅ 선택 직후 한 번은 무시하고 목록 닫기
    if (suppressSuggestOnce) { suppressSuggestOnce = false; hideList(); return; }

    const v = (inputName.value || '').trim();
    if (v.length < MIN_LEN){ hideList(); return; }

    const items = await search(v);
    showList(items);
  }, WAIT_MS);

  inputName.setAttribute('autocomplete','off');
  inputName.addEventListener('input', fire);
  inputName.addEventListener('compositionupdate', fire);
  inputName.addEventListener('compositionend', fire);

  /* ★[2026-08-20 요청] **목록을 닫을 방법이 없었다** —
       "골라야만 없어지고, 아니면 다른 화면으로 가야 한다"(사용자).
     원인 : 바깥 누름을 **`mousedown` 으로만** 듣고 있었다. 휴대폰 터치에서는 이 이벤트가
            늦게·때로는 오지 않아 **바깥을 눌러도 안 닫혔다.**
     ⇒ 터치까지 함께 받는 `pointerdown` 을 쓰고, 옛 브라우저를 위해 `touchstart` 도 둔다.
       ⚠capture 로 받는다 — 목록 위에 다른 요소가 있어도 먼저 잡는다.
       ⚠목록 안·입력칸은 빼야 한다(고르는 중에 닫히면 안 된다). */
  function outsideClose(e){
    if (e.target === inputName) return;
    if (listbox.contains(e.target)) return;
    hideList();
  }
  document.addEventListener('pointerdown', outsideClose, true);
  document.addEventListener('touchstart',  outsideClose, true);
  document.addEventListener('mousedown',   outsideClose, true);   // 마우스 쓰는 PC 화면
  /* 화면을 굴리면 닫는다 — 목록이 칸에 붙어 있어 굴리면 자리가 어긋난다(휴대폰에서 흔한 동작) */
  window.addEventListener('scroll', hideList, true);
  document.addEventListener('keydown', (e)=>{ if (e.key==='Escape') hideList(); });
}


/* ========== 초기화(DOM 준비 후) ========== */
document.addEventListener('DOMContentLoaded', function(){
  // 로컬 저장 복구
  try {
    const stored = JSON.parse(localStorage.getItem("foodRecords"));
    if (Array.isArray(stored)) { foodData = stored; }
  } catch (e) {
    console.warn("로컬 기록 초기화됨:", e.message);
    foodData = [];
    localStorage.removeItem("foodRecords");
  }

  renderFoodList([], "1");
  getFoodList("1");

  // 초기화 훅
  initCustomSelect();
  initFoodAutosuggest();
});
//페이지 진입 시 input을 기본적으로 readonly 처리
document.querySelectorAll('.custom-select input').forEach(input => {
  input.setAttribute('readonly', true);

  input.addEventListener('click', function (e) {
    const options   = this.nextElementSibling;
    const isVisible = options && options.style.display === 'block';
    e.stopPropagation();

    // 1) 옵션 패널이 닫혀 있고, 이전에 일반 옵션을 선택했다면 = "수정 모드"
    if (!isVisible && this.dataset.editReady === '1') {
      this.removeAttribute('readonly');
      delete this.dataset.editReady;

      setTimeout(() => {
        this.focus({ preventScroll: true });
        const len = this.value.length;
        try { this.setSelectionRange(len, len); } catch (err) {}
      }, 0);
      return;
    }

    // 2) 기본 동작: 다른 패널 닫고 현재 것만 열기
    document.querySelectorAll('.custom-select-options')
      .forEach(opt => opt.style.display = 'none');
    if (options) options.style.display = 'block';
  });

  input.addEventListener('blur', function () {
    this.setAttribute('readonly', true);
  });
});

//옵션 클릭 시 (pointerdown 사용)
document.querySelectorAll('.custom-select-options div').forEach(option => {
  option.addEventListener('pointerdown', function (e) {
    e.preventDefault();
    e.stopPropagation();

    const select = this.closest('.custom-select');
    const input  = select.querySelector('input');
    const value  = this.textContent.trim();

    if (value === '직접입력') {
      this.parentElement.style.display = 'none';
      input.value = '';
      input.removeAttribute('readonly');
      delete input.dataset.editReady;

      setTimeout(() => {
        input.focus({ preventScroll: true });
        try { input.select(); } catch (err) {}
      }, 0);
    } else {
      input.value = value;
      input.setAttribute('readonly', true);
      input.dataset.editReady = '1';
      this.parentElement.style.display = 'none';

      // ✅ 자동검색/키보드 안 뜨게 blur 시킴
      setTimeout(() => {
        input.blur();
      }, 50);
    }
  });
});


(function () {
    const SELECTOR = '.custom-select';

    // 열기
    function openSelect(root) {
      root.classList.add('open');
    }

    // 닫기
    function closeSelect(root) {
      root.classList.remove('open');
    }

    // 모든 셀렉트 닫기
    function closeAll(except) {
      document.querySelectorAll(SELECTOR).forEach(s => {
        if (!except || s !== except) s.classList.remove('open');
      });
    }

    // 초기화: 각 셀렉트에 리스너 바인딩
    document.querySelectorAll(SELECTOR).forEach(customSelect => {
      const input = customSelect.querySelector('input');
      const options = customSelect.querySelector('.custom-select-options');

      if (!input || !options) return;

      // 입력 클릭/포커스 시 열기
      const open = (e) => {
        openSelect(customSelect);
        e.stopPropagation(); // 바깥 닫힘 로직과 충돌 방지
      };
      input.addEventListener('focus', open);
      input.addEventListener('click', open);

      // 옵션 클릭 시 값 설정 + 닫기
      options.addEventListener('click', (e) => {
        const opt = e.target.closest('[role="option"]');
        if (!opt) return;
        input.value = opt.textContent.trim();
        closeSelect(customSelect);
        e.stopPropagation();
      });

      // 옵션 영역에서 입력 blur 방지 + 클릭 전파 차단
      options.addEventListener('pointerdown', (e) => {
        e.preventDefault();   // input blur로 인한 외부 클릭 발생 방지
        e.stopPropagation();
      });

      // 셀렉트 내부 클릭은 전파 막기 (문서 클릭 닫기와 충돌 방지)
      customSelect.addEventListener('click', (e) => {
        e.stopPropagation();
      });
    });

    // 문서 바깥 클릭 시 전부 닫기
    document.addEventListener('click', () => {
      closeAll();
    });

    // Esc로 닫기
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') closeAll();
    });
  })();

</script>

</body>
</html>
