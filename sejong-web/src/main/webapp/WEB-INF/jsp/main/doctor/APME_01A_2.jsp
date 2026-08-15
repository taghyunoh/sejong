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
  <link rel="stylesheet" href="/js/jquery/grid/css/jquery-ui.css" />
<title>${sessionScope['t_user_nm']}님 정보</title>
<%-- embed(환자 대시보드 iframe) 모드에선 daterangepicker 의존 main.js 미로드(중복 jQuery로 에러) --%>
<c:if test="${param.embed ne '1'}"><script src="/js/main.js"></script></c:if>
<script src="https://cdn.jsdelivr.net/npm/echarts/dist/echarts.min.js"></script>
<script>
  var previousStyle = {}; // 초기 상태 저장을 위한 전역 변수
</script>
<style>
@media  print{
        /* 브라우저 인쇄 머리글/바닥글(상단 날짜·제목, 하단 URL·페이지번호) 제거 */
        @page { margin: 0; }
        html, body { margin: 0 !important; }
        /* @page 여백 0 으로 사라진 가장자리 여백을 본문에 직접 부여 */
        #printableArea { padding: 10mm 8mm !important; }
        /* 기간 선택(날짜 입력칸)·우측 인쇄버튼 영역 숨김 */
        .date-search-wrap,
        .butcon-wrap,
        .search-box {
            display: none !important;
        }
        .content-box {
            margin: 10px 0;
            page-break-inside: avoid;
        }
        .center-content {
            justify-content: center; /* 중복된 속성 수정 */
        }
        .login-info {
            display: none !important;
        } 
	    .logo-wrap,
	    .navbar,
	    .gnb-container,
	    .btn-primary,
	    .btn-outline-primary,
	    .stab-menu {
	        display: none !important;   /* 외부 CSS(flex !important) 보다 우선해 인쇄 시 확실히 숨김 */
	    }
        .section {
            /* 큰 섹션(혈당 그래프 등)은 avoid 하면 통째로 다음 페이지로 밀려 빈 화면이 생김.
               자연스럽게 흐르도록 강제 페이지나눔 없음 */
            page-break-inside: auto;
            page-break-before: auto;
            page-break-after: auto;
        }
        /* 개별 차트 박스만 페이지 중간에서 잘리지 않게 (각 차트는 한 페이지에 들어감) */
        .chart-wrap { page-break-inside: avoid; }
        /* 현재 선택된 탭(.active)만 출력 — 나머지 탭은 기존대로 숨김 유지 */
	    .patient-info {
	        margin: 0 !important;
	        padding: 0 !important;
	        display: inline !important;
	    }
        
        .btn-primary, .btn-outline-primary, .stab-menu {
            display: none !important;
        }

        /* 인쇄: 해당(선택된) 탭 내용만 가운데 정렬 + 조금 큰 폰트 */
        #printableArea {
            text-align: center;
            font-size: 1.15em;        /* 화면보다 조금 큰 폰트 */
        }
        #printableArea .content-box,
        #printableArea .chart-wrap,
        #printableArea .steb-container,
        #printableArea section {
            margin-left: auto !important;
            margin-right: auto !important;
            float: none !important;   /* 좌우 분할(flex-left/right) 해제하고 가운데로 */
        }
        /* 차트(echarts 캔버스)가 용지를 넘으면 폭에 맞춰 축소 + 가운데 */
        #printableArea canvas {
            max-width: 100% !important;
            height: auto !important;
            margin-left: auto !important;
            margin-right: auto !important;
            display: block !important;
        }
        /* ── 하단 빈 페이지 방지 ──
           래퍼의 min-height(100vh 등)·하단 여백이 내용보다 키를 키워 다음 페이지로 넘치는 것 차단 */
        html, body,
        #printableArea, .tab-pane, .content-body, .tab-content,
        .content-wrap, .steb-container, .stab-content, .section {
            min-height: 0 !important;
            height: auto !important;
        }
        #printableArea { padding-bottom: 0 !important; }
        .stab-content > .steb-container,
        .stab-content .section,
        .chart-wrap:last-child,
        .content-box:last-child {
            margin-bottom: 0 !important;
            padding-bottom: 0 !important;
        }
}
</style>

<script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/0.4.1/html2canvas.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/1.3.2/jspdf.min.js"></script>
<script type="text/javascript">
  
    $(document).ready(function () {
	
    	// AJAX로 로드된 후 스타일을 강제로 적용
        // 기간 조회 인터렉션
        $('.date-search-wrap button').click(function () {
          $('.date-search-wrap button').removeClass('btn-primary');
          $('.date-search-wrap button').addClass('btn-outline-primary');
          $(this).removeClass('btn-outline-primary');
          $(this).addClass('btn-primary');
        });
        
        // 서브 탭메뉴 인터렉션
        $('.stab-item a').click(function (e) {
            e.preventDefault();
            $('.stab-item a').removeClass('active');
            $('.stab-content').removeClass('active');
            $(this).addClass('active');
            var $target = $($(this).attr('href')).addClass('active');
            // 숨김 탭에서 0크기로 그려진 echarts들을, 탭이 보일 때 컨테이너 크기에 맞춰 다시 사이즈 조정
            setTimeout(function(){
                $target.find('div').each(function(){
                    try { var inst = echarts.getInstanceByDom(this); if (inst) inst.resize(); } catch(e){}
                });
            }, 60);
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
        //bmi 결과
       	var bmi = ${sessionScope['t_bmi']};
		if(bmi < 18.5){
			$("#bmi_stat").text("저체중");
 				$("#bmi_stat").addClass("bmi_low");
		}else if(bmi < 24.9){
			$("#bmi_stat").text("정상");
 				$("#bmi_stat").addClass("bmi_normal");
		}else if(bmi < 29.9){
			$("#bmi_stat").text("과체중");
 				$("#bmi_stat").addClass("bmi_over");
		}else{
			$("#bmi_stat").text("비만");
 				$("#bmi_stat").addClass("bmi_high");
		}

		//혈당 화살표 색 표시
		var bld     = ${sessionScope['t_bld_val']}; //최근 혈당 값
		var gap_bld = ${sessionScope['t_gap_val']}; //한시간전과 비교  


		if(bld < 71 ){
 		    $("#bl_normal").hide(); 
 		    $("#bl_high").hide(); 
 		    $("#bl_high").show(); //71이하 노란색 
 		    $("#bl_high").addClass("bl_angle_slowdown");
		}else if(bld < 141 ){
 		    $("#bl_low").hide(); 
 		    $("#bl_high").hide(); 
 		    $("#bl_normal").show(); //140이하 청색 
 		    $("#bl_normal").addClass("bl_angle_stable"); //
		}else if(bld > 200 ){
 		    $("#bl_normal").hide(); 
 		    $("#bl_low").hide(); 
			$("#bl_low").show();  //200이상 빨간색  
 			$("#bl_low").addClass("bl_angle_fastup");
		}else if(bld > 140 ){
 		    $("#bl_normal").hide(); 
 		    $("#bl_low").hide(); 
			$("#bl_high").show();  //140이상 노란색 
 			$("#bl_high").addClass("bl_angle_slowup");
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
        selectWeek();
    });

    function fnPdf() { /* 마킹 */
    	var printableArea = document.getElementById('printableArea');
    	const jsPDF = window.jspdf;
        const doc = new jsPDF();
        	html2canvas(printableArea, { scale: 4 }).then(canvas => {
            const imgData = canvas.toDataURL("image/png");
            doc.addImage(imgData, 'PNG', 10, 10, 200, 200); // 위치와 크기 조정
            doc.save('${sessionScope['t_user_nm']}님.pdf');
            location.reload();
            return;
        });
    } 
    function fnPrint() {
    	//$('.navbar').attr('class','hide');
    	var initBody;
    	 window.onbeforeprint = function(){
    	    initBody = document.body.innerHTML;
    	    hiderprint() ;
    	    document.body.innerHTML =  document.getElementById('print').innerHTML;
    	 };
    	 window.onafterprint = function(){
        	  document.body.innerHTML = initBody;   
        };
        
        // 출력후 재로드진행 제거 부분  
        // ── 현재 보고 있는 탭만 출력 ──
        // 깨진 body 교체 핸들러 무력화 (#print 요소가 없어 throw 되던 부분)
        window.onbeforeprint = null;
        window.onafterprint  = null;
        // 활성 탭 차트만 컨테이너 크기에 맞춰 정렬 후 인쇄
        var active = document.querySelector('.stab-content.active');
        if (active) {
            active.querySelectorAll('div').forEach(function (d) {
                try { var inst = echarts.getInstanceByDom(d); if (inst) inst.resize(); } catch (e) {}
            });
        }
        setTimeout(function () { window.print(); }, 80);
    }
    //스타일에서 않되서 여기다 처리했음 주메뉴에서 상속한 경우 이런문제가 있네요 
    function hiderprint(){
    	document.querySelector('.btn-primary').style.display = 'none'; 
    	document.querySelectorAll('.btn-outline-primary').forEach(button => {
    	    button.style.display = 'none';
    	});
    	document.querySelector('.stab-menu').style.display = 'none'; 
    	document.querySelector('#prt').style.display = 'none';
    }
    function unhiderprint(){
    	document.querySelector('.btn-primary').style.display = '';
    	document.querySelectorAll('.btn-outline-primary').forEach(button => {
    	    button.style.display = '';
    	});
    	document.querySelector('.stab-menu').style.display = '';
    	document.querySelector('#prt').style.display = 'block';
   	
    }        
    function selectWeek() {
    	var userId = "${sessionScope['t_user_uuid']}";
    	var today = "${sessionScope['t_end_date']}";
		var year = today.substring(0,4);
	    var month = today.substring(5,7);
	    var day = today.substring(8,10);
	    var end_date = year+ "-" + month + "-" +day; 
			    
	    // 7일 전의 날짜 계산
	    var endDate = new Date(year, month - 1, day);  // 월은 0부터 시작
	    endDate.setDate(endDate.getDate() - 7);
	    var start_year = endDate.getFullYear();
	    var start_month = ('0' + (endDate.getMonth() + 1)).slice(-2);
	    var start_day = ('0' + endDate.getDate()).slice(-2);
	    var start_date = start_year + '-' + start_month + '-' + start_day;
	    
	 	// 시작일에서 하루 더한 날짜 계산
	    var next_day = new Date(start_date);
	    next_day.setDate(next_day.getDate() + 1);
	    var next_day_year = next_day.getFullYear();
	    var next_day_month = ('0' + (next_day.getMonth() + 1)).slice(-2);
	    var next_day_day = ('0' + next_day.getDate()).slice(-2);
	    var day_after_start_date = next_day_year + '-' + next_day_month + '-' + next_day_day;

	    // 날짜 설정
	    $("#start_date").val(day_after_start_date); // 하루 더한 날짜를 시작일로 설정
	    $("#end_date").val(end_date);
		 
	    drawBloodBarChart(day_after_start_date, end_date,userId);
		calcBlood(day_after_start_date, end_date,userId);
		drawWeeklyBloodChart(day_after_start_date, end_date, userId);
		drawRangeChart(day_after_start_date, end_date, userId);
		drawChart14(day_after_start_date, end_date , userId);
		drawActionBloodChart(day_after_start_date, end_date , userId);
		//통계
		drawDailyMealBlood(day_after_start_date, end_date, userId);
		drawDailyChart(day_after_start_date, end_date, userId);
		drawWeekHoliAvg(day_after_start_date, end_date, userId);
		
	}
    
    function select2Weeks() {
    	var userId = "${sessionScope['t_user_uuid']}";
    	var today = "${sessionScope['t_end_date']}";
		var year = today.substring(0,4);
	    var month = today.substring(5,7);
	    var day = today.substring(8,10);
	    var end_date = year+ "-" + month + "-" +day; 
	    
	    // 14일 전의 날짜 계산
	    var endDate = new Date(year, month - 1, day);  // 월은 0부터 시작
	    endDate.setDate(endDate.getDate() - 14);
	    var start_year = endDate.getFullYear();
	    var start_month = ('0' + (endDate.getMonth() + 1)).slice(-2);
	    var start_day = ('0' + endDate.getDate()).slice(-2);
	    var start_date = start_year + '-' + start_month + '-' + start_day;
		// 시작일에서 하루 더한 날짜 계산
	    var next_day = new Date(start_date);
	    next_day.setDate(next_day.getDate() + 1);
	    var next_day_year = next_day.getFullYear();
	    var next_day_month = ('0' + (next_day.getMonth() + 1)).slice(-2);
	    var next_day_day = ('0' + next_day.getDate()).slice(-2);
	    var day_after_start_date = next_day_year + '-' + next_day_month + '-' + next_day_day;

	    // 날짜 설정
	    $("#start_date").val(day_after_start_date); // 하루 더한 날짜를 시작일로 설정
	    $("#end_date").val(end_date);
	    
	    drawBloodBarChart(day_after_start_date, end_date,userId);
		calcBlood(day_after_start_date, end_date,userId);
		drawWeeklyBloodChart(day_after_start_date, end_date, userId);
		drawRangeChart(day_after_start_date, end_date, userId);
		drawChart14(day_after_start_date, end_date , userId);
		drawActionBloodChart(day_after_start_date, end_date , userId);
		//통계
		drawDailyMealBlood(day_after_start_date, end_date, userId);
		drawWeekHoliAvg(day_after_start_date, end_date, userId);
	}
    
	function selectMonth() {
		var userId = "${sessionScope['t_user_uuid']}";
	    var today = "${sessionScope['t_end_date']}";
		var year = today.substring(0,4);
	    var month = today.substring(5,7);
	    var day = today.substring(8,10);
	    var end_date = year+ "-" + month + "-" +day; 

	    // 한 달 전의 날짜 계산
	    var endDate = new Date(year, month - 1, day);  // 월은 0부터 시작
	    endDate.setMonth(endDate.getMonth() - 1);
	    var start_year = endDate.getFullYear();
	    var start_month = ('0' + (endDate.getMonth() + 1)).slice(-2);
	    var start_day = ('0' + endDate.getDate()).slice(-2);
	    var start_date = start_year + '-' + start_month + '-' + start_day;
		// 시작일에서 하루 더한 날짜 계산
	    var next_day = new Date(start_date);
	    next_day.setDate(next_day.getDate() + 1);
	    var next_day_year = next_day.getFullYear();
	    var next_day_month = ('0' + (next_day.getMonth() + 1)).slice(-2);
	    var next_day_day = ('0' + next_day.getDate()).slice(-2);
	    var day_after_start_date = next_day_year + '-' + next_day_month + '-' + next_day_day;

	    // 날짜 설정
	    $("#start_date").val(day_after_start_date); // 하루 더한 날짜를 시작일로 설정
	    $("#end_date").val(end_date);
	    //개요
	    drawBloodBarChart(day_after_start_date, end_date,userId);
		calcBlood(day_after_start_date, end_date,userId);
		drawWeeklyBloodChart(day_after_start_date, end_date, userId);
		drawRangeChart(day_after_start_date, end_date, userId);
		drawChart14(day_after_start_date, end_date , userId);
		drawActionBloodChart(day_after_start_date, end_date , userId);
		//통계
		drawDailyMealBlood(day_after_start_date, end_date, userId);
		drawWeekHoliAvg(day_after_start_date, end_date, userId);
	}
	
		function calcBlood(day_after_start_date, end_date,userId) {

	  		var formData = {
	  	  	        start: day_after_start_date,
	  	  	          end: end_date,
	  	  	       userId: userId
	  	  	    };
	      	CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/calcBlood.do","POST",formData,
	  			function(response){
	      			//console.log("GMI, 표준편차, 변동계수 가져옴. :", response);
	      			var fastingAvg = Math.round(response.avgFood.avgFASTING);
					var avgBlood = Math.round(response.AvgBlood);
					var avgMeal = Math.round(response.avgMeal.avgBlood);
					//개요
	      			document.getElementById('gmi').textContent = response.GMI;
	      			document.getElementById('std').textContent = response.stdBlood;
	      			document.getElementById('cv').textContent = response.CV;
	      			document.getElementById('fastingAvg').textContent = fastingAvg;
	      			document.getElementById('avg').textContent = avgBlood;
	      			document.getElementById('avgMeal').textContent = avgMeal;
                    //agp추가
	      			document.getElementById('gmi_agp').textContent = response.GMI;
	      			document.getElementById('std_agp').textContent = response.stdBlood;
	      			document.getElementById('cv_agp').textContent = response.CV;
	      			document.getElementById('fastingAvg_agp').textContent = fastingAvg;
	      			document.getElementById('avg_agp').textContent = avgBlood;
	      			document.getElementById('avgMeal_agp').textContent = avgMeal;

	      			// ② 표준 목표 판정 색상 (CV<36% 권장 / GMI 목표 / 평균 70~180)
	      			(function(){
	      			    var ok='#2f9e63', warn='#e0a800', bad='#d9534f';
	      			    var cvN  = parseFloat(response.CV)  || 0;
	      			    var gmiN = parseFloat(response.GMI) || 0;
	      			    var avgN = parseFloat(avgBlood)      || 0;
	      			    var cvCol  = (cvN < 36) ? ok : bad;                                   // 변동계수 목표 <36%
	      			    var gmiCol = (gmiN < 7) ? ok : (gmiN < 8 ? warn : bad);               // GMI 목표 <7%
	      			    var avgCol = (avgN >= 70 && avgN <= 180) ? ok : (avgN < 70 ? bad : warn); // 평균 목표 70~180
	      			    $("#cv,#cv_agp").css({color:cvCol, fontWeight:'bold'});
	      			    $("#gmi,#gmi_agp").css({color:gmiCol, fontWeight:'bold'});
	      			    $("#avg,#avg_agp").css({color:avgCol, fontWeight:'bold'});
	      			})();
	      			
	      			if(fastingAvg < 54) {
	      				$("#fastingAvg").addClass("bl_color_very_low");
	      			} else if(fastingAvg > 53 && fastingAvg < 71) {
	      				$("#fastingAvg").addClass("bl_color_low");
	      			} else if (fastingAvg > 70 && fastingAvg < 101) {
	      				$("#fastingAvg").addClass("bl_color_slight_low");
	      			} else if (fastingAvg > 100 && fastingAvg < 141) {
	      				$("#fastingAvg").addClass("bl_color_stable");
	      			} else if (fastingAvg > 140 && fastingAvg < 181) {
	      				$("#fastingAvg").addClass("bl_color_slight_high");
	      			}else if (fastingAvg > 180 && fastingAvg < 201) {
	      				$("#fastingAvg").addClass("bl_color_high");
	      			}else if (fastingAvg > 200) {
	      				$("#fastingAvg").addClass("bl_color_very_high");
	      			}
	      			
	      			if (avgBlood < 54) {
	      				$("#avg").addClass("bl_color_very_low");
	      			} else if (avgBlood > 53 && avgBlood < 71) {
	      				$("#avg").addClass("bl_color_low");
	      			} else if (avgBlood > 70 && avgBlood < 101) {
	      				$("#avg").addClass("bl_color_slight_low");
	      			} else if (avgBlood > 100 && avgBlood < 141) {
	      				$("#avg").addClass("bl_color_stable");
	      			} else if (avgBlood > 140 && avgBlood < 181) {
	      				$("#avg").addClass("bl_color_slight_high");
	      			} else if (avgBlood > 180 && avgBlood < 201) {
	      				$("#avg").addClass("bl_color_high");
	      			} else if (avgBlood > 200) {
	      				$("#avg").addClass("bl_color_very_high");
	      			}
	      			
	      			if(avgMeal < 54) {
	      				$("#avgMeal").addClass("bl_color_very_low");
	      			} else if (avgMeal > 53 && avgMeal < 71) {
	      				$("#avgMeal").addClass("bl_color_low");
	      			} else if (avgMeal > 70 && avgMeal < 101) {
	      				$("#avgMeal").addClass("bl_color_slight_low");
	      			} else if (avgMeal > 100 && avgMeal < 141) {
	      				$("#avgMeal").addClass("bl_color_stable");
	      			} else if (avgMeal > 140 && avgMeal < 181) {
	      				$("#avgMeal").addClass("bl_color_slight_high");
	      			} else if (avgMeal > 180 && avgMeal < 201) {
	      				$("#avgMeal").addClass("bl_color_high");
	      			} else if (avgMeal > 200) {
	      				$("#avgMeal").addClass("bl_color_very_high");
	      			}
	  			}
	  		)
	  	};

		
		function drawBloodBarChart(day_after_start_date, end_date,userId) {
	  	    //console.log("막대 차트 그리기 // halfNow : ", halfNow, "now :", now);
	  	    var formData = {
	  	        start: day_after_start_date,
	  	          end: end_date,
	  	       userId: userId
	  	    };
	  	    CommonUtil.callAjax(CommonUtil.getContextPath() + "/drawBloodBarChart.do", "POST", formData,
	  	        function(response) {
	  	          
	  	          	var total = response.LOWEST + response.LOW + response.NORMAL + response.HIGHT + response.HIGHTEST ;
	  	    
	  	     		var lowestPercentage = (total === 0) ? 0 : Math.round((response.LOWEST / total) * 100);
	  	     		var lowPercentage = (total === 0) ? 0 : Math.round((response.LOW / total) * 100);
	  	     		var normalPercentage = (total === 0) ? 0 : Math.round((response.NORMAL / total) * 100);
	  	     		var highPercentage = (total === 0) ? 0 : Math.round((response.HIGHT / total) * 100);
	  	     		var highestPercentage = (total === 0) ? 0 : Math.round((response.HIGHTEST / total) * 100);
	  	     		
	  	     		document.getElementById('highestPercentage').textContent = highestPercentage;
	  	     		document.getElementById('highPercentage').textContent = highPercentage;
	  	     		document.getElementById('normalPercentage').textContent = normalPercentage;
	  	     		document.getElementById('lowPercentage').textContent = lowPercentage;
	  	     		document.getElementById('lowestPercentage').textContent = lowestPercentage;

	  	     		// ── AGP 표준 작성기준 판정 색상 (녹색=기준달성 / 빨강=미달) ──
	  	     		(function(){
	  	     		    var ok='#2f9e63', bad='#d9534f', bold='bold';
	  	     		    var TIR = normalPercentage;                          // 목표 70~180
	  	     		    var TAR = highestPercentage + highPercentage;        // >180 합계
	  	     		    var TBR = lowPercentage + lowestPercentage;          // <70 합계
	  	     		    var set = function(id, good){ var el=document.getElementById(id); if(el){ el.style.color = good?ok:bad; el.style.fontWeight = bold; } };
	  	     		    set('normalPercentage',  TIR >= 70);                 // TIR  ≥ 70%
	  	     		    set('highPercentage',    TAR <  25);                 // TAR(>180 합) < 25%
	  	     		    set('highestPercentage', highestPercentage < 5);     // 매우높음(>250) < 5%
	  	     		    set('lowPercentage',     TBR <  4);                  // TBR(<70 합) < 4%
	  	     		    set('lowestPercentage',  lowestPercentage < 1);      // 매우낮음(<54) < 1%

	  	     		    // [2026-07-31 기획] 개요 하단 '5개 관리지표' 카드에도 같은 값·판정으로 표시
	  	     		    var card = function(id, val, good){
	  	     		        var el = document.getElementById(id); if(!el) return;
	  	     		        el.textContent = val;
	  	     		        el.style.color = good ? ok : bad; el.style.fontWeight = bold;
	  	     		    };
	  	     		    card('tirCard', TIR, TIR >= 70);
	  	     		    card('tarCard', TAR, TAR <  25);
	  	     		    card('tbrCard', TBR, TBR <   4);
	  	     		})();
	  	     		var cal_lowestPercentage  ;
	  	     		var cal_Percentage5       ;
	  	     		var cal_lowPercentage     ;
	  	     		var cal_Percentage25      ;
	  	     		var cal_normalPercentage  ;
	  	     		var cal_Percentage70      ;
	  	     		var cal_highPercentage    ;
	  	     		var cal_Percentage4       ;
	  	     		var cal_highestPercentage ;
	  	     		var cal_Percentage1       ;
	  	     		
               		if (highestPercentage > 5) {
               			cal_highestPercentage = '5%미만 (1시간12분미만/일)' ; 
               			cal_Percentage5       =  '▲'+ (highestPercentage - 5)  + ' %'; 
                   	} else {
                   		cal_highestPercentage = '5%미만 (1시간12분미만/일)' ; 
                   		cal_Percentage5       =  '▼'+ (highestPercentage - 5)  + ' %'; 
                    }
               		if (highPercentage > 25) {
               			cal_highPercentage = '25%미만 (6시간미만/일) '; 
               			cal_Percentage25   =  '▲'+ (highPercentage - 25)  + ' %'; 
                   	} else {
                   		cal_highPercentage = '25%미만 (6시간미만/일) '; 
                   		cal_Percentage25   =  '▼'+ (highPercentage - 25)  + ' %'; 
                    }
               		if (normalPercentage > 70) {
               			cal_normalPercentage = '70%초과 (16시간48분초과/일) '; 
               			cal_Percentage70   =  '▲'+ (normalPercentage - 70)  + ' %'; 
                   	} else {
                   		cal_normalPercentage = '70%초과 (16시간48분초과/일) '; 
                   		cal_Percentage70   =  '▼'+ (normalPercentage - 70)  + ' %'; 
                    }
               		if (lowPercentage > 4) {
               			cal_lowPercentage = '4%미만 (57분 미만/일)' ; 
               			cal_Percentage4   =  '▲'+ (lowPercentage - 4)  + ' %'; 
                   	} else {
                   		cal_lowPercentage = '4%미만 (57분 미만/일)' ;
                   		cal_Percentage4   =  '▼'+ (lowPercentage - 4)  + ' %'; 
                    }
               		if (lowestPercentage > 4) {
               			cal_lowestPercentage = '1%미만 (14분 미만/일)' ; 
               			cal_Percentage1   =  '▲'+ (lowestPercentage - 1)  + ' %'; 
                   	} else {
                   		cal_lowestPercentage = '1%미만 (14분 미만/일)'; 
                   		cal_Percentage1   =  '▼'+ (lowestPercentage - 1)  + ' %';
                    }
               		document.getElementById('cal_highestPercentage').textContent = cal_highestPercentage;
               		document.getElementById('cal_highPercentage').textContent = cal_highPercentage;
               		document.getElementById('cal_normalPercentage').textContent = cal_normalPercentage;
               		document.getElementById('cal_lowPercentage').textContent = cal_lowPercentage;
               		document.getElementById('cal_lowestPercentage').textContent = cal_lowestPercentage;
               		     		
               		document.getElementById('cal_Percentage5').textContent  = cal_Percentage5;
               		document.getElementById('cal_Percentage25').textContent = cal_Percentage25;
               		document.getElementById('cal_Percentage70').textContent = cal_Percentage70;
               		document.getElementById('cal_Percentage4').textContent  = cal_Percentage4;
               		document.getElementById('cal_Percentage1').textContent  = cal_Percentage1;
               		
	  	     		var xAxisData = []; 
	  	            var seriesData = [];
	  	            var option = {
	  	                tooltip: {},
	  	                xAxis: {
	  	                    type: 'category',
	  	                    data: ['-', ''], // x축 데이터
	  	                    axisLabel: {
	  	                        align: 'center'
	  	                    },
	  	                    position: 'bottom',
	  	                },
     	                yAxis: {
	  	                	type: 'value',
	  	                    min: 0,
	  	                    max: 280,
	  	                    interval: 70 , 
	  	                    axisLabel: {
	  	                        formatter: '{value}',
					          	fontSize: 15, // 레이블 글씨 크기
					            fontWeight: 'bolder' ,
 	                     
	  	                    },
	  	                   	                    
	  	                    splitLine: {
	  	                        show: true,
	  	                        lineStyle: {
	  	                            color: '#ddd',
	  	                            type: 'dashed',
	  	                            width: 2
	  	                        }
	  	                    }
	  	                },
	  	                series: [
	  	                    {
	  	                        name: '목표 내 혈당',
	  	                        type: 'bar',
	  	                       // data: [70], 
	  	                        itemStyle: { color: 'grey' },
	  	                        barWidth: '60%',
	  	                        stack: '-', 
	  	                        markLine: {
	  	                            data: [
	  	                                {
	  	                                    yAxis: 280,
	  	                                    lineStyle: {
	  	                                        color: 'red',
	  	                                        width: 2
	  	                                    },
	  	                                    /*
	  	                                    label: {
	  	                                        show: true,
	  	                                        position: 'middle',
	  	                                      	formatter: function() {
	  	                                      		if (highestPercentage > 5) {
			                                        	   return '매우높음   ' + highestPercentage + ' %'+ '         ' +  '5%미만 ' 
			                                        	                                 + '▲'+ (highestPercentage - 5)  + ' %';  // 함수로 값을 반환
		  	                                     	} else {
		  	                                      		   return '매우높음   ' + highestPercentage + ' %'+ '         ' +  '5%미만  ' 
		  	                                      		                                 + '▼'+ (highestPercentage - 5)  + ' %';  // 함수로 값을 반환
		  	                                        }   
	  	                                      	},
	  	                                        color: 'black',
	  	                                        fontSize: 14
	  	                                    },
	  	                                    */
	  	                                   label: {
		                                        show: false,
		                                    },
	  	                                   symbol: 'none', 
	  	                                   symbolSize: 0, 
	  	                                  },	  	                            	
	  	                                  {
	  	                                    yAxis: 250,
	  	                                    lineStyle: {
	  	                                        color: 'orange',
	  	                                        width: 2
	  	                                    },
	  	                                    label: {
		                                        show: true,
		                                        position: 'start',
		                                        align: 'right',
		                                        verticalAlign: 'middle',
		                                        padding: [0, 8, 0, 0],
		                                        formatter: '{c}',
		                                        color: '#333',
		                                        fontWeight: 'bolder',
		                                        fontSize: 15
		                                    },	  	                                    

	  	                                    
	  	                                    symbol: 'none', 
	  	                                    symbolSize: 0, 
	  	                                },
	  	                                {
	  	                                    yAxis: 180,
	  	                                    lineStyle: {
	  	                                        color: 'blue',
	  	                                        width: 2
	  	                                    },
	  	                                    label: {
		                                        show: true,
		                                        position: 'start',
		                                        align: 'right',
		                                        verticalAlign: 'middle',
		                                        padding: [0, 8, 0, 0],
		                                        formatter: '{c}',
		                                        color: '#333',
		                                        fontWeight: 'bolder',
		                                        fontSize: 15
		                                    },	  	                                    
	  	                                    symbol: 'none', 
	  	                                    symbolSize: 0, 
	  	                                },
	  	                                {
	  	                                    yAxis: 70, 
	  	                                    lineStyle: {
	  	                                        color: 'orange',
	  	                                        width: 2
	  	                                    },
		  	                                label: {
			                                      show: false,
			                                },		  	                                    
	  	                                    symbol: 'none',
	  	                                    symbolSize: 0, 
	  	                                },
	  	                                {
	  	                                    yAxis: 54, 
	  	                                    lineStyle: {
	  	                                        color: 'red',
	  	                                        width: 2
	  	                                    },
	  	                                    label: {
		                                        show: true,
		                                        position: 'start',
		                                        align: 'right',
		                                        verticalAlign: 'middle',
		                                        padding: [0, 8, 0, 0],
		                                        formatter: '{c}',
		                                        color: '#333',
		                                        fontWeight: 'bolder',
		                                        fontSize: 15
		                                    },	  	                                    

	  	                                    symbol: 'none',
	  	                                    symbolSize: 0, 
	  	                                }
	  	                            ]
	  	                        }
	  	                    },
	  	                    {
	  	                        type: 'bar',
	  	                        data: [54],
	  	                        itemStyle: {color: '#FF4C4C',  borderColor: '#FFFFFF', borderWidth: 1}, // 선 두께
	  	                        barWidth: '50%',
	  	                        stack: '-'
	  	                    },
	  	                    {
	  	                        type: 'bar',
	  	                        data: [16],
	  	                       itemStyle: {  color: '#FFA500', borderColor: '#FFFFFF', borderWidth: 1} , 
	  	                        barWidth: '50%',
	  	                        stack: '-'
	  	                    },
	  	                    {
	  	                        type: 'bar',
	  	                        data: [110], 
	  	                        itemStyle: { color: 'green' },
	  	                        barWidth: '50%',
	  	                        stack: '-' 
	  	                    },
	  	                    {
	  	                        type: 'bar',
	  	                        data: [70], 
	  	                        itemStyle: {  color: '#FFA500', borderColor: '#FFFFFF', borderWidth: 1} , 
	  	                        barWidth: '50%',
	  	                        stack: '-'
	  	                    },
	  	                   {
	  	                        type: 'bar',
	  	                        data: [30], 
	        	                itemStyle: {color: '#FF4C4C',  borderColor: '#FFFFFF', borderWidth: 1}, // 선 두께
	  	                        barWidth: '50%',
	  	                        stack: '-'
	  	                    }
	  	                ]
	  	            };


	  	            var chart = echarts.init(document.getElementById('mainChart'));
	  	            chart.setOption(option);
	  	        });
	  	}
		
		//요일별 범위내 시간
		function drawRangeChart(day_after_start_date, end_date, userId) {
		    var formData = {
		        start: day_after_start_date,
		        end: end_date,
		        userId: userId
		    };
		    CommonUtil.callAjax(CommonUtil.getContextPath() + "/drawRangeChart.do", "POST", formData, function(response) {

		    	var weekNm = [];
		    	var lowAvg = []; 
		        var norAvg = []; 
		        var warnAvg = [];
		        var dangAvg = [];
		        
				for (var i = 0; i < response.length; i++) {
					weekNm.push(response[i].weekNm || 0);
					lowAvg.push(response[i].lowAvg || 0);
					norAvg.push(response[i].norAvg || 0);
					warnAvg.push(response[i].warnAvg || 0);
					dangAvg.push(response[i].dangAvg || 0);
				}  

				/* '매우 낮음\n(0~53)', 
                '낮음\n(54~70)', 
                '약간 낮음\n(71~100)', 
                '안정적\n(101~140)', 
                '약간 높음\n(141~180)', 
                '높음\n(181~200)', 
                '매우 높음\n(201~)' */
                
		  	 	var option = {
                    title: {
                        text: day_after_start_date + ' ~ ' + end_date 
                    },
        	        legend: {
        	            right: '10%', // 오른쪽 끝에 위치
        	            text: [
        	                '낮음', 
        	                '정상', 
        	                '높음', 
        	                '매우 높음'
        	            ]	            
        	        },
  	                tooltip: {
	  	                trigger: 'axis',
	  	                order:'seriesDesc'
  	                },
        		    xAxis: {
	  	                type: 'category',
	  	                data: weekNm,
		  	            axisLine: {
		  	                lineStyle: {
		  	                    width: 3, // x축 선 두께
		  	                    //color: '#333' // x축 선 색상 (선택 사항)
		  	                }
		  	            },
		  	            axisLabel: {
		  	                fontSize: 16, // 레이블 글씨 크기
                            fontWeight: 'bolder'
		  	            }
        		    },
        		    yAxis: {
        		        type: 'value',
	  	                interval: 0,
        		        axisLine: {
        		            show: false // y축 선 숨기기
        		        },
        		        splitLine: {
        		            show: false // y축 그리드 라인 숨기기 (선택 사항)
        		        }
        		    },
        	        series: [
        	            {
        	                name: '낮음',
        	                type: 'bar',
        	                stack: 'total',
        	                data: lowAvg,
        	                itemStyle: {
        	                    color: '#FF4C4C', // 54-70
       	                        borderColor: '#FFFFFF', // 흰색 선
       	                        borderWidth: 1 // 선 두께
        	                },
        	                label: {
        	                    show: true,
        	                    formatter: (params) => {
        	                        return params.value === 0 ? '' : Math.round(params.value * 10) / 10 + '%';
        	                    },
                                  fontSize: 15,
                                  fontWeight: 'bolder'
        	                }
        	            },
        	            {
        	                name: '정상',
        	                type: 'bar',
        	                stack: 'total',
        	                data: norAvg,
        	                itemStyle: {
        	                    color: '#4CAF50', // 71-100
       	                        borderColor: '#FFFFFF', // 흰색 선
       	                        borderWidth: 1 // 선 두께
        	                },
        	                label: {
        	                    show: true,
        	                    formatter: (params) => {
        	                        return params.value === 0 ? '' : Math.round(params.value * 10) / 10 + '%';
        	                    },
                                  fontSize: 15,
                                  fontWeight: 'bolder'
        	                }
        	            },
        	            {
        	                name: '높음',
        	                type: 'bar',
        	                stack: 'total',
        	                data: warnAvg,
        	                itemStyle: {
        	                    color: '#FFA500', // 181-200
       	                        borderColor: '#FFFFFF', // 흰색 선
       	                        borderWidth: 1 // 선 두께
        	                },
        	                label: {
        	                    show: true,
        	                    formatter: (params) => {
        	                        return params.value === 0 ? '' : Math.round(params.value * 10) / 10 + '%';
        	                    },
                                  fontSize: 15,
                                  fontWeight: 'bolder'
        	                }
        	            },
        	            {
        	                name: '매우 높음',
        	                type: 'bar',
        	                stack: 'total',
        	                data: dangAvg,
        	                itemStyle: {
        	                    color: '#FF4C4C', // 201이상
       	                        borderColor: '#FFFFFF', // 흰색 선
       	                        borderWidth: 1 // 선 두께
        	                },
        	                label: {
        	                    show: true,
        	                    formatter: (params) => {
        	                        return params.value === 0 ? '' : Math.round(params.value * 10) / 10 + '%';
        	                    },
                                  fontSize: 15,
                                  fontWeight: 'bolder'
        	                }
        	            }
        	        ]
        	    };

		        var myChart = echarts.init(document.getElementById('rangeChart'));
				myChart.setOption(option);

		    }); 
		}
		
		// 일일 혈당 프로필 — 날짜별 미니차트 15개를 하나의 연속 그래프로 통합
		function drawChart14(day_after_start_date, end_date, userId) {
          	var formData = {
          		             	start: day_after_start_date,
	  	  	                      end: end_date,
	  	  	                   userId: userId
                		   };
            CommonUtil.callAjax(CommonUtil.getContextPath() + "/getBloodChartDataMulti.do", "POST", formData, function(response) {
    			var dom = document.getElementById('dailyAllChart');
    			if (!dom) { return; }
    			var prev = echarts.getInstanceByDom(dom);
    			if (prev) { prev.dispose(); }
    			var chart = echarts.init(dom);

    			var xLabels = [];   // 일자 경계에만 'MM/DD' 표시, 나머지는 ''
    			var data    = [];   // 시간별 평균 혈당
    			var prevYmd = '';
    			for (var i = 0; i < response.length; i++) {
    				var ymd = String(response[i].CGM_DTM || ''); // 'yymmdd'
    				var lbl = '';
    				if (ymd !== prevYmd && ymd.length >= 6) {
    					lbl = ymd.substring(2, 4) + '/' + ymd.substring(4, 6); // MM/DD
    					prevYmd = ymd;
    				}
    				xLabels.push(lbl);
    				var v = parseFloat(response[i].UPT_VALUE);
    				data.push(isNaN(v) ? null : v);
    			}

    			if (data.length === 0) {
    				chart.setOption({
    					title: { text: '데이터 없음', left: 'center', top: 'middle',
    						textStyle: { color: '#9aa3af', fontSize: 14, fontWeight: 'normal' } }
    				});
    				return;
    			}

    			var greenLabel = { show: true, position: 'end', distance: 4, color: '#2f9e63', fontSize: 11, formatter: '{c}' };
    			var option = {
    				grid: { left: 48, right: 56, top: 24, bottom: 56 },
    				tooltip: {
    					trigger: 'axis',
    					formatter: function (p) {
    						if (!p || !p.length) { return ''; }
    						var v = p[0].value;
    						return (v == null ? '-' : v + ' mg/dL');
    					}
    				},
    				xAxis: {
    					type: 'category', data: xLabels, boundaryGap: false,
    					axisTick: { show: false },
    					axisLine: { lineStyle: { color: '#cfd8e3' } },
    					axisLabel: { interval: 0, color: '#6b7280', fontSize: 11 }
    				},
    				yAxis: {
    					type: 'value', min: 0, max: 300, interval: 70,
    					axisLine: { show: false }, axisTick: { show: false },
    					splitLine: { lineStyle: { color: '#eef1f5' } },
    					axisLabel: { color: '#6b7280', fontSize: 11 }
    				},
    				series: [{
    					name: '혈당', type: 'line', data: data,
    					smooth: true, symbol: 'none', connectNulls: true,
    					lineStyle: { color: '#2f6fd1', width: 2 },
    					areaStyle: { color: 'rgba(47,111,209,0.06)' },
    					markArea: {
    						silent: true,
    						data: [
    							[{ yAxis: 0,   itemStyle: { color: 'rgba(231,76,60,0.08)' } }, { yAxis: 70 }],   // 저혈당
    							[{ yAxis: 70,  itemStyle: { color: 'rgba(46,204,113,0.10)' } }, { yAxis: 180 }],  // 목표
    							[{ yAxis: 180, itemStyle: { color: 'rgba(243,156,18,0.10)' } }, { yAxis: 300 }]   // 고혈당
    						]
    					},
    					markLine: {
    						symbol: 'none', silent: true,
    						data: [
    							{ yAxis: 180, lineStyle: { color: '#f0a500', type: 'dashed' }, label: greenLabel },
    							{ yAxis: 140, lineStyle: { color: '#2f9e63', type: 'dashed', opacity: 0.5 }, label: { show: true, position: 'end', distance: 4, color: '#2f9e63', fontSize: 11, formatter: '{c}' } },
    							{ yAxis: 70,  lineStyle: { color: '#2f9e63', type: 'dashed' }, label: greenLabel }
    						]
    					}
    				}],
    				dataZoom: [{ type: 'slider', show: true, start: 0, end: 100, bottom: 8, height: 16 }]
    			};
    			chart.setOption(option);
    			setTimeout(function () { chart.resize(); }, 50);
            });
        }
		function calDayChart(YMD_VAL,UPT,totval,maxval,setval,avgval,cntval,option1,chart) {
			if (setval > maxval) {
				maxval = Math.round(setval / 100) * 100 ;
			}
            option1 = {
            		title: {
	       				 text:   YMD_VAL.substring(4,6) ,
	       				 font: {
	       					size: 10
	       				 },
	       			     right: 'right'
			    		 },
                    xAxis: {
                        type: 'category',
                        data: ['00시','','','','','','06시','','','','','','12시','','','','','','18시','','','','','','24시'],
                        axisLabel: {
                            interval: 0, // 모든 레이블 표시
                            rotate: 0, // 기울기 없음
                            align: 'center', // 중앙 정렬,
                            fontSize: 12 ,
                            fontWeight: 'bolder'
                        }
                    },
                    yAxis: {
                        type: 'value',
                        min: 0,
                        max: 180,
	  	                interval: 70,
        		        axisLine: {
        		            show: false // y축 선 숨기기
        		        },
        		        splitLine: {
        		            show: true , // y축 그리드 라인 숨기기 (선택 사항)
        		            width: 5
        		        },
			  	        axisLabel: {
			  	         	fontSize: 10, // 레이블 글씨 크기
			  	            align: 'center', // 중앙 정렬,
	                        fontWeight: 'bolder'
			  	        }
                    },
                    series: [
                         {
                          name: '혈당 수치',
  	                      type: 'line',
  	                      data: UPT ,
  	                      itemStyle: { 
  	                          color: 'blue',
  	                          borderWidth: 20
  	                      },
  	                      stack: 'blood',
  	                      showSymbol: false,
	  	                  label: {
	  	                      show: false, // 숫자 값을 표시
	  	                      position: 'top', // 점 위에 위치
                              fontSize: 0,
                              fontWeight: 'bolder' 
	  	                  },
  	                      markLine: {
	                            data: [
	                                {
	                                    yAxis: 180,
	                                    symbol: 'none',
	                                    lineStyle: {
	                                        color: 'orange',
	                                        width: 1,
	                                    },
	                                    symbol: 'none', 
	                                    label: {
	                                        show: false,
	                                    },
	                                } ,  
	                                {
	                                    yAxis: 140,
	                                    symbol: 'none', // 데이터 포인트에 나타나는 동그라미(마커) 제거
	                                    lineStyle: {
	                                        color: 'green',
	                                        width: 1 ,
	                                    },
	                                    symbol: 'none', 
	                                    label: {
	                                        show: false,
	                                    },	                                    
	                                } ,  
	                                {
	                                    yAxis: 70,
	                                    symbol: 'none',
	                                    lineStyle: {
	                                        color: 'green',
	                                        width: 1
	                                    },
	                                    symbol: 'none', 
	                                    label: {
	                                        show: false,
	                                    },	
	                                },    	     	                                

	                             ]
	                      
	  	                    },	                      
                        }
                    ]
            };
            chart = echarts.init(document.getElementById("chart"+cntval));
            chart.setOption(option1);
		}	
		//전체 평균 line 차트(일별 평균 혈당)
		function drawWeeklyBloodChart(day_after_start_date, end_date, userId) {
	  	    var formData = {
	  	          start: day_after_start_date,
	  	          end: end_date,
	  	          userId: userId
	  	      };

	  	      CommonUtil.callAjax(CommonUtil.getContextPath() + "/drawWeeklyBloodChart.do", "POST", formData, function(response) {
	  	    	  var weekdays = ['월', '화', '수', '목', '금', '토', '일'];
	  	          var today = new Date();
	  	          var todayIndex = today.getDay(); // 0 (일요일) ~ 6 (토요일)
	  	          // 오늘의 인덱스를 수정하여 '오늘'을 추가
	  	          var rotatedWeekdays = weekdays.slice(todayIndex).concat(weekdays.slice(0, todayIndex - 1)).concat(['오늘']);

	  	          var avgBlood   = [];
	  	          var avgpost    = [];
	  	          var avgfasting = [];
	  	          var date = [];
	  	          var date2 = [];
	  	          var max = [];

	  	          for (var i = 0; i < response.length; i++) {
	  	        	  date.push(response[i].date || 0);
	  	        	  date2.push(response[i].date2 || 0);
	  	           	  avgBlood.push(response[i].avgBlood || 0);
	  	              avgpost.push(response[i].avgpost || 0);
	  	              avgfasting.push(response[i].avgfasting || 0);
	  	              max.push(response[i].max || 0);
	  	          }

	  	          var option3 = {
	  	              title: {
	  	                  text: '일별 평균 혈당'
	  	              },
	  	              tooltip: {
	  	                  trigger: 'axis'
	  	              },
	  	              xAxis: {
	  	                  type: 'category',
	  	                  data: date2,
			  	          axisLabel: {
				  	          	fontSize: 11, // 레이블 글씨 크기
		                        fontWeight: 'bolder'
				  	          }
	  	              },
	  	              legend: {
	  	                  data: ['공복 평균', '전체 평균', '식후 평균']
	  	              },	  	              
	  	              yAxis: {
	  	                  type: 'value',
	  	               //   min: 70,
	  	               //   max: 300,
	  	               // interval: 30,
	  	                  interval: 0,
			  	          axisLabel: {
				  	          	fontSize: 15, // 레이블 글씨 크기
		                        fontWeight: 'bolder'
				  	          }
	  	              },
	  	              series: [
  	                  {
  	                      name: '공복 평균',
  	                      type: 'line',
  	                      data: avgpost ,
  	                      itemStyle: { color: 'pink' },
  	                      stack: 'blood',
  	                      symbolSize: 11, // 동그라미 크기 설정
	  	                  label: {
	  	                    show: true, // 숫자 값을 표시
	  	                    position: 'top', // 점 위에 위치
                            fontSize: 11,
                            fontWeight: 'bolder'
	  	                  }
  	                  },
  	                  {
  	                      name: '전체 평균',
  	                      type: 'line',
  	                      data: avgBlood ,
  	                      itemStyle: { color: 'blue' },
  	                      stack: 'blood',
  	                      symbolSize: 11, // 동그라미 크기 설정
	  	                  label: {
	  	                      show: true, // 숫자 값을 표시
	  	                      position: 'top', // 점 위에 위치
                              fontSize: 11,
                              fontWeight: 'bolder'
	  	                  }
  	                  },  	                  
                      {  
  	                      name: '식후 평균',
  	                      type: 'line',
  	                      data: avgfasting ,
  	                      itemStyle: { color: 'orange' },
  	                      stack: 'blood',
  	                      symbolSize: 11, // 동그라미 크기 설정
	  	                  label: {
	  	                      show: true, // 숫자 값을 표시
	  	                      position: 'top', // 점 위에 위치
                              fontSize: 11,
                              fontWeight: 'bolder'
	  	                  }
  	                  } 
       
	  	              ],
	      	 		  dataZoom: [{
	       		      			type: 'slider',
	        	        		show: true,
	        	       			xAxisIndex: [0],
	        		        	start: 0, // 초기 시작 비율
	        		        	end: 100 // 전체 데이터를 보여주고 슬라이드로 조정 가능
	        		    		}
	      	 		 		]
	  	          };

	  	          // 두 번째 차트 적용
		  	          var myChart3 = echarts.init(document.getElementById('BloodAveChart'));
		  	          myChart3.setOption(option3);

	  	          	  myChart3.on('click', function(params) {
		                  	var selectedDate = params.name; // params.name에서 날짜를 가져옴
	                      	drawTodayBloodChart(selectedDate, userId, avgBlood); // 선택된 날짜로 두 번째 차트 그리기 (식사 마커 포함)
                   });

	  	          	  // 초기 로드 시 가장 최근 날짜 자동 선택 → 하단 2개 차트(하루혈당·식사별)를 클릭 없이 표시
	  	          	  if (date2 && date2.length > 0) {
	  	          	      var initDate = date2[date2.length - 1];
	  	          	      drawTodayBloodChart(initDate, userId, avgBlood); // 식사 마커 포함
	  	          	  }
	  	      });
	  	  }
		//혈당활동개요(AGP)  
		function drawActionBloodChart(day_after_start_date, end_date, userId) {
	  	    var formData = {
	  	          start: day_after_start_date,
	  	          end: end_date,
	  	          userId: userId
	  	      };

	  	      CommonUtil.callAjax(CommonUtil.getContextPath() + "/drawActionBloodChart.do", "POST", formData, function(response) {

	  	          var avg_value   = [];
	  	          var max_value   = [];
	  	          var min_value   = [];
	  	          var avgm_value   = [];
	  	          var avgl_value   = [];
	  	          for (var i = 0; i < response.length; i++) {
	  	        	  avg_value.push(response[i].AVG_VALUE || 0);
	  	          	  max_value.push(response[i].MAX_VALUE || 0);
	  	              min_value.push(response[i].MIN_VALUE || 0);
	  	              avgm_value.push(response[i].AVGM_VALUE || 0);
	  	              avgl_value.push(response[i].AVGL_VALUE || 0);
	  	          }

	  	          var agpChart = echarts.init(document.getElementById('agpChart'));

	  	          // 데이터 부족 시 안내 후 종료 (AGP는 여러 시간대 데이터 필요)
	  	          var hasPlot = false;
	  	          if (response && response.length >= 2) {
	  	              for (var hi = 0; hi < avg_value.length; hi++) { if (avg_value[hi] > 0) { hasPlot = true; break; } }
	  	          }
	  	          if (!hasPlot) {
	  	              agpChart.clear();
	  	              agpChart.setOption({ title:{ text:'AGP 분석에 필요한 혈당 데이터가 부족합니다 (여러 시간대 데이터 필요)',
	  	                  left:'center', top:'middle', textStyle:{ color:'#9aa5b1', fontSize:14, fontWeight:'normal' } } });
	  	              return;
	  	          }

	  	          // 밴드(영역) 계산: 5~95%, 25~75%
	  	          var band9505 = [], band7525 = [];
	  	          for (var bi = 0; bi < min_value.length; bi++) {
	  	              band9505.push(Math.max(0, (max_value[bi]||0) - (min_value[bi]||0)));
	  	              band7525.push(Math.max(0, (avgm_value[bi]||0) - (avgl_value[bi]||0)));
	  	          }

	  	          var option1 = {
	  	              grid: { left: 56, right: 76, top: 34, bottom: 42 },
	  	              tooltip: {
	  	                  trigger: 'axis',
	  	                  axisPointer: { type: 'line', lineStyle: { color: '#9ec0ea', width: 1 } },
	  	                  formatter: function(p){
	  	                      if(!p || !p.length) return '';
	  	                      var idx = p[0].dataIndex;
	  	                      var f = function(v){ return (v==null ? '-' : Math.round(v)); };
	  	                      return '<b>' + p[0].axisValue + '</b><br/>'
	  	                           + '95% &nbsp;&nbsp;' + f(max_value[idx])  + ' mg/dL<br/>'
	  	                           + '75% &nbsp;&nbsp;' + f(avgm_value[idx]) + '<br/>'
	  	                           + '<b style="color:#163f86">50% &nbsp;&nbsp;' + f(avg_value[idx]) + '</b><br/>'
	  	                           + '25% &nbsp;&nbsp;' + f(avgl_value[idx]) + '<br/>'
	  	                           + '5% &nbsp;&nbsp;&nbsp;' + f(min_value[idx]);
	  	                  }
	  	              },
	  	              xAxis: {
	  	                  type: 'category',
	  	                  boundaryGap: false,
	  	                  data: ['오전12','','','오전3','','','오전6','','','오전9','','','오후12','','','오후3','','','오후6','','','오후9','','','오전12'],
	  	                  axisLine: { lineStyle: { color: '#cfd8e3' } },
	  	                  axisTick: { show: false },
	  	                  axisLabel: { color: '#6b7280', fontSize: 12 }
	  	              },
	  	              yAxis: {
	  	                  type: 'value',
	  	                  min: 0, max: 350, interval: 70,
	  	                  axisLine: { show: false },
	  	                  axisTick: { show: false },
	  	                  axisLabel: { color: '#6b7280', fontSize: 12 },
	  	                  splitLine: { lineStyle: { color: '#eceff3' } }
	  	              },
	  	              series: [
	  	                  // 5~95% 밴드 (옅은 파랑)
	  	                  { name:'min', type:'line', stack:'b9505', data:min_value, symbol:'none', smooth:true, silent:true,
	  	                    lineStyle:{opacity:0}, areaStyle:{opacity:0},
	  	                    endLabel:{ show:true, formatter:'5%', color:'#9aa5b1', fontSize:11 } },
	  	                  { name:'5~95%', type:'line', stack:'b9505', data:band9505, symbol:'none', smooth:true, silent:true,
	  	                    lineStyle:{opacity:0}, areaStyle:{ color:'#d8e7f8' },
	  	                    endLabel:{ show:true, formatter:'95%', color:'#9aa5b1', fontSize:11 } },
	  	                  // 25~75% 밴드 (진한 파랑) — 라벨은 오버랩 방지로 숨김(툴팁에서 확인)
	  	                  { name:'25', type:'line', stack:'b7525', data:avgl_value, symbol:'none', smooth:true, silent:true,
	  	                    lineStyle:{opacity:0}, areaStyle:{opacity:0}, endLabel:{ show:false } },
	  	                  { name:'25~75%', type:'line', stack:'b7525', data:band7525, symbol:'none', smooth:true, silent:true,
	  	                    lineStyle:{opacity:0}, areaStyle:{ color:'#9ec0ea' }, endLabel:{ show:false } },
	  	                  // 중앙값(50%) 굵은 선 + 목표범위(70~180)
	  	                  { name:'중앙값(50%)', type:'line', data:avg_value, symbol:'none', smooth:true, z:5,
	  	                    lineStyle:{ color:'#163f86', width:3 },
	  	                    endLabel:{ show:true, formatter:'50%', color:'#163f86', fontWeight:'bold', fontSize:12 },
	  	                    markLine:{ symbol:'none', silent:true,
	  	                        label:{ show:true, position:'end', distance:6, formatter:'{c}', color:'#2f9e63', fontSize:11, fontWeight:'bold' },
	  	                        data:[ { yAxis:180, lineStyle:{ color:'#2f9e63', width:2 } },
	  	                               { yAxis:70,  lineStyle:{ color:'#2f9e63', width:2 } } ] },
	  	                    markArea:{ silent:true, itemStyle:{ color:'rgba(47,158,99,0.08)' },
	  	                        data:[ [ { yAxis:70 }, { yAxis:180 } ] ] } }
	  	              ]
	  	          };
	  	          agpChart.setOption(option1);
	  	      });
	  	  }		
	      // 다양한 형식(숫자/epoch문자열/ISO/"YYYY-MM-DD HH:mm:ss")에서 시(0~23) 안전 추출, 실패 시 -1
          function _extractHour(v){
              if (v == null) return -1;
              if (typeof v === 'number') return new Date(v).getHours();
              var s = String(v);
              if (/^\d{10,}$/.test(s)) return new Date(parseInt(s,10)).getHours();
              var m = s.match(/[T ](\d{1,2}):/);
              if (m) return parseInt(m[1],10);
              var d = new Date(s);
              return isNaN(d.getTime()) ? -1 : d.getHours();
          }
      //혈당그래프의 일별 평균 혈당 클릭시 보여지는 하루 혈당그래프
          function drawTodayBloodChart(selectedDate, userId, avgBlood) {
          	var formData = { 
            				 end: selectedDate ,  
                             userId: userId
                		   };
            CommonUtil.callAjax(CommonUtil.getContextPath() + "/getBloodChartData.do", "POST", formData, function(response) {
				var UPT      = []; // 서버로부터 받은 혈당 값
				var totval   = 0   ;
				var setval   = 0   ;
				var maxval   = 250 ;
				var DTM_VAL  = ""  ; 
				var avgval   = 0   ;
				// 시(0~23)별 평균 혈당으로 정렬 — 실제 시간대 위치에 점 배치 (데이터 없는 시는 null → 선 연결)
				var _sumH = [], _cntH = [], _cntAll = 0;
				for (var _h = 0; _h < 24; _h++) { _sumH[_h] = 0; _cntH[_h] = 0; }
				for (var i = 0; i < response.length; i++) {
					// HM("HH:mm") 에서 시(hour) 추출 — DTM 직렬화 형식과 무관하게 확실
					var _hh = parseInt(String(response[i].HM || '').substring(0,2), 10);
					if (isNaN(_hh)) { _hh = _extractHour(response[i].DTM); } // 폴백
					var _v  = parseInt(response[i].UPT, 10);
					if (isNaN(_hh) || _hh < 0 || _hh > 23 || isNaN(_v) || _v <= 0) { continue; }
					_sumH[_hh] += _v; _cntH[_hh] += 1; totval += _v; _cntAll += 1;
					if (_v > setval) { setval = _v; }
				}
				for (var _h = 0; _h < 24; _h++) {
					UPT.push(_cntH[_h] > 0 ? Math.round(_sumH[_h] / _cntH[_h]) : null);
				}
				UPT.push(null); // 25번째 라벨(다음날 12시) 자리
				avgval = (_cntAll > 0) ? (totval / _cntAll) : 0 ;
				if (setval > maxval) {
					maxval = Math.round(setval / 100) * 100 ;
				}
				var timeLabels = ['\n12시\n오전', '\n1시', '\n2시', '\n3시', '\n4시', '\n5시', '\n6시', '\n7시', '\n8시', '\n9시', '\n10시', '\n11시', '\n12시\n오후', 
								  '\n1시', '\n2시', '\n3시', '\n4시', '\n5시', '\n6시', '\n7시', '\n8시', '\n9시', '\n10시', '\n11시', '\n12시\n오전'];
        
                var secondOption = {
                    title: {
                        text: selectedDate + ' (평균 혈당: ' +   avgval.toFixed(1)  + ')',
                        left: 'left',
                        right: 'right'
                    },
                    tooltip: {
                        trigger: 'axis'
                    },
                    xAxis: {
                        type: 'category',
                        data: timeLabels,
                        axisLabel: {
                            interval: 0, // 모든 레이블 표시
                            rotate: 0, // 기울기 없음
                            align: 'center', // 중앙 정렬,
                            fontSize: 14,
                            fontWeight: 'bolder'
                        }
                    },
                    yAxis: {
                        type: 'value',
                        min: 0,
                        max: maxval,
				        axisLabel: {
				          	fontSize: 15, // 레이블 글씨 크기
				            fontWeight: 'bolder'
				        }
                    },
                    series: [
                        {
                            name: '혈당 수치',
                            type: 'line',
                            data: UPT,
                            smooth: true,
                            connectNulls: true,
                            showSymbol: true,
                            symbolSize: 6,
                            lineStyle: {
                                color: 'green'
                            },
                            markPoint: {
                                data: [
                                    { type: 'max', name: '최대' },
                                    { type: 'min', name: '최소' }
                                ]
                            }
                        }
                    ]
                };

                // 차트 초기화 및 설정 (혈당 라인 먼저 — 항상 표시)
                // notMerge=true: 날짜 변경 시 이전 식사 마커(scatter)가 잔존하지 않도록 매번 완전 초기화
                var mySecondChart = echarts.init(document.getElementById('SecondBloodChart'));
                mySecondChart.setOption(secondOption, true);

                // ── 하단 식사내용을 같은 차트에 겹쳐 표시 (식사 마커) ──
                CommonUtil.callAjax(CommonUtil.getContextPath() + "/drawOneMealChart.do", "POST", formData, function(mealRes) {
                    if (!mealRes || !mealRes.length) { return; }
                    var mealMap = {}; // 시(hour) -> [음식명...]
                    for (var i = 0; i < mealRes.length; i++) {
                        var hh = parseInt(mealRes[i].hh, 10);
                        if (isNaN(hh)) { hh = _extractHour(mealRes[i].dtm); }
                        if (isNaN(hh) || hh < 0 || hh > 23) {           // 끼니로 폴백 배치
                            var et = mealRes[i].eatType;
                            hh = (et === '0') ? 8 : (et === '1') ? 12 : (et === '2') ? 18 : (et === '6') ? 21 : 12;
                        }
                        var nm = mealRes[i].foodNm || '식사';
                        if (!mealMap[hh]) { mealMap[hh] = []; }
                        if (mealMap[hh].indexOf(nm) === -1) { mealMap[hh].push(nm); }
                    }
                    var mealPoints = [];
                    for (var h in mealMap) {
                        if (!mealMap.hasOwnProperty(h)) { continue; }
                        var hi = parseInt(h, 10);
                        var yv = (UPT[hi] != null) ? UPT[hi] : Math.max(50, Math.round(avgval)); // 해당 시각 혈당값(없으면 평균 근처)
                        mealPoints.push({
                            value: [hi, yv],
                            name: mealMap[h].join(', '),
                            label: {
                                show: true, position: 'top', distance: 10,
                                formatter: mealMap[h].join('\n'),
                                color: '#c0392b', fontSize: 11, fontWeight: 'bold', lineHeight: 14,
                                backgroundColor: 'rgba(255,255,255,0.88)', padding: [2, 5], borderRadius: 3,
                                borderColor: '#FFA500', borderWidth: 1
                            }
                        });
                    }
                    if (!mealPoints.length) { return; }
                    // 혈당 라인(index 0) 유지 + 식사 마커(scatter) 추가
                    mySecondChart.setOption({
                        series: secondOption.series.concat([{
                            name: '식사',
                            type: 'scatter',
                            symbol: 'pin',
                            symbolSize: 28,
                            itemStyle: { color: '#FFA500', borderColor: '#fff', borderWidth: 1 },
                            data: mealPoints,
                            z: 12,
                            tooltip: { trigger: 'item', formatter: function (p) { return '🍽 ' + p.name; } }
                        }])
                    });
                });

            });
        }
	      //식사 메모
	      function drawOneMealChart(selectedDate, userId) {
	    	  var formData = { 
     				  end: selectedDate ,  
                      userId: userId
         		   };
	    	  CommonUtil.callAjax(CommonUtil.getContextPath() + "/drawOneMealChart.do", "POST", formData, function(response) {
	    		    var foodByTime = Array(24).fill('').map(() => []); // 24시간을 위한 배열
	    		    var eatTypes = Array(24).fill(''); // 각 시간대의 식사 유형

	    		    for (var i = 0; i < response.length; i++) {
	    		        // SQL이 직접 반환하는 hh(EAT_STIME 앞 2자리=시) 사용 — 정확한 시각에 배치
	    		        var hourIndex = parseInt(response[i].hh, 10);
	    		        if (isNaN(hourIndex)) { hourIndex = _extractHour(response[i].dtm); } // dtm 폴백
	    		        if (isNaN(hourIndex) || hourIndex < 0 || hourIndex > 23) {        // 그래도 불가 시 끼니로 배치
	    		            var _et = response[i].eatType;
	    		            hourIndex = (_et==='0')?8:(_et==='1')?12:(_et==='2')?18:(_et==='6')?21:12;
	    		        }

	    		        // 음식 목록 처리
	    		        var foods = response[i].foodNm; // 여러 음식을 쉼표로 구분

	    		        if (!foodByTime[hourIndex].includes(foods)) {
	    		            foodByTime[hourIndex].push(foods || '없음');
	    		        }
	    		        // 식사 유형 처리 (중복 방지)
	    		        if (eatTypes[hourIndex] === '') { 
	    		            if (response[i].eatType === '0') {
	    		                eatTypes[hourIndex] = "아침";
	    		            } else if (response[i].eatType === '1') {
	    		                eatTypes[hourIndex] = "점심";
	    		            } else if (response[i].eatType === '2') {
	    		                eatTypes[hourIndex] = "저녁";
	    		            } else if (response[i].eatType === '6') {
	    		                eatTypes[hourIndex] = "야식";
	    		            } else {
	    		                eatTypes[hourIndex] = "간식";
	    		            }
	    		        }
	    		    }
	    		    var foodNm = foodByTime.map(foods => foods.join('\r\n')); // 각 시간대의 음식 목록을 결합

	    		    var timeLabels = ['\n12시\n오전', '\n1시', '\n2시', '\n3시', '\n4시', 
	    		                      '\n5시', '\n6시', '\n7시', '\n8시', 
	    		                      '\n9시', '\n10시', '\n11시', '\n12시\n오후', 
	    		                      '\n1시', '\n2시', '\n3시', '\n4시', 
	    		                      '\n5시', '\n6시', '\n7시', '\n8시', 
	    		                      '\n9시', '\n10시', '\n11시', '\n12시\n오전'];

	    		    // ECharts 옵션 설정
	    		    var option = {
	    		        title: {
	    		            text: '시간별 섭취 목록'
	    		        },
	    		        tooltip: {
	    		            trigger: 'axis',
	    		            formatter: function(params) {
    		                    return foodNm[params.dataIndex];
	    		            }
	    		        },
	    		        xAxis: {
	    		            type: 'category',
	    		            data: timeLabels,
	    		            axisLabel: {
	    		                interval: 0, // 모든 레이블 표시
	    		                rotate: 0, // 기울기 없음
	    		                align: 'center', // 중앙 정렬,
                                fontSize: 14,
                                fontWeight: 'bolder'
	    		            }
	    		        },
	    		        yAxis: {
	    		            type: 'value',
	    		            max: 1.6,
	    		            show: false // Y축 숨김 (막대 위 라벨 공간 확보 위해 max 여유)
	    		        },
	    		        series: [{
	    		            name: '음식',
	    		            type: 'bar',
	    		            barWidth: '45%',
	    		            data: foodNm.map(item => (item ? 1 : 0)), // 식사 있는 시간대만 막대 표시
	    		            label: {
	    		                show: true,
	    		                position: 'top',
                                distance: 6,
                                fontSize: 12,
                                color: '#333',
                                lineHeight: 15,
                                overflow: 'break',
                                width: 90,
                                align: 'center',
	    		                formatter: function(params) {
	    		                    return foodNm[params.dataIndex] || ''; // 음식 이름 표시(막대 위)
	    		                }
	    		            },
	    		            itemStyle: {
	    		                color: '#FFA500',
	    		                borderRadius: [4,4,0,0]
	    		            },
	    		        }],
		      	 		  dataZoom: [{
	       		      			type: 'slider',
	        	        		show: true,
	        	       			xAxisIndex: [0],
	        		        	start: 0, // 초기 시작 비율
	        		        	end: 100, // 전체 데이터를 보여주고 슬라이드로 조정 가능
	        		            bottom: 0 // 슬라이더의 위치 조정 (x축과의 간격)
	        		    		}
	      	 		 		]
	  	          };
	                // 차트 초기화 및 설정
	                var mySecondChart = echarts.init(document.getElementById('drawOneMealChart'));
	                mySecondChart.setOption(option);
                setTimeout(function(){ try{ mySecondChart.resize(); }catch(e){} }, 50); // 숨김 탭/지연 렌더 대비
	          });  
	      }
          
	  	  
		 //아침, 점심, 저녁 식후 혈당  
		function drawDailyMealBlood(day_after_start_date, end_date, userId) {
		    var formData = {
		        start: day_after_start_date,
		        end: end_date,
		        userId: userId
		    };
		    CommonUtil.callAjax(CommonUtil.getContextPath() + "/drawDailyMealBlood.do", "POST", formData, function(response) {

		    	var breakfast = []; // 서버에서 받은 아침 혈당 데이터
		        var lunch = []; // 서버에서 받은 점심 혈당 데이터
		        var dinner = []; // 서버에서 받은 저녁 혈당 데이터
		        var date = [];
		        var max = [];
		        var maxData = 200; 
		        
				for (var i = 0; i < response.length; i++) {
					breakfast.push(response[i].breakfast || 0);
					lunch.push(response[i].lunch || 0);
					dinner.push(response[i].dinner || 0);
					date.push(response[i].date || 0);
					max.push(response[i].max || 0);
					// max 배열에서 최대값을 찾기
		            if (response[i].max > maxData) {
		                maxData = response[i].max; // 더 큰 값을 찾으면 maxData에 저장
		            }
				}
	  	          
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
	  	                data: date,
			  	        axisLabel: {
				  	    	fontSize: 14, // 레이블 글씨 크기
		                	fontWeight: 'bolder'
				  	    }
        		    },
        		    yAxis: {
        		        type: 'value',
        		        min: 0,
        		        max: maxData,
				        axisLabel: {
				          	fontSize: 14, // 레이블 글씨 크기
				            fontWeight: 'bolder'
				        }
        		    },
        		    series: [
        		        {
        		            name: '아침',
        		            type: 'bar',
        		            data: breakfast, 
        		            label: {
        		                show: true,
        		                position: 'top',
        		                formatter: '{c}',
        				  	    fontSize: 14, // 레이블 글씨 크기
        		                fontWeight: 'bolder'
        		            },
        		            itemStyle: {
        		                color: '#FF69B4'
        		            },
        		            barWidth: '20%' // 막대 너비 조정
        		        },
        		        {
        		            name: '점심',
        		            type: 'bar',
        		            data: lunch, 
        		            label: {
        		                show: true,
        		                position: 'top',
        		                formatter: '{c}',
        				  	    fontSize: 14, // 레이블 글씨 크기
        		                fontWeight: 'bolder'
        		            },
        		            itemStyle: {
        		                color: '#F5F5DC'
        		            },
        		            barWidth: '20%'
        		        },
        		        {
        		            name: '저녁',
        		            type: 'bar',
        		            data: dinner,
        		            label: {
        		                show: true,
        		                position: 'top',
        		                formatter: '{c}',
        				  	    fontSize: 14, // 레이블 글씨 크기
        		                fontWeight: 'bolder'
        		            },
        		            itemStyle: {
        		                color: '#87CEFA'
        		            },
        		            barWidth: '20%'
        		        }
        		    ],
        		    dataZoom: [{
        		        type: 'slider',
        		        show: true,
        		        xAxisIndex: [0],
        		        start: 0, // 초기 시작 비율
        		        end: 100 // 전체 데이터를 보여주고 슬라이드로 조정 가능
        		    }]
        		};

		        var myChart = echarts.init(document.getElementById('mealsChart'));
				myChart.setOption(option);

		    });
		}
		
		//요일별 혈당 평균 (전체, 식후, 공복)
		//요일별 평균혈당, 일별 평균 혈당, 요일별 평균 혈당
		function drawDailyChart(day_after_start_date, end_date, userId) {
	  	    var formData = {
	  	          start: day_after_start_date,
	  	          end: end_date,
	  	          userId: userId
	  	      };
	  	      CommonUtil.callAjax(CommonUtil.getContextPath() + "/drawDailyChart.do", "POST", formData, function(response) {
	  	          var weekdays = ['월', '화', '수', '목', '금', '토', '일'];
	  	          var today = new Date();
	  	          var todayIndex = today.getDay(); // 0 (일요일) ~ 6 (토요일)

	  	          var rotatedWeekdays = weekdays.slice(todayIndex).concat(weekdays.slice(0, todayIndex - 1)).concat(['오늘']);

	  	          var avgFasting = [];
	  	          var avgPostMeal = [];
	  	          var avgBlood = [];

	  	     	// 요일별 평균 혈당 값 설정
	  	        response.fasting.forEach(item => {
	  	            avgFasting.push(item.avgFasting || 0); // fasting 데이터에서 avgFasting 값 가져오기
	  	        });
                
	  	        response.post.forEach(item => {
	  	            avgPostMeal.push(item.avgPostMeal || 0); // post 데이터에서 avgPostMeal 값 가져오기
	  	        });

	  	        response.result.forEach(item => {
	  	            avgBlood.push(item.avgBlood || 0); // 전체 평균 혈당
	  	        });
	  	          // 데이터가 7일치가 아닐 경우 빈 값으로 채우기
	  	          while (avgFasting.length < 7) avgFasting.unshift(0);
	  	          while (avgPostMeal.length < 7) avgPostMeal.unshift(0);
	  	          while (avgBlood.length < 7) avgBlood.unshift(0);

	  	          var option = {
	  	              title: {
	  	                  text: '최근 일주일 평균 혈당'
	  	              },
	  	              tooltip: {
		  	              trigger: 'axis',
		  	              order:'seriesDesc' //역순
		  	                 
	  	              },
	  	              legend: {
	  	                  data: ['공복 평균', '전체 평균', '식후 평균']
	  	              },
	  	              xAxis: {
	  	                  type: 'category',
	  	                  data: rotatedWeekdays,
	  	                  max: 6,
				  	      axisLabel: {
					  	  	fontSize: 15, // 레이블 글씨 크기
			              	fontWeight: 'bolder'
					  	  }
	  	              },
	  	              yAxis: {
	  	                  type: 'value',
	  	                  interval: 0,
				          axisLabel: {
				          	fontSize: 14, // 레이블 글씨 크기
				            fontWeight: 'bolder'
				          }
	  	              },
	  	              series: [
	  	                  {
	  	                      name: '공복 평균',
	  	                      type: 'line',
	  	                      data: avgFasting,
	  	                      itemStyle: { color: 'pink' },
	  	                      stack: 'blood',
	  	                      symbolSize: 6, // 동그라미 크기 설정
		  	                  label: {
		  	                      show: true, // 숫자 값을 표시
		  	                      position: 'top', // 점 위에 위치
	                              fontSize: 12,
	                              fontWeight: 'bolder'
		  	                  }	
	  	                  },
	  	                  {
	  	                      name: '전체 평균',
	  	                      type: 'line',
	  	                      data: avgBlood,
	  	                      itemStyle: { color: 'green' },
	  	                      stack: 'blood',
	  	                      symbolSize: 6, // 동그라미 크기 설정
		  	                  label: {
		  	                      show: true, // 숫자 값을 표시
		  	                      position: 'top', // 점 위에 위치
	                              fontSize: 12,
	                              fontWeight: 'bolder'
		  	                  }	
	  	                  },
	  	                  {
	  	                      name: '식후 평균',
	  	                      type: 'line',
	  	                      data: avgPostMeal,
	  	                      itemStyle: { color: 'orange' },
	  	                      stack: 'blood',
	  	                      symbolSize: 6, // 동그라미 크기 설정
		  	                  label: {
		  	                      show: true, // 숫자 값을 표시
		  	                      position: 'top', // 점 위에 위치
	                              fontSize: 12,
	                              fontWeight: 'bolder'
		  	                  }	  	                      
	  	                  }
	  	              ]
	  	          };

	  	          var myChart = echarts.init(document.getElementById('mealAveChart'));
	  	          myChart.setOption(option);
	  	          var myChart2 = echarts.init(document.getElementById('mealAveChart2'));
	  	          myChart2.setOption(option);
	  	          
	  	      });
	  	  }
		//주중 주말 평균
		function drawWeekHoliAvg(day_after_start_date, end_date, userId) { 
		    var formData = {
		        start: day_after_start_date,
		        end: end_date,
		        userId: userId
		    };

		    CommonUtil.callAjax(CommonUtil.getContextPath() + "/drawWeekHoliAvg.do", "POST", formData, function(response) {
		        var weekday_avg = []; 
		        var holiday_avg = []; 

	  	        response.result.forEach(item => {
	  	        	weekday_avg.push(item.weekday_avg || 0); // 주중 평균 혈당
	  	        	holiday_avg.push(item.holiday_avg || 0); // 주말 평균 혈당
	  	        });
		        
				var option = { 
						title: {
			       				 text: '주중/주말 평균 혈당 추이 (' + day_after_start_date + ' ~ ' + end_date +')'
					    		},
			            xAxis: {
			                type: 'category',
			                data: ['주중                                                                      주말'], // 공백 계산 된거에요 줄이기 금지
				  	        axisLabel: {
						  	  	fontSize: 16, // 레이블 글씨 크기
				              	fontWeight: 'bolder'
						  	}
			            },
					    yAxis: {
					        type: 'value',
					        min: 0,
					        max: 280,
		  	                interval: 70,
					        axisLine: {
					            lineStyle: {
					                color: '#333'
					            }
					        },
					        axisLabel: {
					            formatter: '{value}',
						  	  	fontSize: 14, // 레이블 글씨 크기,
						        fontWeight: 'bolder'
					        }
					    },
					    series: [
					        {
					            name: '주중 평균',
					            type: 'bar',
					            data: weekday_avg, // 주중 평균 데이터
					            label: {
					                show: true,
					                position: 'top',
					                formatter: '{c}',
							  	  	fontSize: 14, // 레이블 글씨 크기
					              	fontWeight: 'bolder'
					            },
					            itemStyle: {
					                color: '#FF69B4' // 핫핑크 색상
					            },
					            barWidth: '20%', // 막대 너비 조정
			                    barGap: '108%', // 막대 간격 조정 (50%로 설정)
					        },
					        {
					            name: '주말 평균',
					            type: 'bar',
					            data: holiday_avg, // 주말 평균 데이터
					            label: {
					                show: true,
					                position: 'top',
					                formatter: '{c}',
							  	  	fontSize: 14, // 레이블 글씨 크기
					              	fontWeight: 'bolder'
					            },
					            itemStyle: {
					                color: '#87CEFA' // 연한 하늘색
					            },
					            barWidth: '20%', // 막대 너비 조정
					            markArea: {
					                silent: true,
					                data: [
					                    [{
					                        name: '정상범위',
					                        yAxis: 70
					                    }, {
					                        yAxis: 140,
					                        itemStyle: {
					                            color: '#FFFFE0' // 연한 노란색
					                        }
					                    }]
					                ]
					            }
					        }
					    ]
					};


			        var myChart = echarts.init(document.getElementById('weeklyChart'));
			        myChart.setOption(option);
			        var myChart2 = echarts.init(document.getElementById('weeklyChart2'));
			        myChart2.setOption(option);
			    });
			}

</script>
</head>
<body>

<div class="tab-pane" id="printableArea">  
	<div class="content-body">
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
							${sessionScope['t_birth'].substring(6, 8)}일</span> 만<span><em id="age"></em>세</span>
						<span id="gender"></span>
					</div>
					<div class="info-bmi">
						<span>BMI(체질량지수)</span>
						<span>${sessionScope['t_bmi']}</span>
						<a class="" id="bmi_stat"></a>
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
						<!-- <a class="" id="bldAngle"></a>
						<span class="" id="bldAngle">
			              <img src="<c:url value='/asset/images/blood/blood_arrow.svg'/>" alt="범위내화살표" class="bl_normal hide" id="bl_normal">
			              <img src="<c:url value='/asset/images/blood/blood_arrow_high.svg'/>" alt="고혈당" class="bl_high hide" id="bl_high">
			              <img src="<c:url value='/asset/images/blood/blood_arrow_low.svg'/>" alt="저혈당" class="bl_low hide" id="bl_low">
						</span>  -->
						<!-- 화살표의 컬러는 현재 혈당수치에 따라 컬러를 적용 -->
						<!-- 화살표의 각도는 직전 혈당 수치와 비교하여 각도 적용 기획서 표 참고 -->
					</div>
				</div>
				<!-- //혈당 정보 end -->

			</div>
			<div class="flex-left-right mb-10">
				<div class="date-search-wrap flex-left">
					<span>
						<button class="btn btn-sm btn-primary"
							onclick="javascript:selectWeek();" id="7days" name="7days">7일</button>
					</span> <span>
						<button class="btn btn-sm btn-outline-primary"
							onclick="javascript:select2Weeks();" id="14days" name="14days">14일</button>
					</span> <span>
						<button class="btn btn-sm btn-outline-primary"
							onclick="javascript:selectMonth();"  id="30days" name="30days">30일</button>
					</span>
					<div class="search-box flex-left">
						<!-- 데이트피커 범위 -->
						<!-- <input type="text" class="form-control" name="dates" value=" "> -->
						<!-- 데이트피커 싱글 -->
						<input type="date" class="form-control" name="start_date"
							id="start_date" value="" readonly> <span> ~ </span> <input
							type="date" class="form-control" name="end_date" id="end_date"
							value="" readonly>
						<!-- <button class="buttcon"><span class="icon icon-search"></span></button> -->
					</div>
				</div>
				<div class="butcon-wrap flex-right">
				<!--<button id="pdf" class="buttcon close" onclick="javascript:fnPdf();">
						<span class="icon icon-download"></span>
					</button>
				-->	
				    <button id="prt" class="buttcon close" onclick="javascript:fnPrint();">
						<span class="icon icon-print"></span>
					</button>
					
				</div>
			</div>

		<!-- 서브 탭메뉴 영역 start -->
		<ul class="stab-menu">
			<li class="stab-item"><a class="active" id="tab1"
				href="#sub-tab1">개 요</a></li>
			<li class="stab-item"><a class="" id="tab2" 
				href="#sub-tab2">AGP 보고서</a></li>
			<li class="stab-item"><a class="" id="tab3"
				href="#sub-tab3">혈당 그래프</a></li>
			<li class="stab-item"><a class="" id="tab4"
				href="#sub-tab4">통 계</a></li>
			<%-- [2026-07-31 기획] AI 분석 탭 — 의사 입장에서 중요한 '지표 해석'을 강조 --%>
			<li class="stab-item"><a class="" id="tab5"
				href="#sub-tab5">AI 분석</a></li>
		</ul>
				<!-- 서브 탭메뉴 컨텐츠 영역 -->
				<!-- 서브 탭 컨텐츠 개요 -->
				<div class="stab-content active" id="sub-tab1">
					<div class="steb-container">
					<script src="/asset/js/echarts/echarts.min.js"></script>

			          <section class="content-box">
			            <h5>범위 내 요일(요일대별)</h5>
			            <div>
			              <div id="rangeChart" style="width: 1100px; height: 600px; margin: 0 auto; "></div>
			            </div>
			          </section>
          

			          <div class="content-row flex-left-right">
			            <section class="content-box box-row">
			              <h5>평균혈당</h5>             
			              <p class="num-wrap">
			                <span class="num "  id="avg"></span>
			                <span>mg/dL</span>
			              </p>
			            </section>
			            <section class="content-box box-row">
			              <h5>공복평균</h5>
						  <p class="num-wrap">
			                <span class="num " id="fastingAvg"></span>
			                <span>mg/dL</span>
			              </p>
			            </section>
			            <section class="content-box box-row">
			              <h5>식후평균</h5>              
			              <p class="num-wrap">
			                <span class="num " id="avgMeal"></span>
			                <span>mg/dL</span>
			              </p>
			            </section>
			          </div>
			          <%-- [2026-07-31 기획] 5개 관리지표(TIR/TBR/TAR/CV/GMI) — 대한당뇨병학회 권장기준 병기.
			               TIR·TAR·TBR 값은 drawBloodBarChart 응답으로 이미 계산되던 것을 여기에도 표시(추가 조회 없음).
			               색: 권장 충족=초록 / 미달=빨강 (기존 판정 색상 규칙과 동일) --%>
			          <div class="content-row flex-left-right">
			            <section class="content-box box-row">
			              <h5>목표범위 유지<br>&emsp; TIR <small>(≥70%)</small></h5>
			              <p class="num-wrap"><span class="num" id="tirCard">-</span><span>%</span></p>
			            </section>
			            <section class="content-box box-row">
			              <h5>고혈당 시간<br>&emsp; TAR <small>(&lt;25%)</small></h5>
			              <p class="num-wrap"><span class="num" id="tarCard">-</span><span>%</span></p>
			            </section>
			            <section class="content-box box-row">
			              <h5>저혈당 시간<br>&emsp; TBR <small>(&lt;4%)</small></h5>
			              <p class="num-wrap"><span class="num" id="tbrCard">-</span><span>%</span></p>
			            </section>
			          </div>
			          <div class="content-row flex-left-right">
			            <section class="content-box box-row">
			              <h5>혈당관리지표<br>&emsp; GMI</h5>
			              <p class="num-wrap">
			                <span class="num" id="gmi"></span>
			                <span>%</span>
			              </p>
			            </section>
			            <section class="content-box box-row">
			              <h5>변동계수<br>&emsp; CV <small>(≤36%)</small></h5>
			              <p class="num-wrap">
			                <span class="num" id="cv"></span>
			                <span>%</span>
			              </p>
			            </section>
			            <section class="content-box box-row">
			              <h5>표준편차</h5>
			              <p class="num-wrap">
			                <span class="num" id="std"></span>
			                <span>mg/dL</span>
			              </p>
			          </div>
			          <!-- <section class="content-box">
			            <h5>요일별<span>평균혈당</span></h5>
			            <div><div id="weeklyBloodChart" style="width: 1100px; height: 400px;"></div></div>
			          </section> -->
			            <div class="chart-wrap">
				          <section class="content-box"><div id="mealAveChart" style="height: 500PX; width: 1100px; margin: 0 auto;"></div></section>
						</div>
						<div class="chart-wrap">
				          <section class="content-box"><div id="weeklyChart" style="height: 500PX; width: 1100px; margin: 0 auto; "></div></section>
						</div>
			          <!-- <div class="content-row flex-left-right">
			            <section class="content-box">
			              <h5>센서 활성화 비율</h5>
			              <div>내용</div>
			            </section>
			            <section class="content-box">
			              <h5>센서 정보</h5>
			              <div>내용</div>
			            </section>
			          </div> -->
			        </div>
	      </div>


				<!-- 서브 탭 컨텐츠 AGP 보고서 -->
				<div class="stab-content" id="sub-tab2">
					<%-- <jsp:include page="/WEB-INF/jsp/main/doctor/FAHR_01F_1.jsp"></jsp:include> --%>
					<div class="steb-container">
	                <div class="section">
              				
                     <div class="content-row flex-left-right">
					      <section class="content-box" style="width: 80%; max-width:640px; margin: 0 auto;">
						 	<h5>
								혈당 범위 차트 <span>기간 내 평균 혈당 비율 및 시간을 나타냅니다.</span>
							</h5>
							<div id="mainChart" style="height: 550px; width: 500px;"></div>
				
							<div class="unit flx-row j-end">
								<span class="ft12">단위 : mg/dL</span>
							</div>
						  </section>
						<!--  -->
						<section class="content-box" style="width: 80%; max-width: 600px; margin: 0 auto;">
						     <h5>
								목표 및 목표대비  
							</h5>
							 <span>5% 이상 증가해야 임상적으로 유의미합니다 .</span>
                            <div class="content-row flex-left-right" >
                                <section class="small-box" style="height: 10px; width: 300px;">
					            </section>
							</div>								 
							<div class="content-row flex-left-right" >
								   <h12 style="font-size: 15px;">매우높음</h12>                                
								   <p class="num-wrap" style="font-size: 15px;">
								        <span class="num" id="highestPercentage" style="font-size: 15px;"></span>
								        <span>%</span> &emsp; &emsp;
								        <span class="num" id="cal_highestPercentage" style="font-size: 15px;"></span> &emsp; &emsp;
								        <span class="num" id="cal_Percentage5" style="font-size: 15px; color: blue;"></span>
							       </p> 
							</div>
                            <div class="content-row flex-left-right" >
								   <h12 style="font-size: 15px;">높음     </h12>    &nbsp;                         
								   <p class="num-wrap" style="font-size: 15px;">
								        <span class="num" id="highPercentage" style="font-size: 15px;"></span>
								        <span>%</span> &emsp; &emsp;   
								        <span class="num" id="cal_highPercentage" style="font-size: 15px;"></span>  &emsp; &emsp;&emsp;&ensp;
								        <span class="num" id="cal_Percentage25" style="font-size: 15px; color: blue;"></span>
							       </p> 
							</div>
                            <div class="content-row flex-left-right">
                                <section class="content-box box-row" style="visibility: hidden; height: 100px; width: 300px;">
					            </section>
							</div>
                            <div class="content-row flex-left-right" >
								   <h12 style="font-size: 15px;">목표내범위</h12>                                
								   <p class="num-wrap" style="font-size: 15px;">
								        <span class="num" id="normalPercentage" style="font-size: 15px;"></span>
								        <span>%</span> &emsp;
								        <span class="num" id="cal_normalPercentage" style="font-size: 15px;"></span> &emsp; 
								        <span class="num" id="cal_Percentage70" style="font-size: 15px; color: red;"></span>
							       </p> 
							</div>
                            <div class="content-row flex-left-right" >
                                <section class="small-box" style="height: 40px; width: 300px;">
					            </section>
							</div>														
                            <div class="content-row flex-left-right" >
								   <h12 style="font-size: 15px;">낮음      </h12>                               
								   <p class="num-wrap" style="font-size: 15px;">  &ensp;&ensp;&ensp; 
	                                    <span class="num" id="lowPercentage" style="font-size: 15px;"></span>
								        <span>%</span> &emsp; &emsp; 
								        <span class="num" id="cal_lowPercentage" style="font-size: 15px;"></span> 
								        &emsp; &emsp;&emsp;&emsp;&ensp;  
								        <span class="num" id="cal_Percentage4" style="font-size: 15px;color: blue;"></span>
							       </p> 
							</div>
                            <div class="content-row flex-left-right" >
								   <h12 style="font-size: 15px;">매우낮음</h12>                                
								   <p class="num-wrap" style="font-size: 15px;"> 
								        <span class="num" id="lowestPercentage" style="font-size: 15px;"></span>
                                        <span>%</span> &emsp; &emsp;
								        <span class="num" id="cal_lowestPercentage" style="font-size: 15px;"></span> 
								        &emsp; &emsp;&emsp;&emsp;&ensp; 
								        <span class="num" id="cal_Percentage1" style="font-size: 15px;color: blue;"></span>
							       </p> 
							</div>
						</section>
		

				       <!--  -->
					</div>  			 
						<!--  개요내용추가  -->
			            <div class="content-row flex-left-right">
			            <section class="content-box box-row">
			              <h5>평균혈당</h5>             
			              <p class="num-wrap">
			                <span class="num "  id="avg_agp"></span>
			                <span>mg/dL</span>
			              </p>
			            </section>
			            <section class="content-box box-row">
			              <h5>공복평균</h5>
						  <p class="num-wrap">
			                <span class="num " id="fastingAvg_agp"></span>
			                <span>mg/dL</span>
			              </p>
			            </section>
			            <section class="content-box box-row">
			              <h5>식후평균</h5>              
			              <p class="num-wrap">
			                <span class="num " id="avgMeal_agp"></span>
			                <span>mg/dL</span>
			              </p>
			            </section>
			          </div>
			          <div class="content-row flex-left-right">
			            <section class="content-box box-row">
			              <h5>혈당관리지표<br>&emsp; GMI</h5>
			              <p class="num-wrap">
			                <span class="num" id="gmi_agp"></span>
			                <span>%</span>
			              </p>
			            </section>
			            <section class="content-box box-row">
			              <h5>변동계수<br>&emsp; CV</h5>              
			              <p class="num-wrap">
			                <span class="num" id="cv_agp"></span>
			                <span>%</span>
			              </p>
			            </section>
			            <section class="content-box box-row">
			              <h5>표준편차</h5>              
			              <p class="num-wrap">
			                <span class="num" id="std_agp"></span>
			                <span>mg/dL</span>
			              </p>
			          </div>						
					<!--  개요내용추가   -->	
					</div>	 <!--  <div class="section"> -->
                    <div class="section">
						<section class="content-box">
							<div id="agpChart" style="height: 550px; width: 1100px; margin: 0 auto; "></div>
						</section>
  
												<section class="content-box">
							<h5>일일 혈당 프로필 <span>기간 내 날짜별 혈당 추이 (한 그래프)</span></h5>
							<div id="dailyAllChart" style="height: 360px; width: 1100px; margin: 0 auto;"></div>
						</section>	
					</div>	
						<!-- <section class="content-box">
				      <h5>활동 (AGP)</h5>
				      <span>AGP는 조회 기간 동안의 혈당값을 요약한 것으로, 중앙값(50%)와 기타 백분위수가 하루만에 발생한 것 처럼 표시됩니다. </span>
					  <div class="chart-row">
				      	<div class="chart-wrap">
				            <div class="chart">
				            	<div id="agpAvgChart" style="height: 400PX; width: 1000px;"></div>
				            </div>
				        </div>
				      </div>
				    </section> -->
					</div>
				</div>

				<!-- 서브 탭 컨텐츠 혈당 그래프 -->
				<div class="stab-content" id="sub-tab3">
					<div class="steb-container">
					<div class="section"> <!-- 분리 출력을 위해 나눔  -->
						<div class="chart-wrap">
				          <section class="content-box"><div id="BloodAveChart" style="height: 600PX; width: 1100px; margin: 0 auto;"></div></section>
						</div>
						<div class="chart-wrap">
				          <section class="content-box">
					          <div id="SecondBloodChart" style="height: 500PX; width: 100%;"></div>
					    <!-- 분리 출력을 위해 나눔  -->
					    <!--        <div id="drawOneMealChart" style="height: 500PX; width: 100%;"></div>  -->
					      </section>
						</div> 
					</div>	   <!-- 분리 출력을 위해 나눔  -->
					</div>
				</div>
				
				<!-- 서브 탭 컨텐츠 통계 -->
				<div class="stab-content" id="sub-tab4">
					<div class="steb-container">
						<div class="chart-wrap">
						  <section class="content-box"><div id="mealsChart" style="height: 500PX; width: 1100px;"></div></section>
						</div>
						<div class="chart-wrap">
				          <section class="content-box"><div id="mealAveChart2" style="height: 500PX; width: 1100px;"></div></section>
						</div>
						<div class="chart-wrap">
				          <section class="content-box"><div id="weeklyChart2" style="height: 500PX; width: 1100px;"></div></section>
						</div>
					</div>
				</div>

				<%-- [2026-07-31 기획] AI 분석 — 5개 지표별 현재상태 해석 + 종합 분석/코칭.
				     값은 개요 탭에서 이미 계산된 것(TIR/TAR/TBR/CV/GMI·평균)을 그대로 읽어 쓴다(추가 조회 없음).
				     탭을 열 때마다 최신 값으로 다시 해석한다(aiRender). --%>
				<div class="stab-content" id="sub-tab5">
					<div class="steb-container">
						<%-- [2026-07-31 기획] 환자 앱(patient_main.jsp)의 '시간대별 혈당 + 식사·운동 마커' 그래프를 그대로 가져옴.
						     날짜는 조회기간의 종료일 기준. 원천 = getBloodChartData / getFoodInfo / getExerInfo (앱과 동일) --%>
						<section class="content-box">
							<h5><span id="aiDayTitle">시간대별 혈당 추이</span></h5>
							<div class="ai-legend">
								<span style="color:#5b8ff9">— 혈당</span> &nbsp;·&nbsp; <span>🍚 식사</span> &nbsp;·&nbsp; <span>🚴 운동</span>
								&nbsp;·&nbsp; <span style="color:#c0c4cc;">┊</span> 식사·운동 시각
							</div>
							<div id="aiDayChart" style="height:340px; width:100%;"></div>
						</section>
						<section class="content-box">
							<h5>📌 지표 해석 <small style="font-weight:400;color:#888;">— 대한당뇨병학회 관리지표 기준</small></h5>
							<div id="aiIdxWrap" class="ai-idx"></div>
						</section>
						<%-- 종합 분석 · 생활습관 코칭 — 한 줄에 두 박스로(2026-07-31 요청, 세로 여백 절약) --%>
						<div class="content-row flex-left-right ai-2box">
							<section class="content-box">
								<h5>🩺 종합 분석</h5>
								<div id="aiSummary" class="ai-box">개요 탭에서 기간을 조회하면 표시됩니다.</div>
							</section>
							<section class="content-box">
								<h5>💡 생활습관 코칭 <small style="font-weight:400;color:#888;">— 환자 앱과 동일한 기준</small></h5>
								<div id="aiCoach" class="ai-box">개요 탭에서 기간을 조회하면 표시됩니다.</div>
							</section>
						</div>
						<%-- [2026-07-31 기획] 식사·운동 정보 = 하단 두 박스(앱의 내용). 위 그래프와 같은 조회분을 재사용 --%>
						<div class="content-row flex-left-right ai-2box">
							<section class="content-box">
								<h5>🍚 식사 정보 <small style="font-weight:400;color:#888;">— <span class="aiDayTxt"></span></small></h5>
								<div id="aiFoodBox" class="ai-list">조회 후 표시됩니다.</div>
							</section>
							<section class="content-box">
								<h5>🚴 운동 정보 <small style="font-weight:400;color:#888;">— <span class="aiDayTxt"></span></small></h5>
								<div id="aiExerBox" class="ai-list">조회 후 표시됩니다.</div>
							</section>
						</div>
					</div>
				</div>
			</div>
		</div>
	 </div>
</div>
<script>
/* [2026-07-31 기획 'AI 분석'] 5개 지표(TIR·TAR·TBR·CV·GMI) 해석 + 종합/코칭 문장.
   개요 탭이 채운 DOM 값(#tirCard·#tarCard·#tbrCard·#cv·#gmi·#avg)을 읽어 해석만 만든다 — 서버 재조회 없음.
   권장기준: TIR ≥70% · TAR <25% · TBR <4% · CV ≤36% · GMI 참고치(권장 없음) */
(function(){
  var AI_OK='#2f9e63', AI_BAD='#d9534f';
  function _n(id){ var el=document.getElementById(id); if(!el) return NaN;
    return parseFloat(String(el.textContent||'').replace(/[^0-9.\-]/g,'')); }
  window.aiRender = function(){
    var tir=_n('tirCard'), tar=_n('tarCard'), tbr=_n('tbrCard'), cv=_n('cv'), gmi=_n('gmi'), avg=_n('avg');
    var rows=[];
    function row(nm, val, unit, ok, txt){
      if(isNaN(val)) return;
      rows.push('<div class="ai-row"><span class="ai-nm">'+nm+'</span>'
        +'<span class="ai-val" style="color:'+(ok===null?'#333':(ok?AI_OK:AI_BAD))+'">'+val+unit+'</span>'
        +'<span class="ai-txt">'+txt+'</span></div>');
    }
    row('TIR (목표범위 유지)', tir, '%', tir>=70,
        tir>=70 ? '권장(70% 이상)을 충족합니다. 혈당이 목표 범위에서 잘 유지되고 있습니다.'
                : '권장(70% 이상)에 미달합니다. 목표 범위 유지 시간을 늘리는 관리가 필요합니다.');
    row('TAR (고혈당 시간)', tar, '%', tar<25,
        tar<25 ? '권장(25% 미만)을 충족합니다. 고혈당 노출이 적습니다.'
               : '권장(25% 미만)을 초과합니다. 식후 혈당 상승 관리(식사량·탄수화물·식후 활동)가 필요합니다.');
    row('TBR (저혈당 시간)', tbr, '%', tbr<4,
        tbr<4 ? '권장(4% 미만)을 충족합니다. 저혈당 위험이 낮습니다.'
              : '권장(4% 미만)을 초과합니다. 저혈당 위험이 있어 약물·식사 시간 점검이 필요합니다.');
    row('CV (혈당 변동성)', cv, '%', cv<=36,
        cv<=36 ? '권장(36% 이하)을 충족합니다. 혈당 변동이 안정적입니다.'
               : '권장(36% 이하)을 초과해 변동이 큽니다. 식사 규칙성과 저혈당 반복 여부를 확인하세요.');
    row('GMI (혈당관리지표)', gmi, '%', null,
        '평균혈당을 당화혈색소 형태로 환산한 <b>참고 지표</b>입니다(권장 위험분류 제시 없음).');
    var w=document.getElementById('aiIdxWrap');
    if(w) w.innerHTML = rows.length ? rows.join('') : '<div class="ai-box">표시할 지표가 없습니다. 개요 탭에서 기간을 조회해 주세요.</div>';

    // 종합 분석 — TIR 기준 판정 + 벗어난 지표 나열
    var bad=[];
    if(!isNaN(tar) && tar>=25) bad.push('고혈당 시간(TAR)');
    if(!isNaN(tbr) && tbr>=4)  bad.push('저혈당 시간(TBR)');
    if(!isNaN(cv)  && cv>36)   bad.push('혈당 변동성(CV)');
    var sum='';
    if(!isNaN(tir)){
      sum += (tir>=70)
        ? '<b style="color:'+AI_OK+'">목표 달성</b> — 목표범위 유지시간(TIR) '+tir+'%로 권장 기준을 충족합니다.'
        : '<b style="color:'+AI_BAD+'">관리 필요</b> — 목표범위 유지시간(TIR) '+tir+'%로 권장(70% 이상)에 미달합니다.';
      if(!isNaN(avg)) sum += ' 평균혈당은 '+avg+' mg/dL 입니다.';
      sum += bad.length ? '<br>함께 살펴볼 지표: <b>'+bad.join(', ')+'</b>' : '<br>다섯 개 지표가 모두 권장 범위 안에 있습니다.';
    }else{
      sum = '지표 값을 불러오면 분석이 표시됩니다. (개요 탭에서 기간을 조회하세요)';
    }
    var s=document.getElementById('aiSummary'); if(s) s.innerHTML=sum;

    // 생활습관 코칭 — 가장 두드러진 문제 기준(환자 앱과 동일한 문구 체계)
    var head='', tips=[];
    if(!isNaN(tar) && tar>=25){
      head='선택 기간 동안 고혈당 시간이 길었습니다. 식후 혈당 상승이 반복되는 양상입니다.';
      tips=['식사량(특히 정제 탄수화물) 줄이도록 안내','채소·단백질 먼저 섭취, 식사 속도 20분 이상','식후 20~30분 걷기 권장'];
    }else if(!isNaN(tbr) && tbr>=4){
      head='선택 기간 동안 저혈당이 관찰되었습니다. 저혈당 원인 확인이 우선입니다.';
      tips=['공복 운동 회피, 식사 거르지 않도록 안내','약물(인슐린·설포닐우레아) 용량·시점 점검','저혈당 증상 시 즉시 당분 섭취 교육'];
    }else if(!isNaN(cv) && cv>36){
      head='혈당 변동 폭이 큰 편입니다. 저혈당과 고혈당이 번갈아 나타날 수 있습니다.';
      tips=['식사 시간 규칙화, 과식·결식 회피','간식 패턴 점검','활동량을 일정하게 유지'];
    }else if(!isNaN(tir)){
      head='지난 일주일 혈당이 안정적으로 관리되고 있습니다.';
      tips=['현재 생활습관을 그대로 유지하세요.','꾸준한 측정과 기록을 계속해 주세요.'];
    }
    var c=document.getElementById('aiCoach');
    if(c) c.innerHTML = head ? (head + '<ul class="ai-tips">' + tips.map(function(t){ return '<li>'+t+'</li>'; }).join('') + '</ul>')
                             : '지표 값을 불러오면 코칭 내용이 표시됩니다.';
  };
  /* [2026-07-31 기획] 시간대별 혈당 + 식사·운동 마커 그래프 + 하단 식사/운동 2박스.
     환자 앱(patient_main.jsp loadDayChart)과 같은 원천·같은 표현.
     날짜 = 조회기간 종료일(#endDate). 조회 3건은 한 번에 받아 그래프와 두 박스가 같은 자료를 쓴다. */
  /* ★차트 영역이 '실제로 보일 때'까지 기다렸다 그린다(2026-07-31 — 보였다 안 보였다 하던 원인).
     탭 전환 애니메이션/렌더 시점이 기기·상황마다 달라 고정 지연(setTimeout)으로는 폭이 0인 채로
     그려지는 경우가 생겼다. 폭이 잡힐 때까지 50ms 간격으로 확인(최대 2초)한 뒤 실행한다. */
  function _whenVisible(dom, cb, tries){
    tries = tries || 0;
    if((dom.clientWidth > 0 && dom.offsetParent !== null) || tries > 40){ cb(); return; }
    setTimeout(function(){ _whenVisible(dom, cb, tries + 1); }, 50);
  }
  /* ★중복 실행 방지(2026-07-31 '불안하게 뜨네요') — 탭 클릭 핸들러와 감시 안전망이 겹쳐 조회가 두 번 돌면
     그리는 도중 다시 그려져 깜빡이거나 빈 화면이 스쳤다. 진행 중이면 무시하고, 같은 날짜는 다시 그리지 않는다. */
  var _aiBusy = false, _aiDrawnKey = '';
  window.aiDayRender = function(force){
    var dom = document.getElementById('aiDayChart');
    if(!dom){ console.warn('[AI분석] 차트 영역 없음'); return; }
    if(typeof echarts === 'undefined'){ dom.innerHTML = '<div class="ai-box" style="color:#d9534f">차트 라이브러리(echarts)를 불러오지 못했습니다.</div>'; return; }
    if(_aiBusy) return;
    var _key = ($("#end_date").val() || "").substring(0,10);
    if(!force && _key && _key === _aiDrawnKey && dom.querySelector('canvas')) return;   // 이미 같은 날짜로 그려져 있음
    _aiBusy = true;
    dom.innerHTML = '<div class="ai-box">불러오는 중…</div>';   // 실행 여부를 화면에서 바로 확인(2026-07-31 진단)
    var dateKey = _key;                                          // 'YYYY-MM-DD' (조회기간 종료일)
    var uid = "${sessionScope['t_user_uuid']}";                        // 선택 환자 UUID(다른 조회와 동일 원천)
    if(!dateKey || !uid){ _aiBusy = false; dom.innerHTML = '<div class="ai-box">조회 기간/환자 정보가 없습니다. (기간 '+(dateKey||'-')+' / 환자 '+(uid?'있음':'없음')+')</div>'; return; }
    $("#aiDayTitle").text(dateKey + " 시간대별 혈당 추이");
    $(".aiDayTxt").text(dateKey);
    var dc = dateKey.replace(/-/g,'');                                 // 'YYYYMMDD'
    var prev = echarts.getInstanceByDom(dom); if(prev) prev.dispose();

    /* ★조회 3건은 서로 독립 처리한다(2026-07-31) — 종전엔 $.when 으로 묶어, 식사/운동 조회가 하나라도
       실패하면 done 이 실행되지 않아 <혈당 그래프까지 통째로 비어> 보였다(의사 화면에서 발생).
       실패한 건은 빈 결과로 바꿔 이어가므로, 혈당만 있어도 그래프는 그려진다. */
    var _soft = function(req){ return req.then(null, function(){ return $.Deferred().resolve(null).promise(); }); };
    $.when(
      _soft($.ajax({ url:CommonUtil.getContextPath()+"/getBloodChartData.do", type:"post",
        data:JSON.stringify({ end:dateKey, userId:uid }), contentType:"application/json", dataType:"json" })),
      _soft($.ajax({ url:CommonUtil.getContextPath()+"/getFoodInfo.do", type:"post",
        data:JSON.stringify({ userUuid:uid, eatDate:dc }), contentType:"application/json", dataType:"json" })),
      _soft($.ajax({ url:CommonUtil.getContextPath()+"/getExerInfo.do", type:"post",
        data:JSON.stringify({ userUuid:uid, exerDate:dc }), contentType:"application/json", dataType:"json" }))
    ).done(function(bRes, fRes, eRes){
      // 성공 시 [data, status, xhr] 배열 / 실패로 대체된 건 null
      var _d = function(r){ return (r && r.length !== undefined && r[1] !== undefined) ? r[0] : r; };
      var b = _d(bRes), f = _d(fRes), e = _d(eRes);
      var rows     = Array.isArray(b) ? b : (b && b.Data ? b.Data : []);
      var foodRows = (f && f.Data) ? f.Data : [];
      var exerRows = (e && e.Data) ? e.Data : [];
      console.log('[AI분석]', dateKey, '혈당', rows.length, '식사', foodRows.length, '운동', exerRows.length);

      // 시간(HH)별 혈당 평균
      var buckets = {};
      rows.forEach(function(r){
        var hm = r.HM || (function(v){ var s=String(v==null?'':v); var m=s.match(/(\d{2}):(\d{2})/); return m?(m[1]+':'+m[2]):''; })(r.DTM);
        var hh = hm.substring(0,2), v = parseInt(r.UPT,10);
        if(!hh || isNaN(v)) return;
        if(!buckets[hh]) buckets[hh]={sum:0,cnt:0};
        buckets[hh].sum += v; buckets[hh].cnt++;
      });
      var foodMap = {}, exerMap = {};
      foodRows.forEach(function(r){ var hh=(r.eatStime||'').substring(0,2); if(hh){ (foodMap[hh]=foodMap[hh]||[]).push(r.foodName||'식사'); } });
      exerRows.forEach(function(r){ var hh=(r.exerStime||'').substring(0,2); if(hh){ (exerMap[hh]=exerMap[hh]||[]).push(r.exerName||'운동'); } });

      var hourSet={};
      Object.keys(buckets).forEach(function(h){ hourSet[h]=1; });
      Object.keys(foodMap).forEach(function(h){ hourSet[h]=1; });
      Object.keys(exerMap).forEach(function(h){ hourSet[h]=1; });
      var hours = Object.keys(hourSet).sort();
      var xs = hours.map(function(h){ return h+'시'; });
      var ys = hours.map(function(h){ return buckets[h] ? Math.round(buckets[h].sum/buckets[h].cnt) : null; });
      var FOOD_Y=290, EXER_Y=258;
      var foodPts = hours.map(function(h){ return foodMap[h] ? FOOD_Y : null; });
      var exerPts = hours.map(function(h){ return exerMap[h] ? EXER_Y : null; });
      var eventLines = hours.filter(function(h){ return foodMap[h]||exerMap[h]; }).map(function(h){ return { xAxis:h+'시' }; });

      // 하단 두 박스 — 시간순 목록
      var fmtT = function(s){ s=String(s||''); return s.length>=4 ? (s.substring(0,2)+':'+s.substring(2,4)) : s; };
      var listHtml = function(arr, tmKey, nmKey, extra){
        if(!arr.length) return '<div class="ai-box">이 날짜의 기록이 없습니다.</div>';
        return '<ul class="ai-ul">' + arr.slice().sort(function(a,b){ return String(a[tmKey]||'').localeCompare(String(b[tmKey]||'')); })
          .map(function(r){
            var ex = extra ? extra(r) : '';
            return '<li><span class="ai-tm">'+fmtT(r[tmKey])+'</span><span class="ai-nm2">'+(r[nmKey]||'-')+'</span>'+ex+'</li>';
          }).join('') + '</ul>';
      };
      $("#aiFoodBox").html(listHtml(foodRows, 'eatStime', 'foodName', function(r){
        var kcal = (r.kcal!=null && r.kcal!=='') ? (' <span class="ai-sub">'+r.kcal+' kcal</span>') : '';
        return kcal;
      }));
      $("#aiExerBox").html(listHtml(exerRows, 'exerStime', 'exerName', function(r){
        var min = (r.exerTime!=null && r.exerTime!=='') ? (' <span class="ai-sub">'+r.exerTime+'분</span>') : '';
        return min;
      }));

      if(!rows.length && !foodRows.length && !exerRows.length){
        _aiBusy = false; _aiDrawnKey = '';
        dom.innerHTML = '<div class="ai-box">'+dateKey+' 데이터 없음</div>';
        return;
      }
      dom.innerHTML = '';
      var chart = echarts.init(dom);
      _aiBusy = false; _aiDrawnKey = dateKey;   // 그리기 완료 — 같은 날짜면 재조회하지 않는다
      // 영역이 보인 뒤에 그리지만, 레이아웃이 늦게 확정되는 경우까지 대비해 몇 차례 더 크기를 맞춘다
      [0, 120, 350, 800].forEach(function(ms){ setTimeout(function(){ try{ chart.resize(); }catch(e){} }, ms); });
      $(window).off('resize.aiDay').on('resize.aiDay', function(){ try{ chart.resize(); }catch(e){} });
      chart.setOption({
        tooltip:{ trigger:'axis', formatter:function(params){
          if(!params||!params.length) return '';
          var hh=hours[params[0].dataIndex]||'', bv=null;
          params.forEach(function(p){ if(p.seriesName==='혈당'&&p.value!=null) bv=p.value; });
          var txt=params[0].axisValue+'<br/>혈당: <b>'+(bv!=null?bv+' mg/dL':'기록 없음')+'</b>';
          if(foodMap[hh]) txt+='<br/>🍚 식사: '+foodMap[hh].join(', ');
          if(exerMap[hh]) txt+='<br/>🚴 운동: '+exerMap[hh].join(', ');
          return txt;
        }},
        legend:{ show:false },
        grid:{ left:40, right:16, top:20, bottom:30 },
        xAxis:{ type:'category', data:xs, axisTick:{ alignWithLabel:true } },
        yAxis:{ type:'value', min:0, max:300 },
        series:[
          { name:'혈당', type:'line', data:ys, smooth:true, areaStyle:{}, connectNulls:true,
            label:{ show:true, position:'top', formatter:function(p){ return p.value!=null?p.value:''; } },
            markPoint:{ data:[ {type:'max',name:'최고',itemStyle:{color:'#dc3545'}}, {type:'min',name:'최저',itemStyle:{color:'#f5c518'}} ] },
            markLine:{ silent:true, symbol:'none', lineStyle:{type:'dashed',color:'#c0c4cc',width:1}, label:{show:false}, data:eventLines } },
          { name:'식사', type:'scatter', data:foodPts, symbolSize:1, label:{ show:true, formatter:'🍚', fontSize:20, position:'inside' } },
          { name:'운동', type:'scatter', data:exerPts, symbolSize:1, label:{ show:true, formatter:'🚴', fontSize:20, position:'inside' } }
        ]
      });
    }).fail(function(xhr){
      _aiBusy = false; _aiDrawnKey = '';
      // 3건 중 하나라도 실패하면 done 이 안 돌아 그래프가 빈 채로 남는다 → 원인을 화면·콘솔 양쪽에 남김
      console.error('[AI분석] 조회 실패', xhr && xhr.status, xhr && xhr.responseText);
      dom.innerHTML = '<div class="ai-box" style="color:#d9534f">시간대별 조회 실패 (HTTP '+(xhr&&xhr.status)+') — 콘솔 로그를 확인하세요.</div>';
    });
  };
  // AI 분석 탭 클릭 시 최신 값으로 해석·그래프 갱신
  //   ★탭 전환(다른 스크립트가 stab-content 를 보이게 함)이 끝난 뒤 그려야 차트 크기가 0이 되지 않는다(2026-07-31)
  // AI 분석 탭 진입 감지 — id(#tab5) / 링크(a[href="#sub-tab5"]) 어느 쪽으로 걸려도 잡히게(2026-07-31)
  $(document).on('click', '#tab5, a[href="#sub-tab5"]', function(){
    setTimeout(function(){
      window.aiRender();
      var dom = document.getElementById('aiDayChart');
      if(dom) _whenVisible(dom, window.aiDayRender);   // 고정 지연 대신 '보일 때까지' 기다렸다 그린다
    }, 0);
  });
  // 안전망 — 클릭 이벤트를 못 잡는 구조여도 탭이 활성화되면 그린다(0.7초 간격 감시).
  //   aiDayRender 자체가 '진행 중 무시 / 같은 날짜 재조회 안 함' 이라 중복 조회는 일어나지 않는다.
  setInterval(function(){
    var tabEl = document.getElementById('sub-tab5');
    if(tabEl && tabEl.className.indexOf('active') >= 0 && tabEl.offsetParent !== null){
      window.aiRender();
      window.aiDayRender();
    }
  }, 700);
  // 기간(종료일)이 바뀌면 다음 진입 때 새로 그리도록 캐시 해제
  $(document).on('change', '#end_date, #start_date', function(){ _aiDrawnKey = ''; });
})();
</script>
<style>
/* AI 분석 탭 */
.ai-idx .ai-row { display:flex; align-items:flex-start; gap:10px; padding:10px 4px; border-bottom:1px solid #eef2f7; }
.ai-idx .ai-row:last-child { border-bottom:0; }
.ai-idx .ai-nm { flex:0 0 175px; font-weight:700; color:#2d303f; font-size:14px; }
.ai-idx .ai-val { flex:0 0 70px; font-weight:800; font-size:16px; text-align:right; }
.ai-idx .ai-txt { flex:1; color:#37475a; font-size:14px; line-height:1.6; }
.ai-box { font-size:14px; line-height:1.8; color:#37475a; padding:6px 4px; }
.ai-tips { margin:8px 0 0; padding-left:20px; }
.ai-tips li { margin-bottom:4px; }
/* 그래프 범례 + 하단 식사/운동 2박스 */
.ai-legend { font-size:12px; color:#8a98a8; margin:2px 0 6px; }
.ai-2box { display:flex; gap:12px; }
.ai-2box > .content-box { flex:1 1 0; min-width:0; }
.ai-list { max-height:260px; overflow-y:auto; }
.ai-ul { list-style:none; margin:0; padding:0; }
.ai-ul li { display:flex; align-items:center; gap:10px; padding:7px 4px; border-bottom:1px solid #eef2f7; font-size:14px; }
.ai-ul li:last-child { border-bottom:0; }
.ai-ul .ai-tm { flex:0 0 52px; color:#1976d2; font-weight:700; }
.ai-ul .ai-nm2 { flex:1; color:#2d303f; }
.ai-ul .ai-sub { color:#8a98a8; font-size:13px; }
</style>
</body>
</html>
