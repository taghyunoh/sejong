<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<link href="/bootstrap/css/bootstrap.css" rel="stylesheet">
<link href="/asset/css/common.css" rel="stylesheet">
<link href="/asset/component/sub_teb_menu.css" rel="stylesheet">
<title>FAQ</title>
<script src="/js/main.js"></script>
<script type="text/javascript">
$(document).ready(function () {
	fnSearch() ;
})

var adminModal = new bootstrap.Modal(document.getElementById('adminModal'));
function fnSearch() {

	$("#infoTable tr").attr("class", ""); 
	
	document.getElementById("regForm").reset();
	 
	$("#dataArea").empty();
	$.ajax({
   	url : CommonUtil.getContextPath() + '/doctor/faqList.do',
    type : 'post',
    data : {searchText : $("#searchText").val()},
	dataType : "json",
   	success : function(data) {
   		if(data.error_code != "0") return;
   		if(data.resultCnt > 0 ){
    		var dataTxt = "";
    		for(var i=0 ; i < data.resultCnt; i++){
    			var gubunText = "";
    			dataTxt = '<tr  class="" onclick="javascript:fnDtlSearch(\''+data.resultLst[i].faq_seq+'\');" id="row_'+data.resultLst[i].faq_seq+'">';
 				dataTxt += 	"<td>" + (i+1)  + "</td>" ;
 				dataTxt +=  "<td>" + data.resultLst[i].qstn_conts    + "</td>" ;
				dataTxt +=  "<td class='txt-left ellips'>" + data.resultLst[i].ansr_conts    + "</td>" ;
				dataTxt +=  "<td>" + '관리자'        + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].mod_dtm + "</td>" ;
				dataTxt +=  "</tr>";
	            $("#dataArea").append(dataTxt);
        	 }
    		// 각 행 클릭 시 모달에 데이터 전달
            $("#dataArea tr").on('click', function() {
              var faq_seq = $(this).attr('id').replace('row_', ''); // 행 ID에서 faq_seq 추출
              var faqData = data.resultLst.find(function(item) { return item.faq_seq === faq_seq; });

              // 모달에 데이터 채우기
              openModalWithData(faqData); // FAQ 데이터를 모달로 전달
            });
   		}else{
			  $("#dataArea").append("<tr><td colspan='12'>검색된 정보가 없습니다.</td></tr>");
		  }
      }
   });
}
// 모달에 데이터를 전달하여 여는 함수
function openModalWithData(faqData) {
  var modalElement = document.getElementById('adminModal');
  if (modalElement) {
    var adminModal = new bootstrap.Modal(modalElement);

    // 모달에 데이터 채우기
    $('#modalQstnConts').text(faqData.qstn_conts); // 질문 내용
    $('#modalAnsrConts').text(faqData.ansr_conts); // 답변 내용
    $('#modalAdmin').text('관리자'); // 관리자
    $('#modalModDtm').text(faqData.mod_dtm); // 수정 일시

    // 모달 열기
    adminModal.show();
  }
}
function fnDtlSearch(data){ 
		if(data == '' || data == null) return;
		 
		document.regForm.faq_seq.value = data; 
		
		//row 클릭시 바탕색 변경 처리 Start 
		$("#infoTable tr").attr("class", ""); 
		$("#infoTable #"+data).attr("checked", true);
		$("#infoTable #row_"+data).attr("class", "tr-primary");
		fnSave();
	}
	
function fnSave(){
	
	$.ajax( {
		type : "post",
		url : CommonUtil.getContextPath() + "/doctor/faqInfo.do",
		data : {faq_seq : $("#faq_seq").val()},
		dataType : "json",
		success : function(data) {    
			if(data.error_code != "0") {
				alert(data.error_msg);
				return;
			}
			$("#qstn_conts").val(data.result.qstn_conts);
			$("#ansr_conts").val(data.result.ansr_conts);
			$("#mod_dtm").val(data.result.mod_dtm);
			$("#mod_id").val('관리자');
		}
	});
	$("#adminModal").modal("show");
}
function modalClose(){
	//모달이 있을 경우
	$("#adminModal").modal("hide");
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
							<div class="info-name">FAQ</div>
						</div>
					</div>
					<section class="top-pannel">
						<!-- 서브 탭메뉴 컨텐츠 영역 -->
						<!-- <div class="main-container">
							<div class="list-description">
								각 질문을 선택하면 답변을 확인 할 수 있습니다. <br> <br>
								<div class="accordion" id="accordionExample"></div>
							</div>
						</div> -->
						<div class="search-box">
				            <label for="search" class="form-title"  onclick="">검색</label>
				            <input type="text" name="searchText" id="searchText" class="form-control search" placeholder="검색어를 입력하세요." 
				                                                                      onkeypress="if( event.keyCode == 13 ){fnSearch();}">
				            <button class="buttcon" onclick="javascript:fnSearch();"><span class="icon icon-search" ></span></button>
						</div> 
					</section>
					<section class="main-pannel">
			            <div class="main-content">
			              <!-- 테이블 샘플 -->
			              <div class="container text-center">
			              <div class="table-responsive">
			                <table id="infoTable" class="table table-bordered" >
			                  <colgroup>
			                  	<col style="width: 5%">
			                    <col style="width: 20%">
			                    <col style="width: 60%">
			                    <col style="width: 5%">
			                    <col style="width: 10%">
			                  </colgroup>
			                  <thead>
			                    <tr>
			                      <th>번호</th>
			                      <th>FAQ 제목</th>
			                      <th>FAQ 내용</th>
			                      <th>등록자</th>
			                      <th>등록일</th>
			                    </tr>
			                  </thead>
			                  <tbody id="dataArea"> 
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
		</div>
	</div>
	

  <!-- 모달 -->
  <div class="modal fade" id="adminModal" tabindex="-1" aria-labelledby="adminLFaqLabel" aria-hidden="true">
    <!-- 모달 class명으로 사이즈 조절 modal-320, 410, 520, 650, 820 -->
    <div class="modal-dialog  modal-820">
      <div class="modal-content">
        <div class="modal-footer">
          <button type="button" class="btn btn-outline-dark btn-sm" data-bs-dismiss="modal" onclick="modalClose();">목록</button>
        </div>
         <form:form commandName="DTO"  id="regForm" name="regForm" method="post">
           <input type="hidden" name="iud" id="iud"/> 
           <input type="hidden" name="faq_seq" id="faq_seq"/> 
        <div class="modal-body">
          <div class="form-container">        
            <div class="form-wrap w-100">
              <label for="" style="left">FAQ 제목</label>
              <input type="text" name="qstn_conts" id="qstn_conts" class="form-control" readonly>
            </div>
            <div class="form-wrap w-100">
              <label for="" style="left">내용</label>
              <textarea class="form-control" aria-label="With textarea" name="ansr_conts" id="ansr_conts" readonly></textarea>              
            </div>
            <div class="form-wrap w-50">
              <label for="">등록일</label>
              <input type="date" name="mod_dtm" id="mod_dtm" class="form-control" readonly>
            </div>
            <div class="form-wrap w-50">
              <label for="">등록자</label>
              <input type="text" class="form-control" name="mod_id" id="mod_id" value="관리자" readonly>
            </div>
          </div> 
        </div>
	  </form:form>
      </div>
    </div>
  </div>
</body>
</html>