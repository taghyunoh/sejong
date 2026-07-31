<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>  
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link href="${pageContext.request.contextPath}/asset/css/blood_fahr.css?v=123" rel="stylesheet"> <!-- ASQ 스타일   -->
<title>Insert title here</title>
</head>

<body>
<style>
/* [2026-07-31 기획 — 화면 2페이지 분할] 1p=수치·그래프·평균 / 2p=혈당 변화·상세 지표(TIR·TAR·TBR·GMI·CV).
   긴 스크롤 대신 [다음]/[이전] 버튼으로 화면 전환. */
/* [2026-07-31] 평균 패널·다음 버튼 위아래 간격 축소 — [상세 지표 보기 (다음)]가 스크롤 없이 보이게 */
/* [2026-07-31 재수정] 간격의 실제 원천 = common.css .blood_list 의 flex gap:20px + padding:20px
   (margin 조정으로는 안 바뀌던 이유). gap·padding 을 직접 줄인다 */
#bloodPage1 .blood_list{ gap: 6px !important; padding: 8px 20px !important; }
#bloodPage1 .blood_list .aval_wrap{ gap: 2px !important; }   /* 라벨(평균혈당 등) ↔ 숫자 간격 */
/* [2026-07-31 추가 미세조정] 버튼이 '살짝만' 보임 → 시간버튼 줄 위 여백(mt20)·버튼 주변을 더 줄여 온전히 보이게 */
#bloodPage1 .time_wrap{ margin-top: 8px !important; }
/* 차트 아래 큰 여백의 원천 = .contents .lyInner 의 아래 padding(5.56vwu) — 이 화면만 축소 (2026-07-31) */
#bloodPage1 .lyInner{ padding-bottom: calc(1.2 * var(--vwu,1vw)); }
.bloodPageNav .pgBtn{ padding: calc(2.4 * var(--vwu,1vw)) 0; }
.bloodPageNav{ padding: calc(0.8 * var(--vwu,1vw)) calc(4 * var(--vwu,1vw)) calc(1.5 * var(--vwu,1vw)); }
/* 하단 고정 메뉴 대비 여유는 1페이지(맨 아래 [다음] 버튼)에만 — 2페이지 상단 [이전] 버튼에 주면
   버튼과 지표 사이가 벌어진다(2026-07-31 '표시부분 공간 좁혀주세요' 원인) */
#bloodPage1 .bloodPageNav{ margin-bottom: calc(14 * var(--vwu,1vw)); }
#bloodPage2 .bloodPageNav{ margin-bottom: 0; padding-bottom: calc(2.2 * var(--vwu,1vw)); }   /* [이전]과 지표 사이 살짝만 간격(2026-07-31) */
.bloodPageNav .pgBtn{ display:flex; align-items:center; justify-content:center; width:100%;
  background:#218ecb; color:#fff; border:0; border-radius: calc(2.2 * var(--vwu,1vw));
  padding: calc(3 * var(--vwu,1vw)) 0; font-size: calc(4 * var(--vwu,1vw)); font-weight:700; cursor:pointer; }
.bloodPageNav .pgBtn.prev{ background:#fff; color:#218ecb; border:1px solid #218ecb; }
/* 2페이지 지표 목록(2026-07-31 상세 기획) — 라벨(권장 기준) 작은 글씨 + 값 큰 글씨 세로 나열.
   값 색: 목표 안=초록(#2e7d32) / 벗어남=황토(#e67e22) / GMI=참고치라 조건 없음(검정) */
/* [2026-07-31 '밀도있게'] 2페이지 지표 목록 — 줄 간격·값 크기 축소 */
.p2list{ margin: calc(0.6 * var(--vwu,1vw)) calc(4 * var(--vwu,1vw)) calc(1.5 * var(--vwu,1vw)); }
.p2list .p2head{ display:flex; justify-content:space-between; font-size: calc(3.3 * var(--vwu,1vw));
  color:#2d303f; font-weight:600; padding-bottom: calc(1 * var(--vwu,1vw)); border-bottom:1px solid #eef2f7; }
.p2list .p2avgrow{ display:flex; gap: calc(6 * var(--vwu,1vw)); padding: calc(1.3 * var(--vwu,1vw)) 0; border-bottom:1px solid #eef2f7; }
.p2list .p2avgrow h6{ font-size: calc(3.1 * var(--vwu,1vw)); color:#5b6b80; font-weight:600; margin:0 0 calc(0.3 * var(--vwu,1vw)); }
.p2list .p2avgrow .v{ font-size: calc(4.8 * var(--vwu,1vw)); font-weight:800; color:#2d303f; }
.p2list .p2item{ padding: calc(1.3 * var(--vwu,1vw)) 0; border-bottom:1px solid #eef2f7; }
.p2list .p2item .lb{ font-size: calc(3.1 * var(--vwu,1vw)); color:#2d303f; font-weight:700; margin:0; }
.p2list .p2item .lb .hint{ color:#8a98a8; font-weight:500; }
.p2list .p2item .v{ font-size: calc(4.8 * var(--vwu,1vw)); font-weight:800; color:#2d303f; margin-top: calc(0.3 * var(--vwu,1vw)); }
/* 2페이지 아래 '현재 혈당 변화' 설명 블록도 촘촘하게 */
#bloodPage2 .blood-detail-section{ margin: calc(0.8 * var(--vwu,1vw)) 0 !important; }
#bloodPage2 .blood-detail-section .section-content{ padding-top: 0 !important; padding-bottom: 0 !important; }
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
			<span class="blood_arrow">
			      <img  id="bloodArrow" src="<c:url value='/asset/images/blood/blood_arrow.svg'/>" alt="안정적" class="bl_nomal">
			</span>
            <span class="diff" id="diff">5.0</span>
          </div>
          <div class="down_row">mg/dL/min</div>
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
          <div id="lineChart" style="height: 268px; width: 100%"></div>
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
      <%-- 1페이지 → 2페이지 이동 (2026-07-31 기획: 하단 내용은 스크롤 대신 다음 화면으로) --%>
      <div class="bloodPageNav">
        <button type="button" class="pgBtn" onclick="bloodPage(2)">상세 지표 보기 (다음) &nbsp;&gt;</button>
      </div>
     </div><%-- /#bloodPage1 --%>

     <div id="bloodPage2" style="display:none;"><%-- 2페이지 = 상세 지표 (2026-07-31 상세 기획 표현식 그대로) --%>
      <div class="bloodPageNav">
        <button type="button" class="pgBtn prev" onclick="bloodPage(1)">&lt;&nbsp; 수치·그래프로 (이전)</button>
      </div>
      <section class="p2list">
        <div class="p2head"><span>현재시점 24시간 기준</span><span>단위 : mg/dL</span></div>
        <%-- 평균 3종 — 1페이지 값을 페이지 전환 시 복사(bloodPage(2)) — 서버 재조회 없음 --%>
        <div class="p2avgrow">
          <div><h6>평균혈당</h6><div class="v" id="p2avg">-</div></div>
          <div><h6>공복평균</h6><div class="v" id="p2fast">-</div></div>
          <div><h6>식후평균</h6><div class="v" id="p2after">-</div></div>
        </div>
        <div class="p2item"><p class="lb">GMI지수(%) <span class="hint">: 혈당 관리지표(참고사항)</span></p><div class="v" id="p2gmi">-</div></div>
        <div class="p2item"><p class="lb">목표혈당 유지시간(TIR) <span class="hint">권장 : 70% 이상</span></p><div class="v" id="p2tir">-</div></div>
        <div class="p2item"><p class="lb">고혈당 시간(TAR) <span class="hint">권장 : 25% 미만</span></p><div class="v" id="p2tar">-</div></div>
        <div class="p2item"><p class="lb">저혈당 시간(TBR) <span class="hint">권장 : 4% 미만</span></p><div class="v" id="p2tbr">-</div></div>
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
                    <span class="change-text">• GMI수치(혈당관리지표)는 </span>
                    <span class="detail-box_small" id="gmi1">로</span>
                    <span class="detail-box_small" id="gmiconsult">-</span>
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

     </div><%-- /#bloodPage2 --%>
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

  // [2026-07-31 기획] 화면 2페이지 전환 — 1p(수치·그래프·평균) ↔ 2p(상세 지표)
  function bloodPage(no){
    var p1=document.getElementById('bloodPage1'), p2=document.getElementById('bloodPage2');
    if(p1) p1.style.display = (no===1)?'':'none';
    if(p2) p2.style.display = (no===2)?'':'none';
    if(no===2){
      // 평균 3종은 1페이지 값을 그대로 복사(같은 화면 원천 — 서버 재조회 없음)
      [['avgUpt','p2avg'],['avgFastingBlood','p2fast'],['after2hBlood','p2after']].forEach(function(m){
        var s=document.getElementById(m[0]), d=document.getElementById(m[1]);
        if(s && d) d.textContent = (s.textContent||'-').trim() || '-';
      });
    }
    var c=document.querySelector('.contents'); if(c) c.scrollTop=0;
    window.scrollTo(0,0);
  }
  // [2026-07-31 상세 기획] 2페이지 지표 — 차트에 그린 것과 같은 데이터(dataPoints)로 계산.
  //   TIR=70~180 비율(권장 70% 이상) / TAR=180 초과(권장 25% 미만) / TBR=70 미만(권장 4% 미만)
  //   CV=표준편차÷평균×100(권장 36% 이하) / GMI=3.31+0.02392×평균(참고치 — 색 조건 없음)
  //   ★값 색: 목표 안=초록(#2e7d32) / 벗어남=황토(#e67e22) — 메인 화면 혈당상태 색과 동일 규칙
  var P2_OK='#2e7d32', P2_WARN='#e67e22', P2_PLAIN='#2d303f';
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
    put('p2tir', tir+' %', (tir>=70)?P2_OK:P2_WARN);
    put('p2tar', tar+' %', (tar<25)?P2_OK:P2_WARN);
    put('p2tbr', tbr+' %', (tbr<4)?P2_OK:P2_WARN);
    put('p2cv',  cv +' %', (cv<=36)?P2_OK:P2_WARN);
    put('p2gmi', (3.31+0.02392*mean).toFixed(1));   // 참고치 — 검정 유지
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
						}
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
		      	 		 			      	 		
		      	 		document.getElementById('diff').textContent = (parseInt(nowUpt, 10) - parseInt(prevUpt, 10));	  
		      	 		
		      	 		let blood_status = "";
		      	 		let blood_name   = "";
		      	 		let point = (parseInt(nowUpt, 10) - parseInt(prevUpt, 10));

		      	 		if (point >= 91) {
		      	 		    blood_status = "빠르게 증가";
		      	 		    blood_name   = "혈당이 지난 30분동안  91 mg/dL  이상 증가하고 있습니다";
		      	 		} else if (point >= 61 && point <= 90) {
		      	 		    blood_status = "증가";
		      	 		    blood_name   = "혈당이 지난 30분동안  61-90 mg/dL  증가하고 있습니다";
		      	 		} else if (point >= 31 && point <= 60) {
		      	 		    blood_status = "서서히 증가";
		      	 		    blood_name   = "혈당이 지난 30분동안  31-60 mg/dL  증가하고 있습니다";
		      	 		} else if (point >= -30 && point <= 30) {
		      	 		    blood_status = "안정적";
		      	 		    blood_name   = "혈당이 지난 30분동안  30 mg/dL  이하 증가 또는 감소하고 있습니다";
		      	 		} else if (point <= -91) {
		      	 		    blood_status = "빠르게 감소";
		      	 		    blood_name   = "혈당이 지난 30분동안  91 mg/dL  이상 감소하고 있습니다"
		      	 		} else if (point >= -90 && point <= -61) {   
		      	 		    blood_status = "감소";
		      	 		    blood_name   = "혈당이 지난 30분동안  61-90 mg/dL  감소하고 있습니다";
		      	 		} else if (point >= -60 && point <= -31) {
		      	 		    blood_status = "서서히 감소";
		      	 		    blood_name   = "혈당이 지난 30분동안  31-60 mg/dL  감소하고 있습니다";
		      	 		} else {
		      	 		    blood_status = "알수없음";
		      	 		    blood_name   = "혈당값 변화의 속도와 방향을 계산할 수 없습니다";
		      	 		}

		      	 		document.getElementById('blood_status').textContent = blood_status;
		      	 		document.getElementById('blood_name').textContent   = blood_name;

		      	 		const arrowEl = document.getElementById('bloodArrow');
		      	 	    if (!arrowEl) return; // 엘리먼트가 없다면 조용히 종료

		      	 	    if (point >= 91) {
		      	 	      arrowEl.src = BLOOD_IMG.fastUp;
		      	 	      arrowEl.alt = "빠르게 증가";
		      	 	    } else if (point >= 61 && point <= 90) {
		      	 	      arrowEl.src = BLOOD_IMG.up;
		      	 	      arrowEl.alt = "증가";
		      	 	    } else if (point >= 31 && point <= 60) {
		      	 	      arrowEl.src = BLOOD_IMG.slowUp;
		      	 	      arrowEl.alt = "서서히 증가";
		      	 	    } else if (point >= -30 && point <= 30) {
		      	 	      arrowEl.src = BLOOD_IMG.normal;
		      	 	      arrowEl.alt = "안정적";
		      	 	    } else if (point <= -91) {
		      	 	      arrowEl.src = BLOOD_IMG.fastDn;
		      	 	      arrowEl.alt = "빠르게 감소";
		      	 	    } else if (point >= -90 && point <= -61) {
		      	 	      arrowEl.src = BLOOD_IMG.down;
		      	 	      arrowEl.alt = "감소";
		      	 	    } else if (point >= -60 && point <= -31) {
		      	 	      arrowEl.src = BLOOD_IMG.slowDn;
		      	 	      arrowEl.alt = "서서히 감소";
		      	 	    } else {
		      	 	      arrowEl.src = BLOOD_IMG.normal;
		      	 	      arrowEl.alt = "알수없음";
		      	 	    }
		      	 	 
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
      			
      			document.getElementById('gmi').textContent     = response.GMI;
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
	        if (fastingEl) fastingEl.textContent = Math.trunc(response.Data.fastingValue);
	        if (after2hEl) after2hEl.textContent = Math.trunc(response.Data.after2hValue);
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