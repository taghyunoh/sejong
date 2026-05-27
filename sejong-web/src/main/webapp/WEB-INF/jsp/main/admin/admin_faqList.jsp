<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<%@ page   import = "java.util.*" %>
<html>
<head>
<!-- 달력(일자, 월별) 사용시 추가 필요함 -->
<script src="/js/main.js"></script>
<script type="text/javaScript">

var adminNoticeModal = new bootstrap.Modal(document.getElementById('adminModal'));
var uidGubun = "" ;
function fnSearch() {

	$("#infoTable tr").attr("class", "");

	document.getElementById("regForm").reset();

	$("#dataArea").empty();
	$.ajax({
   	url : CommonUtil.getContextPath() + '/admin/faqList.do',
    type : 'post',
    data : {searchGb : $("#searchGb").val(),searchText : $("#searchText").val()},
	dataType : "json",
   	success : function(data) {
   		if(data.error_code != "0") return;
   		if(data.resultCnt > 0 ){
    		var dataTxt = "";
    		for(var i=0 ; i < data.resultCnt; i++){
    			var gubunText = "";
        		if (data.resultLst[i].faqGb == "T"){
        			gubunText = "공통";
        	    } else if(data.resultLst[i].faqGb == "A") {
        	    	gubunText = "앱";
        	    } else if(data.resultLst[i].faqGb == "W") {
        	    	gubunText = "웹";
        	    }
    			dataTxt = '<tr  class="" onclick="javascript:fnDtlSearch(\''+data.resultLst[i].faqSeq+'\');" id="row_'+data.resultLst[i].faqSeq+'">';
 				dataTxt += 	"<td>" + (i+1)  + "</td>" ;
				dataTxt +=  "<td>" + gubunText   + "</td>" ;
 				dataTxt +=  "<td>" + data.resultLst[i].qstnConts    + "</td>" ;
				dataTxt +=  "<td class='txt-left ellips'>" + data.resultLst[i].ansrConts    + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].useYn        + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].modId        + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].modDtm       + "</td>" ;
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

		document.regForm.faqSeq.value = data ;

		//row 클릭시 바탕색 변경 처리 Start
		$("#infoTable tr").attr("class", "");
		$("#infoTable #"+data).attr("checked", true);
		$("#infoTable #row_"+data).attr("class", "tr-primary");

	}
function fnsave(iud){
	$("#iud").val(iud);  // 입력(I), 수정(U), 삭제(D)
	uidGubun = iud ;

	if(iud == "I"){
		document.getElementById("regForm").reset();
		$("#faqGb").val("T");
		$("#useYn").val("Y");

		modalOpen() ;

	}else if(iud == "U" || iud == "D" ){
		if($("#faqSeq").val() == ""){
			alert("선택된  정보가 없습니다.!");
			modalClose() ;
			return;
		}
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/admin/faqInfo.do",
			data : {faqSeq : $("#faqSeq").val()},
			dataType : "json",
			success : function(data) {
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				$("#faqGb").val(data.result.faqGb);
				$("#qstnConts").val(data.result.qstnConts);
				$("#ansrConts").val(data.result.ansrConts);
				$("#useYn").val(data.result.useYn);
			}
		});
	} else if(iud == "D"){
		fnSaveProc();
	}
	modalOpen() ;
}
function fnSaveProc(){
	if(!fnRequired('qstnConts', 'faq제목을 확인 하세요.'))    return;
	if(!fnRequired('ansrConts', 'faq내용을  확인하세요.'))    return;
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
			url : CommonUtil.getContextPath() + "/admin/faqSaveProc.do",
			data : formData,
			dataType : "json",
			success : function(data) {
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				fnSearch() ;
				modalClose();
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
function fnPdf() {
    const jsPDF = window.jspdf;
    const doc = new jsPDF();

    html2canvas(document.querySelector("#lineChart"), { scale: 2 }).then(canvas => {
        const imgData = canvas.toDataURL("image/png");
        doc.addImage(imgData, 'PNG', 10, 10, 180, 90);

        doc.addPage();
        html2canvas(document.querySelector("#dotsChart"), { scale: 2 }).then(canvas => {
            const imgData = canvas.toDataURL("image/png");
            doc.addImage(imgData, 'PNG', 10, 10, 180, 90);

            doc.save('charts.pdf');
        });
    });
}

function fnPrint() {
	var initBody;
	 window.onbeforeprint = function(){
	  initBody = document.body.innerHTML;
	  document.body.innerHTML =  document.getElementById('print').innerHTML;
	 };
	 window.onafterprint = function(){
	  document.body.innerHTML = initBody;
	 };
    window.print();
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
				<div class="info-name">FAQ 목록</div>
			</div>
		</div>
        <section class="top-pannel">
          <div class="search-box">
            <label for="search" class="form-title"  onclick="">검색구분</label>
           	  <select class="form-select w-10"  name="searchGb" id="searchGb">
                <option value="ALL">전체</option>
       			<option value="T">공통</option>
                <option value="A">앱</option>
                <option value="W">웹</option>
              </select>
            <input type="text" name="searchText" id="searchText" class="form-control search" placeholder="검색어를 입력하세요."
                                                                      onkeypress="if( event.keyCode == 13 ){fnSearch();}">
            <button class="buttcon" onclick="javascript:fnSearch();"><span class="icon icon-search" ></span></button>
          </div>
        </section>
        <section class="main-pannel">
          <div class="main-left w-100">
            <header class="main-hd">
              <h2></h2>
              <div class="btn-box">
                <button class="btn btn-outline-dark btn-sm" onclick="fnsave('U');">수정</button>
                <button class="btn btn-primary btn-sm"  onclick="fnsave('I');">입력</button>
              </div>
            </header>

            <div class="main-content">
              <div class="container text-center">
              <div class="table-responsive">
                <table id="infoTable" class="table table-bordered" >
                  <colgroup>
                  	<col style="width: 30px">
                  	<col style="width: 50px">
                    <col style="width: 250px">
                    <col style="width: 300px">
                    <col style="width: 100px">
                    <col style="width: 100px">
                    <col style="width: 50px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th>번호</th>
                      <th>사용구분</th>
                      <th>FAQ 제목</th>
                      <th>FAQ 내용</th>
                      <th>사용 여부</th>
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
          </div>
        </section>
      </div>
     </div>
    </div>
  <!-- 모달 -->
  <div class="modal fade" id="adminModal" tabindex="-1" aria-labelledby="adminLFaqLabel" aria-hidden="true">
    <div class="modal-dialog  modal-820">
      <div class="modal-content">
        <div class="modal-footer">
          <button type="button" class="btn btn-primary btn-sm"  onclick="fnSaveProc();">저장</button>
          <button type="button" class="btn btn-outline-dark btn-sm" data-bs-dismiss="modal" onclick="modalClose();">목록</button>
        </div>
         <form:form commandName="DTO"  id="regForm" name="regForm" method="post">
           <input type="hidden" name="iud" id="iud"/>
           <input type="hidden" name="faqSeq" id="faqSeq"/>
        <div class="modal-body">
          <div class="form-container">
            <div class="form-wrap w-50">
              <label for=""class="critical">사용 구분</label>
       		  <select class="form-select" name="faqGb" id="faqGb">
                <option value="">선택</option>
                <option value="T">T.공통</option>
                <option value="A">A.앱</option>
                <option value="W">W.웹</option>
              </select>
            </div>
            <div class="form-wrap w-100">
              <label for="" class="critical" style="left">FAQ 제목</label>
              <input type="text" name="qstnConts" id="qstnConts" class="form-control" placeholder="faq제목을 입력하세요." >
            </div>
            <div class="form-wrap w-100">
              <label for="" class="critical" style="left">내용</label>
              <textarea class="form-control" aria-label="With textarea" placeholder="faq내용을 입력하세요." name="ansrConts" id="ansrConts"></textarea>
            </div>
            <div class="form-wrap w-50">
              <label for=""class="critical">사용 여부</label>
       		  <select class="form-select" name="useYn" id="useYn">
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
