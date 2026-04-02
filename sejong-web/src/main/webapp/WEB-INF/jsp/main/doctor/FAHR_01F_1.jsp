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
        <h1>연속혈당 일일보고서</h1>
      </div>
      <div class="alignRight">
        <a href="#" class="btnMenu"><span>메뉴</span></a>
      </div>
    </header>
    <!-- header : e -->

    <!-- contents : s -->
    <div class="contents">
      <!-- TOP 네임바 -->
      <article class="top_name_bar">
        <h4>홍길동</h4>
        <button class="butcon btcon_down"></button>
      </article>
      <!-- //TOP 네임바 -->

      <div class="lyInner">
        <!-- 기간 선택 -->
        <section class="date_select">
          <div class="time_wrap" id="btnWeeks">
            <button class="btn btn_sm btnCol06"  value="7">7일</button>
            <button class="btn btn_sm btnLine05" value="14">14일</button>
            <button class="btn btn_sm btnLine05" value="30">30일</button>
            <button class="btn btn_sm btnLine05" value="60">60일</button>
            <button class="btn btn_sm btnLine05" value="90">90일</button>
          </div>
          <div class="date_wrap j-center mt20">
            <div id="prevDay">2024년 7월 12일 (금)</div>
            <span>~</span>
            <div id="toDay">2024년 7월 12일 (금)</div>
          </div>
        </section>
        <!-- //기간 선택 -->
      </div>

      <!-- 혈당 수치 패널 -->
      <section class="blood_list">
        <div class="unit flx-row j-end">
          <span class="ft12">단위 : mg/dL</span>
        </div>
        <div class="top_row flx-row j-between a-center">
          <div class="left_wrap aval_wrap">
            <h6>평균 혈당</h6>
            <div class="bl_color_stable ft40" id="avg">120</div>
          </div>
          <div class="line_col" style="height: 10vw;"></div>
          <div class="center_wrap aval_wrap">
            <h6>공복 평균</h6>
            <div class="bl_color_low ft40" id="fastingAvg">65</div>
          </div>
          <div class="line_col" style="height: 10vw;"></div>
          <div class="center_wrap aval_wrap">
            <h6>식후 평균</h6>
            <div class="bl_color_high ft40" id="avgMeal">210</div>
          </div>
        </div>
        <div class="line_row"></div>
        <div class="down_row">
          <div class="range_wrap a-start">
            <h6 class="mb5">혈당관리지표(GMI)</h6>
            <div>
              <span class="data ft28 mr5" id="gmi">6.1</span>
              <span class="ft12">%</span>
            </div>
          </div>
          <div class="range_wrap a-start">
            <h6 class="mb5" >표준편차</h6>
            <div>
              <span class=" ft28 mr5" id="std">17</span>
              <span class="ft12">mg/dL</span>
            </div>
          </div>
          <div class="range_wrap a-start">
            <h6 class="mb5" >변동계수</h6>
            <div>
              <span class=" ft28 mr5" id="cv">14.7</span>
              <span class="ft12">%</span>
            </div>
          </div>
        </div>
      </section>
      <!-- //혈당 수치 패널 -->

      <div class="lyInner">
        <!-- 혈당 범위 chart -->
        <section class="blood_chart">
        	<script src="https://cdn.jsdelivr.net/npm/echarts/dist/echarts.min.js"></script>
               <!--  <img src="<c:url value='/asset/images/blood/chart_mockup2.png'/>" alt="차트2 목업" style="width: 100%;"> -->
        	<!-- 차트 영역 -->
          		<div id="lineChart" style="height: 400px; width: 100%"></div>
          	<!-- //차트 영역 -->
        </section>
        <!-- //혈당 범위 chart -->
      </div>

    </div>
    <!-- contents : e -->

  </div>
  <!-- wrap : e -->
  <script>
  var accToken = "";
  var userId = ""; 
  var now = new Date();
  var halfNow = new Date();
  halfNow.setDate(halfNow.getDate() - 7);
  document.getElementById('toDay').textContent = dateFormatFunc(now);
  document.getElementById('prevDay').textContent = dateFormatFunc(halfNow);
  
  
  $(document).ready(function() {
	    
	    getBloodUserData();
	    
	    calcBlood();
	    
	    drawBloodBarChart(now, halfNow);
	    
	});
  
  
  
  $('#btnWeeks').click(function(event) {
		 
		 const clickedButton = $(event.target);
		 
		 $('.time_wrap button').removeClass('btnCol06').addClass('btnLine05');
		 clickedButton.removeClass('btnLine05').addClass('btnCol06');
		 
		 const clickedValue = parseInt(clickedButton.val(), 10);
		 ClickedweeksBtn = clickedValue;
		 
		
		 
		 var halfNow = new Date();
		 halfNow.setDate(halfNow.getDate() - clickedValue);
		 console.log(" 날짜(halfNow) : ", halfNow);
		 
		 document.getElementById('prevDay').textContent = dateFormatFunc(halfNow);
		 
		 drawBloodBarChart(now, halfNow);
		 
		 calcBlood(now, halfNow);
		
	 });

  
	//원래라면 이미 로그인직후부터 사용자정보를 가져와야하지만.. 개발을 위해 여기서 사용자 정보 가지고 오도록함. 
	function getBloodUserData() {
    	const senseId = 'dudqls28@naver.com';
    	CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/getBloodUserData.do","POST",{userId : senseId },
			function(response){
    			console.log("find Acceess token Data success :", response);
    			accToken = response.accToken;
    			userId = response.userId;
			}
		)
	}

	function calcBlood(now,halfNow) {
  		
  		var formData = {
  	  	        start: halfNow,
  	  	        end: now,
  	  	        userId: userId
  	  	    };
  		
      	CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/calcBlood.do","POST",formData,
  			function(response){
      			console.log("GMI, 표준편차, 변동계수 가져옴. :", response);
      			
      			document.getElementById('gmi').textContent = response.GMI;
      			document.getElementById('std').textContent = response.stdBlood;
      			document.getElementById('cv').textContent = response.CV;
      			document.getElementById('fastingAvg').textContent = Math.round(response.FASTING);
      			document.getElementById('avg').textContent = Math.round(response.AvgBlood);
      			
      			document.getElementById('avgMeal').textContent = Math.round(response.avgMeal.avgBlood);
      	 		
  			}
  		)
  	};

	
	
	
	
	function drawBloodBarChart(endDate, startDate) {
  	    //console.log("막대 차트 그리기 // halfNow : ", halfNow, "now :", now);
  	    var formData = {
  	        start: startDate,
  	        end: endDate,
  	        userId: userId
  	    };

  	    CommonUtil.callAjax(CommonUtil.getContextPath() + "/drawBloodBarChart.do", "POST", formData,
  	        function(response) {
  	            console.log("스택 막대 차트를 위한 데이터 가져오기 성공 :", response);

  	          	var total = response.LOWEST + response.LOW + response.NORMAL + response.HIGHT;
  	    
  	     		var lowestPercentage = (total === 0) ? 0 : Math.round((response.LOWEST / total) * 100);
  	     		var lowPercentage = (total === 0) ? 0 : Math.round((response.LOW / total) * 100);
  	     		var normalPercentage = (total === 0) ? 0 : Math.round((response.NORMAL / total) * 100);
  	     		var highPercentage = (total === 0) ? 0 : Math.round((response.HIGHT / total) * 100);

  	     
  	            var xAxisData = []; 
  	            var seriesData = [];

  	           
  	            var chart = echarts.init(document.getElementById('lineChart'));

  	            
  	            var option = {
  	                title: {
  	                    text: '혈당 범위 차트'
  	                },
  	                tooltip: {},
  	                xAxis: {
  	                    type: 'category',
  	                    data: ['A', '', '', ''], // x축 데이터
  	                    axisLabel: {
  	                        align: 'center'
  	                    },
  	                    position: 'bottom',
  	                },
  	                yAxis: {
  	                    type: 'value',
  	                    min: 0,
  	                    max: 250,
  	                    axisLabel: {
  	                        formatter: '{value}'
  	                    },
  	                    splitLine: {
  	                        show: true,
  	                        lineStyle: {
  	                            color: '#ddd',
  	                            type: 'dashed',
  	                            width: 1
  	                        }
  	                    }
  	                },
  	                series: [
  	                    {
  	                        name: '혈당',
  	                        type: 'bar',
  	                        data: [54], 
  	                        itemStyle: { color: 'grey' },
  	                        barWidth: '40%',
  	                        stack: 'A', 
  	                        markLine: {
  	                            data: [
  	                                {
  	                                    yAxis: 220,
  	                                    lineStyle: {
  	                                        color: 'red',
  	                                        width: 2
  	                                    },
  	                                    label: {
  	                                        show: true,
  	                                        position: 'middle',
  	                                      	formatter: function() {
  	                                        	return '높음   ' + highPercentage + ' %';  // 함수로 값을 반환
  	                                    	},
  	                                        color: 'red',
  	                                        fontSize: 12
  	                                    },
  	                                    symbol: 'none', 
  	                                    symbolSize: 0, 
  	                                },
  	                                {
  	                                    yAxis: 150,
  	                                    lineStyle: {
  	                                        color: 'orange',
  	                                        width: 2
  	                                    },
  	                                    label: {
  	                                        show: true,
  	                                        position: 'middle',
  	                                      	formatter: function() {
	                                        	return '중간   ' + normalPercentage + ' %';  // 함수로 값을 반환
	                                    	},
  	                                        color: 'orange',
  	                                        fontSize: 12
  	                                    },
  	                                    symbol: 'none', 
  	                                    symbolSize: 0, 
  	                                },
  	                                {
  	                                    yAxis: 66, 
  	                                    lineStyle: {
  	                                        color: 'blue',
  	                                        width: 2
  	                                    },
  	                                    label: {
  	                                        show: true,
  	                                        position: 'middle',
  	                                      	formatter: function() {
	                                        	return '낮음   ' + lowPercentage + ' %';  // 함수로 값을 반환
	                                    	},
  	                                        color: 'blue',
  	                                        fontSize: 12
  	                                    },
  	                                    symbol: 'none',
  	                                    symbolSize: 0, 
  	                                },
  	                              {
  	                                    yAxis: 25, 
  	                                    lineStyle: {
  	                                        color: 'blue',
  	                                        width: 2
  	                                    },
  	                                    label: {
  	                                        show: true,
  	                                        position: 'middle',
  	                                      	formatter: function() {
	                                        	return '매우 낮음   ' + lowestPercentage + ' %';  // 함수로 값을 반환
	                                    	},
  	                                        color: 'blue',
  	                                        fontSize: 12
  	                                    },
  	                                    symbol: 'none',
  	                                    symbolSize: 0, 
  	                                }
  	                            ]
  	                        }
  	                    },
  	                    {
  	                        name: '낮음',
  	                        type: 'bar',
  	                        data: [30],
  	                        itemStyle: { color: 'yellow' },
  	                        barWidth: '40%',
  	                        stack: 'A' 
  	                    },
  	                    {
  	                        name: '정상',
  	                        type: 'bar',
  	                        data: [110], 
  	                        itemStyle: { color: 'green' },
  	                        barWidth: '40%',
  	                        stack: 'A' 
  	                    },
  	                    {
  	                        name: '높음',
  	                        type: 'bar',
  	                        data: [40], 
  	                        itemStyle: { color: 'orange' },
  	                        barWidth: '40%',
  	                        stack: 'A' 
  	                    },
  	                  {
  	                        name: '매우높음',
  	                        type: 'bar',
  	                        data: [20], 
  	                        itemStyle: { color: 'grey' },
  	                        barWidth: '40%',
  	                        stack: 'A' 
  	                    }
  	                ]
  	            };

  	           
  	            chart.setOption(option);
  	        }
  	    );
  	}

  	
	

  //포맷 함수
  function formatDate(date) {
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0'); 
      const day = String(date.getDate()).padStart(2, '0');
      const hours = String(date.getHours()).padStart(2, '0');
      const minutes = String(date.getMinutes()).padStart(2, '0');
      const seconds = String(date.getSeconds()).padStart(2, '0');
      
      return year+"-"+month+"-"+day+"T"+hours+":"+minutes+":"+seconds;
  }

  
  function timeFormatFunc(timeOri){
 	const date = new Date(timeOri);
 	
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

	  function stringToDate(oriString){
	  	 var dateParts = oriString.match(/(\d{4})년\s(\d{1,2})월\s(\d{1,2})일/);
	  	 
	  	 var year = parseInt(dateParts[1]);
	  	 var month = parseInt(dateParts[2]) - 1; 
	  	 var day = parseInt(dateParts[3]);

	  	 const date = new Date(year, month, day);
	  	 return date;
	  	 
	  }
  </script>
</body>
</html>
