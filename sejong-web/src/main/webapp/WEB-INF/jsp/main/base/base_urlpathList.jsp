<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>  
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>  
<%@ page import = "java.util.*" %>
<style>
</style> 
<html>
<head>  
<!-- 스크립트 -->
<!-- 달력(일자, 월별) 사용시 추가 필요함 -->  
<script src="/js/main.js"></script>
<script type="text/javaScript"> 
var adminModal = new bootstrap.Modal(document.getElementById('adminModal'));
function fnSearch() {
	 $("#infoTable tr").attr("class", ""); 
	 document.getElementById("regForm").reset();
	 $("#dataArea").empty();
//	 	if($('#searchText').val() == "") {
//		alert("검색어를 입력하세요.");
//		$('#searchText').focus();
//		return; 
//	 }
	$.ajax({
	   	url : CommonUtil.getContextPath() + '/base/ctl_urlpathList.do',
	    type : 'post',
	    data: {hosp_uuid : $("#hosp_uuid").val() , url_path: $("#searchText").val() },
	   	dataType : "json",
	   	success : function(data) {
	   		if(data.error_code != "0") return;
	   		if(data.resultCnt > 0 ){
	    		var dataTxt = "";
	    		for(var i=0 ; i < data.resultCnt; i++){
	    			dataTxt = '<tr class="" onclick="javascript:fnDtlSearch(\'' 
    				    + data.resultLst[i].hosp_uuid + '\', \''
    		            + data.resultLst[i].url_path   + '\', \''
    		            + data.resultLst[i].start_dt    + '\');" id="row_'
    		            + data.resultLst[i].hosp_uuid 
    		            + data.resultLst[i].url_path 
    		            + data.resultLst[i].start_dt + '">';
	        
					dataTxt += 	"<td>" + (i+1)  + "</td>" ; 
					dataTxt +=  "<td>" + data.resultLst[i].hosp_cd   + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].url_path   + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].sub_code_nm  + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].start_dt  + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].end_dt    + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].user_nm   + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].use_yn    + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].upd_user  + "</td>" ;
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
function fnDtlSearch(hosp_uuid ,url_path , start_dt){ 
	if (!hosp_uuid || !url_path || !start_dt) return;
	document.regForm.iud.value  = "U";
	document.regForm.hosp_uuid.value  = hosp_uuid ; 
	document.regForm.url_path.value   = url_path ; 
	document.regForm.start_dt.value   = start_dt ; 
	
    $("#infoTable tr").removeClass("tr-primary");
    $("#infoTable #row_" + hosp_uuid + url_path + start_dt).addClass("tr-primary");
}
//입력,수정 , 비밀번호 초기화  버큰 클릭시
function fnSave(iud){
	$("#iud").val(iud);  // 입력(I), 수정(U), 삭제(D) 
	uidGubun = iud ;
	if(iud == "I"){
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
		$("#url_path").css("pointer-events", "auto").css("background-color", ""); // 콤보박스 활성화 
		$("#hosp_cd").prop("readonly",true);
		document.getElementById("regForm").reset();
		setCurrDate("start_dt");
		$("#end_dt").val("2099-12-31");
		$("#start_dt").prop("readonly","");
		$("#end_dt").prop("readonly","");
		modalOpen();
		
	}else if(iud == "U"){
		if ($("#hosp_uuid").val() == "" || $("#url_path").val() == "" ){
			alert("선택된  정보가 없습니다.!");
			return;
		}
		modalClose() ;
		
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/base/selecturlpathInfo.do",
			data : {hosp_uuid: $("#hosp_uuid").val() , 
				    url_path : $("#url_path").val(), 
				    start_dt : $("#start_dt").val() },
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				$("#hosp_cd").val(data.result.hosp_cd);
				$("#hosp_uuid").val(data.result.hosp_uuid);
				$("#url_path").val(data.result.url_path);
				$("#use_yn").val(data.result.use_yn);
				$("#bigo").val(data.result.bigo);
				$("#upt_user").val(data.result.upt_user);
				$("#upt_dttm").val(data.result.upt_dttm);
				$("#start_dt").val(data.result.start_dt);
				$("#end_dt").val(data.result.end_dt);
				$("#url_path").css("pointer-events", "none").css("background-color", "#e9ecef"); // 콤보박스 비활성화 
				$("#start_dt").prop("readonly",true);
				$("#hosp_cd").prop("readonly",true);
				$("#end_dt").prop("readonly",true);
			}
		});
		modalOpen();
	}else
		return;
	}
function fnSaveProc(){
	if(!fnRequired('url_path', '프로그램 경로를 확인하세요.'))  return;
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
		$.ajax({
			type : "post" ,                       
			url : CommonUtil.getContextPath() + "/base/urlpathSaveAct.do",
			data : formData,
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
		        fnSearch();
		        modalClose() ;
		    },
		    error: function(xhr, status, error) {
		      console.error("Error:", error);
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
    if (window.adminModalInstance) {
        window.adminModalInstance.hide();  // 모달 닫기
    }	
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
					<div class="info-name">사용자 프로그램 목록</div>
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
           <!--    <h2>&nbsp 사용자 목록</h2> 원래  -->
              <h2> </h2>
              <div class="btn-box"> 
                <button class="btn btn-outline-dark btn-sm" onclick="fnSave('U');">수정</button>
                <button class="btn btn-primary btn-sm" onclick="fnSave('I');" >입력</button>
              </div>
            </header>
            <div class="main-content">
              <!-- 테이블 샘플 -->
              <div class="table-responsive">
                <table  class="table table-bordered"  id="infoTable">
                  <colgroup>
                  	<col style="width: 50px">
                    <col style="width: 100px">
                    <col style="width: 200px">
                    <col style="width: 300px">
                    <col style="width: 200px">
                    <col style="width: 200px">
                    <col style="width: 100px">
                    <col style="width: 50px">
                    <col style="width: 100px">
                    <col style="width: 100px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th>번호</th>
                      <th>요양기관명</th>
                      <th>프로그램경로</th>
                      <th>프로그램명</th>
                      <th>시작일자</th>
                      <th>종료일자</th>
                      <th>사용자명</th>
                      <th>사용여부</th>
                      <th>등록자</th>
                      <th>등록일자</th>
                    </tr>
                  </thead>
                  <tbody id="dataArea"> 
        			<tr>
        				<td colspan="10">&nbsp;</td>
        			</tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div> 
        </section>
        </div> 
      </div>
   <!--   원래 밑에 없음  -->  
   </div>
   </div>       
  <!-- 모달 -->
  <div class="modal fade" id="adminModal" tabindex="-1" aria-labelledby="adminModalLabel" aria-hidden="true">
    <!-- 모달 class명으로 사이즈 조절 modal-320, 410, 520, 650, 820 -->
    <div class="modal-dialog  modal-820">
       
      <div class="modal-content">
        <div class="modal-footer">
          <button type="button" class="btn btn-primary btn-sm"  onclick="fnSaveProc();">저장</button>
          <button type="button" class="btn btn-outline-dark btn-sm" data-bs-dismiss="modal" onclick="modalClose();">목록</button>
        </div>
    		<form:form commandName="DTO" id="regForm" name="regForm" method="post"> 
              <input type="hidden" name="iud" id="iud" />
              <input type="hidden" name="upd_user" id="upd_user" value = "1111"/>
              <input type="hidden" name="hosp_uuid" id="hosp_uuid" value = "${sessionScope['q_uuid']}" />
        <div class="modal-body">
          <div class="form-container"> 
            <div class="form-wrap w-50">
              <label for="" class="critical">요양기관</label>
              <input type="text" name="hosp_cd" id="hosp_cd" class="form-control" placeholder="요양기관를 입력하세요.">
            </div>
        
           <div class="form-wrap w-100">
	           <label for="">프로그램목록</label> 
	            <select class="form-select" name="url_path" id="url_path"> <!-- readonly -->
	                <option value="">선택</option> 
	                <c:forEach var="result" items="${commList}" varStatus="status">
	                   <option value="${result.sub_code}">${result.sub_code_nm}</option>
	                </c:forEach> 
	           </select>
           </div>  
          
            <div class="form-wrap w-50">
              <label for="" class="critical">시작일</label>
              <input type="text" name="start_dt" id="start_dt" class="form-control" placeholder="시작일를 입력하세요.">
            </div>    
            <div class="form-wrap w-50">
              <label for="" class="critical">종료일</label>
              <input type="text" name="end_dt" id="end_dt" class="form-control" placeholder="종료일를 입력하세요.">
            </div>    
            <div class="form-wrap w-100">
              <label for="" class="critical">비고</label>
              <input type="text" name="bigo" id="bigo" class="form-control" placeholder="비고사항를 입력하세요.">
            </div>
            <div class="form-wrap w-50">
	              <label for=""class="critical">사용여부</label>
	       		  <select class="form-select" name="use_yn" id="use_yn">
	                <option value="">선택</option> 
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
