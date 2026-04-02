<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>  
    
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<!-- CSS -->
<link href="/asset/css/comm_blood.css?v=123" rel="stylesheet"> 
<style>
.tab-container, 
.header, 
.navbar {
    background-color: #fff !important;  /* 흰색 또는 원하는 색으로 변경 */
}
.metric-item {
  flex: 1 1 0;                /* shrink 허용 (중요) */
  min-width: 0;               /* flex 박스에서 텍스트 … 처리를 위해 필요 */
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: center;
  gap: 6px;
  flex-wrap: nowrap;          /* 내부도 한 줄 유지 */
  white-space: nowrap;        /* 내부 인라인 줄바꿈 방지 */
}

.metric-label {
  display: inline-block;
  color: #ffffff !important;
  font-weight: 500;
  white-space: nowrap; /* 줄바꿈 방지 */
}

.metric-value {
  white-space: nowrap;        /* 값도 한 줄 고정 */
}
.note-text,
.unit-display {
    color: black;
}
.recommendation-text {
    color: #000 !important;
    font-size: 14px !important;
    display: block !important;
    visibility: visible !important;
    opacity: 1 !important;
}
.main-content {
    background-color: #f8f9fa;  /* 연한 회색 */
    min-height: 100vh;         /* 화면 전체 높이 차지 */
    padding: 20px;             /* 내용과의 여백 */
}

</style>
</head>
<body>

	<!-- 메인 콘텐츠 -->
	<main class="main-content">
	    <!-- 탭 카드 -->
	    <div class="tab-container">
	        <button class="tab-btn active" onclick="showTab(event, 'mealTab')">식사분석</button>
	        <button class="tab-btn" onclick="showTab(event, 'exerciseTab')">운동분석</button>
	    </div>
	
	    <!-- 스크롤 가능한 콘텐츠 영역 -->
	    <div id="mealTab" class="scrollable-content tab-content active">
	        <!-- 혈당 지표 카드 -->
	        <div class="blood-metrics-card">
	            <!-- 단위 표시 -->
	            <div class="unit-display font-small">단위 : mg/dL</div>
	
	            <!-- 혈당 지표 -->
	            <div class="blood-metrics">
	                <div class="metric-row">
	                  <div class="exercise-info">
		                    <div class="metric-item">
		                        <span class="metric-label font-small">평균혈당</span>
		                        <span class="metric-value good font-small" id="avg_blood"
		                            data-db-field="average_blood">-</span>
		                    </div>
		                    <div class="metric-item">
		                        <span class="metric-label font-small">공복평균</span>
		                        <span class="metric-value low font-small" id="avgFastingBlood"
		                            data-db-field="fasting_avg">-</span>
		                    </div>
		                    <div class="metric-item">
		                        <span class="metric-label font-small">식후평균</span>
		                        <span class="metric-value high font-small" id="after2hBlood"
		                            data-db-field="post_meal_avg">-</span>
		                    </div>
	                  </div> 
	                </div>
	                <div class="metric-row">
		                 <div class="exercise-info">
		                    <div class="metric-item">
		                        <span class="metric-label font-small">GMI지수(%)</span>
		                        <span class="metric-value moderate font-small" id="gmi_value" data-db-field="gmi_index">-</span>
		                    </div> 
		                    <div class="metric-item">
		                        <span class="metric-label font-small">저혈당시점</span>
		                        <span class="metric-value normal font-small" id="low_value" data-db-field="hypoglycemia_time">-</span>
		                    </div>
		                 </div>
	                </div>
	            </div>
	        </div>
	
	        <!-- 주간 혈당 증가 식사 TOP3 카드 -->
	        <div class="top3-card increase-card">
	            <div class="card-header">
	                <h3 class="card-title increase font-small">[주간 혈당 증가 식사 TOP3]</h3>
	                <span class="unit-display font-small">단위 : mg/dL</span>
	            </div>
	
	            <div class="ranking-grid">
	                <div class="ranking-item" data-rank="1">
	                    <span class="rank-badge font-large">1위</span>
	                    <div class="exercise-details">
		                    <div class="exercise-info">
		                        <span class="exercise-name  font-samll" id="food_date_1"
		                            data-db-field="meal_name">-</span>
		                        <span class="exercise-name  font-samll" id="food_name_1"
		                            data-db-field="meal_name">-</span>
		                        <span class="value decrease-value  font-samll" id="food_decrease_1"
		                            data-db-field="blood_increase">-</span>
		                    </div>
	                    </div>
	                </div>
	                <div class="ranking-item" data-rank="2">
	                    <span class="rank-badge font-large">2위</span>
	                    <div class="exercise-details">
		                    <div class="exercise-info">
		                        <span class="date  font-samll" id="food_date_2"
		                            data-db-field="meal_name">-</span>
		                        <span class="exercise-name  font-samll" id="food_name_2"
		                            data-db-field="meal_name">-</span>
		                        <span class="value decrease-value  font-samll" id="food_decrease_2"
		                            data-db-field="blood_increase">-</span>
		                    </div>
	                    </div>
	                </div>
	                <div class="ranking-item" data-rank="3">
	                    <span class="rank-badge font-large">3위</span>
	                    <div class="exercise-details">
		                    <div class="exercise-info">
		                        <span class="date  font-samll" id="food_date_3"
		                            data-db-field="meal_name">-</span>
		                        <span class="exercise-name  font-samll" id="food_name_3"
		                            data-db-field="meal_name">-</span>
		                        <span class="value  decrease-value font-samll" id="food_decrease_3"
		                            data-db-field="blood_increase">-</span>
		                    </div>
	                    </div>
	                </div>
	            </div>
	
	            <div class="note-text  font-small">
	                (식전 혈당과 식후 2시간후 혈당을 비교합니다)
	            </div>
	        </div>
	
	        <!-- 주간 혈당 감소 식사 TOP3 카드 -->
	        <div class="top3-card decrease-card">
	            <div class="card-header">
	                <h3 class="card-title decrease font-small">[주간 혈당 감소 식사 TOP3]</h3>
	                <span class="unit-display font-small">단위 : mg/dL</span>
	            </div>
	
	            <div class="ranking-grid">
	                <div class="ranking-item" data-rank="1">
	                    <span class="rank-badge font-large">1위</span>
	                    <div class="exercise-details">
		                    <div class="exercise-info">
		                        <span class="date  font-samll" id="food_datelow_1"
		                            data-db-field="meal_name">-</span>
		                        <span class="exercise-name  font-samll" id="food_namelow_1"
		                            data-db-field="meal_name">-</span>
		                        <span class="value  decrease-value font-samll" id="food_low_1"
		                            data-db-field="blood_decrease">-</span>
		                    </div>
	                    </div>
	                </div>
	                <div class="ranking-item" data-rank="2">
	                    <span class="rank-badge font-large">2위</span>
	                    <div class="exercise-details">
		                    <div class="exercise-info">
		                        <span class="date  font-samll" id="food_datelow_2"
		                            data-db-field="meal_name">-</span>
		                        <span class="exercise-name  font-samll" id="food_namelow_2"
		                            data-db-field="meal_name">-</span>
		                        <span class="value  decrease-value font-samll" id="food_low_2"
		                            data-db-field="blood_decrease">-</span>
		                    </div>
	                    </div>
	                </div>
	                <div class="ranking-item" data-rank="3">
	                    <span class="rank-badge font-large">3위</span>
	                    <div class="exercise-details">
		                    <div class="exercise-info">
		                        <span class="date  font-samll" id="food_datelow_3"
		                            data-db-field="meal_name">-</span>
		                        <span class="exercise-name  font-samll" id="food_namelow_3"
		                            data-db-field="meal_name">-</span>
		                        <span class="value  decrease-value  font-samll" id="food_low_3"
		                            data-db-field="blood_decrease">-</span>
		                    </div>
	                    </div>
	                </div>
	            </div>
	        </div>
	
	        <!-- 개인 맞춤 추천 카드 -->
	        <div class="recommendation-card">
	            <div class="card-header">
	                <h3 class="card-title recommendation font-large">[개인 맞춤 추천]</h3>
	            </div>
	
	            <div class="recommendation-content">
	                <p class="recommendation-text font-large" data-db-field="recommendation_text">
	                    점심식사 후 혈당이 빠르게 올랐습니다. 다음 식사에서는 탄수화물 섭취를 줄이고, 운동은 식후 30분 이내 시작하면 더 효과적입니다
	                </p>
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
	    </div> <!-- mealTab 끝 -->
	
	    <!-- 스크롤 가능한 콘텐츠 영역 (운동 분석) -->
	    <div id="exerciseTab" class="scrollable-content tab-content">
	        <!-- 주간 혈당 감소 운동 TOP3 카드 -->
	        <div class="top3-card decrease-card">
	            <div class="card-header">
	                <h3 class="card-title decrease font-small">[주간 혈당 감소 운동 TOP3]</h3>
	                <span class="unit-display font-small">단위 : mg/dL</span>
	            </div>
	
	            <div class="ranking-grid">
	                <div class="ranking-item" data-rank="1">
	                    <span class="rank-badge font-large">1위</span>
	                    <div class="exercise-details">
	                        <div class="exercise-info">
	                            <span class="date  font-samll" id="exercise_date_1"
	                                data-db-field="exercise_date">-</span>
	                            <span class="exercise-name  font-samll" id="exercise_name_1"
	                                data-db-field="exercise_name">-</span>
	                            <span class="duration  font-samll" id="exercise_duration_1"
	                                data-db-field="exercise_duration">-</span>
	                            <span class="value decrease-value  font-samll" id="blood_decrease_1"
	                                data-db-field="blood_decrease">-</span>
	                        </div>
	                    </div>
	                </div>
	                <div class="ranking-item" data-rank="2">
	                    <span class="rank-badge font-large">2위</span>
	                    <div class="exercise-details">
	                        <div class="exercise-info">
	                            <span class="date  font-samll" id="exercise_date_2"
	                                data-db-field="exercise_date">-</span>
	                            <span class="exercise-name  font-samll" id="exercise_name_2"
	                                data-db-field="exercise_name">-</span>
	                            <span class="duration  font-samll" id="exercise_duration_2"
	                                data-db-field="exercise_duration">-</span>
	                            <span class="value decrease-value  font-samll" id="blood_decrease_2"
	                                data-db-field="blood_decrease">-</span>
	                        </div>
	                    </div>
	                </div>
	                <div class="ranking-item" data-rank="3">
	                    <span class="rank-badge font-large">3위</span>
	                    <div class="exercise-details">
	                        <div class="exercise-info">
	                            <span class="date  font-samll" id="exercise_date_3"
	                                data-db-field="exercise_date">-</span>
	                            <span class="exercise-name  font-samll" id="exercise_name_3"
	                                data-db-field="exercise_name">-</span>
	                            <span class="duration  font-samll" id="exercise_duration_3"
	                                data-db-field="exercise_duration">-</span>
	                            <span class="value decrease-value  font-samll" id="blood_decrease_3"
	                                data-db-field="blood_decrease">-</span>
	                        </div>
	                    </div>
	                </div>
	            </div>
	
	            <div class="note-text  font-small">
	                (운동시작 직전 혈당과 운동종료후 15분 후 혈당을 비교합니다)
	            </div>
	        </div>
	
	        <!-- 개인 맞춤 추천 카드 -->
	        <div class="recommendation-card">
	            <div class="card-header">
	                <h3 class="card-title recommendation font-large">[개인 맞춤 추천]</h3>
	            </div>
	
	            <div class="recommendation-content">
	                <p class="recommendation-text font-large" data-db-field="recommendation_text">
	                    점심식사 후 혈당이 빠르게 올랐습니다. 다음 식사에서는 탄수화물 섭취를 줄이고, 운동은 식후 30분 이내 시작하면 더 효과적입니다
	                </p>
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
	    </div> <!-- exerciseTab 끝 -->
	</main>


  <script>
  var accToken = "";
  var userId = ""; 
  var now = new Date();

  const weekAgo = getPastDate(now, 24*3, 0);  // 7일 전
  const dayAgo  = getPastDate(now, 24, 0);    // 24시간 전
  
  $(document).ready(function() {
	    var userNm = '<%= session.getAttribute("userNm") %>';
	    $("#name").text(userNm.trim()+'님은');
   

	  	userId = '<%= session.getAttribute("userUuid") %>'; 
	    	
	    calcBlood(now, dayAgo);
	    
	});
  
	function calcBlood(now,halfNow) {
		var formData = {
  	  	        start: halfNow,
  	  	        end:    now,
  	  	        userId: userId
  	  	    };
		var exFormData = Object.assign({}, formData, { start: weekAgo }); // start만 7일 전으로(운동/식사이력)
		
		CommonUtil.callSyncAjax(
			  CommonUtil.getContextPath() + "/analysisBlood.do",
			  "POST",
			  formData,
			  function (response) {
				    console.log("GMI, 표준편차, 변동계수 가져옴:", response);

				    const elGmi = document.getElementById("gmi_value");
				    const elAvg = document.getElementById("avg_blood");
				    const elLow = document.getElementById("low_value");

				    // GMI
				    if (elGmi && response.GMI !== undefined) {
				      elGmi.textContent = parseFloat(response.GMI).toFixed(1);
				    }

				    // 평균혈당
				    if (elAvg && response.AvgBlood !== undefined) {
				      elAvg.textContent = Math.round(response.AvgBlood);
				    }

				    // 최저값
				    if (elLow && response.MinHours !== undefined) {
				      elLow.textContent = response.MinHours;
				    }
			  }
		);

		// 공복 혈당
		CommonUtil.callSyncAjax(
			  CommonUtil.getContextPath() + "/analfastingBlood.do",
			  "POST",
			  formData,
			  function (response) {
			    console.log("공복 혈당:", response);
	
			    const elFasting = document.getElementById("avgFastingBlood");
			    if (elFasting && response?.fastingValue !== undefined) {
			      const val = Number(response.fastingValue);
			      elFasting.textContent = Number.isFinite(val) ? Math.round(val) : "-";
			    }
			  }
		);

		// 식후 혈당
		CommonUtil.callSyncAjax(
			  CommonUtil.getContextPath() + "/analpostBlood.do",
			  "POST",
			  formData,
			  function (response) {
			    console.log("식후 혈당:", response);
	
			    const elAfter2h = document.getElementById("after2hBlood");
			    if (elAfter2h && response?.after2hBlood !== undefined) {
			      const val = Number(response.after2hBlood);
			      elAfter2h.textContent = Number.isFinite(val) ? Math.round(val) : "-";
			    }
			  }
		);

  		//운동전후혈당 
  		CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/analexerBlood.do","POST",exFormData,
  			   function(responseList){
  			       // 배열이 아니거나 null이면 그냥 초기화 후 종료
  			       if (!Array.isArray(responseList) || responseList.length === 0) {
  			           for (let i = 1; i <= 3; i++) {
  			               document.getElementById('exercise_date_' + i).textContent = '-';
  			               document.getElementById('exercise_name_' + i).textContent = '-';
  			               document.getElementById('exercise_duration_' + i).textContent = '-';
  			               document.getElementById('blood_decrease_' + i).textContent = '-';
  			           }
  			           return;
  			       }

  			       // 먼저 3개 모두 기본값 세팅
  			       for (let i = 1; i <= 3; i++) {
  			           document.getElementById('exercise_date_' + i).textContent = '-';
  			           document.getElementById('exercise_name_' + i).textContent = '-';
  			           document.getElementById('exercise_duration_' + i).textContent = '-';
  			           document.getElementById('blood_decrease_' + i).textContent = '-';
  			       }

  			       // 응답값이 있는 만큼만 덮어쓰기
  			       responseList.slice(0, 3).forEach((response, idx) => {
  			           document.getElementById('exercise_date_' + (idx+1)).textContent =
  			               response?.exerciseDate ?? '-';

  			           const name = response?.exerciseName 
  			               ? (response.exerciseName.length > 4 
  			                   ? response.exerciseName.substring(0, 4) + "..." 
  			                   : response.exerciseName) 
  			               : '-';
  			           document.getElementById('exercise_name_' + (idx+1)).textContent = name;
  			           
  			           document.getElementById('exercise_duration_' + (idx+1)).textContent =
  			               response?.durationMin+ "분" ?? '-';
  			           document.getElementById('blood_decrease_' + (idx+1)).textContent =
  			               response?.deltaValue ?? '-';
  			       });
  			   }
  		 );
  		//식사전후혈당 큰값으로 
      	CommonUtil.callSyncAjax(
      		  CommonUtil.getContextPath() + "/analfoodBlood.do",
      		  "POST",Object.assign({}, exFormData, { onlyRise: '1' }),
      		  function(responseList) {
      		    // 배열이 아니거나 null이면 초기화 후 종료
      		    if (!Array.isArray(responseList) || responseList.length === 0) {
      		      for (let k = 1; k <= 3; k++) {
      		        document.getElementById('food_date_' + k).textContent = '-';
      		        document.getElementById('food_name_' + k).textContent = '-';
      		        document.getElementById('food_decrease_' + k).textContent = '-';
      		      }
      		      return;
      		    }

      		    // 먼저 3개 모두 기본값 세팅
      		    for (let k = 1; k <= 3; k++) {
      		      document.getElementById('food_date_' + k).textContent = '-';
      		      document.getElementById('food_name_' + k).textContent = '-';
      		      document.getElementById('food_decrease_' + k).textContent = '-';
      		    }

      		    // 응답값이 있는 만큼만 덮어쓰기
      		  responseList.slice(0, 3).forEach((response, idx) => {
      			  document.getElementById('food_date_' + (idx + 1)).textContent =
      			    response?.foodDate ?? '-';

      			  let foodName = response?.foods_in_day ?? '-';
      			  if (foodName.length > 4) {
      			      foodName = foodName.substring(0, 4) + '..'; // 5자 이후는 ... 처리
      			  }
      			  document.getElementById('food_name_' + (idx + 1)).textContent = foodName;

      			  document.getElementById('food_decrease_' + (idx + 1)).textContent =
      			    response?.avg_increase ?? '-';
      			});
      		  }
      	);
  		//작은값으로 
      	CommonUtil.callSyncAjax(
        		  CommonUtil.getContextPath() + "/analfoodBlood.do",
        		  "POST",Object.assign({}, exFormData, { onlyRise: '2' }),      
        		  function(responseList) {
        		    // 배열이 아니거나 null이면 초기화 후 종료
        		    if (!Array.isArray(responseList) || responseList.length === 0) {
        		      for (let k = 1; k <= 3; k++) {
        		        document.getElementById('food_datelow_' + k).textContent = '-';
        		        document.getElementById('food_namelow_' + k).textContent = '-';
        		        document.getElementById('food_low_' + k).textContent = '-';
        		      }
        		      return;
        		    }

        		    // 먼저 3개 모두 기본값 세팅
        		    for (let k = 1; k <= 3; k++) {
        		      document.getElementById('food_datelow_' + k).textContent = '-';
        		      document.getElementById('food_namelow_' + k).textContent = '-';
        		      document.getElementById('food_low_' + k).textContent = '-';
        		    }

        		    // 응답값이 있는 만큼만 덮어쓰기
        		    responseList.slice(0, 3).forEach((response, idx) => {
        		      document.getElementById('food_datelow_' + (idx+1)).textContent =
        		        response?.foodDate ?? '-';
        		      
        		      let foodName = response?.foods_in_day ?? '-';
        		      if (foodName.length > 4) {
        		        foodName = foodName.substring(0, 4) + '..'; // 5자 이후는 ... 처리
        		      }
        		      document.getElementById('food_namelow_' + (idx + 1)).textContent = foodName;
        		      
        		      document.getElementById('food_low_' + (idx+1)).textContent =
        		        response?.avg_increase ?? '-';
        		    });
        		  }
        	);
	};
  	//이전시간 함수처리 
  	function getPastDate(baseDate, hours = 0, minutes = 0) {
  	    return new Date(baseDate.getTime() - (hours * 60 + minutes) * 60 * 1000);
  	}
  	
  	function showTab(event, tabId) {
  	  // 모든 탭 내용 숨기기
  	  const tabContents = document.querySelectorAll('.tab-content');
  	  tabContents.forEach(tab => tab.classList.remove('active'));

  	  // 모든 버튼에서 active 제거
  	  const tabButtons = document.querySelectorAll('.tab-btn');
  	  tabButtons.forEach(btn => btn.classList.remove('active'));

  	  // 클릭된 탭과 버튼 활성화
  	  document.getElementById(tabId).classList.add('active');
  	  event.currentTarget.classList.add('active');
  	} 	

  </script>
</body>
</html>
