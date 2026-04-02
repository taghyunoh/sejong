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
<!-- 달력(일자, 월별) 사용시 추가 필요함 -->  
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
	//	if($('#searchText').val() == "") {
	//		alert("검색어를 입력하세요.");
	//		$('#searchText').focus();
	//		return; 
	//	}
		$("#dataArea1").empty();
		console.log($('#searchtext').val());
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/admin/selectCommMstList.do",
			data : {code : $("#searchtext").val()},
			dataType : "json",
			success : function(data) {    
				console.log(data);
				if(data.error_code != "0") return;
				
				if(data.resultCnt > 0 ){
					var dataTxt = "";
					
					for(var i=0 ; i < data.resultCnt; i++){
						dataTxt = '<tr  class="" onclick="javascript:fnDtlSearch(\''+data.resultLst[i].code+'\');" id="row_'+data.resultLst[i].code+'">'; 
						dataTxt += '<td>'+(i+1) +'</td>';
						dataTxt += "<td>"+ data.resultLst[i].code+"</td>";
					//	dataTxt += "<td class='txt-left ellips'>"+ data.resultLst[i].code_name+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].code_name+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].start_date+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].end_date+"</td>";
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
function fnDtlSearch(code){  
	
	if(code == '' || code == null) return;
	
	document.regForm.gbn.value  = "M";
	document.regForm.iud.value  = "U";
	document.regForm.code.value = code ;
	 
	
	//row 클릭시 바탕색 변경 처리 Start		
	$("#infoTable tr").attr("class", "");
	$("#infoTable2 tr").attr("class", "");
	$("#infoTable #"+code).attr("checked", true);
	$("#infoTable #row_"+code).attr("class", "tr-primary");
	//row 클릭시 바탕색 변경 처리 End
	
	$("#dataArea2").empty();
	$.ajax( {
		type : "post",
		url : CommonUtil.getContextPath() + "/admin/selectCommDetailList.do",
		data : {code : code},
		dataType : "json",
		success : function(data) {    
			if(data.error_code != "0") return;
			
			if(data.resultCnt > 0 ){
				var dataTxt = "";
				
				for(var i=0 ; i < data.resultCnt; i++){
					dataTxt = '<tr class="" onclick="javascript:fnDtlSearch2(\''+code+'\',\''+data.resultLst[i].dtl_code+'\');" id="dtlrow_'
					                                                                  +code+data.resultLst[i].dtl_code+'">';
					
					dataTxt += '<td>'+(i+1) +'</td>'; 
					dataTxt += "<td>"+ data.resultLst[i].dtl_code+"</td>";
				//	dataTxt += "<td class='txt-left ellips'>"+ data.resultLst[i].dtl_code_nm+"</td>";
					dataTxt += "<td>"+ data.resultLst[i].dtl_code_nm+"</td>";
					dataTxt += "<td>"+ data.resultLst[i].start_date+"</td>";
					dataTxt += "<td>"+ data.resultLst[i].end_date+"</td>";
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
function fnDtlSearch2(code,dtl_code){ 
       
	document.regForm.iud.value  = "DU";
	document.regForm.code.value = code ;
	document.regForm.dtl_code.value = dtl_code ;

	//row 클릭시 바탕색 변경 처리 Start		
	$("#infoTable2 #"+code+dtl_code).attr("checked", true);
	$("#infoTable2 tr").attr("class", "");
	$("#infoTable2 #dtlrow_"+code+dtl_code).attr("class", "tr-primary");
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
			$("#dtlCodeName").prop("style","display:none");
			$("#sortInfo").prop("style","display:none");
			$("#mstdupid").prop("style","");
			$("#CodeName").prop("style","");
			//
			if(iud == "I"){
				$("#code").prop("readonly","");
				document.getElementById("regForm").reset();
				$("#end_date").val("9999-12-31");
				setCurrDate("start_date");
				$("#dupchk").val("X");
			}else if(iud == "U"){
				if($("#code").val() == ""){
					alert("선택된 코드 정보가 없습니다.!");
					modalClose() ;
					return;
				}
				//
				$.ajax( {
					type : "post",
					url : CommonUtil.getContextPath() + "/admin/selectCommMstList.do",
					data : {code : $("#code").val()},
					dataType : "json",
					success : function(data) {    
						if(data.error_code != "0") return;
					
						if(data.resultCnt > 0 ){ 
							$("#code_name").val(data.resultLst[0].code_name);
							$("#start_date").val(data.resultLst[0].start_date);
							$("#end_date").val(data.resultLst[0].end_date);
						 
						}
					}
				});

				$("#dupchk").val("N");
				$("#code").prop("readonly","true");
			}
			modalOpen() ;
		}else if(val == 'D'){

			$("#mstdupid").prop("style","display:none");
			$("#CodeName").prop("style","display:none"); 
			var code = $("#code").val() ;
			if($("#code").val() == ""){ 
				alert("선택된 코드 정보가 없습니다.!");
				modalClose() ;
				return;
			}
			$("#dtlCodeInfo").prop("style","");
			$("#dtlCodeName").prop("style","");
			$("#sortInfo").prop("style","");
			
			if(iud == "I"){
				document.getElementById("regForm").reset();
				$("#dtldupid").prop("style","");  //중복체크 버튼 활성화
				
				$("#code").prop("readonly","false");
				$("#dtl_code").prop("readonly","");

				setCurrDate("start_date");
				$("#end_date").val("9999-12-31");
				$("#code").val(code);
				$("#dupchk").val("X");
				 
			}else if(iud == "U"){
				$("#dtldupid").prop("style","display:none");//중복체크 버튼 숨김 
				$("#dupchk").val("N");
				if($("#code").val() == ""){
					alert("선택된 코드 정보가 없습니다.!");
					modalClose() ;
					return;
				}
				if($("#dtl_code").val() == ""){
					alert("선택된 상세코드 정보가 없습니다.!");
					modalClose() ;
					return;
				}
				//
				$.ajax( {
					type : "post",
					url : "/admin/selectCommDetailList.do",
					data : {code : $("#code").val(), dtl_code : $("#dtl_code").val()},
					dataType : "json",
					success : function(data) {    
						if(data.error_code != "0") return;
						
						if(data.resultCnt > 0 ){ 
							$("#dtl_code_nm").val(data.resultLst[0].dtl_code_nm);
							$("#start_date").val(data.resultLst[0].start_date);
							$("#end_date").val(data.resultLst[0].end_date);
							$("#sort").val(data.resultLst[0].sort); 
						}
					}
				});
				
				$("#dtl_code").prop("readonly","true");
				$("#code").prop("readonly","true");
				
			}

			modalOpen() ;
		}		
	}
	 
}
	
function fnDupchk(gbn){
	 
	if(gbn == 'M'){
		if(!fnRequired('code', '코드정보를 입력하세요')) return;
		
		$.ajax( {
			type : "post",
			url : "/admin/CommMstDupChk.do",
			data : {code : $("#code").val()},
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") return;
				if(data.dupchk == "Y"){  
					alert("해당 코드정보는 이미 존재하는 코드입니다.");
					$("#code").val("");
					$("#code").focus();
					$("#dupchk").val("Y");
					return;
				}
				alert("사용 가능한 코드 정보입니다.");
				$("#dupchk").val("N");
			}
		});
		
	}else if(gbn == 'D'){
		if(!fnRequired('code', '코드정보를 입력하세요')) return;
		if(!fnRequired('dtl_code', '상세 코드정보를 입력하세요')) return;
		//상세코드 중복 체크
		$.ajax( {
			type : "post",
			url : "/admin/CommDetailDupChk.do",
			data : {code : $("#code").val() , dtl_code : $("#dtl_code").val() },
			dataType : "json",
			success : function(data) {   
				
				if(data.error_code != "0") return;
				if(data.dupchk == "Y"){  
					alert("해당 상세 코드정보는 이미 존재하는 코드입니다.");
					$("#dtl_code").val("");
					$("#dtl_code").focus();
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
	
	if(!fnRequired('code', '코드정보를 입력하세요')) return;
	if(iud != "D" && val == "D" && !fnRequired('dtl_code', '상세 코드정보를 입력하세요')) return;
	if(iud != "D" && !fnRequired('start_date', '적용시작일자를 입력하세요')) return;
	if(iud != "D" && val == "M" && !fnRequired('code_name', '코드명 정보를 입력하세요')) return;
	if(iud != "D" && val == "D" && !fnRequired('dtl_code_nm', '상세코드명 정보를 입력하세요')) return;
	if(iud != "D" && ($("#dupchk").val() == "Y" || $("#dupchk").val() == "X")) {
		alert("코드 중복체크 여부를 확인하세요.!");
		return;
	}

	var formData = $("form[name='regForm']").serialize();
	
	 
	$.ajax( {
		type : "post",
		url : "/admin/CommSaveProc.do",
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
					fnDtlSearch($("#code").val());
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
		<div class="content-wrap">
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
                    <col style="width: 200px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 50px">
                    <col style="width: 50px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th>번호</th>
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
        <div class="modal-body">
          <div class="form-container">
          
    		<form:form commandName="VO" id="regForm" name="regForm" method="post">
              <input type="hidden" name="gbn" id="gbn" />
              <input type="hidden" name="iud" id="iud" />
              <input type="hidden" name="dupchk" id="dupchk" value="X"/>
            <div class="form-wrap w-70">
              <label for="" class="critical">코드</label>
              <input type="text" name="code" id="code" class="form-control" placeholder="" readonly>
              <button type="button" class="btn btn-outline-dark" id="mstdupid" onclick="fnDupchk('M');">중복체크</button>
            </div>
            <div class="form-wrap w-100" id="CodeName" >
              <label for="" class="critical">코드명</label>
              <input type="text" name="code_name"  id="code_name" class="form-control" placeholder="코드명을 입력하세요.">
            </div>
            <div class="form-wrap w-70" id="dtlCodeInfo" style="display:none">
              <label for="" class="critical">상세코드</label>
              <input type="text" name="dtl_code" id="dtl_code" class="form-control" placeholder="" readonly>
              <button type="button" class="btn btn-outline-dark" id="dtldupid"  onclick="fnDupchk('D');">중복체크</button>
            </div>
            <div class="form-wrap w-100" id="dtlCodeName" style="display:none">
              <label for="" class="critical">상세코드명</label>
              <input type="text" name="dtl_code_nm" id="dtl_code_nm" class="form-control" placeholder="상세코드명을 입력하세요.">
            </div>
            <div class="form-wrap w-100">
              <label for="" class="critical">적용시작일</label>
              <input type="date" name="start_date" id="start_date"  class="form-control" value="">  
              <label for="" class="critical">적용종료일</label>
              <input type="date" name="end_date" id="end_date" class="form-control" value="9999-12-31">
            </div>
            <div class="form-wrap w-50" id="sortInfo" style="display:none">
              <label for="">정렬순서</label>
              <input type="text" name="sort" id="sort" class="form-control" placeholder="00" value="">
            </div>
            </form:form>
          </div>
        </div>
      </div>
    </div>
  </div>
</body>

  
</html>