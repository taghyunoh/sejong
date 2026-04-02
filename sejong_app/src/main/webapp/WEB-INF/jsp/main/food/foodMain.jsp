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
  <title>식사 기록</title>
  <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.7/main.min.css" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
  <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.7/main.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
  <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
  <link href="/asset/css/comm_style.css?v=123" rel="stylesheet">
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
  font-size: 14px;
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
.date-input {
    font-size: 12px !important;   /* 글자 크기 강제 적용 */
    padding: 1px 3px;
    width: 118px;
}
#historyTab {
  margin-left: -9px; /* 원하는 만큼 조정 (-값은 왼쪽으로 당김) */
}
#inputTab {
  margin-left: -9px; /* 원하는 만큼 조정 (-값은 왼쪽으로 당김) */
}


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

/* ========== 저장/삭제/조회 ========== */
function saveFood() {
  const data = {
    userUuid : document.getElementById("userUuid").value,
    eatDate  : document.getElementById("eatDate").value,
    eatStime : pickHHMM("eatStime"),
    // 종료시간 입력칸(eatEtime)이 있으면 그것을 사용, 없으면 시작시간과 동일
    eatEtime : (document.getElementById("eatEtime") ? pickHHMM("eatEtime") : pickHHMM("eatStime")),
    foodName : document.getElementById("foodName").value,
    foodCnt  : document.getElementById("foodCnt").value,
    foodAcnt : document.getElementById("foodAcnt").value,
    foodMseq : document.getElementById("foodMseq").value
  };

  if (!data.eatDate) { alert("식사일자를 입력하세요."); return; }
  if (!data.foodName) { alert("식사종류를 입력하세요."); return; }
  if (!data.foodAcnt) { alert("식사량을 입력하세요."); return; }

  if (confirm("입력하시겠습니까?")) {
    $.ajax({
      url: "/updateFood.do",
      type: "POST",
      contentType: "application/json",
      data: JSON.stringify([data]),
      success: function(){
        alert("식사기록이 저장되었습니다.");
        document.getElementById("foodName").value = "";
        document.getElementById("foodCnt").value  = "1";
        document.getElementById("foodAcnt").value = "1";
        getFoodList("2");
      },
      error: function(){ alert("시스템오류입니다 다시 입력하세요!"); }
    });
  }
}

function delExercise(foodSeq, rowElement) {
  const data = { userUuid: document.getElementById("userUuid").value, foodSeq };
  $.ajax({
    url: "/deleteFood.do",
    type: "POST",
    contentType: "application/json",
    data: JSON.stringify([data]),
    success: function(){
      alert("식사기록이 삭제되었습니다.");
      if (rowElement) { rowElement.remove(); getFoodList("1"); getFoodList("2"); }
    },
    error: function(){ alert("시스템오류입니다 다시 입력하세요!"); }
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

  fetch('/getFoodList.do', {
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

  const MIN_LEN = 2;
  const WAIT_MS = 250;

  let timer = null;
  let lastController = null;
  let suppressSuggestOnce = false;   // ✅ 선택 직후 자동완성 1회 무시

  function showList(items){
    listbox.innerHTML = '';
    if (!items || !items.length){
      listbox.style.display = 'none';
      return;
    }
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
    return fetch('/getFoodMstList.do', {
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

  document.addEventListener('mousedown', (e)=>{
    if (e.target === inputName) return;
    if (!listbox.contains(e.target)) hideList();
  });
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
