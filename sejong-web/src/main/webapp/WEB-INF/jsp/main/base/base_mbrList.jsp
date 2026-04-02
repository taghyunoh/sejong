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
   	url : CommonUtil.getContextPath() + '/base/ctl_mbrList.do',
    type : 'post',
    data: { hosp_cd: $("#searchText").val() },
   	dataType : "json",
   	success : function(data) {
   		if(data.error_code != "0") return;
   		if(data.resultCnt > 0 ){
    		var dataTxt = "";
    		for(var i=0 ; i < data.resultCnt; i++){
    			dataTxt = '<tr class="" onclick="javascript:fnDtlSearch(\'' 
					        +data.resultLst[i].hosp_cd +'\',\''+data.resultLst[i].email +'\');" id="row_'
			                +data.resultLst[i].hosp_cd + data.resultLst[i].email+'">';
        
				dataTxt += 	"<td>" + (i+1)  + "</td>" ; 
				dataTxt +=  "<td>" + data.resultLst[i].hosp_cd  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].hosp_nm  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].mbr_nm  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].mbr_tel  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].email    + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].per_use_nm  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].per_info_nm  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].per_pro_nm  + "</td>" ;
				dataTxt += "<td>"  + data.resultLst[i].use_yn+"</td>";
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
function fnDtlSearch(hosp_cd ,email ){ 
	if (!hosp_cd || !email ) return;
	document.regForm.iud.value  = "U";
	document.regForm.hosp_cd.value  = hosp_cd ; 
	document.regForm.email.value    = email ; 
	
    $("#infoTable tr").removeClass("tr-primary");
    $("#infoTable #row_" + hosp_cd + email).addClass("tr-primary");   
}
//입력,수정 , 비밀번호 초기화  버큰 클릭시
function fnSave(iud){
	$("#iud").val(iud);  // 입력(I), 수정(U), 삭제(D) 
	uidGubun = iud ;
	if(iud == "I"){
		//등록폼 초기화
		$("#hosp_cd").prop("readonly","");
		$("#email").prop("readonly","");
		document.getElementById("regForm").reset();
		modalOpen();
		
	}else if(iud == "U"){
		if ($("#hosp_cd").val() == "" || $("#email").val() == "" ){
			alert("선택된  정보가 없습니다.!");
			modalClose() ;
			return;
		}
		
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/base/selectMbrInfo.do",
			data : {hosp_cd: $("#hosp_cd").val() , email : $("#email").val()},
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				$("#hosp_cd").val(data.result.hosp_cd);
				$("#hosp_nm").val(data.result.hosp_nm);
				$("#email").val(data.result.email);
				$("#mbr_nm").val(data.result.mbr_nm);
				$("#mbr_tel").val(data.result.mbr_tel);
				$("#upd_dttm").val(data.result.upd_dttm);
				if (data.result.use_yn == "Y") {
					$("#use_yn").prop("checked", true);
				} else {
					$("#use_yn").prop("checked", false);
				}
				$("#user_id").val(data.result.user_id);
				$("#hosp_cd").prop("readonly","true");
				$("#hosp_nm").prop("readonly","true");
				$("#email").prop("readonly","true");
				$("#mbr_nm").prop("readonly","true");
				$("#mbr_tel").prop("readonly","true");
			}
		});
		modalOpen();
	}else
		return;
	}
function fnSaveProc(){
	if(!fnRequired('hosp_cd', '요양기관를  확인하세요.'))  return;
	if(!fnRequired('hosp_nm', '요양기관명을 확인 하세요.'))   return;
	if ($("#use_yn").prop('checked')) {
	    $("#use_yn").val("Y");  // 체크박스가 체크되었을 때, value 값을 "Y"로 설정
	} else {
	    $("#use_yn").val("");  // 체크박스가 체크되지 않았을 때, value 값을 빈 문자열로 설정
	}
	var formData = $("form[name='regForm']").serialize();
	var msg = "" ;
	if (uidGubun == "U"){
		msg = "수정 하시겠습니다?" ;
	}
	if(confirm(""+ msg)) {
		$.ajax( {
			type : "post" ,                       
			url : CommonUtil.getContextPath() + "/base/MbrSaveAct.do",
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
					<div class="info-name">회원등록 목록</div>
				</div>
			</div>
        <section class="top-pannel">  
          <div class="search-box">
            <label for="search" class="form-title" onclick="">검색어 입력</label>
            <input type="text" name="searchText" id="searchText" class="form-control search" placeholder="아이디 및 사용자명를 입력하세요." 
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
                <table id="infoTable" class="table table-bordered">
                  <colgroup>
                  	<col style="width: 50px">
                    <col style="width: 100px">
                    <col style="width: 200px">
                    <col style="width: 100px">
                    <col style="width: 100px">
                    <col style="width: 100px">
                    <col style="width: 100px">
                    <col style="width: 100px">
                    <col style="width: 100px">
                    <col style="width: 100px"> 
                    <col style="width: 100px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th>번호</th>
                      <th>요양기관</th>
                      <th>요양기관명</th>
                      <th>담당자명</th>
                      <th>담당전화</th>
                      <th>이메이주소</th>
                      <th>이용약관</th>
                      <th>수집이용</th>
                      <th>처리위탁</th>
                      <th>승인여부</th>
                      <th>등록일자</th>
                    </tr>
                  </thead>
                  <tbody id="dataArea"> 
        			<tr>
        				<td colspan="11">&nbsp;</td>
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
              <label for="" class="critical">요양기관</label>
              <input type="text" name="hosp_cd" id="hosp_cd" class="form-control" placeholder="요양기관를 입력하세요.">
            </div>
            <div class="form-wrap w-100">
              <label for="" class="critical">요양기관명</label>
              <input type="text" name="hosp_nm" id="hosp_nm" class="form-control" placeholder="요양기관명을 입력하세요.">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">담당자명</label>
              <input type="text" name="mbr_nm" id="mbr_nm" class="form-control" placeholder="담당자명을 입력하세요.">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">이메일</label>
              <input type="text" name="email" id="email" class="form-control" placeholder="이메일를 입력하세요.">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">담당전화</label>
              <input type="text" name="mbr_tel" id="mbr_tel" class="form-control" placeholder="담당전화번호를 입력하세요.">
            </div>            
            <div class="form-wrap w-50">
              <label for="" class="critical">사용아이디</label>
              <input type="text" name="user_id" id="user_id" class="form-control" placeholder="사용아이디를 입력하세요.">
            </div>  
 			<div class="form-wrap w-50">
				<label for="">사용여부</label>
					<input class="form-check-input" type="checkbox" value="Y"
						name="use_yn" id="use_yn"> <span class="ml-1">사용</span>
			</div>        
          </div> 
        </div>
        </form:form>
      </div>
    </div>
  </div>
</body>
</html>
