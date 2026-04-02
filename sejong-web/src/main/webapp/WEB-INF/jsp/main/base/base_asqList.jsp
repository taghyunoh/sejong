<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>  
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page   import = "java.util.*" %>
<html>
<head>
<style>
.modal-820 {
    max-width: 1000px;
}
</style>
<!-- 달력(일자, 월별) 사용시 추가 필요함 -->  
<script src="/js/main.js"></script>
<script type="text/javaScript"> 

var adminModal = new bootstrap.Modal(document.getElementById('adminModal'));
var uidGubun = "" ;

	
function fnSearch() {
	$("#infoTable tr").attr("class", ""); 
	
	document.getElementById("regForm").reset();
	 
	$("#dataArea").empty();
	$.ajax({
	   	url : CommonUtil.getContextPath() + 'base/ctl_asqList.do',
	    type : 'post',
	    data : {qstn_title : $("#searchText").val() },
		dataType : "json",
	   	success : function(data) {
	   		if(data.error_code != "0") return;
	   		if(data.resultCnt > 0 ){
	    		var dataTxt = "";
	    		for(var i=0 ; i < data.resultCnt; i++){
	    			dataTxt = '<tr  class="" onclick="javascript:fnDtlSearch(\''+data.resultLst[i].asq_seq +'\');" id="row_' 
	    			                                                                      + data.resultLst[i].asq_seq+'">';
	 				dataTxt += 	"<td>" + (i+1)  + "</td>" ; 
	 				dataTxt +=  "<td>" + data.resultLst[i].hosp_nm   + "</td>" ;
	 				dataTxt +=  "<td class='txt-left ellips'>" + data.resultLst[i].qstn_title    + "</td>" ;
					dataTxt +=  "<td class='txt-left ellips'>" + data.resultLst[i].qstn_conts    + "</td>" ;	
					dataTxt +=  "<td>" + data.resultLst[i].qstn_stat    + "</td>" ;	
	 				dataTxt +=  "<td>" + data.resultLst[i].ansr_stat    + "</td>" ;	
	 				dataTxt +=  "<td>" + data.resultLst[i].user_nm   + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].upd_user + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].upd_dttm  + "</td>" ; 
					dataTxt +=  "</tr>";
		            $("#dataArea").append(dataTxt);
	        	 }
		 	  }else{
				  $("#dataArea").append("<tr><td colspan='12'>검색된 정보가 없습니다.</td></tr>");
			  }
	      }
   });
}
function fnDtlSearch(data){ 
		if(data == '' || data == null) return;
		document.regForm.asq_seq.value = data ; 
		//row 클릭시 바탕색 변경 처리 Start 
		$("#infoTable tr").attr("class", ""); 
		$("#infoTable #"+data).attr("checked", true);
		$("#infoTable #row_"+data).attr("class", "tr-primary");
		 
	}
function fnsave(iud){
	$("#iud").val(iud);  // 입력(I), 수정(U), 삭제(D) 
	uidGubun = iud ;
    // 특정 요소 숨기기
    $("#ansr_conts").parent().hide(); // 답변내용 숨기기
    $("#ansrInput").closest(".form-wrap").hide(); // 파일업로드 숨기기
    $("#ansr_wan").closest(".form-wrap").hide(); // 답변완료 숨기기	
	if(iud.substring(1,2) == "I"){
		//등록폼 초기화
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/base/ctl_getHospmst.do",
			data : {hosp_uuid: "${sessionScope['q_uuid']}"},
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				$("#hosp_cd").val(data.result.hosp_cd);
			}	
		} );		
		document.getElementById("regForm").reset();
		setCurrDate("reg_dtm");
    	$("#ansr_conts").prop("readonly","true");
		modalOpen() ;

	}else if(iud.substring(1,2) == "U" || iud.substring(1,2) == "D" ){
		if($("#asq_seq").val() == ""){
			alert("선택된  정보가 없습니다.!");
			modalClose() ;
			return;
		}
		
		$("#reg_dtm").prop("readonly",false);
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/base/selectAnsrInfo.do",
			data : {asq_seq : $("#asq_seq").val()},
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				$("#qstn_title").val(data.result.qstn_title);
				$("#qstn_conts").val(data.result.qstn_conts);
				$("#qstn_wan").val(data.result.qstn_wan);
				$("#ansr_wan").val(data.result.ansr_wan);
				$("#ansr_conts").val(data.result.ansr_conts);
				$("#file_gb").val(data.result.file_gb);
				$("#reg_dtm").val(data.result.reg_dtm);

				if ($("#qstn_wan").val().trim() === "Y") { 
					$("#ansr_conts").parent().show(); // 답변내용 보이기
					$("#ansrInput").closest(".form-wrap").show(); // 파일업로드 보이기
					$("#ansr_wan").closest(".form-wrap").show(); // 답변완료 보이기
				}; 
				
				if (uidGubun.substring(0,1) == "Q") {
					$("#qstn_title").prop("readonly","");
					$("#qstn_conts").prop("readonly","");
					document.getElementById("qstnInput").disabled = false;
					$("#qstn_wan").css("pointer-events", "auto").css("background-color", ""); // 콤보박스 활성화 
					$("#qstnButton").removeClass("disabled"); // 클릭 불가 클래스 제거

					$("#ansr_conts").prop("readonly","true");
					$("#ansrButton").addClass("disabled"); // 클릭 불가 클래스 추가
					$("#ansr_wan").css("pointer-events", "none").css("background-color", ""); // 콤보박스 활성화 
				}else {
					$("#ansr_conts").prop("readonly","");
					document.getElementById("ansrInput").disabled = false;
					$("#ansr_wan").css("pointer-events", "auto").css("background-color", ""); // 콤보박스 활성화 
					$("#ansrButton").removeClass("disabled"); // 클릭 불가 클래스 제거

					$("#qstn_title").prop("readonly","true");
					$("#qstn_conts").prop("readonly","true");
					$("#qstnButton").addClass("disabled"); // 클릭 불가 클래스 추가
					$("#qstn_wan").css("pointer-events", "none").css("background-color", ""); // 콤보박스 활성화 	
				}
			}
		});
	} else if(iud.substring(1,2) == "D"){
		fnSaveProc();
	}	
	modalOpen() ;
}
function fnSaveProc(){
	//if(!fnRequired('file_gb', '공지구분을 확인 하세요.'))   return;
	if(!fnRequired('qstn_title', '질문제목을 확인 하세요.'))   return;
	if(!fnRequired('qstn_conts', '질문내용을  확인하세요.')) return;
	var formData = $("form[name='regForm']").serialize();
	var msg = "" ;
	if (uidGubun.substring(1,2) == "U"){
		msg = "수정 하시겠습니다?" ;
	}else if (uidGubun.substring(1,2) == "D"){
		msg = "삭제 하시겠습니다?" ;
	}else{
		msg = "입력 하시겠습니다?" ;
	}
	if(confirm(""+ msg)) {
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/base/asqSaveAct.do",
			data : formData,
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				fnSearch() ;
				modalClose();
			}
		});
	}
}
function modalOpen() {
    // 모달을 열기 위한 조건을 true로 설정
    var condition = true;

    // adminModal 요소가 존재하고, condition이 true일 때만 모달을 열기
    var adminModal = document.getElementById('adminModal');
    
    if (adminModal && condition) {
        if (window.adminModalInstance) {
            window.adminModalInstance.dispose(); // 기존 모달 인스턴스를 폐기
        }
        
        window.adminModalInstance = new bootstrap.Modal(adminModal);
        window.adminModalInstance.show();  // 모달 열기
    } else {
        console.log("조건이 맞지 않아 모달을 열지 않습니다.");
    }
}
function modalClose(){
 //   $('#adminModal').modal('hide'); // 모달 닫기
 //   추가적인 인스턴스 호출이 필요하다면 확인 후 사용
     if (window.adminModalInstance) {
         window.adminModalInstance.hide();  // 모달 닫기
     }	
}

function GetDate(sdt,edt){
	$("#start_date").val(sdt);
	$("#end_date").val(edt);
}
function selectToday() {
	var today = new Date();
	var year = today.getFullYear();
	var month = ('0' + (today.getMonth() + 1)).slice(-2);
	var day = ('0' + today.getDate()).slice(-2);
	var dateString = year + '-' + month  + '-' + day;
	GetDate(dateString,dateString);
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
    GetDate(start_date,end_date);
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
    GetDate(start_date,end_date);
}
// 파일 목록에 추가
function handleFiles(files) {
    for (let i = 0; i < files.length; i++) {
        const file = files[i];
        const fileItem = document.createElement('div');
        fileItem.classList.add('file-item');
        fileItem.textContent = file.name;

        // 삭제 버튼 추가
        const deleteBtn = document.createElement('button');
        deleteBtn.textContent = '삭제';
        deleteBtn.classList.add('delete-btn');
        deleteBtn.addEventListener('click', function() {
            fileItem.remove(); // 해당 파일 항목 삭제
        });

        fileItem.appendChild(deleteBtn);
        fileList.appendChild(fileItem);
    }
}
function openFileInput(event) {
    event.preventDefault();
    const inputId = uidGubun.startsWith("Q") ? 'qstnInput' : 'ansrInput';
    document.getElementById(inputId).click();
}
function showFileName(event) {
    const fileName = event.target.files[0]?.name || "선택된 파일 없음";
    const targetId = uidGubun.startsWith("Q") ? "fileNameqstn" : "fileNameansr";
    document.getElementById(targetId).textContent = fileName;
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
				<div class="info-name">질의응답 목록</div>
			</div>
		</div>

        <section class="top-pannel">  
           <div class="search-box">
            <label for="search" class="form-title" onclick="">검색어 입력</label>
            <input type="text" name="searchText" id="searchText" class="form-control search" placeholder="검색어를 입력하세요." 
                                                                 onkeypress="if( event.keyCode == 13 ){fnSearch();}">
            <button class="buttcon" onclick="javascript:fnSearch();"><span class="icon icon-search" ></span></button>
          </div> 
        </section>
        <section class="main-pannel">
          <div class="main-left w-100">
            <header class="main-hd">
            <!--  <h2>&nbsp 공지 사항 목록</h2> --> 
              <h2></h2>
              <div class="btn-box">
                <button class="btn btn-outline-dark btn-sm" onclick="fnsave('QU');">질문수정</button>
                <button class="btn btn-primary btn-sm"  onclick="fnsave('QI');">질문등록</button>
                <button class="btn btn-outline-dark btn-sm" onclick="fnsave('AU');">답변등록</button>
              </div>
            </header>
            <div class="main-content">
              <!-- 테이블 샘플 -->
              <div class="table-responsive">
                <table id="infoTable" class="table table-bordered">
                  <colgroup>
                  	<col style="width: 30px">
                  	<col style="width: 50px">
                    <col style="width: 100px">
                    <col style="width: 200px">
                    <col style="width: 50px">
                    <col style="width: 50px">
                    <col style="width: 50px">
                    <col style="width: 50px">
                    <col style="width: 50px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th>번호</th>
                      <th>병원정보</th>
                      <th>질문제목</th>
                      <th>질문내용</th>
                      <th>질문상태</th>
                      <th>답변상태</th>
                      <th>질문자</th>
                      <th>아이디</th>
                      <th>적성일</th>
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
  <div class="modal fade" id="adminModal" tabindex="-1" aria-labelledby="adminlNoticeLabel" aria-hidden="true">
    <!-- 모달 class명으로 사이즈 조절 modal-320, 410, 520, 650, 820 -->
    <div class="modal-dialog" style="max-width: 1000px;">>
      <div class="modal-content">
        <div class="modal-footer">
          <button type="button" class="btn btn-primary btn-sm"  onclick="fnSaveProc();">저장</button>
          <button type="button" class="btn btn-outline-dark btn-sm" data-bs-dismiss="modal" onclick="modalClose();">목록</button>
        </div>
         <form:form commandName="DTO"  id="regForm" name="regForm" method="post" enctype="multipart/form-data">
           <input type="hidden" name="iud" id="iud"/> 
           <input type="hidden" name="asq_seq" id="asq_seq"/> 
           <input type="hidden" name="file_gb" id="file_gb" value = "4"/>  
           <input type="hidden" name="hosp_cd" id="hosp_cd"/> 
           <input type="hidden" name="hosp_uuid" id="hosp_uuid" value = "${sessionScope['q_uuid']}" />
           <input type="hidden" name="upd_user" id="upd_user" value = "1111"/> 
        <div class="modal-body">
          <div class="form-container"> 
            <div class="form-wrap w-100">
              <label for="" class="critical" style="left">제목</label>
              <input type="text" name="qstn_title" id="qstn_title" class="form-control" placeholder="질문제목을 입력하세요." >
            </div>
            <div class="form-wrap w-100">
              <label for="" class="critical">파일업로드</label>
              <div class="btn-box d-flex align-items-center">
                <input type="file" id="qstnInput" style="display: none;" onchange="showFileName(event)">
                <button type="button" id="qstnButton" class="btn btn-primary btn-sm" onclick="openFileInput(event)">파일 선택</button>
                <span id="fileNameqstn" class="ms-3"></span>
              </div>
            </div>  
            <div class="form-wrap w-100">
              <label for="" class="critical" style="left">질문내용</label>
              <textarea class="form-control" aria-label="With textarea" placeholder="질문내용을 입력하세요." 
                                      name="qstn_conts" id="qstn_conts" style= "height: 210px;"> </textarea>              
            </div>
            <div class="form-wrap w-50">
	              <label for=""class="critical">질문완료</label>
	       		  <select class="form-select" name="qstn_wan" id="qstn_wan">
	                <option value="">선택</option> 
	                <option value="Y">Y.질문완료</option>
	                <option value="N">N.진행중</option>
	              </select> 
		    </div>   
            <div class="form-wrap w-100" >
              <label for="" class="critical" style="left">답변내용</label>
              <textarea class="form-control" aria-label="With textarea" placeholder="답변내용을 입력하세요." 
                                      name="ansr_conts" id="ansr_conts"  style= "height: 260px;"></textarea>              
            </div>  
            <div class="form-wrap w-100">
              <label for="" class="critical">파일업로드</label>
              <div class="btn-box d-flex align-items-center">
                <input type="file" id="ansrInput" style="display: none;" onchange="showFileName(event)">
                <button type="button" id="ansrButton" class="btn btn-primary btn-sm" onclick="openFileInput(event)">파일 선택</button>
                <span id="fileNameansr" class="ms-3"></span>
              </div>
            </div> 
            <div class="form-wrap w-50" >
	              <label for=""class="critical">답변완료</label>
	       		  <select class="form-select" name="ansr_wan" id="ansr_wan">
	                <option value="">선택</option> 
	                <option value="Y">Y.답변완료</option>
	                <option value="N">N.진행중</option>
	              </select> 
		    </div>        
          </div>
        </div> 	
	  </form:form>
      </div>
    </div>
  </div>
</body>
</html>
