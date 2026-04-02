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
   	url : CommonUtil.getContextPath() + '/admin/selectAuserList.do',
    type : 'post',
    data : {user_nm : $("#searchText").val()},
   	dataType : "json",
   	success : function(data) {
   		if(data.error_code != "0") return;
   		if(data.resultCnt > 0 ){
    		var dataTxt = "";
    		for(var i=0 ; i < data.resultCnt; i++){
    			var depnmText = "";
	    		if (data.resultLst[i].user_gb == "D"){
	    			depnmText = "의사";
	    	    } else if(data.resultLst[i].user_gb == "A") {
	    	    	depnmText = "관리자";
	    	    } 
    			dataTxt = '<tr class="" onclick="javascript:fnDtlSearch(\'' 
    		               + data.resultLst[i].user_id.replace(/'/g, "\\'") 
    		               + '\');" id="row_' + data.resultLst[i].user_id + '">'; 
				dataTxt += 	"<td>" + (i+1)  + "</td>" ; 
				dataTxt +=  "<td style='display: none;'>" + data.resultLst[i].user_id  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].user_id_nm  + "</td>" ; 
				dataTxt +=  "<td>" + data.resultLst[i].user_nm  + "</td>" ;
				dataTxt +=  "<td>" + depnmText   + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].dept_nm  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].start_date  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].end_date  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].useyn  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].lock_yn  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].reg_dtm.substring(0,10)  + "</td>" ;
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
	 
	document.regForm.iud.value  = "U";
	document.regForm.user_id.value = data ; 
	
	//row 클릭시 바탕색 변경 처리 Start 
	$("#infoTable #"+data).attr("checked", true);
	$("#infoTable tr").attr("class", ""); 
	$("#infoTable #row_"+data).attr("class", "tr-primary");
}
//입력,수정 , 비밀번호 초기화  버큰 클릭시
function fnSave(iud){
	$("#iud").val(iud);  // 입력(I), 수정(U), 삭제(D) 
	uidGubun = iud ;	
	if(iud == "I"){
		//등록폼 초기화
		$("#user_id").prop("readonly","");
		document.getElementById("regForm").reset();
		setCurrDate("start_date");
		$("#user_gb").val("D");
		$("#end_date").val("2099-12-31");
		$("#lock_yn").val("N");
		$("#useyn").val("Y");
		modalOpen();
	}else if(iud == "U"){
		if($("#user_id").val() == ""){
			alert("선택된  정보가 없습니다.!");
			modalClose() ;
			return;

		}
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/admin/AuserInfo.do",
			data : {user_id : $("#user_id").val()},
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				$("#user_id").val(data.result.user_id);
				$("#user_nm").val(data.result.user_nm);
				$("#user_id_nm").val(data.result.user_id_nm);
				$("#dept_nm").val(data.result.dept_nm);
				$("#user_gb").val(data.result.user_gb);
				$("#reg_dtm").val(data.result.reg_dtm);
				$("#start_date").val(data.result.start_date);
				$("#end_date").val(data.result.end_date);
				$("#lock_yn").val(data.result.lock_yn);
				$("#useyn").val(data.result.useyn);
				$("#bigo").val(data.result.bigo);
				$("#user_id").prop("readonly","true");
			}
		});
		modalOpen();
	}else
		return;
	}
function fnSaveProc(){
	if(!fnRequired('user_id_nm', '아이디를  확인하세요.'))  return;
	if(!fnRequired('user_nm', '성명을 확인 하세요.'))   return;
	if($("#user_pw").val() == ""){
		alert("비밀번호를 입력하세요.!");
		document.getElementById("user_pw").focus();
		return;
	}
	if($("#af_auser_pwd").val() == ""){
		alert("비밀번호를 입력하세요.!");
		document.getElementById("af_auser_pwd").focus();
		return;
	}
	var formData = $("form[name='regForm']").serialize();
	var msg = "" ;
	if (uidGubun == "U"){
		msg = "수정 하시겠습니다?" ;
	}else if (uidGubun == "D"){
		msg = "삭제 하시겠습니다?" ;
	}else{
		if ( $("#user_pw").val() != $("#af_auser_pwd").val() ){
			alert("비빌번호가 상호 상이합니다  .!");
			document.getElementById("af_auser_pwd").focus();
			return;			
		}
		msg = "입력 하시겠습니다?" ;
	}
	if(confirm(""+ msg)) {
		$.ajax( {
			type : "post" ,
			url : CommonUtil.getContextPath() + "/admin/AuserSaveAct.do",
			data : formData,
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
		        fnSearch();
		        modalClose()
      
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
 //   $('#adminModal').modal('hide'); // 모달 닫기
 //   추가적인 인스턴스 호출이 필요하다면 확인 후 사용
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
					<div class="info-name">사용자 목록</div>
				</div>
			</div>
        <section class="top-pannel">  
          <div class="search-box">
            <label for="search" class="form-title" onclick="">검색어 입력</label>
            <input type="text" name="searchText" id="searchText" class="form-control search" placeholder="환자명 또는 전화번호를 입력하세요." onkeypress="if( event.keyCode == 13 ){fnSearch();}">
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
                <table id="infoTable" class="table table-bordered">
                  <colgroup>
                  	<col style="width: 50px">
                    <col style="width: 100px">
                    <col style="width: 200px">
                    <col style="width: 200px">
                    <col style="width: 200px">
                    <col style="width: 200px">
                    <col style="width: 100px">
                    <col style="width: 100px">
                    <col style="width: 100px">
                    <col style="width: 20px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th>번호</th>
                      <th>아이디</th>
                      <th>성명</th>
                      <th>구분</th>
                      <th>진료과</th>
                      <th>시작일</th>
                      <th>종료일</th>
                      <th>사용여부</th>
                      <th>lock여부</th>
                      <th>등록일</th>
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
        <div class="modal-body">
          <div class="form-container"> 
            <div class="form-wrap w-50">
              <label for="" class="critical">아이디</label>
              <input type="text" name="user_id_nm" id="user_id_nm" class="form-control" placeholder="아이디를 입력하세요.">
              <input type="hidden" name="user_id" id="user_id" />
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">사용자명</label>
              <input type="text" name="user_nm" id="user_nm" class="form-control" placeholder="사용자 명을 입력하세요.">
            </div>
            
            <div class="form-wrap w-50">
              <label for=""class="critical">사용자 구분</label>
       		  <select class="form-select" name="user_gb" id="user_gb">
                <option value="">선택</option> 
                <option value="D">D.의사</option>
                <option value="A">A.관리자</option>
              </select> 
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">진료과명</label>
              <input type="text" name="dept_nm" id="dept_nm" class="form-control" placeholder="진료과명을  입력하세요.">
            </div>     
            <div class="form-wrap w-50">
              <label for="" class="critical">시작일</label>
              <input type="date" name="start_date" id="start_date" class="form-control" placeholder="시작일를  입력하세요.">
            </div>    
            <div class="form-wrap w-50">
              <label for="" class="critical">종료일</label>
              <input type="date" name="end_date" id="end_date" class="form-control" placeholder="종료일를  입력하세요.">
            </div>    
            <div class="form-wrap w-50">
              <label for=""class="critical">lock여부</label>
       		  <select class="form-select" name="lock_yn" id="lock_yn">
                <option value="">선택</option> 
                <option value="Y">Y.봉인</option>
                <option value="N">N.해체</option>
              </select> 
            </div> 
            <div class="form-wrap w-50">
              <label for=""class="critical">사용여부</label>
       		  <select class="form-select" name="useyn" id="useyn">
                <option value="">선택</option> 
                <option value="Y">Y.사용</option>
                <option value="N">N.미사용</option>
              </select> 
            </div>                                      
            <div class="form-wrap w-50">
              <label for="" class="critical">비밀번호</label>
              <input type="password" name="user_pw" id="user_pw" class="form-control" placeholder="비밀번호를 입력하세요.">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">비밀번호 확인</label>
              <input type="password" name="af_auser_pwd" id="af_auser_pwd" class="form-control" placeholder="비밀번호를 재입력하세요.">
            </div>
          </div> 
        </div>
        </form:form>
      </div>
      
    </div>
  </div>
</body>
</html>
