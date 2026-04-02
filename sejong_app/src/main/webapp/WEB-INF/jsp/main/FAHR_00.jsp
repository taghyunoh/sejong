<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>  
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link href="/asset/css/blood_fahr.css?v=123" rel="stylesheet"> <!-- ASQ 스타일   -->
<title>Insert title here</title>
</head>
<body>
    <!-- contents : s -->
    <div class="contents">
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
          <div id="lineChart" style="height: 300px; width: 100%"></div>
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
		
      </section>
      <section class="blood_list">
        <div class="top_row flx-row j-between a-center">
          <div class="left_wrap aval_wrap">
            <h6> GMI지수(%)</h6>
            <span class="bl_color_stable ft40" id="gmi" data-value="-">-</span>
          </div>
          <div class="line_col" style="height: 10vw;"></div>
    	  <div class="center_wrap aval_wrap">
	        <h6>TIR(%)</h6>
	        <div>
	           <span class="bl_color_stable ft40" id="tir" data-value="-">-</span>
	         </div>
	      </div>
	      <div class="line_col" style="height: 10vw;"></div>
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
        <!-- contents : e -->
    </div>
  <script>
  
  var accessToken = "";
  var userId = ""; 
  
  var now = new Date();
  var halfNow = new Date();
  halfNow.setHours(halfNow.getHours() - 24);
  
  const BLOOD_IMG = {
		    fastUp:  "<c:url value='/asset/images/blood/blood_arrow_sspeeh_h.png'/>",
		    up:      "<c:url value='/asset/images/blood/blood_arrow_speeh_h.png'/>",
		    slowUp:  "<c:url value='/asset/images/blood/blood_arrow_slow_h.png'/>",
		    normal:  "<c:url value='/asset/images/blood/blood_arrow.svg'/>",
		    fastDn:  "<c:url value='/asset/images/blood/blood_arrow_sspeeh_l.png'/>",
		    down:    "<c:url value='/asset/images/blood/blood_arrow_speeh_l.png'/>",
		    slowDn:  "<c:url value='/asset/images/blood/blood_arrow_slow_l.png'/>"
		  };
  
  $(document).ready(function() {
	    // 토큰 정보 
 	    const urlParams = new URLSearchParams(window.location.search);
  		CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/tokenYn.do","POST",'',function(response){
			console.log(response.Data);
			if(!response.IsSucceed){
				// token 가져오는 로직
				if(urlParams.get('code') == null){
					alert("i-sens에서 혈당 정보를 가져오기 위해 로그인 정보가 필요합니다.");
					getAuth();
				}else{
		    		getToken();
		    	}
				return;
			}
		});   
 		
		// userId : "${sessionScope.userUuid}"
		
		todayExecs();
	    getBloodUserData();
	    getBloodData();
	    orderby();
	});
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
			async: false,
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
							refreshToken();
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
		      	 		
		      	 		document.getElementById('avgUpt').textContent = Math.round(response.aveUpt)|| 0;
		      	 		 			      	 		
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
	    	if(response.Data.length>0){
	    		foodChartData = response.Data;
	    	}
	    	console.log(foodChartData);
	    });

	    CommonUtil.callAjax(CommonUtil.getContextPath() + "/getBloodChartData.do", "POST", formData, function(response) {
	
	        
	        var bloodData = Array.isArray(response) ? response : [JSON.parse(response)];
	        bloodData = bloodData || [];

	        function parseTime(dtm) {
	            return new Date(dtm.replace('Z', ''));
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
	        var chart = echarts.init(document.querySelector("#lineChart"));
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
	                bottom: '3%',
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
	const date = new Date(timeOri.replace('Z', ''));
	
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