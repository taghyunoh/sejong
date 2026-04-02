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
<!-- 달력(일자, 월별) 사용시 추가 필요함 -->  
<script src="/js/main.js"></script>
<script type="text/javaScript"> 

var adminNoticeModal = new bootstrap.Modal(document.getElementById('adminModal'));
var uidGubun = "" ;
function fnSearch() {

	$("#infoTable tr").attr("class", ""); 
	
	document.getElementById("regForm").reset();
	 
	$("#dataArea").empty();
	$.ajax({
   	url : CommonUtil.getContextPath() + '/admin/asqList.do',
    type : 'post',
    data : {searchText : $("#searchText").val()},
	dataType : "json",
   	success : function(data) {
   		if(data.error_code != "0") return;
   		if(data.resultCnt > 0 ){
    		var dataTxt = "";
    		for(var i=0 ; i < data.resultCnt; i++){

    			dataTxt = '<tr  class="" onclick="javascript:fnDtlSearch(\''+data.resultLst[i].asqSeq+'\');" id="row_'+data.resultLst[i].asqSeq+'">';
 				dataTxt += 	"<td>" + (i+1)  + "</td>" ;
 				dataTxt += "<td>" + data.resultLst[i].userNm + "</td>";
 				dataTxt += "<td class='txt-left ellips'>" + truncateText(data.resultLst[i].qstnConts, 50) + "</td>";
 				dataTxt += "<td class='txt-left ellips'>" + truncateText(data.resultLst[i].ansrConts, 50) + "</td>"; 
				dataTxt +=  "<td>" + data.resultLst[i].ansrYn        + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].qstnYmd       + "</td>" ;
				dataTxt +=  "</tr>";
	            $("#dataArea").append(dataTxt);
        	 }
	 	  }else{
			  $("#dataArea").append("<tr><td colspan='12'>검색된 정보가 없습니다.</td></tr>");
		  }
      }
   });

}

function truncateText(text, length) {
    if (!text) return "";
    return text.length > length ? text.substring(0, length) + "..." : text;
}


function fnDtlSearch(data){ 
	if(data == '' || data == null) return;
	 
	document.regForm.asqSeq.value = data ; 
	
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
		$("#ansrYn").val("Y");
		
		modalOpen() ;
	
	}else if(iud == "U" || iud == "D" ){
		if($("#asqSeq").val() == ""){
			alert("선택된  정보가 없습니다.!");
			modalClose() ;
			return;
		}
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/admin/asqInfo.do",
			data : {asqSeq : $("#asqSeq").val()},
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				$("#qstnTitl").val(data.result.qstnTitl);
				$("#qstnConts").val(data.result.qstnConts);
				$("#ansrConts").val(data.result.ansrConts);
				$("#ansrYn").val(data.result.ansrYn);
			}
		});
	} else if(iud == "D"){
		fnSaveProc();
	}	
	modalOpen() ;
}
function fnSaveProc(){
	//if(!fnRequired('qstnTitl',  '질문제목을 확인 하세요.'))     return;
	if(!fnRequired('qstnConts', '질문내용을  확인하세요.'))    return;
	if(!fnRequired('ansrConts', '답변내용을  확인하세요.'))    return;
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
			url : CommonUtil.getContextPath() + "/admin/asqSaveProc.do",
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

$(document).ready(function() {
    fnSearch(); // 페이지 로드 시 실행
});

</script>
</head>
<body>  
      <div class="tab-pane">  
      <div class="content-body">
		<div class="tab-content">
		<div class="content-wrap">
		<div class="flex-left-right mb-10">
			<div class="patient-info">
				<div class="info-name">질의목록</div>
			</div>
		</div>
        <section class="top-pannel">  
          <div class="search-box">
            <label for="search" class="form-title"  onclick="">검색구분</label>
            <input type="text" name="searchText" id="searchText" class="form-control search" placeholder="검색어를 입력하세요." 
                                                                      onkeypress="if( event.keyCode == 13 ){fnSearch();}">
            <button class="buttcon" onclick="javascript:fnSearch();"><span class="icon icon-search" ></span></button>
 
          </div> 
        </section>
        <section class="main-pannel">
          <div class="main-left w-100">
            <header class="main-hd">
              <h2></h2>
              <div class="btn-box">
                <button class="btn btn-outline-dark btn-sm" onclick="fnsave('U');">답변등록</button>
              </div>
            </header>
           
            <div class="main-content">
              <!-- 테이블 샘플 -->
              <div class="container text-center">
              <div class="table-responsive">
                <table id="infoTable" class="table table-bordered" >
                  <colgroup>
                  	<col style="width: 30px">
                  	<col style="width: 100px">
                    <col style="width: 200px">
                    <col style="width: 250px">
                    <col style="width: 100px">
                    <col style="width: 50px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th>번호</th>
                      <th>질문자</th>
                      <th>질문내용</th>
                      <th>답변내용</th>
                      <th>사용여부</th>
                      <th>등록일</th>
                    </tr>
                  </thead>
                  <tbody id="dataArea"> 
        			<tr>
        				<td colspan="7">&nbsp;</td>
        			</tr>
                  </tbody>
                </table>
              </div>
            </div>
              </div>
          </div>
        </section>
      </div>
     </div>
    </div>
  <!-- 모달 -->
  <div class="modal fade" id="adminModal" tabindex="-1" aria-labelledby="adminLFaqLabel" aria-hidden="true">
    <!-- 모달 class명으로 사이즈 조절 modal-320, 410, 520, 650, 820 -->
    <div class="modal-dialog  modal-820">
      <div class="modal-content">
        <div class="modal-footer">
          <button type="button" class="btn btn-primary btn-sm"  onclick="fnSaveProc();">저장</button>
          <button type="button" class="btn btn-outline-dark btn-sm" data-bs-dismiss="modal" onclick="modalClose();">목록</button>
        </div>
         <form:form commandName="DTO"  id="regForm" name="regForm" method="post">
           <input type="hidden" name="iud" id="iud"/> 
           <input type="hidden" name="asqSeq"   id="asqSeq"/> 
           <input type="hidden" name="userUuid" id="userUuid"/> 
        <div class="modal-body">
          <div class="form-container"> 
      
            <div class="form-wrap w-100">
              <label for="" class="critical" style="left">질문내용</label>
              <textarea class="form-control" aria-label="With textarea" placeholder="질문내용을 입력하세요." readonly  
                                                          name="qstnConts" id="qstnConts" style="height: 220px;"></textarea>              
            </div>
            <div class="form-wrap w-100">
              <label for="" class="critical" style="left">답변내용</label>
              <textarea class="form-control" aria-label="With textarea" placeholder="답변내용을 입력하세요." name="ansrConts" id="ansrConts"></textarea>              
            </div>
            <div class="form-wrap w-50">
              <label for=""class="critical">사용여부</label>
       		  <select class="form-select" name="ansrYn" id="ansrYn">
                <option value="Y">Y</option>
                <option value="N">N</option>
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
