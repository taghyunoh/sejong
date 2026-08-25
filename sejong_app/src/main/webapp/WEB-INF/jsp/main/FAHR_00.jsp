<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>  
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link href="${pageContext.request.contextPath}/asset/css/blood_fahr.css?v=124" rel="stylesheet"> <!-- ASQ 스타일 · v124=분석 문장 18px -->
<title>Insert title here</title>
</head>

<body>
<style>
/* [2026-08-05 검토회의 — 한 화면 통합] 종전 2페이지 분할(1p=수치·그래프·평균 / 2p=상세 지표)을 폐기.
   요청: ① [상세 지표 보기(다음)]·[수치·그래프로(이전)] 버튼 삭제 ② 지표를 그래프 아래에 바로 보이게
        ③ 평균 3종이 두 번 나오던 중복 제거 ④ 지표별 상하 간격 확보 + 글씨 크게.
   목표 = "하루 24시간 발생한 혈당지표를 참고용으로 확인한다". */
/* [2026-07-31 재수정] 간격의 실제 원천 = common.css .blood_list 의 flex gap:20px + padding:20px
   (margin 조정으로는 안 바뀌던 이유). gap·padding 을 직접 줄인다 */
#bloodPage1 .blood_list{ gap: 6px !important; padding: 8px 20px !important; }
#bloodPage1 .blood_list .aval_wrap{ gap: 2px !important; }   /* 라벨(평균혈당 등) ↔ 숫자 간격 */
#bloodPage1 .time_wrap{ margin-top: 8px !important; }
/* 차트 아래 큰 여백의 원천 = .contents .lyInner 의 아래 padding(5.56vwu) — 이 화면만 축소 (2026-07-31) */
#bloodPage1 .lyInner{ padding-bottom: calc(1.2 * var(--vwu,1vw)); }
/* 상세 지표 목록 — 라벨(권장 기준) 왼쪽 / 값 오른쪽 한 줄.
   [2026-08-05] 값을 세로로 쌓지 않고 같은 줄에 두어, 글씨를 키우고 줄 간격을 넓혀도 한 화면에 들어온다.
   값 색: 목표 안=초록(#2e7d32) / 벗어남=황토(#e67e22) / GMI=참고치라 조건 없음(검정) */
.p2list{ margin: calc(0.6 * var(--vwu,1vw)) calc(4 * var(--vwu,1vw)) calc(1.5 * var(--vwu,1vw)); }
.p2list .p2item{ display:flex; align-items:center; justify-content:space-between; gap: calc(3 * var(--vwu,1vw));
  padding: calc(2 * var(--vwu,1vw)) 0; border-bottom:1px solid #eef2f7; }
/* [2026-08-15] 라벨을 우측 값 크기에 가깝게 키우고(3.6→5.5), 권장 힌트도 조금 크게(3.1→4.0) */
.p2list .p2item .lb{ font-size: calc(5.5 * var(--vwu,1vw)); color:#2d303f; font-weight:700; margin:0; line-height:1.35; }
.p2list .p2item .lb .hint{ display:block; font-size: calc(4.0 * var(--vwu,1vw)); color:#8a98a8; font-weight:500; }
.p2list .p2item .v{ flex:0 0 auto; font-size: calc(6.4 * var(--vwu,1vw)); font-weight:800; color:#2d303f; white-space:nowrap; }
/* 아래 '현재 혈당 변화' 설명 블록은 촘촘하게 */
#bloodPage1 .blood-detail-section{ margin: calc(0.8 * var(--vwu,1vw)) 0 !important; }
#bloodPage1 .blood-detail-section .section-content{ padding-top: 0 !important; padding-bottom: 0 !important; }
/* 페이지 마지막 블록 — 하단 고정 메뉴에 가리지 않도록 여유 (종전엔 [다음] 버튼이 이 역할을 했다) */
#bloodPage1 .blood-container{ padding-bottom: calc(16 * var(--vwu,1vw)); }
</style>
    <!-- contents : s -->
    <div class="contents">
     <div id="bloodPage1"><%-- 1페이지 = 현재 수치 + 차트 + 평균 3종 (기획: 유지) --%>
      <!-- 혈당 대시보드 -->
      <article class="top_board_blood">
        <div class="prev_wrap">
          <div class="data" id="prevBloodUpt"></div>
          <div class="time" id="prevBloodDtm"></div>
        </div>
        <div class="gap_wrap">
          <div class="up_row">
            <!-- 화살표 .up .down 클래스 추가 -->
			<%-- [2026-08-16] 이미지 화살표 → 글자 화살표: 숫자(diff)와 같은 색을 입히기 위해 텍스트로 전환 --%>
			<span class="blood_arrow" id="bloodArrow" style="color:#2f9e63;">→</span>
            <span class="diff" id="diff">5.0</span>
          </div>
          <%-- [2026-08-15] 표시 숫자 = 직전 측정(5분 간격) 대비 변화량이라 단위 표기를 /min → /5분 으로 --%>
          <div class="down_row">mg/dL/5분</div>
        </div>
        <div class="now_wrap">
          <div class="data" id="nowBloodUpt"></div>
          <div class="time" id="nowBloodDtm"></div>
        </div>
        
      </article>
      <!-- //혈당 대시보드 -->
      
      
      <div class="lyInner">
        <!-- 날짜 & 시간 선택 -->
        <section class="date_select">
          <div class="date_wrap">
            <a href="#"><span class="material-symbols-outlined icon" id="prevDay">chevron_left</span></a>
            <div id="nowDTM"></div>
            <a href="#"><span class="material-symbols-outlined icon" id="nextDay">chevron_right</span></a>
          </div>
          <!-- [2026-07-11] 오늘 데이터가 없어 마지막 측정일로 이동했을 때만 표시 -->
          <div id="lastMeasureNotice" class="ft14" style="display:none; text-align:center; color:#1f7aed; margin-top:6px; font-weight:600;"></div>
          <div class="time_wrap mt20" id="btnHours">
            <button class="btn btn_sm btnLine05"  value="3">3시간</button>
            <button class="btn btn_sm btnLine05"  value="6">6시간</button>
            <button class="btn btn_sm btnLine05"  value="12">12시간</button>
            <button class="btn btn_sm btnCol06"   value="24">24시간</button>
          </div>
        </section>
        <!-- //날짜 & 시간 선택 -->

        <!-- 연속혈당 chart -->
        <section class="blood_chart">
          <script src="https://cdn.jsdelivr.net/npm/echarts/dist/echarts.min.js"></script>
          <!-- 차트 영역 -->
          <%-- [2026-07-31] 높이 300→268 — 그래프(플롯) 크기는 grid(top24/bottom12)로 그대로 유지하고,
               차트 아래 남던 빈 공간만 줄여 하단(평균 패널)을 위로. 여백은 12px 정도 남김(너무 붙지 않게) --%>
          <%-- [2026-08-05] 268→200 — 상세 지표를 같은 화면으로 합치면서, 지표 5줄이 하단 메뉴 위로
               모두 들어오도록 차트 높이만 줄였다(플롯 비율은 grid 설정 그대로). --%>
          <div id="lineChart" style="height: 200px; width: 100%"></div>
          <!-- //차트 영역 -->
          
        </section>
      </div>
      <!-- 혈당 수치 패널 -->
      <section class="blood_list">
		<div class="unit flx-row j-between a-center">
		  <span class="ft14">현재시점 24시간 기준</span>
		  <span class="ft14">단위 : mg/dL</span>
		</div>
		<div class="top_row flx-row j-between a-center">
		  <div class="left_wrap aval_wrap">
		    <h6>평균 혈당 </h6>
		    <div class="bl_color_stable ft40" id="avgUpt" data-value="-">-</div>
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

      </section>
      <%-- [2026-08-05 검토회의] 상세 지표를 그래프·평균 바로 아래에 이어 붙인다(페이지 전환 버튼 삭제).
           평균 3종은 위 패널에 이미 있으므로 여기서는 반복하지 않는다(중복 제거 요청). --%>
      <section class="p2list">
        <div class="p2item"><p class="lb">GMI지수(%) <span class="hint">혈당 관리지표(참고사항)</span></p><div class="v" id="p2gmi">-</div></div>
        <%-- [2026-08-25] 권장 수치는 **나이·당뇨 유형에 따라 달라진다**(서버 CgmTarget → 아래 _P2STD 가 채운다) --%>
        <div class="p2item"><p class="lb">목표혈당 유지시간(TIR) <span class="hint" id="p2hintTir">권장 : 70% 이상</span></p><div class="v" id="p2tir">-</div></div>
        <div class="p2item"><p class="lb">고혈당 시간(TAR) <span class="hint" id="p2hintTar">권장 : 25% 미만</span></p><div class="v" id="p2tar">-</div></div>
        <div class="p2item"><p class="lb">저혈당 시간(TBR) <span class="hint" id="p2hintTbr">권장 : 4% 미만</span></p><div class="v" id="p2tbr">-</div></div>
        <div class="p2item"><p class="lb">혈당변동성(CV) <span class="hint">권장 : 36% 이하</span></p><div class="v" id="p2cv">-</div></div>
      </section>
      <%-- 기존 GMI지수·TIR 큰 패널 — 위 목록과 중복이라 숨김(#gmi/#tir 은 기존 스크립트가 채우므로 요소는 유지) --%>
      <section class="blood_list" style="display:none;">
        <div class="top_row flx-row j-between a-center">
          <div class="left_wrap aval_wrap">
            <h6> GMI지수(%)</h6>
            <span class="bl_color_stable ft40" id="gmi" data-value="-">-</span>
          </div>
          <div class="line_col" style="height: calc(10 * var(--vwu, 1vw));"></div>
    	  <div class="center_wrap aval_wrap">
	        <h6>TIR(%)</h6>
	        <div>
	           <span class="bl_color_stable ft40" id="tir" data-value="-">-</span>
	         </div>
	      </div>
	      <div class="line_col" style="height: calc(10 * var(--vwu, 1vw));"></div>
        </div>      
      </section>
      <!-- //혈당 수치 패널 -->
	  <div class="blood-container">
	        <!-- 현재 혈당 변화 섹션 -->
	        <section class="blood-detail-section">
	            <div class="section-content">
                    <div class="detail-box_none">
                        <span class="change-text">현재 혈당 변화가</span>
                        <span class="detail-box_small" id = "blood_status" ></span>
                        <span class="change-text"> 입니다 </span>
                    </div>
	            </div>
	        </section>
	
	        <!-- 상세 혈당 증가 정보 -->
	        <section class="blood-detail-section">
	            <div class="section-content">
	                <div class="detail-box">
	                    <span class="detail-text" id = "blood_name"></span>
	                </div>
	            </div>
	        </section>
	
	        <!-- GMI 수치 섹션 -->
	        <section class="blood-detail-section">
	            <div class="section-content">
                  <div class="detail-box_none">
                    <%-- ★[2026-08-18 요청] 문장에서 **「높음/정상」 판정 글자를 뺐다** —
                         「6.6 % 높음입니다」처럼 두 말이 붙어 어색했다. 수치만 남긴다.
                         ⚠`gmiconsult` 요소는 지우지 않고 숨긴다 — 스크립트가 아직 값을 채운다(에러 방지). --%>
                    <span class="change-text">• GMI수치(혈당관리지표)는 </span>
                    <span class="detail-box_small" id="gmi1">-</span>
                    <span class="detail-box_small" id="gmiconsult" style="display:none;">-</span>
                    <span class="change-text">입니다</span>
                   </div>
                </div>  
	        </section>
	
	        <!-- 저혈당 주의 구간 -->
	        <section class="blood-detail-section">
	           <div class="section-content">
                <div class="detail-box_none">
                    <span class="change-text">• TIR(목표범위 내 머문 비율)은
                                                (일반적으로 70~180 mg/dl)</span>
                    <span class="detail-box_small"id="tir1" >-</span>
                    <span class="change-text"> 입니다</span>
                </div>
               </div>
	        </section>
	    </div>

     </div><%-- /#bloodPage1 (2026-08-05: 한 화면 통합 — 2페이지 분할 폐기) --%>
        <!-- contents : e -->
    </div>
  <script>
  
  var accessToken = "";
  var userId = ""; 
  
  var now = new Date();
  var halfNow = new Date();
  halfNow.setHours(halfNow.getHours() - 24);

  // [2026-07-11] 오늘 데이터가 없을 때 이동한 '마지막 측정일'(없으면 null)
  var lastMeasureDate = null;
  
  /* ⚠[2026-08-20] 안 쓰는 값이다 — 화살표는 2026-08-16 에 이미지 → 글자로 바뀌었고,
     2026-08-20 에는 그 글자마저 **하나(→)를 기울이는 방식**이 되어 단계별 그림이 필요 없다.
     지우지 않고 남겨 둔다(그림 파일도 그대로) — 되돌릴 때 경로를 다시 찾지 않도록. */
  const BLOOD_IMG = {
		    fastUp:  "<c:url value='/asset/images/blood/blood_arrow_sspeeh_h.png'/>",
		    up:      "<c:url value='/asset/images/blood/blood_arrow_speeh_h.png'/>",
		    slowUp:  "<c:url value='/asset/images/blood/blood_arrow_slow_h.png'/>",
		    normal:  "<c:url value='/asset/images/blood/blood_arrow.svg'/>",
		    fastDn:  "<c:url value='/asset/images/blood/blood_arrow_sspeeh_l.png'/>",
		    down:    "<c:url value='/asset/images/blood/blood_arrow_speeh_l.png'/>",
		    slowDn:  "<c:url value='/asset/images/blood/blood_arrow_slow_l.png'/>"
		  };
  
  // [2026-07-11] 연동 안내 배너(showConnectGuide) 제거 — 최초/재연동 모두 i-Sens 로그인 자동 이동으로 통일.

  // [2026-08-05] 화면 2페이지 전환 폐기(한 화면 통합) — 외부에서 호출되던 흔적 대비 no-op 로만 남긴다.
  function bloodPage(){ window.scrollTo(0,0); }
  // [2026-07-31 상세 기획] 상세 지표 — 차트에 그린 것과 같은 데이터(dataPoints)로 계산.
  //   TIR=70~180 비율 / TAR=180 초과 / TBR=70 미만  ★권장 %는 나이·유형별로 다르다(_P2STD, 2026-08-25)
  //   CV=표준편차÷평균×100(권장 36% 이하) / GMI=3.31+0.02392×평균(참고치 — 색 조건 없음)
  //   ★값 색: 목표 안=초록(#2e7d32) / 벗어남=황토(#e67e22) — 메인 화면 혈당상태 색과 동일 규칙
  var P2_OK='#2e7d32', P2_WARN='#e67e22', P2_PLAIN='#2d303f';
  /* ★[2026-08-25 요청 — 의사 협의] 권장 수치는 **나이·당뇨 유형마다 다르다.**
     기준은 서버(CgmTarget) 한 곳에서 정하고 여기서는 받아 쓰기만 한다 —
     홈·AI 종합분석·이 화면이 각자 계산하면 같은 사람에게 서로 다른 판정이 나온다.
     EL 이 비어 있으면(옛 화면) 70/25/4 로 떨어져 종전과 똑같이 동작한다. */
  var _P2STD = { nm:'${stdName}',
                 tir:parseInt('${stdTir}',10), tar:parseInt('${stdTar}',10), tbr:parseInt('${stdTbr}',10),
                 note:'${stdNote}' };
  if(isNaN(_P2STD.tir)) _P2STD.tir = 70;
  if(isNaN(_P2STD.tar)) _P2STD.tar = 25;
  if(isNaN(_P2STD.tbr)) _P2STD.tbr = 4;
  (function(){   // 권장 힌트를 그 기준으로 — 화면 숫자와 색 판정이 어긋나지 않게
    var h;
    if((h=document.getElementById('p2hintTir'))) h.textContent = '권장 : ' + _P2STD.tir + '% 이상';
    if((h=document.getElementById('p2hintTar'))) h.textContent = '권장 : ' + _P2STD.tar + '% 미만';
    if((h=document.getElementById('p2hintTbr'))) h.textContent = '권장 : ' + _P2STD.tbr + '% 미만';
  })();
  function _fillPage2Stats(points){
    function put(id,txt,col){ var e=document.getElementById(id); if(e){ e.textContent=txt; e.style.color=col||P2_PLAIN; } }
    var vals=(points||[]).map(function(p){ return +p.value; }).filter(function(v){ return !isNaN(v) && v>0; });
    if(!vals.length){ ['p2tir','p2tar','p2tbr','p2gmi','p2cv'].forEach(function(i){ put(i,'-'); }); return; }
    var n=vals.length;
    var tir=Math.round(vals.filter(function(v){ return v>=70 && v<=180; }).length*100/n);
    var tar=Math.round(vals.filter(function(v){ return v>180; }).length*100/n);
    var tbr=Math.round(vals.filter(function(v){ return v<70; }).length*100/n);
    var mean=vals.reduce(function(a,b){ return a+b; },0)/n;
    var sd=Math.sqrt(vals.reduce(function(a,b){ return a+(b-mean)*(b-mean); },0)/n);
    var cv=Math.round(sd*100/mean);
    put('p2tir', tir+' %', (tir>=_P2STD.tir)?P2_OK:P2_WARN);
    put('p2tar', tar+' %', (tar<_P2STD.tar)?P2_OK:P2_WARN);
    put('p2tbr', tbr+' %', (tbr<_P2STD.tbr)?P2_OK:P2_WARN);
    put('p2cv',  cv +' %', (cv<=36)?P2_OK:P2_WARN);
    /* ★[2026-08-18 요청] GMI 에도 단위 **%** — 바로 위 TIR·TAR·TBR·CV 가 전부 `%` 라 이것만 맨숫자였다.
       ★색은 종전대로 검정(참고치라 좋고 나쁨을 칠하지 않는다). */
    put('p2gmi', (3.31+0.02392*mean).toFixed(1) + ' %');   // 참고치 — 검정 유지
  }

  $(document).ready(function() {
	    // 토큰 정보 
 	    const urlParams = new URLSearchParams(window.location.search);
  		CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/tokenYn.do","POST",'',function(response){
			console.log(response.Data);
			if(!response.IsSucceed){
				// token 가져오는 로직
				if(urlParams.get('code') == null){
					// [2026-07-11] 최초 미연동(토큰 없음) → i-Sens 로그인으로 "자동" 이동(자동 연동).
					//   재연동(토큰 있으나 만료)은 아래 getBloodData 실패 시 배너+버튼으로 안내.
					//   ※ 예전의 '홈 튕김'은 commonUtil 의 자동 index.do 이동이 원인이었고 그건 별도 제거됨.
					getAuth();
					return;
				}else{
		    		getToken();
		    	}
				return;
			}
		});   
 		
		// userId : "${sessionScope.userUuid}"
		
		todayExecs();
	    getBloodUserData();
	    // [2026-07-11] 오늘 데이터가 없으면 데이터가 있는 마지막 일자로 화면을 이동(어느 날 끝났는지 알 수 있게).
	    //   getBloodUserData()로 userId가 세팅된 뒤 호출해야 함(동기).
	    adjustToLastDataDate();
	    getBloodData();
	    orderby();
	});

	// [2026-07-11] 오늘 데이터가 없을 때, 데이터가 있는 마지막 측정 일자로 now/halfNow 를 이동시킴.
	//   - 오늘 데이터가 있으면 아무것도 안 함(오늘 유지)
	//   - 데이터가 전혀 없으면 아무것도 안 함(기존 '데이터가 없습니다' 표시 유지)
	function adjustToLastDataDate(){
		try {
			CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/getLastBloodDate.do", "POST", { userId: userId },
				function(response){
					if (!response || !response.IsSucceed || !response.Data) return; // 데이터 자체가 없음 → 그대로

					// 서버 포맷 'YYYY-MM-DDTHH:mm:ss' → Date
					var last = new Date(String(response.Data));
					if (isNaN(last.getTime())) return;

					var today = new Date();
					if (last.toDateString() === today.toDateString()) return; // 오늘 데이터 있음 → 그대로

					// 오늘 데이터 없음 → 마지막 데이터 날짜(하루 범위)로 이동. (전날 버튼과 동일한 방식)
					lastMeasureDate = new Date(last.getFullYear(), last.getMonth(), last.getDate());
					now = new Date(last.getFullYear(), last.getMonth(), last.getDate());
					now.setHours(23, 59, 59, 999);
					halfNow = new Date(now);
					halfNow.setHours(0, 0, 0, 0);

					updateButtonState(); // 과거일자이므로 시간 버튼 상태 갱신(24시간만 활성)
					console.log("오늘 데이터 없음 → 마지막 데이터 일자로 이동:", now);
				}
			);
		} catch (e) {
			console.error("adjustToLastDataDate 오류:", e);
		}
	}

	// [2026-08-20] 폴백(오늘 자료가 없어 '마지막 측정일'을 보는 중)에서 **수집으로 오늘 자료가 들어오면 오늘로 되돌린다.**
	//   adjustToLastDataDate 는 '오늘 → 과거' 한 방향뿐이라 돌아오는 길이 없었다 —
	//   한참 만에 로그인해 수집이 그제서야 오늘 자료를 채워도 화면은 과거일에 머물고
	//   "당일 혈당 측정이 없어…" 안내까지 남아 있었다.
	//   ★폴백 상태가 아니면 아무것도 하지 않고 그대로 done() 한다(오늘을 보는 평소 경로).
	//   ★확인이 오는 사이 사용자가 ◀▶ 로 날짜를 옮기면 손대지 않는다(done 도 부르지 않음 = 다시 그리지 않음).
	function restoreTodayIfArrived(done){
		var isFallback = lastMeasureDate
			&& now.toDateString() === lastMeasureDate.toDateString()
			&& lastMeasureDate.toDateString() !== new Date().toDateString();
		if (!isFallback) { done(); return; }

		var _at = now.toDateString();
		try {
			CommonUtil.callAjax(CommonUtil.getContextPath() + "/getLastBloodDate.do", "POST", { userId: userId },
				function(response){
					if (now.toDateString() !== _at) return;   // 그 사이 사용자가 날짜를 옮겼다 → 그대로 둔다
					try {
						if (response && response.IsSucceed && response.Data){
							var last = new Date(String(response.Data));
							if (!isNaN(last.getTime()) && last.toDateString() === new Date().toDateString()){
								lastMeasureDate = null;                        // 폴백 해제 → '최종 측정일' 안내도 사라진다
								now = new Date();
								halfNow = new Date();
								halfNow.setHours(halfNow.getHours() - 24);      // 초기화(209~211줄)와 같은 규칙
								// 시간 버튼을 '오늘·24시간' 모양으로 되돌린다.
								// ※updateButtonState() 의 오늘 분기는 3·6·12·24 를 전부 선택색(btnCol06)으로 칠한다 —
								//   여기서는 전날버튼의 '오늘로 돌아왔을 때' 처리와 같은 모양(24시간만 선택)을 쓴다.
								$('.time_wrap button').prop('disabled', false).removeClass('btnLine04').addClass('btnLine05');
								$('#btnHours button[value="24"]').removeClass('btnLine05').addClass('btnCol06');
								console.log("수집으로 오늘 자료 도착 → 오늘로 복귀:", now);
							}
						}
					} catch (e) { console.error("restoreTodayIfArrived 오류:", e); }
					done();
				}
			);
		} catch (e) { console.error("restoreTodayIfArrived 오류:", e); done(); }
	}

	// [2026-07-11] 현재 보고 있는 날짜가 '마지막 측정일'(오늘 아님)일 때만 최종 측정일 안내를 표시.
	//   날짜를 다른 날로 넘기면 자동으로 숨김.
	function updateLastMeasureNotice(){
		var el = document.getElementById('lastMeasureNotice');
		if (!el) return;

		var isFallbackDay = lastMeasureDate
			&& now.toDateString() === lastMeasureDate.toDateString()
			&& lastMeasureDate.toDateString() !== new Date().toDateString();

		if (isFallbackDay) {
			el.textContent = "당일 혈당 측정이 없어 최종 측정일을 표시합니다.";
			el.style.display = "";
		} else {
			el.style.display = "none";
		}
	}
  function todayExecs(){
		CommonUtil.callAjax(CommonUtil.getContextPath() + "/getTodayExecs.do","POST",'',function(response){
			console.log(response);
			var calorie = 0;
			var step = 0;
			var distance = 0;
			if(response.Data != null){
				calorie = response.Data.cal
				step = response.Data.step
				distance = response.Data.cal
			}
			$("#exerCal").text(calorie);
			$("#step").text(step);
			$("#distance").text(distance);
		});
	}
	/* === 공통 헬퍼 & 메시지 === */
	function _isBad(s){ return /\bfunction\b|[{}]|%7B|%7D/i.test(String(s||'')); }
	function _safeCtx(){
	  try{
	    const v = (typeof CommonUtil?.getContextPath === 'function')
	      ? CommonUtil.getContextPath()
	      : (typeof CommonUtil?.getContextPath === 'string' ? CommonUtil.getContextPath : '');
	    return (!v || _isBad(v)) ? '' : v;
	  }catch{ return ''; }
	}
	function _abs(u){ try { return new URL(u, location.origin).toString(); } catch { return null; } }
	function _userError(msg){ alert('[사용자 오류] ' + msg); }

	/* === 그대로 사용 가능 === */
	function redirectToLogin() {
	  const next = encodeURIComponent(location.href);
	  const ctx  = _safeCtx();
	  const t    = (ctx ? ctx : '') + '/login.do?next=' + next;
	  const abs  = _abs(t) || ('/login.do?next=' + next);
	  _userError('로그인이 필요합니다. 다시 로그인해주세요.');
	  location.href = abs;
	}

	/* === 강화된 getAuth: 모든 분기를 사용자 오류로 회수 === */
	function getAuth() {
	  const ctx = _safeCtx();

	  // redirectUri 안전 생성
	  const redirectUri = _abs((ctx || '') + '/goBloodPage.do') || (location.origin + '/goBloodPage.do');
	  if (!redirectUri || _isBad(redirectUri)) {
	    _userError('잘못된 이동 경로입니다. 다시 로그인해주세요.');
	    return redirectToLogin();
	  }
	  console.log('[getAuth] redirectUri =', redirectUri);

	  $.ajax({
	    url: (ctx || '') + '/getAuth.do',
	    type: 'POST',
	    data: JSON.stringify({ redirect_uri: redirectUri }),
	    contentType: 'application/json',
	    dataType: 'text',
	    headers: { 'X-Requested-With': 'XMLHttpRequest' },
	    timeout: 10000,

	    // 서버 코드별 사용자 오류 처리
	    statusCode: {
	      400: function(){ _userError('잘못된 요청입니다. 다시 로그인해주세요.'); redirectToLogin(); },
	      401: function(){ redirectToLogin(); },
	      403: function(){ redirectToLogin(); }
	    },

	    success: function (raw) {
	      // 1) 로그인 폼 HTML이 섞여 온 경우
	      if (typeof raw === 'string') {
	        const lower = raw.toLowerCase();
	        if (raw.indexOf('<form') !== -1 && (lower.indexOf('login') !== -1 || lower.indexOf('로그인') !== -1)) {
	          _userError('세션이 만료되었습니다. 다시 로그인해주세요.');
	          return redirectToLogin();
	        }
	      }

	      // 2) JSON 파싱
	      let resp;
	      if (typeof raw === 'string') {
	        try { resp = JSON.parse(raw); }
	        catch { _userError('인증 정보가 올바르지 않습니다. 다시 로그인해주세요.'); return redirectToLogin(); }
	      } else {
	        resp = raw;
	      }

	      // 3) 서버 신호: 사용자 오류만 노출
	      if (resp && (resp.code === 'LOGIN_REQUIRED' || resp.code === 'UNAUTHORIZED' || resp.code === 'USER_ERROR')) {
	        _userError('로그인이 필요하거나 요청이 올바르지 않습니다. 다시 로그인해주세요.');
	        return redirectToLogin();
	      }

	      // 4) redirectUrl 이동 (검증 필수)
	      if (resp && resp.redirectUrl) {
	        const urlStr = String(resp.redirectUrl);
	        if (_isBad(urlStr)) { _userError('잘못된 이동 경로입니다. 다시 로그인해주세요.'); return redirectToLogin(); }
	        const u = _abs(urlStr);
	        if (!u) { _userError('잘못된 이동 경로입니다. 다시 로그인해주세요.'); return redirectToLogin(); }
	        window.location.href = u;
	      } else {
	        _userError('인증이 필요합니다. 다시 로그인해주세요.');
	        return redirectToLogin();
	      }
	    },

	    error: function (xhr, status) {
	      console.log('[getAuth] error =', status, 'statusCode=', xhr && xhr.status);

	      if (xhr && (xhr.status === 400)) { _userError('잘못된 요청입니다. 다시 로그인해주세요.'); return redirectToLogin(); }
	      if (xhr && (xhr.status === 401 || xhr.status === 403)) { return redirectToLogin(); }
	      if (status === 'timeout') { _userError('요청이 지연되었습니다. 다시 로그인해주세요.'); return redirectToLogin(); }

	      _userError('인증을 다시 진행해주세요.');
	      return redirectToLogin();
	    }
	  });
	}

	
  function getToken(){
	  	const urlParams = new URLSearchParams(window.location.search);
	  	var formData = {
	  		redirect_uri : window.location.origin + CommonUtil.getContextPath() + '/goBloodPage.do',
	  		code : urlParams.get('code')
			}
		
	  	CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/getToken.do","POST",formData,
	  			function(response){
	  				if(response != null || response != "null"){
	  					alert("i-sens와 연동 성공하였습니다.");
	  				}
	  			}
	  	)
  }
  function orderby(){
	  
		
	    console.log("혈당 데이터가져오기 성공 ");
	    console.log("now :", now, "/halfNow :",halfNow );
		document.getElementById('nowDTM').textContent = dateFormatFunc(now);
		updateLastMeasureNotice();

		drawBloodSugarChart(now, halfNow);
	    showBloodData(now, halfNow);
	    getAvgFastingBlood();
	    getPercentage(now, halfNow);
	}

	$('#prevDay').click(function(event) {
	    console.log("전날 데이터 가져오기 ");

	  	now.setDate(now.getDate()-1);
	  	//halfNow.setDate(now.getDate());
	  	halfNow = new Date(now);
	  	
	  	now.setHours(23, 59, 59, 999);
        //now.setHours(0, 0, 0);
        halfNow.setHours(0, 0, 0, 0);
        
	    
		console.log("초기화 전날버튼 now :", now);
	  	console.log("초기화 전날버튼 halfNow :", halfNow);
	    
	  	const today = new Date();
	    if (now.toDateString() === today.toDateString()) {
	        now.setHours(today.getHours(), today.getMinutes(), today.getSeconds(), today.getMilliseconds());
	        halfNow.setHours(today.getHours()-24, today.getMinutes(), today.getSeconds(), today.getMilliseconds());
	        
	        console.log("현재 now : " ,now, "/ halnow : " , halfNow);
	        $('.time_wrap button').prop('disabled', false).removeClass('btnLine04').addClass('btnLine05');
	        $('#btnHours button[value="24"]').removeClass('btnLine05').addClass('btnCol06');
            
	        
	    } else {
	    	
	        updateButtonState(); // 버튼 상태 업데이트
	    }
	  	
	  	
		orderby();
	  	
	});

 
	 $('#nextDay').click(function(event) {
		const today = new Date();
	    now.setDate(now.getDate()+1);
	    console.log("다음날 now :", now);
	    console.log("now.getDate() :", now.getDate());
	  	//halfNow.setDate(now.getDate());
		halfNow = new Date(now);
	  	console.log("다음날 halfNow :", halfNow);
		    
	  	
	    //now.setHours(0, 0, 0);
	    now.setHours(23, 59, 59, 999);
        halfNow.setHours(0, 0, 0, 0);
	  	
        console.log(">>>다음날 halfNow :", halfNow);
	    if (now.toDateString() === today.toDateString()) {
	        now.setHours(today.getHours(), today.getMinutes(), today.getSeconds(), today.getMilliseconds());
	        halfNow.setHours(today.getHours()-24, today.getMinutes(), today.getSeconds(), today.getMilliseconds());
	        
	        console.log("현재 now : " ,now, "/ halnow : " , halfNow);
	        $('.time_wrap button').prop('disabled', false).removeClass('btnLine04').addClass('btnLine05');
	        $('#btnHours button[value="24"]').removeClass('btnLine05').addClass('btnCol06');
        
	    } else {
	    	//now.setHours(23, 59, 59);
	        
	        updateButtonState(); // 버튼 상태 업데이트
	    }
	    
	    console.log("다음날버튼 now :", now);
	    console.log("다음날버튼 halfNow :", halfNow);
	  	
		orderby();
	    	
	 });
	 
	 $('#btnHours').click(function(event) {
		 const clickedButton = $(event.target);
		 const clickedValue = parseInt(clickedButton.val(), 10);

		 $('.time_wrap button').removeClass('btnCol06').addClass('btnLine05');
		 clickedButton.removeClass('btnLine05').addClass('btnCol06');
		 
		        
		 let nowHour = new Date(now); 
		 nowHour.setHours(nowHour.getHours() - clickedValue);
		 
		 console.log("!!!뺀 시간 :", nowHour);
		 
		 drawBloodSugarChart(now, nowHour);
		
	 });
	 
 
	 function getBloodUserData() {
		  try {
		    CommonUtil.callSyncAjax(
		      CommonUtil.getContextPath() + "/getBloodUserData.do",
		      "POST",
		      "",
		      function (response) {
		        if (response && response.accToken && response.userId) {
		          accessToken = response.accToken;
		          userId = response.userId;
		        } else {
		          console.warn("⚠️ 서버 응답에 필요한 데이터가 없습니다.", response);
		          alert("사용자 정보를 불러올 수 없습니다. 다시 시도해주세요.");
		        }
		      },
		      function (error) { // 실패 콜백이 있다면
		        console.error("❌ Ajax 요청 실패:", error);
		        alert("데이터 통신 중 오류가 발생했습니다.");
		      }
		    );
		  } catch (e) {
		    console.error("❗ 예외 발생:", e);
		    alert("시스템 오류가 발생했습니다. 관리자에게 문의해주세요.");
		  }
		}

	function getFormattedDate(date) {
	  const year    = date.getFullYear();
	  const month   = String(date.getMonth() + 1).padStart(2, '0'); // 월은 0부터 시작하므로 +1
	  const day     = String(date.getDate()).padStart(2, '0');
	  const hours   = String(date.getHours()).padStart(2, '0');
	  const minutes = String(date.getMinutes()).padStart(2, '0');
	  const seconds = String(date.getSeconds()).padStart(2, '0');

	  const timezoneOffset = -date.getTimezoneOffset(); // 분 단위 오프셋
	  const sign          = timezoneOffset >= 0 ? '+' : '-';
	  const offsetHours   = String(Math.floor(Math.abs(timezoneOffset) / 60)).padStart(2, '0');
	  const offsetMinutes = String(Math.abs(timezoneOffset) % 60).padStart(2, '0');
	  return year+"-"+month+"-"+day+"T"+hours+":"+minutes+":"+seconds+""+sign+""+offsetHours+":"+offsetMinutes;
	}

	function getDateNDaysAgoFormatted(days) {
	  const date = new Date();
	  date.setDate(date.getDate() - days); // N일 전 날짜로 설정
	  return getFormattedDate(date);
	}

  
  //혈당 데이터 가져오기
  function getBloodData(){
	  var end   = getDateNDaysAgoFormatted(0);
	  var start = getDateNDaysAgoFormatted(3);

	  /* ★[2026-08-20 수정] 수집이 끝나면 화면을 다시 그린다.
	     증상 : 한참 만에 로그인하면 큰 숫자 밑 시각이 지금보다 한참 이르게 나온다(예 14:00 인데 13:40).
	     원인 : $(document).ready 가 getBloodData()(외부 CGM 수집, 비동기)를 쏘고 **기다리지 않고**
	            바로 orderby() 로 DB 를 읽는다. 그 순간 DB 에는 옛 자료뿐이라 마지막 측정시각이 수집 전
	            값으로 그려지고, 수집이 끝나도 **다시 그리는 곳이 없어** 그대로 남았다
	            (아래 async 주석의 "완료 시 orderby로 차트 갱신" 이 실제로는 빠져 있었다).
	     ⚠응답이 오는 사이 사용자가 ◀▶ 로 다른 날을 볼 수 있다 — 그때는 건드리지 않는다. */
	  var _viewAtCall = now.toDateString();

	  $.ajax({
		    url: CommonUtil.getContextPath() + '/getBloodData.do',
			type: 'GET',
			async: true,   /* [2026-07-11] 외부 CGM 재수집을 비동기로 — 화면이 외부응답을 기다리지 않음(완료 시 orderby로 차트 갱신) */
			data: {
	            start : start,
		        end: end,
	            accessToken : accessToken,
	            goTokenUrl : "" , // application.properties api.isens.cgms-url
			  },
			success: function(response) { 
					const result = JSON.parse(response);
					console.log(result);
						if(!result.IsSucceed){
							// [2026-07-11] 재연동 필요(REAUTH) → 배너/버튼 없이 i-Sens 로그인 자동 이동 (최초 미연동과 동일)
							if (result.Data === 'REAUTH') { getAuth(); }
							return;
						}
						// 수집 완료 → 방금 들어온 자료로 다시 그린다
						if (now.toDateString() !== _viewAtCall) return;   // 그 사이 다른 날로 이동 = 손대지 않는다
						// 폴백(마지막 측정일)을 보는 중이었고 오늘 자료가 들어왔으면 먼저 오늘로 되돌린다
						restoreTodayIfArrived(function(){
							if (now.toDateString() === new Date().toDateString()) {
								// 오늘을 보는 중이면 조회 상한(now)도 '지금'으로 당긴다 —
								// 수집 중에 들어온 '페이지 연 시각 이후' 측정이 BETWEEN 밖으로 빠지지 않게.
								now = new Date();
								halfNow = new Date();
								halfNow.setHours(halfNow.getHours() - 24);     // 초기화(209~211줄)와 같은 규칙
							}
							orderby();
						});
				    },
			error: function(xhr, status, error) {
				   	console.log('Error: ' + error);
				 	}     
		});    
  }
  function refreshToken(){
	  CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/refreshToken.do","POST",'',
  			function(response){
  				console.log(response);
  				if(response.IsSucceed){
  					getBloodUserData();
  				    getBloodData();
  				    orderby();
  				}else{
  					deleteToken();
  				}
  			}
  	)
  }
  function deleteToken() {
	    CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/deleteToken.do","POST",'',
	  		function(response){
	    		console.log("delete Token");
	    		window.location.reload();
	  		}
	  	)
	}
  //센서 데이터 가져오기.
  function getSensorInfo(){
	  
	  $.ajax({
			url: CommonUtil.getContextPath() +  '/getData.do',
			type: 'GET',
			data: {
		            start : '2024-08-12T16:28:36+09:00',
		            end: '2024-08-17T17:23:20+09:00',
		            accessToken : accessToken,
		            goTokenUrl : 'https://api.i-sens.com/v1/public/sensors'
				  },
			success: function(response) {
				console.log("sensor Data received:", response);
				},
			error: function(xhr, status, error) {
				console.log('Error: ' + error);
				}
		});	  
  }
	//이전시간 함수처리 
	function getPastDate(baseDate, hours = 0, minutes = 0) {
	    return new Date(baseDate.getTime() - (hours * 60 + minutes) * 60 * 1000);
	}
  /* ★[2026-08-25 요청] 혈당 변화 상태·설명·화살표 = **기기 설명서의 변화 속도 화살표 표** 그대로.
     기준이 '직전 5분'이 아니라 **「혈당이 지난 30분 동안 얼마나 변했는가」**(설명서 원문):
       ≤30 안정적(→) · 31~60 서서히 증가/감소(↗↘) · 61~90 증가/감소 · ≥91 빠르게 증가/감소(↑↓) · 계산불가 = 알 수 없음(=)
     30분 전 값은 차트가 이미 받아 둔 시리즈(getBloodChartData)에서 찾는다 — 서버는 안 바꿨다.
     화살표는 [2026-08-20]의 연속 기울임을 유지하되 근거만 30분 변화량으로: 1 mg/dL(30분) = 1° 라
     설명서 구간(31~60 = 비스듬, 91 = 수직)과 각도가 저절로 맞는다. */
  function applyTrend30(points){
      var stEl = document.getElementById('blood_status');
      var nmEl = document.getElementById('blood_name');
      var arrowEl = document.getElementById('bloodArrow');
      if (!stEl || !nmEl) return;

      // 최신 측정점과, 그보다 30분 앞선 측정점(±10분 이내 근사 — 그 안에 없으면 계산 불가)
      var latest = null, i;
      for (i = 0; i < points.length; i++)
          if (points[i] && !isNaN(points[i].time) && !isNaN(points[i].value) && (!latest || points[i].time > latest.time)) latest = points[i];
      var past = null;
      if (latest) {
          var target = latest.time.getTime() - 30 * 60 * 1000, best = 10 * 60 * 1000 + 1;
          for (i = 0; i < points.length; i++) {
              var p = points[i]; if (!p || isNaN(p.time) || isNaN(p.value)) continue;
              var d = Math.abs(p.time.getTime() - target);
              if (d < best) { best = d; past = p; }
          }
      }

      var status, name, color, deg = 0, glyph = '→';
      if (!latest || !past) {
          status = "알 수 없음";
          name   = "혈당값 변화의 속도와 방향을 계산할 수 없습니다";
          color  = '#6c757d';
          glyph  = '=';
      } else {
          var delta = latest.value - past.value;
          var a = Math.abs(delta);
          var dirTxt = delta >= 0 ? '증가' : '감소';
          if (a <= 30) {
              status = "안정적";
              name   = "혈당이 지난 30분 동안 30 mg/dL 이하로 증가 또는 감소하고 있습니다";
          } else if (a <= 60) {
              status = "서서히 " + dirTxt;
              name   = "혈당이 지난 30분 동안 31~60 mg/dL " + dirTxt + "하고 있습니다";
          } else if (a <= 90) {
              status = dirTxt;
              name   = "혈당이 지난 30분 동안 61~90 mg/dL " + dirTxt + "하고 있습니다";
          } else {
              status = "빠르게 " + dirTxt;
              name   = "혈당이 지난 30분 동안 91 mg/dL 이상 " + dirTxt + "하고 있습니다";
          }
          name += " (최근 30분 " + (delta > 0 ? '+' : '') + delta + " mg/dL)";
          color = a <= 30 ? '#2f9e63' : delta > 0 ? '#dc3545' : '#0d6efd';
          deg = -Math.max(-90, Math.min(90, delta));   // 1 mg/dL(30분) = 1°, ±91 이상 = 수직
      }

      stEl.textContent = status;
      stEl.style.color = color;
      nmEl.textContent = name;
      if (arrowEl) {
          arrowEl.textContent = glyph;
          arrowEl.style.display = 'inline-block';
          arrowEl.style.transition = 'transform .35s ease';
          arrowEl.style.transform = 'rotate(' + deg.toFixed(1) + 'deg)';
          arrowEl.style.color = color;
          arrowEl.title = status;
      }
  }

  //날짜, 현재혈당, 5분전 혈당 등등 각종 가져오기
  function showBloodData(endDate, startDate){
	  console.log(userId);
	  
	  var start = getPastDate(now,24,0) //48시간전   getPastDate(now,0,30) //30분전 
	  
	  var formData = {
	    		start  : formatDate(start),
	    		end    : formatDate(endDate),
	    		userId : userId
	    	}
	  CommonUtil.callAjax(CommonUtil.getContextPath() + "/showBloodData.do","POST",formData,
	  			function(response){
	      	 			const prevData = response.prevData || {};
	      	 		    const nowData = response.nowData || {};

	      	 		    const prevUpt = prevData.UPT || 0;
	      	 		    const prevDtm = prevData.DTM ? timeFormatFunc(prevData.DTM) : "0:0";
	      	 		    const nowUpt = nowData.UPT || 0;
	      	 		    const nowDtm = nowData.DTM ? timeFormatFunc(nowData.DTM) : "0:0";

	      	 		  
		      	 		document.getElementById('prevBloodUpt').textContent = prevUpt; 
		      	 		document.getElementById('prevBloodDtm').textContent = prevDtm; 		      	 	
		      	 		document.getElementById('nowBloodUpt').textContent = nowUpt;
		      	 		document.getElementById('nowBloodDtm').textContent = nowDtm; 
		      	 		
		      	 		// [2026-07-11] avgUpt 요소가 없으면 null → textContent 설정에서 에러(함수 중단) → null-safe 처리
		      	 		var _avgUptEl = document.getElementById('avgUpt'); if (_avgUptEl) _avgUptEl.textContent = Math.round(response.aveUpt)|| 0;
		      	 		 			      	 		
		      	 		// [2026-08-15] 화살표가 늘 '안정적'에 머물던 문제 수정.
		      	 		//   종전에는 인접 측정(5분 간격) 차이에 30분 기준 임계값(±31/61/91)을 적용해
		      	 		//   사실상 화살표가 움직일 수 없었다. 표시 숫자(직전 측정 대비 변화량)와 같은 값으로
		      	 		//   ±2 / ±5 / ±10 단계 판정 → 화살표가 변화 방향·속도를 그대로 보여준다.
		      	 		let point = (parseInt(nowUpt, 10) - parseInt(prevUpt, 10));
		      	 		const _hasBoth = !!(prevData.DTM && nowData.DTM);
		      	 		const _diffEl = document.getElementById('diff');
		      	 		_diffEl.textContent = _hasBoth ? point : 0;
		      	 		// [2026-08-15] 색 구분: 상승(+2 이상)=빨강 / 하강(-2 이하)=파랑 / 안정(±1)=초록 (숫자·화살표 공통)
		      	 		const _dirColor = (!_hasBoth || (point > -2 && point < 2)) ? '#2f9e63' : (point >= 2 ? '#dc3545' : '#0d6efd');
		      	 		_diffEl.style.color = _dirColor;
		      	 		_diffEl.style.fontWeight = '700';

		      	 		/* ★[2026-08-25 요청] 상태·설명·화살표는 **기기 설명서의 「지난 30분」 기준표** 그대로 —
		      	 		   판정에 30분 전 값이 필요해서 차트 시리즈를 받은 곳(applyTrend30)에서 계산한다.
		      	 		   여기(#diff 숫자·색)는 종전 그대로 '직전 5분 차이' — 좌우 두 측정값의 차이와 같아야 해서. */

	          }
	  	)	  	
	  	
	    CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/calcBlood.do","POST",formData,
  			function(response){
      			console.log("표준편차, 변동계수 가져옴. :", response);

      			let gmi_value = "" ;
      			let gmi_point = parseFloat(response.GMI);  // 문자열을 숫자로 변환
      			if (gmi_point < 5) {
      			    gmi_value = "낮음";
      			} 
      			else if (gmi_point >= 6.5) {
      			    gmi_value = "높음";
      			} 
      			else if (gmi_point >= 5 && gmi_point < 6.5) {
      			    gmi_value = "정상";
      			} 
      			document.getElementById('gmiconsult').textContent     = gmi_value;
      			
      			/* ★[2026-08-18 요청] GMI 타일에도 **단위 %** 를 붙인다 — 제목이 「GMI지수(%)」라도
      			   숫자만 6.6 으로 서 있으면 옆 지표(TIR 89 %)와 달라 보인다. */
      			document.getElementById('gmi').textContent     = response.GMI + " %";
      			document.getElementById('gmi1').textContent    = response.GMI + " %";
      			document.getElementById('avgMeal').textContent = response.avgMeal.avgBlood;
     			
 			}
  		)
	  	
 	}
  //공복식후  평균_ 식사이벤트가 있을때만 발생
	function getAvgFastingBlood() {
	  var formData = {
	    userId: userId,
	    date: formatDate(now) // 현재 접속한 시간
	  };
	
	  CommonUtil.callAjax(
	    CommonUtil.getContextPath() + "/getAvgFastingBlood.do",
	    "POST",
	    formData,
	    function (response) {
	      // 응답이 문자열인 경우 파싱
	      if (typeof response === "string") {
	        try { response = JSON.parse(response); } catch (e) {}
	      }
	
	      const fastingEl = document.getElementById('avgFastingBlood');
	      const after2hEl = document.getElementById('after2hBlood');
	
	      if (response && response.IsSucceed && response.Data) {
	        if (fastingEl) fastingEl.textContent = Math.round(response.Data.fastingValue);
	        if (after2hEl) after2hEl.textContent = Math.round(response.Data.after2hValue);
	      } else {
	        if (fastingEl) fastingEl.textContent = "-";
	        if (after2hEl) after2hEl.textContent = "-";
	      }
	    }
	  ); // ← Ajax 닫힘
	}      // ← 함수 닫힘
  
  //고혈당 저혈당 구하기 
	function getPercentage(endDate, startDate) {
	    var formData = {
	        userId: userId,
	        start: formatDate(startDate),
	        end:   formatDate(endDate)
	    };
	
	    CommonUtil.callAjax(
	        CommonUtil.getContextPath() + "/BloodLowHigh.do", 
	        "POST", 
	        formData, 
	        function(response) {
	            var tirElem    = document.getElementById('tir');
	            var tirElem1   = document.getElementById('tir1');
	
	            // 응답이 없거나 속성이 없는 경우 "-" 표시
	            if (!response || (!response.TIR)) {
	                tirElem.textContent   = "-";
	                tirElem1.textContent   = "-";
	                return;
	            }
	
	            tirElem.textContent    = response.TIR   || "-";
	            tirElem1.textContent   = response.TIR   || "-";
	        }
	    ); 
	}

  function drawBloodSugarChart(endDate, startDate) { 
	    console.log("차트그리기 startDate :", formatDate(startDate), " // ", "endDate : ", formatDate(endDate));

	    var formData = {
	        userId: userId,
	        start:  formatDate(startDate), 
	        end:    formatDate(endDate)
	    };
	    var foodChartData;
	    CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/getChartFood.do", "POST", formData, function(response) {
	    	console.log("foodData");
	    	// [2026-07-11] response.Data 가 null 이면 .length 접근에서 예외 → 차트 그리기 중단 방지(null 가드)
	    	if(response && response.Data && response.Data.length>0){
	    		foodChartData = response.Data;
	    	}
	    	console.log(foodChartData);
	    });

	    CommonUtil.callAjax(CommonUtil.getContextPath() + "/getBloodChartData.do", "POST", formData, function(response) {
	
	        
	        var bloodData = Array.isArray(response) ? response : [JSON.parse(response)];
	        bloodData = bloodData || [];

	        function parseTime(dtm) {
	            // [2026-07-11] DTM 이 숫자(epoch)/문자열 모두 올 수 있어 방어. 문자열이 아니면 .replace 에서 크래시났었음.
	            if (dtm == null) return new Date(NaN);
	            if (typeof dtm === 'number') return new Date(dtm);
	            return new Date(String(dtm).replace('Z', ''));
	        }
	        
	        var xAxisLabels = generateXAxisLabels(startDate, endDate);

	        function generateXAxisLabels(startDate, endDate) {
	            var xAxisLabels = [];
	            var currentDate = new Date(endDate); 
	            while (currentDate >= startDate) {
	                var hours = currentDate.getHours().toString().padStart(2, '0');
	                var minutes = currentDate.getMinutes().toString().padStart(2, '0');
	                xAxisLabels.push(hours + ':' + minutes);

	       
	                currentDate = new Date(currentDate.getTime() - 5 * 60 * 1000);
	            }
	            return xAxisLabels.reverse(); 
	        }

	        var seriesData = new Array(xAxisLabels.length).fill(null); 
			
	        var dataPoints = bloodData.length > 0 ? bloodData.map(function(item) {
	            return {
	                time: parseTime(item.DTM),
	                value: parseInt(item.UPT, 10)
	            };
	        }) : [];
	        _fillPage2Stats(dataPoints);   // [2026-07-31] 2페이지 상세 지표(TIR·TAR·TBR·GMI·CV) — 차트와 동일 데이터
	        applyTrend30(dataPoints);      // [2026-08-25] 변화 상태·설명·화살표 — 설명서의 「지난 30분」 기준표로 판정
	        
	        var foodIndex = 0;
	        var foodList = [];
			dataPoints.forEach(function(dp,index) {
				var dpHours   = dp.time.getHours().toString();  
			    var dpMinutes = dp.time.getMinutes().toString().padStart(2, '0');
			    var dpTime    = dpHours + ':' + dpMinutes;

		
			    var closestTimeIndex = -1;
			    var minDiff = Number.MAX_VALUE;

			    xAxisLabels.forEach(function(label, index) {
			        var [hours, minutes] = label.split(':');
			        var labelDate = new Date(dp.time);
			        
			        labelDate.setHours(hours);
			        labelDate.setMinutes(minutes);
			        labelDate.setSeconds(0);
			        
			        var diff = Math.abs(dp.time - labelDate);

			        if (diff <= 5 * 60 * 1000 && diff < minDiff) { // 5분 이내 근사
			            minDiff = diff;
			            closestTimeIndex = index;
			        }
			    });
			 
			    if (closestTimeIndex != -1) {
			        seriesData[closestTimeIndex] = dp.value;
			    }
			});
			console.log(foodList);
	        // [2026-07-11] 이미 초기화된 echarts 인스턴스가 남아 있으면 재init 시 갱신이 안 될 수 있어 dispose 후 재생성
	        var _chartDom = document.querySelector("#lineChart");
	        var _existChart = (window.echarts && echarts.getInstanceByDom) ? echarts.getInstanceByDom(_chartDom) : null;
	        if (_existChart) { _existChart.dispose(); }
	        var chart = echarts.init(_chartDom);
	        chart.setOption({
	            tooltip: {
	                trigger: 'axis',
	                axisPointer: {
	                    type: 'line'
	                },
	                formatter: function(params) {
	                    if (params.length === 0 || !params[0].data) {
	                        return '데이터가 없습니다';
	                    }
	                    var index = params[0].dataIndex;
	                    var time = xAxisLabels[index]; 
	                    var value = seriesData[index];

	                    return value === '-' ? '' : '시간:' + time + ' / 값: ' + value;
	                }
	            },
	            visualMap: {
	                show: false,
	                pieces: [
	                	{ gt: 0,   lte: 53,   color: '#dc354e' },
	                    { gt: 54,  lte: 70,   color: '#bf14fd' },
	                    { gt: 71,  lte: 100,  color: '#0aa2c0' },
	                    { gt: 101, lte: 140,  color: '#198754' },
	                    { gt: 141, lte: 180,  color: '#1aa179' },
	                    { gt: 181, lte: 200,  color: '#fd7e14' },
	                    { gt: 201, lte: 1000, color: '#ff3e09' }
	                ]
	            },
	            grid: {
	                left: '3%',
	                right: '8%',
	                /* [2026-07-31] 그래프 크기는 유지한 채 위·아래 빈 공간만 정리 —
	                   top 24 / bottom 12 + 컨테이너 300→268 로 아래 표시부(평균 패널)가 올라옴(플롯 높이는 종전과 동일) */
	                top: 24,
	                bottom: 12,
	                containLabel: true
	            },
	            xAxis: {
	                type: 'category',
	                data: (function() {
	                    var alreadyLabeled = {
	                        '6': false,
	                        '12': false,
	                        '14': false,
	                        '18': false
	                    };

	                    return xAxisLabels.map(function(label) {
	                        var [hours, minutes] = label.split(':');
	                        hours = parseInt(hours, 10);
	                        minutes = parseInt(minutes, 10);

	                       
	                        if (!alreadyLabeled['6'] && (hours === 6 && minutes <= 5 || (hours === 5 && minutes >= 55))) {
	                            alreadyLabeled['6'] = true; 
	                            return '06:00';
	                        }
	                      
	                        else if (!alreadyLabeled['12']&& (hours === 12 && minutes <= 5 || (hours === 12 && minutes >= 55))) {
	                            alreadyLabeled['12'] = true; 
	                            return '12:00';
	                        }
	                  
	                        else if (!alreadyLabeled['18']&& (hours === 18 && minutes <= 5 || (hours === 18 && minutes >= 55))) {
	                            alreadyLabeled['18'] = true;
	                            return '18:00';
	                        }
	                        else {
	                            return ""; 
	                        }
	                    });
	                })(),
	                axisLabel: {
	                	interval: 0, // 모든 레이블을 보이도록 설정
	                    rotate: 0 // 필요시 각도 조절
	                },
	                axisLine: {
	                    lineStyle: {
	                      color: '#666', // 선 색상 설정
	                      width: 1 // 선 두께 설정
	                    }
	                  },
	                  splitLine: {
	                    show: true, // 세로줄을 보이게 설정
	                    interval: function (index, value) {
	                      // '06:00', '09:00', '12:00'에만 세로줄 표시
	                      return value === '06:00' || value === '12:00' || value === '18:00';
	                    },
	                    lineStyle: {
	                      color: '#E7E7E7', // 세로줄 색상 설정
	                      width: 1 // 세로줄 두께 설정
	                    }
	                  },
	                  axisTick: {
	                    show: false // x축의 구분선을 보이지 않게 설정
	                  }
	            },
	            yAxis: [
                {
                    type: 'value',
                    position: 'left', // y축 라벨을 왼쪽에 표시
                    axisLabel: {
                      show: false, // y축 라벨을 보이지 않게 설정
                    },
                    type: 'value',
                    position: 'right', // 오른쪽에 표시되는 y축
                    axisLabel: {
                      show: false, // y축 라벨을 보이지 않게 설정                      
                    },
                    axisPointer: {
                      show: false // y축에 나타나는 화살표 제거
                    },
                    axisTick: {
                      show: false // y축 눈금과 관련된 화살표 제거
                    },
                    axisLine: {
                      symbol: ['none', 'none'], // 축 끝에 있는 화살표 제거
                    },
                  }
                ],
	            series: [{
	                data: seriesData,
	                type: 'line',
	                smooth: true,
	                symbol: 'circle',
	                symbolSize: 5,
	                z:10,
	                label: {
	                    show: true,
	                    position: 'top',
	                    formatter: function(params) {
	                    	//console.log(params.dataIndex);
	                        if (foodList.includes(params.dataIndex)) {
	                            return `{image|}`;
	                        } else {
	                            return '';
	                        }
	                    },
	                    rich: {
	                        value: {
	                            color: '#000', // 텍스트 색상 설정
	                            fontSize: 14
	                        },
	                        image: {
	                            height: 17,  // 이미지 높이
	                            backgroundColor: {
	                                image: "<c:url value='/asset/images/blood/chart_icon_food.png'/>"  // 이미지 URL
	                            }
	                        }
	                    }
	                },
	                lineStyle: {
	                    type: 'solid',
	                    width: 0
	                },
	                markLine: {
	                    data: [
	                    	{
	                            yAxis: 54,
	                            lineStyle: {
	                              color: '#E7E7E7',
	                              type: 'dashed',
	                              width: 1,
	                              dashOffset: 10 // 점선의 각 점과 점의 간격을 넓게 설정
	                            },
	                            symbol: ['none', 'none'], // 시작과 끝 모두 화살표 제거
	                            symbolSize: [0, 0], // 시작과 끝의 화살표 크기를 0으로 설정
	                            label: {
	                              fontSize: 14,  // 폰트 크기를 14으로 설정
	                              color: '#999' // 폰트 색상을 회색으로 설정
	                            }
	                          },
	                          {
	                            yAxis: 70,
	                            lineStyle: {
	                              color: '#DF87FF',
	                              type: 'dashed',
	                              width: 1,
	                              dashOffset: 10 // 점선의 각 점과 점의 간격을 넓게 설정
	                            },
	                            symbol: ['none', 'none'], // 시작과 끝 모두 화살표 제거
	                            symbolSize: [0, 0], // 시작과 끝의 화살표 크기를 0으로 설정
	                            label: {
	                              fontSize: 14,  // 폰트 크기를 14으로 설정
	                              color: '#CD44FF' // 폰트 색상을 보라색으로 설정
	                            }
	                          },
	                          {
	                            yAxis: 100,
	                            lineStyle: {
	                              color: '#E7E7E7',
	                              type: 'dashed',
	                              width: 1,
	                              dashOffset: 10 // 점선의 각 점과 점의 간격을 넓게 설정
	                            },
	                            symbol: ['none', 'none'], // 시작과 끝 모두 화살표 제거
	                            symbolSize: [0, 0], // 시작과 끝의 화살표 크기를 0으로 설정
	                            label: {
	                              fontSize: 14, // 폰트 크기를 14으로 설정
	                              color: '#999' // 폰트 색상을 회색으로 설정
	                            }
	                          },
	                          {
	                            yAxis: 140,
	                            lineStyle: {
	                              color: '#E7E7E7',
	                              type: 'dashed',
	                              width: 1,
	                              dashOffset: 10 // 점선의 각 점과 점의 간격을 넓게 설정
	                            },
	                            symbol: ['none', 'none'], // 시작과 끝 모두 화살표 제거
	                            symbolSize: [0, 0], // 시작과 끝의 화살표 크기를 0으로 설정
	                            label: {
	                              fontSize: 14, // 폰트 크기를 14으로 설정
	                              color: '#999' // 폰트 색상을 회색으로 설정
	                            }
	                          },
	                          {
	                            yAxis: 180,
	                            lineStyle: {
	                              color: '#E7E7E7',
	                              type: 'dashed',
	                              width: 1,
	                              dashOffset: 10 // 점선의 각 점과 점의 간격을 넓게 설정
	                            },
	                            symbol: ['none', 'none'], // 시작과 끝 모두 화살표 제거
	                            symbolSize: [0, 0], // 시작과 끝의 화살표 크기를 0으로 설정
	                            label: {
	                              fontSize: 14, // 폰트 크기를 14으로 설정
	                              color: '#999' // 폰트 색상을 회색으로 설정
	                            }
	                          },
	                          {
	                            yAxis: 200,
	                            lineStyle: {
	                              color: '#FFBD84',
	                              type: 'dashed',
	                              width: 1,
	                              dashOffset: 10 // 점선의 각 점과 점의 간격을 넓게 설정
	                            },
	                            symbol: ['none', 'none'], // 시작과 끝 모두 화살표 제거
	                            symbolSize: [0, 0], // 시작과 끝의 화살표 크기를 0으로 설정
	                            label: {
	                              fontSize: 14, // 폰트 크기를 14으로 설정
	                              color: '#FF9438' // 폰트 색상을 주황색으로 설정
	                            }
	                          },
	                          {
	                            yAxis: 300,
	                            lineStyle: {
	                              color: '#E7E7E7',
	                              type: 'dashed',
	                              width: 1,
	                              dashOffset: 10 // 점선의 각 점과 점의 간격을 넓게 설정
	                            },
	                            symbol: ['none', 'none'], // 시작과 끝 모두 화살표 제거
	                            symbolSize: [0, 0], // 시작과 끝의 화살표 크기를 0으로 설정
	                            label: {
	                              fontSize: 14, // 폰트 크기를 14으로 설정
	                              color: '#999' // 폰트 색상을 회색으로 설정
	                            }
	                          }
	                    ],
	                    symbol: ['none', 'none']
	                }
	            }],
	            title: {
	                text: bloodData.length === 0 ? '데이터가 없습니다' : '',
	                left: 'center',
	                top: 'center',
	                textStyle: {
	                    color: '#999',
	                    fontSize: 16
	                }
	            },
	        });
	    });
	}

 function updateButtonState() {
		
  	const today = new Date();
   	const isToday = now.toDateString() === today.toDateString();

   	if (isToday) {
       	$('.time_wrap button').prop('disabled', false).removeClass('btnLine04 btnLine05').addClass('btnCol06');
   	} else {
       	$('.time_wrap button').prop('disabled', true).removeClass('btnCol06 btnLine05').addClass('btnLine04');
       	$('#btnHours button[value="24"]').prop('disabled', false).removeClass('btnLine04').addClass('btnCol06');
   	}
 }  
	

 
 //포맷 함수
 function formatDate(date) {
     const year    = date.getFullYear();
     const month   = String(date.getMonth() + 1).padStart(2, '0'); // 월은 0부터 시작
     const day     = String(date.getDate()).padStart(2, '0');
     const hours   = String(date.getHours()).padStart(2, '0');
     const minutes = String(date.getMinutes()).padStart(2, '0');
     const seconds = String(date.getSeconds()).padStart(2, '0');
     
     return year+"-"+month+"-"+day+"T"+hours+":"+minutes+":"+seconds;
 }

 
 function timeFormatFunc(timeOri){
	// [2026-07-11] timeOri 가 숫자(epoch)/문자열 모두 올 수 있어 방어. 문자열이 아니면 .replace 에서 크래시났었음.
	const date = (timeOri == null) ? new Date(NaN)
	           : (typeof timeOri === 'number') ? new Date(timeOri)
	           : new Date(String(timeOri).replace('Z', ''));

	const ampm = date.getHours() >= 12 ? '오후' : '오전';
	const hours = date.getHours() % 12 || 12;
	const min =  String(date.getMinutes()).padStart(2, '0')
	
	const formattedTime = ampm + ' ' + hours + ':' + min;
	 	
	return formattedTime;
	}

 
function dateFormatFunc(oriTime){
	 const dateString = oriTime; 
	 
	 const date = new Date(dateString); 
	 const daysOfWeek = ['일', '월', '화', '수', '목', '금', '토']; 

	 const year = date.getFullYear();
	 const month = date.getMonth() + 1; 
	 const day = date.getDate();
	 const dayOfWeek = daysOfWeek[date.getDay()]; 

	 const formattedDate = year + '년' +' '+ month + '월' +' '+ day +'일' + ' ('+ dayOfWeek +')';

	 return formattedDate;

}
function moveBlood(){
	location.href = CommonUtil.getContextPath() + "/goBloodPage2.do";
}
function goFoodPage(){
	location.href = CommonUtil.getContextPath() + "/foodMain.do";
}
  </script>
</body>
</html>