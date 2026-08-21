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
	      			// ★식사 기록이 없는 환자는 avgFood/avgMeal 이 null 로 온다(2026-08-15 한용기).
	      			//   종전엔 response.avgFood.avgFASTING 에서 TypeError 로 콜백 전체가 죽어
	      			//   평균혈당·GMI·CV·표준편차까지 전부 빈 칸이 됐다. 항목별로 독립 계산하고, 없는 값은 '-' 로 표시한다.
	      			var _num = function(v){ var n = Math.round(parseFloat(v)); return isNaN(n) ? '-' : n; };
	      			var _raw = function(v){ return (v == null || v === '') ? '-' : v; };
	      			/* ★★[2026-08-18 확정] 세 평균의 뜻을 못 박는다.
	      			     · 평균혈당 = **기간 전체 평균**(AvgBlood)
	      			     · 공복평균 = **새벽 03~05시 평균**(FASTING) — 종전에는 `avgFood`(식전 직전 값)를 썼는데
	      			       ***식사 기록이 있어야만*** 나오는 값이라, 기록이 없으면 빈 칸이었다.
	      			     · 식후평균 = **아침·점심·저녁 식후 2시간** 값의 평균(avgMeal)
	      			       ⇒ ★***식사 등록이 없으면 평균혈당으로 대신 보여준다***(빈 칸 대신). */
					var avgBlood = _num(response.AvgBlood);
	      			var fastingAvg = _num(response.FASTING);
					var avgMeal = _num(response.avgMeal && response.avgMeal.avgBlood);
					if (avgMeal === '-') avgMeal = avgBlood;      // 식사 기록 없음 → 평균혈당

					/* ★★[2026-08-18] TIR·TAR·TBR 도 **여기 값으로 통일**한다(앱과 같은 식·기간·필터).
					   ⚠종전에는 구간 카운트 조회에서 따로 계산해 ***앱 95% / 웹 96%*** 로 어긋났다.
					   ★자리수도 앱에 맞춘다 — TIR 은 정수(서버가 FLOOR), TAR·TBR 은 소수 1자리. */
					var _f1 = function(v){ var n = parseFloat(v); return isNaN(n) ? '-' : n.toFixed(1); };
					window.__IDX = { TIR: _num(response.TIR), TAR: _f1(response.TAR), TBR: _f1(response.TBR) };
					window.applyIdxCards = function(){
						var ok = '#2f9e63', bad = '#d9534f', put = function(id, val, good){
							var el = document.getElementById(id); if(!el) return;
							el.textContent = val;
							el.style.color = good ? ok : bad; el.style.fontWeight = 'bold';
						};
						var I = window.__IDX; if(!I) return;
						put('tirCard', I.TIR, parseFloat(I.TIR) >= 70);
						put('tarCard', I.TAR, parseFloat(I.TAR) <  25);
						put('tbrCard', I.TBR, parseFloat(I.TBR) <   4);
					};
					window.applyIdxCards();
					//개요
	      			document.getElementById('gmi').textContent = _raw(response.GMI);
	      			document.getElementById('std').textContent = _raw(response.stdBlood);
	      			document.getElementById('cv').textContent = _raw(response.CV);
	      			document.getElementById('fastingAvg').textContent = fastingAvg;
	      			document.getElementById('avg').textContent = avgBlood;
	      			document.getElementById('avgMeal').textContent = avgMeal;
                    //agp추가
	      			document.getElementById('gmi_agp').textContent = _raw(response.GMI);
	      			document.getElementById('std_agp').textContent = _raw(response.stdBlood);
	      			document.getElementById('cv_agp').textContent = _raw(response.CV);
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

		
		// [2026-08-15] '목표 내 혈당' 컴포넌트 — 세로 막대(구간 비례) + 구간별 %·(시간/일) + 그룹 소계 + 목표·목표 대비.
	//   종전 [혈당 범위 차트 + 목표 및 목표대비] 두 박스를 대체. 시간/일 = 비율×24시간(1% = 14.4분).
	//   구간 경계(250/180/70/54)와 목표 기준(5/25/70/4/1%) 문구는 종전 그대로.
	function _renderTirGoal(vl, lo, nor, hi, vh){
	    var wrap = document.getElementById('tirGoalWrap');
	    if(!wrap) return;
	    function tm(p){
	        var m = Math.round(p * 14.4);
	        if(m >= 60){ return Math.floor(m/60) + '시간 ' + (m%60) + '분/일'; }
	        return m + '분/일';
	    }
	    function chip(p, goal){
	        var d = p - goal, up = d > 0;
	        var col = up ? '#d64545' : '#1a73e8', bg = up ? 'rgba(214,69,69,.09)' : 'rgba(26,115,232,.09)';
	        return '<span style="display:inline-block; padding:2px 9px; border-radius:12px; font-weight:700; font-size:13px; color:'+col+'; background:'+bg+';">'+(up?'▲':'▼')+Math.abs(d)+'%</span>';
	    }
	    var ROWS = [
	        { nm:'매우 높음',    p:vh,  goal:'5% 미만 (1시간 12분 미만/일)',   g:5,  big:false },
	        { nm:'높음',         p:hi,  goal:'25% 미만 (6시간 미만/일)',       g:25, big:false },
	        { nm:'목표 내 범위', p:nor, goal:'70% 초과 (16시간 48분 초과/일)', g:70, big:true  },
	        { nm:'낮음',         p:lo,  goal:'4% 미만 (57분 미만/일)',         g:4,  big:false },
	        { nm:'매우 낮음',    p:vl,  goal:'1% 미만 (14분 미만/일)',         g:1,  big:false }
	    ];
	    // ── 세로 막대: 비율대로, 0% 구간도 최소 두께로 표시(참고 시안과 동일한 인상) ──
	    var H = 372, MINH = 16;   // [2026-08-15] 0% 구간도 참고 시안처럼 도톰하게. 16px = 높음·낮음 행 높이(45/19)와 블록 중심이 정확히 맞는 값 — 같이 조정할 것
	    // [2026-08-15] 참고 시안 색: 매우높음·낮음 = 진회색(위아래 동일), 높음 = 주황, 목표 = 초록, 매우낮음 = 진홍
    var COL = { vh:'#616161', hi:'#F5A623', nor:'#00A651', lo:'#616161', vl:'#8E1B1B' };
	    // [2026-08-15] 참조화면(LibreView): 매우 높음 블록은 자기 밑줄(58) "아래"에 매달리고(4px 세로선 연결),
	    //   막대 본체(높음·목표·낮음)는 그 아래(BODYTOP)부터 430까지. 매우 낮음 블록은 본체 아래, 자기 밑줄(456) 위.
	    var hs = {};
	    [['vh',vh],['hi',hi],['lo',lo],['vl',vl]].forEach(function(a){ hs[a[0]] = Math.max(MINH, Math.round(a[1]/100*H)); });
	    var GAP = 3;
	    var BARTOP = 58, BOT = 26, TOTALH = H + BARTOP + BOT;
	    var vhH = Math.max(6, hs.vh - GAP), vlH = Math.max(6, hs.vl - GAP);
	    var BODYTOP = BARTOP + 4 + vhH + GAP, BODYH = BARTOP + H - BODYTOP;
	    hs.nor = Math.max(MINH, BODYH - hs.hi - hs.lo);
	    var tot = hs.hi + hs.nor + hs.lo;
	    if(tot > BODYH){ ['hi','nor','lo'].forEach(function(k){ hs[k] = Math.round(hs[k]*BODYH/tot); }); }
	    var y = 0, seg = '', bounds = [0];
	    ['hi','nor','lo'].forEach(function(k, i){
	        var segH = Math.max(6, hs[k] - (i < 2 ? GAP : 0));
	        seg += '<div style="position:absolute; left:0; width:100%; top:'+y+'px; height:'+segH+'px; background:'+COL[k]+';"></div>';
	        y += hs[k];
	        if(i < 2) bounds.push(y);
	    });
	    bounds.push(BODYH);
	    // 경계 숫자(250/180/70/54) 겹침 방지 — 구간이 얇으면 숫자를 최소 16px 간격으로 밀어낸다
	    var labY = bounds.map(function(b){ return b - 9; });
	    var li;
	    for(li = 1; li < labY.length; li++){ if(labY[li] - labY[li-1] < 16) labY[li] = labY[li-1] + 16; }
	    for(li = labY.length - 1; li >= 0; li--){
	        if(labY[li] > BODYH - 6) labY[li] = BODYH - 6;
	        if(li < labY.length - 1 && labY[li+1] - labY[li] < 16) labY[li] = labY[li+1] - 16;
	    }
	    var axis = [250,180,70,54].map(function(v, j){
	        return '<span style="position:absolute; right:6px; top:'+labY[j]+'px; font-weight:700; font-size:14px; color:#333;">'+v+'</span>';
	    }).join('');
	    // [2026-08-15] 참조화면 배치: 매우 높음 블록 [62..62+vhH](밑줄 58 아래), 본체 [BODYTOP..430],
	    //   매우 낮음 블록 [432..432+vlH](밑줄 456 위). 훅 = 블록 가로 중앙(x124) 세로선이 각 밑줄(왼쪽 연장)과 ㄱ/ㄴ자로 연결.
	    var vlBot = BARTOP + H + 2 + vlH;
	    var outerBlocks =
	          '<div style="position:absolute; left:96px; width:56px; top:'+(BARTOP + 4)+'px; height:'+vhH+'px; background:'+COL.vh+';"></div>'
	        + '<div style="position:absolute; left:96px; width:56px; top:'+(BARTOP + H + 2)+'px; height:'+vlH+'px; background:'+COL.vl+';"></div>';
	    var hooks =
	          '<span style="position:absolute; left:124px; top:'+BARTOP+'px; width:0; height:4px; border-left:2.5px solid #8a8a8a;"></span>'
	        + '<span style="position:absolute; left:124px; top:'+vlBot+'px; width:0; height:'+(TOTALH - 2 - vlBot)+'px; border-left:2.5px solid #8a8a8a;"></span>';
	    var barHtml = '<div style="position:relative; flex:0 0 158px; height:'+TOTALH+'px;">'
	        + '<span style="position:absolute; left:0; top:'+(BARTOP+Math.round(H/2)-9)+'px; font-size:12px; color:#888;">mg/dL</span>'
	        + '<div style="position:absolute; left:46px; top:'+BODYTOP+'px; width:44px; height:'+BODYH+'px;">'+axis+'</div>'
	        + '<div style="position:absolute; left:96px; top:'+BODYTOP+'px; width:56px; height:'+BODYH+'px;">'+seg+'</div>'
	        + outerBlocks
	        + hooks
	        + '</div>';
	    // ── 우측 표: 5행 + 상/하 그룹 소계(세로 괄선) + 목표·목표 대비 ──
	    function row(r, gr, ln){
	        // ln = 행 밑 가로 안내선이 걸치는 열 범위. 그룹 행은 소계 괄선 앞(1/4), 단독 행은 목표 열 앞(1/5)까지.
	        // [2026-08-15] 선 굵기·색은 소계선과 통일(2.5px #8a8a8a). 그룹 행(1/4)은 괄선 세로선에서 딱 멈추고,
	        //   단독 행(1/5)은 목표 열 앞 세로 점선을 넘지 않게 점선 직전에서 끝냄.
	        var mr = (ln === '1 / 4') ? '1px' : '3px';
	        // 매우 높음(2행)·매우 낮음(8행) 밑줄은 왼쪽으로 연장해 블록 중앙 세로 훅 선(x124)과 연결
	        var mlh = (gr === 2 || gr === 8) ? ' margin-left:-46px;' : '';
	        return '<span style="grid-row:'+gr+'; grid-column:'+ln+'; align-self:end; height:0; border-bottom:2.5px solid #8a8a8a; margin-right:'+mr+';'+mlh+'"></span>'
	             + '<span style="grid-row:'+gr+'; grid-column:1; font-size:15px; font-weight:700; color:#222; word-break:keep-all;">'+r.nm+'</span>'
	             + '<b style="grid-row:'+gr+'; grid-column:2; font-size:'+(r.big?'20px':'16px')+'; color:#111; text-align:right; padding-right:4px;">'+r.p+'%</b>'
	             + '<span style="grid-row:'+gr+'; grid-column:3; font-size:13px; color:#777;">('+tm(r.p)+')</span>'
	             + '<span style="grid-row:'+gr+'; grid-column:5; font-size:14px; font-weight:600; color:#333; word-break:keep-all;">'+r.goal+'</span>'
	             + '<span style="grid-row:'+gr+'; grid-column:6;">'+chip(r.p, r.g)+'</span>';
	    }
	    // [2026-08-15] 목표 내 범위(단독 행) — %·시간을 소계와 같은 열 위치(4열, 같은 padding)에 두어
	    //   위(21%)·아래(1%) 소계와 세로로 정렬되게 한다. 밑줄은 기존처럼 목표 열 앞까지.
	    function midRow(r, gr){
	        return '<span style="grid-row:'+gr+'; grid-column:1 / 5; align-self:end; height:0; border-bottom:2.5px solid #8a8a8a; margin-right:3px;"></span>'
	             + '<span style="grid-row:'+gr+'; grid-column:1; font-size:15px; font-weight:700; color:#222; word-break:keep-all;">'+r.nm+'</span>'
	             + '<span style="grid-row:'+gr+'; grid-column:4; display:flex; align-items:baseline; justify-content:space-between; padding:0 18px 0 16px;">'
	             + '<b style="font-size:20px; color:#111;">'+r.p+'%</b>'
	             + '<small style="color:#777; font-size:13px; white-space:nowrap;">('+tm(r.p)+')</small></span>'
	             + '<span style="grid-row:'+gr+'; grid-column:5; font-size:14px; font-weight:600; color:#333; word-break:keep-all;">'+r.goal+'</span>'
	             + '<span style="grid-row:'+gr+'; grid-column:6;">'+chip(r.p, r.g)+'</span>';
	    }
	    // [2026-08-15] 참고 시안 괄선: 소계 [%·(분/일)]이 선 "위"에 오고, 그 아래 굵은(2.5px) 가로선이
	    //   괄선 세로선부터 목표 열 앞까지 길게 이어진다. gr=소계가 걸치는 두 행, connGr=세로 연결선이 차지하는 아래 행.
	    function comb(p, gr, connGr){
	        // [2026-08-15] 세로 괄선도 소계선과 같은 굵기·색. 오른쪽은 목표 열 글자에 닿지 않게 선·글자 모두 안쪽에서 끝냄.
	        return '<span style="grid-row:'+connGr+'; grid-column:4; align-self:stretch; justify-self:start; width:0; margin-left:-11px; border-left:2.5px solid #8a8a8a;"></span>'
	             + '<span style="grid-row:'+gr+'; grid-column:4; align-self:center; display:flex; flex-direction:column; gap:4px;">'
	             + '<span style="display:flex; align-items:baseline; justify-content:space-between; padding:0 18px 0 16px;">'
	             + '<b style="font-size:16px; color:#111;">'+p+'%</b>'
	             + '<small style="color:#777; font-size:12px; white-space:nowrap;">('+tm(p)+')</small></span>'
	             + '<span style="height:0; border-bottom:2.5px solid #8a8a8a; margin-left:-11px;"></span>'
	             + '</span>';
	    }
	    // [2026-08-15] 참고 시안: 소계(4열)를 늘림폭 담당(1fr)으로 두어 목표·목표 대비 열을 우측 끝으로 밀착
	    // 행 구성: 헤더 28 | 매우 높음 30(밑줄 58, 블록은 그 아래 매달림) | 높음 36(주황 블록 옆) | fr | 목표 50 | fr
	    //   | 낮음 22(밑줄 430=본체 끝=회색 블록 끝, 글자가 매우 낮음과 겹치지 않게 위로 여유) | 매우 낮음 26(블록은 본체 아래, 밑줄 456)
	    //   ※ MINH=16·GAP=3 기준으로 블록과 밑줄·텍스트가 맞물리도록 계산된 값
	    var gridHtml = '<div style="flex:1; min-width:620px; height:'+TOTALH+'px; display:grid;'
	        + ' grid-template-columns: 96px 60px 112px minmax(120px,1fr) auto 110px;'
	        + ' grid-template-rows: 28px 30px 36px minmax(20px,1fr) 50px minmax(20px,1fr) 22px 26px;'
	        + ' align-items:center; column-gap:10px;">'
	        + '<b style="grid-row:1; grid-column:5; font-size:14px; color:#333;">목표</b>'
	        + '<b style="grid-row:1; grid-column:6; font-size:14px; color:#333;">목표 대비</b>'
	        // 목표 · 목표 대비 열 앞 세로 점선(참고 시안)
	        + '<span style="grid-row:1 / 9; grid-column:5; align-self:stretch; justify-self:start; width:0; margin-left:-12px; border-left:1px dashed #ccc;"></span>'
	        + '<span style="grid-row:1 / 9; grid-column:6; align-self:stretch; justify-self:start; width:0; margin-left:-12px; border-left:1px dashed #ccc;"></span>'
	        + row(ROWS[0], 2, '1 / 4') + row(ROWS[1], 3, '1 / 4') + comb(vh + hi, '2 / 4', 3)
	        + midRow(ROWS[2], 5)
	        + row(ROWS[3], 7, '1 / 4') + row(ROWS[4], 8, '1 / 4') + comb(lo + vl, '7 / 9', 8)
	        + '</div>';
	    // [2026-08-15] 참고 시안 상단 안내문구(파란 글씨)
	    var noteHtml = '<div style="font-size:13px; font-weight:600; color:#1a73e8; line-height:1.55; margin:2px 0 4px 4px;">'
	        + '5% 이상 증가해야 임상적으로 유의미합니다.<br>각 1% Time in range = 약 15분.</div>';
	    wrap.innerHTML = noteHtml + '<div style="display:flex; align-items:flex-start; gap:12px; padding:6px 2px; flex-wrap:wrap;">' + barHtml + gridHtml + '</div>';
	}

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
	  	     		
	  	     		// [2026-08-15] '목표 내 혈당' 컴포넌트 렌더 — 종전 두 박스(echarts 막대·목표대비 텍스트)를 대체
	  	     		_renderTirGoal(lowestPercentage, lowPercentage, normalPercentage, highPercentage, highestPercentage);

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
	  	     		    /* ★[2026-08-18] 카드 세 개는 ***calcBlood 값이 있으면 그것을 쓴다*** —
	  	     		       앱과 같은 식·같은 기간·같은 0값 필터로 낸 값이다(§동일 기준).
	  	     		       구간 막대(위 낮음/정상/높음)는 종전 카운트를 그대로 쓴다 — 그건 5구간이라 축이 다르다.
	  	     		       ⚠calcBlood 가 먼저 끝나든 나중이든 같은 값이 남도록, 양쪽에서 applyIdxCards() 를 부른다. */
	  	     		    if (window.applyIdxCards && window.__IDX) { window.applyIdxCards(); }
	  	     		    else { card('tirCard', TIR, TIR >= 70); card('tarCard', TAR, TAR < 25); card('tbrCard', TBR, TBR < 4); }
	  	     		})();
	  	     		if (false) { // [2026-08-15] 이하 종전 '목표 및 목표대비' 텍스트 계산 + echarts 막대 — 목표 내 혈당 컴포넌트로 대체(코드 보존·미실행)
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


	  	            } // [2026-08-15] if(false) 끝 — #mainChart 는 제거됨. 아래 setOption 호출은 빈 객체로 무해화
	  	            var chart = { setOption: function(){} };
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
		// [2026-08-21] 식후·전체·공복 세 선을 한 축에 겹치면 값이 비슷해 서로 가린다(사용자 지적) →
		// 위/중/아래 3칸으로 나눠 칸마다 자기 눈금(scale)으로 변화를 보인다. 날짜축·툴팁은 세 칸이 공유.
		// 0(자료 없음)은 null 로 두어 칸의 눈금을 끌어내리지 않는다. 「일별 평균 혈당」·「최근 일주일 평균 혈당」 공용.
		//   panels = [{name, color, data}] (위→아래 순 — 호출부가 식후·전체·공복으로 넘긴다) · chartEl = 높이를 잴 컨테이너 · opt = {zoom:슬라이더, xMax:날짜축 상한}
		function wnnAvgPanelOption(title, xData, panels, chartEl, opt) {
		    opt = opt || {};
		    var nz = function(arr){ return arr.map(function(v){ return (v && v > 0) ? v : null; }); };
		    var P_TOP = 60, P_GAP = 38, P_BOTTOM = opt.zoom ? 70 : 40;   // 제목 · 칸 사이(날짜 라벨 자리) · 슬라이더/여백
		    // ⚠높이는 clientHeight 로 재면 안 된다 — 첫 화면은 「개요」 탭이라 혈당 그래프·통계 컨테이너는 display:none 상태(0px)로
		    //   그려지고, 탭을 열 때의 resize() 는 칸 배치(grid top/height)를 다시 계산하지 않는다 → inline style 높이(720px)를 우선.
		    var H  = parseFloat(chartEl.style && chartEl.style.height) || chartEl.clientHeight || 720;
		    var pH = Math.max(90, Math.floor((H - P_TOP - P_BOTTOM - P_GAP * 2) / 3));
		    var grids = [], xAxes = [], yAxes = [], series = [];
		    panels.forEach(function(p, i){
		        var top = P_TOP + i * (pH + P_GAP);
		        grids.push({ left: 70, right: 40, top: top, height: pH });
		        var xa = { type: 'category', gridIndex: i, data: xData,   // boundaryGap 기본(true) — 양 끝 점이 축선에 붙지 않게
		                   axisLabel: { fontSize: 11, fontWeight: 'bolder' } };
		        if (opt.xMax != null) xa.max = opt.xMax;
		        xAxes.push(xa);
		        yAxes.push({
		            type: 'value', gridIndex: i, scale: true,        // 칸마다 값 범위에 맞춘 눈금 — 변화가 보이게
		            name: p.name, nameLocation: 'middle', nameGap: 48,
		            nameTextStyle: { color: p.color === 'pink' ? '#e06b8a' : p.color, fontWeight: 'bolder', fontSize: 12 },
		            splitNumber: 3,
		            axisLabel: { fontSize: 11, fontWeight: 'bolder' }
		        });
		        series.push({
		            name: p.name, type: 'line', xAxisIndex: i, yAxisIndex: i,
		            data: nz(p.data), connectNulls: true,
		            itemStyle: { color: p.color }, lineStyle: { color: p.color, width: 2 },
		            symbolSize: 9,
		            label: { show: true, position: 'top', fontSize: 11, fontWeight: 'bolder' }
		        });
		    });
		    var o = {
		        title: { text: title },
		        tooltip: {
		            trigger: 'axis',
		            // 칸이 셋이라 기본 툴팁은 날짜 머리를 세 번 찍는다 → 날짜 한 줄 + 칸 순서(식후·전체·공복) 한 덩이로
		            formatter: function(ps){
		                ps = Array.isArray(ps) ? ps : [ps];
		                var seen = {}, rows = [];
		                panels.forEach(function(p){
		                    ps.forEach(function(q){
		                        if (q.seriesName !== p.name || seen[p.name]) return;
		                        seen[p.name] = 1;
		                        rows.push(q.marker + ' ' + p.name + ' <b style="float:right;margin-left:18px">' + (q.value == null ? '-' : q.value) + '</b>');
		                    });
		                });
		                return (ps[0] ? ps[0].axisValue : '') + '<br/>' + rows.join('<br/>');
		            }
		        },
		        axisPointer: { link: [{ xAxisIndex: 'all' }] },   // 한 날짜를 가리키면 세 칸 모두 표시
		        legend: { data: panels.map(function(p){ return p.name; }), top: 4, right: 10 },
		        grid: grids, xAxis: xAxes, yAxis: yAxes, series: series
		    };
		    if (opt.zoom) o.dataZoom = [{ type: 'slider', show: true, xAxisIndex: [0, 1, 2], start: 0, end: 100 }];
		    return o;
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

	  	          // 3칸 분리 — 공용 wnnAvgPanelOption (2026-08-21). ★칸 순서는 위→아래 = 식후 · 전체 · 공복
	  	          //   (「공복 값이 제일 밑에 있게」 — 혈당이 낮은 공복을 바닥에, 높은 식후를 위에. 범례·툴팁도 같은 순서).
	  	          // 값 = getDaylyBloodData : 공복 avgfasting = 그날 03~05시 평균 · 식후 avgpost = 끼니마다 [식사+2h,+3h) 첫 측정 평균
	  	          //   (2026-08-21 확정 정의로 쿼리 교체 — 종전 버킷 방식은 공복·식후가 뒤섞였다. 정의는 Blood_SQL.xml 머리말).
	  	          var panels = [
	  	              { name: '식후 평균', color: 'orange', data: avgpost    },
	  	              { name: '전체 평균', color: 'blue',   data: avgBlood   },
	  	              { name: '공복 평균', color: 'pink',   data: avgfasting }
	  	          ];
	  	          var option3 = wnnAvgPanelOption('일별 평균 혈당', date2, panels, document.getElementById('BloodAveChart'), { zoom: true });

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
	  	                  /* ★[2026-08-18] `interval:0` 이 없으면 ECharts 가 자리가 좁다고 **제멋대로 건너뛴다** —
	  	                     3시간 간격으로 적어 두었는데 화면에는 오전12·오전6·오후12·오후6 **6시간 간격**으로만 나왔다.
	  	                     빈 칸('')은 어차피 안 보이므로 전부 그리게 두면 3시간 간격이 그대로 나온다. */
	  	                  axisLabel: { color: '#6b7280', fontSize: 12, interval: 0, hideOverlap: false }
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

	  	          // 공복·전체·식후 3칸 분리 — 일별 평균 혈당과 같은 공용 wnnAvgPanelOption (2026-08-21, 개요·통계 두 탭에 같은 option)
	  	          // 칸 순서 위→아래 = 식후 · 전체 · 공복(일별 차트와 동일). 값 = getFastingBlood(03~05시) · getPostBlood(식사+2h~3h)
	  	          //   — 세 응답은 같은 날짜 목록 위에 LEFT JOIN 되어 길이가 같다(위치로 맞추는 아래 unshift 패딩이 어긋나지 않게).
	  	          var panels = [
	  	              { name: '식후 평균', color: 'orange', data: avgPostMeal },
	  	              { name: '전체 평균', color: 'green',  data: avgBlood    },
	  	              { name: '공복 평균', color: 'pink',   data: avgFasting  }
	  	          ];
	  	          var option = wnnAvgPanelOption('최근 일주일 평균 혈당', rotatedWeekdays, panels, document.getElementById('mealAveChart'), { xMax: 6, zoom: true }); // zoom: 혈당 그래프와 같은 배치(칸 높이 동일)

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
			            </section><%-- 2026-08-21 누락돼 있던 닫힘 — 없으면 뒤의 차트 카드가 이 카드 안으로 말려 들 수 있다 --%>
			          </div>
			          <!-- <section class="content-box">
			            <h5>요일별<span>평균혈당</span></h5>
			            <div><div id="weeklyBloodChart" style="width: 1100px; height: 400px;"></div></div>
			          </section> -->
			            <div class="chart-wrap">
				          <section class="content-box"><div id="mealAveChart" style="height: 600px; width: 1100px; margin: 0 auto;"></div></section>
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
					      <%-- [2026-08-15] '목표 내 혈당' — 종전 [혈당 범위 차트(echarts)+목표 및 목표대비(텍스트)] 두 박스를
					           세로 막대 + 구간별 %·시간/일 + 목표·목표 대비 표(참고 시안) 한 컴포넌트로 통합.
					           내용은 _renderTirGoal() 이 drawBloodBarChart 응답 값으로 그린다. 구간 경계(250/180/70/54)·목표 기준 종전 동일. --%>
					      <section class="content-box" style="width:100%; margin: 0 auto;">
						 	<h5>
								목표 내 혈당 <span>기간 내 평균 혈당 비율 및 시간을 나타냅니다.</span>
							</h5>
							<%-- [2026-08-15] width:100% 필수 — content-box가 align-items:flex-start 라 없으면 내용 최소폭으로 줄어 목표 열이 왼쪽에 붙음 --%>
							<div id="tirGoalWrap" style="width:100%; min-height:410px;"></div>
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
							<%-- ★[2026-08-18] 제목·설명 추가 — 원본 AGP 보고서에 있는 문구다.
							     그래프만 있으면 「중앙값과 백분위수가 <하루 만에> 겹쳐 그려진 그림」이라는 것을
							     모르고 그날그날 혈당으로 읽는다. 표준 AGP 설명을 그대로 둔다. --%>
							<h5>활동 혈당 개요(AGP)
								<span>AGP는 조회 기간 동안의 혈당값을 요약한 것으로, 중앙값(50%)과 기타 백분위수가 하루 만에 발생한 것처럼 표시됩니다.</span></h5>
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
				          <section class="content-box"><div id="BloodAveChart" style="height: 600px; width: 1100px; margin: 0 auto;"></div></section>
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
						  <section class="content-box"><div id="mealsChart" style="height: 500PX; width: 1100px; margin: 0 auto;"></div></section>
						</div>
						<div class="chart-wrap">
				          <section class="content-box"><div id="mealAveChart2" style="height: 600px; width: 1100px; margin: 0 auto;"></div></section>
						</div>
						<div class="chart-wrap">
				          <section class="content-box"><div id="weeklyChart2" style="height: 500PX; width: 1100px; margin: 0 auto;"></div></section>
						</div>
					</div>
				</div>

				<%-- [2026-07-31 기획] AI 분석 — 5개 지표별 현재상태 해석 + 종합 분석/코칭.
				     값은 개요 탭에서 이미 계산된 것(TIR/TAR/TBR/CV/GMI·평균)을 그대로 읽어 쓴다(추가 조회 없음).
				     탭을 열 때마다 최신 값으로 다시 해석한다(aiRender). --%>
				<div class="stab-content" id="sub-tab5">
					<div class="steb-container">
						<%-- [2026-07-31 기획] 환자 앱(patient_main.jsp)의 '시간대별 혈당 + 식사·운동 마커' 그래프를 그대로 가져옴.
						     ★[2026-08-18] ***기간 전체***로 바꿨다 — 원천 = getBloodChartDataMulti(start~end).
						       식사·운동은 하루 단위 조회라 함께 뺐다(위 그래프·아래 두 박스). --%>
						<section class="content-box">
							<h5><span id="aiDayTitle">혈당 추이</span></h5>
							<%-- ★식사·운동 표식을 뺐으므로 범례도 혈당·목표범위만 남긴다(2026-08-18) --%>
							<div class="ai-legend">
								<span style="color:#2f6fd1">— 혈당</span> &nbsp;·&nbsp;
								<span style="color:#2f9e63">--- 목표범위 70~180</span>
							</div>
							<div id="aiDayChart" style="height:340px; width:100%;"></div>
						</section>
						<section class="content-box">
							<%-- ★기간 표기(2026-08-18) — 위 그래프와 <같은 기간>을 본다는 것을 못 박는다.
							     종전에는 그래프만 하루라서 「이 해석도 그날 것인가」로 읽혔다. --%>
							<h5>📌 지표 해석 <small style="font-weight:400;color:#888;">— <span class="aiDayTxt"></span> · 대한당뇨병학회 관리지표 기준</small></h5>
							<div id="aiIdxWrap" class="ai-idx"></div>
						</section>
						<%-- 종합 분석 · 생활습관 코칭 — 한 줄에 두 박스로(2026-07-31 요청, 세로 여백 절약) --%>
						<div class="content-row flex-left-right ai-2box">
							<section class="content-box">
								<h5>🩺 종합 분석 <small style="font-weight:400;color:#888;">— <span class="aiDayTxt"></span></small></h5>
								<div id="aiSummary" class="ai-box">개요 탭에서 기간을 조회하면 표시됩니다.</div>
							</section>
							<section class="content-box">
								<h5>💡 생활습관 코칭 <small style="font-weight:400;color:#888;">— <span class="aiDayTxt"></span></small></h5>
								<div id="aiCoach" class="ai-box">개요 탭에서 기간을 조회하면 표시됩니다.</div>
							</section>
						</div>
						<%-- ★[2026-08-18 요청] 식사·운동 정보 두 박스를 **뺐다**.
						     조회가 <하루 단위>(eatDate/exerDate)라 이 탭이 기간 그래프로 바뀌면서
						     ***혼자만 종료일 하루 것***이 되어 화면이 서로 다른 이야기를 하게 된다.
						     (앱·환자 화면에는 그대로 있다 — 여기서만 뺀 것이다.) --%>
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
  var AI_OK='#2f9e63', AI_BAD='#d9534f', AI_WARN='#e0a800';
  function _n(id){ var el=document.getElementById(id); if(!el) return NaN;
    return parseFloat(String(el.textContent||'').replace(/[^0-9.\-]/g,'')); }
  window.aiRender = function(){
    var tir=_n('tirCard'), tar=_n('tarCard'), tbr=_n('tbrCard'), cv=_n('cv'), gmi=_n('gmi'), avg=_n('avg');
    var rows=[];
    function row(nm, val, unit, ok, txt){
      if(isNaN(val)) return;
      // ok: true=녹색, false=적색, 'warn'=황색(개요 타일의 GMI 7~8% 판정과 동일), null=회색(판정 없음)
      var col = (ok===null) ? '#333' : (ok==='warn' ? AI_WARN : (ok ? AI_OK : AI_BAD));
      rows.push('<div class="ai-row"><span class="ai-nm">'+nm+'</span>'
        +'<span class="ai-val" style="color:'+col+'">'+val+unit+'</span>'
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
    row('GMI (혈당관리지표)', gmi, '%', gmi<7 ? true : (gmi<8 ? 'warn' : false),
        gmi<7 ? '목표(7% 미만) 범위입니다. 평균혈당을 당화혈색소(HbA1c) 형태로 환산한 추정치입니다.'
              : (gmi<8 ? '7~8% 주의 구간입니다. 평균혈당을 당화혈색소(HbA1c) 형태로 환산한 추정치로, 생활습관·약물 조정 검토가 필요할 수 있습니다.'
                       : '8% 이상입니다. 평균혈당을 당화혈색소(HbA1c) 형태로 환산한 추정치로, 적극적인 혈당 관리가 필요합니다.'));
    var w=document.getElementById('aiIdxWrap');
    if(w) w.innerHTML = rows.length ? rows.join('') : '<div class="ai-box">표시할 지표가 없습니다. 개요 탭에서 기간을 조회해 주세요.</div>';

    // 종합 분석 — 환자 앱 AI 챗봇의 인사 분석과 동일한 형식(Blood_Consult.jsp _chatIntroAnalysis)
    function aiLn(s){ return '<span style="display:block; word-break:keep-all;">'+s+'</span>'; }
    var sum='';
    if(!isNaN(tir) || !isNaN(tar) || !isNaN(tbr)){
      var L2=[];
      if(!isNaN(tir)) L2.push(aiLn('• TIR(목표유지) <b>'+tir+'%</b> — 권장 70%↑ '+(tir>=70?'충족&nbsp;👍':'<b style="color:#e67e22">미달</b>')));
      if(!isNaN(tar)) L2.push(aiLn('• TAR(고혈당) <b>'+tar+'%</b> — 권장 25%↓ '+(tar<25?'충족':'<b style="color:#e67e22">초과</b>')));
      if(!isNaN(tbr)) L2.push(aiLn('• TBR(저혈당) <b>'+tbr+'%</b> — 권장 4%↓ '+(tbr<4?'충족':'<b style="color:#e67e22">초과</b>')));
      sum = '최근 일주일 지표 분석입니다.' + L2.join('');
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
    /* ★[2026-08-18 요청] ***하루가 아니라 조회 기간 전체***를 그린다.
       종전에는 종료일 하루만 그려 놓고, 아래 지표 해석·종합 분석·코칭은 기간 값을 쓰고 있었다 —
       ***같은 화면에서 위는 하루, 아래는 일주일***이라 서로 다른 이야기를 했다.
       ⇒ 원천을 「일일 혈당 프로필」과 같은 getBloodChartDataMulti(start~end) 로 바꿨다.
       ★식사·운동 표식은 뺐다 — 조회가 <하루 단위>(eatDate/exerDate)라 기간 그래프에는 못 붙인다.
         하단 식사·운동 박스도 같은 이유로 삭제(2026-08-18 요청). */
    var sKey = ($("#start_date").val() || "").substring(0,10);
    var eKey = ($("#end_date").val()   || "").substring(0,10);
    var _key = sKey + '~' + eKey;
    if(!force && _key && _key === _aiDrawnKey && dom.querySelector('canvas')) return;   // 같은 기간이면 다시 안 그린다
    _aiBusy = true;
    dom.innerHTML = '<div class="ai-box">불러오는 중…</div>';
    var uid = "${sessionScope['t_user_uuid']}";
    /* ★기간 표기는 **조회가 되든 안 되든** 먼저 박는다 — 환자를 안 고른 상태에서
       제목이 빈 채로 남으면 「어느 기간을 보는 화면인지」가 사라진다. */
    var prdTxt = (sKey && eKey) ? (sKey + ' ~ ' + eKey) : '';
    $("#aiDayTitle").text(prdTxt ? (prdTxt + ' 시간대별 혈당 추이') : '시간대별 혈당 추이');
    $(".aiDayTxt").text(prdTxt);          // 지표 해석·종합 분석·코칭 제목의 기간 표기
    if(!sKey || !eKey || !uid){ _aiBusy = false; dom.innerHTML = '<div class="ai-box">조회 기간/환자 정보가 없습니다. (기간 '+(_key||'-')+' / 환자 '+(uid?'있음':'없음')+')</div>'; return; }
    var prev = echarts.getInstanceByDom(dom); if(prev) prev.dispose();

    /* ⚠★폼 형식으로 보내면 **HTTP 415**(Unsupported Media Type)다 —
         이 화면의 조회는 전부 `CommonUtil.callAjax`(= JSON 본문 + contentType application/json)를 쓴다.
         한 번 폼으로 보냈다가 415 를 맞았다. ***같은 통로를 쓴다.***
       ★[2026-08-18 요청] ***일자별이 아니라 시간대별***로 본다 —
         기간을 하루(24시간)에 겹쳐 「몇 시에 오르내리는가」를 본다(AGP 와 같은 읽는 법).
         ⇒ 원천도 AGP 와 같은 `drawActionBloodChart.do`(기간→시간대 요약)를 쓴다. 서버는 손대지 않는다. */
    $.ajax({ url:CommonUtil.getContextPath()+"/drawActionBloodChart.do", type:"post",
             data:JSON.stringify({ start:sKey, end:eKey, userId:uid }),
             contentType:"application/json;charset=UTF-8", dataType:"json" })
    .done(function(res){
      var rows = Array.isArray(res) ? res : (res && res.Data ? res.Data : []);
      /* 라벨은 3시간 간격(오전12·오전3…) — AGP 축과 같은 눈금이라 두 그래프를 나란히 읽을 수 있다.
         ★칸 수(24 또는 25)를 세지 않고 **자리 번호로 만든다** — 자료가 한 칸 더 와도 어긋나지 않는다. */
      var hLbl = function(i){ var ap = (i >= 12 && i < 24) ? '오후' : '오전', h = i % 12; return ap + (h === 0 ? 12 : h); };
      var xs = [], ys = [];
      rows.forEach(function(r, i){
        xs.push((i % 3 === 0) ? hLbl(i) : '');
        var v = parseFloat(r.AVG_VALUE);
        ys.push(isNaN(v) || v <= 0 ? null : v);
      });
      if(!ys.length){
        _aiBusy = false; _aiDrawnKey = '';
        dom.innerHTML = '<div class="ai-box">'+prdTxt+' 데이터 없음</div>';
        return;
      }
      dom.innerHTML = '';
      var chart = echarts.init(dom);
      _aiBusy = false; _aiDrawnKey = _key;
      [0, 120, 350, 800].forEach(function(ms){ setTimeout(function(){ try{ chart.resize(); }catch(e){} }, ms); });
      $(window).off('resize.aiDay').on('resize.aiDay', function(){ try{ chart.resize(); }catch(e){} });
      var greenLabel = { show:true, position:'end', distance:4, color:'#2f9e63', fontSize:11, formatter:'{c}' };
      chart.setOption({
        grid:{ left:48, right:56, top:24, bottom:46 },
        tooltip:{ trigger:'axis', formatter:function(p){
          if(!p || !p.length) return '';
          // 빈 라벨 자리(3시간 간격이 아닌 시각)도 몇 시인지 알려 준다
          var i = p[0].dataIndex, v = p[0].value;
          return hLbl(i) + '시 · ' + (v == null ? '측정 없음' : Math.round(v) + ' mg/dL (평균)');
        } },
        xAxis:{ type:'category', data:xs, boundaryGap:false,
          axisTick:{ show:false }, axisLine:{ lineStyle:{ color:'#cfd8e3' } },
          axisLabel:{ interval:0, color:'#6b7280', fontSize:11 } },
        yAxis:{ type:'value', min:0, max:300, interval:70,
          axisLine:{ show:false }, axisTick:{ show:false },
          splitLine:{ lineStyle:{ color:'#eef1f5' } },
          axisLabel:{ color:'#6b7280', fontSize:11 } },
        series:[{ name:'혈당', type:'line', data:ys, smooth:true, symbol:'none', connectNulls:true,
          lineStyle:{ color:'#2f6fd1', width:2 },
          areaStyle:{ color:'rgba(47,111,209,0.06)' },
          markArea:{ silent:true, data:[
            [{ yAxis:0,   itemStyle:{ color:'rgba(231,76,60,0.08)' } }, { yAxis:70 }],
            [{ yAxis:70,  itemStyle:{ color:'rgba(46,204,113,0.10)' } }, { yAxis:180 }],
            [{ yAxis:180, itemStyle:{ color:'rgba(243,156,18,0.10)' } }, { yAxis:300 }]
          ] },
          markLine:{ symbol:'none', silent:true, data:[
            { yAxis:180, lineStyle:{ color:'#f0a500', type:'dashed' }, label:greenLabel },
            { yAxis:70,  lineStyle:{ color:'#2f9e63', type:'dashed' }, label:greenLabel }
          ] }
        }]
      });
    })
    .fail(function(xhr){
      _aiBusy = false; _aiDrawnKey = '';
      console.error('[AI분석] 기간 조회 실패', xhr && xhr.status, xhr && xhr.responseText);
      dom.innerHTML = '<div class="ai-box" style="color:#d9534f">기간 혈당 조회 실패 (HTTP '+(xhr&&xhr.status)+') — 콘솔 로그를 확인하세요.</div>';
    });
  };
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
