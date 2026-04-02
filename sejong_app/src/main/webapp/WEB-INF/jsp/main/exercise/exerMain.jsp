<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Date nowTime = new Date();
    SimpleDateFormat sfDate = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat sfTime = new SimpleDateFormat("HH:mm");
    String todayDate  = sfDate.format(nowTime);
 // 1시간 전 시간 계산
    Calendar cal = Calendar.getInstance();
    cal.setTime(nowTime);
    cal.add(Calendar.HOUR_OF_DAY, -1);
    Date preTime = cal.getTime();

    // 1시간 전 시간 문자열
    String preTimeStr = sfTime.format(nowTime);

    String nowTimeStr = sfTime.format(nowTime);
    String endDate    = sfDate.format(nowTime);

    cal.setTime(nowTime);
    cal.add(Calendar.DATE, -6); // 오늘 포함해서 7일 범위로 하고 싶으면 -6

    String startDate = sfDate.format(cal.getTime());

%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>운동 기록</title>
  <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.7/main.min.css" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
  <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.7/main.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
  <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
  <!-- CSS -->
  <link href="/asset/css/comm_style.css?v=123" rel="stylesheet"> <!-- exercise 스타일   -->
<style>
/* 입력 폼 전체 간격 줄이기 */
#exerciseForm .input-group { margin: 6px 0; }

/* 라벨 크기 축소 */
#exerciseForm label {
  font-size: 13px;
  line-height: 1.2;
}

/* 인풋(날짜/시간/텍스트) 크기 축소 */
#exerciseForm input[type="date"],
#exerciseForm input[type="time"],
#exerciseForm input[type="text"] {
  width: 100%;
  height: 36px;          /* 기본 40~44px → 36px */
  padding: 6px 10px;     /* 패딩 축소 */
  font-size: 14px;       /* 폰트 축소 */
  border-radius: 8px;
}

/* 커스텀 셀렉트 드롭다운 글씨/간격 축소 */
.custom-select .custom-select-options > div {
  padding: 6px 10px;
  font-size: 14px;
}

/* 버튼 축소 */
#exerciseForm button[type="button"] {
  height: 36px;          /* 높이 축소 */
  padding: 0 12px;       /* 좌우 패딩 축소 */
  font-size: 14px;       /* 폰트 축소 */
  border-radius: 8px;
}

/* 테이블도 조금 컴팩트하게(선택) */
.exercise-table th, .exercise-table td {
  padding: 6px;
  font-size: 14px;
}

.date-input {
    font-size: 12px !important;   /* 글자 크기 강제 적용 */
    padding: 1px 3px;
    width: 118px;
}
#historyTab {
  margin-left: -11px; /* 원하는 만큼 조정 (-값은 왼쪽으로 당김) */
}
.custom-select-options {
  max-height: 800px;     /* 5개 정도 보이도록 적절히 조정 */
  overflow-y: auto;      /* 세로 스크롤 가능 */
  -webkit-overflow-scrolling: touch; /* iOS에서 부드러운 스크롤 */
  border: 1px solid #ccc;
  border-radius: 6px;
  background: #fff;
  z-index: 1000;
}
/* 모바일에서만 세로 스크롤 */
@media (max-width: 768px) {
  .exer-table-wrap {
    max-height: 400px;   /* 원하는 높이 */
    overflow-y: auto;    /* 세로 스크롤 활성화 */
    border: 1px solid #ccc;
  }
}

</style>
</head>
<body>
<div class="contents">
  <div class="lyInner">
    <!-- 탭 메뉴 -->
    <div class="tab-menu">
      <button class="tab-btn active" onclick="showTab(event, 'historyTab')">운동 이력</button>
      <button class="tab-btn" onclick="showTab(event, 'inputTab')">운동 등록</button>
    </div>
    <!-- 운동 이력 보기 -->
	<section id="historyTab" class="tab-content  active">
	   <div class="date-range">
			<input type="date" id="startDt" class="date-input" value="<%= startDate %>" />
			<span>-</span>
			<input type="date" id="endDt" class="date-input" value="<%= endDate %>" />
			<button type="button" onclick="getExerciseList(1)" style="
			  width: 30px;  height: 30px; padding: 0;  border: 1px solid #ccc;  background-color: white;
			  cursor: pointer;  display: flex;  align-items: center; justify-content: center; ">
			  <i class="fas fa-search" style="font-size: 12px;"></i>
			</button>
	   </div>
 	 <div class="exer-table-wrap">
		  <table class="exercise-table">
		    <thead>
		      <tr>
		        <th>운동일자</th>
		        <th>시간</th>
		        <th>종류</th>
		        <th>분단위</th>
		        <th></th>
		      </tr>
		    </thead>
		    <tbody id="exerciseList">
		      <!-- JS로 동적 삽입 -->
		    </tbody>
		  </table>
	  </div>
	</section>
	
    <!-- 운동 입력 폼 -->
    <section id="inputTab" class="tab-content">
      <form id="exerciseForm">
            <input type="hidden" id="userUuid" value="${sessionScope.userUuid}">  
            <input type="hidden" id="exerInt" value="">  
			<div class="input-group">
			  <label for="exerciseDate">운동일자</label>
			  <input type="date" id="exerDate" name="exerDate" value="<%= todayDate %>" required>
			</div>
			
			<div class="input-group">
			  <label for="exerStime">시작시간</label>
			  <input type="time" id="exerStime" name="exerStime" value="<%= preTimeStr %>" required>
			</div>
			
			<div class="input-group">
			  <label for="exerEtime">종료시간</label>
			  <input type="time" id="exerEtime" name="exerEtime" value="<%= nowTimeStr %>" required>
			</div>
			
			<div class="input-group">
			  <label for="exerName">운동종류</label>
			
			  <div class="custom-select dropup">
			    <input type="text" id="exerName" name="exerName" placeholder="운동을 선택하거나 입력" required autocomplete="off">
			    <div class="custom-select-options" role="listbox" style="display:none;">
			      <div role="option">직접입력</div>
			      <div role="option">걷기</div>
			      <div role="option">경보</div>
			      <div role="option">축구</div>
			      <div role="option">농구</div>
			      <div role="option">줄넘기</div>
			      <div role="option">달리기</div>
			      <div role="option">틱구</div>
			      <div role="option">댄스</div>
			      <div role="option">등산</div>
			      <div role="option">배구</div>
			      <div role="option">배드민턴</div>
			      <div role="option">자전거</div>
			      <div role="option">에어로빅</div>
			      <div role="option">수영</div>
			      <div role="option">헬스</div>
			    </div>
			  </div>
			</div>
			<button type="button" onclick="saveExercise()">입력</button>
      </form>
	<div class="table-wrapper">
	  <table class="exercise-table">
	    <thead>
	      <tr>
	        <th>운동일자</th>
	        <th>시간</th>
	        <th>종류</th>
	        <th>분단위</th>
	        <th></th>
	      </tr>
	    </thead>
	    <tbody id="todayexerciseList">
	      <!-- JS로 동적 삽입 -->
	    </tbody>
	  </table>
	</div>
    </section>
  </div>
</div>

<script>
let exerciseData = [];
function saveExercise() {
	  const data = {
	    userUuid :  document.getElementById("userUuid").value,
	    exerDate :  document.getElementById("exerDate").value,
	    exerStime:  document.getElementById("exerStime").value.substring(0, 5).replace(":", "") + "00",
	    exerEtime:  document.getElementById("exerEtime").value.substring(0, 5).replace(":", "") + "00",
	    exerName :  document.getElementById("exerName").value,
	    exerInt  :  document.getElementById("exerInt").value
	  };
	  if (!data.exerDate) {
	     alert("운동일자를 입력하세요.");
	     return;
	  }
	  if (data.exerStime > data.exerEtime ) {
		  alert("종료시간이 시작시간보다 커야 합니다.");
		  document.getElementById("exerEtime").focus();
		  return;
	  }
	  if (!data.exerName) {
		  alert("운동종류를 입력하세요.");
		  return;
	  }
	  
	  if (confirm("입력하시겠습니까?")) {
	    $.ajax({
	      url: "/updateHealth.do",
	      type: "POST",
	      contentType: "application/json",
	      data: JSON.stringify([data]), // 배열로 전송
	      success: function(response) {
            alert("운동기록이 저장되었습니다.");
            document.getElementById("exerName").value = "";
            document.getElementById("exerInt").value = "";
            getExerciseList("2")
            
	      },
	      error: function(xhr, status, error) {
	    	  alert("시스템오류입니다 다시 입력하세요!");
	      }
	    });
	  }
	}
//해당 운동기록삭제 
function delExercise(exerSeq ,  rowElement) {
	  const data = {
	    userUuid :  document.getElementById("userUuid").value,
	    exerSeq  :  exerSeq
	  };
      $.ajax({
	      url: "/deleteHealth.do",
	      type: "POST",
	      contentType: "application/json",
	      data: JSON.stringify([data]), // 배열로 전송
	      success: function(response) {
	         alert("운동기록이 삭제되었습니다.");
	         // 해당 tr 삭제
	         if (rowElement) {
	            rowElement.remove();
	            getExerciseList("1")
	            getExerciseList("2")	            
	         }
	      },
	      error: function(xhr, status, error) {
	    	  alert("시스템오류입니다 다시 입력하세요!");
	      }
	  });
	}

function filterByDate() {
  const filter = document.getElementById("filterDate").value;
  if (!filter) return renderExerciseList();
  const filtered = exerciseData.filter(item => item.date === filter);
  renderExerciseList(filtered);
}

function showTab(event, tabId) {
  document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
  document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
  document.getElementById(tabId).classList.add('active');
  event.target.classList.add('active');
  if (tabId ==  "inputTab") {
	  getExerciseList("2");
	  renderExerciseList([] , "2"); 
  }else {
	  getExerciseList("1");
	  renderExerciseList([] , "1"); 
  } 
}

window.onload = function() {
  try {
    const stored = JSON.parse(localStorage.getItem("exerciseRecords"));
    if (Array.isArray(stored)) {
      exerciseData = stored;
    }
  } catch (e) {
    console.warn("로컬 기록 초기화됨:", e.message);
    exerciseData = [];
    localStorage.removeItem("exerciseRecords");
  }
  renderExerciseList([] , "1");
  getExerciseList("1");  
};
function getExerciseList(gubun) {
	  let param;
	  if (gubun == "1") {
	       param = {
		    userUuid :  document.getElementById("userUuid").value ,
		    startDt  :  document.getElementById("startDt").value, 
		    endDt    :  document.getElementById("endDt").value 
           };
	  } else if (gubun == "2"){
	       param = {
	   		    userUuid :  document.getElementById("userUuid").value ,
	   		    startDt  :  document.getElementById("exerDate").value, 
	   		    endDt    :  document.getElementById("exerDate").value 		 
	       }; 
	  }
	  if ((param.startDt > param.endDt) && (gubun == "1"))
	   {
	      alert("종료일자가 시작일자보다 커야 합니다.");
	      document.getElementById("endDt").focus();
	      return;
	   }


	  fetch('/getExercise.do', {
	    method: 'POST',
	    headers: {
	      'Content-Type': 'application/json'
	    },
	    body: JSON.stringify(param)
	  })
	  .then(response => response.json())
	  .then(result => {
	    if (result.IsSucceed) {
	      renderExerciseList(result.Data , gubun);
	    } else {
	      alert('운동 기록을 불러오는 데 실패했습니다.');
	    }
	  })
	  .catch(error => {
	    console.error('Error:', error);
	  });
	}
	function renderExerciseList(data, gubun) {
	  let lastDate = '' ;
	  let list ;
	  if (gubun == "1") {
	     list = document.getElementById("exerciseList");
	  } else if (gubun == "2"){
		 list = document.getElementById("todayexerciseList");  
	  }
	  list.innerHTML = '';

	  data.forEach(item => {
	    const tr = document.createElement('tr');
	    
	    tr.setAttribute('data-exer-seq', item.exerSeq); // tr에 key 저장
	    
	    const tdDate = document.createElement('td');
	    if (item.exerDate !== lastDate) {
	        tdDate.textContent = item.exerDate || '';
	        lastDate = item.exerDate;
	      } else {
	        tdDate.textContent = '\u00A0';  // 공백 문자로 칸 유지
	      }	    
	    // 시간 칸 (항상 출력)
	    const tdTime = document.createElement('td');
	    tdTime.textContent =
	      (item.exerStime ? item.exerStime.substring(0, 2) + ':' + item.exerStime.substring(2, 4) : '') +
	      ' ~ ' +
	      (item.exerEtime ? item.exerEtime.substring(0, 2) + ':' + item.exerEtime.substring(2, 4) : '');

	    const tdType = document.createElement('td');
	    const name = item.exerName || '';  // ✅ 먼저 name 변수 선언

	    if (name.length > 4) {
	      tdType.textContent = name.substring(0, 4) + '…';
		  tdType.setAttribute("data-tooltip", name);
		  tdType.classList.add("has-tooltip");
	    } else {
	      tdType.textContent = name;
	    }
    
	    const tdDuration = document.createElement('td');
	    tdDuration.textContent = item.exerMinutes + '분';

	    const tdDelete = document.createElement('td');
	    tdDelete.textContent = '🗑️';
	    tdDelete.style.cursor = 'pointer';
	    tdDelete.title = '삭제';
	    tdDelete.onclick = function () {

	   	if (confirm(`${item.exerName} 운동기록을 삭제하시겠습니까?`)) {
	    	const currentRow = this.closest('tr');
    	    // 삭제 함수 호출, 삭제 완료 후 해당 행 제거
    	    delExercise(item.exerSeq, currentRow);
	       }
	    };

	    tr.appendChild(tdDate);
	    tr.appendChild(tdTime);
	    tr.appendChild(tdType);
	    tr.appendChild(tdDuration);
	    tr.appendChild(tdDelete);

	    list.appendChild(tr);
	  });
	}
	// 페이지 진입 시 input을 기본적으로 readonly 처리
	document.querySelectorAll('.custom-select input').forEach(input => {
	  input.setAttribute('readonly', true);
	  
	  input.addEventListener('click', function (e) {
	    const options   = this.nextElementSibling;
	    const isVisible = options && options.style.display === 'block';
	    e.stopPropagation();

	    // 1) 옵션 패널이 닫혀 있고, 이전에 일반 옵션을 선택했다면 = "수정 모드"로 전환
	    //    -> readonly 해제 + 포커스(커서를 맨 뒤로)
	    if (!isVisible && this.dataset.editReady === '1') {
	      this.removeAttribute('readonly');
	      // editReady 플래그는 한번 쓰면 제거(원하면 유지해도 OK)
	      delete this.dataset.editReady;

	      // 포커스 & 커서 끝으로 이동 (모바일 키보드 확실히 띄움)
	      setTimeout(() => {
	        this.focus({ preventScroll: true });
	        const len = this.value.length;
	        try { this.setSelectionRange(len, len); } catch (err) {}
	      }, 0);
	      return;
	    }

	    // 2) 기본 동작: 모든 옵션 닫고, 현재 것만 열기 (첫 탭은 메뉴 열기)
	    document.querySelectorAll('.custom-select-options').forEach(opt => opt.style.display = 'none');
	    if (options) options.style.display = 'block';
	  });

	  // 수정 종료 시 다시 readonly로 돌려서 다음 진입에 키보드가 자동으로 안 뜨게 함
	  input.addEventListener('blur', function () {
	    // 직접입력 모드에서 완전히 막고 싶지 않다면 조건을 조절하세요.
	    this.setAttribute('readonly', true);
	  });
	});

	// 옵션 클릭 시
	document.querySelectorAll('.custom-select-options div').forEach(option => {
	  option.addEventListener('click', function () {
	    const select = this.closest('.custom-select');
	    const input  = select.querySelector('input');
	    const value  = this.textContent.trim();

	    if (value === '직접입력') {
	      // 드롭다운 닫고 인풋에 입력 가능하게
	      this.parentElement.style.display = 'none';
	      input.value = '';
	      input.removeAttribute('readonly');   // 즉시 입력 가능
	      // 직입 모드에선 editReady 굳이 안 씀
	      delete input.dataset.editReady;

	      setTimeout(() => {
	        input.focus({ preventScroll: true });
	        try { input.select(); } catch (err) {}
	      }, 0);
	    } else {
	      // 일반 옵션 선택: 값만 넣고, 다음에 인풋을 탭하면 "수정 모드"로 진입하도록 플래그만 설정
	      input.value = value;
	      input.setAttribute('readonly', true);   // 선택 직후엔 그대로 잠가둠
	      input.dataset.editReady = '1';          // 다음 탭에서 키보드 뜨게 하는 신호
	      this.parentElement.style.display = 'none';
	    }
	  });
	});

	// 외부 클릭 시 옵션 닫기
	document.addEventListener("click", function (e) {
	  document.querySelectorAll('.custom-select').forEach(select => {
	    if (!select.contains(e.target)) {
	      const options = select.querySelector('.custom-select-options');
	      if (options) options.style.display = "none";
	    }
	  });
	});


</script>
</body>
</html>

