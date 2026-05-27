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

	$.ajax({
   	url : CommonUtil.getContextPath() + '/admin/selectAuserList.do',
    type : 'post',
    data : {userNm : $("#searchText").val()},
   	dataType : "json",
   	success : function(data) {
   		if(data.error_code != "0") return;
   		if(data.resultCnt > 0 ){
    		var dataTxt = "";
    		for(var i=0 ; i < data.resultCnt; i++){
    			var depnmText = "";
	    		if (data.resultLst[i].userGb == "D"){
	    			depnmText = "의사";
	    	    } else if(data.resultLst[i].userGb == "A") {
	    	    	depnmText = "관리자";
	    	    }
    			dataTxt = '<tr class="" onclick="javascript:fnDtlSearch(\''
    		               + data.resultLst[i].userId.replace(/'/g, "\\'")
    		               + '\');" id="row_' + data.resultLst[i].userId + '">';
				dataTxt += 	"<td>" + (i+1)  + "</td>" ;
				dataTxt +=  "<td style='display: none;'>" + data.resultLst[i].userId  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].userIdNm  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].userNm  + "</td>" ;
				dataTxt +=  "<td>" + depnmText   + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].deptNm  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].startDate  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].endDate  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].useYn  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].lockYn  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].regDtm.substring(0,10)  + "</td>" ;
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
	document.regForm.userId.value = data ;

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
		$("#userId").prop("readonly","");
		document.getElementById("regForm").reset();
		setCurrDate("startDate");
		$("#userGb").val("D");
		$("#endDate").val("2099-12-31");
		$("#lockYn").val("N");
		$("#useYn").val("Y");
		modalOpen();
	}else if(iud == "U"){
		if($("#userId").val() == ""){
			alert("선택된  정보가 없습니다.!");
			modalClose() ;
			return;

		}
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/admin/AuserInfo.do",
			data : {userId : $("#userId").val()},
			dataType : "json",
			success : function(data) {
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				$("#userId").val(data.result.userId);
				$("#userNm").val(data.result.userNm);
				$("#userIdNm").val(data.result.userIdNm);
				$("#deptNm").val(data.result.deptNm);
				$("#userGb").val(data.result.userGb);
				$("#regDtm").val(data.result.regDtm);
				$("#startDate").val(data.result.startDate);
				$("#endDate").val(data.result.endDate);
				$("#lockYn").val(data.result.lockYn);
				$("#useYn").val(data.result.useYn);
				$("#bigo").val(data.result.bigo);
				$("#userId").prop("readonly","true");
			}
		});
		modalOpen();
	}else
		return;
	}
function fnSaveProc(){
	if(!fnRequired('userIdNm', '아이디를  확인하세요.'))  return;
	if(!fnRequired('userNm', '성명을 확인 하세요.'))   return;
	if($("#userPw").val() == ""){
		alert("비밀번호를 입력하세요.!");
		document.getElementById("userPw").focus();
		return;
	}
	if($("#afAuserPwd").val() == ""){
		alert("비밀번호를 입력하세요.!");
		document.getElementById("afAuserPwd").focus();
		return;
	}
	var formData = $("form[name='regForm']").serialize();
	var msg = "" ;
	if (uidGubun == "U"){
		msg = "수정 하시겠습니다?" ;
	}else if (uidGubun == "D"){
		msg = "삭제 하시겠습니다?" ;
	}else{
		if ( $("#userPw").val() != $("#afAuserPwd").val() ){
			alert("비빌번호가 상호 상이합니다  .!");
			document.getElementById("afAuserPwd").focus();
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
    var condition = true;
    var adminModal = document.getElementById('adminModal');

    if (adminModal && condition) {
        if (window.adminModalInstance) {
            window.adminModalInstance.dispose();
        }

        window.adminModalInstance = new bootstrap.Modal(adminModal);
        window.adminModalInstance.show();
    } else {
        console.log("조건이 맞지 않아 모달을 열지 않습니다.");
    }
}
function modalClose(){
    if (window.adminModalInstance) {
        window.adminModalInstance.hide();
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
            <input type="text" name="searchText" id="searchText" class="form-control search" placeholder="환자명 또는 전화번호를 입력하세요." onkeypress="if( event.keyCode == 13 ){fnSearch();}">
            <button class="buttcon" onclick="javascript:fnSearch();"><span class="icon icon-search" ></span></button>
          </div>
        </section>

        <section class="main-pannel">
          <div class="main-left w-100">
            <header class="main-hd">
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
   </div>
  <!-- 모달 -->
  <div class="modal fade" id="adminModal" tabindex="-1" aria-labelledby="adminModalLabel" aria-hidden="true">
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
              <input type="text" name="userIdNm" id="userIdNm" class="form-control" placeholder="아이디를 입력하세요.">
              <input type="hidden" name="userId" id="userId" />
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">사용자명</label>
              <input type="text" name="userNm" id="userNm" class="form-control" placeholder="사용자 명을 입력하세요.">
            </div>

            <div class="form-wrap w-50">
              <label for=""class="critical">사용자 구분</label>
       		  <select class="form-select" name="userGb" id="userGb">
                <option value="">선택</option>
                <option value="D">D.의사</option>
                <option value="A">A.관리자</option>
              </select>
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">진료과명</label>
              <input type="text" name="deptNm" id="deptNm" class="form-control" placeholder="진료과명을  입력하세요.">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">시작일</label>
              <input type="date" name="startDate" id="startDate" class="form-control" placeholder="시작일를  입력하세요.">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">종료일</label>
              <input type="date" name="endDate" id="endDate" class="form-control" placeholder="종료일를  입력하세요.">
            </div>
            <div class="form-wrap w-50">
              <label for=""class="critical">lock여부</label>
       		  <select class="form-select" name="lockYn" id="lockYn">
                <option value="">선택</option>
                <option value="Y">Y.봉인</option>
                <option value="N">N.해체</option>
              </select>
            </div>
            <div class="form-wrap w-50">
              <label for=""class="critical">사용여부</label>
       		  <select class="form-select" name="useYn" id="useYn">
                <option value="">선택</option>
                <option value="Y">Y.사용</option>
                <option value="N">N.미사용</option>
              </select>
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">비밀번호</label>
              <input type="password" name="userPw" id="userPw" class="form-control" placeholder="비밀번호를 입력하세요.">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">비밀번호 확인</label>
              <input type="password" name="afAuserPwd" id="afAuserPwd" class="form-control" placeholder="비밀번호를 재입력하세요.">
            </div>
          </div>
        </div>
        </form:form>
      </div>

    </div>
  </div>
</body>
</html>
