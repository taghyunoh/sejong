<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>  
    
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<!-- CSS -->
<link href="/asset/css/comm_blood.css?v=123" rel="stylesheet"> 
<style>
.tab-container, 
.header, 
.navbar {
    background-color: #fff !important;  /* 흰색 또는 원하는 색으로 변경 */
}
.metric-item {
  flex: 1 1 0;                /* shrink 허용 (중요) */
  min-width: 0;               /* flex 박스에서 텍스트 … 처리를 위해 필요 */
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: center;
  gap: 6px;
  flex-wrap: nowrap;          /* 내부도 한 줄 유지 */
  white-space: nowrap;        /* 내부 인라인 줄바꿈 방지 */
}

.metric-label {
  display: inline-block;
  color: #ffffff !important;
  font-weight: 500;
  white-space: nowrap; /* 줄바꿈 방지 */
}

.metric-value {
  white-space: nowrap;        /* 값도 한 줄 고정 */
}
.note-text,
.unit-display {
    color: black;
}

.main-content {
    background-color: #f8f9fa;  /* 연한 회색 */
    min-height: 100vh;         /* 화면 전체 높이 차지 */
    padding: 20px;             /* 내용과의 여백 */
}
:root { --header-height: 56px; }

.main-content {
  background-color: #f8f9fa;
  min-height: 100vh;
  padding-top: calc(var(--header-height, 56px) + max(16px, env(safe-area-inset-top)));
  padding-right: max(20px, env(safe-area-inset-right));
  padding-bottom: max(20px, env(safe-area-inset-bottom));
  padding-left: max(20px, env(safe-area-inset-left));
}
/* ===== 텍스트 유틸 ===== */
.note-text,
.unit-display { color: #000; }
.left-align { text-align: left; }
.title-text { font-size: 0.9rem; margin: 0 0 8px 0; }
.red-text { color: red; }

/* ===== 랭킹 그리드 ===== */
.ranking-grid {
  display: grid;
  gap: 8px;
  justify-content: start;  /* 전체를 좌측 정렬 */
  width: 100%;
}

/* 공통 행: 좌우 패딩 0으로 왼쪽 붙임 */
.grid-header,
.grid-row {
  display: grid;
  grid-template-columns: 60px 50px 70px 1fr;  /* 시간 | 종류 | 분 | 값 */
  gap: 8px;
  align-items: center;
  font-size: 13px;
  padding: 6px 0;    /* 좌우 0 (중요) */
  box-sizing: border-box;
}

.grid-header {
  background-color: #e0f0ff;
  border-radius: 8px;  /* 둥근 정도 그대로 유지 */
  font-weight: 700;
  padding: 8px calc(var(--card-pad));
  margin-left: calc(var(--card-pad) * -0.1);  /* -1 → -0.7로 줄임 */
  margin-right: calc(var(--card-pad) * -0.7);
  overflow: hidden;
}

/* 셀 기본 */
.grid-header span,
.grid-row span { white-space: nowrap; }

/* 정렬(좌우 패딩 제거로 완전 왼쪽 붙임) */
.grid-col-start  { text-align: left;  padding-left: 0; }
.grid-col-center { text-align: center; }
.grid-col-end    { text-align: right; padding-right: 0; }

/* 행 구분선 */
.grid-row { border-bottom: 1px solid #eee; }
.grid-row:last-child { border-bottom: none; }

.grid-header {
  background-color: #e0f0ff;
  border-radius: 6px;
  font-weight: 700;

  /* 좌측만 조금 붙이기 */
  margin-left: -18px;   /* 원하는 만큼 조정 (-2px ~ -6px 정도) */
}
.grid-header span {
  display: inline-block;
  margin-left: -2px;   /* 원하는 만큼 이동 (-2px ~ -6px 정도 조정 가능) */
}
.grid-header-wrap {
  position: relative;
}

.grid-header {
  background-color: #e0f0ff;
  border-radius: 8px;
  font-weight: 700;
  padding: 8px;
  position: relative;
  left: 10px;   /* 배경만 우측으로 5px 이동 */
}
#grid-rows span:nth-child(3),
#grid-rows span:nth-child(4) {
  margin-left: 10px;  /* 두 번째 컬럼만 우측으로 */
}
#grid-rows-max span:nth-child(3),
#grid-rows-max span:nth-child(4) {
  margin-left: 10px;  /* 두 번째 컬럼만 우측으로 */
}

/* 헤더 */
.grid-header span:nth-child(2) {
  text-align: left;
  margin-left: -8;
}
/* 헤더 */
.grid-header span:nth-child(3) {
  text-align: left;
  margin-left: 10;
}
.grid-header span:nth-child(4) {
  text-align: left;
  margin-left: -6;
}

/* 데이터 행 */
#grid-rows span:nth-child(2) {
  text-align: left;
  margin-left: -8;
}
/* 데이터 행 */
#grid-rows-max span:nth-child(1) {
  text-align: left;
  margin-left: 3;
}
/* 데이터 행 */
#grid-rows-max span:nth-child(2) {
  text-align: left;
  margin-left: -8;
}
/* 데이터 행 */
/* 데이터 행 */
#grid-rows span:nth-child(3) {
  text-align: left;
  margin-left: 24;
}
#grid-rows-max span:nth-child(3) {
  text-align: left;
  margin-left: 24;
}
.main-content { max-width: 960px; margin: 0 auto; }
.date-nav {
  position: sticky; bottom: 0; /* 스크롤 내려도 하단에 고정 */
  background: #fff;
  border-top: 1px solid #eee;
  padding: 12px 16px;
  display: flex; align-items: center; justify-content: center; gap: 12px;
  z-index: 10;
}
.date-nav .nav-btn {
  border: 1px solid #ddd; border-radius: 999px;
  width: 40px; height: 40px; font-size: 18px; cursor: pointer;
  background: #fafafa;
}
.date-nav .nav-btn:disabled { opacity: 0.4; cursor: not-allowed; }
#selected-date { padding: 8px 10px; border: 1px solid #ddd; border-radius: 8px; }
.ranking-grid .grid-row {
  display: grid; grid-template-columns: 1fr 2fr 1fr 1fr; gap: 8px;
  padding: 8px 0; border-bottom: 1px dashed #eee;
}
.decrease-card .ranking-grid .grid-row { grid-template-columns: 0.7fr 2fr 1fr 1fr; }
.empty-state { color: #888; font-size: 0.95rem; padding: 8px 0; }
.date-range {
  display: flex;
  align-items: center;
  gap: 0;                 /* 완전히 붙이기 */
  margin-left: -13px;
}

.date-range button {
  background: none;
  border: none;
  font-size: 16px;        /* 화살표 약간 키움 */
  padding: 0 4px;
  cursor: pointer;
  color: #555;
}

.date-range button:hover {
  color: #000;
}

.date-range input[type="date"] {
  width: 120px;           /* 글자가 커지면 폭 약간 늘림 */
  padding: 6px 6px;       /* 내부 여백 확대 */
  font-size: 12px;        /* 날짜 폰트 크게 */
  font-weight: 400;       /* 글씨 약간 두껍게 */
  text-align: center;
  border: 1px solid #ccc;
  border-radius: 6px;
  color: #333;
  background-color: #fff;
}


.date-range .tilde {
  margin: 0 6px;
  font-size: 18px;        /* ~ 기호도 동일 크기로 */
  font-weight: 600;
  color: #444;
}

/* 브라우저 기본 캘린더 아이콘 정렬 조정 */
input[type="date"]::-webkit-calendar-picker-indicator {
  margin-left: -4px;
  transform: scale(1.2);  /* 아이콘 크기 살짝 키움 */
}

</style>
</head>
<body>

	<!-- 메인 콘텐츠 -->
	<main class="main-content">
		<div class="top2-card decrease-card" style="margin-top:-30px;">
		  <div class="date-range">
		    <button id="prev7" class="btn" type="button" aria-label="이전 1일">◀</button>
		    <input type="date" id="startDate" aria-label="시작일" readonly>
		    <button id="next7" class="btn" type="button" aria-label="다음 1일">▶</button>
		  </div>
		</div>	
	  <!-- 주간 혈당 증가 식사 TOP3 카드 -->
	  <div class="top3-card increase-card">
	    <div class="card-header"> 
			  <h2 class="title-text red-text">* 식사 2시간 후 식후 혈당 </h2> 
			  <span class="unit-display">단위 : mg/dL</span> 
        </div>
	
		<div class="ranking-grid">
		  <div class="grid-header">
		    <span>식사시간</span>
		    <span>음식종류</span> 
		    <span>식사량</span>
		    <span>식후혈당</span>
		  </div>
		  <div id="grid-rows"></div>
		</div>
	  </div>
	
	    <div class="note-text font-large left-align">
		  * 오늘의 평균 혈당(24시간 기준)은 <br>
		  <span class="detail-box_small" id="avg_blood">-</span>
		  <span class="unit-label">mg/dL</span> 입니다  
		</div>
		<br> <!-- 줄바꿈으로 공간 확보 -->
		
	  <!-- 주간 혈당 감소 식사 TOP3 카드 -->
	  <div class="top3-card decrease-card">
	    <div class="card-header"> 
			  <h2 class="title-text">* 식사전후 혈당 변동폭순위 </h2> 
			  <span class="unit-display">단위 : mg/dL</span> 
        </div>	
		<div class="ranking-grid">
		  <div class="grid-header">
		    <span>순위</span>
		    <span>음식종류</span>   <!-- 여기를 조정 -->
		    <span>식사량</span>
		    <span>혈당변동폭</span>
		  </div>
		  <div id="grid-rows-max"></div>
	    </div>
	  </div>
	</main>
	
<script>
  var accToken = "";
  var userId = "";

  // 선택된 날짜 (기본: 오늘)
  let selectedDate = new Date();

  $(document).ready(function () {
    var userNm = '<%= session.getAttribute("userNm") %>';
    $("#name").text(userNm.trim() + '님은');

    userId = '<%= session.getAttribute("userUuid") %>';

    const $start = document.getElementById("startDate");
    const $prev  = document.getElementById("prev7");
    const $next  = document.getElementById("next7");
    const today  = stripTime(new Date());

    // 날짜 입력 기본값/최대값 설정 (오늘)
    $start.value = toYMD(selectedDate);
    $start.setAttribute("max", toYMD(today));
    updateNextButtonState();

    // 최초 로드 시 데이터 조회
    renderFor(selectedDate);

    // ◀ 버튼 클릭 (이전날)
    $prev.addEventListener("click", () => {
      selectedDate = addDays(selectedDate, -1);
      renderFor(selectedDate);
    });

    // ▶ 버튼 클릭 (다음날, 미래 불가)
    $next.addEventListener("click", () => {
      const cand = addDays(selectedDate, 1);
      if (stripTime(cand) <= today) {
        selectedDate = cand;
        renderFor(selectedDate);
      }
    });

    function renderFor(d) {
      $start.value = toYMD(d);
      updateNextButtonState();
      calcBlood(d, d); // 선택된 하루 조회
    }

    function updateNextButtonState() {
      const isToday = toYMD(stripTime(selectedDate)) === toYMD(stripTime(today));
      $next.disabled = isToday;
    }
  });

  /** 혈당 데이터 조회 **/
  function calcBlood(startDateObj, endDateObj) {
    var formData = {
      start:  toYMD(startDateObj),
      end:    toYMD(endDateObj),
      userId: userId
    };

    /* ===== 식후 혈당 ===== */
    CommonUtil.callSyncAjax(
      CommonUtil.getContextPath() + "/today_foodBlood.do",
      "POST",
      formData,
      function(responseList) {
        const container = document.getElementById('grid-rows');
        container.innerHTML = '';

        const safeText = v => (v === null || v === undefined || v === '') ? '-' : String(v);
        const truncate = (s, len) => {
          s = safeText(s);
          return s.length > len ? s.substring(0, len) + '…' : s;
        };
        const toHHMM = v => {
          if (!v) return '-';
          const s = String(v);
          if (/^\d{2}:\d{2}$/.test(s)) return s;
          if (/^\d{6}$/.test(s)) return s.slice(0,2)+':'+s.slice(2,4);
          return s;
        };
        const toNumber = x => {
          if (x === null || x === undefined || x === '') return null;
          const n = Number(x);
          return Number.isFinite(n) ? n : null;
        };

        if (!Array.isArray(responseList) || responseList.length === 0) {
          container.innerHTML = `
            <div class="grid-row" style="text-align:center; width:100%;">
              <span>자료없음</span>
            </div>
          `;
          return;
        }

        const rowsHtml = responseList.map(item => {
          const foodTime = toHHMM(item.EAT_STIME);
          const rawName  = item.FOOD_NAME;
          const foodName = truncate(rawName, 5);
          const foodQty  = item.FOOD_CNT;

          const pre  = toNumber(item.PRE_VALUE);
          const post = toNumber(item.UPT_VALUE);
          let bloodVal = '-';
          if (pre !== null || post !== null) {
            const maxVal = Math.max(pre ?? -Infinity, post ?? -Infinity);
            if (Number.isFinite(maxVal)) bloodVal = String(maxVal);
          } else {
            bloodVal = safeText(item.UPT_VALUE);
          }

          return `
            <div class="grid-row">
              <span>\${safeText(foodTime)}</span>
              <span title="\${safeText(rawName)}">\${safeText(foodName)}</span>
              <span>\${safeText(foodQty)}</span>
              <span>\${safeText(bloodVal)}</span>
            </div>
          `;
        }).join('');

        container.innerHTML = rowsHtml;
      }
    );

    /* ===== 혈당 변동폭 ===== */
    CommonUtil.callSyncAjax(
      CommonUtil.getContextPath() + "/foodBlood_max.do",
      "POST",
      formData,
      function(responseList) {
        const container = document.getElementById('grid-rows-max');
        container.innerHTML = '';

        const safeText = v => (v === null || v === undefined || v === '') ? '-' : String(v);
        const truncate = (s, len) => {
          s = safeText(s);
          return s.length > len ? s.substring(0, len) + '…' : s;
        };
        const toHHMM = v => {
          if (!v) return '-';
          const s = String(v);
          if (/^\d{2}:\d{2}$/.test(s)) return s;
          if (/^\d{6}$/.test(s)) return s.slice(0,2)+':'+s.slice(2,4);
          return s;
        };
        const toNumber = x => {
          if (x === null || x === undefined || x === '') return null;
          const n = Number(x);
          return Number.isFinite(n) ? n : null;
        };

        if (!Array.isArray(responseList) || responseList.length === 0) {
          container.innerHTML = `
            <div class="grid-row" style="text-align:center; width:100%;">
              <span>자료없음</span>
            </div>
          `;
          return;
        }

        const rowsHtml = responseList.map(item => {
          const foodRn   = toHHMM(item.RN);
          const rawName  = item.FOOD_NAME;
          const foodName = truncate(rawName, 5);
          const foodQty  = item.FOOD_CNT;

          const pre  = toNumber(item.PRE_VALUE);
          const post = toNumber(item.DELTA_2H);
          let bloodVal = '-';
          if (pre !== null || post !== null) {
            const maxVal = Math.max(pre ?? -Infinity, post ?? -Infinity);
            if (Number.isFinite(maxVal)) bloodVal = String(maxVal);
          } else {
            bloodVal = safeText(item.DELTA_2H);
          }

          return `
            <div class="grid-row">
              <span>\${safeText(foodRn)}</span>
              <span title="\${safeText(rawName)}">\${safeText(foodName)}</span>
              <span>\${safeText(foodQty)}</span>
              <span>\${safeText(bloodVal)}</span>
            </div>
          `;
        }).join('');

        container.innerHTML = rowsHtml;
      }
    );

    /* ===== 평균 혈당 ===== */
    CommonUtil.callSyncAjax(
      CommonUtil.getContextPath() + "/avgBlood.do",
      "POST",
      formData,
      function(avgBlood) {
        console.log("평균 혈당:", avgBlood);
        document.getElementById('avg_blood').textContent = avgBlood.AVG_VAL;
      }
    );
  }

  /* ===== 날짜 유틸 ===== */
  function pad2(n){ return ('0' + n).slice(-2); }
  function toYMD(date){
    return date.getFullYear() + '-' + pad2(date.getMonth()+1) + '-' + pad2(date.getDate());
  }
  function stripTime(d){
    return new Date(d.getFullYear(), d.getMonth(), d.getDate());
  }
  function addDays(d, days){
    const t = new Date(d);
    t.setDate(t.getDate() + days);
    return t;
  }
</script>

</body>
</html>
