<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>  
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>  
<%@ page import = "java.util.*" %>
<html>
<head>  
 <title>공지 사항 </title>
<!-- 달력(일자, 월별) 사용시 추가 필요함 -->  
<script src="/js/main.js"></script>
<script type="text/javaScript"> 
$( document ).ready(
		function() {
			selectWeek();
});
$(document).ready(function () {
	fnSearch() ;
})
var adminModal = new bootstrap.Modal(document.getElementById('adminModal'));

function fnSearch() {
	if ($("#start_date").val() > $("#end_date").val()){
		alert("조회시작일은 종료일보다 낮을 수 없습니다. 다시 선택해주세요.");
		return;
	}
	 $("#infoTable tr").attr("class", ""); 
	
	 document.getElementById("regForm").reset();
	 
	 $("#dataArea").empty();

	$.ajax({
   	url : CommonUtil.getContextPath() + '/doctor/noticeList.do',
    type : 'post',
    data : {searchGb : $("#searchGb").val(), 
    		start_date : $("#start_date").val(), 
    		end_date:$("#end_date").val(),
    		searchText:$("#searchText").val()
    		},
	dataType : "json",
   	success : function(data) {
   		if(data.error_code != "0") return;
   		if(data.resultCnt > 0 ){
    		var dataTxt = "";
    		for(var i=0 ; i < data.resultCnt; i++){
    			dataTxt = '<tr  class="" onclick="javascript:fnDtlSearch(\''+data.resultLst[i].noti_seq+'\');" id="row_'+data.resultLst[i].noti_seq+'">';
 				dataTxt += 	"<td>" + (i+1)  + "</td>" ; 
				dataTxt +=  "<td>" + data.resultLst[i].title  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].post_str.substring(0,4)+"년&nbsp" + 
									 data.resultLst[i].post_str.substring(5,7)+"월&nbsp" + 
									 data.resultLst[i].post_str.substring(8,10)+"일  ~   " +
									 data.resultLst[i].post_end.substring(0,4)+"년&nbsp" + 
									 data.resultLst[i].post_end.substring(5,7)+"월&nbsp" + 
									 data.resultLst[i].post_end.substring(8,10)+"일" + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].reg_dtm.substring(0,4)+"년&nbsp" + 
									 data.resultLst[i].reg_dtm.substring(5,7)+"월&nbsp" + 
									 data.resultLst[i].reg_dtm.substring(8,10)+"일" + "</td>" ;
				dataTxt +=  "</tr>";
	            $("#dataArea").append(dataTxt);
        	 }
            // 각 행 클릭 시 모달에 데이터 전달
            $("#dataArea tr").on('click', function() {
              var noti_seq = $(this).attr('id').replace('row_', ''); // 행 ID에서 noti_seq 추출
              var noticeData = data.resultLst.find(function(item) { return item.noti_seq === noti_seq; });

              // 모달에 데이터 채우기
              openModalWithData(noticeData);  // 공지사항 데이터를 모달로 전달
            });    	
	 	  }else{
				 $("#dataArea").append("<tr><td colspan='12'>검색된 정보가 없습니다.</td></tr>");
		  }
      }
   });
}
//모달에 데이터를 전달하여 여는 함수
function openModalWithData(noticeData) {
  var modalElement = document.getElementById('adminModal');
  if (modalElement) {
    var adminModal = new bootstrap.Modal(modalElement);

    // 모달에 데이터 채우기
    $('#modalTitle').text(noticeData.title);
    $('#modalPostStart').text(noticeData.post_str.substring(0, 4) + "년 " +
                             noticeData.post_str.substring(5, 7) + "월 " +
                             noticeData.post_str.substring(8, 10) + "일");
    $('#modalPostEnd').text(noticeData.post_end.substring(0, 4) + "년 " +
                           noticeData.post_end.substring(5, 7) + "월 " +
                           noticeData.post_end.substring(8, 10) + "일");
    $('#modalRegDate').text(noticeData.reg_dtm.substring(0, 4) + "년 " +
                            noticeData.reg_dtm.substring(5, 7) + "월 " +
                            noticeData.reg_dtm.substring(8, 10) + "일");
    
    // 필요한 다른 데이터도 채울 수 있음
    $('#modalContent').text(noticeData.content); // 예: 공지 내용

    // 모달 열기
    adminModal.show();
  }
}
	
function fnDtlSearch(data){ 
	if(data == '' || data == null) return;
	 
	document.regForm.noti_seq.value = data ; 
	
	//row 클릭시 바탕색 변경 처리 Start 
	$("#infoTable tr").attr("class", ""); 
	$("#infoTable #"+data).attr("checked", true);
	$("#infoTable #row_"+data).attr("class", "tr-primary");
	fnSave();
	 
}

function fnSave(){

	$.ajax( {
		type : "post",
		url : CommonUtil.getContextPath() + "/doctor/noticeInfo.do",
		data : {noti_seq : $("#noti_seq").val()},
		dataType : "json",
		success : function(data) {    
			if(data.error_code != "0") {
				alert(data.error_msg);
				return;
			}
			$("#title").val(data.result.title);
			$("#expln").val(data.result.expln);
			$("#post_str").val(data.result.post_str);
			$("#post_end").val(data.result.post_end);
			$("#reg_dtm").val(data.result.reg_dtm);
			}
		});
	$("#adminModal").modal("show");
}

function modalClose(){
	//모달이 있을 경우
	$("#adminModal").modal("hide");
}



function selectToday() {
	var today = new Date();
	var year = today.getFullYear();
	var month = ('0' + (today.getMonth() + 1)).slice(-2);
	var day = ('0' + today.getDate()).slice(-2);
	var dateString = year + '-' + month  + '-' + day;

	$("#start_date").val(dateString);
	$("#end_date").val(dateString);
}
function selectWeek() {
	var today = new Date();
    var year = today.getFullYear();
    var month = ('0' + (today.getMonth() + 1)).slice(-2);
    var day = ('0' + today.getDate()).slice(-2);
    var end_date = year + '-' + month  + '-' + day;
    
    // 7일 전의 날짜 계산
    var lastWeek = new Date(today);
    lastWeek.setDate(today.getDate() - 7);
    var start_year = lastWeek.getFullYear();
    var start_month = ('0' + (lastWeek.getMonth() + 1)).slice(-2);
    var start_day = ('0' + lastWeek.getDate()).slice(-2);
    var start_date = start_year + '-' + start_month + '-' + start_day;
    
    // 날짜 설정
    $("#start_date").val(start_date);
    $("#end_date").val(end_date);
}
function selectMonth() {
	var today = new Date();
    var year = today.getFullYear();
    var month = ('0' + (today.getMonth() + 1)).slice(-2);
    var day = ('0' + today.getDate()).slice(-2);
    var end_date = year + '-' + month  + '-' + day;

    // 한 달 전의 날짜 계산
    var lastMonth = new Date(today);
    lastMonth.setMonth(today.getMonth() - 1);
    var start_year = lastMonth.getFullYear();
    var start_month = ('0' + (lastMonth.getMonth() + 1)).slice(-2);
    var start_day = ('0' + lastMonth.getDate()).slice(-2);
    var start_date = start_year + '-' + start_month + '-' + start_day;

    // 날짜 설정
    $("#start_date").val(start_date);
    $("#end_date").val(end_date);
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
				<div class="info-name">공지관리</div>
			</div>
		</div>
		
        <section class="top-pannel">  
          <div class="search-box w-750">
            <label class="form-title">등록일&nbsp&nbsp&nbsp</label>
            <!-- 데이트피커 범위 -->
            <!-- <input type="text" class="form-control" name="dates" value=" "> -->
            <!-- 데이트피커 싱글 -->
            <input type="date" class="form-control w-30" name="start_date" id="start_date"  value="">
            <span> ~ </span>
            <input type="date" class="form-control w-30" name="end_date" id="end_date"  value=""> 
          <button type="button" class="btn btn-outline-dark btn-md" onclick="javascript:selectToday();">오늘</button>
          <button type="button" class="btn btn-outline-dark btn-md" onclick="javascript:selectWeek();">최근 일주일</button>
          <button type="button" class="btn btn-outline-dark btn-md" onclick="javascript:selectMonth();">최근 한달</button>
          </div> 
          <div class="search-box w-75">
            <label for="search" class="form-title" onclick="">검색구분</label>
           	  <select class="form-select w-25" name="searchGb" id="searchGb">
                <option value="A">전체</option> 
       			<option value="T">제목</option>
                <option value="E">내용</option>
              </select> 
            <input type="text" name="searchText" id="searchText" class="form-control search" placeholder="검색어를 입력하세요." onkeypress="if( event.keyCode == 13 ){fnSearch();}">
            <button class="buttcon" onclick="javascript:fnSearch();"><span class="icon icon-search" ></span></button>
          </div> 
          <div class="search-box w-30"></div>
        </section>
        <section class="main-pannel">
          <div class="main-left w-100">
            <header class="main-hd">
              <h2>&nbsp </h2>
            </header>
            <div class="main-content">
              <!-- 테이블 샘플 -->
              <div class="table-responsive">
                <table id="infoTable" class="table table-bordered">
                  <colgroup>
                  	<col style="width: 30px">
                    <col style="width: 200px">
                    <col style="width: 130px">
                    <col style="width: 100px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th>번호</th>
                      <th>제목</th>
                      <th>게시기간</th>
                      <th>등록일</th>
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
  <!-- 모달 -->
  <div class="modal fade" id="adminModal" tabindex="-1" aria-labelledby="adminModallLabel" aria-hidden="true">
    <!-- 모달 class명으로 사이즈 조절 modal-320, 410, 520, 650, 820 -->
    <div class="modal-dialog  modal-820">
      <div class="modal-content">
        <div class="modal-footer">
          <button type="button" class="btn btn-outline-dark btn-sm" data-bs-dismiss="modal" onclick="modalClose();">목록</button>
        </div>
        <form:form commandName="DTO" id="regForm" name="regForm" method="post"> 
          <input type="hidden" name="noti_seq" id="noti_seq"/>
        <div class="modal-body">
          <div class="form-container"> 
            <div class="form-wrap w-100">
              <label for="" class="critical" style="left">제목</label>
              <input type="text" name="title" id="title" class="form-control" readonly>
            </div>
            <div class="form-wrap w-100 h-300">
              <label for="" class="critical">내용</label>
              <textarea class="form-control" aria-label="With textarea" placeholder="공지내용을 입력하세요." name="expln" id="expln" readonly></textarea>   
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical" style="left">공지시작일</label>
              <input type="date" name="post_str" id="post_str" class="form-control" readonly> 
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical" style="left">공지종료일</label>
              <input type="date" name="post_end" id="post_end" class="form-control" readonly> 
	        </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">등록일</label>
              <input type="date" name="reg_dtm" id="reg_dtm" class="form-control" readonly>
            </div>
          </div> 
        </div>
        </form:form>
      </div>
    </div>
  </div>
  </div>
</body>
</html>
