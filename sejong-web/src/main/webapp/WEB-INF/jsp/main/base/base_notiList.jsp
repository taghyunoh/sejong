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
    /* 드래그 앤 드롭 영역 스타일 */
    #drag-area {
        width: 80%;
        height: 150px;
        border: 2px dashed #ccc;
        display: flex;
        justify-content: center;
        align-items: center;
        margin-bottom: 20px;
        flex-direction: column;
    }
    #file-list {
        margin-top: 20px;
    }
    .file-item {
        padding: 5px;
        border: 1px solid #ddd;
        margin-bottom: 5px;
        background-color: #f9f9f9;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .file-list-container {
        width: 100%;
        max-height: 100px;
        overflow-y: auto;
        margin-top: 10px;
    }
    .delete-btn {
        background-color: #ff4d4d;
        color: white;
        border: none;
        padding: 2px 8px;
        cursor: pointer;
        font-size: 12px;
        border-radius: 4px;
    }
</style>
<!-- 달력(일자, 월별) 사용시 추가 필요함 -->  
<script src="/js/main.js"></script>
<script type="text/javaScript"> 
$( document ).ready(
		function() {
			selectWeek();
});

var adminModal = new bootstrap.Modal(document.getElementById('adminModal'));
var uidGubun = "" ;

function fnSearch() {

	$("#infoTable tr").attr("class", ""); 
	
	document.getElementById("regForm").reset();
	 
	$("#dataArea").empty();
	$.ajax({
	   	url : CommonUtil.getContextPath() + 'base/ctl_notiList.do',
	    type : 'post',
	    data : {start_date : $("#start_date").val(),end_date:$("#end_date").val(),searchText:$("#searchText").val()},
		dataType : "json",
	   	success : function(data) {
	   		if(data.error_code != "0") return;
	   		if(data.resultCnt > 0 ){
	    		var dataTxt = "";
	    		for(var i=0 ; i < data.resultCnt; i++){
	    			dataTxt = '<tr  class="" onclick="javascript:fnDtlSearch(\''+data.resultLst[i].noti_seq+'\');" id="row_'+data.resultLst[i].noti_seq+'">';
	 				dataTxt += 	"<td>" + (i+1)  + "</td>" ; 
	 				dataTxt +=  "<td>" + data.resultLst[i].noti_nm    + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].noti_title    + "</td>" ;
					dataTxt +=  "<td class='txt-left ellips'>" + data.resultLst[i].noti_content    + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].start_dt + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].end_dt + "</td>" ;
	 				dataTxt +=  "<td>" + data.resultLst[i].user_nm   + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].hosp_cd + "</td>" ;
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
		document.regForm.noti_seq.value = data ; 
		//row 클릭시 바탕색 변경 처리 Start 
		$("#infoTable tr").attr("class", ""); 
		$("#infoTable #"+data).attr("checked", true);
		$("#infoTable #row_"+data).attr("class", "tr-primary");
		 
	}
function fnsave(iud){
	$("#iud").val(iud);  // 입력(I), 수정(U), 삭제(D) 
	uidGubun = iud ;

	if(iud == "I"){
		document.getElementById("regForm").reset();
		setCurrDate("reg_dtm");
		setCurrDate("start_dt");
    	$("#end_dt").val("2099-12-31");
    	$("#use_yn").val("Y");
    	$("#file_gb").css("pointer-events", "auto").css("background-color", ""); // 콤보박스 활성화 
		modalOpen() ;

	}else if(iud == "U" || iud == "D" ){
		if($("#noti_seq").val() == ""){
			alert("선택된  정보가 없습니다.!");
			modalClose() ;
			return;
		}
		$("#reg_dtm").prop("readonly","");
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/base/selectNotiMstinfo.do",
			data : {noti_seq : $("#noti_seq").val()},
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				$("#noti_title").val(data.result.noti_title);
				$("#noti_content").val(data.result.noti_content);
				$("#file_gb").val(data.result.file_gb);
				$("#file_gb").css("pointer-events", "none").css("background-color", ""); // 콤보박스 활성화 
				$("#start_dt").val(data.result.start_dt);
				$("#end_dt").val(data.result.end_dt);
				$("#use_yn").val(data.result.use_yn);
				$("#reg_dtm").val(data.result.reg_dtm);
			}
		});
	} else if(iud == "D"){
		fnSaveProc();
	}	
	modalOpen() ;
}
function fnSaveProc(){
	if(!fnRequired('file_gb', '공지구분을 확인 하세요.'))   return;
	if(!fnRequired('noti_title', '제목을 확인 하세요.'))   return;
	if(!fnRequired('noti_content', '공지내용을  확인하세요.')) return;
	var formData = $("form[name='regForm']").serialize();
	var msg = "" ;
	if (uidGubun == "U"){
		msg = "수정 하시겠습니다?" ;
	}else if (uidGubun == "D"){
		msg = "삭제 하시겠습니다?" ;
	}else{
		msg = "입력 하시겠습니다?" ;
	}
	if(confirm(""+ msg)) {
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/base/notiSaveAct.do",
			data : formData,
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				fnSearch() ;
				modalClose();
				<!-- alert(msg.substr(0, 2) + "처리되었습니다.");	-->
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

window.fileHandlerInitialized = false;
//전역 변수로 초기화 상태 관리
if (!window.fileHandlerInitialized) {
	window.fileHandlerInitialized = true;
    // 요소 가져오기
    const dragArea = document.getElementById("drag-area");
    const fileInput = document.getElementById("file-input");
    const fileList = document.getElementById("file-list");

    // 이벤트 핸들러
    function dragOverHandler(event) {
        event.preventDefault(); // 기본 동작 방지
        dragArea.style.borderColor = "blue"; // 드래그 효과
    }

    function dragLeaveHandler() {
        dragArea.style.borderColor = "#ccc"; // 원래 색상 복구
    }

    function dropHandler(event) {
        event.preventDefault(); // 기본 동작 방지
        dragArea.style.borderColor = "#ccc"; // 색상 복구
        const files = event.dataTransfer.files; // 드래그된 파일 가져오기
        handleFiles(files);
    }

    function changeHandler(event) {
        const files = event.target.files; // 파일 입력 값 가져오기
        handleFiles(files);
        fileInput.value = ""; // 파일 입력 초기화
    }

    function openFileInput(event) {
        event.preventDefault(); // 기본 동작 방지
        fileInput.click(); // 파일 선택 창 열기
    }

    function handleFiles(files) {
        // 파일 목록 초기화 (필요 시 주석 처리 가능)
        // fileList.innerHTML = "";

        for (let i = 0; i < files.length; i++) {
            const file = files[i];
            const fileItem = document.createElement('div');
            fileItem.classList.add('file-item');
            fileItem.textContent = file.name;

            // 삭제 버튼 추가
            const deleteBtn = document.createElement('button');
            deleteBtn.textContent = '삭제';
            deleteBtn.classList.add('delete-btn');
            deleteBtn.style.marginLeft = "10px";
            deleteBtn.addEventListener('click', function() {
                fileItem.remove(); // 해당 파일 항목 삭제
            });

            fileItem.appendChild(deleteBtn);
            fileList.appendChild(fileItem);
        }
    }

    // 이벤트 리스너 등록
    dragArea.addEventListener("dragover", dragOverHandler);
    dragArea.addEventListener("dragleave", dragLeaveHandler);
    dragArea.addEventListener("drop", dropHandler);
    fileInput.addEventListener("change", changeHandler);
}
function saveFileListToStorage() {
    const fileItems = document.querySelectorAll('.file-item');
    const fileNames = Array.from(fileItems).map(item => item.textContent.replace('삭제', '').trim());
    localStorage.setItem('fileList', JSON.stringify(fileNames));
}

function loadFileListFromStorage() {
    const savedFileList = JSON.parse(localStorage.getItem('fileList') || '[]');
    savedFileList.forEach(fileName => {
        const fileItem = document.createElement('div');
        fileItem.classList.add('file-item');
        fileItem.textContent = fileName;

        const deleteBtn = document.createElement('button');
        deleteBtn.textContent = '삭제';
        deleteBtn.classList.add('delete-btn');
        deleteBtn.style.marginLeft = "10px";
        deleteBtn.addEventListener('click', function() {
            fileItem.remove();
            saveFileListToStorage();
        });

        fileItem.appendChild(deleteBtn);
        fileList.appendChild(fileItem);
    });
}
// 초기 로드 시 파일 목록 복구
loadFileListFromStorage();

function dragOverHandler(event) {
    event.preventDefault();
    dragArea.style.borderColor = "blue";
    dragArea.style.backgroundColor = "#f0f8ff"; // 연한 배경색 추가
}

function dragLeaveHandler() {
    dragArea.style.borderColor = "#ccc";
    dragArea.style.backgroundColor = "white"; // 기본 배경색 복구
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
				<div class="info-name">공지 사항 목록</div>
			</div>
		</div>

        <section class="top-pannel">  
          <div class="search-box">
            <label class="form-title">등록일</label>
            <!-- 데이트피커 범위 -->
            <!-- <input type="text" class="form-control" name="dates" value=" "> -->
            <!-- 데이트피커 싱글 -->
            <input type="date" class="form-control" name="start_dt" id="start_date"  value="">
            <span> ~ </span>
            <input type="date" class="form-control" name="end_dt" id="end_date"  value=""> 
          <button type="button" class="btn btn-outline-dark btn-md" onclick="javascript:selectToday();">오늘</button>
          <button type="button" class="btn btn-outline-dark btn-md" onclick="javascript:selectWeek();">최근 일주일</button>
          <button type="button" class="btn btn-outline-dark btn-md" onclick="javascript:selectMonth();">최근 한달</button>            
          </div> 
          <h2>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp</h2>
          <div class="search-box">
            <label for="search" class="form-title" onclick="">검색구분</label>
           	  <select class="form-select w-10" name="searchGb" id="searchGb">
                <option value="A">전체</option> 
       			<option value="T">제목</option>
                <option value="C">내용</option>
              </select> 
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
                <button class="btn btn-outline-dark btn-sm" onclick="fnsave('U');">수정</button>
                <button class="btn btn-primary btn-sm"  onclick="fnsave('I');">입력</button>
              </div>
            </header>
            <div class="main-content">
              <!-- 테이블 샘플 -->
              <div class="table-responsive">
                <table id="infoTable" class="table table-bordered">
                  <colgroup>
                  	<col style="width: 30px">
                  	<col style="width: 50px">
                    <col style="width: 150px">
                    <col style="width: 300px">
                    <col style="width: 50px">
                    <col style="width: 100px">
                    <col style="width: 50px">
                    <col style="width: 50px">
                    <col style="width: 50px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th>번호</th>
                      <th>공지구분</th>
                      <th>제 목</th>
                      <th>공지내용</th>
                      <th>시작일</th>
                      <th>종료일</th>
                      <th>등록자</th>
                      <th>요양기관</th>
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
  <div class="modal fade" id="adminModal" tabindex="-1" aria-labelledby="adminlNoticeLabel" aria-hidden="true">
    <!-- 모달 class명으로 사이즈 조절 modal-320, 410, 520, 650, 820 -->
    <div class="modal-dialog  modal-820">
      <div class="modal-content">
        <div class="modal-footer">
          <button type="button" class="btn btn-primary btn-sm"  onclick="fnSaveProc();">저장</button>
          <button type="button" class="btn btn-outline-dark btn-sm" data-bs-dismiss="modal" onclick="modalClose();">목록</button>
        </div>
         <form:form commandName="DTO"  id="regForm" name="regForm" method="post" enctype="multipart/form-data">
           <input type="hidden" name="iud" id="iud"/> 
           <input type="hidden" name="noti_seq" id="noti_seq"/> 
           <input type="hidden" name="hosp_uuid" id="hosp_uuid" value = "${sessionScope['q_uuid']}" />
           <input type="hidden" name="upd_user" id="upd_user" value = "1111"/> <!-- value="${sessionScope['q_user_id']}" /> -->
        <div class="modal-body">
           <div class="form-wrap w-50">
	           <label for="">공지구분</label> 
	            <select class="form-select" name="file_gb" id="file_gb"> <!-- readonly -->
	                <option value="">선택</option> 
	                <c:forEach var="result" items="${commList}" varStatus="status">
	                   <option value="${result.sub_code}">${result.sub_code_nm}</option>
	                </c:forEach> 
	           </select>
           </div>
          <div class="form-container"> 
            <div class="form-wrap w-100">
              <label for="" class="critical" style="left">제목</label>
              <input type="text" name="noti_title" id="noti_title" class="form-control" placeholder="제목을 입력하세요." >
            </div>
            <div class="form-wrap w-100">
              <label for="" class="critical" style="left">내용</label>
              <textarea class="form-control" aria-label="With textarea" placeholder="공지내용을 입력하세요." 
                                      name="noti_content" id="noti_content"></textarea>              
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical" style="left">공지시작일</label>
              <input type="text" name="start_dt" id="start_dt" class="form-control"> 
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">공지종료일</label>
              <input type="text" name="end_dt" id="end_dt" class="form-control" value="">
            </div>
            <div class="form-wrap w-50">
              <label for=""class="critical">사용여부</label>
       		  <select class="form-select" name="use_yn" id="use_yn">
                <option value="">선택</option> 
                <option value="Y">Y</option>
                <option value="N">N</option>
              </select> 
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">요양기관</label>
              <input type="text" name="hosp_cd" id="hosp_cd" class="form-control" value="">
            </div>   
          
             <div class="form-wrap w-100">
              <label for="" class="critical">파일업로드</label>
	            <div class="btn-box">
	                <button class="btn btn-primary btn-sm"  onclick="openFileInput(event)">파일 선택</button>
	            </div>
				<div id="drag-area">
				  <p>파일을 여기에 드래그 하세요.</p>
				  <input type="file" id="file-input" multiple style="display: none;">
				  <div id="file-list" class="file-list-container"></div>
				</div>
			</div> 	
	  </form:form>
      </div>
    </div>
  </div>
</body>
</html>