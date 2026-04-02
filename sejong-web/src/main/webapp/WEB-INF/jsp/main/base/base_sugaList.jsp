<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>  
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
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

var pageIndex = 1; // 페이지 인덱스 초기값
var pageSize = 13; // 페이지 크기

// fnSearch 함수 수정
function fnSearch() {
    $("#infoTable tr").attr("class", "");
    document.getElementById("regForm").reset();
    $("#dataArea").empty();
 	if($('#searchText').val() == "") {
		alert("검색어를 입력하세요.");
		$('#searchText').focus();
		return; 
   }  
    $.ajax({
        url: CommonUtil.getContextPath() + '/base/ctl_sugaList.do',
        type: 'post',
        data: {
            kor_nm: $("#searchText").val(),
            pageIndex: pageIndex,
            pageSize: pageSize
        },
        dataType: "json",
        success: function(data) {
            if (data.error_code != "0") return;
            if (data.resultCnt > 0) {
                var startIndex = (pageIndex - 1) * pageSize + 1; // 페이지 인덱스에 맞는 시작 인덱스 계산
                var dataTxt = "";
                for (var i = 0; i < data.resultCnt; i++) {
                    dataTxt = '<tr class="" onclick="javascript:fnDtlSearch(\'' + 
                        data.resultLst[i].fee_code + '\', \'' + data.resultLst[i].start_dt + '\');" id="row_' + 
                        data.resultLst[i].fee_code + data.resultLst[i].start_dt + '">';
                    dataTxt += "<td>" + (startIndex + i) + "</td>"; // 올바른 인덱스 표시
                    dataTxt += "<td>" + data.resultLst[i].fee_code + "</td>";
                    dataTxt += "<td>" + data.resultLst[i].fee_type + "</td>";
                    dataTxt += "<td>" + data.resultLst[i].start_dt + "</td>";
                    dataTxt += "<td>" + data.resultLst[i].class_no + "</td>";
                    dataTxt += "<td>" + data.resultLst[i].kor_nm + "</td>";
                    dataTxt += "<td>" + data.resultLst[i].div_type + "</td>";
                    dataTxt += "<td>" + data.resultLst[i].surg_yn + "</td>";
                    dataTxt += "<td>" + data.resultLst[i].cln_price + "</td>";
                    dataTxt += "<td>" + data.resultLst[i].hos_price + "</td>";
                    dataTxt += "<td>" + data.resultLst[i].dnt_price + "</td>";
                    dataTxt += "<td>" + data.resultLst[i].orh_price + "</td>";
                    dataTxt += "<td>" + data.resultLst[i].rlt_value + "</td>";
                    dataTxt += "<td class='text-left'>" + data.resultLst[i].calc_nm + "</td>";
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
    if ($('#searchText').val() != "") {
        fnSearch(); // 페이지 로드 후 검색 함수 호출
    }
}

// 초기 페이지 로드
loadPage(1, 13);

// 상세 검색 함수 수정 (선택된 행 강조)
function fnDtlSearch(fee_code, start_dt) {
    if (!fee_code || !start_dt) return; // 유효성 검사

    // 폼의 값 설정
    document.regForm.iud.value = "U";
    document.regForm.fee_code.value = fee_code;
    document.regForm.start_dt.value = start_dt;

    // 선택된 행의 바탕색 변경
    $("#infoTable tr").removeClass("tr-primary");
    $("#infoTable #row_" + fee_code + start_dt).addClass("tr-primary");
}

// 입력, 수정, 삭제 버튼 처리
function fnSave(iud) {
    $("#iud").val(iud);  // 입력(I), 수정(U), 삭제(D)
    uidGubun = iud;
    if (iud == "I") {
        // 등록폼 초기화
        $("#fee_code").prop("readonly", "");
        document.getElementById("regForm").reset();
        setCurrDate("start_date");
        $("#end_date").val("2099-12-31");
        modalOpen();
    } else if (iud == "U") {
        if ($("#fee_code").val() == "" || $("#start_dt").val() == "") {
            alert("선택된 정보가 없습니다!");
            modalClose();
            return;
        }
        $.ajax({
            type: "post",
            url: CommonUtil.getContextPath() + "/base/ctl_sugaInfo.do",
            data: { fee_code: $("#fee_code").val(), start_dt: $("#start_dt").val() },
            dataType: "json",
            success: function(data) {
                if (data.error_code != "0") {
                    alert(data.error_msg);
                    return;
                }
                $("#fee_code").val(data.result.fee_code);
                $("#fee_type").val(data.result.fee_type);
                $("#start_dt").val(data.result.start_dt);
                $("#class_no").val(data.result.class_no);
                $("#kor_nm").val(data.result.kor_nm);
                $("#calc_nm").val(data.result.calc_nm);
                $("#div_type").val(data.result.div_type);
                $("#surg_yn").val(data.result.surg_yn);
                $("#cln_price").val(data.result.cln_price);
                $("#hos_price").val(data.result.hos_price);
                $("#dnt_price").val(data.result.dnt_price);
                $("#orh_price").val(data.result.orh_price);
                $("#rlt_value").val(data.result.rlt_value);
                $("#fee_code").prop("readonly", "true");
                $("#start_dt").prop("readonly", "true");
            }
        });
        modalOpen();
    } else {
        return;
    }
}

function fnSaveProc(){
	if(!fnRequired('fee_code', '수가코드를  확인하세요.'))  return;
	if(!fnRequired('start_dt', '시작일자을 확인 하세요.'))   return;
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
			url : CommonUtil.getContextPath() + "/base/ctl_SugaSaveAct.do",
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
	<!-- <div class="content-wrap"> --> <!--  마킹하면  화면 넓히기  -->
			<div class="flex-left-right mb-10">
				<div class="patient-info">
					<div class="info-name">수가코드관리</div>
				</div>
			</div>  
        <section class="top-pannel">  
          <div class="search-box">
            <label for="search" class="form-title" onclick="">검색어 입력</label>
            <input type="text" name="searchText" id="searchText" class="form-control search" placeholder="수가코드및 수가명를 입력하세요." onkeypress="if( event.keyCode == 13 ){fnSearch();}">
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
                    <col style="width: 10px">
                  	<col style="width: 50px">
                    <col style="width: 20px">
                    <col style="width: 50px">
                    <col style="width: 100px">
                    <col style="width: 200px">
                    <col style="width: 50px">
                    <col style="width: 50px">
                    <col style="width: 50px">
                    <col style="width: 50px">
                    <col style="width: 50px">
                    <col style="width: 50px">
                    <col style="width: 50px">
                    <col style="width: 200px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th>번호</th>
                      <th>수가코드</th>
                      <th>수가구분</th>
                      <th>시작일자</th>
                      <th>뷴류번호</th>
                      <th>한글명칭</th>
                      <th>행위구분</th>
                      <th>수술구분</th>
                      <th>의원단가</th>
                      <th>병원단가</th>
                      <th>치과단가</th>
                      <th>한방단가</th>
                      <th>상대점수</th>
                      <th>산정명칭</th>
                    </tr>
                  </thead>
                  <tbody id="dataArea"> 
        			<tr>
        				<td colspan="14">&nbsp;</td>
        			</tr>
                  </tbody>
                </table>
              </div>
              <div id="pagination" class="pagination" style="margin: 0 auto; text-align: center;"></div>
       <!--     </div> -->  <!--  마킹하면  화면 넓히기  -->
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
              <label for="" class="critical">수가코드</label>
              <input type="text" name="fee_code" id="fee_code" class="form-control" placeholder="수가코드를 입력하세요">
            </div>
            <div class="form-wrap w-50">
              <label for=""class="critical">수가구분</label>
       		  <select class="form-select" name="fee_type" id="fee_type">
                <option value="">선택</option> 
                <option value="1">1.수가</option>
                <option value="3">3.약가</option>
                <option value="7">7.재료대</option>
              </select> 
            </div> 
            <div class="form-wrap w-50">
              <label for="" class="critical">시작일자</label>
              <input type="text" name="start_dt" id="start_dt" class="form-control" placeholder="시작일자를 입력하세요.">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">뷴류기호</label>
              <input type="text" name="class_no" id="class_no" class="form-control" placeholder="분류기호를  입력하세요.">
            </div>     
            <div class="form-wrap w-100">
              <label for="" class="critical">한글명칭</label>
              <input type="text" name="kor_nm" id="kor_nm" class="form-control" placeholder="한글명칭 을 입력하세요.">
            </div>    
            <div class="form-wrap w-100">
              <label for="" class="critical">산정명칭</label>
              <input type="text" name="calc_nm" id="calc_nm" class="form-control" placeholder="산정명칭을  입력하세요.">
            </div>    
            <div class="form-wrap w-50">
			  <label for="cln_price" class="critical">의원단가</label>
			  <input type="text" name="cln_price" id="cln_price" class="form-control price-input" placeholder="의원단가를 입력하세요.">
			</div>                                 
            <div class="form-wrap w-50">
			  <label for="hos_price" class="critical">병원단가</label>
			  <input type="text" name="hos_price" id="hos_price" class="form-control price-input" placeholder="병원단가를 입력하세요.">
			</div>
            <div class="form-wrap w-50">
			  <label for="dnt_price" class="critical">치과단가</label>
			  <input type="text" name="dnt_price" id="dnt_price" class="form-control price-input" placeholder="치과단가를 입력하세요.">
			</div>
            <div class="form-wrap w-50">
			  <label for="orh_price" class="critical">한방단가</label>
			  <input type="text" name="orh_price" id="orh_price" class="form-control price-input" placeholder="한방단가를 입력하세요.">
			</div>
            <div class="form-wrap w-50">
			  <label for="" class="critical">상대점수</label>
			  <input type="text" name="orh_price" id="rlt_value" class="form-control" placeholder="상대점수를 입력하세요.">
			</div>
            <div class="form-wrap w-50">
			  <label for="" class="critical">본인50%</label>
			  <input type="text" name="copay_50" id="copay_50" class="form-control" placeholder="본인50%을 입력하세요.">
			</div>
             <div class="form-wrap w-50">
			  <label for="" class="critical">본인80%</label>
			  <input type="text" name="copay_80" id="copay_80" class="form-control" placeholder="본인80%을 입력하세요.">
			</div>
            <div class="form-wrap w-50">
			  <label for="" class="critical">본인90%</label>
			  <input type="text" name="copay_90" id="copay_90" class="form-control" placeholder="본인90%을 입력하세요.">
			</div>			
            <div class="form-wrap w-50">
			  <label for="" class="critical">중복인정</label>
			  <input type="text" name="dup_yn" id="dup_yn" class="form-control" placeholder="중복인정을 입력하세요.">
			</div>
            <div class="form-wrap w-50">
			  <label for="" class="critical">장구분</label>
			  <input type="text" name="sec_maj" id="sec_maj" class="form-control" placeholder="장구분을 입력하세요.">
			</div>
            <div class="form-wrap w-50">
			  <label for="" class="critical">절구분</label>
			  <input type="text" name="sec_min" id="sec_min" class="form-control" placeholder="절구분을 입력하세요.">
			</div>
            <div class="form-wrap w-50">
			  <label for="" class="critical">세구분</label>
			  <input type="text" name="sub_cat" id="sub_cat" class="form-control" placeholder="세구분을 입력하세요.">
			</div>						
          </div> 
        </div>
        </form:form>
      </div>
      
    </div>
  </div>
</body>
</html>
