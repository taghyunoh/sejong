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
<style>
  :root { --reg-teal:#1f9b8e; --reg-teal-dark:#178074; --reg-teal-border:#bfe0db; --reg-teal-bg:#eaf6f4; }
  .tab-pane .content-body { align-items: stretch; }
  .tab-pane .content-body .tab-content, .tab-pane .content-body .content-wrap { width: 100%; }
  .table-responsive { overflow-x: auto; }
  #infoTable, #infoTable2 { width: 100%; }
  #infoTable thead th, #infoTable2 thead th { position: sticky; top: 0; z-index: 2; white-space: nowrap; background-color: #d9edf7 !important; color: #000000 !important; }
  #infoTable tbody tr, #infoTable2 tbody tr { cursor: pointer; }
  #infoTable tbody tr:hover, #infoTable2 tbody tr:hover { background-color: #f2f2f2; }
  #infoTable tbody tr:nth-child(even), #infoTable2 tbody tr:nth-child(even) { background-color: #f2f2f2; }
  .paging { display: flex; justify-content: center; align-items: center; gap: 4px; margin: 14px 0 4px; flex-wrap: wrap; }
  .paging .pg-btn { min-width: 32px; height: 32px; padding: 0 8px; border: 1px solid var(--reg-teal-border); background: #fff; color: #333; border-radius: 4px; cursor: pointer; font-size: 13px; line-height: 1; }
  .paging .pg-btn:hover:not(:disabled) { background: var(--reg-teal-bg); }
  .paging .pg-btn.active { background: var(--reg-teal); border-color: var(--reg-teal); color: #fff; font-weight: 700; }
  .paging .pg-btn:disabled { opacity: .4; cursor: default; }
  .modal-content { border-top: 3px solid var(--reg-teal); }
  .modal-header.reg-head { border-bottom: 2px solid var(--reg-teal); }
  .reg-modal-title { color: var(--reg-teal); font-weight: 700; font-size: 18px; margin: 0; }
  .modal-footer .btn-primary { background: var(--reg-teal); border-color: var(--reg-teal); }
  .modal-footer .btn-primary:hover { background: var(--reg-teal-dark); border-color: var(--reg-teal-dark); }
  .reg-table { width: 100%; border-collapse: collapse; table-layout: fixed; }
  .reg-table th, .reg-table td { border: 1px solid var(--reg-teal-border); padding: 9px 12px; vertical-align: middle; font-size: 14px; }
  .reg-table th { background: var(--reg-teal-bg); color: var(--reg-teal); font-weight: 600; text-align: left; white-space: nowrap; }
  .reg-table td { background: #fff; }
  .reg-table .req { color: #dc3545; margin-right: 3px; font-weight: 700; }
  .reg-table input.form-control, .reg-table select.form-select { height: 34px; font-size: 14px; }
  .reg-table textarea.form-control { font-size: 14px; }
  .reg-table input.form-control.full, .reg-table select.form-select.full { width: 100%; }
</style>
<script type="text/javascript">
if (typeof window.AdminPager !== 'function') {
  window.AdminPager = function(o){ this.dataSel=o.dataArea; this.pagingSel=o.paging; this.rowHtml=o.rowHtml; this.size=o.pageSize||15; this.colspan=o.colspan||12; this.emptyMsg=o.emptyMsg||'검색된 정보가 없습니다.'; this.onRender=o.onRender||null; this.list=[]; this.page=1; };
  window.AdminPager.prototype.setData = function(list){ this.list=list||[]; this.page=1; this.render(); };
  window.AdminPager.prototype.goPage = function(p){ if(p<1) return; this.page=p; this.render(); };
  window.AdminPager.prototype.render = function(){
    var $a=$(this.dataSel); $a.empty(); var total=this.list.length;
    if(total===0){ $a.append("<tr><td colspan='"+this.colspan+"'>"+this.emptyMsg+"</td></tr>"); this._paging(0); return; }
    var tp=Math.ceil(total/this.size); if(this.page>tp) this.page=tp; if(this.page<1) this.page=1;
    var s=(this.page-1)*this.size, e=Math.min(s+this.size,total), html="";
    for(var i=s;i<e;i++){ html+=this.rowHtml(this.list[i], i); }
    $a.append(html); if(this.onRender) this.onRender(); this._paging(tp);
  };
  window.AdminPager.prototype._paging = function(tp){
    var $p=$(this.pagingSel); $p.empty(); if(tp<1) return;
    var self=this, block=10, sp=Math.floor((this.page-1)/block)*block+1, ep=Math.min(sp+block-1,tp), html="";
    function b(l,pg,dis,act){ return '<button class="pg-btn'+(act?' active':'')+'" '+(dis?'disabled':'')+' data-page="'+pg+'">'+l+'</button>'; }
    html+=b('&laquo;',1,this.page===1,false); html+=b('&lsaquo;',this.page-1,this.page===1,false);
    for(var p=sp;p<=ep;p++){ html+=b(p,p,false,p===this.page); }
    html+=b('&rsaquo;',this.page+1,this.page===tp,false); html+=b('&raquo;',tp,this.page===tp,false);
    $p.html(html);
    $p.find('.pg-btn').off('click').on('click', function(){ var pg=parseInt($(this).attr('data-page'),10); if(!isNaN(pg)) self.goPage(pg); });
  };
}
</script>
<script type="text/javaScript">
var scrid = sessionStorage.getItem("q_screen_id");
//모달이 있을 경우
var adminModal = new bootstrap.Modal(document.getElementById('adminModal'));

// 공통 클라이언트 페이징 — 마스터 코드 목록 (admin-paging.js)
var commMstPager = new AdminPager({
	dataArea:'#dataArea1', paging:'#pagingArea1', pageSize:15, colspan:5,
	rowHtml:function(d, i){
		var t = '<tr class="" onclick="javascript:fnDtlSearch(\''+d.code+'\');" id="row_'+d.code+'">';
		t += '<td>'+(i+1)+'</td>';
		t += "<td>"+d.code+"</td>";
		t += "<td>"+d.codeName+"</td>";
		t += "<td>"+d.startDate+"</td>";
		t += "<td>"+d.endDate+"</td>";
		t += "</tr>";
		return t;
	}
});
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

				commMstPager.setData(data.resultCnt > 0 ? data.resultLst : []);
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
					dataTxt = '<tr class="" onclick="javascript:fnDtlSearch2(\''+code+'\',\''+data.resultLst[i].dtlCode+'\');" id="dtlrow_'
					                                                                  +code+data.resultLst[i].dtlCode+'">';

					dataTxt += '<td>'+(i+1) +'</td>';
					dataTxt += "<td>"+ data.resultLst[i].dtlCode+"</td>";
					dataTxt += "<td>"+ data.resultLst[i].dtlCodeNm+"</td>";
					dataTxt += "<td>"+ data.resultLst[i].startDate+"</td>";
					dataTxt += "<td>"+ data.resultLst[i].endDate+"</td>";
					dataTxt += "<td>"+ data.resultLst[i].sort+"</td>";
					dataTxt += "<td>"+ data.resultLst[i].useYn+"</td>";
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
function fnDtlSearch2(code,dtlCode){

	document.regForm.iud.value  = "DU";
	document.regForm.code.value = code ;
	document.regForm.dtlCode.value = dtlCode ;

	//row 클릭시 바탕색 변경 처리 Start
	$("#infoTable2 #"+code+dtlCode).attr("checked", true);
	$("#infoTable2 tr").attr("class", "");
	$("#infoTable2 #dtlrow_"+code+dtlCode).attr("class", "tr-primary");
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
				$("#endDate").val("9999-12-31");
				setCurrDate("startDate");
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
							$("#codeName").val(data.resultLst[0].codeName);
							$("#startDate").val(data.resultLst[0].startDate);
							$("#endDate").val(data.resultLst[0].endDate);

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
				$("#dtlCode").prop("readonly","");

				setCurrDate("startDate");
				$("#endDate").val("9999-12-31");
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
				if($("#dtlCode").val() == ""){
					alert("선택된 상세코드 정보가 없습니다.!");
					modalClose() ;
					return;
				}
				//
				$.ajax( {
					type : "post",
					url : "/admin/selectCommDetailList.do",
					data : {code : $("#code").val(), dtlCode : $("#dtlCode").val()},
					dataType : "json",
					success : function(data) {
						if(data.error_code != "0") return;

						if(data.resultCnt > 0 ){
							$("#dtlCodeNm").val(data.resultLst[0].dtlCodeNm);
							$("#startDate").val(data.resultLst[0].startDate);
							$("#endDate").val(data.resultLst[0].endDate);
							$("#sort").val(data.resultLst[0].sort);
						}
					}
				});

				$("#dtlCode").prop("readonly","true");
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
		if(!fnRequired('dtlCode', '상세 코드정보를 입력하세요')) return;
		//상세코드 중복 체크
		$.ajax( {
			type : "post",
			url : "/admin/CommDetailDupChk.do",
			data : {code : $("#code").val() , dtlCode : $("#dtlCode").val() },
			dataType : "json",
			success : function(data) {

				if(data.error_code != "0") return;
				if(data.dupchk == "Y"){
					alert("해당 상세 코드정보는 이미 존재하는 코드입니다.");
					$("#dtlCode").val("");
					$("#dtlCode").focus();
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
	if(iud != "D" && val == "D" && !fnRequired('dtlCode', '상세 코드정보를 입력하세요')) return;
	if(iud != "D" && !fnRequired('startDate', '적용시작일자를 입력하세요')) return;
	if(iud != "D" && val == "M" && !fnRequired('codeName', '코드명 정보를 입력하세요')) return;
	if(iud != "D" && val == "D" && !fnRequired('dtlCodeNm', '상세코드명 정보를 입력하세요')) return;
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

$(document).ready(function(){ fnSearch('M'); });
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
                                                                       onkeypress="if( event.keyCode == 13 ){fnSearch('M');}">
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
              <div id="pagingArea1" class="paging"></div>
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
        <div class="modal-header reg-head">
          <h5 class="reg-modal-title">공통코드</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" onclick="modalClose();" aria-label="Close"></button>
        </div>
        <form:form commandName="VO" id="regForm" name="regForm" method="post">
          <input type="hidden" name="gbn" id="gbn" />
          <input type="hidden" name="iud" id="iud" />
          <input type="hidden" name="dupchk" id="dupchk" value="X"/>
          <div class="modal-body">
            <table class="reg-table">
              <colgroup><col style="width:20%"><col style="width:80%"></colgroup>
              <tbody>
                <tr>
                  <th><span class="req">*</span>코드</th>
                  <td>
                    <input type="text" name="code" id="code" class="form-control" style="width:200px;display:inline-block;" readonly>
                    <button type="button" class="btn btn-outline-dark" id="mstdupid" onclick="fnDupchk('M');">중복체크</button>
                  </td>
                </tr>
                <tr id="CodeName">
                  <th><span class="req">*</span>코드명</th>
                  <td><input type="text" name="codeName" id="codeName" class="form-control" placeholder="코드명을 입력하세요." style="width:100%;"></td>
                </tr>
                <tr id="dtlCodeInfo" style="display:none">
                  <th><span class="req">*</span>상세코드</th>
                  <td>
                    <input type="text" name="dtlCode" id="dtlCode" class="form-control" style="width:200px;display:inline-block;" readonly>
                    <button type="button" class="btn btn-outline-dark" id="dtldupid" onclick="fnDupchk('D');">중복체크</button>
                  </td>
                </tr>
                <tr id="dtlCodeName" style="display:none">
                  <th><span class="req">*</span>상세코드명</th>
                  <td><input type="text" name="dtlCodeNm" id="dtlCodeNm" class="form-control" placeholder="상세코드명을 입력하세요." style="width:100%;"></td>
                </tr>
                <tr>
                  <th><span class="req">*</span>적용기간</th>
                  <td>
                    <input type="date" name="startDate" id="startDate" class="form-control" style="width:180px;display:inline-block;">
                    <span style="margin:0 6px;">~</span>
                    <input type="date" name="endDate" id="endDate" class="form-control" value="9999-12-31" style="width:180px;display:inline-block;">
                  </td>
                </tr>
                <tr id="sortInfo" style="display:none">
                  <th>정렬순서</th>
                  <td><input type="text" name="sort" id="sort" class="form-control" placeholder="00" style="width:120px;"></td>
                </tr>
              </tbody>
            </table>
          </div>
        </form:form>
        <div class="modal-footer">
          <button type="button" class="btn btn-primary btn-sm" onclick="fnSaveProc();">저장</button>
          <button type="button" class="btn btn-outline-dark btn-sm" data-bs-dismiss="modal" onclick="modalClose();">목록</button>
        </div>
      </div>
    </div>
  </div>
</body>


</html>
