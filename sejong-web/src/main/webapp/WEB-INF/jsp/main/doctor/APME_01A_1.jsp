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

  table thead th {
    position: sticky;
    top: 0; /* 헤더 고정 */
    background-color: #f8f9fa; /* 헤더 배경색 */
    z-index: 2; /* 헤더가 데이터보다 위에 위치하도록 설정 */
  }

  table tbody tr:nth-child(even) {
    background-color: #f2f2f2; /* 짝수행 배경색 설정 (가독성 개선) */
  }
  .total-count {
    margin-right: 1rem; /* 오른쪽 여백 (옵션) */
  }
</style>
<script>
var user_gubun = "" ;
$(document).ready(function () {
	$("#user_gb").prop("checked",true); 
	fnSearch() ;
})
</script>
<script type="text/javaScript"> 
//조회시작 
function fnSearch() {

	 document.getElementById("regForm").reset();
	 
	 $("#dataArea").empty();
//	 	if($('#searchText').val() == "") {
//		alert("검색어를 입력하세요.");
//		$('#searchText').focus();
//		return; 
//	 }
 
    user_gubun = $("#user_gb").is(':checked') ? "1" : "2" ;
    
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
    data : {user_nm : $("#searchText").val(),
	        user_gb : user_gubun,
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
            
    		var dataTxt = "";
    		var totalCount = data.resultCnt ;
    		document.getElementById("totalCount").textContent = totalCount; // 건수 업데이트
    		for(var i=0 ; i < data.resultCnt; i++){
    			//성별 구분
    			var genderText = "";
	    		if (data.resultLst[i].gender == "F"){
	    			genderText = "여성";
	    	    } else if(data.resultLst[i].gender == "M") {
	    	        genderText = "남성";
	    	    } 
   		
	    		//만나이 계산
    		    // 현재 날짜를 가져옵니다.
	    		  var birthYear = data.resultLst[i].birth.substring(0,4);
				  var birthMonth = data.resultLst[i].birth.substring(4,6);
				  var birthDay = data.resultLst[i].birth.substring(6,8);
				  var birthDate = birthYear+ "-" + birthMonth +"-" + birthDay;
					  
				  var currentDate = new Date();
				  var currentYear = currentDate.getFullYear();
				  var currentMonth = currentDate.getMonth();
				  var currentDay = currentDate.getDate();
				  
				  var age = currentYear - birthYear;
				  if (currentMonth < birthMonth) {
					    age-1;
					  }
					  // 현재 월과 생일의 월이 같은 경우, 현재 일과 생일의 일을 비교합니다.
					  else if (currentMonth === birthMonth && currentDay < birthDay) {
					    age-1;
					  }else{
						age;
					  }
				  
	             var userText = "";
	             if (data.resultLst[i].user_gb == "1"){
	            	 userText = "실증환자";
	             } else if(data.resultLst[i].user_gb == "2") {
	            	 userText = "테스트";
	             } 	  
	    		  
    			dataTxt = '<tr  class="" onclick="javascript:fnDtlSearch(\''+data.resultLst[i].user_uuid+'\');" id="row_'+data.resultLst[i].user_uuid+'">'; 
				dataTxt += 	"<td>" + (i+1)  + "</td>" ; 
				dataTxt +=  "<td>" + data.resultLst[i].user_nm.substring(0,1)  + "*" +
				                     data.resultLst[i].user_nm.substring(2,3)  + "</td>" ;
				                     
				dataTxt +=  "<td>" + data.resultLst[i].phone.substring(0,3)+"-****-" + 
									 data.resultLst[i].phone.substring(7,11)+"</td>" ;
				dataTxt +=  "<td>" + genderText   + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].birth.substring(0,4)+"년&nbsp" + 
									 data.resultLst[i].birth.substring(4,6)+"월&nbsp" + 
									 data.resultLst[i].birth.substring(6,8)+"일" + "</td>" ;
				dataTxt +=  "<td>" + age   + "</td>" ;
	            
				dataTxt +=  "<td>" + data.resultLst[i].dtl_code_nm   + "</td>" ;
	            dataTxt +=  "<td>" + data.resultLst[i].height        + "</td>" ;
	            dataTxt +=  "<td>" + data.resultLst[i].weight        + "</td>" ;
	            
				dataTxt +=  "<td>" + data.resultLst[i].joinYmd.substring(0,4)+"년&nbsp" + 
									 data.resultLst[i].joinYmd.substring(4,6)+"월&nbsp" + 
									 data.resultLst[i].joinYmd.substring(6,8)+"일" + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].reg_dtm        + "</td>" ;					 
			    dataTxt +=  "<td>" + userText   + "</td>" ;					 
				dataTxt +=  "</tr>";
	            $("#dataArea").append(dataTxt);
	            
				$("#user_uuid").val(data.resultLst[i].user_uuid);
        	 }
	 	  }else{
				 $("#dataArea").append("<tr><td colspan='12'>검색된 정보가 없습니다.</td></tr>");
		  }
      }
   });
}
function formatTimeWithMilliseconds(date) { const hours = String(date.getHours()).padStart(2, '0'); 
         const minutes = String(date.getMinutes()).padStart(2, '0'); 
         const seconds = String(date.getSeconds()).padStart(2, '0'); 
         const milliseconds = String(date.getMilliseconds()).padStart(3, '0'); 
         return `${hours}:${minutes}:${seconds}.${milliseconds}`;
}
	function fnDtlSearch(data){ 
		if(data == '' || data == null) return;
		
		 document.regForm.user_uuid.value = data ; 
		//row 클릭시 바탕색 변경 처리 Start 
		$("#infoTable tr").attr("class", ""); 
		$("#infoTable #"+data).attr("checked", true);
		$("#infoTable #row_"+data).attr("class", "tr-primary");
		
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/tab/tabInfo.do",
			data : {user_uuid : data},
			dataType : "json",
			success : function(data) {    
			//	 window.location.href = CommonUtil.getContextPath() +  "/tab/tab.do";
				 // 페이지를 새로고침 없이 변경
			        history.pushState(null, null, CommonUtil.getContextPath() + "/main.do");  // 주소 변경(가상)
			        $("#contentArea").load(CommonUtil.getContextPath() + "/tab/tab.do");  // 콘텐츠만 업데이트	
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
              <div class="btn-box"> 
               <!--   <button class="btn btn-outline-dark btn-sm" onclick="fnSave('U');">수정</button>
                <button class="btn btn-primary btn-sm" onclick="fnSave('I');" >입력</button>-->
              </div> 
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
            </div>
          </div> 
        </section>
        </div>
        </div>
      </div>
  <form:form commandName="DTO" id="regForm" name="regForm" method="post"> 
   <input type="hidden" name="user_uuid" id="user_uuid" value="${sessionScope['t_user_uuid']}"/>
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
