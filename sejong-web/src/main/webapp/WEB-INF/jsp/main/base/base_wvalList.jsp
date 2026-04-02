<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>  
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>  
<%@ page import = "java.util.*" %>
<style>
	.table-responsive {
	  max-height: 600px; /* 적당한 높이 설정 (10개 행 기준으로 조정) */
	  overflow-y: auto; /* 수직 스크롤 활성화 */
	  border: 1px solid #ccc; /* 테두리 추가 */
	}
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
   	url : CommonUtil.getContextPath() + '/base/ctl_wvalList.do',
    type : 'post',
    data: {cate_code: $("#searchText").val() },
   	dataType : "json",
   	success : function(data) {
   		if(data.error_code != "0") return;
   		if(data.resultCnt > 0 ){
    		var dataTxt = ""; 
    		for(var i=0 ; i < data.resultCnt; i++){
    			var rateText = "";
    			if (data.resultLst[i].cal_gubun == "1"){
	    			rateText = "점수";
	    	    } else if(data.resultLst[i].cal_gubun == "2") {
	    	    	rateText = "율";
	    	    }
    			dataTxt = '<tr class="" onclick="javascript:fnDtlSearch(\'' 
					        +data.resultLst[i].cate_code +'\',\''+data.resultLst[i].order_seq+'\',\''+data.resultLst[i].start_dt+'\');" id="row_'
			                +data.resultLst[i].cate_code + data.resultLst[i].order_seq + data.resultLst[i].start_dt+'">';
        
				dataTxt += 	"<td>" + (i+1)  + "</td>" ; 
				dataTxt +=  "<td>" + data.resultLst[i].cate_code  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].order_seq  + "</td>" ;
				dataTxt +=  "<td class='txt-left ellips'>" + data.resultLst[i].wevalue_nm  + "</td>" ;
				dataTxt +=  "<td>" + rateText   + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].start_dt  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].start_indi  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].end_indi  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].std_score  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].we_value  + "</td>" ;
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
function fnDtlSearch(cate_code ,order_seq , start_dt){ 
	if (!cate_code || !order_seq || !start_dt) return;
	document.regForm.iud.value  = "U";
	document.regForm.cate_code.value  = cate_code ; 
	document.regForm.order_seq.value  = order_seq ; 
	document.regForm.start_dt.value = formatDate(start_dt) ;
	
    $("#infoTable tr").removeClass("tr-primary");
    $("#infoTable #row_" + cate_code + order_seq + start_dt).addClass("tr-primary");
}
function formatDate(dateString) {
    return dateString.replace(/-/g, '');
}
//입력,수정 , 비밀번호 초기화  버큰 클릭시
function fnSave(iud){
	$("#iud").val(iud);  // 입력(I), 수정(U), 삭제(D) 
	uidGubun = iud ;
	if(iud == "I"){
		//등록폼 초기화
		$("#cate_code").prop("readonly","");
		$("#order_seq").prop("readonly","");
		$("#start_dt").prop("readonly","");
		document.getElementById("regForm").reset();
		setCurrDate("start_dt");
		$("#cal_gubun").val("1");
		$("#end_dt").val("2099-12-31");
		modalOpen();
		
	}else if(iud == "U"){
		if ($("#cate_code").val() == "" || $("#cate_code").val() == "" ){
			alert("선택된  정보가 없습니다.!");
			modalClose() ;
			return;
		}
		
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/base/wvalInfo.do",
			data : {cate_code: $("#cate_code").val() , order_seq : $("#order_seq").val(), start_dt : $("#start_dt").val() },
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				$("#cate_code").val(data.result.cate_code);
				$("#order_seq").val(data.result.order_seq);
				$("#cal_gubun").val(data.result.cal_gubun);
				$("#start_indi").val(data.result.start_indi);
				$("#end_indi").val(data.result.end_indi);
				$("#std_score").val(data.result.std_score);
				$("#we_value").val(data.result.we_value);
				$("#upt_user").val(data.result.upt_user);
				$("#upt_dttm").val(data.result.upt_dttm);
				$("#start_dt").val(data.result.start_dt);
				$("#end_dt").val(data.result.end_dt);
				$("#cate_code").prop("readonly","true");
				$("#order_seq").prop("readonly","true");
				$("#start_dt").prop("readonly","true");
			}
		});
		modalOpen();
	}else
		return;
	}
function fnSaveProc(){
	if(!fnRequired('cate_code', '지표구분를  확인하세요.'))  return;
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
			type : "post" ,                       
			url : CommonUtil.getContextPath() + "/base/WvalSaveAct.do",
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
	<!--    	<div class="content-wrap">   -->
			<div class="flex-left-right mb-10">
				<div class="patient-info">
					<div class="info-name">가중치 목록</div>
				</div>
			</div>
        <section class="top-pannel">  
          <div class="search-box">
            <label for="search" class="form-title" onclick="">검색어 입력</label>
            <input type="text" name="searchText" id="searchText" class="form-control search" placeholder="아이디 및 사요자명를 입력하세요." 
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
                    <col style="width: 40px">
                    <col style="width: 40px">
                    <col style="width: 150px">
                    <col style="width: 40px">
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
                      <th>분류번호</th>
                      <th>분류순서</th>
                      <th>분류명</th>
                      <th>구분(점수/율)</th>
                      <th>시작일</th>
                      <th>지표시작</th>
                      <th>지표종료</th>
                      <th>표준화점수</th>
                      <th>가중치</th>
                      <th>입력일시</th>
                    </tr>
                  </thead>
                  <tbody id="dataArea"> 
        			<tr>
        				<td colspan="9">&nbsp;</td>
        			</tr>
                  </tbody>
                </table>
              </div>
           <!--   </div> -->
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
             <input type="hidden" name="order_seq" id="order_seq" />
        <div class="modal-body">
          <div class="form-container"> 
             <div class="form-wrap w-100">
	           <label for="">지표구분</label> 
	            <select class="form-select" name="cate_code" id="cate_code"> <!-- readonly -->
	                <option value="">선택</option> 
	                <c:forEach var="result" items="${verList}" varStatus="status">
	                   <option value="${result.sub_code}">${result.sub_code_nm}</option>
	                </c:forEach> 
	           </select>
             </div>  
             <div class="form-wrap w-50">
              <label for=""class="critical">계산방식</label>
       		  <select class="form-select" name="cal_gubun" id="cal_gubun">
                <option value="">선택</option> 
                <option value="1">1.점수</option>
                <option value="2">2.율</option>
              </select> 
            </div> 
       
            <div class="form-wrap w-50">
              <label for="" class="critical">시작일</label>
              <input type="text" name="start_dt" id="start_dt" class="form-control" placeholder="시작일를  입력하세요.">
            </div>    
            <div class="form-wrap w-50">
              <label for="" class="critical">시작지표</label>
              <input type="text" name="start_indi" id="start_indi" class="form-control" placeholder="시작지표를  입력하세요.">
            </div>    
            <div class="form-wrap w-50">
              <label for="" class="critical">종료지표</label>
              <input type="text" name="end_indi" id="end_indi" class="form-control" placeholder= "종료지표릏 입력하세요.">
            </div>                                    
            <div class="form-wrap w-50">
              <label for="" class="critical">표준점수</label>
              <input type="text" name="std_score" id="std_score" class="form-control" placeholder="표준점수를 입력하세요.">
            </div> 
            <div class="form-wrap w-50">
              <label for="" class="critical">가중치</label>
              <input type="text" name="we_value" id="we_value" class="form-control" placeholder="가중치를 입력하세요.">
            </div> 
            <div class="form-wrap w-50">
              <label for="" class="critical">종료일</label>
              <input type="text" name="end_dt" id="end_dt" class="form-control" placeholder="종료일를  입력하세요.">
            </div>              
          </div> 
        </div>
        </form:form>
      </div>
      
    </div>
  </div>
</body>
</html>