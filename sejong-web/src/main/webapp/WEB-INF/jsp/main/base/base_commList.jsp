<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>  
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>  
<%@ page import = "java.util.*" %>
<html>

<style>
</style>

<head>  
<!-- 달력(일자, 월별) 사용시 추가 필요함 11-->  
<script src="/js/main.js"></script> 
<script type="text/javaScript">
var scrid = sessionStorage.getItem("q_screen_id");
//모달이 있을 경우
var adminModal = new bootstrap.Modal(document.getElementById('adminModal'));
//조회
function fnSearch(gbn){
	//등록폼 초기화
	document.getElementById("regForm").reset();
	if(gbn == 'M'){
		$("#dataArea1").empty();
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() +  "/base/base_CommMstList.do",
			data : {code_cd : $("#searchText").val()},
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") return;
				
				if(data.resultCnt > 0 ){
					var dataTxt = "";
					
					for(var i=0 ; i < data.resultCnt; i++){
						dataTxt = '<tr  class="" onclick="javascript:fnDtlSearch(\''+data.resultLst[i].code_cd+'\');" id="row_'
						                                                            +data.resultLst[i].code_cd+'">'; 
						dataTxt += '<td>'+(i+1) +'</td>';
						dataTxt += "<td>"+ data.resultLst[i].code_cd+"</td>";
						dataTxt += "<td class='txt-left ellips'>"+ data.resultLst[i].code_nm+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].start_dt+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].end_dt+"</td>";
						dataTxt += "</tr>"; 
	                    $("#dataArea1").append(dataTxt);
					}
				}
			}
		});
	}
}
	//
 	//상세코드 정보 조회
function fnDtlSearch(code_cd){  
	
	if(code_cd == '' || code_cd == null) return;
	
	document.regForm.gbn.value  = "M";
	document.regForm.iud.value  = "U";
	document.regForm.code_cd.value = code_cd ;
	
	//row 클릭시 바탕색 변경 처리 Start		
	$("#infoTable tr").attr("class", "");
	$("#infoTable2 tr").attr("class", "");
	$("#infoTable #"+code_cd).attr("checked", true);
	$("#infoTable #row_"+code_cd).attr("class", "tr-primary");
	//row 클릭시 바탕색 변경 처리 End
	
	$("#dataArea2").empty();
	$.ajax( {
		type : "post",
		url : CommonUtil.getContextPath() + "/base/base_CommDetailList.do",
		data : {code_cd : code_cd},
		dataType : "json",
		success : function(data) {    
			if(data.error_code != "0") return;
			
			if(data.resultCnt > 0 ){
				var dataTxt = "";
				
				for(var i=0 ; i < data.resultCnt; i++){
					dataTxt = '<tr class="" onclick="javascript:fnDtlSearch2(\''
							        +data.resultLst[i].code_gb +'\',\''+code_cd+'\',\''+data.resultLst[i].sub_code+'\');" id="dtlrow_'
					                +data.resultLst[i].code_gb +code_cd + data.resultLst[i].sub_code+'">';
					
					dataTxt += '<td>'+(i+1) +'</td>'; 
					dataTxt += "<td>"+ data.resultLst[i].code_gb+"</td>";
					dataTxt += "<td>"+ data.resultLst[i].sub_code+"</td>";
					dataTxt += "<td class='txt-left ellips'>"+ data.resultLst[i].sub_code_nm+"</td>";
					dataTxt += "<td>"+ data.resultLst[i].start_dt+"</td>";
					dataTxt += "<td>"+ data.resultLst[i].end_dt+"</td>";
					dataTxt += "<td>"+ data.resultLst[i].sort+"</td>";
					dataTxt += "<td>"+ data.resultLst[i].use_yn+"</td>";
					dataTxt += "</tr>";
                    $("#dataArea2").append(dataTxt);
				}
			   
			}else{
				 $("#dataArea2").append("<tr><td colspan='8'>자료가 존재하지 않습니다.</td></tr>");
			}
		}
	});
	
}

	//상세코드 정보 선택시
function fnDtlSearch2(code_gb ,code_cd,sub_code){ 
       
	document.regForm.iud.value  = "DU";
	document.regForm.code_gb.value = code_gb ;
	document.regForm.code_cd.value = code_cd ;
	document.regForm.sub_code.value = sub_code ;
	//row 클릭시 바탕색 변경 처리 Start		
	$("#infoTable2 #"+code_gb+code_cd+sub_code).attr("checked", true);
	$("#infoTable2 tr").attr("class", "");
	$("#infoTable2 #dtlrow_"+code_gb+code_cd+sub_code).attr("class", "tr-primary");
	//row 클릭시 바탕색 변경 처리 End 
	
}
	// 버튼 클릭시 처리
function fnsave(gbn){
	var val = gbn.substring(0,1);
	var iud = gbn.substring(1,2);

	$("#gbn").val(val);  // 마스터(M),상세코드(D)
	$("#iud").val(gbn);  // 입력(I), 수정(U), 삭제(D) 
	
	if(iud == "D") fnSaveProc();
	else{  
		if(val == 'M'){
			$("#dtlCodeInfo").prop("style","display:none");
			$("#codegbInfo").prop("style","display:none");
			$("#dtlCodeName").prop("style","display:none");
			$("#sortInfo").prop("style","");
			$("#mstdupid").prop("style","");
			$("#CodeName").prop("style","");
			//
			if(iud == "I"){
				$("#code_cd").prop("readonly","");
				document.getElementById("regForm").reset();
				$("#end_dt").val("9999-12-31");
				setCurrDate("start_dt");
				$("#dupchk").val("X");
			}else if(iud == "U"){
				if($("#code_cd").val() == ""){
					alert("선택된 코드 정보가 없습니다.!");
					modalClose() ;
					return;
				}
				//
				$.ajax( {
					type : "post",
					url : CommonUtil.getContextPath() + "/base/base_CommMstList.do",
					data : {code_cd : $("#code_cd").val()},
					dataType : "json",
					success : function(data) {    
						if(data.error_code != "0") return;
					
						if(data.resultCnt > 0 ){ 
							$("#code_nm").val(data.resultLst[0].code_nm);
							$("#sort").val(data.resultLst[0].sort);
							$("#start_dt").val(data.resultLst[0].start_dt);
							$("#end_dt").val(data.resultLst[0].end_dt);
						 
						}
					}
				});

				$("#dupchk").val("N");
				$("#code_cd").prop("readonly","true");
			}
			modalOpen() ;
		}else if(val == 'D'){

			$("#mstdupid").prop("style","display:none");
			$("#CodeName").prop("style","display:none"); 
			var code_cd = $("#code_cd").val() ;
			if($("#code_cd").val() == ""){ 
				alert("선택된 코드 정보가 없습니다.!");
				modalClose() ;
				return;
			}
			$("#dtlCodeInfo").prop("style","");
			$("#codegbInfo").prop("style",""); 
			$("#dtlCodeName").prop("style","");
			$("#sortInfo").prop("style","");
			
			if(iud == "I"){
				document.getElementById("regForm").reset();
				$("#dtldupid").prop("style","");  //중복체크 버튼 활성화
				
				$("#code_cd").prop("readonly","false");
				$("#sub_code").prop("readonly","");

				setCurrDate("start_dt");
				$("#end_dt").val("9999-12-31");
				$("#code_cd").val(code_cd);
				$("#code_gb").val("Z");
				$("#dupchk").val("X");
				 
			}else if(iud == "U"){
				$("#dtldupid").prop("style","display:none");//중복체크 버튼 숨김 
				$("#dupchk").val("N");
				if($("#code_cd").val() == ""){
					alert("선택된 코드 정보가 없습니다.!");
					modalClose() ;
					return;
				}
				if($("#sub_code").val() == ""){
					alert("선택된 상세코드 정보가 없습니다.!");
					modalClose() ;
					return;
				}
				//
				$.ajax( {
					type : "post",
					url : CommonUtil.getContextPath() + "/base/base_CommDetailList.do",
					data : {code_cd : $("#code_cd").val(), sub_code : $("#sub_code").val()},
					dataType : "json",
					success : function(data) {    
						if(data.error_code != "0") return;
						
						if(data.resultCnt > 0 ){ 
							$("#sub_code_nm").val(data.resultLst[0].sub_code_nm);
							$("#start_dt").val(data.resultLst[0].start_dt);
							$("#end_dt").val(data.resultLst[0].end_dt);
							$("#sort").val(data.resultLst[0].sort); 
							if (data.resultLst[0].use_yn == "Y") {
								$("#use_yn").prop("checked", true);
							} else {
								$("#use_yn").prop("checked", false);
							}
						}
					}
				});
				
				$("#code_gb").prop("readonly","true");
				$("#sub_code").prop("readonly","true");
				$("#code_cd").prop("readonly","true");
				
			}

			modalOpen() ;
		}		
	}
	 
}
	
function fnDupchk(gbn){
	 
	if(gbn == 'M'){
		if(!fnRequired('code_cd', '코드정보를 입력하세요')) return;
		
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/base/CommMstDupChk.do",
			data : {code_cd : $("#code_cd").val()},
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") return;
				if(data.dupchk == "Y"){  
					alert("해당 코드정보는 이미 존재하는 코드입니다.");
					$("#code_cd").val("");
					$("#code_cd").focus();
					$("#dupchk").val("Y");
					return;
				}
				alert("사용 가능한 코드 정보입니다.");
				$("#dupchk").val("N");
			}
		});
		
	}else if(gbn == 'D'){
		if(!fnRequired('code_cd', '코드정보를 입력하세요')) return;
		if(!fnRequired('sub_code', '상세 코드정보를 입력하세요')) return;
		//상세코드 중복 체크
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() +  "/base/CommDetailDupChk.do",
			data : {code_cd : $("#code_cd").val() , sub_code : $("#sub_code").val() },
			dataType : "json",
			success : function(data) {   
				
				if(data.error_code != "0") return;
				if(data.dupchk == "Y"){  
					alert("해당 상세 코드정보는 이미 존재하는 코드입니다.");
					$("#sub_code").val("");
					$("#sub_code").focus();
					$("#dupchk").val("Y");
					return;
				}
			}
		});
		$("#dupchk").val("N");
	}
}
	
	//저장 처리
function fnSaveProc(){
	 
	var val = $("#gbn").val();  // 공통코드 마스터/상세 구분
	var iud = $("#iud").val().substring(0,1);  // 입력,수정,삭제 구분
	
	if(!fnRequired('code_cd', '코드정보를 입력하세요')) return;
	if(iud != "D" && val == "D" && !fnRequired('sub_code', '상세 코드정보를 입력하세요')) return;
	if(iud != "D" && !fnRequired('start_dt', '적용시작일자를 입력하세요')) return;
	if(iud != "D" && val == "M" && !fnRequired('code_nm', '코드명 정보를 입력하세요')) return;
	if(iud != "D" && val == "D" && !fnRequired('sub_code_nm', '상세코드명 정보를 입력하세요')) return;
	if(iud != "D" && ($("#dupchk").val() == "Y" || $("#dupchk").val() == "X")) {
		alert("코드 중복체크 여부를 확인하세요.!");
		return;
	}
	if ($("#use_yn").prop('checked')) {
	    $("#use_yn").val("Y");  // 체크박스가 체크되었을 때, value 값을 "Y"로 설정
	} else {
	    $("#use_yn").val("");  // 체크박스가 체크되지 않았을 때, value 값을 빈 문자열로 설정
	}

	var formData = $("form[name='regForm']").serialize();
	
	$.ajax( {
		type : "post",
		url : CommonUtil.getContextPath() + "/base/CommSaveProc.do",
		data : formData,
		dataType : "json",
		success : function(data) {   
			
			if(data.error_code != "0") {
				alert("처리실패하였습니다.");
				return; 
			}
			else{
				alert("정상 처리되었습니다.");
				modalClose() ;
				
				if(val == "M")
					fnSearch(gbn);
				else
					fnDtlSearch($("#code_cd").val());
			}
			 
		}
	});
	
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
<body id="BodyArea">  
    <div class="tab-pane">  
      <div class="content-body">
		<div class="tab-content">
	<!--  	<div class="content-wrap"> -->
		<div class="flex-left-right mb-10">
			<div class="patient-info">
				<div class="info-name">코드 목록</div>
			</div>
		</div> 
     <!--
      <header class="header">
        <h1>
          공통코드 정보 관리
        </h1>
      </header>
      <div class="tab-pane"> 
      <div class="content-body">
     -->
        <section class="top-pannel">
          <div class="search-box">
            <label for="search" class="form-title">검색어 입력</label>
            <input name="searchText" id="searchText" type="text" class="form-control" placeholder="검색어를 입력하세요"
                                                                       onkeypress="if( event.keyCode == 13 ){fnSearch('M');}">
              <button class="buttcon" onclick="fnSearch('M');"><span class="icon icon-search"></span></button> 
          </div>
        </section>
        <section class="main-pannel">
          <div class="main-left">
            <header class="main-hd">
            <!--<h2>코드 목록</h2> 원래 -->
              <h2></h2>
              <div class="btn-box">
                <button class="btn btn-outline-dark btn-sm"   onclick="fnsave('MU');">수정</button>
                <button class="btn btn-primary btn-sm"  onclick="fnsave('MI');">입력</button>  
              </div>
            </header>
            <div class="main-content">
              <!-- 테이블 샘플 -->
              <div class="table-responsive">
                <table id="infoTable"  class="table table-bordered">
                  <colgroup>
                    <col style="width: 50px">
                    <col style="width: 80px">
                    <col style="width: auto">
                    <col style="width: 80px">
                    <col style="width: 80px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th>번호</th>
                      <th>코드</th>
                      <th>코드명</th>
                      <th>적용시작일</th>
                      <th>적용종료일</th>
                    </tr>
                  </thead>
                  <tbody id="dataArea1"> 
                    <tr>
                       <td colspan="6">&nbsp; </td> 
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
          <div class="main-right">
            <header class="main-hd">
              <h2>상세코드 목록</h2>
              <div class="btn-box">
                <button class="btn btn-outline-dark btn-sm" onclick="fnsave('DU');">수정</button>
                <button class="btn btn-primary btn-sm"  onclick="fnsave('DI');">입력</button> 
              </div>
            </header>
            <div class="main-content">
              <!-- 테이블 샘플 -->
              <div class="table-responsive">
                <table id="infoTable2" class="table table-bordered">
                  <colgroup>
                    <col style="width: 50px">
                    <col style="width: 50px">
                    <col style="width: 50px">
                    <col style="width: 200px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 50px">
                    <col style="width: 50px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th>번호</th>
                      <th>상세구분</th>
                      <th>상세코드</th>
                      <th>상세코드 명</th>
                      <th>적용시작일</th>
                      <th>적용종료일</th>
                      <th>정렬</th>
                      <th>사용여부</th>
                    </tr>
                  </thead>
                  <tbody id="dataArea2">
                    <tr>
                      <td colspan="9">&nbsp;</td>
                    </tr>
                  </tbody>
                </table>
              </div>
          <!--  </div> -->
          </div>
        </section>
      </div>
      </div>
   <!--   원래 밑에 없음  -->  
    </div>   
  <!-- 모달 -->
   
  <div class="modal fade" id="adminModal"  tabindex="-1" aria-labelledby="adminModalLabel" aria-hidden="true">
    <!-- 모달 class명으로 사이즈 조절 modal-320, 410, 520, 650, 820 -->
    <div class="modal-dialog  modal-820">
      <div class="modal-content">
        <div class="modal-footer">
          <button type="button" class="btn btn-primary btn-sm"  onclick="fnSaveProc();">저장</button>
          <button type="button" class="btn btn-outline-dark btn-sm" data-bs-dismiss="modal" onclick="modalClose();">목록</button>
        </div>
        <div class="modal-body">
          <div class="form-container">
          
    		<form:form commandName="DTO" id="regForm" name="regForm" method="post">
              <input type="hidden" name="gbn" id="gbn" />
              <input type="hidden" name="iud" id="iud" />
              <input type="hidden" name="dupchk" id="dupchk" value="X"/>
              
 
            <div class="form-wrap w-70" id="codegbInfo" style="display:none">
	           <label for="">코드구분</label> 
	            <select class="form-select" name="code_gb" id="code_gb"> <!-- readonly -->
	                <option value="">선택</option> 
	                <c:forEach var="result" items="${codegbList}" varStatus="status">
	                   <option value="${result.sub_code}">${result.sub_code_nm}</option>
	                </c:forEach> 
	           </select>
           </div>
           
           
            <div class="form-wrap w-70">
              <label for="" class="critical">코드</label>
              <input type="text" name="code_cd" id="code_cd" class="form-control" placeholder="" readonly>
              <button type="button" class="btn btn-outline-dark" id="mstdupid" onclick="fnDupchk('M');">중복체크</button>
            </div>
            <div class="form-wrap w-100" id="CodeName" >
              <label for="" class="critical">코드명</label>
              <input type="text" name="code_nm"  id="code_nm" class="form-control" placeholder="코드명을 입력하세요.">
            </div>
            <div class="form-wrap w-70" id="dtlCodeInfo" style="display:none">
              <label for="" class="critical">상세코드</label>
              <input type="text" name="sub_code" id="sub_code" class="form-control" placeholder="" readonly>
              <button type="button" class="btn btn-outline-dark" id="dtldupid"  onclick="fnDupchk('D');">중복체크</button>
            </div>
            <div class="form-wrap w-100" id="dtlCodeName" style="display:none">
              <label for="" class="critical">상세코드명</label>
              <textarea class="form-control" aria-label="With textarea" name="sub_code_nm" id="sub_code_nm" placeholder="상세코드명을 입력하세요."></textarea>              
            </div>  
                  
            <div class="form-wrap w-100">
              <label for="" class="critical">적용시작일</label>
              <input type="text" name="start_dt" id="start_dt"  class="form-control" value="">  
              <label for="" class="critical">적용종료일</label>
              <input type="text" name="end_dt" id="end_dt" class="form-control" value="9999-12-31">
            </div>
            <div class="form-wrap w-50" id="sortInfo">
              <label for="">정렬순서</label>
              <input type="text" name="sort" id="sort" class="form-control" placeholder="00" value="">
            </div>
			<div class="form-wrap w-50">
				<label for="">사용여부</label>
					<input class="form-check-input" type="checkbox" value="Y"
						name="use_yn" id="use_yn"> <span class="ml-1">사용</span>
			</div>            
             </form:form>
          </div>
        </div>
      </div>
    </div>
  </div>
</body>
</html>