<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>  
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>  
<%@ page import = "java.util.*" %>
<%@ page import="java.lang.*" %>
  
<html>
<head>  
 <title>회원 관리</title>
<!-- 달력(일자, 월별) 사용시 추가 필요함 -->  
<script src="/js/main.js"></script>
<style>
	.search-times {
	    display: flex;
	    align-items: center;
	    gap: 20px; /* 간격 조정 */
	    font-size: 14px; /* 글자 크기 */
	}
	
	.search-times .time {
	    color: blue; /* 시간을 파란색으로 설정 */
	    font-weight: bold; /* 강조 */
	}
	
	.search-times .divider {
	    margin: 0 10px; /* 구분자(|) 양쪽 간격 */
	    color: gray; /* 구분자 색상 */
	}
  .table-responsive {
    max-height: 600px; /* 적당한 높이 설정 (10개 행 기준으로 조정) */
    overflow-y: auto; /* 수직 스크롤 활성화 */
    border: 1px solid #ccc; /* 테두리 추가 */
  }

  #infoTable thead th {
    position: sticky;
    top: 0; /* 헤더 고정 */
    background-color: #d9edf7 !important; /* 헤더 배경색 — 연한 하늘색 */
    color: #000000 !important;
    z-index: 2; /* 헤더가 데이터보다 위에 위치하도록 설정 */
  }

  table tbody tr:nth-child(even) {
    background-color: #f2f2f2; /* 짝수행 배경색 설정 (가독성 개선) */
  }
  .total-count {
    margin-right: 1rem; /* 오른쪽 여백 (옵션) */
  }
  /* 페이징 영역 */
  .grid-pager {
    display: flex; align-items: center; justify-content: center;
    gap: 4px; padding: 10px 0; flex-wrap: wrap;
    font-size: 13px;
  }
  .grid-pager .pg-btn {
    border: 1px solid #ccc; background:#fff; color:#333;
    padding: 4px 10px; min-width: 32px; cursor:pointer; border-radius:3px;
  }
  .grid-pager .pg-btn:hover:not(:disabled) { background:#eef5ff; border-color:#1976d2; }
  .grid-pager .pg-btn:disabled { color:#aaa; cursor:not-allowed; background:#f7f7f7; }
  .grid-pager .pg-btn.active { background:#1976d2; color:#fff; border-color:#1976d2; font-weight:600; }
  .grid-pager .pg-sep { margin: 0 6px; color:#888; }
  .grid-pager select { padding: 3px 6px; border:1px solid #ccc; border-radius:3px; }
</style>
<script>
var user_gubun = "" ;
$(document).ready(function () {
	$("#user_gb").prop("checked",false);
	fnSearch() ;
})
</script>
<script type="text/javaScript">
// ─────────────────────────────────────────────────────────────────────
// 페이징 상태 (클라이언트 사이드)
//   _gridRows     : 서버에서 받은 전체 리스트 (resultLst)
//   _gridPage     : 현재 페이지 (1-base)
//   _gridPageSize : 페이지당 행 수
// ─────────────────────────────────────────────────────────────────────
var _gridRows = [];
var _gridPage = 1;
var _gridPageSize = 20;

//조회시작
function fnSearch() {

	 document.getElementById("regForm").reset();

	 $("#dataArea").empty();
	 _gridRows = []; _gridPage = 1;
	 _renderPager();   // 검색 직전 페이저 초기화
//	 	if($('#searchText').val() == "") {
//		alert("검색어를 입력하세요.");
//		$('#searchText').focus();
//		return; 
//	 }
 
    user_gubun = $("#user_gb").is(':checked') ? "1" : "" ;   // 체크: 실증환자(1)만 / 해제: 전체
    
    var startTime = new Date(); //조회시작시간  
    
    let millisecondsStart = startTime.getMilliseconds().toString().padStart(4, '0'); // 밀리초
    let formatted01Hour = startTime.toLocaleTimeString('en-US', { 
      hour12: false, 
      hour: '2-digit', 
      minute: '2-digit', 
      second: '2-digit'
    }) + '.' + millisecondsStart;
    
    var sendTime;
    
    $.ajax({
   	url : CommonUtil.getContextPath() + '/doctor/selectPatientList.do',
    type : 'post',
    data : {userNm : $("#searchText").val(),
	        userGb : user_gubun,
    	    },
    	    beforeSend: function() {
                // 송신 시간 기록
    	    	sendTime = new Date();
            },
   	dataType : "json",
   	success : function(data) {
   		if(data.error_code != "0") return;
   		if(data.resultCnt > 0 ){
   			let endTime = new Date(); //조회종료시간 
   			let millisecondsEnd = endTime.getMilliseconds().toString().padStart(4, '0');
   			let formatted12Hour = endTime.toLocaleTimeString('en-US', { 
   			  hour12: false, 
   			  hour: '2-digit', 
   			  minute: '2-digit', 
   			  second: '2-digit'
   			}) + '.' + millisecondsEnd; 
   			formatted01Hour = formatted01Hour.substring(3,13);
   			formatted12Hour = formatted12Hour.substring(3,13);
            document.getElementById('formatted01Hour').innerText = formatted01Hour;
            document.getElementById('formatted12Hour').innerText = formatted12Hour;   			
            // 시간 계산
            let queryTime = ((sendTime.getTime() - startTime.getTime()) / 1000).toFixed(2); // 조회 시간 (초)
            let sendDuration = ((endTime.getTime() - sendTime.getTime()) / 1000).toFixed(2); // 송신 시간 (초)
            let totalResponseTime = ((endTime.getTime() - startTime.getTime()) / 1000).toFixed(2); // 총 응답 시간 (초)
            
            document.getElementById('totalResponseTime').innerText = totalResponseTime;
            
            // 시분초로 포맷팅
            let formatTime = (date) => date.toLocaleTimeString();
            
    		var totalCount = data.resultCnt ;
    		document.getElementById("totalCount").textContent = totalCount; // 건수 업데이트
    		// 전체 리스트 캐시 후 1페이지 렌더 (페이지 단위로 잘라 렌더)
    		_gridRows = data.resultLst || [];
    		_gridPage = 1;
    		_renderGridPage();
	 	  }else{
	 			 _gridRows = []; _gridPage = 1;
	 			 document.getElementById("totalCount").textContent = 0;
				 $("#dataArea").append("<tr><td colspan='12'>검색된 정보가 없습니다.</td></tr>");
				 _renderPager();
		  }
      }
   });
}
// ─────────────────────────────────────────────────────────────────────
// 현재 페이지 행만 렌더
// ─────────────────────────────────────────────────────────────────────
function _renderGridPage(){
	$("#dataArea").empty();
	var total = _gridRows.length;
	if (total === 0) {
		$("#dataArea").append("<tr><td colspan='12'>검색된 정보가 없습니다.</td></tr>");
		_renderPager();
		return;
	}
	var totalPages = Math.max(1, Math.ceil(total / _gridPageSize));
	if (_gridPage > totalPages) _gridPage = totalPages;
	if (_gridPage < 1) _gridPage = 1;

	var startIdx = (_gridPage - 1) * _gridPageSize;
	var endIdx   = Math.min(startIdx + _gridPageSize, total);

	var html = "";
	for (var i = startIdx; i < endIdx; i++) {
		var row = _gridRows[i];
		// 성별
		var genderText = (row.gender == "F") ? "여성" : (row.gender == "M") ? "남성" : "";
		// 만나이
		var birthYear  = row.birth.substring(0,4);
		var birthMonth = parseInt(row.birth.substring(4,6),10);
		var birthDay   = parseInt(row.birth.substring(6,8),10);
		var cd = new Date();
		var age = cd.getFullYear() - parseInt(birthYear,10);
		if ((cd.getMonth()+1) < birthMonth) age--;
		else if ((cd.getMonth()+1) === birthMonth && cd.getDate() < birthDay) age--;
		// 환자 구분
		var userText = (row.userGb == "1") ? "실증환자" : (row.userGb == "2") ? "테스트" : "";

		html += '<tr ondblclick="javascript:fnDtlSearch(\''+row.userUuid+'\');" id="row_'+row.userUuid+'">';
		html +=   "<td>" + (i+1) + "</td>";   // 전체 기준 일련번호 (페이지 넘겨도 연속)
		html +=   "<td>" + row.userNm.substring(0,1) + "*" + row.userNm.substring(2,3) + "</td>";
		html +=   "<td>" + row.phone.substring(0,3) + "-****-" + row.phone.substring(7,11) + "</td>";
		html +=   "<td>" + genderText + "</td>";
		html +=   "<td>" + row.birth.substring(0,4) + "년&nbsp;" + row.birth.substring(4,6) + "월&nbsp;" + row.birth.substring(6,8) + "일</td>";
		html +=   "<td>" + age + "</td>";
		html +=   "<td>" + row.dtlCodeNm + "</td>";
		html +=   "<td>" + row.height + "</td>";
		html +=   "<td>" + row.weight + "</td>";
		html +=   "<td>" + row.joinYmd.substring(0,4) + "년&nbsp;" + row.joinYmd.substring(4,6) + "월&nbsp;" + row.joinYmd.substring(6,8) + "일</td>";
		html +=   "<td>" + row.regDtm + "</td>";
		html +=   "<td>" + userText + "</td>";
		html += "</tr>";
	}
	$("#dataArea").html(html);
	_renderPager();
}

// ─────────────────────────────────────────────────────────────────────
// 페이저 UI 렌더 (1 2 3 … N 형태, 좌/우 화살표 포함)
// ─────────────────────────────────────────────────────────────────────
function _renderPager(){
	var total = _gridRows.length;
	var totalPages = Math.max(1, Math.ceil(total / _gridPageSize));
	var p = _gridPage;
	// 화면에 표시할 페이지 번호 범위 (현재 페이지 기준 앞뒤 2개)
	var WIN = 2;
	var fromP = Math.max(1, p - WIN);
	var toP   = Math.min(totalPages, p + WIN);

	var html = '';
	// 페이지 크기 선택
	html += '<span>페이지당 </span>';
	html += '<select onchange="_changePageSize(this.value)">';
	[10,20,50,100].forEach(function(n){
		html += '<option value="'+n+'" '+(n===_gridPageSize?'selected':'')+'>'+n+'</option>';
	});
	html += '</select>';
	html += '<span class="pg-sep">|</span>';
	// 처음/이전
	html += '<button class="pg-btn" '+(p<=1?'disabled':'')+' onclick="_gotoPage(1)">«</button>';
	html += '<button class="pg-btn" '+(p<=1?'disabled':'')+' onclick="_gotoPage('+(p-1)+')">‹</button>';
	// 번호
	if (fromP > 1) {
		html += '<button class="pg-btn" onclick="_gotoPage(1)">1</button>';
		if (fromP > 2) html += '<span class="pg-sep">…</span>';
	}
	for (var i = fromP; i <= toP; i++) {
		html += '<button class="pg-btn '+(i===p?'active':'')+'" onclick="_gotoPage('+i+')">'+i+'</button>';
	}
	if (toP < totalPages) {
		if (toP < totalPages-1) html += '<span class="pg-sep">…</span>';
		html += '<button class="pg-btn" onclick="_gotoPage('+totalPages+')">'+totalPages+'</button>';
	}
	// 다음/끝
	html += '<button class="pg-btn" '+(p>=totalPages?'disabled':'')+' onclick="_gotoPage('+(p+1)+')">›</button>';
	html += '<button class="pg-btn" '+(p>=totalPages?'disabled':'')+' onclick="_gotoPage('+totalPages+')">»</button>';
	// 위치 표시
	html += '<span class="pg-sep">|</span>';
	html += '<span>'+p+' / '+totalPages+' (총 '+total+'건)</span>';

	$("#gridPager").html(html);
}
function _gotoPage(n){ _gridPage = n; _renderGridPage(); }
function _changePageSize(n){ _gridPageSize = parseInt(n,10); _gridPage = 1; _renderGridPage(); }

function formatTimeWithMilliseconds(date) { const hours = String(date.getHours()).padStart(2, '0');
         const minutes = String(date.getMinutes()).padStart(2, '0'); 
         const seconds = String(date.getSeconds()).padStart(2, '0'); 
         const milliseconds = String(date.getMilliseconds()).padStart(3, '0'); 
         return `${hours}:${minutes}:${seconds}.${milliseconds}`;
}
	function fnDtlSearch(data){ 
		if(data == '' || data == null) return;
		
		 document.regForm.userUuid.value = data ;
		//row 클릭시 바탕색 변경 처리 Start 
		$("#infoTable tr").attr("class", ""); 
		$("#infoTable #"+data).attr("checked", true);
		$("#infoTable #row_"+data).attr("class", "tr-primary");
		
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/tab/tabInfo.do",
			data : {userUuid : data},
			dataType : "json",
			success : function(data) {    
			//	 window.location.href = CommonUtil.getContextPath() +  "/tab/tab.do";
				 // 페이지를 새로고침 없이 변경
			        history.pushState(null, null, CommonUtil.getContextPath() + "/main.do");  // 주소 변경(가상)
			        $("#contentArea").load(CommonUtil.getContextPath() + "/tab/tab.do");  // 콘텐츠만 업데이트	
			}
		});
	}
    // 선택 환자의 i-Sens 혈당 데이터 수동 동기화
	function fnSyncBlood() {
		var uuid = $("#userUuid").val();
		if (!uuid) {
			alert("먼저 환자 행을 클릭하여 선택하세요.");
			return;
		}
		if (!confirm("선택한 환자의 i-Sens 혈당 데이터를 동기화하시겠습니까?")) return;

		$.ajax({
			type: "post",
			url: CommonUtil.getContextPath() + "/syncPatientBlood.do",
			data: JSON.stringify({ userUuid: uuid }),
			contentType: "application/json",
			dataType: "json",
			success: function(data) {
				if (data.IsSucceed) {
					alert(data.Message || ("동기화 완료: " + data.Data + " 건"));
				} else {
					alert("동기화 실패: " + (data.Message || ""));
				}
			},
			error: function(xhr, status, error) {
				alert("동기화 요청 중 오류가 발생했습니다.");
				console.error(status, error);
			}
		});
	}

    // 버튼 클릭 시 특정 JSP를 불러오는 함수
	function loadAdminResp() {
	    $.ajax({
	        type: "post",
	        url: CommonUtil.getContextPath() + "/admin/admin_resp.do",
	        dataType: "html", // JSP 화면 호출에 적합한 데이터 유형
	        success: function(response) {
	            // 호출한 JSP 화면을 특정 영역에 삽입
	            $("#targetElement").html(response);
	        },
	        error: function(xhr, status, error) {
	            console.error("Error loading JSP: ", error);
	        }
	    });
	}
</script>
</head>
<body>  
    <div class="tab-pane">  
      <div class="content-body">
      
	   <div class="tab-content">
		<div class="content-wrap">  
		
		<div class="flex-left-right mb-10">
			<div class="patient-info">
				<div class="info-name">회원관리</div>
			</div>
		</div>
		
        <section class="top-pannel">  
          <div class="search-box">
            <label for="search" class="form-title" onclick="">검색어 입력</label>
            <input type="text" name="searchText" id="searchText" class="form-control search" placeholder="환자명 또는 전화번호를 입력하세요." 
                                                                                onkeypress="if( event.keyCode == 13 ){fnSearch();}">
            <button class="buttcon" onclick="javascript:fnSearch();"><span class="icon icon-search" ></span></button>
					<input class="form-check-input" type="checkbox" name="user_gb"  onchange="fnSearch()"
						id="user_gb" value="Y"> <span class="ml-1">실증환자</span>
                        <span class="total-count">총인원: <span id="totalCount">0</span>명</span>
 						<div class="search-times" style= "text-align: right; white-space: nowrap;">
						    <span>조회분초: <span id="formatted01Hour" class="time">--:--</span></span> 
						  <!--  <span class="divider">|</span> --> 
						    <span>조회종료: <span id="formatted12Hour" class="time">--:--</span></span> 
						 <!--    <span class="divider">|</span> -->
						    <span>소요시간: <span id="totalResponseTime" class="time">0</span>초</span>
						</div>
            </div>    
        </section>
       
        <section class="main-pannel">
          <div class="main-left w-100">
            <header class="main-hd">
              <h2></h2>
            </header>
            <div class="main-content">
              <!-- 테이블 샘플 -->
              <div class="table-responsive">
                <table id="infoTable" class="table table-bordered">
                  <colgroup>
                  	<col style="width: 50px">
                    <col style="width: 100px">
                    <col style="width: 100px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 100px">
                    <col style="width: 80px">     
                    <col style="width: 80px">                                   
                    <col style="width: 180px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th>번호</th>
                      <th>이름</th>
                      <th>연락처</th>
                      <th>성별</th>
                      <th>생년월일</th>
                      <th>나이</th>
                      <th>당뇨구분</th>
                      <th>신장(cm)</th>     
                      <th>몸무게(kg)</th>                   
                      <th>가입일</th>
                      <th>가입접수일시</th>
                      <th>환자구분</th>
                    </tr>
                  </thead>
                  <tbody id="dataArea">
        			<tr>
        				<td colspan="8">&nbsp;</td>
        			</tr>
                  </tbody>
                </table>
              </div>
              <!-- 페이저 영역 -->
              <div id="gridPager" class="grid-pager"></div>
            </div>
          </div>
        </section>
        </div>
        </div>
      </div>
  <form:form commandName="DTO" id="regForm" name="regForm" method="post"> 
   <input type="hidden" name="userUuid" id="userUuid" value="${sessionScope['t_user_uuid']}"/>
  </form:form>
  </div>
<!-- Modal -->
<div class="modal fade" id="responseTimeModal" tabindex="-1" role="dialog" aria-labelledby="responseTimeModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="responseTimeModalLabel">혈당실증대상자결과(100건)</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body" id="responseTimeMessage">
			    <p>조회시작 시간: <span id="formatted01Hour"></span> </p>
			    <p>수신 시간: <span id="formatted12Hour"></span> </p>
			    <p>응답소요 시간: <span id="totalResponseTime">0</span> 초</p>
			</div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

</body>
</html>
