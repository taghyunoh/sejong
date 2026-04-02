<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />

  <!-- 부트스트랩 css -->
  <link href="/bootstrap/css/bootstrap.css" rel="stylesheet">

  <link href="/asset/css/common.css" rel="stylesheet">
  <link href="/asset/component/sub_teb_menu.css" rel="stylesheet" />

<title>${sessionScope['t_user_nm']}님 정보</title>
<script src="/js/main.js"></script>
<script src="https://cdn.jsdelivr.net/npm/echarts/dist/echarts.min.js"></script>
<script src="/asset/js/echarts/echarts.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/0.5.0-beta4/html2canvas.min.js"></script>
<style>
    @media print {
        .no-print {
            display: none;    
            }    
    }
  </style>
<script type="text/javascript">

    $(document).ready(function () {
        // 기간 조회 인터렉션
        $('.date-search-wrap button').click(function () {
          $('.date-search-wrap button').removeClass('btn-primary');
          $('.date-search-wrap button').addClass('btn-outline-primary');
          $(this).removeClass('btn-outline-primary');
          $(this).addClass('btn-primary');
        });
        
        // 서브 탭메뉴 인터렉션
        $('.stab-item a').click(function () {
            $('.stab-item a').removeClass('active');
            $('.stab-content').removeClass('active');
            $(this).addClass('active');
            $($(this).attr('href')).addClass('active');
        });

        // 생년월일을 바탕으로 나이 계산
        function calculateAge(birthDate) {
            var birthYear = parseInt(birthDate.substring(0, 4));
            var birthMonth = parseInt(birthDate.substring(4, 6));
            var birthDay = parseInt(birthDate.substring(6, 8));

            var today = new Date();
            var age = today.getFullYear() - birthYear;
            var month = today.getMonth() + 1;
            var day = today.getDate();

            if (month < birthMonth || (month === birthMonth && day < birthDay)) {
                age--;
            }

            return age;
        }

        // 문서가 준비되면 나이 계산 및 표시
        var birthDate = "${sessionScope['t_birth']}";
        var age = calculateAge(birthDate);
        $('#age').text(age);

        // 성별을 한글로 변환
        var gender = "${sessionScope['t_gender']}";
        var genderText = (gender === 'F') ? '여성' : (gender === 'M') ? '남성' : '알 수 없음';
        $('#gender').text(genderText);
        $('#7days').trigger('click');
    });
    
    function fnPdf() {
        
    }
    
    function fnPrint() {
    	var initBody;
    	 window.onbeforeprint = function(){
    	  initBody = document.body.innerHTML;
    	  document.body.innerHTML =  document.getElementById('print').innerHTML;
    	 };
    	 window.onafterprint = function(){
    	  document.body.innerHTML = initBody;
    	 };
        window.print();
    }

    function selectWeek() {
    	var userId = "${sessionScope['t_user_uuid']}";
    	var today = "${sessionScope['t_end_date']}";
		var year = today.substring(0,4);
	    var month = today.substring(5,7);
	    var day = today.substring(8,10);
	    var end_date = year+ "-" + month + "-" +day; 
		/* var end_date = today.substring(0,10); */
			    
	    // 7일 전의 날짜 계산
	    var endDate = new Date(year, month - 1, day);  // 월은 0부터 시작
	    endDate.setDate(endDate.getDate() - 7);
	    var start_year = endDate.getFullYear();
	    var start_month = ('0' + (endDate.getMonth() + 1)).slice(-2);
	    var start_day = ('0' + endDate.getDate()).slice(-2);
	    var start_date = start_year + '-' + start_month + '-' + start_day;
	    
	    // 날짜 설정
	    $("#start_date").val(start_date);
	    $("#end_date").val(end_date);
		 
	    drawBloodBarChart(start_date, end_date,userId);
		calcBlood(start_date, end_date,userId);
		drawMealsAveChart(start_date, end_date, userId);
	}
    
    function select2Weeks() {
    	var userId = "${sessionScope['t_user_uuid']}";
    	var today = "${sessionScope['t_end_date']}";
		var year = today.substring(0,4);
	    var month = today.substring(5,7);
	    var day = today.substring(8,10);
	    var end_date = year+ "-" + month + "-" +day; 
		/* var end_date = today.substring(0,10); */
	    
	    // 14일 전의 날짜 계산
	    var endDate = new Date(year, month - 1, day);  // 월은 0부터 시작
	    endDate.setDate(endDate.getDate() - 14);
	    var start_year = endDate.getFullYear();
	    var start_month = ('0' + (endDate.getMonth() + 1)).slice(-2);
	    var start_day = ('0' + endDate.getDate()).slice(-2);
	    var start_date = start_year + '-' + start_month + '-' + start_day;
	    
	    // 날짜 설정
	    $("#start_date").val(start_date);
	    $("#end_date").val(end_date);
	    drawBloodBarChart(start_date, end_date,userId);
		calcBlood(start_date, end_date,userId);
		//drawMealsAveChart(start_date, end_date, userId);
	}
    
	function selectMonth() {
		var userId = "${sessionScope['t_user_uuid']}";
		/* var today = new Date();
	    var year = today.getFullYear();
	    var month = ('0' + (today.getMonth() + 1)).slice(-2);
	    var day = ('0' + today.getDate()).slice(-2); */
	    var today = "${sessionScope['t_end_date']}";
		var year = today.substring(0,4);
	    var month = today.substring(5,7);
	    var day = today.substring(8,10);
	    var end_date = year+ "-" + month + "-" +day; 
		/* var end_date = today.substring(0,10); */

	    // 한 달 전의 날짜 계산
	    var endDate = new Date(year, month - 1, day);  // 월은 0부터 시작
	    endDate.setMonth(endDate.getMonth() - 1);
	    var start_year = endDate.getFullYear();
	    var start_month = ('0' + (endDate.getMonth() + 1)).slice(-2);
	    var start_day = ('0' + endDate.getDate()).slice(-2);
	    var start_date = start_year + '-' + start_month + '-' + start_day;

	    // 날짜 설정
	    $("#start_date").val(start_date);
	    $("#end_date").val(end_date);
	    drawBloodBarChart(start_date, end_date,userId);
		calcBlood(start_date, end_date,userId);
		//drawMealsAveChart(start_date, end_date, userId);
	}
	
		function calcBlood(start_date, end_date,userId) {

	  		var formData = {
	  	  	        start: start_date,
	  	  	          end: end_date,
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
	      			
	      			document.getElementById('gmi2').textContent = response.GMI;
	      			document.getElementById('std2').textContent = response.stdBlood;
	      			document.getElementById('cv2').textContent = response.CV;
	      			document.getElementById('fastingAvg2').textContent = Math.round(response.FASTING);
	      			document.getElementById('avg2').textContent = Math.round(response.AvgBlood);
	      			document.getElementById('avgMeal2').textContent = Math.round(response.avgMeal.avgBlood);
	      	 		
	  			}
	  		)
	  	};

		
		function drawBloodBarChart(start_date, end_date,userId) {
	  	    //console.log("막대 차트 그리기 // halfNow : ", halfNow, "now :", now);
	  	    var formData = {
	  	        start: start_date,
	  	          end: end_date,
	  	       userId: userId
	  	    };

	  	    CommonUtil.callAjax(CommonUtil.getContextPath() + "/drawBloodBarChart.do", "POST", formData,
	  	        function(response) {
	  	          
	  	          	var total = response.LOWEST + response.LOW + response.NORMAL + response.HIGHT;
	  	    
	  	     		var lowestPercentage = (total === 0) ? 0 : Math.round((response.LOWEST / total) * 100);
	  	     		var lowPercentage = (total === 0) ? 0 : Math.round((response.LOW / total) * 100);
	  	     		var normalPercentage = (total === 0) ? 0 : Math.round((response.NORMAL / total) * 100);
	  	     		var highPercentage = (total === 0) ? 0 : Math.round((response.HIGHT / total) * 100);

	  	            var xAxisData = []; 
	  	            var seriesData = [];

	  	            var chart = echarts.init(document.getElementById('agpChart'));
	  	            var chart2 = echarts.init(document.getElementById('mainChart'));
	  	            
	  	            var option = {
	  	                title: {
	  	                    text: '목표 내 혈당'
	  	                },
	  	                tooltip: {},
	  	                xAxis: {
	  	                    type: 'category',
	  	                    data: ['A', '', ''], // x축 데이터
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
	  	                        name: '목표 내 혈당',
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
	  	            chart2.setOption(option);
	  	        });
	  	}
		
	 	//통계 2번째 차트
	function drawMealsAveChart(start_date, end_date, userId) {
		 		console.log("차트2222>>>>>>>>>>>>>>>>>>"+userId+">>>"+start_date);
	    $.ajax({
	        type: "post",
	        url: "/drawMealsAveChart.do",
	        data: {
	            start: start_date,
	            end: end_date,
	            userId: userId
	        },
	        dataType: "json",
	        success: function(data) {  
	            console.log("차트2222응답 데이터:", data); // 응답 데이터 로그
	
	            var myChart = echarts.init(document.getElementById('mealAveChart'));
	
	            var xAxisData = []; 
	            var seriesData = [];
	            // 응답 데이터에서 날짜와 평균 혈당 값 추출
	            var dates = data.map(function(item) {
	                return item.date; // 날짜
	            });
	            var avgBloodValues = data.map(function(item) {
	                return item.avgBlood; // 평균 혈당 값
	            });
	
		 		console.log("차트2222>>>>>>>>>>>>>>>>>>"+dates);
	            // 차트 옵션 설정
	            var option = {
	                title: {
	                    text: '식후 평균 혈당'
	                },
	                tooltip: {
	                    trigger: 'axis'
	                },
	                xAxis: {
	                    type: 'category',
	                    data: dates,
	                    axisLabel: {
	                        formatter: '{value}'
	                    }
	                },
	                yAxis: {
	                    type: 'value',
	                    min: 70, // y축 최소값
	                    max: 250, // y축 최대값
	                    interval: 20,
	                    axisLine: {
	                        lineStyle: {
	                            color: '#333'
	                        }
	                    },
	                    axisLabel: {
	                        formatter: '{value}'
	                    },
	                    splitLine: {
	                        show: false // 간격 줄 숨기기
	                    }
	                },
	                series: [
	                    {
	                        name: '평균 혈당',
	                        type: 'line', // 선형 차트
	                        data: avgBloodValues,
	                        itemStyle: {
	                            color: '#3398DB' // 선 색상
	                        },
	                        lineStyle: {
	                            color: '#3398DB' // 선 색상
	                        },
	                        markArea: {
	                            data: [
	                                [{
	                                    name: '',
	                                    yAxis: 70
	                                }, {
	                                    yAxis: 140,
	                                    itemStyle: {
	                                        color: '#F5F5DC' // 배경 색상
	                                    }
	                                }]
	                            ]
	                        }
	                    }
	                ]
	            };
	            // 차트 옵션 적용
	            myChart.setOption(option);
	        }
	    });
	}
</script>
</head>
<body>
<div class="tab-pane">  
	<div class="content-body">
			<!-- <div class="search-box"><br>&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;
				<button type="button" class="btn btn-outline-dark btn-sm"
					onclick="javascript:history.back();">회원목록</button>
			</div> -->
		<div class="tab-content">
		<div class="content-wrap">
			<div class="flex-left-right mb-10">
				<!-- 기본 정보 start -->
				<div class="patient-info">
					<div class="info-name">${sessionScope['t_user_nm']}님</div>
					 <input type="hidden" name="user_uuid" id="user_uuid" value="${sessionScope['t_user_id']}"/>
  					<div class="info-age">
						<span>${sessionScope['t_birth'].substring(0, 4)}년
							${sessionScope['t_birth'].substring(4, 6)}월
							${sessionScope['t_birth'].substring(6, 8)}일</span> 만<span id="age"></span>세
						<span id="gender"></span>
					</div>
					<div class="info-bmi">
						<span>BMI(체질량 지수)</span>
						<span>${sessionScope['t_bmi']}</span>
					</div>
				</div>
				<!-- //기본 정보 end -->

				<!-- 혈당 정보 start -->
				<div class="blood-info">
					<div class="title">최근 혈당</div>
					<div class="date">
						<span class="mr-1">${sessionScope['t_end_date'].substring(0, 4)}년
							${sessionScope['t_end_date'].substring(5, 7)}월
							${sessionScope['t_end_date'].substring(8, 10)}일</span> 
						<span>${sessionScope['t_end_date'].substring(11, 13)}시
							  ${sessionScope['t_end_date'].substring(14, 16)}분</span>
					</div>
					<div class="blood-num">
						<span>${sessionScope['t_bld_val']}</span> <span class="fs-16">mg/dl</span> 
						<span class="material-icons blood_arrow bl_color_stable bl_angle_up">
			              <img src="<c:url value='/asset/images/blood/blood_arrow.svg'/>" alt="범위내화살표" class="bl_nomal">
			              <img src="<c:url value='/asset/images/blood/blood_arrow_high.svg'/>" alt="고혈당" class="bl_high hide">
			              <img src="<c:url value='/asset/images/blood/blood_arrow_low.svg'/>" alt="저혈당" class="bl_low hide">
						</span>
						<!-- 화살표의 컬러는 현재 혈당수치에 따라 컬러를 적용 -->
						<!-- 화살표의 각도는 직전 혈당 수치와 비교하여 각도 적용 기획서 표 참고 -->
					</div>
				</div>
				<!-- //혈당 정보 end -->

			</div>
			<div class="flex-left-right mb-2">
				<div class="date-search-wrap flex-left">
					<span>
						<button class="btn btn-sm btn-primary"
							onclick="javascript:selectWeek();" id="7days">7일</button>
					</span> <span>
						<button class="btn btn-sm btn-outline-primary"
							onclick="javascript:select2Weeks();">14일</button>
					</span> <span>
						<button class="btn btn-sm btn-outline-primary"
							onclick="javascript:selectMonth();">30일</button>
					</span>
					<div class="search-box flex-left">
						<!-- 데이트피커 범위 -->
						<!-- <input type="text" class="form-control" name="dates" value=" "> -->
						<!-- 데이트피커 싱글 -->
						<input type="date" class="form-control" name="start_date"
							id="start_date" value=" "> <span> ~ </span> <input
							type="date" class="form-control" name="end_date" id="end_date"
							value=" ">
						<!-- <button class="buttcon"><span class="icon icon-search"></span></button> -->
					</div>
				</div>
				<div class="butcon-wrap flex-right">
					<button class="buttcon close" onclick="javascript:fnPdf();">
						<span class="icon icon-download"></span>
					</button>
					<button class="buttcon close" onclick="javascript:fnPrint();">
						<span class="icon icon-print"></span>
					</button>
				</div>
			</div>

		<!-- 서브 탭메뉴 영역 start -->
		<ul class="stab-menu">
			<li class="stab-item"><a class="active" id="tab1"
				data-bs-toggle="tab" href="#sub-tab1">개 요</a></li>
			<li class="stab-item"><a class="" id="tab2" 
				data-bs-toggle="tab" href="#sub-tab2">AGP 보고서</a></li>
			<li class="stab-item"><a class="" id="tab3"
				data-bs-toggle="tab" href="#sub-tab3">혈당 그래프</a></li>
			<li class="stab-item"><a class="" id="tab4"
				data-bs-toggle="tab" href="#sub-tab4">통 계</a></li>
		</ul>
				<!-- 서브 탭메뉴 컨텐츠 영역 -->
				<!-- 서브 탭 컨텐츠 개요 -->
				<div class="stab-content active" id="sub-tab1">
					<div class="steb-container">
			          <section class="content-box">
			            <h5>목표 내 혈당 <span>기간 내 평균 혈당 비율 및 시간을 나타냅니다.</span></h5>
			            <div class="chart-row">
			              <div class="chart-wrap">
			                <p>5% 이상 증가해야 임상적으로 유의미합니다.<br>
			                  각 1% Time in range = 약 15분</p>
			                <div class="chart">
			                  <div id="mainChart" style="height: 400px;  weight:600px;"></div>
			                </div>
			              </div>
			              <div class="object-wrap">
			                <h6><br>목표</h6>
			                <div>
			                  <p>5% 미만 (하루 1시간 12분 미만)</p>
			                </div>
			              </div>
			              <div class="compare-wrap">
			                <h6><br>목표 대비</h6>
			                <div>
			                  <p>5%</p>
			                </div>
			              </div>
			            </div>
			          </section>
			          <div class="content-row flex-left-right">
			            <section class="content-box">
			              <h5>평균혈당</h5>
			              <div class="bl_color_stable ft40" id="avg">120</div>
			            </section>
			            <section class="content-box">
			              <h5>공복평균</h5>
			              <div class="bl_color_low ft40" id="fastingAvg">65</div>
			            </section>
			            <section class="content-box">
			              <h5>식후평균</h5>
			              <div class="bl_color_high ft40" id="avgMeal">210</div>
			            </section>
			          </div>
			          <div class="content-row flex-left-right">
			            <section class="content-box">
			              <h5>혈당관리지표</h5>
			              <div>
							  <span class="data ft28 mr5" id="gmi">6.1</span>
				              <span class="ft12">%</span>
				          </div>
			            </section>
			            <section class="content-box">
			              <h5>변동계수</h5>>
				            <div>
				              <span class=" ft28 mr5" id="cv">14.7</span>
				              <span class="ft12">%</span>
				            </div>
			            </section>
			            <section class="content-box">
			              <h5>표준편차</h5>
			              <div>
				              <span class=" ft28 mr5" id="std">17</span>
				              <span class="ft12">mg/dL</span>
				          </div>
			            </section>
			          </div>
			          <section class="content-box">
			            <h5>요일별<span>평균혈당</span></h5>
			            <div>내용</div>
			          </section>
			          <section class="content-box">
			            <h5>요일별 범위내 시간</h5>
			            <div>내용</div>
			          </section>
			          <div class="content-row flex-left-right">
			            <section class="content-box">
			              <h5>센서 활성화 비율</h5>
			              <div>내용</div>
			            </section>
			            <section class="content-box">
			              <h5>센서 정보</h5>
			              <div>내용</div>
			            </section>
			          </div>
			        </div>
			      </div>

				
				<!-- 서브 탭 컨텐츠 AGP 보고서 -->
				<div class="stab-content" id="sub-tab2">
					<%-- <jsp:include page="/WEB-INF/jsp/main/doctor/FAHR_01F_1.jsp"></jsp:include> --%>
			        <div id="agpChart" style="height: 300px; width: 960px"></div>
			        <section class="blood_list">
				        <div class="unit flx-row j-end">
				          <span class="ft12">단위 : mg/dL</span>
				        </div>
				        <div class="top_row flx-row j-between a-center">
				          <div class="left_wrap aval_wrap">
				            <h6>평균 혈당</h6>
				            <div class="bl_color_stable ft40" id="avg2"></div>
				          </div>
				          <div class="center_wrap aval_wrap">
				            <h6>공복 평균</h6>
				            <div class="bl_color_low ft40" id="fastingAvg2"></div>
				          </div>
				          <div class="center_wrap aval_wrap">
				            <h6>식후 평균</h6>
				            <div class="bl_color_high ft40" id="avgMeal2"></div>
				          </div>
				        </div>
				        <div class="down_row">
				          <div class="range_wrap a-start">
				            <h6 class="mb5">혈당관리지표(GMI)</h6>
				            <div>
				              <span class="data ft28 mr5" id="gmi2"></span>
				              <span class="ft12">%</span>
				            </div>
				          </div>
				          <div class="range_wrap a-start">
				            <h6 class="mb5" >표준편차</h6>
				            <div>
				              <span class=" ft28 mr5" id="std2"></span>
				              <span class="ft12">mg/dL</span>
				            </div>
				          </div>
				          <div class="range_wrap a-start">
				            <h6 class="mb5" >변동계수</h6>
				            <div>
				              <span class=" ft28 mr5" id="cv2"></span>
				              <span class="ft12">%</span>
				            </div>
				          </div>
				        </div>
			        </section>
				</div>
				
				<!-- 서브 탭 컨텐츠 혈당 그래프 -->
				<div class="stab-content" id="sub-tab3">
				</div>
				
				<!-- 서브 탭 컨텐츠 통계 -->
				<div class="stab-content" id="sub-tab4">
					<div class="chart-wrap">
						<div id="mealsChart" style="height: 600PX; width: 1000%; margin: 0 auto;"></div>
					</div>
					<div class="chart-wrap">
						<div id="mealAveChart" style="height: 600PX; width: 1000%; margin: 0 auto;"></div>
					</div>
					<div class="chart-wrap">
						<div id="weeklyChart" style="height: 600PX; width: 1000%; margin: 0 auto;"></div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

 <script>
    // 차트 인스턴스 생성
    var myChart = echarts.init(document.getElementById('mealsChart'));

    // 차트 옵션 설정
    var option = {
        title: {
            text: '일일 식후 혈당'
        },
        tooltip: {
            trigger: 'axis'
        },
        legend: {
            data: ['아침', '점심', '저녁']
        },
        xAxis: {
            type: 'category',
            data: ['9/1', '9/2', '9/3', '9/4', '9/5', '9/6', '9/7'],
            axisLabel: {
                formatter: '{value}'
            }
        },
        yAxis: {
            type: 'value',
            min: 70,
            max: 200,
            interval: 10
        },
        series: [
            {
                name: '아침',
                type: 'bar',
                data: [120, 122, 101, 114, 90, 100, 102],
                label: {
                    show: true,
                    position: 'top',
                    formatter: '{c}' // 바 위에 숫자 표시
                },
                itemStyle: {
                    color: '#FF69B4'
                }
            },
            {
                name: '점심',
                type: 'bar',
                data: [140, 132, 141, 128, 130, 140, 157],
                label: {
                    show: true,
                    position: 'top',
                    formatter: '{c}' // 바 위에 숫자 표시
                },
                itemStyle: {
                    color: '#F5F5DC' 
                }
            },
            {
                name: '저녁',
                type: 'bar',
                data: [148, 132, 151, 154, 190, 138, 140],
                label: {
                    show: true,
                    position: 'top',
                    formatter: '{c}' // 바 위에 숫자 표시
                },
                itemStyle: {
                    color: '#87CEFA' 
                }
            }
        ]
    };

    // 차트 옵션 적용
    myChart.setOption(option);
</script>
<script>
    // 차트 인스턴스 생성
    var myChart = echarts.init(document.getElementById('weeklyChart'));

    // 차트 옵션 설정
    var option = {
        title: {
            text: '주중/주말 평군 혈당 추이'
        },
        tooltip: {
            trigger: 'item'
        },
        xAxis: {
            type: 'category',
            data: ['주중', '주말']
        },
        yAxis: {
            type: 'value',
            min: 40,
            max: 200,
            interval: 10,
            axisLine: {
                lineStyle: {
                    color: '#333'
                }
            },
            axisLabel: {
                formatter: '{value}'
            },
            splitLine: {
                show: false // 간격 줄 숨기기
            }
        },
        series: [
            {
                name: '평균',
                type: 'bar',
                data: [120, 160],
                label: {
                    show: true,
                    position: 'top',
                    formatter: '{c}' // 바 위에 숫자 표시
                },
                itemStyle: {
                    color: function(params) {
                        // 주중과 주말에 따른 색상 설정
                        var colorList = ['#FF69B4', '#87CEFA']; // 진한 분홍색, 하늘색
                        return colorList[params.dataIndex];
                    }
                },
                markArea: {
                    data: [
                        [{
                            name: '',
                            yAxis: 100
                        }, {
                            yAxis: 140,
                            itemStyle: {
                                color: '#FFFFE0' // 연한 노란색 배경
                            }
                        }]
                    ]
                }
            }
        ]
    };


    // 차트 옵션 적용
    myChart.setOption(option);
</script>

</body>
</html>