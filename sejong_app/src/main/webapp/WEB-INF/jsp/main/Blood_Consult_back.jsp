<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>시간대별 통계</title>

<link href="/asset/css/comm_blood.css?v=123" rel="stylesheet">

<!-- (선택) Spring Security CSRF 메타 -->
<meta name="_csrf" content="${_csrf.token}">
<meta name="_csrf_header" content="${_csrf.headerName}">

<!-- jQuery & Chart.js -->
<script src="https://code.jquery.com/jquery-3.6.4.min.js" defer></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4" defer></script>
<!-- 데이터라벨 (옵션) -->
<script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2" defer></script>

<style>
  .tab-container,.header,.navbar{background-color:#fff!important}
  .metric-item{flex:1 1 0;min-width:0;display:flex;flex-direction:row;align-items:center;justify-content:center;gap:6px;flex-wrap:nowrap;white-space:nowrap}
  .metric-label{display:inline-block;color:#fff!important;font-weight:500;white-space:nowrap}
  .metric-value{white-space:nowrap}
  .note-text,.unit-display{color:black}
  :root{--header-height:56px}
.main-content {
  margin-top: -60px;
  padding-top: 0;
}
  /* 차트 카드 */
  .card{
    background:#fff;border-radius:12px;padding:14px;
    box-shadow:0 2px 10px rgba(0,0,0,.05);
    max-width:760px;margin:0 auto;
  }
  .card h5{margin:0 0 8px}
  #chartBox{height:340px;position:relative}
  #timeBandChart{width:100% !important;height:90% !important;display:block}

  /* 범위 버튼 */
  .range-buttons{display:flex;gap:8px;margin:6px 0 10px}
  .range-buttons .btn{
    padding:6px 6px;
    border:1px solid #e0e0e0;border-radius:8px;background:#fff;font-size:12px;cursor:pointer
  }
  .range-buttons .btn.active{background:#1f7aed;color:#fff;border-color:#1f7aed}

  /* 날짜 구간 입력 */
  .date-range{display:flex;gap:8px;align-items:center;margin:6px 0 10px}
  .date-range input[type="date"]{
    padding:4px 5px;border:1px solid #e0e0e0;border-radius:8px;background:#fff;font-size:11px
  }
  .date-range .tilde{color:#888}
  .date-range .btn.apply{
    padding:6px 10px;border:1px solid #e0e0e0;border-radius:8px;background:#fff;font-size:12px;cursor:pointer
  }
  .date-range .btn.apply:hover{background:#f3f6ff;border-color:#c9d7ff}

  /* 로딩 인디케이터 */
  .loading {
    position:absolute; inset:0; display:none; align-items:center; justify-content:center;
    background:rgba(255,255,255,.65); font-size:13px; backdrop-filter: blur(1px);
  }
  .loading.show{display:flex}

  /* 배치/간격 커스터마이즈 */
  .main-content { display:flex; justify-content:flex-start }
  .card { margin-left:-22px; margin-top:30px }
  .chart-title { margin-bottom:16px }

  /* 범례 (글자 표시 개선) */
  .legend {
    display:flex; gap:16px; margin-top:2px; font-size:10px; color:#333; align-items:center;
  }
  .legend .item { display:flex; align-items:center; gap:6px }
  .legend .box { width:14px; height:14px; display:inline-block; border-radius:2px }
  .j-end {
	 justify-content: flex-end;
   }

.blood_list .top_row {
  margin: -2px 0;    /* 위아래 요소 간격 줄이기 */
}   
#chartBox {
  margin-bottom: 2px; /* 차트와 legend 사이 간격 */
}

.legend {
  margin-top: -5px; /* legend 위쪽 여백 */
  display: flex;
  gap: 12px; /* 항목 간 간격 */
  font-size: 10px;
}
.main-content {
  background-color: #f8f9fa;
  min-height: 100vh;
  padding-top: calc(var(--header-height, 56px) + max(16px, env(safe-area-inset-top)));
  padding-right: max(20px, env(safe-area-inset-right));
  padding-bottom: max(20px, env(safe-area-inset-bottom));
  padding-left: max(20px, env(safe-area-inset-left));
}
.ranking-grid { 
  display: grid; 
  gap: 8px; 
}

/* 공통 레이아웃 */
.grid-header,
.grid-row {
  display: grid;
  grid-template-columns: 60px 60px 50px 60px; /* 시간 | 음식 | 수량 | 혈당 */
  gap: 8px;
  align-items: center;
  font-size: 14px;
  padding: 4px 8px;
  box-sizing: border-box;        /* 패딩 포함 폭 계산 */
  margin-left: -7px;   /* 원하는 만큼 조정 */
}

/* 한 줄 처리 */
.grid-header span,
.grid-row span {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  text-align: left;
  /* 🔧 음수 여백 제거 */
  padding-left: 0;
  margin-left: 0;
}

/* ✅ 타이틀 스타일 */
.grid-header {
  background-color: #e0f0ff;   /* 하늘색 배경 */
  border-radius: 6px;         /* 모서리 라운딩 */
  font-weight: bold;          /* 강조 */
  overflow: hidden;            /* 🔒 둥근 모서리 밖으로 내용이 안 새게 */
}

.grid-header span {
  margin-left: -10px;   /* 원하는 만큼 조정 */
}
/* 수량, 혈당 컬럼만 우측으로 이동 */
/* 행 데이터 */
.grid-row > :nth-child(2),
.grid-row > :nth-child(2) {
  transform: translateX(-6px); /* 필요 시 값 조정 */
}
.grid-header > :nth-child(2),
.grid-header > :nth-child(3),
.grid-header > :nth-child(4){
  padding-left: -4px;
}
.grid-header > :nth-child(1){
  padding-left: 8px;
}
.left-align {
  text-align: left;
}
.left_wrap {
  display: flex;
  flex-direction: column; /* 세로 정렬 */
  gap: 8px; /* 항목 간 간격 */
  margin-top: -3px;
}
.left_wrap1 {
  background-color: #fff;
  border-radius: 10px;
  padding: 15px;
  margin: 8px auto;     /* auto → 좌우 중앙 정렬 */
  width: 90%;           /* 화면의 90% 너비 */
  max-width: 800px;     /* 최대 800px 제한 */
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
}

.row_item {
  display: flex;
  justify-content: flex-start;
  align-items: baseline;   /* 텍스트 기준선 맞춤 */
  gap: 5px;
  margin-bottom: 6px;      /* 줄 간격 */
}
.recommendation-text a {
  display: inline;   /* 기본 인라인 유지 */
  padding: 4px 0;    /* 클릭 영역 살짝만 확장 */
}

.recommendation-text li {
  margin-bottom: 8px;
}
.recommendation-text a:hover {
  text-decoration: underline;
  background-color: #f0f0f0;
}

#grid-rows span:nth-child(3),
#grid-rows span:nth-child(4) {
  margin-left: 20px;  /* 두 번째 컬럼만 우측으로 */
}
#grid-rows-max span:nth-child(3),
#grid-rows-max span:nth-child(4) {
  margin-left: 20x;  /* 두 번째 컬럼만 우측으로 */
}

#grid-rows span:nth-child(3) {
  text-align: left;
  margin-left: 30;
}
#grid-rows span:nth-child(4) {
  text-align: left;
  margin-left: 24;
}
#grid-rows-food span:nth-child(1) {
  text-align: left;
  margin-left: 5;
}  
#grid-rows-exer span:nth-child(1) {
  text-align: left;
  margin-left: 5;
}
#grid-rows-food span:nth-child(2) {
  text-align: left;
  margin-left: -7;
}  
#grid-rows-exer span:nth-child(2) {
  text-align: left;
  margin-left: -7;
}

#grid-rows-food span:nth-child(3) {
  text-align: left;
  margin-left: 5;
}  
#grid-rows-exer span:nth-child(3) {
  text-align: left;
  margin-left: 5;
}

#grid-rows-food span:nth-child(4),
#grid-rows-exer span:nth-child(4) {
  text-align: right;
  transform: translateX(-20px); /* 왼쪽으로 8px 이동 */
}
.unit-display {
  display: block;       /* 줄바꿈 */
  margin-top: 14px;      /* 제목과 간격 */
  text-align: right;    /* 우측 정렬 */
}

/* 헤더 */
.grid-header span:nth-child(2) {
  text-align: left;
  margin-left: -18;
}
.range-buttons .btn {
  font-size: 15px;   /* 기본보다 살짝 크게 */
  padding: 6px 12px; /* 버튼 크기도 균형 맞게 */
}

.range-buttons {
  position: absolute;
  left: -9999px;
  top: -9999px;
}

#chartBox {
  width: 100%;  /* 화면의 90%까지 차지 */
  max-width: 1000px; /* 최대 넓이 제한 */
  margin: 0 auto;
}
#timeBandChart {
  width: 100% !important;
  height: auto;
}
/* 공통 유틸 */
.visually-collapsed {
  height: 1px;           /* 최소 공간만 남김 */
  overflow: hidden;      /* 내부 내용 잘라내 숨김 */
  opacity: 0;            /* 시각적으로 투명 */
  pointer-events: none;  /* 사용자 입력 차단 (JS는 실행 가능) */
}

/* 키보드 포커스도 못 들어오게 */
.visually-collapsed * {
  pointer-events: none;
}
.row_item {
  display: flex;
  flex-wrap: wrap;          /* 설명(span)이 길면 줄바꿈 가능 */
  align-items: center;      /* 라벨과 값 수직정렬 */
  margin-bottom: 6px;
}

.row_item label {
  margin-right: 4px;
  white-space: nowrap;      /* 라벨 줄바꿈 금지 */
}

.row_item .value {
  margin-right: 6px;
  white-space: nowrap;      /* 값 줄바꿈 금지 */
}

.row_item .desc {
  flex: 1 1 100%;           /* 설명은 아래 줄 전체 차지 */
  margin-left: calc(90px);  /* 라벨 길이만큼 들여쓰기 (선택사항) */
  white-space: normal;      /* 설명은 자동 줄바꿈 */
  color: gray;
}
.card {
  margin-left: 21px;   /* 카드 전체를 오른쪽으로 이동 */
}

.center_wrap {
  display: flex;
  flex-direction: column; /* 세로 배치 */
  align-items: center;    /* 가운데 정렬 */
}

.center_wrap h6 {
  margin-bottom: 6px;  /* 라벨과 값 사이 간격 */
}

.center_wrap span {
  display: block;
  text-align: center;
}

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
  width: 114px;           /* 글자가 커지면 폭 약간 늘림 */
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

<!-- (선택) 플러그인 전역 등록: 중복 선언 없음 -->
<script defer>
  document.addEventListener('DOMContentLoaded', function(){
    if (window.Chart && window.ChartDataLabels) {
      Chart.register(ChartDataLabels);
    }
  });
  
</script>
</head>
<body>

<main class="main-content">
  <!-- 시간대별 스택 막대 차트 -->
	<div class="top2-card decrease-card" style="margin-top:40px;">
	  <div class="date-range">
	    <button id="prev7" class="btn" type="button" aria-label="이전 7일">◀</button>
	    <input type="date" id="startDate" aria-label="시작일" readonly>
	    <span class="tilde"></span>
	    <input type="date" id="endDate" aria-label="종료일" readonly>
	    <button id="next7" class="btn" type="button" aria-label="다음 7일">▶</button>
	  </div>
	</div>	
  <div class="top3-card decrease-card" style="margin-top:1px;">
      <!-- 혈당 수치 패널 -->
	  <h5 class="chart-title">* 주간 혈당관리지표</h5>
		<section class="blood_list">
		  <div class="unit flx-row a-center j-end"> 
		    <span class="ft14">단위 : mg/dL</span>
		  </div>
		
		  <div class="top_row flx-row j-between a-center">
		    <div class="center_wrap aval_wrap">
		      <h6>평균 혈당</h6>
		      <div class="bl_color_low ft40" id="avgUpt" data-value="-">-</div>
		    </div>
		    <div class="line_col" style="height: 10vw;"></div>
		    <div class="center_wrap aval_wrap">
		      <h6>공복 평균</h6>
		      <div class="bl_color_low ft40" id="avgFastingBlood" data-value="-">-</div>
		    </div>
		    <div class="line_col" style="height: 10vw;"></div>
		    <div class="center_wrap aval_wrap">
		      <h6>식후 평균</h6>
		      <div class="bl_color_high ft40" id="after2hBlood" data-value="-">-</div>
		    </div>
		  </div>
		
		  <div class="top_row flx-row j-between a-center">
		    <div class="center_wrap aval_wrap">
		      <h6>GMI지수(%)</h6>
		      <span class="bl_color_low ft40" id="gmi" data-value="-">-</span>
		    </div>
		    <div class="line_col" style="height: 10vw;"></div>
		    <div class="center_wrap aval_wrap">
		      <h6>TIR(%)</h6>
		      <div>
		        <span class="bl_color_low ft40" id="tir" data-value="-">-</span>
		      </div>
		    </div>
		    <div class="line_col" style="height: 10vw;"></div>
		  </div>
		</section>
		<br>
    <h5 class="chart-title">* 저혈당/고혈당 발생구간(시간)</h5>

    <!-- 날짜 범위 선택 버튼 (기본 active = 당일) -->
    <div class="range-buttons" id="rangeButtons">
      <button class="btn" data-days="0">당일</button>
      <button class="btn active" data-days="7">7일</button>
      <button class="btn" data-days="14">14일</button>
      <button class="btn" data-days="30">30일</button>
    </div>

    <div id="chartBox">
      <div class="loading" id="loading">불러오는 중...</div>
      <canvas id="timeBandChart"></canvas>
    </div>
    <div class="legend" aria-label="범례">
      <span class="item"><i class="box" style="background:#6CC070"></i> 정상 (70~180)</span>
      <span class="item"><i class="box" style="background:#F0B24B"></i> 고 (180이상)</span>
      <span class="item"><i class="box" style="background:#FF0000"></i> 저 (70미만)</span>
    </div>
  </div>
   <div class="top3-card decrease-card">
	
	  <div class="top_row flx-row j-between a-center">
	    <div class="center_wrap aval_wrap">
	      <h6>TAR(%)</h6>
	      <span class="bl_color_low ft24" id="tar" data-value="-">-</span>
	    </div>
	    <div class="line_col" style="height: 10vw;"></div>
	    <div class="center_wrap aval_wrap">
	      <h6>TBR(%)</h6>
	      <div>
	        <span class="bl_color_low ft24" id="tbr" data-value="-">-</span>
	      </div>
	    </div>
	    <div class="line_col" style="height: 10vw;"></div>
	    <div class="center_wrap aval_wrap">
	      <h6>CV(%)</h6>
	      <div>
	        <span class="bl_color_low ft24" id="cv" data-value="-">-</span>
	      </div>
	    </div>
	  </div>
	  <br>
	  <div class="row_item">
	    <label style="font-size: 12px;">TAR(%):목표혈당범위(70-180mg/dl)초과시간비율</label>
	  </div>
	  <div class="row_item">
	    <label style="font-size: 12px;">TBR(%):목표혈당범위 미만(70미만 저혈당)시간비율</label>
	  </div>
	  <div class="row_item">
	    <label style="font-size: 12px;">CV(%) :혈당 변동계수(36% 미만 안정적)</label>
	  </div>

   </div> 
   <div class="top3-card decrease-card"> 
	  <div class="row_item">
	      <label>* 고혈당 구간:</label>
	      <span class="ft16 mr5" id="avgHigh_name" style="color: gray;"></span>
	  </div>
	  <div class="row_item">
	      <label>* 저혈당 구간:</label>
	      <span class="ft16 mr5" id="avgLow_name" style="color: gray;"></span>
	  </div>
   </div>	     
  <!-- 주간 혈당 감소 식사 TOP3 카드 -->
  <div class="top3-card decrease-card">
    <div class="card-header">
      <h5>*주의할음식TOP3(주간)</h5>
      <span class="unit-display font-small">단위 : mg/dL</span>
    </div>

	<div class="ranking-grid">
	  <div class="grid-header">
	    <span>순위</span>
	    <span>음식종류</span>
	    <span>식사량</span>
	    <span>혈당변동폭</span>
	  </div>
	  <div id="grid-rows-food"></div>
    </div>
  </div>  
  <div class="top3-card decrease-card">
    <div class="card-header">
      <h5>*추천운동TOP3(주간)</h5>    
      <span class="unit-display font-small">단위 : mg/dL</span>
    </div>

	<div class="ranking-grid">
	  <div class="grid-header">
	    <span>순위</span>
	    <span>운동종류</span>
	    <span>운동(분)</span>
	    <span>혈당변동폭</span>
	  </div>
	  <div id="grid-rows-exer"></div>
    </div>
  </div> 

  <div class="recommendation-card">

       <div class="card-header">
           <h3 class="card-title recommendation font-large">[개인 맞춤 추천]</h3>
       </div>	    
		<div class="report-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
		  <h5 style="margin: 0;">*주간 혈당관련 리포트</h5>
		  <span style="font-size: 12px; color: gray;"></span>
		</div>	  
	    <div class="row_item">

	      <span class="ft16 mr5" id="avgUpt1_name" style="color: gray;"></span>
	    </div>
	    <div class="row_item">
	      <span class="ft16 mr5" id="avgFastingBlood1_name" style="color: gray;"></span>
	    </div>
	    <div class="row_item">
          <span class="ft16 mr5" id="after2hBlood_name" style="color: gray;"></span>
	    </div>
	    <div class="row_item">
	      <span class="ft16 mr5" id="exerBlood_name1" style="color: gray;"></span> <!--exerBlood_name변경  -->
	    </div>
	    <div class="row_item">
	      <span class="ft16 mr5" id="exerBlood_name2" style="color: gray;"></span> <!--exerBlood_name변경  -->
	    </div>
	    <div class="row_item">
	      <span class="ft16 mr5" id="exerBlood_name3" style="color: gray;"></span> <!--exerBlood_name변경  -->
	    </div>
	    <div class="row_item">
	      <span class="ft16 mr5" id="exerBlood_name4" style="color: gray;"></span> <!--exerBlood_name변경  -->
	    </div>
	    <div class="row_item">
	      <span class="ft16 mr5" id="exerBlood_name5" style="color: gray;"></span> <!--exerBlood_name변경  -->
	    </div>	    	    	    
	  </div>

   <!-- 참조링크 -->
   <div class="recommendation-card">
       <div class="card-header">
           <h3 class="card-title recommendation font-large">[참조링크]</h3>
       </div>

       <div class="recommendation-content">
           <p class="recommendation-text font-large">
               * <a href="https://www.diabetes.or.kr/" target="_blank">대한당뇨병학회 바로가기</a><br><br>
               * <a href="https://www.youtube.com/channel/UCsVB1GWF-NH-RTxJax8XA_Q/featured?view_as=subscriber"
                   target="_blank">당뇨병의정석 (YouTube)</a>
           </p>
       </div>
   </div>  
</main>

<script>
  // ===== 전역 =====
  let chart;                         // Chart.js 인스턴스
  let userId = "";                   // 세션에서 주입
  // ▶ 라벨 통일(서버: '오전 12' 형태와 맞춤)
  const HOUR_ORDER = ['오전12','오전3','오전6','오전9','오후12','오후3','오후6','오후9'];

  // 서버/클라 라벨 포맷 차이 흡수 ('오전12' ↔ '오전 12')
  function normalizeHourLabel(s){
    if (!s) return '';
    const k = String(s).trim().replace(/\s+/g,''); // 공백 제거
    const map = {
      '오전12':'오전12','오전3':'오전3','오전6':'오전6','오전9':'오전9',
      '오후12':'오후12','오후3':'오후3','오후6':'오후6','오후9':'오후9'
    };
    return map[k] || s; // 매핑 없으면 원문 유지(디버깅 용)
  }

  // ===== 유틸 =====
  function pad2(n){ return ('0' + n).slice(-2); }
  function toYMD(date){
    return date.getFullYear() + '-' + pad2(date.getMonth()+1) + '-' + pad2(date.getDate());
  }

  // input에 날짜 세팅: valueAsDate 지원 시 우선 사용
  function setDateInputs(start, end){
    const sInput = document.getElementById('startDate');
    const eInput = document.getElementById('endDate');
    if(!sInput || !eInput) return;

    if ('valueAsDate' in sInput) sInput.valueAsDate = start;
    sInput.value = toYMD(start);

    if ('valueAsDate' in eInput) eInput.valueAsDate = end;
    eInput.value = toYMD(end);
  }

  function parseDateInput(value){
    if(!value) return null;
    const [y,m,d] = value.split('-').map(Number);
    return new Date(y, m-1, d);
  }

  // “오늘 포함 N일” 범위 계산 (종료일=오늘, 시작일은 N-1일 전)
  function computeRange(days){
    const today = new Date();
    const end = new Date(today.getFullYear(), today.getMonth(), today.getDate()); // 오늘(자정)
    const start = new Date(end);
    if (days > 0) start.setDate(start.getDate() - (days - 1));
    return { start, end };
  }

  function showLoading(on){
    var el = document.getElementById('loading');
    if(!el) return;
    if(on){ el.classList.add('show'); } else { el.classList.remove('show'); }
  }

//===== 차트 렌더 =====
  function renderChart(payload){
    const canvas = document.getElementById('timeBandChart');
    if(!canvas || !window.Chart){ return; }
    const ctx = canvas.getContext('2d');
    if (chart) chart.destroy();

    const cfg = {
      type: 'bar',
      data: {
        labels: payload.labels,
        datasets: [
           { 
                label:'저',   
                data: payload.low,    
                backgroundColor: '#FF0000',  // 빨간색 계열
                stack:'pct',
                barThickness: 20
           },
          { 
            label:'정상',  
            data: payload.normal, 
            backgroundColor:'#6CC070', 
            stack:'pct',
            barThickness: 20   // 막대 두께
          },
          { 
            label:'고',   
            data: payload.high,   
            backgroundColor:'#F0B24B', 
            stack:'pct',
            barThickness: 20
          }

        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display:false },
          tooltip: { 
            callbacks:{ 
              label:(ctx)=>`${ctx.dataset.label}: ${ctx.parsed.y}%` 
            } 
          },
          datalabels: window.ChartDataLabels ? {
            formatter: (value) => (value >= 5 ? value + '%' : ''),
            color: '#fff',
            font: { weight: '600' },
            anchor: 'center',
            align: 'center',
            clip: true
          } : undefined
        },
        scales: {
          x: { stacked:true },
          y: { stacked:true, beginAtZero:true, max:100, display:false, grid:{ display:false } }
        }
      },
      plugins: window.ChartDataLabels ? [ChartDataLabels] : []
    };

    chart = new Chart(ctx, cfg);
  }
 
  //===== 데이터 로드 (AJAX/fetch) =====
  function loadTimeBand(startDate, endDate){
    const s = new Date(startDate);
    const e = new Date(endDate);
    const uid = (userId && userId !== "null") ? userId : "";
    const formData = { start: toYMD(s), end: toYMD(e), userId: uid };

    const fallback = () => renderChart({
      labels: HOUR_ORDER,
      low:    [0,0,0,0,0,0,0,0],  // 데이터 없으면 0
      normal: [0,0,0,0,0,0,0,0],
      high:   [0,0,0,0,0,0,0,0]
    });

    showLoading(true);
    loadclear() ;
    // 응답을 배열 또는 {list:[...]}/{data:[...]} 모두 처리
    const handleResponse = (resp) => {
      try{
        const responseList = Array.isArray(resp) ? resp : (resp?.list || resp?.data || []);
        if (!Array.isArray(responseList) || responseList.length === 0){
          fallback(); return;
        }
        const byLabel = {};
        responseList.forEach(r=>{
          const rawLabel = r.hourLabel ?? r.HOUR_LABEL ?? r.hour_label;
          const label = normalizeHourLabel(rawLabel);
          if(!label) return;
          byLabel[label] = {
            low:    Number(r.lowPct ?? r.LOW_PCT ?? r.low_pct ?? 0),
            normal: Number(r.normalPct ?? r.NORMAL_PCT ?? r.normal_pct ?? 0),
            high:   Number(r.highPct ?? r.HIGH_PCT ?? r.high_pct ?? 0)
          };
        });

        const labels = [], low=[], normal=[], high=[];
        HOUR_ORDER.forEach(lbl=>{
          const row = byLabel[lbl] || {low:0, normal:0, high:0};
          labels.push(lbl);
          low.push(row.low); normal.push(row.normal); high.push(row.high);
        });

        renderChart({ labels, low, normal, high });
      } catch (e){
        console.error('PARSE ERROR', e);
        fallback();
      } finally {
        showLoading(false);
      }
      showBloodData(formData.start,formData.end) ;
      showBloodData_max(formData.start,formData.end) ;
    };

    // CSRF 메타에서 읽기 (Spring Security 사용 시)
    const csrfToken  = document.querySelector('meta[name="_csrf"]')?.content;
    const csrfHeader = document.querySelector('meta[name="_csrf_header"]')?.content;

    // jQuery 존재시 AJAX(JSON), 없으면 fetch(JSON)
    if (window.$ && $.ajax) {
      $.ajax({
        url: "/avgBloodlowhight.do",
        method: "POST",
        contentType: "application/json; charset=UTF-8",
        dataType: "json",
        data: JSON.stringify(formData),
        beforeSend: function(xhr){
          if (csrfToken && csrfHeader) xhr.setRequestHeader(csrfHeader, csrfToken);
        },
        success: handleResponse,
        error: function(xhr){
          console.error("AJAX ERROR", xhr.status, xhr.responseText);
          showLoading(false); fallback();
        }
      });
    } else {
      const headers = { "Content-Type": "application/json; charset=UTF-8" };
      if (csrfToken && csrfHeader) headers[csrfHeader] = csrfToken;

      fetch("/avgBloodlowhight.do", {
        method: "POST",
        headers,
        body: JSON.stringify(formData)
      })
      .then(async res => {
        const txt = await res.text();
        if (!res.ok) throw new Error(`HTTP ${res.status} :: ${txt}`);
        return JSON.parse(txt);
      })
      .then(handleResponse)
      .catch(err => { console.error("REQ FAIL:", err); showLoading(false); fallback(); });
    }
  }

  // ===== 디바운스 유틸 =====
  function debounce(fn, delay){
    let t;
    return (...args) => { clearTimeout(t); t = setTimeout(()=>fn(...args), delay); };
  }
  // ===== 초기화 & 이벤트 =====
  document.addEventListener('DOMContentLoaded', function(){
    // 세션 userUuid 주입
    userId = '<%= String.valueOf(session.getAttribute("userUuid")) %>';

    const box = document.getElementById('rangeButtons');
    const applyBtn = document.getElementById('applyBtn');
    const sEl = document.getElementById('startDate');
    const eEl = document.getElementById('endDate');

    // 초기: active 버튼 기준으로 input/차트 세팅
    const activeBtn = box?.querySelector('.btn.active') || box?.querySelector('.btn[data-days="0"]');
    if (activeBtn){
      const days = Number(activeBtn.getAttribute('data-days'));
      const { start, end } = computeRange(days);
      setDateInputs(start, end);
      loadTimeBand(start, end);
    }

    // 범위 버튼 클릭
    box?.addEventListener('click', function(e){
      const btn = e.target.closest('.btn');
      if(!btn) return;

      box.querySelectorAll('.btn').forEach(b=>b.classList.remove('active'));
      btn.classList.add('active');

      const days = Number(btn.getAttribute('data-days'));
      const { start, end } = computeRange(days);
      setDateInputs(start, end);
      loadTimeBand(start, end);
    });

    // 조회 버튼: 입력값 기준 수동 조회 (버튼 active 해제)
    applyBtn?.addEventListener('click', function(){
      const sVal = sEl?.value;
      const eVal = eEl?.value;
      if(!sVal || !eVal) return;

      let s = parseDateInput(sVal);
      let e = parseDateInput(eVal);

      // 시작 > 종료면 자동 교환
      if (s.getTime() > e.getTime()){
        const t = s; s = e; e = t;
        setDateInputs(s, e);
      }

      // 수동 조회 시 버튼 active 해제
      document.querySelectorAll('#rangeButtons .btn').forEach(b=>b.classList.remove('active'));
      loadTimeBand(s, e);
    });

    // 날짜 변경 시 자동 조회 (디바운스)
    const autoQuery = debounce(()=>{
      const sVal = sEl?.value, eVal = eEl?.value;
      if(!sVal || !eVal) return;
      let s = parseDateInput(sVal), e = parseDateInput(eVal);
      if (s.getTime() > e.getTime()){
        const t = s; s = e; e = t;
        setDateInputs(s, e);
      }
      document.querySelectorAll('#rangeButtons .btn').forEach(b=>b.classList.remove('active'));
      loadTimeBand(s, e);
    }, 300);

    // 일부 브라우저 호환을 위해 input/change 모두 연결
    sEl?.addEventListener('input', autoQuery);
    sEl?.addEventListener('change', autoQuery);
    eEl?.addEventListener('input', autoQuery);
    eEl?.addEventListener('change', autoQuery);

    // 엔터로 조회
    ['startDate','endDate'].forEach(id=>{
      const el = document.getElementById(id);
      el?.addEventListener('keydown', ev=>{
        if(ev.key === 'Enter') document.getElementById('applyBtn')?.click();
      });
    });
  });
  function loadclear(){
		document.getElementById('avgUpt').textContent = "-";
		document.getElementById('gmi').textContent = "-" ;	  
	    document.getElementById('tar').textContent = "-" ;
	    document.getElementById('tbr').textContent = "-" ;
	    document.getElementById('cv').textContent  = "-" ;
	    document.getElementById('avgFastingBlood').textContent  = "-" ;
	    document.getElementById('after2hBlood').textContent  = "-" ;
	    document.getElementById('tir').textContent  = "-" ;
	    
	    document.getElementById('avgUpt1_name').textContent  = "";
	    document.getElementById('exerBlood_name1').textContent  = "";
	    document.getElementById('exerBlood_name2').textContent  = "";
	    document.getElementById('exerBlood_name3').textContent  = "";
	    document.getElementById('exerBlood_name4').textContent  = "";
	    document.getElementById('exerBlood_name5').textContent  = "";
	    document.getElementById('after2hBlood_name').textContent  = "";
	    document.getElementById('avgFastingBlood1_name').textContent  = "";
	    document.getElementById('grid-rows-food').innerHTML = '자료없음';
	    document.getElementById('grid-rows-exer').innerHTML = '자료없음';
	    document.getElementById('avgLow_name').textContent  =  "";
        document.getElementById('avgHigh_name').textContent =  "";
	    
  } 
  function showBloodData(startDate, endDate) {
	    var formData = {
	        start: startDate,
	        end: endDate,
	        userId: userId
	    };

	    // 평균 Upt 데이터 가져오기
	    const avgUpt1_name = document.getElementById('avgUpt1_name');
	    
   
	    CommonUtil.callAjax(CommonUtil.getContextPath() + "/showBloodAvgData.do", "POST", formData,
	        function(response) {
	            document.getElementById('tar').textContent = (response.TAR_UPT || 0).toFixed(1);
	            document.getElementById('tbr').textContent = (response.TBR_UPT || 0).toFixed(1);
	            document.getElementById('cv').textContent  = (response.CV_UPT || 0).toFixed(1);
	            
	            let avgUptValue = Math.round(response.AVG_UPT)  || 0;
	            
	            document.getElementById('avgUpt').textContent = avgUptValue;

	            if (avgUptValue < 154) {
	                avgUpt1_name.textContent = "평균혈당이 안정적";
	            } else if (avgUptValue >= 154 && avgUptValue <= 180) {
	                avgUpt1_name.textContent = "평균혈당이 조금 높습니다. 생활습관을 점검해 보시면 좋겠습니다.";
	            } else if (avgUptValue > 180) {
	                avgUpt1_name.textContent = "평균혈당이 높습니다. 의료진 상담을 권장드립니다.";
	            } else {
	                avgUpt1_name.textContent = "";
	            }   

	            let tarnum = parseFloat(response.TAR_UPT || 0).toFixed(1);
	            tarnum = parseFloat(tarnum);

	            let message = "";
	            if (tarnum < 25) {
	                message = "TAR 고혈당 시간이 적어 양호";
	            } else if (tarnum >= 25 && tarnum <= 50) {
	                message = "TAR 고혈당 시간이 늘고 있습니다. 주의가 필요합니다.";
	            } else if (tarnum > 50) {
	                message = "TAR 고혈당 시간이 많습니다. 의료진 상담을 권장드립니다.";
	            }
	            const exerBlood_name2 = document.getElementById('exerBlood_name2');
	            exerBlood_name2.textContent = message ;
	            
	            // --- TBR 부분 ---
	            let tbrnum = parseFloat(response.TBR_UPT || 0).toFixed(1);
	            tbrnum = parseFloat(tbrnum);

	            let message1 = "";
	            if (tbrnum < 4) {
	                message1 = "TBR 저혈당이 거의 없어 안전합니다.";
	            } else if (tbrnum >= 4 && tbrnum <= 10) {
	                message1 = "TBR 저혈당이 가끔 발생합니다. 조심해 주세요.";
	            } else if (tbrnum > 10) {
	                message1 = "TBR 저혈당 위험이 큽니다. 빠른 대처가 필요합니다.";
	            }
	            const exerBlood_name3 = document.getElementById('exerBlood_name3');
	            exerBlood_name3.textContent = message1 ;
	            
	            let cvnum = parseFloat(response.CV_UPT || 0).toFixed(1);
	            let message2 = "";
	            if (cvnum <= 36) {
	                message2 = "CV 혈당 변동이 안정적입니다.";
	            } else if (cvnum > 36 && cvnum <= 45) {
	                message2 = "CV 혈당 변동이 조금 큽니다. 생활습관 조정이 필요합니다.";
	            } else if (cvnum > 45) {
	                message2 = "CV 혈당 변동이 심합니다. 전문가 상담을 권장드립니다.";
	            }
	            const exerBlood_name4 = document.getElementById('exerBlood_name4');
	            exerBlood_name4.textContent = message2 ;
	            
	        }
	    );
	    //gmi 
	    CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/calcBlood.do", "POST", formData,
	        function(response) {
	            console.log("표준편차, 변동계수 가져옴. :", response);
	            let gmi = parseFloat(response.GMI);
	            document.getElementById('gmi').textContent = gmi;

	            let message = "";
	            if (gmi < 7.0) {
	                message = "GMI가 양호합니다.";
	            } else if (gmi >= 7.0 && gmi <= 8.0) {
	                message = "GMI가 다소 높습니다. 관리 강화를 권장드립니다.";
	            } else if (gmi > 8.0) {
	                message = "GMI가 높아 합병증 위험이 있습니다. 빠른 상담이 필요합니다.";
	            }
	            const exerBlood_name1 = document.getElementById('exerBlood_name1');
	            exerBlood_name1.textContent = message ;
	        }
	    );

	    // TIR 처리
	    CommonUtil.callAjax(CommonUtil.getContextPath() + "/BloodLowHigh.do", "POST", formData,
	        function(response) {
	            var tirElem = document.getElementById('tir');

	            if (!response || !response.TIR) {
	                tirElem.textContent = "-";
	                document.getElementById('exerBlood_name').innerHTML += "<br><br>";
	                return;
	            }

	            let tir = response.TIR;
	            tirElem.textContent = tir;

	            let tirnum = parseFloat(response.TIR);
	            let message = "";
	            if (tirnum >= 70) {
	                message = "TIR 혈당이 목표 범위 내에서 잘 유지되고 있습니다.";
	            } else if (tirnum > 50 && tirnum < 70) {
	                message = "TIR 목표 범위 내 시간이 다소 부족합니다. 조금 더 관리가 필요합니다.";
	            } else if (tirnum <= 50) {
	                message = "TIR 목표 범위 내 시간이 매우 적습니다. 적극적인 조치가 필요합니다.";
	            }
	            const exerBlood_name5 = document.getElementById('exerBlood_name5');
	            exerBlood_name5.textContent = message ;
	        }
	    );
	 
	    //공복/식후 혈당 로직  
	    CommonUtil.callAjax(
	    		  CommonUtil.getContextPath() + "/getAvgFasting.do",
	    		  "POST",
	    		  formData,
	    		  function (response) {
	    		    // 문자열 응답이면 JSON 파싱
	    		    if (typeof response === "string") {
	    		      try { response = JSON.parse(response); } catch (e) {}
	    		    }

	    		    // 요소
	    		    const fastingEl       = document.getElementById('avgFastingBlood');   // 숫자만
	    		    const fastingEl1      = document.getElementById('avgFastingBlood1');  // 숫자 + 단위
	    		    const after2hEl       = document.getElementById('after2hBlood');      // 숫자만
	    		    const after2hEl1      = document.getElementById('after2hBlood1');     // 숫자 + 단위

	    		    // 데이터 안전 추출
	    		    const data = (response && response.IsSucceed && response.Data) ? response.Data : null;

	    		    // 숫자 검증 + 정수화
	    		    const fastingVal = (data && Number.isFinite(Number(data.fastingValue)))
	    		      ? Math.trunc(Number(data.fastingValue)) : null;
	    		    const after2hVal = (data && Number.isFinite(Number(data.after2hValue)))
	    		      ? Math.trunc(Number(data.after2hValue)) : null;

	    		    // 값 표시
	    		    if (data) {
	    		      if (fastingEl)  fastingEl.textContent  = (fastingVal ?? '-');
	    		      if (fastingEl1) fastingEl1.textContent = (fastingVal != null) ? (fastingVal + "mg/dl") : "-";
	    		      if (after2hEl)  after2hEl.textContent  = (after2hVal ?? '-');
	    		      if (after2hEl1) after2hEl1.textContent = (after2hVal != null) ? (after2hVal + "mg/dl") : "-";
	    		    } else {
	    		      if (fastingEl)  fastingEl.textContent  = "-";
	    		      if (fastingEl1) fastingEl1.textContent = "-";
	    		      if (after2hEl)  after2hEl.textContent  = "-";
	    		      if (after2hEl1) after2hEl1.textContent = "-"; // ← 오타 수정
	    		    }

	    		    // 상태 문구 갱신 (식후 2시간 기준 예시)
	    		    const statusSpan = document.getElementById('after2hBlood_name');
	    		    if (statusSpan) {
	    		      if (after2hVal != null && after2hVal < 180) {
	    		        statusSpan.textContent = "식후혈당이 적절한 범위 입니다.";
	    		      }else if ( after2hVal >= 180 && after2hVal <= 220) {
		    		    statusSpan.textContent = "식후혈당이 약간 높습니다. 식사 후 가벼운 활동이 도움이 됩니다. ";
	    		      } else if (after2hVal != null && after2hVal > 220) {
	    		        statusSpan.textContent = "식후혈당이 많이 올랐습니다. 관리가 필요합니다.";
	    		      }
	    		    }
	    		    const fastingEl1_name = document.getElementById('avgFastingBlood1_name');  // 숫자 + 단위
	    		      if (fastingVal >= 80 &&fastingVal <= 130) {
	    		    	  fastingEl1_name.textContent = "공복혈당이 목표 범위 안 입니다.";
		    		  }else if (fastingVal > 131 && fastingVal <= 160) {
		    		      fastingEl1_name.textContent = "공복혈당이 다소 높습니다. 식습관을 살펴보시면 좋겠습니다.";
		    		  }else if (fastingVal > 160) {
		    		      fastingEl1_name.textContent = "공복혈당이 높습니다. 조속한 관리가 필요합니다.";		    		      
		    		  }else {
		    		      fastingEl1_name.textContent = "";
	 	    		 }
	    		  }
	    		); // ← Ajax 콜 닫힘 정상
	    	    // 평균 Upt 데이터 가져오기
	    	    CommonUtil.callAjax(CommonUtil.getContextPath() + "/showBloodHighLow.do", "POST", formData,
	    	        function(response) {
	    	            document.getElementById('avgLow_name').textContent  = response.Low_Value ;
	    	            document.getElementById('avgHigh_name').textContent = response.High_Value;
	    	            
	    	       }
	    	    ); 
    }	  
	function showBloodData_max(startDate, endDate)	  {
	         var formData = {
		        start: startDate,
		        end: endDate,
		        userId: userId
		     };
			  // 식사전/식후 혈당 중 큰 값으로, 그리드에 렌더
 			  CommonUtil.callSyncAjax(
				    CommonUtil.getContextPath() + "/foodBlood_max.do",
				    "POST",
				    formData,
				    function(responseList) {
					  const container = document.getElementById('grid-rows-food');
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
				
				      // 전체 행 표시
				        const rowsHtml = responseList.map(item => {
				        const foodRn   = toHHMM(item.RN);
				        const rawName  = item.FOOD_NAME;
				        const foodName = truncate(rawName, 8);
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
				// 운동후  혈당 중 큰 값으로, 그리드에 렌더
			    let isExerBloodSet = false; // 최초 실행 여부 플래그
				const exerBloodEl       = document.getElementById('exerBlood');
				const exerBloodEl_name  = document.getElementById('exerBlood_name');
			    CommonUtil.callSyncAjax(
				    CommonUtil.getContextPath() + "/exerBlood_max.do",
				    "POST",
				    formData,
				    function(responseList) {
				      const container = document.getElementById('grid-rows-exer');
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
				    	  exerBloodEl.innerText = "-" ;
				    	  return;
				    	}
				
				      // 전체 행 표시
				        const rowsHtml = responseList.map(item => {
				        const exerRn   = toHHMM(item.RN);
				        const rawName  = item.EXER_NAME;
				        const exerName = truncate(rawName, 8);
				        const exerQty  = item.MINUTES_DIFF;
				
				        const pre  = toNumber(item.PRE_VALUE);
				        const post = toNumber(item.DELTA_15M);
				        let bloodVal = '-';
				        if (pre !== null || post !== null) {
				          const maxVal = Math.max(pre ?? -Infinity, post ?? -Infinity);
				          if (Number.isFinite(maxVal)) bloodVal = String(maxVal);
				        } else {
				          bloodVal = safeText(item.DELTA_15M);
				        }
				     // 최초 1건일 때만 #exerBlood에 값 넣기
						
						if (exerBloodEl && !isExerBloodSet) {
						  if (bloodVal && bloodVal !== '-') {
						    exerBloodEl.innerText = "" ;
						  } else {
						    exerBloodEl.innerText = "";
						  }
						  isExerBloodSet = true; // 최초 1번 실행 후 true로 변경
						}
				        return `
				          <div class="grid-row">
				            <span>\${safeText(exerRn)}</span>
				            <span title="\${safeText(rawName)}">\${safeText(exerName)}</span>
				            <span>\${safeText(exerQty)}</span>
				            <span>\${safeText(bloodVal)}</span>
				          </div>
				        `;
				      }).join('');
				
				      container.innerHTML = rowsHtml;
				    }
				  );			
      }  
	
	// ===== 7일 이동 보조 함수 =====
	function addDays(d, n){
	  const nd = new Date(d.getFullYear(), d.getMonth(), d.getDate());
	  nd.setDate(nd.getDate() + n);
	  return nd;
	}

	function shiftRangeBy(daysDelta){
	  const sEl = document.getElementById('startDate');
	  const eEl = document.getElementById('endDate');

	  // 현재 input 값 기준으로 이동 (없으면 active 버튼 기준 계산)
	  let start, end;
	  if (sEl?.value && eEl?.value){
	    start = parseDateInput(sEl.value);
	    end   = parseDateInput(eEl.value);
	    if (start.getTime() > end.getTime()){
	      const t = start; start = end; end = t;
	    }
	  } else {
	    const box = document.getElementById('rangeButtons');
	    const activeBtn = box?.querySelector('.btn.active') || box?.querySelector('.btn[data-days="0"]');
	    if (activeBtn){
	      const days = Number(activeBtn.getAttribute('data-days'));
	      const r = computeRange(days);
	      start = r.start; end = r.end;
	    } else {
	      // 안전장치: 오늘 기준 최근 7일
	      const today = new Date();
	      end = today;
	      start = addDays(today, -6);
	    }
	  }

	  // 7일 단위 이동
	  const newStart = addDays(start, daysDelta);
	  const newEnd   = addDays(end,   daysDelta);

	  // 버튼 active 해제 후 세팅 & 조회
	  document.querySelectorAll('#rangeButtons .btn').forEach(b=>b.classList.remove('active'));
	  setDateInputs(newStart, newEnd);
	  loadTimeBand(newStart, newEnd);
	}

	// ===== DOMContentLoaded 내부에 추가할 이벤트 바인딩 =====
	const prev7Btn = document.getElementById('prev7');
	const next7Btn = document.getElementById('next7');

	prev7Btn?.addEventListener('click', function(){
	  shiftRangeBy(-7);
	});

	next7Btn?.addEventListener('click', function(){
	  shiftRangeBy(7);
	});
<%-- 	
   // 숫자만 추출해서 반환 ("0"도 유효), 없으면 null
	function getNumberText(elId){
	  const el = document.getElementById(elId);
	  if(!el) return null;

	  const pickNum = s => (s || '').trim().replace(/[^\d.-]/g,'');
	  let v = pickNum(el.textContent);
	  if(!v) v = pickNum(el.getAttribute('data-value')); // data-value도 체크
	  return v || null;
	}
	// 프롬프트 생성
	function buildPrompt(){
	  const avg     = getNumberText('avgUpt1');             // 평균혈당
	  const fasting = getNumberText('avgFastingBlood1');    // 공복평균
	  const post2h  = getNumberText('after2hBlood1');       // 식후평균

	  const sAvg     = avg     ?? '';
	  const sFasting = fasting ?? '';
	  const sPost2h  = post2h  ?? '';
	  
	  return [
	    '아래 혈당 지표를 바탕으로 300자 이내 한국어 요약 소견을 작성해 주세요.',
	    '문체: 간결, 조언 2~3개, 과도한 의학적 단정 금지.',
	    `평균혈당: ${sAvg}`,
	    `공복평균: ${sFasting}`,
	    `식후(2h) 평균: ${sPost2h}`,
	    '출력은 문장 한 단락으로만.'
	  ].join('\n');
	}

	// AI 호출
	async function ai_chat(){
		
	  const prompt = buildPrompt();
	  if (!prompt) {
	    console.log("보낸자료 없음 -> ai_chat 실행 안 함");
	    return;
	  }
	  const out = document.getElementById('exerBlood_name');
	  if(!out) return;

	  const prev = out.textContent;
	  out.style.color = 'gray';
	  out.textContent = '소견 생성 중...';

	  try{
	    const message = buildPrompt();

	    const res = await fetch('<%=request.getContextPath()%>/ai/chat.do', {
	      method: 'POST',
	      headers: {'Content-Type':'application/json;charset=UTF-8'},
	      body: JSON.stringify({ message })
	    });

	    const data = await res.json().catch(()=>({error:'JSON parse error'}));
	    let text = data?.answer ?? ('오류: ' + (data?.error || 'unknown'));

	    if (text.length > 300) text = text.slice(0, 300).replace(/\s+\S*$/,'') + '…';

	    out.textContent = text;
	    out.style.color = '#444';
	  }catch(err){
	    out.textContent = '오류: ' + (err?.message || err);
	    out.style.color = 'crimson';
	  }
	}

	// 값 존재 여부(세 지표 중 하나라도 있으면 true)
	function hasAnyGlycemiaValue(){
	  const vals = [
	    getNumberText('avgUpt1'),
	    getNumberText('avgFastingBlood1'),
	    getNumberText('after2hBlood1')
	  ];
	  return vals.some(v => v !== null && v !== '');
	}

	// 자동 실행 세팅 (한 번만)
	(function setupAutoRunOnce(){
	  const ids = ['avgUpt1','avgFastingBlood1','after2hBlood1'];
	  const targets = ids.map(id => document.getElementById(id)).filter(Boolean);
	  if (targets.length === 0) return;

	  let fired = false;
	  let timer = null;
	  const observers = [];

	  const runOnceIfReady = () => {
	    if (fired) return;
	    if (hasAnyGlycemiaValue()) {
	      fired = true;
	      observers.forEach(o => o.disconnect());
	      ai_chat();
	    }
	  };

	  const debounced = () => {
	    clearTimeout(timer);
	    timer = setTimeout(runOnceIfReady, 120);
	  };

	  // 로드 직후 값이 이미 있으면 바로 실행
	  document.readyState === 'loading'
	    ? document.addEventListener('DOMContentLoaded', () => setTimeout(runOnceIfReady, 0))
	    : setTimeout(runOnceIfReady, 0);

	  // 이후 변경 감시 (텍스트/속성)
	  targets.forEach(el => {
	    const obs = new MutationObserver(debounced);
	    obs.observe(el, {
	      childList: true,
	      characterData: true,
	      subtree: true,
	      attributes: true,
	      attributeFilter: ['data-value']
	    });
	    observers.push(obs);
	  });

	  // 전역 수동 호출도 가능하게 노출(선택)
	  window.ai_chat = ai_chat;
	})();  
	
	--%>

</script>
</body>
</html>
