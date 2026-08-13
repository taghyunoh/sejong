<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>  
    
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<!-- CSS -->
<link href="${pageContext.request.contextPath}/asset/css/comm_blood.css?date=<%= System.currentTimeMillis() %>" rel="stylesheet"> 
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
  padding-right: max(12px, env(safe-area-inset-right)); /* 좌우 조금 확장(20→12px) */
  padding-bottom: max(20px, env(safe-area-inset-bottom));
  padding-left: max(12px, env(safe-area-inset-left));   /* 좌우 조금 확장(20→12px) */
}
/* [연속혈당 측정 화면처럼 구분선 없이 자연스럽게] 카드 테두리·그림자 제거 + 좌우 여백 축소로 넓게 */
.top2-card,
.top3-card {
  border: 0 !important;
  box-shadow: none !important;
  padding-left: 6px !important;
  padding-right: 6px !important;
}
/* ===== 텍스트 유틸 ===== */
.note-text,
.unit-display { color: #000; }
.left-align { text-align: left; }
/* '* 오늘의 평균 혈당(24시간 기준)은 0 mg/dL 입니다' 줄.
   마크업의 <br> 을 없앴다(그게 두 줄로 보이던 이유).
   폭이 모자라 접힐 때는 단어 중간이 아니라 어절에서 끊기게 한다. */
.avg-blood-line {
  /* <br> 을 지워도 .font-large(=4.1vwu ≈ 16px) 로는 폭이 모자라 두 줄로 접혔다.
     한 줄을 보장하도록 크기를 낮추고 줄바꿈을 막는다.
     --vwu 기준이라 프레임/화면 폭이 달라져도 비율이 유지된다. */
  font-size: calc(3.5 * var(--vwu, 1vw));   /* 390px 기준 약 13.7px */
  letter-spacing: -0.2px;
  white-space: nowrap;
  word-break: keep-all;
  line-height: 1.45;
  margin: 4px 0;      /* 위아래 간격 축소 */
}
/* 카드 사이 간격도 조금 좁힌다 (comm_blood.css 기본 10px) */
.top2-card,
.top3-card { margin-bottom: 6px; }
.title-text { font-size: 0.9rem; margin: 0 0 8px 0; }
.red-text { color: red; }

/* ===== 랭킹 그리드 ===== */
.ranking-grid {
  display: grid;
  gap: 8px;
  justify-content: start;  /* 전체를 좌측 정렬 */
  width: 100%;
}

/* 공통 행
   고정폭(60px 50px 70px 1fr)이라 뒤쪽 열이 좁아 붙어 보였다.
   비율(fr)로 바꿔 카드 폭을 고르게 나눈다. Exercise_Consult 와 동일 기준. */
.grid-header,
.grid-row {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(0, 1fr) minmax(0, 1.2fr) minmax(0, 1.3fr);
  gap: 8px;
  column-gap: 12px;
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
  /* 음수 마진으로 헤더만 좌우로 삐져나가 본문 열과 어긋났다. 제거. */
  margin-left: 0;
  margin-right: 0;
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

/* 예전에는 헤더와 각 span 에 음수 마진(-18px, -2px)과 `left: 10px` 로
   열 위치를 억지로 맞췄다. 게다가 `margin-left: -8` 처럼 단위 없는 값도 섞여 있는데,
   이 페이지는 쿼크 모드라 그것들이 실제로 적용되어 열이 어긋났다.
   그리드 비율을 제대로 잡았으므로 전부 제거한다. */
.grid-header {
  background-color: #e0f0ff;
  border-radius: 6px;
  font-weight: 700;
  margin-left: 0;
}
.grid-header span {
  display: inline-block;
  margin-left: 0;
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
  left: 0;
}
#grid-rows span:nth-child(3),
#grid-rows span:nth-child(4),
#grid-rows-max span:nth-child(3),
#grid-rows-max span:nth-child(4) {
  margin-left: 0;
}

/* 헤더 */
.grid-header span:nth-child(2),
.grid-header span:nth-child(3),
.grid-header span:nth-child(4) {
  text-align: left;
  margin-left: 0;
}

/* 데이터 행 */
#grid-rows span:nth-child(2),
#grid-rows-max span:nth-child(1),
#grid-rows-max span:nth-child(2) {
  text-align: left;
  margin-left: 0;
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
/* `margin: 0 auto` 는 이 요소가 .wrap(flex column)의 자식이라 교차축 auto 마진이 되어
   stretch 를 꺼버린다. 그러면 폭이 내용 크기로 줄고 flex:1 도 무력해져
   하단 내비게이션이 프레임 바닥에 붙지 못한다. 프레임이 이미 폭을 잡아 주므로 제거. */
.main-content { max-width: 960px; margin: 0; }
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
  gap: 8px;
  margin-left: 0;         /* 음수 마진 제거 — 좌우가 어긋났다 */
  width: 100%;
  justify-content: space-between;   /* 화살표를 양 끝으로, 날짜가 가운데를 넓게 씀 */
}

.date-range button {
  background: none;
  border: none;
  font-size: 16px;        /* 화살표 약간 키움 */
  padding: 0 4px;
  cursor: pointer;
  color: #555;

  /* common.css 의 `.btn { width: 100%; height: 10.56vw }` 가 화살표를 부풀려
     날짜 입력칸을 찌그러뜨린다. 내용 크기만 차지하게 되돌린다. */
  width: auto;
  height: auto;
  flex: 0 0 auto;
  display: inline-flex;
  justify-content: center;
}

.date-range button:hover {
  color: #000;
}

.date-range input[type="date"] {
  flex: 1;                /* 남는 폭을 날짜가 가져감 — 120px 고정이라 좁았다 */
  min-width: 0;
  width: auto;
  max-width: 220px;
  padding: 7px 6px;       /* 내부 여백 */

  /* ★16px 미만 금지 — iOS Safari 는 폰트가 16px 보다 작은 입력칸을 탭하면 화면을 자동 확대하고,
     포커스가 빠져도 원래 배율로 되돌리지 않는다. 종전 13px 이 딱 이 증상이었다.
     ⚠읽기 편하라고 키운 값이 아니라 확대를 막는 하한선이다. 되돌리면 증상이 재발한다.
     칸을 작게 보이려면 글자가 아니라 height/padding 으로 줄인다.
     (foodMain.jsp · exerMain.jsp 의 .date-input 도 같은 이유로 16px 로 못박았다)
     폭 영향 없음 — 360px 실측(가용 324px): 날짜칸 1개짜리 화면이라 16px 에서도
     필요 206px / 여유 118px 로 한 줄에 여유롭게 들어간다.
     (날짜칸이 두 개인 Blood_Consult.jsp 는 같은 변경에 폭 조정이 따로 필요했다) */
  font-size: 16px;
  font-weight: 400;
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
		<!-- -30px 은 헤더에 너무 붙어 있었다. 살짝 아래로 -->
		<div class="top2-card decrease-card" style="margin-top:-10px;">
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
	
	    <%-- `<br>` 이 강제로 줄을 나눠 두 줄로 보였다. 제거하고 한 줄로 둔다. --%>
	    <div class="note-text font-large left-align avg-blood-line">
		  * 오늘의 평균 혈당(24시간 기준)은
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
