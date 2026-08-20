<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="ko">
<head>

<meta charset="UTF-8">
<title>시간대별 통계</title>

<%@ include file="/WEB-INF/inc/pwa-head.jsp" %>


<link href="${pageContext.request.contextPath}/asset/css/comm_blood.css?date=<%= System.currentTimeMillis() %>" rel="stylesheet">

<!-- (선택) Spring Security CSRF 메타 -->
<meta name="_csrf" content="${_csrf.token}">
<meta name="_csrf_header" content="${_csrf.headerName}">

<!-- jQuery & Chart.js -->
<script src="https://code.jquery.com/jquery-3.6.4.min.js" defer></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4" defer></script>
<!-- 데이터라벨 (옵션) -->
<script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2" defer></script>
<!-- 혈당 Q&A 지식베이스 (답변 추가/수정은 이 파일만 편집) -->
<script src="${pageContext.request.contextPath}/asset/js/blood_qa.js?date=<%= System.currentTimeMillis() %>" defer></script>

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
  #chartBox{height:225px;position:relative;width:calc(100% + 14px);margin:0 -7px}
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
    /* ★16px 미만으로 내리지 말 것 — iOS Safari 는 폰트가 16px 보다 작은 입력칸을 탭하면
       읽을 수 있게 화면을 자동 확대하는데, 포커스가 빠져도 배율을 되돌리지 않는다.
       (확대된 화면에서 나머지 조작을 계속하게 되어 사실상 화면이 깨진 것처럼 보인다)
       이 파일에는 .date-range input[type="date"] 규칙이 두 벌 있다 — 특이도가 같아
       뒤에 나오는 쪽(flex:1 / text-align:center 가 있는 블록)이 실제로 적용되고 여기는 덮인다.
       한쪽만 고치면 효과가 없으므로 둘 다 16px 로 맞춰 둔다. */
    padding:4px 5px;border:1px solid #e0e0e0;border-radius:8px;background:#fff;font-size:16px
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
    display:flex; gap:16px; margin-top:2px; font-size:12px; color:#333; align-items:center;
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
  font-size: 12px;  /* 10px 은 너무 작아 안 읽힘 */
  /* space-between 은 남는 폭을 전부 사이에 몰아넣어 간격이 너무 벌어졌다.
     고정 간격으로 두되, 예전(12px)보다는 넓게 잡아 오른쪽 여백을 줄인다. */
  gap: 24px;
  justify-content: flex-start;
  flex-wrap: wrap;
}
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
.ranking-grid { 
  display: grid; 
  gap: 8px; 
}

/* 공통 레이아웃
   고정폭(60px 60px 50px 60px)이라 카드 폭을 다 못 쓰고 오른쪽이 남았고,
   "음식종류/운동종류" 가 좁아 잘렸다. 비율(fr)로 바꿔 카드 폭을 채운다.
   minmax(0,·) 가 없으면 그리드 항목이 내용 크기 아래로 못 줄어 넘친다. */
.grid-header,
.grid-row {
  display: grid;
  grid-template-columns: 40px minmax(0, 1.4fr) minmax(0, 1fr) minmax(0, 1.3fr);
  gap: 8px;
  column-gap: 14px;   /* '순위' 와 다음 열 사이가 붙어 보여 간격을 조금 더 준다 */
  align-items: center;
  font-size: 14px;
  padding: 4px 8px;
  box-sizing: border-box;        /* 패딩 포함 폭 계산 */
  margin-left: 0;                /* 음수 마진 제거 — 좌우가 어긋났다 */
}

/* 한 줄 처리 */
.grid-header span,
.grid-row span {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  text-align: left;
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
/* 예전에는 여기서 span 에 margin-left:-10px, 2번째 열에 translateX(-6px),
   그리고 유효하지 않은 padding-left:-4px 로 위치를 억지로 맞추고 있었다.
   그리드 비율을 제대로 잡았으므로 모두 제거한다. */
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
/* 예전에는 여기서 `margin-left: 5` / `-7` 처럼 단위 없는 값으로 열 위치를 억지로 맞췄다.
   표준 모드에서는 무시되지만 이 페이지는 쿼크 모드라 실제로 적용되어 열이 어긋났다.
   그리드 비율을 제대로 잡았으므로 모두 제거한다. */
#grid-rows-food span:nth-child(1),
#grid-rows-exer span:nth-child(1),
#grid-rows-food span:nth-child(2),
#grid-rows-exer span:nth-child(2),
#grid-rows-food span:nth-child(3),
#grid-rows-exer span:nth-child(3) {
  text-align: left;
  margin-left: 0;
}

#grid-rows-food span:nth-child(4),
#grid-rows-exer span:nth-child(4) {
  text-align: right;   /* 혈당변동폭은 우측 정렬 */
}
/* `display:block` + `margin-top:14px` 이라 '단위 : mg/dL' 가 제목 아래 줄을 차지했고,
   그 탓에 카드 헤더가 좁아져 '*주의할음식TOP3(주간)' 이 두 줄로 접혔다.
   제목과 같은 줄 오른쪽에 두고, 둘 다 줄바꿈을 막는다. */
.unit-display {
  display: inline-block;
  margin-top: 0;
  margin-left: auto;    /* 헤더가 flex 라 오른쪽 끝으로 */
  text-align: right;
  white-space: nowrap;
  flex: 0 0 auto;
}
.card-header h5 {
  white-space: nowrap;
  margin: 0;
  font-size: 15px;   /* TOP3(주의할음식/추천운동) 제목 조금 작게 */
}

/* [2026-07-31 기획] 주간 혈당관리지표 — 앞장(연속혈당 상세)과 동일한 표현식 목록 + AI 분석 텍스트 */
/* [2026-08-05] 연속혈당 상세 지표(FAHR_00 .p2list)와 같은 배치로 통일 —
   라벨(권장 기준) 왼쪽 / 값 오른쪽 한 줄. 종전엔 값을 라벨 아래에 쌓아 오른쪽이 통째로 비었다. */
/* ═══════════════════════════════════════════════════════════════════════════
   ★★[2026-08-18] 지표 목록을 ***연속혈당 상세와 같은 클래스(.p2list/.p2item)*** 로 바꿨다.
     그동안 `.wk-metrics` 를 저쪽 값에 맞춰 여러 번 손봤지만(크기·굵기·폭·바탕),
     ***화면에서는 계속 어긋나 보였다.*** 값을 베끼는 방식으로는 규칙이 하나만 달라도 갈린다.
   ⇒ 아래 규칙은 FAHR_00.jsp 의 `.p2list` 를 **글자 하나 안 고치고 그대로** 가져온 것이다.
     고칠 일이 생기면 ***두 파일을 함께*** 고친다.
   ⚠이 목록의 부모(.blood_list)가 좌우 20px 을 먹어 저쪽보다 좁아진다 —
     그만큼만 음수 마진으로 되받는다(폭까지 같아진다).
   ═══════════════════════════════════════════════════════════════════════ */
.p2list{
  /* ★「글자체가 다르다」의 진범: FAHR_00 은 blood_fahr.css 가 body 에 Noto Sans KR 을 걸지만
     이 화면(comm_blood.css)에는 font-family 지정이 없어 브라우저 기본 글꼴로 그려졌다.
     px 값을 아무리 맞춰도 글꼴이 달라 계속 어긋나 보였던 것. 저쪽 body 선언과 동일하게: */
  font-family: 'Noto Sans KR', sans-serif; line-height: 1.4; -webkit-font-smoothing: antialiased;
  margin: calc(0.6 * var(--vwu,1vw)) calc(4 * var(--vwu,1vw)) calc(1.5 * var(--vwu,1vw)); }
.p2list .p2item{ display:flex; align-items:center; justify-content:space-between; gap: calc(3 * var(--vwu,1vw));
  padding: calc(2 * var(--vwu,1vw)) 0; border-bottom:1px solid #eef2f7; }
.p2list .p2item .lb{ font-size: calc(5.5 * var(--vwu,1vw)); color:#2d303f; font-weight:700; margin:0; line-height:1.35; }
.p2list .p2item .lb .hint{ display:block; font-size: calc(4.0 * var(--vwu,1vw)); color:#8a98a8; font-weight:500; }
.p2list .p2item .v{ flex:0 0 auto; font-size: calc(6.4 * var(--vwu,1vw)); font-weight:800; color:#2d303f; white-space:nowrap; }
/* ★[2026-08-18] 「첫번째(연속혈당)처럼 좌우 쫙차게」 —
   이 목록 위로 부모 셋이 좌우 여백을 겹겹이 먹는다:
     .main-content 12px + .top3-card 6px(인라인 축소본) + .blood_list 20px = 38px/쪽.
   38px 을 전부 음수 마진으로 되받아 흰 바탕이 화면 끝까지 닿게 하고(전면폭이라 둥근모서리 제거),
   글자 안쪽 여백은 연속혈당 화면과 같은 값(blood_list 20px + p2list 마진 4vwu)을 패딩으로 재현한다. */
.blood_list .p2list{ margin-left:-38px; margin-right:-38px;
  padding-left: calc(20px + 4 * var(--vwu,1vw)); padding-right: calc(20px + 4 * var(--vwu,1vw));
  background:#fff; border-radius:0; }
.wk-ai { margin-top: 0; }  /* 10px -> 0: flex gap(8px)만 남겨 간격 축소 */
/* ★[2026-08-18] 「두가지도 동일하게」 — 생활습관 가이드(.wk-ai)와 저혈당/고혈당 발생구간 묶음(.wk-fullbleed)도
   위 지표 목록과 같은 전면폭으로 — 부모 3겹(12+6+20=38px/쪽)을 되받고 안쪽 20px 만 남긴다. */
.wk-ai, .wk-fullbleed { margin-left:-38px; margin-right:-38px; padding-left:20px; padding-right:20px; background:#fff; }
/* ★[2026-08-18] 전면폭 구간 사이로 .blood_list 의 하늘색 바탕(#eef4f8)이 띠처럼 비쳤다 —
   바탕을 흰색으로 바꿔 띠를 없애고, flex gap 20px 도 8px 로 좁힌다(「색깔 없에고 간격좁혀주세요」). */
.top3-card .blood_list{ background:#fff; gap:8px; }
.wk-fullbleed{ padding-top:14px; }  /* [2026-08-18] gap 8px + 14px: 가이드 점선박스와 차트 제목 사이 숨통 */
/* 파란 섹션 머리띠(기획 모양) + 점선 분석 박스 + 코칭 본문 */
.wk-sechead { margin: 12px 0 8px; padding: 6px 10px; background: #8ca6db; color: #fff;
  border-radius: 6px; font-size: 14px; font-weight: 800; }
.wk-dashbox { border: 1.5px dashed #4a6fb5; border-radius: 8px; padding: 10px 12px; background: #fff; }
/* [2026-08-16] 가이드 본문 확대 요청 13.5 → 15px */
.wk-intro { font-size: 15px; line-height: 1.8; color: #37475a; padding: 2px 4px; }
.wk-coach-label { margin-top: 8px; padding: 2px 4px; font-size: 15px; font-weight: 800; color: #2d303f; }
.wk-coach { font-size: 15px; line-height: 1.8; color: #37475a; padding: 2px 4px; }
.wk-coach ul { margin: 6px 0 0; padding-left: 18px; }
.wk-basis { display: block; margin-top: 6px; padding: 0 4px; color: #8a98a8; font-size: 11.5px; }

/* 참조링크 카드 — 컴팩트 + 헤더 클릭 접기/펼치기 */
.refcard { padding: 10px 16px; }
.refcard-head {
  display: flex; align-items: center; justify-content: space-between;
  cursor: pointer; user-select: none;
}
.refcard-title { margin: 0; font-size: 16px; font-weight: 700; color: #3b6fd4; }
.refcard-caret { font-size: 18px; color: #888; transition: transform .2s; }
.refcard.collapsed .refcard-caret { transform: rotate(-90deg); }
.refcard-body {
  margin-top: 6px; font-size: 14px; line-height: 1.7; color: #333;
}
.refcard-item { display: block; text-align: left; margin-bottom: 4px; }
.refcard-item:last-child { margin-bottom: 0; }
.refcard-body a { color: #1a6fd0; text-decoration: none; }
.refcard-body a:hover { text-decoration: underline; }
.refcard.collapsed .refcard-body { display: none; }

/* 헤더 — `margin-left: -18` (단위 없음) 이 쿼크 모드에서 먹혀
   '음식종류/운동종류' 열만 18px 왼쪽으로 밀려 '순위' 와 겹쳤다. 제거. */
.grid-header span:nth-child(2) {
  text-align: left;
  margin-left: 0;
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
  gap: 8px;
  margin-left: 0;          /* 음수 마진 제거 — 좌우가 어긋났다 */
  width: 100%;
  justify-content: space-between;   /* 화살표를 양 끝으로, 날짜는 남는 폭을 나눠 씀 */
}

/* TAR / TBR / CV 설명줄 — 인라인 12px 대신 클래스로 관리. 카드 폭을 끝까지 쓰고 필요하면 줄바꿈 */
.row_item.metric-note {
  display: block;
}
.row_item.metric-note label {
  display: block;
  width: 100%;
  /* 15px 에서는 한 줄에 322px 이 필요한데 카드 안쪽은 305px 뿐이라 두 줄로 접혔다.
     13px + 자간 축소로 한 줄에 들어가게 한다. */
  font-size: 13px;
  letter-spacing: -0.2px;
  line-height: 1.6;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.date-range button {
  background: none;
  border: none;
  font-size: 16px;         /* 화살표 약간 키움 */
  padding: 0 3px;          /* 간격 약간 줄임 */
  cursor: pointer;
  color: #555;
  letter-spacing: -0.3px;  /* 글자 간격 살짝 좁힘 */

  /* common.css 의 `.btn { width: 100%; height: 10.56vw }` 가 화살표 버튼을 부풀려
     날짜 입력이 12px 로 찌그러졌다. 화살표는 내용 크기만 차지하게 되돌린다. */
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
  flex: 1;                 /* 남는 폭을 두 날짜가 나눠 가짐 */
  min-width: 0;
  width: auto;
  padding: 6px 5px;        /* 내부 여백 */

  /* ★16px 미만 금지 — iOS Safari 는 폰트가 16px 보다 작은 입력칸을 탭하면 화면을 자동 확대하고,
     포커스가 빠져도 원래 배율로 되돌리지 않는다. 종전 13px 이 딱 이 증상이었다.
     ⚠이 값은 '읽기 편하라고' 키운 게 아니라 확대를 막는 하한선이다. 되돌리면 증상이 그대로 재발한다.
     칸을 작게 보이려면 글자가 아니라 height/padding 으로 줄인다.
     (foodMain.jsp · exerMain.jsp 의 .date-input 도 같은 이유로 16px 로 못박았다) */
  font-size: 16px;
  font-weight: 400;
  text-align: center;
  border: 1px solid #ccc;
  border-radius: 6px;
  color: #333;
  background-color: #fff;
  letter-spacing: -0.4px;  /* 글자 밀도 조정 */
}

/* [360px 대응] 위에서 13px → 16px 로 올리면 이 화면만 한 줄에 안 들어간다.
   이 화면은 날짜칸이 **두 개**(시작·종료)라 Exercise/Food_Consult(한 개, max-width 220px)와 사정이 다르다.
   360px 실측(카드 안쪽 폭 324px) — 조정 전에는 두 칸이 각각 136px 을 요구하는데 119px 만 받아
   날짜 글자가 잘렸다(합계 357px 필요 / 324px 가용 = 33px 초과).
   flex:1 + min-width:0 이라 줄이 넘치지는 않고 '조용히 잘리기만' 해서 더 알아채기 어렵다.
   세 군데(gap ↓ / 아래 .tilde 여백 제거 / 달력 아이콘 숨김)로 33px 을 회수한다
   → 360px 실측 결과 필요 299.4px / 가용 324px, 여유 +24.6px, 잘림 없음. */
.date-range {
  gap: 4px;                /* 8px → 4px. 칸이 5개라 gap 이 4군데(32px)나 든다 */
}

/* [안드로이드 큰글씨 대응] 시스템/크롬의 '글자 크게' 설정은 px 글자까지 부풀린다(텍스트 자동 확대).
   이 행은 360px 실측 여유가 +24.6px 뿐이라 조금만 부풀려도 날짜가 잘린다(두 칸 합계로 배율 20%면 +44px).
   iOS 확대 버그 때문에 16px 밑으로 내릴 수 없으므로 이 행만 자동 확대에서 제외한다. */
.date-range,
.date-range input[type="date"],
.date-range button,
.date-range .tilde {
  -webkit-text-size-adjust: 100%;
  text-size-adjust: 100%;
}
.date-range input[type="date"]::-webkit-calendar-picker-indicator {
  /* 달력 아이콘 숨김 — 한 칸당 약 16px 을 먹는데, 이 두 칸은 readonly 라 눌러도 피커가 열리지 않고
     기간 이동은 좌우 ◀/▶ 버튼이 전담한다. 즉 여기서는 장식일 뿐이다.
     아이콘을 남기면 여유가 2.6px 밖에 안 남아 기기 폰트 차이만으로 다시 잘린다(실측). */
  display: none;
}
/* ★[2026-08-18] 실기기(삼성 계열)에서 여전히 「2026. 08. 1」로 끝자리가 잘렸다.
   위의 indicator 숨김은 크롬용이고, 삼성 브라우저·구형 WebView 는 **드롭다운 ∨ 를 따로 그려**
   한 칸당 ~20px 을 계속 먹는다. appearance 자체를 꺼야 그 장식이 사라진다(값 표시는 그대로).
   내부 좌우 패딩도 5→2px 로 줄여 큰글씨 배율에서도 날짜 열 자리가 다 나오게 한다. */
.date-range input[type="date"] {
  appearance: none;
  -webkit-appearance: none;
  padding-left: 2px;
  padding-right: 2px;
}

.date-range .tilde {
  /* [360px 대응] 0 5px → 0. 이 화면의 .tilde 는 <span class="tilde"></span> 로 **내용이 비어 있어**
     폭 0 인데 좌우 여백 10px 만 차지하고 있었다. 위 16px 상향분을 메우는 데 그 10px 을 쓴다.
     (여기서 지정해야 한다 — 위쪽에 같은 특이도로 먼저 써 봐야 이 블록이 뒤에 있어 덮인다) */
  margin: 0;
  font-size: 17px;
  font-weight: 600;
  color: #444;
  letter-spacing: -0.5px;  /* ~ 기호 간격도 줄임 */
}

/* 브라우저 기본 캘린더 아이콘 정렬 조정 */
input[type="date"]::-webkit-calendar-picker-indicator {
  margin-left: -4px;
  transform: scale(1.2);  /* 아이콘 크기 살짝 키움 */
}

/* [AI 분석 리포트] 접힘/펼침
   예전에는 기본이 `display:none` 인데 `.show` 가 opacity/max-height 만 바꿔서
   버튼 텍스트만 '닫기' 로 변할 뿐 카드는 계속 display:none 이라 내용이 영영 안 보였다.
   (display 는 transition 대상도 아니라 애니메이션에도 쓸모가 없었다.)
   `.show` 에서 display 를 열어 준다. */
.recommendation-card {
  display: none;
}
.recommendation-card.show {
  display: block;
  opacity: 1;
  max-height: none;
  overflow: visible;
}
#showRecommendationBtn {
  font-size: 16px;           /* 글자 크게 */
  font-weight: 500;          /* 굵게 */
  padding: 14px 30px;
  border: none;
  border-radius: 10px;
  background: linear-gradient(135deg, #007BFF, #00C6FF); /* 파랑~하늘색 그라데이션 */
  color: white;
  cursor: pointer;
  display: inline-flex;       /* 아이콘 + 텍스트 정렬 */
  align-items: center;
  justify-content: center;
  gap: 8px;                   /* 아이콘과 글자 간격 */
  box-shadow: 0 4px 10px rgba(0,0,0,0.2);
  transition: 0.3s;
}

#showRecommendationBtn:hover {
  background: linear-gradient(135deg, #0056b3, #0094FF);
  transform: scale(1.05);
}

/* ═══════════════ 혈당 Q&A 채팅 (sejong-web patient_main 포팅) ═══════════════ */
.qa-card { display:flex; flex-direction:column; }
.qa-head { display:flex; justify-content:space-between; align-items:center; margin-bottom:8px; }
.qa-head h5 { font-size:17px; margin:0; }
.qa-clear { border:none; background:none; color:#888; font-size:13px; cursor:pointer; padding:0; }
.qa-messages {
  height:275px; overflow-y:auto; display:flex; flex-direction:column; gap:6px;
  padding:8px; background:#f8f9fa; border-radius:8px; margin-bottom:8px;
}
/* [2026-07-31 기획 7] AI 챗봇 = 전체화면 오버레이 (연관분석 본문에서 제외, 메인 [AI 챗봇]→?chat=1 로 진입) */
/* ★[2026-07-31 방식 변경] fixed 오버레이 → '화면 전환'(문서 흐름 그대로)
   fixed + height(100%/100dvh/좌표)는 기기·프레임마다 실제 높이가 달라 하단이 잘리거나 빈 띠가 생겼다.
   연속혈당 1↔2페이지 전환과 같은 방식으로, 챗봇을 열면 이 화면의 다른 카드만 감추고 챗봇 블록을 보인다.
   → 하단 메뉴(footerNav)는 원래 문서 흐름대로 그대로 보이고, 높이 계산이 아예 필요 없다. */
.chat-overlay{ display:none; background:#fff; flex-direction:column; padding:6px 12px 8px; }
.chat-overlay.on{ display:flex; }   /* (기존 .on 규칙과 동일 — 화면 전환 방식에서도 flex 유지) */
/* ★[2026-08-05] 제목줄('🤖 AI 챗봇')이 '고장난 것처럼 일부만 보이던' 진짜 원인 —
   이 화면은 위쪽 .main-content 에 `margin-top:-60px` 이 걸려 있고(33행), 본문 첫 카드는
   인라인 `margin-top:40px` 으로 그걸 각자 상쇄한다. 챗봇 블록만 상쇄가 없어 위쪽 약 35px 이
   position:fixed 헤더(높이 12.04vwu ≒ 47px) 밑에 깔려 잘렸다. 스크롤과는 무관한 문제다.
   → 같은 방식으로 이 블록에도 상단 여백을 되돌려 준다.
   [2026-08-05 3차] 챗봇 블록에 margin 을 더해 '위치'만 맞추면, 본문 상자 자체는 여전히 60px 만큼
   화면 아래로 삐져나간다. PC 프레임은 .wrap 이 overflow:hidden 인 고정 높이라 티가 안 났지만,
   모바일에서는 그 60px 이 화면 밖으로 나가 대화영역이 안에서 스크롤되지 않고 아래로 계속 흘렀다
   ('새 답변이 계속 밑으로 가서 끌어올려야 한다' — PC 는 되고 모바일만 안 되던 이유).
   → 챗봇이 열려 있는 동안에는 -60px 자체를 무효화하고, 고정 헤더 높이(12.04vwu)만큼만 위 여백을 준다. */
.main-content.chat-on{
  margin-top: 0 !important;
  padding-top: calc(12.04 * var(--vwu, 1vw) + 10px) !important;   /* 고정 헤더 높이 + 여백 10px */
  padding-bottom: 6px !important;                                  /* 아래는 하단 메뉴에 바짝 */
  /* 챗봇 블록이 남는 높이를 받으려면 부모가 확실히 'flex 세로 배치'여야 한다.
     (다른 규칙에 밀려 block 이 되면 블록이 내용 높이로만 잡혀 아래가 텅 빈다 — 2026-08-05 실제 발생) */
  display: flex !important;
  flex-direction: column !important;
  align-items: stretch !important;
  justify-content: flex-start !important;
}
/* 위 보정으로 블록 자체가 제자리에 오므로 챗봇 블록의 추가 여백은 필요 없다 */
.chat-overlay.on{ margin-top: 0; }
/* 모바일 전용 — 주소창이 접혔다 펴지면 100%(=레이아웃 뷰포트)가 실제 보이는 높이보다 커서
   아래가 화면 밖으로 밀린다. 챗봇이 열린 동안만 '실제 보이는 높이'(dvh)로 고정한다. */
@media (max-width: 599px){
  @supports (height: 100dvh){
    .wrap.chat-open{ height: 100dvh; min-height: 0; }
  }
}
/* 챗봇만 남으면 아래가 짧아 회색 배경이 드러난다 → 그 영역까지 흰색으로 이어 붙여 카드처럼 보이게 (2026-07-31) */
.contents.chat-on{ background:#fff; }
.chat-overlay.on{ display:flex; }
/* 제목줄은 문서 흐름 그대로 둔다. (sticky 로 띄우면 대화 첫 말풍선 위를 덮어 겹쳐 보인다 — 2026-08-05 시도 후 철회) */
.chat-ovhead{ display:flex; align-items:center; gap:8px; padding:4px 2px 8px; border-bottom:1px solid #e3e9f2; margin-bottom:8px;
  background:#fff; }
/* 휴대폰(좁은 폭)에서 제목이 길면 [전체 삭제]가 화면 밖으로 밀림 → 제목은 말줄임, 버튼은 고정(2026-07-31) */
.chat-ovhead h5{ flex:1 1 auto; min-width:0; margin:0; font-size:16px;
  white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.chat-ovhead .qa-clear{ flex:0 0 auto; white-space:nowrap; }
.chat-back{ border:0; background:none; font-size:19px; color:#2b6fff; cursor:pointer; padding:2px 6px; }
/* ★[2026-08-05 최종] 대화영역 높이를 JS 로 재지 않는다.
   comm_blood.css 의 `.main-content{ display:flex; flex-direction:column; flex:1 }` 덕분에
   본문은 이미 '남는 높이를 차지하는 flex 컬럼'이고, PC·모바일 모두 그 안에서만 스크롤된다.
   → 챗봇 블록이 그 남는 높이를 그대로 받고(flex:1), 대화영역이 다시 남는 높이를 채우게(flex:1) 하면
     기기·프레임과 무관하게 항상 맞는다. 종전의 실측(_chatFill)은 프레임마다 어긋나 폐기. */
   ※ flex-basis 는 반드시 0 (`flex:1 1 0`). auto 로 두면 기준 크기가 '내용 높이'라
     대화가 길어질수록 영역이 같이 커져서, 안에서 스크롤되지 않고 입력창·질문칩이 화면 밖으로
     밀려난다(2026-08-05 '새 답변이 계속 밑으로 가서 끌어올려야 한다'는 지적의 원인).
     0 으로 두면 영역 크기가 '남는 높이'로 고정되고 내용은 그 안에서만 스크롤된다. */
.chat-overlay.on{ flex:1 1 0; min-height:0; }
.chat-overlay .qa-messages{ flex:1 1 0; height:auto; min-height:120px; overflow-y:auto; -webkit-overflow-scrolling:touch; }
.chat-overlay .chat-bottom{ flex:0 0 auto; }
.chat-overlay .qa-trash{ background:#eef2f7 !important; color:#5b6b80 !important; }
.chat-overlay .qa-input, .chat-overlay .qa-quick{ flex:0 0 auto; }
/* ★질문 칩 = 줄바꿈으로 전부 표시(2026-07-31 최종)
   가로 한 줄 스크롤은 옆으로 미는 조작이 불편하다는 지적 → 여러 줄로 모두 보이게. 스크롤 필요 없음.
   (대화 영역을 200px 로 줄여 확보한 공간에 들어간다) */
.chat-overlay .qa-quick{ display:flex; flex-wrap:wrap; max-height:none; overflow:visible; gap:6px; }
.chat-overlay .qa-quick .qbtn{ flex:0 0 auto; font-size:12px; padding:5px 10px; white-space:nowrap; }
.qa-input { display:flex; gap:6px; margin-bottom:8px; }
/* common.css 의 `.btn{width:100%}` 회피를 위해 btn 클래스는 쓰지 않음 */
.qa-input input {
  flex:1; min-width:0; padding:8px 10px; border:1px solid #ccc;
  border-radius:8px; font-size:14px; color:#333; background:#fff;
  transition:padding .15s ease, font-size .15s ease, box-shadow .15s ease;
}
/* 입력(포커스)할 때만 입력창을 크게 — 평소엔 원래 크기 유지 */
.qa-input input:focus {
  padding:13px 14px; font-size:16px; outline:none;
  border-color:#0d6efd; box-shadow:0 0 0 2px rgba(13,110,253,.15);
}
.qa-send {
  flex:0 0 auto; padding:8px 16px; border:none; border-radius:8px;
  background:#0d6efd; color:#fff; font-size:14px; cursor:pointer;
}
.qa-quick { display:flex; flex-wrap:wrap; gap:6px; }
.qbtn { font-size:13px; padding:3px 10px; border-radius:10px; cursor:pointer; border:1px solid #ccc; background:#fff; color:#555; }
/* [2026-08-05] 방금 누른 질문칩 — 다시 눌러도 동작하지 않는다는 것을 눈으로 알 수 있게 흐리게 */
.qa-quick .qbtn.used { background:#f1f4f8; border-color:#dde3ea; color:#9aa6b4; cursor:default; }
.chat-user { position:relative; background:#0d6efd; color:#fff; border-radius:14px 14px 0 14px; padding:9px 13px; align-self:flex-end; max-width:88%; font-size:15px; line-height:1.5; word-break:break-word; }
.chat-bot  { position:relative; background:#fff; color:#222; border:1px solid #dee2e6; border-radius:14px 14px 14px 0; padding:9px 13px; align-self:flex-start; max-width:92%; font-size:15px; line-height:1.5; word-break:break-word; }
/* [2026-08-13] AI 응답 대기 진행바 — 종전 「…」 한 글자는 멈춘 것처럼 보였다.
   .cp-bar 의 width 는 JS 가 90% 까지 점근시키고, 응답이 오면 100% 로 닫는다. */
.chat-progress { min-width:180px; }
.chat-progress .cp-label { font-size:12px; color:#6b7c86; margin-bottom:5px; }
/* [2026-08-13] 「일반적인 진행바」 — 부트스트랩식 파란 줄무늬 바(굵기 10px, 줄무늬가 흐른다) */
.chat-progress .cp-track { height:10px; border-radius:6px; background:#e9ecef; overflow:hidden; }
.chat-progress .cp-bar   { height:100%; width:0; border-radius:6px;
  background-color:#0d6efd; transition:width .18s ease;
  background-image:linear-gradient(45deg,rgba(255,255,255,.25) 25%,transparent 25%,transparent 50%,rgba(255,255,255,.25) 50%,rgba(255,255,255,.25) 75%,transparent 75%,transparent);
  background-size:16px 16px; animation:cpStripe .8s linear infinite; }
@keyframes cpStripe { 0%{background-position:16px 0} 100%{background-position:0 0} }
@media (prefers-reduced-motion: reduce) { .chat-progress .cp-bar { animation:none; } }
.chat-del  { position:absolute; top:-7px; right:-7px; width:20px; height:20px; line-height:18px; text-align:center; border:none; border-radius:50%; background:#dc3545; color:#fff; font-size:13px; cursor:pointer; padding:0; opacity:0.45; transition:opacity .15s; box-shadow:0 1px 2px rgba(0,0,0,0.3); }
.chat-user:hover .chat-del, .chat-bot:hover .chat-del { opacity:1; }
.chat-intro { max-width:100% !important; align-self:stretch !important; font-size:13.5px !important; }
/* ★[2026-08-20 요청 「우측 공간 위하고 맞추어 주세요」] 처음 뜨는 **지표 분석** 말풍선을
   인사말과 **같은 폭**으로 — 보통 답변(.chat-bot 92%)이라 오른쪽이 남아 위 인사말과 어긋나 보였다.
   ⚠글자 크기는 건드리지 않는다(.chat-intro 는 13.5px 로 줄이는데, 분석은 본문 크기를 유지해야 읽힌다).
   ⚠주고받는 답변에는 붙이지 않는다 — 대화는 말풍선이 내용만큼만 차지하는 편이 자연스럽다. */
.chat-wide { max-width:100% !important; align-self:stretch !important; }

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
	  <%-- [2026-07-31 기획] 헤더 = '현재일 기준 이전 일주일' (주간 기준임을 명시) --%>
		<section class="blood_list">
		  <div class="unit flx-row a-center j-between">
		    <span class="ft14" style="font-weight:700; color:#2d303f;">현재일 기준 이전 일주일</span>
		    <span class="ft14">단위 : mg/dL</span>
		  </div>
		
		  <div class="top_row flx-row j-between a-center">
		    <div class="center_wrap aval_wrap">
		      <h6>평균 혈당</h6>
		      <div class="bl_color_low ft40" id="avgUpt" data-value="-">-</div>
		    </div>
		    <div class="line_col" style="height: calc(10 * var(--vwu, 1vw));"></div>
		    <div class="center_wrap aval_wrap">
		      <h6>공복 평균</h6>
		      <div class="bl_color_low ft40" id="avgFastingBlood" data-value="-">-</div>
		    </div>
		    <div class="line_col" style="height: calc(10 * var(--vwu, 1vw));"></div>
		    <div class="center_wrap aval_wrap">
		      <h6>식후 평균</h6>
		      <div class="bl_color_high ft40" id="after2hBlood" data-value="-">-</div>
		    </div>
		  </div>
		
		  <%-- [2026-07-31 기획] 앞장(연속혈당 상세 2페이지)과 동일한 표현식 —
		       GMI(참고치·색 조건 없음) + TIR/TAR/TBR/CV(권장 기준 문구 + 목표 안=초록/벗어남=황토).
		       값 채우기는 기존 스크립트 그대로(#gmi/#tir/#tar/#tbr/#cv) — 색·AI 분석은 하단 감시 스크립트(wkAi)가 처리.
		       종전의 GMI/TIR 큰 패널과 별도 TAR/TBR/CV 카드는 이 목록으로 통합(중복 제거). --%>
		  <section class="p2list">
		    <div class="p2item"><p class="lb">GMI지수(%) <span class="hint">혈당 관리지표(참고사항)</span></p>
		      <div class="v"><span id="gmi" data-value="-">-</span></div></div>
		    <div class="p2item"><p class="lb">목표혈당 유지시간(TIR) <span class="hint">권장 : 70% 이상</span></p>
		      <div class="v"><span id="tir" data-value="-">-</span></div></div>
		    <div class="p2item"><p class="lb">고혈당 시간(TAR) <span class="hint">권장 : 25% 미만</span></p>
		      <div class="v"><span id="tar" data-value="-">-</span></div></div>
		    <div class="p2item"><p class="lb">저혈당 시간(TBR) <span class="hint">권장 : 4% 미만</span></p>
		      <div class="v"><span id="tbr" data-value="-">-</span></div></div>
		    <div class="p2item"><p class="lb">혈당변동성(CV) <span class="hint">권장 : 36% 이하</span></p>
		      <div class="v"><span id="cv" data-value="-">-</span></div></div>
		  </section>
		<%-- [2026-08-16] '* 혈당지표 분석'과 '* 생활습관 코칭' 두 머리띠가 별개 점검항목처럼 보인다는
		     지적으로 헤더 하나('혈당지표 분석 기반 생활습관 가이드')로 통합.
		     내용 = 챗봇 첫 인사의 지표 분석(TIR·TAR·TBR — _chatIntroAnalysis 와 같은 문장) + AI 코칭.
		     #wkCoach 는 챗봇(_chatIntroAnalysis·_chatStatusSummary)이 innerHTML 을 그대로 가져다 쓰므로
		     id 와 내용 구조를 바꾸면 안 된다. --%>
		<div class="wk-ai">
		  <h5 class="wk-sechead">* 혈당지표 분석 기반 생활습관 가이드</h5>
		  <div class="wk-dashbox">
		    <div id="wkIntro" class="wk-intro">지표 수치를 불러오면 분석이 표시됩니다.</div>
		    <div class="wk-coach-label">AI 코칭</div>
		    <div id="wkCoach" class="wk-coach">지표 수치를 불러오면 코칭 내용이 표시됩니다.</div>
		    <small class="wk-basis">※ 대한당뇨병학회 관리지표 기준</small>
		  </div>
		</div>
    <%-- [2026-08-18] 전면폭 묶음 — 제목·기간버튼·차트·범례를 한 덩이로 감싸 좌우 쫙 펴지게 --%>
    <div class="wk-fullbleed">
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
    </div><%-- /.wk-fullbleed --%>
  </div>
   <%-- [2026-07-31 기획] 별도 TAR/TBR/CV 카드 제거 — #tar/#tbr/#cv 는 위 '주간 혈당관리지표' 목록으로 이동
        (같은 id 를 두 곳에 둘 수 없어 이 카드는 통째로 제거. 설명문구는 목록의 '권장 :' 힌트로 대체) --%>
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

  <%-- [2026-07-31 기획] [개인 맞춤 추천] 주간 리포트 블록 숨김(X 표시) — 문장은 상단 'AI 분석(5개 지표 기준)'으로 대체.
       안의 id 들(avgUpt1_name 등)은 기존 스크립트가 채우므로 요소는 남기고 숨김(원복 대비). --%>
  <div class="recommendation-card" style="display:none;">

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
	<%-- [2026-07-31 기획 7. AI 챗봇] 혈당 Q&A 를 연관분석 본문에서 제외하고 전체화면 오버레이로 이동.
	     메인 [AI 챗봇] 버튼 → goBloodPage2.do?chat=1 로 진입하면 바로 열린다(주간 지표는 이 화면 스크립트가 그대로 계산).
	     처음 열릴 때 인사말 하단에 TIR·TAR·TBR 분석 내용 표시(지표가 늦게 오면 도착 시 1회 추가 — wkAi 연동). --%>
	<div id="chatOverlay" class="chat-overlay">
	  <%-- ★제목줄(< 🤖 AI 챗봇) 제거 (2026-08-20 요청) — 상단 공통 헤더가 'AI 챗봇'(컨트롤러 menuName,
	       ?chat=1 분기)을 보여 주므로 여기 또 있으면 제목이 두 줄이었다.
	       나가기 = 상단 공통 뒤로가기(btnPrev → history.back → 메인). closeChat() 은 남겨 둔다(호출부만 없음). --%>
	  <div id="chatMessages" class="qa-messages"></div>
	  <%-- [2026-07-31] 입력줄+질문칩을 한 덩어리로 묶어 화면 하단에 고정(sticky).
	       높이를 계산하지 않아도 어떤 기기에서나 항상 보인다 — 대화가 길어지면 위쪽만 스크롤된다. --%>
	  <div class="chat-bottom">
	  <div class="qa-input">
	    <input type="text" id="chatInput" placeholder="질문을 입력하세요…" onkeypress="if(event.key==='Enter')sendChat();">
	    <button type="button" class="qa-send" onclick="sendChat();">전송</button>
	    <%-- 전체 삭제 🗑 버튼은 2026-08-13 사용자 요청으로 제거(개별 말풍선 × 삭제는 유지).
	         복원 시: <button type="button" class="qa-send qa-trash" onclick="_clearChat();">🗑</button> --%>
	  </div>
	  <%-- [2026-08-05 검토회의] 질문 칩 13개 → 6개.
	       "아래 질문 버튼이 너무 많습니다 / 위 6개로 처리하는게 좋을 듯 합니다" 요청 반영.
	       나머지 지표(TIR·TAR·TBR·CV·GMI·발생구간)는 직접 입력하면 _chatResponse 가 그대로 답한다. --%>
	  <div class="qa-quick">
	    <button type="button" class="qbtn" onclick="_quickQ('주간 평균혈당 어때요?', this)">주간평균혈당</button>
	    <button type="button" class="qbtn" onclick="_quickQ('공복 평균혈당 어때요?', this)">공복평균혈당</button>
	    <button type="button" class="qbtn" onclick="_quickQ('주간 최고혈당 알려줘', this)">주간 최고혈당</button>
	    <button type="button" class="qbtn" onclick="_quickQ('주간 최저혈당 알려줘', this)">주간 최저혈당</button>
	    <button type="button" class="qbtn" onclick="_quickQ('음식 추천해줘', this)">음식추천</button>
	    <button type="button" class="qbtn" onclick="_quickQ('운동 추천해줘', this)">운동추천</button>
	  </div>
	  </div><%-- /.chat-bottom --%>
	</div>

	<script>
	/* [2026-07-31 기획 — wkAi] 지표 값 색(권장 기준: 목표 안=초록/벗어남=황토, GMI는 참고치라 무조건)
	   + 'AI 분석(5개 지표 기준)' 문장 자동 생성. 값은 기존 스크립트가 #gmi/#tir/#tar/#tbr/#cv 에 채우므로
	   그 변화를 감시(MutationObserver)해 색과 문장을 갱신한다 — 기존 계산 로직 무변경. */
	(function(){
	  var OK='#2e7d32', WARN='#e67e22', PLAIN='#2d303f';
	  function num(id){ var e=document.getElementById(id); if(!e) return NaN;
	    return parseFloat(String(e.textContent).replace(/[^0-9.\-]/g,'')); }
	  function paint(id, ok){ var e=document.getElementById(id); if(e && !isNaN(num(id))) e.style.color = ok?OK:WARN; }
	  function upd(){
	    var gmi=num('gmi'), tir=num('tir'), tar=num('tar'), tbr=num('tbr'), cv=num('cv');
	    var g=document.getElementById('gmi'); if(g) g.style.color=PLAIN;   // GMI = 참고치(색 조건 없음)
	    paint('tir', tir>=70); paint('tar', tar<25); paint('tbr', tbr<4); paint('cv', cv<=36);
	    // 평균 3종 색 — 평균 70~180 / 공복 100 미만 / 식후 140 미만이면 초록, 벗어나면 황토(기획 색 예시와 일치)
	    var avg=num('avgUpt'), fast=num('avgFastingBlood'), after=num('after2hBlood');
	    paint('avgUpt', avg>=70 && avg<=180); paint('avgFastingBlood', fast>=70 && fast<100); paint('after2hBlood', after>=70 && after<140);

	    // ── 통합 가이드 ①: 지표 분석 — 챗봇 첫 인사(_chatIntroAnalysis)와 같은 문장을 화면에도 뿌린다 ──
	    var intro=document.getElementById('wkIntro');
	    if(intro && !(isNaN(tir) && isNaN(tar) && isNaN(tbr))){
	      var ln=function(s){ return "<span style='display:block; word-break:keep-all;'>"+s+"</span>"; };
	      var L=[ln('최근 일주일 지표 분석입니다.')];
	      if(!isNaN(tir)) L.push(ln("• TIR(목표유지) <b>"+tir+"%</b> — 권장 70%↑ "+(tir>=70?'충족&nbsp;👍':"<b style='color:"+WARN+"'>미달</b>")));
	      if(!isNaN(tar)) L.push(ln("• TAR(고혈당) <b>"+tar+"%</b> — 권장 25%↓ "+(tar<25?'충족':"<b style='color:"+WARN+"'>초과</b>")));
	      if(!isNaN(tbr)) L.push(ln("• TBR(저혈당) <b>"+tbr+"%</b> — 권장 4%↓ "+(tbr<4?'충족':"<b style='color:"+WARN+"'>초과</b>")));
	      intro.innerHTML = L.join('');
	    }

	    // ── 통합 가이드 ②: AI 코칭 (가장 두드러진 문제 기준 문구 + 실천 항목) ──
	    var box=document.getElementById('wkCoach');
	    if(box && !isNaN(tir)){
	      var head='', tips=[];
	      if(!isNaN(tar) && tar>=25){
	        head='지난 일주일 동안 고혈당 시간이 다소 길었습니다.<br>특히 식후 혈당 상승이 반복되는 것으로 보입니다.';
	        tips=['식사량을 줄이세요.','탄수화물 비율을 줄이세요.','식후 20~30분 걷기를 실천해 보세요.'];
	      }else if(!isNaN(tbr) && tbr>=4){
	        head='지난 일주일 동안 저혈당이 발생했습니다.<br>저혈당은 즉각적인 대처가 필요합니다.';
	        tips=['공복 상태의 운동을 피하세요.','식사를 거르지 말고 규칙적으로 하세요.','저혈당 증상이 느껴지면 즉시 당분을 섭취하세요.'];
	      }else if(!isNaN(cv) && cv>36){
	        head='지난 일주일 동안 혈당 변동 폭이 큰 편이었습니다.';
	        tips=['식사 시간을 규칙적으로 유지하세요.','과식과 결식을 피하세요.','가벼운 활동을 꾸준히 이어가세요.'];
	      }else{
	        head='지난 일주일 혈당이 안정적으로 관리되고 있습니다.';
	        tips=['현재 생활습관을 그대로 유지하세요.','꾸준한 측정과 기록을 계속해 주세요.'];
	      }
	      box.innerHTML = head + '<ul>' + tips.map(function(s){ return '<li>'+s+'</li>'; }).join('') + '</ul>';
	    }
	    // [기획 7] 챗봇이 열려 있고 아직 인사 분석을 못 붙였으면 지표 도착 시 1회 게시
	    if (window._chatIntroHook) try{ window._chatIntroHook(); }catch(e){}
	  }
	  ['gmi','tir','tar','tbr','cv','avgUpt','avgFastingBlood','after2hBlood'].forEach(function(id){
	    var e=document.getElementById(id); if(!e) return;
	    new MutationObserver(upd).observe(e, { childList:true, characterData:true, subtree:true });
	  });
	  upd();
	})();
	</script>

	<!-- 참조링크 (헤더 클릭으로 접기/펼치기, 컴팩트) — 맨 아래 -->
	<div class="top3-card decrease-card refcard" id="refCard">
	    <div class="refcard-head" onclick="_toggleRef()">
	        <h3 class="refcard-title">[참조링크]</h3>
	        <span class="refcard-caret" id="refCaret" aria-hidden="true">▾</span>
	    </div>
	    <div class="refcard-body" id="refBody">
	        <span class="refcard-item">💡 <a href="https://www.diabetes.or.kr/" target="_blank">대한당뇨병학회 바로가기</a></span>
	        <span class="refcard-item">💡 <a href="https://www.youtube.com/channel/UCsVB1GWF-NH-RTxJax8XA_Q/featured?view_as=subscriber" target="_blank">당뇨병의정석 (YouTube)</a></span>
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

  // 지정한 종료일 기준 N일 범위 (종료일 포함, 시작일은 N-1일 전)
  function computeRangeEndingAt(end, days){
    const e = new Date(end.getFullYear(), end.getMonth(), end.getDate());
    const start = new Date(e);
    if (days > 0) start.setDate(start.getDate() - (days - 1));
    return { start, end: e };
  }

  // [2026-07-11] 데이터가 있는 마지막 측정일(연/월/일)을 동기 조회. 없으면 null → 오늘 기준 폴백.
  //   연속혈당(FAHR_00) 화면의 adjustToLastDataDate() 와 동일한 /getLastBloodDate.do 재사용.
  function _getLastDataDate(){
    const uid = (userId && userId !== "null") ? userId : "";
    if (!uid) return null;
    let result = null;
    try {
      CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/getLastBloodDate.do", "POST", { userId: uid },
        function(response){
          if (response && response.IsSucceed && response.Data){
            const last = new Date(String(response.Data)); // 'YYYY-MM-DDTHH:mm:ss'
            if (!isNaN(last.getTime())){
              result = new Date(last.getFullYear(), last.getMonth(), last.getDate());
            }
          }
        });
    } catch(e){ console.error("getLastBloodDate 오류:", e); }
    return result;
  }

  // 참조링크 카드 접기/펼치기
  function _toggleRef(){
    var c = document.getElementById('refCard');
    if(c) c.classList.toggle('collapsed');
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
            font: { weight: '700', size: 13 },
            textStrokeColor: 'rgba(0,0,0,0.65)',
            textStrokeWidth: 3,
            textShadowColor: 'rgba(0,0,0,0.5)',
            textShadowBlur: 2,
            rotation: 0,
            anchor: 'center',
            align: 'center',
            clip: false
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
      _loadWeekMinMax(formData.start, formData.end) ;   // [2026-08-05] 챗봇 '주간 최고/최저혈당' 답변용
    };

    // CSRF 메타에서 읽기 (Spring Security 사용 시)
    const csrfToken  = document.querySelector('meta[name="_csrf"]')?.content;
    const csrfHeader = document.querySelector('meta[name="_csrf_header"]')?.content;

    // jQuery 존재시 AJAX(JSON), 없으면 fetch(JSON)
    if (window.$ && $.ajax) {
      $.ajax({
        url: CommonUtil.getContextPath() + "/avgBloodlowhight.do",
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

      fetch(CommonUtil.getContextPath() + "/avgBloodlowhight.do", {
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

  /* [2026-08-05 검토회의] 챗봇 '주간 최고혈당/최저혈당' 답변용 원자료.
     종전에는 최고·최저를 물으면 답을 못 만들어 '저혈당 대처법' 같은 엉뚱한 지식답변이나
     폴백 안내가 나갔다(회의자료 슬라이드 21·22 '?'). 조회 범위가 바뀔 때마다 한 번 받아 둔다.
     원천 = 홈에서도 쓰는 /getBloodChartData.do (범위 내 측정값 목록). */
  var _wkMinMax = null;   // { max:{v,at}, min:{v,at}, from, to } — 아직 못 받았으면 null
  function _loadWeekMinMax(startYMD, endYMD){
    const uid = (userId && userId !== "null") ? userId : "";
    if(!uid) return;
    CommonUtil.callAjax(CommonUtil.getContextPath() + "/getBloodChartData.do", "POST",
      { userId: uid, start: startYMD + "T00:00:00", end: endYMD + "T23:59:59" },
      function(list){
        list = Array.isArray(list) ? list : [];
        let mx = null, mn = null;
        list.forEach(function(r){
          const v = parseInt(r.UPT, 10);
          if(isNaN(v) || v <= 0) return;
          const tm = (typeof r.DTM === 'number') ? r.DTM : new Date(String(r.DTM).replace('Z','')).getTime();
          const at = isNaN(tm) ? '' : _fmtDtm(new Date(tm));
          if(!mx || v > mx.v) mx = { v:v, at:at };
          if(!mn || v < mn.v) mn = { v:v, at:at };
        });
        _wkMinMax = (mx && mn) ? { max:mx, min:mn, from:startYMD, to:endYMD } : null;
      });
  }
  function _fmtDtm(d){
    return (d.getMonth()+1) + '월 ' + d.getDate() + '일 ' + pad2(d.getHours()) + ':' + pad2(d.getMinutes());
  }

  // ===== 디바운스 유틸 =====
  function debounce(fn, delay){
    let t;
    return (...args) => { clearTimeout(t); t = setTimeout(()=>fn(...args), delay); };
  }
  // ===== 혈당 Q&A 채팅 (sejong-web patient_main 포팅) =====
  /* [2026-08-05] 같은 질문칩을 연달아 누르면 같은 답이 계속 쌓인다 → 방금 누른 칩은 다시 눌러도 무시한다.
     (다른 질문을 한 번 하면 그 칩은 다시 사용할 수 있다.)
     답변을 기다리는 동안(_chatBusy)에도 중복 전송을 막는다. */
  var _lastQuickQ = '', _chatBusy = false;
  var _chatLLMFollow = false;   // [2026-08-13] 수치 즉답 뒤 LLM 가이드를 이어붙일지 (_chatResponse 가 판단)
  function _quickQ(q, el){
    if(_chatBusy) return;
    if(q === _lastQuickQ) return;                  // 방금 누른 그 칩 → 아무 동작 없음
    _lastQuickQ = q;
    var btn = el || (window.event && window.event.currentTarget);
    try{
      document.querySelectorAll('.qa-quick .qbtn.used').forEach(function(b){ b.classList.remove('used'); });
      if(btn && btn.classList) btn.classList.add('used');
    }catch(e){}
    document.getElementById('chatInput').value = q;
    sendChat();
  }

  function _addMsg(txt, isUser, extraCls){
    var box = document.getElementById('chatMessages');
    if(!box) return;
    var msg = document.createElement('div');
    msg.className = (isUser ? 'chat-user' : 'chat-bot') + (extraCls ? (' ' + extraCls) : '');
    if (isUser) {
      // 삭제 버튼은 질문에만 — 삭제 시 바로 뒤 답변(.chat-bot)도 함께 제거
      msg.innerHTML = '<span class="chat-text">' + txt + '</span>'
                    + '<button type="button" class="chat-del" title="질문·답변 삭제">&times;</button>';
      msg.querySelector('.chat-del').addEventListener('click', function(){
        var next = msg.nextElementSibling;
        msg.remove();
        if (next && next.classList.contains('chat-bot')) next.remove();
      });
    } else {
      msg.innerHTML = '<span class="chat-text">' + txt + '</span>';
    }
    box.appendChild(msg);
    _chatScrollToEnd();
  }
  /* [2026-08-05] 새 메시지가 추가되면 항상 맨 아래(최신)로 — 이전 대화가 위로 올라간다.
     appendChild 직후 한 번만 하면 늦게 그려지는 이모지·줄바꿈 때문에 몇 px 모자라게 멈춘다.
     다음 프레임에 한 번 더 맞춘다. */
  function _chatScrollToEnd(){
    var box = document.getElementById('chatMessages');
    if(!box) return;
    box.scrollTop = box.scrollHeight;
    if(window.requestAnimationFrame){
      requestAnimationFrame(function(){ box.scrollTop = box.scrollHeight; });
    }
  }

  // 대화 전체 삭제 후 인사말만 다시 표시
  function _clearChat(){
    if (!confirm('대화 내용을 모두 지울까요?')) return;
    document.getElementById('chatMessages').innerHTML = '';
    // [2026-08-05] 대화를 비웠으면 질문칩도 처음 상태로 (다시 눌러 물어볼 수 있게)
    _lastQuickQ = ''; _chatBusy = false;
    try{ document.querySelectorAll('.qa-quick .qbtn.used').forEach(function(b){ b.classList.remove('used'); }); }catch(e){}
    _addMsg('안녕하세요! 혈당 관련 궁금한 점을 질문해 주세요.', false, 'chat-intro');
  }

  // 동일 질문 캐시: 같은 질문+같은 혈당 컨텍스트면 서버 재호출 없이 이전 답 재사용
  var _chatCache = {};
  function sendChat(){
    if (_chatBusy) return;                 // [2026-08-05] 답변 대기 중 중복 전송 차단
    var input = document.getElementById('chatInput');
    var q = (input.value || '').trim(); if(!q) return;
    input.value = '';
    // 직접 입력으로 다른 질문을 하면 질문칩 잠금 해제(같은 칩을 다시 쓸 수 있게)
    if (q !== _lastQuickQ) _lastQuickQ = '';
    _addMsg(q, true);

    // ① 로컬 키워드/데이터 즉답 (blood_qa.js 매칭 + 화면 지표 기반)
    var local = _chatResponse(q);
    if (local != null) {
      _chatBusy = true;
      setTimeout(function(){
        _addMsg(local, false); _chatBusy = false;
        /* [2026-08-13] "내 최고혈당 관련 운동, 식사 가이드"처럼 수치+가이드를 함께 물으면
           수치 즉답으로 끝내지 않고 LLM 가이드 답변을 이어붙인다(사용자 지적).
           화면의 주의음식·추천운동 TOP3 도 참고자료로 함께 넘긴다. */
        if (_chatLLMFollow) { _chatLLMFollow = false; _askLLM(q, _chatGuideCtx()); }
      }, 280);
      return;
    }
    _askLLM(q, '');
  }

  /* 화면에 이미 계산돼 있는 주의음식·추천운동 TOP3 이름만 뽑아 LLM 참고자료로 (수치는 안 보낸다) */
  function _chatGuideCtx(){
    var f = _topRows('grid-rows-food', 3).map(function(r){ return r[1]; }).filter(Boolean);
    var x = _topRows('grid-rows-exer', 3).map(function(r){ return r[1]; }).filter(Boolean);
    var p = [];
    if (f.length) p.push('이번 주 혈당을 많이 올린 주의 음식: ' + f.join(', '));
    if (x.length) p.push('앱이 추천하는 운동: ' + x.join(', '));
    return p.join(' / ');
  }

  // ②동일 질문 캐시 ③서버 LLM(Gemini) — sendChat 에서 분리(2026-08-13, 수치 즉답 뒤에도 부르기 위해)
  function _askLLM(q, extraCtx){
    // ② 동일 질문 캐시
    var _ctxText  = _chatCtxText();
    if (extraCtx) _ctxText = _ctxText ? (_ctxText + ' / ' + extraCtx) : extraCtx;
    var _cacheKey = q.toLowerCase() + '|' + _ctxText;
    if (_chatCache[_cacheKey]) {
      _chatBusy = true;
      setTimeout(function(){ _addMsg(_chatCache[_cacheKey], false); _chatBusy = false; }, 200);
      return;
    }
    _chatBusy = true;

    // ③ 매칭 실패 → 서버 LLM(Gemini) fallback. "입력 중…" 표시 후 응답으로 교체
    /* [2026-08-13] 「…」 한 글자 → **동적 진행바**. Gemini 호출은 2~5초가 걸려
       점 하나로는 멈춘 것처럼 보인다(사용자 지적). 진행바는 응답이 오면 100% 로 끝난다. */
    var box = document.getElementById('chatMessages');
    var typing = document.createElement('div');
    typing.className = 'chat-bot chat-progress';
    typing.innerHTML =
      '<div class="cp-label">AI 생각중…</div>' +
      '<div class="cp-track"><div class="cp-bar"></div></div>';
    box.appendChild(typing);
    _chatScrollToEnd();
    var _cpBar = typing.querySelector('.cp-bar'), _cpPct = 0;
    /* 응답 시간을 알 수 없으므로 **90% 까지만 점근**시킨다(가짜 100% 로 기다리게 하지 않는다).
       남는 10% 는 응답이 실제로 왔을 때 채운다. */
    var _cpTimer = setInterval(function(){
      _cpPct += Math.max(0.6, (90 - _cpPct) * 0.08);
      if (_cpPct > 90) _cpPct = 90;
      if (_cpBar) _cpBar.style.width = _cpPct.toFixed(1) + '%';
    }, 120);
    function _cpDone(cb){
      clearInterval(_cpTimer);
      if (_cpBar) _cpBar.style.width = '100%';
      setTimeout(function(){ try { typing.remove(); } catch(e){} cb(); }, 180);
    }

    $.ajax({
      url: CommonUtil.getContextPath() + '/blood/chatAsk.do',
      type: 'post',
      data: JSON.stringify({ q: q, ctx: _ctxText }),
      contentType: 'application/json',
      dataType: 'json',
      success: function(r){
        _cpDone(function(){
          if (r && r.IsSucceed && r.Data) {
            var _ans = String(r.Data);
            _chatCache[_cacheKey] = _ans;   // 성공 답변만 캐시
            _addMsg(_ans, false);
          } else {
            _addMsg(_chatFallbackMsg(), false);
          }
          _chatBusy = false;
        });
      },
      error: function(){
        _cpDone(function(){
          _addMsg(_chatFallbackMsg(), false);
          _chatBusy = false;
        });
      }
    });
  }

  // 화면에 표시된 지표 숫자만 추출 ("-" 이거나 없으면 null)
  function _metricNum(id){
    var el = document.getElementById(id);
    if(!el) return null;
    var t = (el.textContent || '').replace(/[^0-9.\-]/g, '');
    if(!t) return null;
    var n = parseFloat(t);
    return isFinite(n) ? n : null;
  }

  /* [2026-08-05] 화면의 TOP3 그리드(음식/운동)에서 앞 N행을 읽어 [순위,이름,양,변동폭] 배열로 반환.
     '자료없음' 한 칸짜리 행은 건너뛴다. */
  function _topRows(gridId, n){
    var g = document.getElementById(gridId);
    if(!g) return [];
    var out = [];
    var rows = g.querySelectorAll('.grid-row');
    for(var i=0; i<rows.length && out.length<n; i++){
      var c = rows[i].querySelectorAll('span');
      if(c.length < 4) continue;                       // '자료없음' 행
      var vals = [];
      for(var j=0; j<4; j++) vals.push((c[j].textContent||'').trim());
      if(!vals[1] || vals[1] === '-') continue;
      out.push(vals);
    }
    return out;
  }

  /* [2026-08-05 검토회의 슬라이드 19] '현재 내 혈당 상태' 한 덩어리 요약.
     화면에 이미 계산된 지표 + 'AI 분석'·'생활습관 코칭' 문장을 그대로 재사용한다(별도 계산 없음).
     지표가 하나도 없으면 null 을 반환해 호출부가 다른 처리를 하도록 한다. */
  function _chatStatusSummary(){
    var avg = _metricNum('avgUpt'), tir = _metricNum('tir'), tar = _metricNum('tar'),
        tbr = _metricNum('tbr'), cv = _metricNum('cv');
    if (avg == null && tir == null && tar == null && tbr == null) return null;

    var L = [];
    if (avg != null) L.push('• 주간 평균 <b>' + avg + ' mg/dL</b> — 권장 : 70~180');
    if (tir != null) L.push('• TIR(목표유지) <b>' + tir + '%</b> — 권장 70% 이상 ' + (tir >= 70 ? '충족' : '<b style="color:#e67e22">미달</b>'));
    if (tar != null) L.push('• TAR(고혈당) <b>' + tar + '%</b> — 권장 25% 미만 ' + (tar < 25 ? '충족' : '<b style="color:#e67e22">초과</b>'));
    if (tbr != null) L.push('• TBR(저혈당) <b>' + tbr + '%</b> — 권장 4% 미만 ' + (tbr < 4 ? '충족' : '<b style="color:#e67e22">초과</b>'));
    if (cv  != null) L.push('• CV(변동성) <b>' + cv + '%</b> — 권장 36% 이하 ' + (cv <= 36 ? '충족' : '<b style="color:#e67e22">초과</b>'));

    var head = (tir != null)
      ? ('현재 혈당 상태는 ' + (tir >= 70 ? "<b style='color:#2e7d32'>‘정상’</b>" : "<b style='color:#e67e22'>‘관리 필요’</b>") + ' 입니다.')
      : '현재 혈당 상태입니다.';

    var coach = '';
    var box = document.getElementById('wkCoach');
    if (box && box.innerHTML && box.innerHTML.indexOf('불러오면') === -1) {
      coach = '<br><b>AI 코칭</b><br>' + box.innerHTML;
    }
    return head + '<br>' + L.join('<br>') + coach
         + '<br><small>※ 대한당뇨병학회 관리지표 기준 · 참고용이며 진단이 아닙니다.</small>';
  }

  function _chatResponse(q){
    q = q.toLowerCase();
    var avg = _metricNum('avgUpt'), fasting = _metricNum('avgFastingBlood'), post = _metricNum('after2hBlood');
    var tir = _metricNum('tir'), tar = _metricNum('tar'), tbr = _metricNum('tbr'), gmi = _metricNum('gmi');
    var note = '<br><small>※ 일반 참고용이며 진단이 아닙니다. 이상 증상은 담당 의사와 상담하세요.</small>';

    // ── 데이터 의도 여부 (교과서 지식 질문 "정상범위는?" 등은 여기 안 걸리게) ──
    var _dataIntent = /(어때|어땠|어떤|어떻|얼마|몇|상태|관리|괜찮|높은가|낮은가|위험|내 |나의|우리|이번\s*주|주간)/.test(q);

    /* [2026-08-13] 수치 질문에 운동·식사·가이드 요청이 섞여 있으면(예: "내 최고혈당 관련 운동, 식사 가이드")
       아래 수치 즉답 뒤에 LLM 가이드를 이어붙이도록 표시한다. 수치 구간에서 return 될 때만 의미가 있고,
       음식추천·운동추천 구간부터는 가이드 자체가 답이므로 다시 끈다. */
    _chatLLMFollow = /(가이드|추천|조언|요령|방법|관리법|팁|어떻게|운동|식사|음식|먹)/.test(q);

    /* ── [2026-08-05 검토회의] 최고/최저 혈당 ──
       "최근 일주일간 최고 혈당은", "나의 최고혈당치는?", "최고 최저혈당은?" 처럼 물으면
       종전에는 지식DB의 '고혈당/저혈당 대처법'이 걸리거나 폴백 안내가 나갔다(슬라이드 21·22 '?').
       ※ 평균 질문보다 먼저 판정해야 한다 — "주간 최고혈당"에도 '주간'이 들어 있어 평균 규칙에 먼저 걸린다. */
    if (/(최고|최대|가장\s*높|제일\s*높|최저|최소|가장\s*낮|제일\s*낮)/.test(q) && /(혈당|수치|값)/.test(q)) {
      if (_wkMinMax == null) {
        return '최고·최저 혈당을 계산할 측정값이 아직 없습니다.<br>혈당기(CGM) 측정값이 들어오면 알려드릴게요.';
      }
      var wantHi = /(최고|최대|가장\s*높|제일\s*높)/.test(q);
      var wantLo = /(최저|최소|가장\s*낮|제일\s*낮)/.test(q);
      var mx = _wkMinMax.max, mn = _wkMinMax.min;
      var out = '조회기간(' + _wkMinMax.from + ' ~ ' + _wkMinMax.to + ') 기준입니다.<br>';
      if (wantHi) {
        out += '• 최고 혈당: <b>' + mx.v + ' mg/dL</b>' + (mx.at ? (' (' + mx.at + ')') : '')
             + '<br>&nbsp;&nbsp;권장 : 180 mg/dL 미만 — ' + (mx.v < 180 ? '충족' : '<b style="color:#e67e22">초과</b>') + '<br>';
      }
      if (wantLo) {
        out += '• 최저 혈당: <b>' + mn.v + ' mg/dL</b>' + (mn.at ? (' (' + mn.at + ')') : '')
             + '<br>&nbsp;&nbsp;권장 : 70 mg/dL 이상 — ' + (mn.v >= 70 ? '충족' : '<b style="color:#e67e22">미달</b>') + '<br>';
      }
      return out + note;
    }

    // ── 이번 주/평균 혈당 ── ('정상범위' 같은 지식 질문은 제외)
    //   [2026-08-05] 평균값만 보여주지 말고 권장 수치를 함께 보여 달라는 요청(슬라이드 20) 반영.
    //   ※ '공복 평균혈당 어때요?' 는 '평균'에 먼저 걸리면 안 되므로 공복·식후는 여기서 제외한다(각자 아래 분기).
    if (avg != null && _dataIntent && /(이번\s*주|주간|평균|한\s*주|일주일|최근|혈당\s*어때|혈당은|혈당이\s*높|혈당이\s*낮)/.test(q)
        && !/(정상\s*범위|범위는)/.test(q) && !/(공복|식후)/.test(q)) {
      var s = avg <= 140 ? '양호한 상태입니다 👍'
            : avg <= 180 ? '관리가 필요합니다.'
            : '<span style="color:#dc3545;">고혈당 주의</span>가 필요합니다.';
      var extra = (tir != null)
        ? ('<br>목표범위 내 비율(TIR): <b>' + tir + '%</b> — 권장 : 70% 이상 '
           + (tir >= 70 ? '충족' : '<b style="color:#e67e22">미달</b>')) : '';
      return '주간 평균 혈당: <b>' + avg + ' mg/dL</b><br>권장 : 목표범위 <b>70~180 mg/dL</b>'
           + extra + '<br>' + s + note;
    }

    // ── 공복 (데이터 의도일 때만; "공복혈당이란?" 은 blood_qa.js 로) ──
    // ★[2026-08-20 수정] 판정 기준을 **관리 목표(권장 80~130)**로 통일 — 종전엔 진단 기준
    //   (정상<100/공복혈당장애 100~125/≥126)으로 판정해 108 이 「공복혈당장애」인데 권장(80~130)
    //   안이라는 모순이 났고, 끝의 "진단이 아닙니다" 안내와도 어긋났다(진단명을 쓰면서).
    //   구간은 이 화면 공복 평균 카드(avgFastingBlood1_name, 80~130/131~160/160↑)와 동일.
    if (fasting != null && _dataIntent && /공복/.test(q)) {
      var ft = fasting < 80  ? '<span style="color:#e67e22;">낮음 — 저혈당 주의</span>'
             : fasting <= 130 ? '목표 범위 내 👍'
             : fasting <= 160 ? '<span style="color:#e67e22;">다소 높음</span>'
             : '<span style="color:#dc3545;">높음</span>';
      /* ★[2026-08-20 요청] **「권장 : 80~130 mg/dL」 줄을 뺀다.** 값과 판정만 보여 준다.
         (각주 note 는 다른 답변들과 같이 그대로 둔다.)
         ⚠권장 범위는 화면에서 사라져도 **판정 기준으로는 그대로 쓰인다** — 위 ft 의 80/130/160 이 그것이다. */
      return '공복 평균 혈당: <b>' + fasting + ' mg/dL</b> (' + ft + ')' + note;
    }

    // ── 식후 (데이터 의도일 때만) ──
    if (post != null && _dataIntent && /(식후|식사\s*후|식사후|밥\s*먹고|먹은\s*후)/.test(q)) {
      var pt = post < 140 ? '정상' : post <= 180 ? '약간 높음' : '<span style="color:#dc3545;">고혈당</span>';
      return '식후 평균 혈당: <b>' + post + ' mg/dL</b> (' + pt + ')<br>권장 : <b>180 mg/dL 미만</b>' + note;
    }

    // ── TIR / TAR / TBR / GMI ──
    if (tir != null && /(tir|목표범위)/.test(q)) {
      return '목표범위 내 비율(TIR): <b>' + tir + '%</b><br>'
           + (tir >= 70 ? '목표(70% 이상)를 잘 유지하고 있습니다 👍' : '목표(70% 이상)에 다소 못 미칩니다. 관리가 필요합니다.');
    }
    if (tar != null && /tar/.test(q)) { return '고혈당 시간 비율(TAR): <b>' + tar + '%</b>' + note; }
    if (tbr != null && /tbr/.test(q)) { return '저혈당 시간 비율(TBR): <b>' + tbr + '%</b>' + note; }
    if (gmi != null && /(gmi|당화|혈당관리지표)/.test(q)) {
      return '혈당관리지표(GMI): <b>' + gmi + '%</b><br>' + (gmi < 7 ? '양호합니다 👍' : '관리 강화를 권장드립니다.')
           + '<br><small>※ 대한당뇨병학회 기준 — GMI는 권장(위험분류) 제시가 없는 참고 지표입니다.</small>';
    }
    // [2026-07-31 기획 7] CV·고혈당/저혈당 구간 칩 응답 (관리지표 기준 = 대한당뇨병학회)
    var cv = _metricNum('cv');
    if (cv != null && /(cv|변동성)/.test(q)) {
      return '혈당 변동성(CV): <b>' + cv + '%</b><br>'
           + (cv <= 36 ? '권장(36% 이하) 범위로 안정적입니다 👍' : '권장(36% 이하)보다 커서 혈당 변동 관리가 필요합니다.');
    }
    if (/고혈당\s*구간/.test(q)) {
      var hz = (document.getElementById('avgHigh_name') || {}).textContent || '';
      return hz.trim() ? ('고혈당 발생 구간(시간대): <b>' + hz + '</b>' + note)
                       : '이번 주 고혈당 발생 구간 정보가 아직 없습니다.';
    }
    if (/저혈당\s*구간/.test(q)) {
      var lz = (document.getElementById('avgLow_name') || {}).textContent || '';
      return lz.trim() ? ('저혈당 발생 구간(시간대): <b>' + lz + '</b>' + note)
                       : '이번 주 저혈당 발생 구간 정보가 아직 없습니다.';
    }

    _chatLLMFollow = false;   // 여기부터는 가이드 자체가 답 — LLM 이어붙임 없음

    /* ── [2026-08-05 검토회의] 음식추천 / 운동추천 칩 ──
       화면에 이미 계산돼 있는 '주의할음식TOP3' · '추천운동TOP3'(주간)을 그대로 읽어 답한다. */
    if (/(음식|식사|먹을|메뉴).*(추천|뭐|무엇|알려)|추천.*(음식|식사|메뉴)/.test(q)) {
      var f = _topRows('grid-rows-food', 3);
      var fh = f.length
        ? ('최근 일주일 <b>주의할 음식 TOP' + f.length + '</b> 입니다.<br>'
           + f.map(function(r,i){ return (i+1) + '. ' + r[1] + (r[3] && r[3] !== '-' ? (' — 혈당변동폭 ' + r[3] + ' mg/dL') : ''); }).join('<br>')
           + '<br><br>')
        : '';
      return fh
           + '식사 요령<br>'
           + '• 채소·단백질을 먼저 먹고 <b>탄수화물은 나중에</b> 드세요.<br>'
           + '• 흰쌀·면·빵·단 음식은 줄이고 <b>잡곡·통곡물</b>로 바꿔 보세요.<br>'
           + '• 식후 <b>20~30분 걷기</b>가 식후 혈당 상승을 완화합니다.' + note;
    }
    if (/(운동|활동|걷기).*(추천|뭐|무엇|알려|좋)|추천.*(운동|활동)/.test(q)) {
      var x = _topRows('grid-rows-exer', 3);
      var xh = x.length
        ? ('최근 일주일 <b>추천 운동 TOP' + x.length + '</b> 입니다.<br>'
           + x.map(function(r,i){ return (i+1) + '. ' + r[1] + (r[2] && r[2] !== '-' ? (' — ' + r[2] + '분') : ''); }).join('<br>')
           + '<br><br>')
        : '';
      return xh
           + '운동 요령<br>'
           + '• <b>식후 30분~1시간</b>에 가볍게 걷는 것이 가장 효과적입니다.<br>'
           + '• 주 <b>150분 이상</b>(하루 20~30분)을 목표로 꾸준히 하세요.<br>'
           + ((tbr != null && tbr >= 4)
              ? '• 저혈당(TBR)이 권장보다 높습니다 — <b>공복 운동은 피하세요.</b>'
              : '• 공복 상태의 격한 운동은 저혈당 위험이 있으니 주의하세요.') + note;
    }

    /* ── [2026-08-05 검토회의] 준비된 질문이 아닐 때(슬라이드 19) ──
       "나의 건강상태는?" 처럼 막연히 물어도 폴백 안내가 아니라
       현재 혈당지표 + AI 분석(코칭) 텍스트를 바로 보여준다. */
    if (/(건강\s*상태|내\s*상태|나의\s*상태|몸\s*상태|어떤가요|어떻습니까|괜찮은가|괜찮나|종합|전체적)/.test(q)) {
      var sum = _chatStatusSummary();
      if (sum) return sum;
    }

    // ── 일반 건강 지식: blood_qa.js 의 BLOOD_QA 키워드 매칭 (점수제) ──
    if (typeof BLOOD_QA !== 'undefined' && BLOOD_QA.length) {
      var bestItem = null, bestScore = 0, bestMaxLen = 0, secondScore = 0;
      for (var i = 0; i < BLOOD_QA.length; i++) {
        var item = BLOOD_QA[i];
        if (!item || !item.kw) continue;
        var score = 0, maxLen = 0;
        for (var j = 0; j < item.kw.length; j++) {
          var kw = String(item.kw[j]).toLowerCase();
          if (kw && q.indexOf(kw) !== -1) {
            score += kw.length;
            if (kw.length > maxLen) maxLen = kw.length;
          }
        }
        if (score > bestScore)        { secondScore = bestScore; bestItem = item; bestScore = score; bestMaxLen = maxLen; }
        else if (score > secondScore) { secondScore = score; }
      }
      if (bestItem && bestMaxLen >= 2 && bestScore >= secondScore + 2) {
        return bestItem.a;
      }
    }

    // ── 특정 음식 질문(전용 답 없을 때 일반 음식 가이드) ──
    if (/(먹어도|먹으면|먹는\s*게|먹는\s*건|드셔도|섭취해도|혈당에\s*(어떤|좋|나쁘|괜찮|영향|올라|안\s*좋))/.test(q)) {
      return '특정 음식과 혈당 (일반 가이드):<br>'
           + '• 흰쌀·면류·빵 등 <b>정제 탄수화물</b>과 단 음식은 혈당을 빠르게 올립니다.<br>'
           + '• <b>채소·단백질을 먼저</b> 먹고 천천히(20분 이상) 드세요.<br>'
           + '• 탄수화물은 양을 줄이고 잡곡·통곡물로 바꾸면 좋습니다.<br>'
           + '• 식후 <b>30분 걷기</b>로 식후 혈당 상승을 완화하세요.<br>'
           + '<small>※ 일반 참고용이며 음식별 반응은 개인차가 있습니다.</small>';
    }

    // ── 매칭 실패 → null → sendChat() 이 서버 LLM 으로 fallback ──
    return null;
  }

  /* LLM·매칭 모두 실패했을 때 — [2026-08-05 검토회의 슬라이드 19]
     "죄송해요…"로 끝내지 말고, 준비된 답이 없더라도 현재 혈당지표 + AI 분석(코칭)을 보여준다.
     지표조차 없을 때만 종전의 예시 질문 안내를 낸다. */
  function _chatFallbackMsg(){
    var sum = _chatStatusSummary();
    if (sum) {
      return '그 질문에 딱 맞는 답변은 준비하지 못했어요.<br>대신 지금 혈당 상태를 알려드릴게요.<br><br>' + sum;
    }
    return '죄송해요, 지금은 답변을 가져오지 못했어요 😅<br><br>이런 질문을 해보세요:<br>• "주간 평균혈당 어때요?"<br>• "주간 최고혈당 알려줘"<br>• "공복 평균혈당 어때요?"<br>• "음식 추천해줘"<br>• "운동 추천해줘"';
  }

  // 현재 화면 지표 요약 — LLM 프롬프트 컨텍스트로 전달
  /* [2026-08-13 기획 「AI 답변 Sample」] 수치는 **화면(기존 자료)** 것을 그대로 쓰고,
     문장만 Gemini 가 만든다. 그래서 컨텍스트에 TIR/TAR/TBR 을 **원값 그대로** 실어 보낸다.
     ⚠TAR·TBR 이 빠져 있던 것이 종전 문제 — 고혈당형/저혈당형을 구분할 근거가 없어
       LLM 이 일반론만 답했다. 기획안의 4유형(우수/고혈당/저혈당/변동)은 이 세 값이 있어야 갈린다. */
  /* ★★숫자를 **LLM 에 보내지 않는다.** 「답변에 수치를 쓰지 마」라고 지시해도 모델은
       받은 숫자를 되읽는다(2026-08-13 실측 — 4유형 전부 TIR/TAR 를 그대로 나열했다).
       ⇒ 되읽을 숫자 자체를 주지 않는 것이 유일하게 확실한 방법이다.
       수치는 화면 표(#tir/#tar/#tbr/#cv)가 이미 보여준다 — 기획 「수치는 기존자료, 문장은 AI」 그대로. */
  function _chatCtxText(){
    var tir = _metricNum('tir'), tar = _metricNum('tar'), tbr = _metricNum('tbr'), cv = _metricNum('cv');
    if (tir == null && tar == null && tbr == null && cv == null) return '';
    var parts = [];
    if (tir != null) parts.push(tir >= 70 ? '목표범위 유지 양호' : (tir >= 50 ? '목표범위 유지 다소 부족' : '목표범위 유지 낮음'));
    if (tar != null) parts.push(tar >= 25 ? '고혈당 시간 김'     : (tar >= 10 ? '고혈당 시간 다소 있음'   : '고혈당 거의 없음'));
    if (tbr != null) parts.push(tbr >= 4  ? '저혈당 반복'        : (tbr >= 1  ? '저혈당 가끔'             : '저혈당 거의 없음'));
    if (cv  != null) parts.push(cv  > 36  ? '혈당 변동 큼'       : '혈당 변동 안정적');
    var t = _chatGlucoseType(tir, tar, tbr, cv);
    return parts.join(' / ') + (t ? (' / 판정유형 ' + t) : '');
  }

  /* 혈당 유형 자동 판정 — 기획안 §「혈당 유형 자동 판정」 4유형.
     ★판정은 **우리가 한다**(대한당뇨병학회 CGM 기준: TIR≥70·TAR<25·TBR<4·CV≤36).
       LLM 에 맡기면 같은 수치에 다른 유형이 나올 수 있다 — 수치·판정은 기존 자료, 문장만 AI. */
  function _chatGlucoseType(tir, tar, tbr, cv){
    if (tir == null && tar == null && tbr == null) return '';
    if (tbr != null && tbr >= 4)  return '저혈당형';
    if (tar != null && tar >= 25) return '고혈당형';
    if (cv  != null && cv  > 36)  return '변동형';
    if (tir != null && tir >= 70) return '우수';
    return '변동형';
  }

  // [2026-07-31 기획 7] 챗봇 오버레이 열기/닫기 — 메인 [AI 챗봇](goBloodPage2.do?chat=1) 진입 시 자동 오픈
  var _chatFromMain = false, _chatIntroDone = false, _chatIntroForce = false;
  // [2026-07-31 방식 변경] 화면 전환 — 챗봇을 열면 이 화면의 다른 카드만 감춘다(연속혈당 1↔2p 와 동일).
  //   fixed 오버레이의 높이 문제(기기별 잘림·빈 띠)를 없애고, 하단 메뉴는 문서 흐름 그대로 보인다.
  function _chatSiblings(ov){
    var out = [];
    if(!ov || !ov.parentNode) return out;
    var kids = ov.parentNode.children;
    for(var i=0;i<kids.length;i++){ if(kids[i] !== ov) out.push(kids[i]); }
    return out;
  }
  /* [2026-08-05 최종] 대화영역 높이 실측(_chatFill) 폐기 — CSS flex 가 대신한다.
     .main-content 는 comm_blood.css 에서 이미 `display:flex; flex-direction:column; flex:1` 이고
     PC(app-desktop)·모바일(comm_blood @media) 모두 그 안에서만 세로 스크롤된다.
     챗봇 블록(.chat-overlay.on)과 대화영역(.qa-messages)에 각각 flex:1 을 주면
     브라우저가 남는 높이를 정확히 배분한다 — 기기·프레임별 실측 오차가 원천적으로 없다.
     (실측 방식은 프레임마다 값이 어긋나 제목줄 잘림·빈 띠를 반복적으로 만들었다.)
     함수 자체는 남겨 둔다 — 예전 호출 지점이 있어도 안전하게 무시되도록. */
  /* [2026-08-05] 안전망 — 챗봇 블록 높이를 본문 컨테이너 '안쪽 높이'에 한 번만 맞춘다.
     CSS(flex:1 1 0)만으로도 채워지지만, 이 화면은 .main-content 에 규칙이 여러 겹 얹혀 있어
     부모가 flex 로 안 잡히는 경우가 있었다(블록이 내용 높이로만 잡혀 아래가 텅 빔).
     반복 계산 없이 clientHeight − 패딩 한 번만 쓰므로 기기·프레임과 무관하게 안전하다. */
  function _chatFill(){
    var ov = document.getElementById('chatOverlay');
    var mc = document.querySelector('.main-content');
    if(!ov || !mc || !ov.classList.contains('on')) return;
    var cs = getComputedStyle(mc);
    var h = mc.clientHeight - (parseFloat(cs.paddingTop) || 0) - (parseFloat(cs.paddingBottom) || 0);
    if(h > 160) ov.style.height = h + 'px';
  }
  function _chatLock(){ /* no-op — 넘치지 않으므로 잠글 필요가 없다 */ }
  function _chatUnlock(){
    document.documentElement.classList.remove('chat-lock');
    var mc = document.querySelector('.main-content');
    if(mc) mc.classList.remove('chat-lock');
  }
  function _chatRefit(){ _chatFill(); _chatLock(); }
  window.addEventListener('resize', function(){
    var box = document.getElementById('chatMessages');
    if(box){ box.style.height = ''; box.style.boxSizing = ''; }   // 예전 인라인 높이 잔재 제거
    var ov = document.getElementById('chatOverlay');
    if(ov) ov.style.height = '';                                  // 다시 재기 전에 초기화
    setTimeout(_chatFill, 0);
  });
  function openChat(){
    var ov = document.getElementById('chatOverlay');
    _chatSiblings(ov).forEach(function(el){
      if(el.getAttribute('data-chat-hidden') === '1') return;
      el.setAttribute('data-chat-prev', el.style.display || '');
      el.setAttribute('data-chat-hidden', '1');
      el.style.display = 'none';
    });
    if(ov) ov.classList.add('on');
    try{ var ct=document.querySelector('.contents'); if(ct) ct.classList.add('chat-on'); }catch(e){}
    // [2026-08-05] 이 화면의 실제 컨테이너는 .main-content — 열려 있는 동안 위/아래 여백을 맞춘다
    try{ var mcO=document.querySelector('.main-content'); if(mcO) mcO.classList.add('chat-on'); }catch(e){}
    // 모바일에서 주소창 때문에 아래가 화면 밖으로 밀리는 것 방지 (CSS 에서 dvh 로 고정)
    try{ var wpO=document.querySelector('.wrap'); if(wpO) wpO.classList.add('chat-open'); }catch(e){}
    // [2026-08-05] 열 때 스크롤 위치를 맨 위로 + 블록 높이를 컨테이너에 맞춘다(CSS flex 보조).
    window.scrollTo(0,0);
    var sc0 = document.querySelector('.main-content'); if(sc0) sc0.scrollTop = 0;
    setTimeout(_chatFill, 0); setTimeout(_chatFill, 320);
    try{ if(document.fonts && document.fonts.ready) document.fonts.ready.then(_chatFill); }catch(e){}
    _chatIntroAnalysis();   // 지표가 이미 준비돼 있으면 인사 밑에 분석 표시(아직이면 wkAi 도착 훅으로 1회)
    // [2026-07-31] TIR 이 늦게 와서 분석에서 빠지는 것 방지 — 3종이 다 모일 때까지 기다리되,
    //   4초가 지나면 그때까지 온 지표만이라도 게시(전부 실패 시 빈 게시는 안 함)
    setTimeout(function(){ _chatIntroForce = true; _chatIntroAnalysis(); }, 4000);
  }
  function closeChat(){
    var ov = document.getElementById('chatOverlay');
    _chatUnlock();
    if(ov){ ov.classList.remove('on'); ov.style.height = ''; }
    try{ var ct=document.querySelector('.contents'); if(ct) ct.classList.remove('chat-on'); }catch(e){}
    try{ var mcC=document.querySelector('.main-content'); if(mcC) mcC.classList.remove('chat-on'); }catch(e){}
    try{ var wpC=document.querySelector('.wrap'); if(wpC) wpC.classList.remove('chat-open'); }catch(e){}
    // 감춰 둔 카드 원복(메인에서 온 경우엔 그대로 뒤로 가므로 복원해도 무해)
    _chatSiblings(ov).forEach(function(el){
      if(el.getAttribute('data-chat-hidden') !== '1') return;
      el.style.display = el.getAttribute('data-chat-prev') || '';
      el.removeAttribute('data-chat-hidden'); el.removeAttribute('data-chat-prev');
    });
    if(_chatFromMain) history.back();   // 메인에서 왔으면 메인으로 복귀
  }
  // 처음 열릴 때 인사 하단에 TIR·TAR·TBR 분석 표시(기획 확정). 지표가 늦게 오면 wkAi 갱신 훅에서 1회 추가.
  function _chatIntroAnalysis(){
    if(_chatIntroDone) return;
    var ov = document.getElementById('chatOverlay');
    if(!ov || !ov.classList.contains('on')) return;
    var tir=_metricNum('tir'), tar=_metricNum('tar'), tbr=_metricNum('tbr');
    if(tir==null && tar==null && tbr==null) return;
    // TIR(가장 중요한 지표) 포함 보장 — 3종이 다 모이기 전에는 게시하지 않는다(4초 경과 시에만 부분 게시)
    if(!_chatIntroForce && (tir==null || tar==null || tbr==null)) return;
    /* [2026-08-05 검토회의 슬라이드 16] 두 가지 수정
       ① nowrap 제거 — 한 줄 고정 때문에 '충족 👍' 끝이 말풍선 밖으로 잘렸다("범위 벗어남").
          글자 크기는 그대로 두고 넘칠 때만 접히게 한다.
       ② 지표 수치 아래에 <b>AI 분석(코칭) 텍스트</b>를 이어 붙인다 — 수치만으로는 해석이 안 되고,
          코칭을 함께 봐야 본인 혈당 상태를 즉시 알 수 있다는 요청. 문장은 화면의 '생활습관 코칭'을 재사용. */
    function ln(s){ return '<span style="display:block; word-break:keep-all;">'+s+'</span>'; }
    var L=[];
    if(tir!=null) L.push(ln('• TIR(목표유지) <b>'+tir+'%</b> — 권장 70%↑ '+(tir>=70?'충족&nbsp;👍':'<b style="color:#e67e22">미달</b>')));
    if(tar!=null) L.push(ln('• TAR(고혈당) <b>'+tar+'%</b> — 권장 25%↓ '+(tar<25?'충족':'<b style="color:#e67e22">초과</b>')));
    if(tbr!=null) L.push(ln('• TBR(저혈당) <b>'+tbr+'%</b> — 권장 4%↓ '+(tbr<4?'충족':'<b style="color:#e67e22">초과</b>')));
    var coach = '';
    var cbox = document.getElementById('wkCoach');
    if(cbox && cbox.innerHTML && cbox.innerHTML.indexOf('불러오면') === -1){
      coach = '<br><b>AI 코칭</b><br>' + cbox.innerHTML;
    }
    _addMsg('최근 일주일 지표 분석입니다.'+L.join('')+coach+'<small>※ 대한당뇨병학회 관리지표 기준</small>', false, 'chat-wide');
    _chatIntroDone = true;
  }
  window._chatIntroHook = _chatIntroAnalysis;   // wkAi upd() 가 지표를 채울 때마다 호출(1회 게시 가드 내장)

  // 초기 인사 메시지 (+ 메인 [AI 챗봇] 경유면 오버레이 자동 오픈)
  document.addEventListener('DOMContentLoaded', function(){
    _addMsg('안녕하세요! 혈당 관련 궁금한 점을 질문해 주세요.', false, 'chat-intro');
    try{
      if(new URLSearchParams(window.location.search).get('chat')==='1'){ _chatFromMain=true; openChat(); }
    }catch(e){}
  });

  // ===== 초기화 & 이벤트 =====
  document.addEventListener('DOMContentLoaded', function(){
    // 세션 userUuid 주입
    userId = '<%= String.valueOf(session.getAttribute("userUuid")) %>';

    const box = document.getElementById('rangeButtons');
    const applyBtn = document.getElementById('applyBtn');
    const sEl = document.getElementById('startDate');
    const eEl = document.getElementById('endDate');

    // 초기: 데이터가 있는 마지막 날을 기준으로 일주일 보기 (연속혈당 화면과 동일).
    //   최근 데이터 일자를 종료일로, 그 6일 전을 시작일로. 데이터가 전혀 없으면 오늘 기준.
    const activeBtn = box?.querySelector('.btn.active') || box?.querySelector('.btn[data-days="0"]');
    const initDays = activeBtn ? Number(activeBtn.getAttribute('data-days')) : 7;
    const anchorEnd = _getLastDataDate();   // 동기 조회 (없으면 null)
    const initRange = anchorEnd ? computeRangeEndingAt(anchorEnd, initDays) : computeRange(initDays);
    setDateInputs(initRange.start, initRange.end);
    loadTimeBand(initRange.start, initRange.end);

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
	            /* ★[2026-08-18 요청] 단위 **%** 를 붙인다 — 연속혈당 상세 화면과 같은 표기.
	               ★소수 1자리는 그대로(4.3 %) · 숫자를 다시 읽는 곳은 숫자 외 글자를 걷어내므로 안전하다. */
	            document.getElementById('tar').textContent = (response.TAR_UPT || 0).toFixed(1) + " %";
	            document.getElementById('tbr').textContent = (response.TBR_UPT || 0).toFixed(1) + " %";
	            document.getElementById('cv').textContent  = (response.CV_UPT || 0).toFixed(1) + " %";
	            
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
	            /* ★[2026-08-18 요청] 단위 **%** 를 붙인다 — 옆 지표(TIR 85 %)와 나란히 서야 한다.
	               ★숫자를 다시 읽는 곳(num()·_metricNum())은 숫자 외 글자를 걷어내므로 안전하다. */
	            document.getElementById('gmi').textContent = gmi + " %";

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
	            /* ★[2026-08-18] 띄어쓰기까지 맞춘다 — 서버가 '95%'(붙여서) 로 주는데
	               옆 지표들은 '4.3 %'(띄어서)라 한 줄만 달라 보였다. */
	            tirElem.textContent = String(tir).replace(/\s*%/, '') + " %";

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
	    		      ? Math.round(Number(data.fastingValue)) : null;   /* ★[2026-08-18] 버림→반올림 : 웹과 같은 자리수 규칙 */
	    		    const after2hVal = (data && Number.isFinite(Number(data.after2hValue)))
	    		      ? Math.round(Number(data.after2hValue)) : null;   /* ★[2026-08-18] 버림→반올림 */

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
