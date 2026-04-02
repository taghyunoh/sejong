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
<script type="text/javaScript"> 
//조회한 리스트 엑셀 다운
var totCnt   = 0  ;
function ExcelDownLoad() { 
	 if(totCnt > 0){
   	    location.href =  "/base/doctListExcelDown.do" ;
	 }
 } 
function ExcelModalOpen() { 
	var popupwidth = '730';
	var popupheight = '200';  
	var url = "/popup/doctExcelPopup.do";   
	 		
	var LeftPosition = (window.screen.width -popupwidth)/2;
	var TopPosition  = (window.screen.height-popupheight)/2; 
	 
	var oPopup = window.open(url,"엑셀창","width="+popupwidth+",height="+popupheight+",top="+TopPosition+",left="+LeftPosition+", scrollbars=no");
	if(oPopup){oPopup.focus();}
}

function fnSearch() {

	$("#infoTable tr").attr("class", ""); 
// 	if($('#searchText').val() == "") {
// 		alert("검색어를 입력하세요.");
// 		$('#searchText').focus();
// 		return; 
// 	}
	 $("#doctList").empty();
	 
	 $.ajax({
    	url : CommonUtil.getContextPath() + 'base/selectHospEmpList.do',
        type : 'post',
        data : { user_nm : $("#searchText").val()} ,
    	dataType : "json",
    	success : function(data) {
    		if(data.error_code != "0") return;
    		if(data.resultCnt > 0 ){
	    		var dataTxt = "";
	    		for(var i=0 ; i < data.resultCnt; i++){
					dataTxt = '<tr>'; 
	    			dataTxt = '<tr class="" onclick="javascript:fnDtlSearch(\'' 
    				    + data.resultLst[i].hosp_uuid + '\', \''
    		            + data.resultLst[i].lic_num   + '\', \''
    		            + data.resultLst[i].ip_dt    + '\');" id="row_'
    		            + data.resultLst[i].hosp_uuid 
    		            + data.resultLst[i].lic_num 
    		            + data.resultLst[i].ip_dt + '">';
    		            
					dataTxt += 	"<td>" + (i+1)  + "</td>" ; 
					dataTxt +=  "<td>" + data.resultLst[i].hosp_nm      + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].lic_num      + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].user_nm      + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].lic_num      + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].lic_type     + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].sub_code_nm  + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].ip_dt        + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].te_dt        + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].lic_detail   + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].lic_str_dt   + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].jumin_id     + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].use_yn       + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].dept_code    + "</td>" ;
					dataTxt +=	"<td>" + data.resultLst[i].dept_name    + "</td>" ;
					dataTxt +=	"<td>" + data.resultLst[i].start_dt     + "</td>" ;
					dataTxt +=	"<td>" + data.resultLst[i].end_dt       + "</td>" ;
					dataTxt +=	"<td>" + data.resultLst[i].upd_dttm     + "</td>" ;
					dataTxt +=  "</tr>";
 	            $("#doctList").append(dataTxt);
         	 }
	 	  }else{
				 $("#doctList").append("<tr><td colspan='12'>자료가 존재하지 않습니다.</td></tr>");
			}
       }
    });
}
//엑셀 서식 자료 다운
function exDown(){
	document.location.href = '/document/의사정보SAMPLE.xlsx';
} 

function fnDtlSearch(hosp_uuid ,lic_num , ip_dt){ 
	if (!hosp_uuid || !lic_num || !ip_dt) return;
	document.regForm.iud.value  = "U";
	document.regForm.hosp_uuid.value  = hosp_uuid ; 
	document.regForm.lic_num.value    = lic_num ; 
	document.regForm.ip_dt.value      = ip_dt ; 

    $("#infoTable tr").removeClass("tr-primary");
    $("#infoTable #row_" + hosp_uuid + lic_num + ip_dt).addClass("tr-primary");
}

//입력,수정 , 비밀번호 초기화  버큰 클릭시
function fnSave(iud){
	$("#iud").val(iud);  // 입력(I), 수정(U), 삭제(D) 
	uidGubun = iud ;
	if(iud == "I"){
		//등록폼 초기화
		document.getElementById("regForm").reset();
		setCurrDate("start_dt");
		$("#end_dt").val("2099-12-31");
		$("#hosp_cd").prop("readonly","true");
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
		$("#lic_num").prop("readonly","");
		$("#ip_dt").prop("readonly","");
		modalOpen();
		
	}else if(iud == "U"){
		
		if ($("#lic_num").val() == "" || $("#hosp_uuid").val() == "" ){
			alert("선택된  정보가 없습니다.!");
			return;
		}

		modalClose() ;
		
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/base/selectHospEmpInfo.do",
			data : {hosp_uuid: $("#hosp_uuid").val() , lic_num : $("#lic_num").val(), ip_dt : $("#ip_dt").val() },
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				$("#user_id").val(data.result.user_id);
				$("#user_nm").val(data.result.user_nm);
				$("#lic_type").val(data.result.lic_type);
				$("#lic_detail").val(data.result.lic_detail);
				$("#lic_str_dt").val(data.result.lic_str_dt);
				$("#jumin_id").val(data.result.jumin_id);
				$("#hosp_cd").val(data.result.hosp_cd);
				$("#use_yn").val(data.result.use_yn);
				$("#te_dt").val(data.result.te_dt);
				$("#start_dt").val(data.result.start_dt);
				$("#end_dt").val(data.result.end_dt);
				$("#dept_code").val(data.result.dept_code);
				$("#dept_name").val(data.result.dept_name);
				$("#hosp_cd").prop("readonly","true");
				$("#lic_num").prop("readonly","true");
				$("#ip_dt").prop("readonly","true");
			}
		});
		modalOpen();
	}else
		return;
	}
function fnSaveProc(){
	if(!fnRequired('user_id', '아이디를  확인하세요.'))  return;
	if(!fnRequired('user_nm', '성명을 확인 하세요.'))   return;
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
			url : CommonUtil.getContextPath() + "/base/HospEmpSaveAct.do",
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
      <!--  <div class="content-wrap">   마킹하면  화면 넓히기  -->
        <section class="top-pannel">
          <div class="search-box"> 
            <label class="form-title">대상병원</label>
            <select name="ncis" id="ncis" class="form-select" aria-label="Default select example" onchange="reset();">
              <option value="">선택</option>
              <c:forEach var="result" items="${ncisList}" varStatus="status">
              	<option value="${result.ncis}" <c:if test="${sessionScope['q_ncis'] == result.ncis}">selected</c:if> >${result.hsptnm}</option>
              </c:forEach>
            </select>&nbsp;&nbsp; 
            <label for="search" class="form-title">검색어 입력</label>
            <input name="searchText" id="searchText" type="text" class="form-control search" placeholder="의사명 또는 면허번호을 입력하세요" onkeypress="if( event.keyCode == 13 ){fnSearch();}">
            <button class="buttcon" onclick="fnSearch();"><span class="icon icon-search"></span></button>
          </div>
        </section>
        <section class="main-pannel">
          <div class="main-left w-100">
            <header class="main-hd">
              <h2>의사 정보 목록</h2>
              <div class="btn-box">
				 <button class="btn btn-outline-dark btn-sm" onclick="fnSave('U');">수정</button>								
				 <button class="btn btn-primary btn-sm"      onclick="fnSave('I');">입력</button>
            	 <button type="button" class="btn btn-outline-dark" onclick="exDown();">서식다운로드</button>
             	 <button type="button" class="btn btn-primary"  onclick="ExcelModalOpen();">엑셀업로드</button>
             	 <button type="button" class="btn btn-dark" onclick="ExcelDownLoad();">엑셀다운로드</button>
          	</div>
            </header>
            <div class="main-content">
              <!-- 테이블 샘플 -->
              <div class="table-responsive">
                <table class="table table-bordered" id="infoTable">
                  <colgroup>
                  	<col style="width: 50px">
                    <col style="width: 200px">
                    <col style="width: 100px">
                    <col style="width: 100px">
                    <col style="width: 50px">
                    <col style="width: auto; min-width: 50px">
                    <col style="width: 100px">
                    <col style="width: 100px">
                    <col style="width: 150px">
                    <col style="width: 100px">
                    <col style="width: 100px">
                    <col style="width: 50px">
                    <col style="width: 120px">
                    <col style="width: 120px">
                    <col style="width: 120px">   
                    <col style="width: 120px">
                    <col style="width: 100px">  
                    <col style="width: 120px">                                     
                  </colgroup>
                  <thead>
                    <tr>
                      <th>번호</th>
                      <th>요양기관명</th>
                      <th>면허번호</th>
                      <th>성명</th>
                      <th>병원사번</th>
                      <th>구분</th>
                      <th>면허구분</th>
                      <th>입사일자</th>
                      <th>퇴사일자</th>
                      <th>세부내용</th>
                      <th>면허취득일</th>
                      <th>주민번호</th>
                      <th>사용여부</th>  
                      <th>진료과</th>     
                      <th>진료과명</th>   
                      <th>적용시작일</th>
                      <th>적용종료일</th>
                      <th>등록일자</th>
                    </tr>
                  </thead>
                  <tbody id="doctList">
                    <tr>
                      <td colspan="17">&nbsp;</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </section>
      <!-- </div>   마킹하면  화면 넓히기  -->
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
            <div class="form-wrap w-50">
              <label for="" class="critical">면허번호</label>
              <input type="text" name="lic_num" id="lic_num" class="form-control" placeholder="면하번호를 입력하세요">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">입사일자</label>
              <input type="text" name="ip_dt" id="ip_dt" class="form-control" placeholder="입사일자를 입력하세요.">
            </div>   
             <div class="form-wrap w-50">
              <label for="" class="critical">성명</label>
              <input type="text" name="user_nm" id="user_nm" class="form-control" placeholder="성명을 입력하세요.">
            </div>
           <div class="form-wrap w-50">
	           <label for="">면허종류</label> 
	            <select class="form-select" name="lic_type" id="lic_type"> <!-- readonly -->
	                <option value="">선택</option> 
	                <c:forEach var="result" items="${commList}" varStatus="status">
	                   <option value="${result.sub_code}">${result.sub_code_nm}</option>
	                </c:forEach> 
	           </select>
           </div>  
            <div class="form-wrap w-50">
              <label for="" class="critical">주민번호</label>
              <input type="text" name="jumin_id" id="jumin_id" class="form-control" placeholder="주민번호를 입력하세요.">
            </div>
            <div class="form-wrap w-100">
              <label for="" class="critical">면허세부내용</label>
              <input type="text" name="lic_detail" id="lic_detail" class="form-control" placeholder="면허세부내용을 입력하세요.">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">아이디</label>
              <input type="text" name="user_id" id="user_id" class="form-control" placeholder="아이디를  입력하세요.">
            </div>     
            <div class="form-wrap w-50">
              <label for="" class="critical">퇴사일자</label>
              <input type="text" name="te_dt" id="te_dt" class="form-control" placeholder="퇴사일자를 입력하세요.">
            </div>  
            <div class="form-wrap w-50">
              <label for="" class="critical">진료과</label>
              <input type="text" name="dept_code" id="dept_code" class="form-control" placeholder="진료과를 입력하세요.">
            </div> 
            <div class="form-wrap w-50">
              <label for="" class="critical">진료과명</label>
              <input type="text" name="dept_name" id="dept_name" class="form-control" placeholder="진료과명을 입력하세요.">
            </div> 	
            <div class="form-wrap w-50">
              <label for="" class="critical">통계용명칭</label>
              <input type="text" name="stat_name" id="stat_name" class="form-control" placeholder="통계용명칭을 입력하세요.">
            </div> 
            <div class="form-wrap w-50">
              <label for="" class="critical">자격취득일</label>
              <input type="text" name="lic_str_dt" id="lic_str_dt" class="form-control" placeholder="자격취득일를 입력하세요.">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">적용시작일</label>
              <input type="text" name="start_dt" id="start_dt" class="form-control" placeholder="적용시작일를 입력하세요.">
            </div>    
            <div class="form-wrap w-50">
              <label for="" class="critical">적용종료일</label>
              <input type="text" name="end_dt" id="end_dt" class="form-control" placeholder="적용종료일를 입력하세요.">
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