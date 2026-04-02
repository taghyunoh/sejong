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
	.table-responsive {
	  max-height: 600px; /* 적당한 높이 설정 (10개 행 기준으로 조정) */
	  overflow-y: auto; /* 수직 스크롤 활성화 */
	  border: 1px solid #ccc; /* 테두리 추가 */
	}
</style>
<head>  
<!-- 달력(일자, 월별) 사용시 추가 필요함 -->  
<script src="/js/main.js"></script> 
<script type="text/javaScript">

	//모달이 있을 경우
	var HospCodeModal = new bootstrap.Modal(document.getElementById("HospCodeModal"));
	var SamVerModal   = new bootstrap.Modal(document.getElementById("SamVerModal"));
	var samverison    = "" ; 
	
	//조회
	function fnSearch(){
		//등록폼 초기화
		document.getElementById("regForm").reset(); 
		document.getElementById("regForm2").reset(); 
		$("#sertblinfo").val(""); 
		$("#dataArea1").empty();
		$.ajax( {
			url : CommonUtil.getContextPath() + "/base/selectCodeDetailList.do",
			type : "post",
			data : {code_cd:'SAMVER', sub_code : $("#samver").val()},
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") return;
		
				if(data.resultCnt > 0 ){
					var dataTxt = "";
					
					for(var i=0 ; i < data.resultCnt; i++){
						dataTxt = '<tr  class="" onclick="javascript:fnDtlSearch(\'' +data.resultLst[i].sub_code+'\',\''+data.resultLst[i].prop_1+'\');" id="row_'
						                                                             +data.resultLst[i].sub_code+ data.resultLst[i].prop_1+'">'; 
						dataTxt += "<td>"+ (i+1)+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].sub_code+"</td>";
						dataTxt += "<td class='txt-left ellips'>"+ data.resultLst[i].sub_code_nm+"</td>";
						dataTxt += "<td>" + data.resultLst[i].prop_1+"</td>";
						dataTxt += "<td class='txt-left ellips'>"+ data.resultLst[i].prop_5+"</td>";
						dataTxt += "</tr>"; 
	                    $("#dataArea1").append(dataTxt); 
					}
 
				}
			}
    	}); 
	}
	//
	//상세코드 정보 조회
	function fnDtlSearch(sub_code,prop_1){  
		if(sub_code == '' || sub_code == null) return;
		$("#sertblinfo").val("");
		document.getElementById("regForm2").reset();  
		document.regForm2.samver.value = sub_code ; 
		$("#samver2").val(sub_code);
		samverison= prop_1;
		//row 클릭시 바탕색 변경 처리 Start  
		$("#infoTable tr").attr("class", "");
		$("#infoTable2 tr").attr("class", "");
		$("#infoTable #row_"+sub_code+prop_1).attr("class", "tr-primary");
		//row 클릭시 바탕색 변경 처리 End
	
		$("#dataArea2").empty();
		$.ajax( { 
			url : CommonUtil.getContextPath() + "/base/selectSamVerList.do",
			type : "post",
			data : {samver : sub_code , version : sub_code , prop_1 : prop_1 },
			dataType : "json",
			success : function(data) {     
				if(data.error_code != "0") return;
				
				if(data.resultCnt > 0 ){
					var dataTxt = "";
					for(var i=0 ; i < data.resultCnt; i++){
						dataTxt = '<tr class="" onclick="javascript:fnDtlSearch2(\''
								 +data.resultLst[i].tblinfo+'\',\''+data.resultLst[i].version+'\',\''+data.resultLst[i].seq+'\',\''+data.resultLst[i].samver+'\');" id="dtlrow_'
						         +data.resultLst[i].tblinfo+data.resultLst[i].version+data.resultLst[i].seq+data.resultLst[i].samver+'">'; 
						dataTxt += "<td>"+ (i+1)+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].samver +"</td>";
						dataTxt += "<td>"+ data.resultLst[i].sub_code_nm +"</td>";
						dataTxt += "<td>"+ data.resultLst[i].version+"</td>"; 
						dataTxt += "<td class='txt-left ellips'>"+ data.resultLst[i].item_nm+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].sort_seq+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].start_pos+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].end_pos+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].data_type+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].decimal_pos+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].dataproc_yn+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].db_colnm+"</td>";
						dataTxt += "</tr>";
	                    $("#dataArea2").append(dataTxt);// class='txt-left ellips'
// 		                    console.log(dataTxt);
					}
				   
				}else{
					 $("#dataArea2").append("<tr><td colspan='11'>자료가 존재하지 않습니다.</td></tr>");
				}
			}
		});
		
	}
	
	function fnDtlSearch3(tblinfo){
		if($("#samver2").val() == ""){ alert("청구파일 정보가 존재하지 않습니다."); return;}
		var samver = $("#samver2").val();
		document.getElementById("regForm2").reset(); 
		document.regForm2.samver.value= samver;
		document.regForm2.tblinfo.value= tblinfo;
		$("#dataArea2").empty();
		$.ajax( { 
			type : "post",
			url : CommonUtil.getContextPath() + "/base/selectSamVerList.do",
			data : {samver : samver,  version : samver , prop_1 : samverison , tblinfo:tblinfo},
			dataType : "json",
			success : function(data) {     
				if(data.error_code != "0") return;
				
				if(data.resultCnt > 0 ){
					var dataTxt = "";
					
					for(var i=0 ; i < data.resultCnt; i++){
						dataTxt = '<tr class="" onclick="javascript:fnDtlSearch2(\''
   								 +data.resultLst[i].tblinfo+'\',\''+data.resultLst[i].version+'\',\''+data.resultLst[i].seq+'\',\''+data.resultLst[i].samver+'\');" id="dtlrow_'
 						         +data.resultLst[i].tblinfo+data.resultLst[i].version+data.resultLst[i].seq+data.resultLst[i].samver+'">'; 						                                                           
						dataTxt += "<td>"+ (i+1)+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].samver +"</td>";
						dataTxt += "<td>"+ data.resultLst[i].sub_code_nm+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].version+"</td>"; 
						dataTxt += "<td class='txt-left ellips'>"+ data.resultLst[i].item_nm+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].sort_seq+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].start_pos+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].end_pos+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].data_type+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].decimal_pos+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].dataproc_yn+"</td>";
						dataTxt += "<td>"+ data.resultLst[i].db_colnm+"</td>";
						dataTxt += "</tr>";
	                    $("#dataArea2").append(dataTxt);// class='txt-left ellips' 
					}
				   
				}else{
					 $("#dataArea2").append("<tr><td colspan='11'>자료가 존재하지 않습니다.</td></tr>");
				}
			}
		});
		
		
	}
	//상세코드 정보 선택시
	function fnDtlSearch2(tblinfo,version,seq,samver){ 
// 		console.log($("#samver2").val()); 
		document.regForm2.iud.value  = "U";  
		document.regForm2.samver.value   = samver // $("#samver2").val();
		document.regForm2.version.value  = version;
		document.regForm2.tblinfo.value  = tblinfo;  
		document.regForm2.seq.value      = seq;  
  
		$("#infoTable2 tr").attr("class", "");
		$("#infoTable2 #dtlrow_"+tblinfo+version+seq+samver).attr("class", "tr-primary");
		//row 클릭시 바탕색 변경 처리 End 
		
	}
	
	// 버튼 클릭시 처리
	function fnsave(){ 

		document.getElementById("regForm").reset();
		$("#end_date").val("9999-12-31");
		setCurrDate("start_date");
		$("#dupchk2").val("X");
				 
		HospCodeModal.show(); 
	}
	
	//상세코드 중복 체크
	function fnCodeDupchk(gbn){ 
		 
		if(!fnRequired('code_cd', '코드정보를 입력하세요')) return;
		if(!fnRequired('sub_code', '상세 코드정보를 입력하세요')) return;
		//상세코드 중복 체크
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/base/CodeDetailDupChk.do",
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
	
	//
	function fnSamDupchk(){ 
		
		if(!fnRequired('samver' , '청구 버전정보를 확인하세요')) return;
		if(!fnRequired('tblinfo', '청구 구분정보 입력하세요')) return;
		if(!fnRequired('version', '청구 버전정보를 입력하세요')) return;
		if(!fnRequired('db_colnm', 'DB컬럼정보를 입력하세요')) return;
			
		$.ajax( {
			type : "post",
			url :  CommonUtil.getContextPath() + "/base/selectSamVerDupchk.do",
			data : {samver : $("#samver").val(),version: $("#version").val(),tblinfo:$("#tblinfo").val(),dbcolid:$("#dbcolid").val()},
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") return;
				if(data.dupchk == "Y"){  
					alert("해당 DB 컬럼정보는 이미 존재하는 정보입니다."); 
					$("#dupchk2").val("Y");
					return;
				}
				alert("등록 가능한 정보입니다");
				$("#dupchk2").val("N");
			}
		});
		
	 
	}
	
	//저장 처리
	function fnSaveProc(){
		 
		var val = $("#gbn").val();  // 공통코드 마스터/상세 구분
		var iud = $("#iud").val().substring(1,1);  // 입력,수정,삭제 구분 
		
		if(!fnRequired('sub_code', '코드정보를 입력하세요')) return;
		if(iud != "D" && val == "D" && !fnRequired('sub_code', '상세 코드정보를 입력하세요')) return;
		if(iud != "D" && !fnRequired('start_dt', '적용시작일자를 입력하세요')) return;
		if(iud != "D" && val == "M" && !fnRequired('code_nm', '코드명 정보를 입력하세요')) return;
		if(iud != "D" && val == "D" && !fnRequired('sub_code_nm', '상세코드명 정보를 입력하세요')) return;
		if(iud != "D" && ($("#dupchk").val() == "Y" || $("#dupchk").val() == "X")) {
			alert("코드 중복체크 여부를 확인하세요.!");
			return;
		}

		var formData = $("form[name='regForm']").serialize(); 
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/base/CodeSaveProc.do",
			data : formData,
			dataType : "json",
			success : function(data) {   
				
				if(data.error_code != "0") {
					alert("처리실패하였습니다.");
					return; 
				}
				else{
					alert("정상 처리되었습니다.");
					HospCodeModal.hide();
					fnSearch();
				 
				}
				 
			}
		});
		
	}
	
	function SamVerSave(iud){ 
		
		if(!fnRequired('samver2', '청구 구분코드를 확인하세요')) return; 
	 
		document.regForm2.iud.value  = iud;
// 		console.log(document.regForm2); 
		
		if(iud == "U"){
			if(!fnRequired('version', '청구 버전정보를 확인하세요')) return;
			$("#dupdbcolid").prop("disabled","true");
			$.ajax( {
				type : "post",
				url : CommonUtil.getContextPath() + "/base/selectSamVerMgtView.do",
				data : {samver:$("#samver2").val(), seq:$("#seq").val(), version:$("#version").val(), tblinfo:$("#tblinfo").val()},
				dataType : "json", 
				success : function(data) {     
					if(data.error_code != "0") {
						alert("처리실패하였습니다.");
						return; 
					}
					else{
						$("#tblinfo").val(data.result.tblinfo);
						$("#item_nm").val(data.result.item_nm);
						$("#sort_seq").val(data.result.sort_seq);
						$("#start_pos").val(data.result.start_pos);
						$("#end_pos").val(data.result.end_pos);
						$("#data_type").val(data.result.data_type);
						$("#decimal_pos").val(data.result.decimal_pos);
						$("#dataproc_yn").val(data.result.dataproc_yn);
						$("#sort_seq").val(data.result.sort_seq);
						if(data.result.dataprocyn == "Y")
							$("#dataproc_yn1").prop("checked","checked");	
						else	
							$("#dataproc_yn2").prop("checked","checked");
						$("#db_colnm").val(data.result.db_colnm);
						
					}
					 
				}
			});
			
		}else{  
			$("#version").prop("readonly","");
			$("#seq").prop("readonly",""); 
			$("#tblinfo").prop("readonly",""); 
			$("#dupdbcolid").prop("disabled","");
			var samver = $("#samver2").val();
			document.getElementById("regForm2").reset(); 
			document.regForm2.iud.value     = iud;
			document.regForm2.samver.value  = samver;
		}
		SamVerModal.show();
	}

	//저장 처리
	function fnSaveSamVer(){
		  
		
		if(!fnRequired('samver2', '청구 구분 정보를 입력하세요')) return;
		if(!fnRequired('tblinfo', '청구 구분명를 입력하세요')) return;
		if(!fnRequired('version', '버전정보를 입력하세요')) return;
		if(!fnRequired('item_nm', '항목구분명를 입력하세요')) return;
		if(!fnRequired('start_pos', '시작위치를 입력하세요')) return;
		//
		if($("#start_pos").val() < "0" || $("#start_pos").val() == "") {
			alert("시작위치 정보는 0 보다 커야 합니다.");
			return;
		}
		
		if(!fnRequired('end_pos', '종료위치를 입력하세요')) return;
		if($("#end_pos").val() < "0" || $("#end_pos").val() == "") {
			alert("시작위치 정보는 0 보다 커야 합니다.");
			return;
		}
		
		if(parseInt($("#start_pos").val()) > parseInt($("#end_pos").val()) ) {
			alert("시작위치 정보가 종료위치보다 큰 정보입니다.");
			return;
		}
		if(!fnRequired('sort_seq', '정렬순서를 입력하세요')) return;
		//
		if(parseInt($("#sort_seq").val()) < 0 ) {
			alert("졍렬순서 정보는 0 보가 커야 합니다.");
			return;
		}
		//
		if(!fnRequired('data_type', '데이타형태 정보를 입력하세요')) return;
		if($("#data_type").val() == "DECIMAL" && ($("#decimal_pos").val() == "" || $("#decimal_pos").val() < "0")) {
			alert("데이타형태가 실수형인 경우 소수점자리수 정보는 0 보다 커야 합니다.");
			return;
		}
		
		if($("#dataprocyn1").prop("checked") && !fnRequired('db_colnm', 'DB 컬럼정보를 입력하세요')) return; 
		//
		if($("#iud").val()== "I" && $("#dupchk2").val() != "N"){
			alert("DB 컬럼 중복체크를 확인하세요.");
			return;
		}
		var formData = $("form[name='regForm2']").serialize(); 
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/base/SamVerSaveProc.do",
			data : formData,
			dataType : "json",
			success : function(data) {   
				console.log(data);
				if(data.error_code != "0") {
					alert("처리실패하였습니다.");
					return; 
				}
				else{
					alert("정상 처리되었습니다.");
					modalClose();
					fnDtlSearch($("#samver2").val());
				 
				}
			}
		});
	}
	//
	function modalClose(){ 
		HospCodeModal.hide();
		SamVerModal.hide();
	}
	
</script>
</head>
<body>  
 <div class="tab-pane">  
   <div class="content-body">
     <div class="tab-content">
   <!--   <div class="content-wrap"> -->  <!--  마킹하면  화면 넓히기  -->
		<div class="flex-left-right mb-10">
			<div class="patient-info">
				<div class="info-name">샘파일관리</div>
			</div>
		</div> 
        <section class="top-pannel">
          <div class="search-box">
            <label for="search" class="form-title">검색어 입력</label>
            <select name="samver" id="samver">
            	<option value="">선택</option>
            	  <c:forEach var="result" items="${verList}" varStatus="status">
	              	<option value="${result.sub_code}">${result.sub_code_nm}</option>
	              </c:forEach>
            </select> 
            <button class="buttcon" onclick="fnSearch();"><span class="icon icon-search"></span></button>
          </div>
        </section>
        <section class="main-pannel">
          <div class="main-left">
            <header class="main-hd">
              <h2>청구 파일정보</h2>
              <div class="btn-box"> 
                <button class="btn btn-primary btn-sm" onclick="fnsave();">입력</button>  
              </div>
            </header>
            <div class="main-content">
              <!-- 테이블 샘플 -->
              <div class="table-responsive">
                <table id="infoTable"  class="table table-bordered">
                  <colgroup>
                    <col style="width: 50px">
                    <col style="width: 100px">
                    <col style="width: auto"> 
                    <col style="width: 80px">
                    <col style="width: 80px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th>번호</th>
                      <th>청구구분코드</th>
                      <th>청구구분명칭</th>
                      <th>확장자범위</th>
                      <th>확장자구분</th>
                    </tr>
                  </thead>
                  <tbody id="dataArea1"> 
                    <tr>
                      <td colspan="3">&nbsp;</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
          <div class="main-right">
            <header class="main-hd">
              <h2>상세 목록   &nbsp; &nbsp; &nbsp; 
                <label  style="font-size:16px;">청구구분&nbsp;:&nbsp;</label>
            	<select name="sertblinfo" id="sertblinfo" onchange="fnDtlSearch3(this.value);"  style="font-size:16px;">
            		<option value="">선택</option>
            	  	<c:forEach var="tblList" items="${tblinfoList}" varStatus="status">
	              		<option value="${tblList.sub_code}">${tblList.sub_code_nm}</option>
	             	 </c:forEach>
            	</select> 
            	</h2>
              <div class="btn-box">
                <button class="btn btn-outline-dark btn-sm"  onclick="SamVerSave('U');">수정</button>
                <button class="btn btn-primary btn-sm" onclick="SamVerSave('I');">입력</button> 
              </div>   
			</header>	
            <div class="main-content">
              <!-- 테이블 샘플 -->
              <div class="table-responsive">
                <table id="infoTable2" class="table table-bordered">
                  <colgroup>
                    <col style="width: 30px">
                    <col style="width: 50px">
                    <col style="width: 50px">
                    <col style="width: 20px">
                    <col style="width: auto">
                    <col style="width: 20px">
                    <col style="width: 20px">
                    <col style="width: 40px">
                    <col style="width: 20px">
                    <col style="width: 20px">
                    <col style="width: 30px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th>번호</th>
                      <th>확장자</th>
                      <th>청구구분명</th>
                      <th>버전</th>
                      <th>항목구분명</th>
                      <th>정렬<br/>순서</th>
                      <th>시작<br/>위치</th>
                      <th>종료<br/>위치</th>
                      <th>데이타형태</th>
                      <th>소수점<br/>자리수</th>
                      <th>처리<br/>여부</th>
                      <th>DB컬럼정보</th>
                    </tr>
                  </thead>
                  <tbody id="dataArea2">
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
  <div class="modal fade" id="HospCodeModal" tabindex="-1" aria-labelledby="HospCodeModalLabel" aria-hidden="true">
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
              <input type="hidden" name="gbn" id="gbn" value="D"/>
              <input type="hidden" name="iud" id="iud" value="DI"/>
              <input type="hidden" name="code" id="code" value="SAMVER"/>
              <input type="hidden" name="cdtp" id="cdtp" value="Z"/>
              <input type="hidden" name="dupchk" id="dupchk" value="X"/>
             
            <div class="form-wrap w-70">
              <label for="" class="critical">청구 구분코드</label>
              <input type="text" name="sub_code" id="sub_code" class="form-control" placeholder="" >
              <button type="button" class="btn btn-outline-dark" id="mstdupid" onclick="fnCodeDupchk('D');">중복체크</button>
            </div>
            <div class="form-wrap w-100" id="CodeName" >
              <label for="" class="critical">청구 구분명칭</label>
              <input type="text" name="sub_code_name"  id="sub_code_name" class="form-control" placeholder="상세코드명을 입력하세요.">
            </div> 
            <div class="form-wrap w-100">
              <label for="" class="critical">적용시작일</label>
              <input type="date" name="start_dt" id="start_dt"  class="form-control" value="">  
              <label for="" class="critical">적용종료일</label>
              <input type="date" name="end_dt" id="end_dt" class="form-control" value="9999-12-31">
            </div>
            <div class="form-wrap w-100">
              <label for="">확장자범위</label>
              <input type="text" name="prop_1"  id="prop_1" class="form-control" placeholder="확장자범위">
              <label for="">확장자내용</label>
              <input type="text" name="prop_5"  id="prop_5" class="form-control" placeholder="확장자내용">
            </div>
            <div class="form-wrap w-50">
              <label for="">정렬순서</label>
              <input type="text" name="sort"  id="sort" class="form-control" placeholder="정렬순서">
            </div> 
            </form:form>
          </div>
        </div>
      </div>
    </div>
  </div>
  
  
  <div class="modal fade" id="SamVerModal" tabindex="-1" aria-labelledby="SamVerModalLabel" aria-hidden="true">
    <!-- 모달 class명으로 사이즈 조절 modal-320, 410, 520, 650, 820 -->
    <div class="modal-dialog  modal-820">
      <div class="modal-content">
        <div class="modal-footer">
          <button type="button" class="btn btn-primary btn-sm"  onclick="fnSaveSamVer();">저장</button>
          <button type="button" class="btn btn-outline-dark btn-sm" data-bs-dismiss="modal" onclick="modalClose();">목록</button>
        </div>
        <div class="modal-body">
          <div class="form-container">
          
    		<form:form commandName="VO" id="regForm2" name="regForm2" method="post" action =""> 
              <input type="hidden" name="iud" id="iud2" />
              <input type="hidden" name="samver" id="samver2" value=""/>
              <input type="hidden" name="seq" id="seq" value=""/>
              <input type="hidden" name="dupchk" id="dupchk2" value="X"/>
            <div class="form-wrap w-75">
              <label for="" class="critical">청구구분명</label>
              <select name="tblinfo" id="tblinfo" >
            	<option value="">선택</option>
            	  <c:forEach var="result" items="${tblinfoList}" varStatus="status">
	              	<option value="${result.sub_code}">${result.sub_code_nm}</option>
	              </c:forEach>
          	  </select> 
            </div>
        
            <div class="form-wrap w-50">
              <label for="" class="critical">버전</label>
              <input type="text" name="version" id="version" class="form-control" placeholder="버전정보을 입력하세요." onkeydown="javascript:fnOnlyNumber();" readonly> 
            </div>
            <div class="form-wrap w-75">
              <label for="" class="critical">항목구분명</label>
              <input type="text" name="item_nm"  id="item_nm" class="form-control" placeholder="항목구분명을 입력하세요.">
            </div> 
            <div class="form-wrap w-75" >
              <label for="" class="critical">시작위치</label>
              <input type="text" name="start_pos"  id="start_pos" class="form-control" placeholder="시작위치을 입력하세요." onkeydown="javascript:fnOnlyNumber();">
              <label for="" class="critical">종료위치</label>
              <input type="text" name="end_pos"  id="end_pos" class="form-control" placeholder="종료위치을 입력하세요." onkeydown="javascript:fnOnlyNumber();">
            </div> 
            
            <div class="form-wrap w-50">
              <label for="" class="critical">데이타형태</label>
              <select name="data_type" id="data_type" class="form-control">
            	<option value="">선택</option>
            	<option value="INT">정수형(INT)</option>  
            	<option value="VARCHAR">문자형</option>  
            	<option value="NUMERIC">정수형(NUMERIC)</option>    
            	<option value="DECIMAL">실수형(소수점포함)</option>    
           	 </select> 
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">정렬순서</label>
              <input type="text" name="sort_seq"  id="sort_seq" class="form-control" placeholder="정렬순서을 입력하세요."  onkeydown="javascript:fnOnlyNumber();">
            </div>  
            <div class="form-wrap w-25">
              <label for="">소수점위치</label>
              <input type="text" name="decimal_pos"  id="decimal_pos" class="form-control" placeholder="소수점위치을 입력하세요." onkeydown="javascript:fnOnlyNumber();">
            </div> 
            
            <div class="form-wrap">
              <label for="" class="critical">데이타처리여부</label>
              <input type="radio" name="dataproc_yn"  id="dataprocyn1"  placeholder="" value="Y" checked>처리
              <input type="radio" name="dataproc_yn"  id="dataprocyn2"  placeholder="" value="N" >미처리
            </div>
                 
            <div class="form-wrap w-100">
              <label for="">DB컬럼정보</label> 
              <input type="text" name="db_colnm"  id="db_colnm"  class="form-control" placeholder="컬럼정보을 입력하세요">
              <button type="button" class="btn btn-outline-dark" id="dupdbcolid"  onclick="fnSamDupchk();" disabled>컬럼중복체크</button>
            </div> 
            </form:form>
          </div>
        </div>
      </div>
    </div>
  </div>
</body>
</html>