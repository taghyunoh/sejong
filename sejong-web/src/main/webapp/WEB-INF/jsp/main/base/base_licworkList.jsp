<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%> 
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>  
<%@ page import = "java.util.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script src="/js/main.js"></script>
<script type="text/javaScript"> 

function fnSearch(){
	
	$("#jobworkList").empty();
/*	
	if($("#ncis").val() == ""){
		alert("요양기관정보를 선택하세요.");
		$("#ncis").focus();
		return;
	}
	if ($("#start_date").val() > $("#end_date").val()){
		alert("조회시작일은 종료일보다 낮을 수 없습니다. 다시 선택해주세요.");
		return;
	}
*/	
	$.ajax({
		type : 'post',
		url : CommonUtil.getContextPath() + '/base/ctl_licworkList.do',
		data : { 
			    user_nm: $("#user_nm").val()
			   },
		dataType : "json",
		success : function(data) {
            if (data.error_code != "0") {
                alert("데이터 로드 중 오류가 발생했습니다. 에러 코드: " + data.error_code);
                return;
            }
            if (!data.resultLst || !Array.isArray(data.resultLst)) {
                alert("결과 데이터가 없습니다.");
                return;
            }

            if (data.resultCnt > 0) {
				var dataTxt = "";
				for (var i = 0; i < data.resultCnt; i++) {
					dataTxt = '<tr class="" onclick="javascript:fnDtlSearch(\'' 
    				    + data.resultLst[i].hosp_uuid + '\', \''
    		            + data.resultLst[i].seq    + '\');" id="row_'
    		            + data.resultLst[i].hosp_uuid 
    		            + data.resultLst[i].seq + '">';					
					dataTxt += "<td>" + (i+1)	 + "</td>";
					dataTxt += "<td>" + data.resultLst[i].seq			  + "</td>";
					dataTxt += "<td>" + data.resultLst[i].hosp_nm	      + "</td>";
					dataTxt += "<td>" + data.resultLst[i].sub_dep_nm      + "</td>";
					dataTxt += "<td>" + data.resultLst[i].lic_detail	  + "</td>";
					dataTxt += "<td>" + data.resultLst[i].user_nm		  + "</td>";
					dataTxt += "<td>" + data.resultLst[i].lic_num		  + "</td>";
					dataTxt += "<td>" + data.resultLst[i].sub_code_nm	  + "</td>";
					dataTxt += "<td>" + data.resultLst[i].vac_start_dt    + "</td>";
					dataTxt += "<td>" + data.resultLst[i].vac_end_dt	  + "</td>";
					dataTxt += "<td>" + data.resultLst[i].sub_name		  + "</td>";
					dataTxt += "<td>" + data.resultLst[i].sub_start_dt    + "</td>";
					dataTxt += "<td>" + data.resultLst[i].sub_end_dt	  + "</td>";
					dataTxt += "<td>" + data.resultLst[i].ward_nm	      + "</td>";
					dataTxt += "<td>" + data.resultLst[i].ward_dan		  + "</td>";
					dataTxt += "<td>" + data.resultLst[i].ward_start_dt	  + "</td>";
					dataTxt += "<td>" + data.resultLst[i].ward_end_dt	  + "</td>";
					dataTxt += "<td>" + data.resultLst[i].ecch_yn		  + "</td>";
					dataTxt += "<td>" + data.resultLst[i].te_dt	          + "</td>"; 
					dataTxt += "<td>" + data.resultLst[i].upd_dttm	      + "</td>"; 
					dataTxt += "</tr>";
					$("#jobworkList").append(dataTxt);
				} 
				 
			} else {
				$("#jobworkList").append("<tr><td colspan='20'>자료가 존재하지 않습니다.</td></tr>");
			}				
		}   
	});	
	
}
 
function fnDtlSearch(hosp_uuid ,seq){ 
	if (!hosp_uuid || !seq ) return;
	document.regForm.iud.value  = "U";
	document.regForm.hosp_uuid.value  = hosp_uuid ; 
	document.regForm.seq.value        = seq ; 

    $("#infoTable tr").removeClass("tr-primary");
    $("#infoTable #row_" + hosp_uuid + seq).addClass("tr-primary");
}
function fnSave(iud){
	$("#iud").val(iud);  // 입력(I), 수정(U), 삭제(D) 
	uidGubun = iud ;
	if(iud == "I"){
		//등록폼 초기화
		document.getElementById("regForm").reset();
		setCurrDate("start_dt");
		$("#end_dt").val("2099-12-31");
		$("#hosp_cd").prop("readonly","true");
		$("#ip_dt").prop("readonly","true");
		$("#te_dt").prop("readonly","true");
		$("#user_nm").prop("readonly","");
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
		modalOpen();
		
	}else if(iud == "U"){
		
		if ($("#hosp_uuid").val() == "" || $("#seq").val() == "" ){
			alert("선택된  정보가 없습니다.!");
			return;
		}

		modalClose() ;
		
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/base/selectlicworkInfo.do",
			data : {hosp_uuid: $("#hosp_uuid").val() , seq : $("#seq").val()},
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				$("#seq").val(data.result.seq);
				$("#user_id").val(data.result.user_id);
				$("#lic_num").val(data.result.lic_num);
				$("#user_nm").val(data.result.user_nm);
				$("#lic_type").val(data.result.lic_type);
				$("#lic_detail").val(data.result.lic_detail);
				$("#hosp_cd").val(data.result.hosp_cd);
				$("#vac_gb").val(data.result.vac_gb);
				$("#ip_dt").val(data.result.ip_dt);
				$("#te_dt").val(data.result.te_dt);
				$("#start_dt").val(data.result.start_dt);
				$("#end_dt").val(data.result.end_dt);
				$("#vac_start_dt").val(data.result.vac_start_dt);
				$("#vac_end_dt").val(data.result.vac_end_dt);
				$("#sub_name").val(data.result.sub_name);	
				$("#sub_dep_nm").val(data.result.sub_dep_nm);	
				$("#sub_start_dt").val(data.result.sub_start_dt);
				$("#sub_end_dt").val(data.result.sub_end_dt);
				$("#ward_nm").val(data.result.ward_nm);				
				$("#ward_dan").val(data.result.ward_dan);
				$("#ward_start_dt").val(data.result.ward_start_dt);
				$("#ward_end_dt").val(data.result.ward_end_dt);				
				$("#ecch_yn").val(data.result.ecch_yn);	
				$("#hosp_cd").prop("readonly","true");
				$("#lic_num").prop("readonly","true");
				$("#user_nm").prop("readonly","true");
				$("#ip_dt").prop("readonly","true");
				$("#te_dt").prop("readonly","true");
			}
		});
		modalOpen();
	}else
		return;
	}
function fnSaveProc(){
	if(!fnRequired('lic_num', '면허번호를  확인하세요.'))  return;
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
			url : CommonUtil.getContextPath() + "/base/licworkSaveAct.do",
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
function ExcelModalOpen() {  
	if($("#hosp_uuid").val() == ""){
		alert("요양기관정보를 선택하세요.");
		$("#hosp_uuid").focus();
		return;
	}
	var popupwidth = '730';
	var popupheight = '200';  
	var url = "/popup/DrgExcelPopup.do?ncis="+$("#ncis").val() ;     
	 		
	var LeftPosition = (window.screen.width -popupwidth)/2;
	var TopPosition  = (window.screen.height-popupheight)/2; 
	 
	var oPopup = window.open(url,"엑셀창","width="+popupwidth+",height="+popupheight+",top="+TopPosition+",left="+LeftPosition+", scrollbars=no");
	if(oPopup){oPopup.focus();}
}
//엑셀 서식 자료 다운
function exDown(){
 	document.location.href = '/document/의약사현황_Sample.xls';
}
function searchHospemp(event) {
	event.preventDefault();  // 폼 제출을 방지
	document.getElementById('licnmResults').style.display = 'block'; // 모달 열기 
	if(!fnRequired('user_nm', '성명을 입력해주세요.'))  return;
    $.ajax({
        url: CommonUtil.getContextPath() +  "/base/ctl_licnmList.do",
        type: "post",
        data: {user_nm: $("#user_nm").val() },
		dataType : "json",
		success: function(data) {
		    if (data.error_code === "0") {
		        // 결과 처리             
		        const resultLst = data.resultLst;
		        const tbody = document.getElementById('licnmResults');
		        tbody.innerHTML = ''; // 기존의 테이블 내용 초기화

		        resultLst.forEach(hospemp => {
		            const row = document.createElement('tr'); // 새로운 tr 요소 생성
		            const cell1 = document.createElement('td'); // 면허번호 td
		            const cell2 = document.createElement('td'); // 성명 td
		            const cell3 = document.createElement('td'); // 성명 td
		            const cell4 = document.createElement('td'); // 입사일 td
		            const cell5 = document.createElement('td'); // 종료일 td
		            const cell6 = document.createElement('td'); // 종료일 td
		            // 병원 정보 넣기
		            cell1.textContent = hospemp.lic_num;
		            cell2.textContent = hospemp.user_nm;
		            cell3.textContent = hospemp.sub_code_nm;
		            cell4.textContent = hospemp.ip_dt;
		            cell5.textContent = hospemp.te_dt;
		            cell6.textContent = hospemp.lic_detail;
		            // tr에 td 추가
		            row.appendChild(cell1);
		            row.appendChild(cell2);
		            row.appendChild(cell3);
		            row.appendChild(cell4);
		            row.appendChild(cell5);
		            row.appendChild(cell6);
                    // 병원 선택 이벤트 추가
                    row.addEventListener('click', function () {
                        document.getElementById('lic_num').value = hospemp.lic_num;
                        document.getElementById('user_nm').value = hospemp.user_nm;
                        document.getElementById('sub_dep_nm').value = hospemp.sub_code_nm;
                        document.getElementById('ip_dt').value = hospemp.ip_dt;
                        document.getElementById('te_dt').value = hospemp.te_dt;
                        document.getElementById('lic_detail').value = hospemp.lic_detail;
                        document.getElementById('licnmResults').style.display = 'none'; // 모달 닫기
                    });
		            // tbody에 tr 추가
		            tbody.appendChild(row);
		        });
		    } else {
		    	$("#licnmResults").append("<tr><td colspan='12'>검색된 정보가 없습니다.</td></tr>");
		    }
		},
		error: function() {
		    alert('AJAX 요청 중 문제가 발생했습니다.');
		}
    });
}
</script>
</head>
<body>
   <div class="tab-pane">  
      <div class="content-body">
    <!--   <div class="content-wrap">   마킹하면  화면 넓히기  -->
        <section class="top-pannel upload">
          <div class="search-box">
			<label class="form-title">의사명</label>
			<input type="text" name="user_nm1" id="user_nm1" class="form-control" value=""> &nbsp;&nbsp;
			<label class="form-title">등록일</label>
			<input type="date" name="start_dt" id="start_dt" class="form-control" value=""> 
			<label class="form-title">~</label>
			<input type="date" name="end_dt" id="end_dt" class="form-control" value="">
			<button class="buttcon" onclick="fnSearch();"><span class="icon icon-search"></span>
			</button>
			<button class="btn btn-outline-dark btn-sm" onclick="fnSave('U');">수정</button>								
			<button class="btn btn-primary btn-sm"      onclick="fnSave('I');">입력</button>
            <button type="button" class="btn btn-outline-dark" onclick="exDown();">서식다운로드</button>
	        <button type="button" class="btn btn-primary"  onclick="ExcelModalOpen();">엑셀업로드</button>
  		</div>
        </section>
        <section class="main-pannel">
          <div class="main-left w-100">
            
            <header class="main-hd">
              <h2>의약사현황 목록</h2>
              </header>
            <div class="main-content">
              <!-- 테이블 샘플 -->
              <div class="table-responsive">
                <table class="table table-bordered" id="infoTable">
                  <colgroup>
                    <col style="width: 50px">
                    <col style="width: 50px">
                    <col style="width: 50px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 50px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 80px"> 
                    <col style="width: 50px"> 
                    <col style="width: 80px">
                    <col style="width: 100px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th rowspan="2">번호</th>
                      <th rowspan="2">순번</th>
                      <th rowspan="2">요양기관명</th>
                      <th rowspan="2">면허종별</th>
                      <th rowspan="2">의사형태</th>
                      <th rowspan="2">성명</th>
                      <th rowspan="2">면허번호</th>
                      <th colspan="3">휴가(교육, 연수, 파견)</th>
                      <th colspan="3">휴가대체정보</th>
                      <th colspan="5">근무병동정보</th>
                      <th rowspan="2">퇴사일자</th> 
                      <th rowspan="2">등록일시</th> 
                    </tr>
                    <tr>
                      <th>구분</th>                      
                      <th>시작일자</th>                      
                      <th>종료일자</th>
                      <th>대체자명</th>
                      <th>대체시작일자</th>
                      <th>대체종료일자</th>
                      <th>병동명</th>
                      <th>단위</th>
                      <th>시작일자</th>
                      <th>종료일자</th>
                      <th>전담<br/>여부</th>
                    </tr>
                  </thead>
                  <tbody id="jobworkList">
                  	<tr><td colspan="20">&nbsp;</td></tr> 
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </section>
   <!--      </div>  -->
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
              <input type="hidden" name="seq" id="seq" />
              <input type="hidden" name="upd_user" id="upd_user" value = "1111"/>
              <input type="hidden" name="hosp_uuid" id="hosp_uuid" value = "${sessionScope['q_uuid']}" />
        <div class="modal-body">
          <div class="form-container"> 
            <div class="form-wrap w-50">
              <label for="" class="critical">요양기관</label>
              <input type="text" name="hosp_cd" id="hosp_cd" class="form-control" placeholder="요양기관를 입력하세요.">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">성명</label>
              <input type="text" name="user_nm" id="user_nm" class="form-control" placeholder="성명을 입력하세요.">
              <button class="button" onclick="searchHospemp(event)">
				    <span class="icon icon-search"></span>
			  </button>	
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">입사일자</label>
              <input type="text" name="ip_dt" id="ip_dt" class="form-control" >
            </div>     
            <div class="form-wrap w-50">
              <label for="" class="critical">퇴사일자</label>
              <input type="text" name="te_dt" id="te_dt" class="form-control">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">면허번호</label>
              <input type="text" name="lic_num" id="lic_num" class="form-control" placeholder="면허번호를 입력하세요">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">의사형태</label>
              <input type="text" name="sub_dep_nm" id="sub_dep_nm" class="form-control" >
            </div>	
            <div class="form-wrap w-100">
	     		<table class="table">
		     	    <tbody id="licnmResults">
				    </tbody>
				</table>
			</div>
	
           <div class="form-wrap w-50">
	           <label for="">휴가종류</label> 
	            <select class="form-select" name="vac_gb" id="vac_gb"> <!-- readonly -->
	                <option value="">선택</option> 
	                <c:forEach var="result" items="${commList}" varStatus="status">
	                   <option value="${result.sub_code}">${result.sub_code_nm}</option>
	                </c:forEach> 
	           </select>
           </div>  
            <div class="form-wrap w-50">
              <label for="" class="critical">면허세부내용</label>
              <input type="text" name="lic_detail" id="lic_detail" class="form-control" placeholder="면허세부내용을 입력하세요.">
            </div>
         
            <div class="form-wrap w-50">
              <label for="" class="critical">휴가시작일</label>
              <input type="text" name="vac_start_dt" id="vac_start_dt" class="form-control" placeholder="류가시작일자를  입력하세요.">
            </div>     
            <div class="form-wrap w-50">
              <label for="" class="critical">휴가종료일</label>
              <input type="text" name="vac_end_dt" id="vac_end_dt" class="form-control" placeholder="류가종료일자를  입력하세요.">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">대체자명</label>
              <input type="text" name="sub_name" id="sub_name" class="form-control" placeholder="대체자명를 입력하세요.">
            </div>  
            <div class="form-wrap w-50">
              <label for="" class="critical">대체시작일</label>
              <input type="text" name="sub_start_dt" id="sub_start_dt" class="form-control" placeholder="대체시작일를 입력하세요.">
            </div> 
            <div class="form-wrap w-50">
              <label for="" class="critical">대체종료일</label>
              <input type="text" name="sub_end_dt" id="sub_end_dt" class="form-control" placeholder="대체종료일를 입력하세요.">
            </div> 
            <div class="form-wrap w-50">
              <label for="" class="critical">병동구분</label>
              <input type="text" name="ward_nm" id="ward_nm" class="form-control" placeholder="병동구분을 입력하세요.">
            </div> 
            <div class="form-wrap w-50">
              <label for="" class="critical">단위</label>
              <input type="text" name="ward_dan" id="ward_dan" class="form-control" placeholder="단위를 입력하세요.">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">병동시작일자</label>
              <input type="text" name="ward_start_dt" id="ward_start_dt" class="form-control" placeholder="병동시작일자를 입력하세요.">
            </div> 
            <div class="form-wrap w-50">
              <label for="" class="critical">병동종료일자</label>
              <input type="text" name="ward_end_dt" id="ward_end_dt" class="form-control" placeholder="병동종료일자를 입력하세요.">
            </div> 
            <div class="form-wrap w-50">
              <label for="" class="critical">전담여부</label>
              <input type="text" name="ecch_yn" id="ecch_yn" class="form-control" placeholder="전담여부를 입력하세요.">
            </div>            
          </div> 
        </div>
        </form:form>
      </div>
    </div>
  </div>       
</body>
</html>