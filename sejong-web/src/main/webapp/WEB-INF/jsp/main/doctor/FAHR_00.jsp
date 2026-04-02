<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>  
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
 <!-- wrap : s -->
  <div class="wrap">
    <!-- header : s -->
    <header class="header">
      <div class="alignLeft">
        <a href="#" class="btnPrev"><span>이전 페이지로 이동</span></a>
      </div>
      <div class="alignTitle">
        <h1>연속혈당측정</h1>
      </div>
      <div class="alignRight">
        <a href="#" class="btnMenu"><span>메뉴</span></a>
      </div>
    </header>
    <!-- header : e -->

    <!-- contents : s -->
    <div class="contents">
      <!-- 혈당 대시보드 -->
      <article class="top_board_blood">
        <div class="prev_wrap">
          <div class="data" id="prevBloodUpt">0</div>
          <div class="time" id="prevBloodDtm">오후 8:15</div>
        </div>
        <div class="gap_wrap">
          <div class="up_row">
            <!-- 화살표 .up .down 클래스 추가 -->
            <span class="blood_arrow up">
              <img src="<c:url value='/asset/images/blood/blood_arrow.svg'/>" alt="범위내화살표" class="bl_nomal">
              <img src="<c:url value='/asset/images/blood/blood_arrow_high.svg'/>" alt="고혈당" class="bl_high hide">
              <img src="<c:url value='/asset/images/blood/blood_arrow_low.svg'/>" alt="저혈당" class="bl_low hide">
            </span>
            <span class="diff" id="diff">5.0</span>
          </div>
          <div class="down_row">mg/dL/min</div>
        </div>
        <div class="now_wrap">
          <div class="data" id="nowBloodUpt">5</div>
          <div class="time" id="nowBloodDtm">오후 8:20</div>
        </div>
      </article>
      <!-- //혈당 대시보드 -->
      <div class="lyInner">
        <!-- 날짜 & 시간 선택 -->
        <section class="date_select">
          <div class="date_wrap">
            <a href="#"><span class="material-symbols-outlined icon" id="prevDay">chevron_left</span></a>
            <div id="nowDTM">2024년 2월 1일 (월)</div>
            <a href="#"><span class="material-symbols-outlined icon" id="nextDay">chevron_right</span></a>
          </div>
          <div class="time_wrap mt20" id="btnHours">
            <button class="btn btn_sm btnLine05" value="1">1시간</button>
            <button class="btn btn_sm btnLine05" value="3">3시간</button>
            <button class="btn btn_sm btnLine05" value="6">6시간</button>
            <button class="btn btn_sm btnCol06"  value="12">12시</button>
            <button class="btn btn_sm btnLine05" value="24">24시</button>
          </div>
        </section>
        <!-- //날짜 & 시간 선택 -->

        <!-- 연속혈당 chart -->
        <section class="blood_chart">
          <script src="https://cdn.jsdelivr.net/npm/echarts/dist/echarts.min.js"></script>
          <!-- 차트 영역 -->
          <div id="lineChart" style="height: 200px; width: 100%"></div>
          <!-- //차트 영역 -->
          
        </section>
        <!-- //연속혈당 chart -->
      </div>

      <!-- 혈당 수치 패널 -->
      <section class="blood_list">
        <div class="unit flx-row j-end">
          <span class="ft12">단위 : mg/dL</span>
        </div>
        <div class="top_row flx-row j-between a-center">
          <div class="left_wrap aval_wrap">
            <h6>평균 혈당</h6>
            <div class="bl_color_stable ft40" id="avgUpt">100</div>
          </div>
          <div class="line_col" style="height: 10vw;"></div>
          <div class="center_wrap aval_wrap">
            <h6>공복 평균</h6>
            <div class="bl_color_low ft40" id="avgFastingBlood">65</div>
          </div>
          <div class="line_col" style="height: 10vw;"></div>
          <div class="center_wrap aval_wrap">
            <h6>식후 평균</h6>
            <div class="bl_color_high ft40" id="avgMeal">210</div>
          </div>
        </div>
        <div class="mid_row left_right_wrap">
          <div class="left_wrap">
            <h6 class="mr20">표준편차</h6>
            <span class="ft20 mr5" id="std">20</span>
            <span class="ft12">mg/dL</span>
          </div>
          <div class="right_wrap">
            <h6 class="mr20">변동계수</h6>
            <span class=" ft20 mr5" id="cv">35</span>
            <span class="ft12">%</span>
          </div>
        </div>
        <div class="line_row"></div>
        <div class="down_row">
          <div class="range_wrap">
            <h6 class="mb5" >매우 낮음</h6>
            <div>
              <span class="data ft28 mr5" id="lowest" value="">2</span>
              <span class="ft12">%</span>
            </div>
          </div>
          <div class="range_wrap">
            <h6 class="mb5">저혈당</h6>
            <div>
              <span class=" ft28 mr5" id="low" value="">4</span>
              <span class="ft12">%</span>
            </div>
          </div>
          <div class="range_wrap">
            <h6 class="mb5">목표 내</h6>
            <div>
              <span class=" ft28 mr5" id="normal" value="">88</span>
              <span class="ft12">%</span>
            </div>
          </div>
          <div class="range_wrap">
            <h6 class="mb5">고혈당</h6>
            <div>
              <span class=" ft28 mr5" id="high" value="">6</span>
              <span class="ft12">%</span>
            </div>
          </div>
        </div>
      </section>
      <!-- //혈당 수치 패널 -->

      <!-- 식사 & 운동 -->
      <div class="lyInner food_walk_wrap flx-row j-center a-strech">
        <!-- 식사 패널 -->
        <section class="food_wrap mr10">
          <div class="title_row mb20">
            <img src="<c:url value='/asset/images/blood/icon_food_01.png'/>" alt="식사 아이콘" class="mr10">
            <h5>식사</h5>
            <span class="time ft12">오후 1:13</span>
          </div>
          <div class="data_list">
            <dl>
              <dt>칼로리</dt>
              <dd class="data">750</dd>
              <dd>kcal</dd>
            </dl>
            <dl>
              <dt>탄수화물</dt>
              <dd class="data">200</dd>
              <dd>g</dd>
            </dl>
            <dl>
              <dt>단백질</dt>
              <dd class="data">500</dd>
              <dd>g</dd>
            </dl>
            <dl>
              <dt>지방</dt>
              <dd class="data">50</dd>
              <dd>g</dd>
            </dl>
            <dl>
              <dt>식후혈당</dt>
              <dd class="data">170</dd>
              <dd>mg/dL</dd>
            </dl>
          </div>
        </section>
        <!-- //식사 패널 -->

        <!-- 운동 패널 -->
        <section class="walk_wrap">
          <div class="title_row mb20">
            <img src="<c:url value='/asset/images/blood/icon_walk_01.png'/>" alt="식사 아이콘" class="mr10">
            <h5>오늘 운동</h5>
          </div>
          <div class="data_list">
            <div class="range_wrap">
              <div class="range_bar">
                <div class="range" style="width: 90%;"></div>
              </div>
            </div>
            <dl>
              <dt>걸음수</dt>
              <dd class="data">5752</dd>
              <dd>
                <span>/</span>
                <span>6000</span>
              </dd>
            </dl>
            <dl>
              <dt>활동시간</dt>
              <dd class="data">59</dd>
              <dd>분</dd>
            </dl>
            <dl>
              <dt>칼로리</dt>
              <dd class="data">230</dd>
              <dd>
                <span>/</span>
                <span>500</span>
              </dd>
            </dl>
            <dl>
              <dt>거리</dt>
              <dd class="data">5.2</dd>
              <dd>km</dd>
            </dl>
          </div>
        </section>
        <!-- //운동 패널 -->
      </div>
      <!-- //식사 & 운동 -->

      <!-- 일일보고서 버튼 -->
      <div class="lyInner pt0">
        <button class="btn btn_lg btnLine05">일일보고서</button>
      </div>

    </div>
    <!-- contents : e -->

  </div>
  <!-- wrap : e -->
  <script>
  var accessToken = "";
  var userId = ""; 
  
  var now = new Date();
  var halfNow = new Date();
  halfNow.setHours(halfNow.getHours() - 12);
  
  
  
  $(document).ready(function() {
	    
	    getBloodUserData();
	    
	    orderby();
	   
	});
  
  
  function orderby(){
	  
		//getBloodData();
	    //console.log("혈당 데이터가져오기 성공 ");
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
	    const today = new Date();
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
	 
 
	 
	//원래라면 이미 로그인직후부터 사용자정보를 가져와야하지만.. 개발을 위해 여기서 사용자 정보 가지고 오도록함. 
  	function getBloodUserData() {
		//console.log("저장된 사용자 엑세스 토큰 + UUID 가져오기 function");    
	    const senseId = 'dudqls28@naver.com';
		     
	    CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/getBloodUserData.do","POST",{userId : senseId },
	  		function(response){
	    		//console.log("find Acceess token Data success :", response);
	      		accessToken = response.accToken;
	      		userId = response.userId;
	      	 		
	      		//console.log("> ACC_TOKEN:", accessToken);
	      	    //console.log("> USER_UUID:", userId);
	      	      
	  		}
	  	)
	}

 
  
  //혈당 데이터 가져오기
  function getBloodData(){
	  
	  $.ajax({
		    url: '/getBloodData.do',
			type: 'GET',
			data: {
				//start: '2024-03-12T16:50:20+09:00', // 시작 시간
	            //end: '2024-03-12T17:23:20+09:00',    // 종료 시간
	             start : '2024-08-12T16:28:36+09:00',
		            end: '2024-08-17T17:23:20+09:00',
	            accessToken : accessToken,
	            goTokenUrl : 'https://api.i-sens.com/v1/public/cgms',
	            userId : userId
				  },
			success: function(response) {
				    console.log("Blood Data received:", response);
				    },
			error: function(xhr, status, error) {
				   	console.log('Error: ' + error);
				 	}     
		});    
  }

 
  //센서 데이터 가져오기.
  function getSensorInfo(){
	  
	  $.ajax({
			url: '/getData.do',
			type: 'GET',
			data: {
					//start: '2024-02-26T16:28:36+09:00', // 시작 시간
		            //end: '2024-03-12T17:23:20+09:00',    // 종료 시간
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




  //날짜, 현재혈당, 5분전 혈당 등등 각종 가져오기
  function showBloodData(endDate, startDate){
	  
	  var formData = {
	    		start : formatDate(startDate),
	    		end : formatDate(endDate),
	    		userId : userId
	    	}

	  CommonUtil.callAjax(CommonUtil.getContextPath() + "/showBloodData.do","POST",formData,
	  			function(response){
	      	 		console.log("혈당디비에 있는 데이터 가져오기 성공  :", response);
	      	 			
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
	      	 		
	  			}
	  	)	  	
	  	
	    CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/calcBlood.do","POST",formData,
  			function(response){
      			console.log("표준편차, 변동계수 가져옴. :", response);
      			
      			document.getElementById('std').textContent = response.stdBlood;
      			document.getElementById('cv').textContent = response.CV;
      			document.getElementById('avgMeal').textContent = response.avgMeal.avgBlood;
      	 		
  			}
  		)
	  	
 	}
  
  
  
  //공복평균_ 식사이벤트가 있을때만 발생
  function getAvgFastingBlood(){
	  var formData = {
	    		userId : userId,
	    		date :  formatDate(now) //현재 접속한 시간 
	    	}
	  
	  CommonUtil.callAjax(CommonUtil.getContextPath() + "/getAvgFastingBlood.do","POST",formData ,
	  			function(response){
	      	 		//console.log("공복 혈당 가져오기 success :", response);
	      	 		document.getElementById('avgFastingBlood').textContent = Math.trunc(response.Data);
	      	 	}
	  	)	  
  }
  
  
  
  //퍼센테지 
  function getPercentage(endDate, startDate){

	  var formData = {
			  userId: userId,
	            start: formatDate(startDate), 
	            end: formatDate(endDate)
	    	}
	  
	  CommonUtil.callAjax(CommonUtil.getContextPath() + "/drawBloodBarChart.do","POST",formData ,
	  			function(response){
	      	 		//console.log("퍼센테지 가져오기 success :", response);
	      	 		
	 	  	            var total = response.LOWEST + response.LOW + response.NORMAL + response.HIGHT;

	 	  	         	var lowestPercentage = total > 0 ? Math.round((response.LOWEST / total) * 100) : 0;
	 	  	         	var lowPercentage = total > 0 ? Math.round((response.LOW / total) * 100) : 0;
	 	  	         	var normalPercentage = total > 0 ? Math.round((response.NORMAL / total) * 100) : 0;
	 	  	         	var highPercentage = total > 0 ? Math.round((response.HIGHT / total) * 100) : 0;
	 	  	            

	 	  	         	document.getElementById('lowest').textContent = lowestPercentage;
	 	  	         	document.getElementById('low').textContent = lowPercentage;
	 	  	      		document.getElementById('normal').textContent = normalPercentage;
	 	  	   			document.getElementById('high').textContent = highPercentage;
		      	 				
	      	 	}
	  )
  }
  

  function drawBloodSugarChart(endDate, startDate) { 
	    console.log("차트그리기 startDate :", formatDate(startDate), " // ", "endDate : ", formatDate(endDate));

	    var formData = {
	        userId: userId,
	        start: formatDate(startDate), 
	        end: formatDate(endDate)
	    };

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
	        
     
	        
			dataPoints.forEach(function(dp) {
			    var dpHours = dp.time.getHours().toString();  //dp.time.getUTCHours().toString().padStart(2, '0');
			    var dpMinutes = dp.time.getMinutes().toString().padStart(2, '0'); //dp.time.getUTCMinutes().toString().padStart(2, '0');
			    var dpTime = dpHours + ':' + dpMinutes;

		
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
	                    {gt: 0, lte: 70, color: 'red'},
	                    {gt: 70, lte: 180, color: 'green'},
	                    {gt: 180, lte: 400, color: 'orange'}
	                ]
	            },
	            grid: {
	                left: '3%',
	                right: '10%',
	                bottom: '10%',
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
	                            return '오전 6시';
	                        }
	                      
	                        else if (!alreadyLabeled['12']&& (hours === 12 && minutes <= 5 || (hours === 12 && minutes >= 55))) {
	                            alreadyLabeled['12'] = true; 
	                            return '오후 12시';
	                        }
	                  
	                        else if (!alreadyLabeled['18']&& (hours === 18 && minutes <= 5 || (hours === 18 && minutes >= 55))) {
	                            alreadyLabeled['18'] = true;
	                            return '오후 6시';
	                        }
	                        else {
	                            return ""; 
	                        }
	                    });
	                })(),
	                axisLabel: {
	                    interval: 0,
	                    fontWeight: 'bold'
	                }
	            },

	            yAxis: {
	                type: 'value',
	                min: 0,
	                max: 400,
	                axisLabel: {
	                    show: false
	                },
	                axisLine: {
	                    lineStyle: {
	                        color: '#000',
	                    }
	                }
	            },
	            series: [{
	                data: seriesData,
	                type: 'line',
	                smooth: true,
	                symbol: 'circle',
	                symbolSize: 4,
	                lineStyle: {
	                    type: 'solid',
	                    width: 2
	                },
	                markLine: {
	                    data: [
	                        { yAxis: 70, lineStyle: { color: 'red', type: 'dashed', width: 1.5 }, symbol: 'none' },
	                        { yAxis: 150, lineStyle: { color: 'yellow', type: 'dashed', width: 1.5 }, symbol: 'none' },
	                        { yAxis: 400, lineStyle: { color: 'grey', type: 'dashed', width: 1.5 }, symbol: 'none' }
	                    ]
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
	            }
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
     const year = date.getFullYear();
     const month = String(date.getMonth() + 1).padStart(2, '0'); // 월은 0부터 시작
     const day = String(date.getDate()).padStart(2, '0');
     const hours = String(date.getHours()).padStart(2, '0');
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

  
  </script>
</body>
</html>