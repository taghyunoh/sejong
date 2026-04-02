<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ page import = "java.util.*" %>
<style>
</style>
<html>
<head> 
<script src="/js/main.js"></script> 
<script type="text/javaScript"> 
var diseModal = new bootstrap.Modal(document.getElementById('diseModal')); 
var uidGubun = "" ;

var pageIndex = 1; // 페이지 인덱스 초기값
var pageSize = 13; // 페이지 크기

function fnSearch(){
    $("#infoTable tr").attr("class", "");
    document.getElementById("regForm").reset();
    $("#dataArea").empty();
	if($('#searchtext').val() == "") {
		alert("검색어를 입력하세요.");
		$('#searchtext').focus();
		return; 
	}
	$.ajax( {
		url : CommonUtil.getContextPath() + "/base/ctl_diseList.do" ,
		type : "post",  
		data : {
			    kor_diag_name : $("#searchtext").val(),
                pageIndex: pageIndex,
                pageSize: pageSize
		},
		dataType : "json",
		success : function(data) {   
			if(data.error_code != "0")   return;
			
			$("#totalCnt").text(data.totalCnt);
		
			if (data.resultCnt > 0) {
                var startIndex = (pageIndex - 1) * pageSize + 1; // 페이지 인덱스에 맞는 시작 인덱스 계산
                var dataTxt = "";
                for (var i = 0; i < data.resultCnt; i++) {
                    dataTxt = '<tr class="" onclick="javascript:fnDtlSearch(\'' 
                    		+ data.resultLst[i].diag_code + '\', \'' + data.resultLst[i].start_dt + '\');" id="row_' 
                            + data.resultLst[i].diag_code + data.resultLst[i].start_dt + '">';
                    
					dataTxt += "<td>" + (startIndex + i) + "</td>"; // 올바른 인덱스 표시
					dataTxt += "<td>"+ data.resultLst[i].diag_code+"</td>";
					dataTxt += "<td>"+ data.resultLst[i].start_dt +"</td>";
					dataTxt += "<td class='txt-left ellips'>" +  data.resultLst[i].kor_diag_name+"</td>";
					dataTxt += "<td class='txt-left ellips'>" +  data.resultLst[i].eng_diag_name+"</td>";
					dataTxt += "<td>"+ data.resultLst[i].gender_type +"</td>";
					dataTxt += "<td>"+ data.resultLst[i].infect_type +"</td>";
					dataTxt += "<td>"+ data.resultLst[i].diag_type +"</td>";
					dataTxt += "<td>"+ data.resultLst[i].icd10_code +"</td>";
					dataTxt += "<td>"+ data.resultLst[i].vcode +"</td>";
					dataTxt += "<td>"+ data.resultLst[i].end_dt +"</td>";
					dataTxt += "</tr>"; 
	                $("#dataArea").append(dataTxt);
                }
                createPagination(data.totalCnt, pageIndex, pageSize); // 페이징 생성
            } else {
                $("#dataArea").append("<tr><td colspan='12'>검색된 정보가 없습니다.</td></tr>");
            }
		 }
     });
 }
function createPagination(totalItems, currentPage, pageSize) {
    const totalPages = Math.ceil(totalItems / pageSize); // 전체 페이지 수 계산
    const pagination = document.getElementById('pagination');
    pagination.innerHTML = ''; // 기존 버튼 초기화

    const maxPageButtons = 10; // 한 번에 표시할 페이지 번호 개수
    const currentGroup = Math.ceil(currentPage / maxPageButtons); // 현재 페이지 그룹
    const startPage = (currentGroup - 1) * maxPageButtons + 1; // 그룹의 시작 페이지
    const endPage = Math.min(startPage + maxPageButtons - 1, totalPages); // 그룹의 마지막 페이지

    // 이전 그룹 버튼
    if (startPage > 1) {
        const prevGroupButton = document.createElement('button');
        prevGroupButton.innerText = '이전 그룹';
        prevGroupButton.onclick = () => loadPage(startPage - 1, pageSize); // 이전 그룹의 마지막 페이지로 이동
        pagination.appendChild(prevGroupButton);
    }

    // 이전 버튼
    const prevButton = document.createElement('button');
    prevButton.innerText = '이전';
    prevButton.disabled = currentPage === 1; // 첫 페이지에서는 비활성화
    prevButton.onclick = () => loadPage(currentPage - 1, pageSize); // 이전 페이지로 이동
    pagination.appendChild(prevButton);

    // 페이지 번호 버튼
    for (let i = startPage; i <= endPage; i++) {
        const pageButton = document.createElement('button');
        pageButton.innerText = i;
        pageButton.className = currentPage === i ? 'active' : ''; // 현재 페이지 활성화
        pageButton.onclick = () => loadPage(i, pageSize); // 해당 페이지로 이동
        pagination.appendChild(pageButton);
    }

    // 다음 버튼
    const nextButton = document.createElement('button');
    nextButton.innerText = '다음';
    nextButton.disabled = currentPage === totalPages; // 마지막 페이지에서는 비활성화
    nextButton.onclick = () => loadPage(currentPage + 1, pageSize); // 다음 페이지로 이동
    pagination.appendChild(nextButton);

    // 다음 그룹 버튼
    if (endPage < totalPages) {
        const nextGroupButton = document.createElement('button');
        nextGroupButton.innerText = '다음 그룹';
        nextGroupButton.onclick = () => loadPage(endPage + 1, pageSize); // 다음 그룹의 첫 페이지로 이동
        pagination.appendChild(nextGroupButton);
    }

    // 현재 페이지 버튼 활성화 스타일 추가
    const allButtons = pagination.querySelectorAll('button');
    allButtons.forEach(button => {
        if (parseInt(button.innerText) === currentPage) {
            button.classList.add('active'); // 현재 페이지 활성화
        } else {
            button.classList.remove('active'); // 나머지 버튼 비활성화
        }
    });
}

// 페이지 이동 함수 수정
function loadPage(pageNumber, pageSize) {
    pageIndex = pageNumber; // 페이지 번호 업데이트
    createPagination(100, pageIndex, pageSize); // 페이지네이션 재생성
    if ($('#searchtext').val() != "") {
        fnSearch(); // 페이지 로드 후 검색 함수 호출
    }
}

// 초기 페이지 로드
loadPage(1, 13);
 
function fnDtlSearch(diag_code , start_dt ){ 

	if (!diag_code || !start_dt) return; // 유효성 검사
	 
	document.regForm.iud.value  = "U";
	document.regForm.diag_code.value = diag_code ; 
	document.regForm.start_dt.value  = start_dt ; 

	//row 클릭시 바탕색 변경 처리 Start 
    $("#infoTable tr").removeClass("tr-primary");
    $("#infoTable #row_" + diag_code + start_dt).addClass("tr-primary");
	 
}
function fnsave(iud){
	$("#iud").val(iud);  // 입력(I), 수정(U), 삭제(D) 
	uidGubun = iud ;
	if(iud == "I"){
		document.getElementById("regForm").reset();
		setCurrDate("start_dt");
		$("#end_dt").val("9999-12-31");
		$("#dupchkbtn").prop("style","");
		$("#dupchk").val("X");
		$("#diag_code").prop("readonly","");
		$("#start_dt").prop("readonly","");
		diseModal.show();
		
	}else if(iud == "U" || iud == "D" ){
		if(!fnRequired('diag_code', '상병코드를 확인하세요.')) return;
		if(!fnRequired('start_dt', '적용일자를 확인하세요.')) return;
		$("#diag_code").prop("readonly","true");
		$("#dupchkbtn").prop("style","display:none");
		$("#dupchk").val("N");
		$("#start_dt").prop("readonly","");
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/base/ctl_DiseInfo.do",
			data : {diag_code : $("#diag_code").val() , start_dt : $("#start_dt").val()  },
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				$("#diag_code").val(data.result.diag_code);
				$("#start_dt").val(data.result.start_dt);
				$("#kor_diag_name").val(data.result.kor_diag_name);
				$("#eng_diag_name").val(data.result.eng_diag_name);
				$("#gender_type").val(data.result.gender_type);
				$("#infect_type").val(data.result.infect_type);
				$("#diag_type").val(data.result.diag_type);
				$("#icd10_code").val(data.result.icd10_code);
				$("#max_age").val(data.result.max_age);
				$("#min_age").val(data.result.min_age);
				$("#vcode").val(data.result.vcode);
				$("#end_dt").val(data.result.end_dt);
				$("#diag_code").prop("readonly", "true");
				$("#start_dt").prop("readonly", "true");
			}
		});
	}	
	diseModal.show();
}
function fnSaveProc(){
	if(!fnRequired('diag_code', '진단코드를 확인하세요.')) return;
	if(!fnRequired('kor_diag_name', '상병 한글명을 확인하세요.')) return;
	if(!fnRequired('eng_diag_name', '상병 영문명을 확인하세요.')) return;
	if(!fnRequired('start_dt', '적용시작일자 정보를 확인하세요.')) return;
	if(!fnRequired('end_dt', '적용종료일자 정보를 확인하세요.')) return;
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
			type : "post",
			url : CommonUtil.getContextPath() + "/base/ctl_DiseSaveAct.do",
			data : formData,
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				modalClose();
				alert(msg.substr(0, 2) + "처리되었습니다.");					
			}
		});
	}
}

function modalClose(){  
	diseModal.hide();
	fnSearch();
} 
function openHira() {
	window.open('https://www.hira.or.kr/rc/insu/insuadtcrtr/InsuAdtCrtrList.do?pgmid=HIRAA030069000400&WT.gnb=%EB%B3%B4%ED%97%98%EC%9D%B8%EC%A0%95%EA%B8%B0%EC%A4%80');
}
function ExcelDownLoad() { 
	 if(totCnt > 0){
  	    location.href =  "/base/sangListPrintExcel.do" ;
	 }
} 
function 	WorkList() { 
	 if(totCnt > 0){
		location.href =  "/base/BASE00401.do";
	 }
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
				<div class="info-name">상병코드관리</div>
			</div>
		</div> 
        <section class="top-pannel">  
          <div class="search-box">
            <label for="search" class="form-title">검색어 입력</label>
            <input type="text" name="searchtext" id="searchtext" class="form-control search" placeholder="검색어를 입력하세요"  onkeypress="if( event.keyCode == 13 ){fnSearch();}">
              <button class="buttcon" onclick="javascript:fnSearch();"><span class="icon icon-search"></span></button> 
              <button type="button" class="btn btn-outline-dark btn-sm" onclick="ExcelDownLoad();">엑셀다운로드</button>
			  <button type="button" class="btn btn-outline-dark btn-sm" onClick="openHira();">심평원 (자료실 참고)</button>
          </div> 
        </section>
        
        <section class="main-pannel">
          <div class="main-left w-100">
           <header class="main-hd">
              <h2>코드 목록</h2>
              <div class="btn-box">
                <button class="btn btn-outline-dark btn-sm"  onclick="fnsave('U');">수정</button>
                <button class="btn btn-primary btn-sm"  onclick="fnsave('I');">입력</button> 
              </div>
            </header>
                 <div style="text-align: right;">
						검색 결과 : 
						<label id="totalCnt"></label>
						개
				</div>            
            <div class="main-content">
              <!-- 테이블 샘플 -->
              <div class="table-responsive">
                <table id="infoTable" class="table table-bordered">
                  <colgroup>
                    <col style="width: 70px">       
                    <col style="width: 140px">
                    <col style="width: 120px">
                    <col style="width: auto; min-width: 160px">
                    <col style="width: auto; min-width: 160px">
                    <col style="width: 110px">
                    <col style="width: 120px">
                    <col style="width: 110px">
                    <col style="width: 110px">
                    <col style="width: 110px">
                    <col style="width: 120px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th> 번호</th>
                      <th> 진단코드</th>
                      <th> 시작적용일</th>
                      <th> 한글명</th>
                      <th> 영문명</th>
                      <th> 성별구분</th>
                      <th> 법정감염병구분</th>
                      <th> 상병구분</th>
                      <th> ICD10</th>
                      <th> 특정코드</th>
                      <th> 종료일</th>
                    </tr>
                  </thead>
                  <tbody id="dataArea"> 
        			<tr>
        				<td colspan="15">&nbsp;</td>
        			</tr>
                  </tbody>
                </table>
              </div>
            </div>
           <div id="pagination" class="pagination" style="margin: 0 auto; text-align: center;"></div>
         </div>
      <!--   </div> -->
       </section>
      </div>
    </div>
   </div>
      
  <!-- 모달 -->
   
  <div class="modal fade" id="diseModal" tabindex="-1" aria-labelledby="CodeModalLabel" aria-hidden="true">
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
              <input type="hidden" name="iud" id="iud" />
              <input type="hidden" name="dupchk" id="dupchk" value="X"/>
            <div class="form-wrap w-50">
              <label for="" class="critical">진단코드</label>
              <input type="text" name="diag_code" id="diag_code" class="form-control" placeholder="" readonly value="">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">적용시작일</label>
              <input type="text" name="start_dt" id="start_dt"  class="form-control" placeholder="" readonly value="">
            </div>  
            <div class="form-wrap w-100">
              <label for="" class="critical">한글진단명</label>
              <input type="text" name="kor_diag_name"  id="kor_diag_name" class="form-control" placeholder="한글명을 입력하세요." value="">
            </div>
            <div class="form-wrap w-100">
              <label for="" class="critical">영문진단명</label>
              <input type="text" name="eng_diag_name"  id="eng_diag_name" class="form-control" placeholder="영문명을 입력하세요." value="">
            </div>         
            <div class="form-wrap w-50">
              <label for="" >남녀구분</label>
              <select class="form-select" name="gender_type" id="gender_type">
                <option value="">선택</option> 
       			<option value="Y">Y.남자 </option>
                <option value="X">X.여자</option>
              </select>
            </div>
            <div class="form-wrap w-60">
              <label for="" >법정전염병</label>
              <input type="text" name="infect_type"  id="infect_type" class="form-control" placeholder="법정전염병" value="">
            </div> 
            <div class="form-wrap w-80">
              <label for="" class="critical">진료구분</label>
              <input type="text" name="diag_type"  id="diag_type" class="form-control" placeholder="진료구분" value="">
            </div>               
            <div class="form-wrap w-50">
              <label for="" >ICD10</label>
              <input type="text" name="icd10_code"  id="icd10_code" class="form-control" placeholder="ICD10" value="">
            </div> 
            <div class="form-wrap w-80">
              <label for="">상한연령</label>
              <input type="number" name="max_age"  id="max_age" class="form-control" placeholder="상한연령" value="">
              <label for="">하한연령</label>
              <input type="number" name="min_age"  id="min_age" class="form-control" placeholder="하한연령" value="">
            </div> 
            <div class="form-wrap w-50">
              <label for="" >특정코드</label>
              <input type="text" name="vcode"  id="vcode" class="form-control" placeholder="특정코드" value="">
            </div>             
            <div class="form-wrap w-80">
              <label for="" class="critical">적용종료일</label>
              <input type="text" name="end_dt" id="end_dt" class="form-control" value="">
            </div>
            </form:form>
          </div>
        </div>
      </div>
    </div>
  </div>
</body>
</html>