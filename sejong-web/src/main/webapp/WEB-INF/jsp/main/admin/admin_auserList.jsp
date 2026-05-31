<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
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
var adminModal = new bootstrap.Modal(document.getElementById('adminModal'));

// 공통 클라이언트 페이징 (admin-paging.js)
var auserPager = new AdminPager({
	dataArea:'#dataArea', paging:'#pagingArea', pageSize:15, colspan:10,
	rowHtml:function(d, i){
		var depnmText = (d.userGb == "D") ? "의사" : (d.userGb == "A" ? "관리자" : "");
		var t = '<tr class="" onclick="javascript:fnDtlSearch(\''+d.userId.replace(/'/g, "\\'")+'\');" id="row_'+d.userId+'">';
		t += "<td>" + (i+1) + "</td>";
		t += "<td style='display: none;'>" + d.userId + "</td>";
		t += "<td>" + d.userIdNm + "</td>";
		t += "<td>" + d.userNm + "</td>";
		t += "<td>" + depnmText + "</td>";
		t += "<td>" + d.deptNm + "</td>";
		t += "<td>" + d.startDate + "</td>";
		t += "<td>" + d.endDate + "</td>";
		t += "<td>" + d.useYn + "</td>";
		t += "<td>" + d.lockYn + "</td>";
		t += "<td>" + d.regDtm.substring(0,10) + "</td>";
		t += "</tr>";
		return t;
	}
});

function fnSearch() {
	 $("#infoTable tr").attr("class", "");
	 document.getElementById("regForm").reset();
	 $("#dataArea").empty();

	$.ajax({
   	url : CommonUtil.getContextPath() + '/admin/selectAuserList.do',
    type : 'post',
    data : {userNm : $("#searchText").val()},
   	dataType : "json",
   	success : function(data) {
   		if(data.error_code != "0") return;
   		auserPager.setData(data.resultCnt > 0 ? data.resultLst : []);
      }
   });
}
function fnDtlSearch(data){
	if(data == '' || data == null) return;

	document.regForm.iud.value  = "U";
	document.regForm.userId.value = data ;

	//row 클릭시 바탕색 변경 처리 Start
	$("#infoTable #"+data).attr("checked", true);
	$("#infoTable tr").attr("class", "");
	$("#infoTable #row_"+data).attr("class", "tr-primary");
}
//입력,수정 , 비밀번호 초기화  버큰 클릭시
function fnSave(iud){
	$("#iud").val(iud);  // 입력(I), 수정(U), 삭제(D)
	uidGubun = iud ;
	if(iud == "I"){
		//등록폼 초기화
		$("#userId").prop("readonly","");
		document.getElementById("regForm").reset();
		setCurrDate("startDate");
		$("#userGb").val("D");
		$("#endDate").val("2099-12-31");
		$("#lockYn").val("N");
		$("#useYn").val("Y");
		modalOpen();
	}else if(iud == "U"){
		if($("#userId").val() == ""){
			alert("선택된  정보가 없습니다.!");
			modalClose() ;
			return;

		}
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/admin/AuserInfo.do",
			data : {userId : $("#userId").val()},
			dataType : "json",
			success : function(data) {
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				$("#userId").val(data.result.userId);
				$("#userNm").val(data.result.userNm);
				$("#userIdNm").val(data.result.userIdNm);
				$("#deptNm").val(data.result.deptNm);
				$("#userGb").val(data.result.userGb);
				$("#regDtm").val(data.result.regDtm);
				$("#startDate").val(data.result.startDate);
				$("#endDate").val(data.result.endDate);
				$("#lockYn").val(data.result.lockYn);
				$("#useYn").val(data.result.useYn);
				$("#bigo").val(data.result.bigo);
				$("#userId").prop("readonly","true");
			}
		});
		modalOpen();
	}else
		return;
	}
function fnSaveProc(){
	if(!fnRequired('userIdNm', '아이디를  확인하세요.'))  return;
	if(!fnRequired('userNm', '성명을 확인 하세요.'))   return;
	if($("#userPw").val() == ""){
		alert("비밀번호를 입력하세요.!");
		document.getElementById("userPw").focus();
		return;
	}
	if($("#afAuserPwd").val() == ""){
		alert("비밀번호를 입력하세요.!");
		document.getElementById("afAuserPwd").focus();
		return;
	}
	var formData = $("form[name='regForm']").serialize();
	var msg = "" ;
	if (uidGubun == "U"){
		msg = "수정 하시겠습니다?" ;
	}else if (uidGubun == "D"){
		msg = "삭제 하시겠습니다?" ;
	}else{
		if ( $("#userPw").val() != $("#afAuserPwd").val() ){
			alert("비빌번호가 상호 상이합니다  .!");
			document.getElementById("afAuserPwd").focus();
			return;
		}
		msg = "입력 하시겠습니다?" ;
	}
	if(confirm(""+ msg)) {
		$.ajax( {
			type : "post" ,
			url : CommonUtil.getContextPath() + "/admin/AuserSaveAct.do",
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

$(document).ready(function(){ fnSearch(); });
</script>
</head>
<body>
    <div class="tab-pane">
      <div class="content-body">
	   <div class="tab-content">
	  	<div class="content-wrap">
			<div class="flex-left-right mb-10">
				<div class="patient-info">
					<div class="info-name">사용자 목록</div>
				</div>
			</div>
        <section class="top-pannel">
          <div class="search-box">
            <label for="search" class="form-title" onclick="">검색어 입력</label>
            <input type="text" name="searchText" id="searchText" class="form-control search" placeholder="환자명 또는 전화번호를 입력하세요." onkeypress="if( event.keyCode == 13 ){fnSearch();}">
            <button class="buttcon" onclick="javascript:fnSearch();"><span class="icon icon-search" ></span></button>
          </div>
        </section>

        <section class="main-pannel">
          <div class="main-left w-100">
            <header class="main-hd">
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
                  	<col style="width: 50px">
                    <col style="width: 100px">
                    <col style="width: 200px">
                    <col style="width: 200px">
                    <col style="width: 200px">
                    <col style="width: 200px">
                    <col style="width: 100px">
                    <col style="width: 100px">
                    <col style="width: 100px">
                    <col style="width: 20px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th>번호</th>
                      <th>아이디</th>
                      <th>성명</th>
                      <th>구분</th>
                      <th>진료과</th>
                      <th>시작일</th>
                      <th>종료일</th>
                      <th>사용여부</th>
                      <th>lock여부</th>
                      <th>등록일</th>
                    </tr>
                  </thead>
                  <tbody id="dataArea">
        			<tr>
        				<td colspan="10">&nbsp;</td>
        			</tr>
                  </tbody>
                </table>
              </div>
              <div id="pagingArea" class="paging"></div>
            </div>
          </div>
        </section>
        </div>
      </div>
   </div>
  <!-- 모달 -->
  <div class="modal fade" id="adminModal" tabindex="-1" aria-labelledby="adminModalLabel" aria-hidden="true">
    <div class="modal-dialog  modal-820">

            <div class="modal-content">
        <div class="modal-header reg-head">
          <h5 class="reg-modal-title">사용자 정보</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" onclick="modalClose();" aria-label="Close"></button>
        </div>
        <form:form commandName="DTO" id="regForm" name="regForm" method="post">
          <input type="hidden" name="iud" id="iud" />
          <input type="hidden" name="userId" id="userId" />
          <div class="modal-body">
            <table class="reg-table">
              <colgroup><col style="width:16%"><col style="width:34%"><col style="width:16%"><col style="width:34%"></colgroup>
              <tbody>
                <tr>
                  <th><span class="req">*</span>아이디</th>
                  <td><input type="text" name="userIdNm" id="userIdNm" class="form-control" placeholder="아이디를 입력하세요." style="width:100%;"></td>
                  <th><span class="req">*</span>사용자명</th>
                  <td><input type="text" name="userNm" id="userNm" class="form-control" placeholder="사용자 명을 입력하세요." style="width:100%;"></td>
                </tr>
                <tr>
                  <th><span class="req">*</span>사용자 구분</th>
                  <td>
                    <select class="form-select" name="userGb" id="userGb" style="width:100%;">
                      <option value="">선택</option>
                      <option value="D">D.의사</option>
                      <option value="A">A.관리자</option>
                    </select>
                  </td>
                  <th><span class="req">*</span>진료과명</th>
                  <td><input type="text" name="deptNm" id="deptNm" class="form-control" placeholder="진료과명을 입력하세요." style="width:100%;"></td>
                </tr>
                <tr>
                  <th><span class="req">*</span>시작일</th>
                  <td><input type="date" name="startDate" id="startDate" class="form-control" style="width:100%;"></td>
                  <th><span class="req">*</span>종료일</th>
                  <td><input type="date" name="endDate" id="endDate" class="form-control" style="width:100%;"></td>
                </tr>
                <tr>
                  <th><span class="req">*</span>lock여부</th>
                  <td>
                    <select class="form-select" name="lockYn" id="lockYn" style="width:100%;">
                      <option value="">선택</option>
                      <option value="Y">Y.봉인</option>
                      <option value="N">N.해체</option>
                    </select>
                  </td>
                  <th><span class="req">*</span>사용여부</th>
                  <td>
                    <select class="form-select" name="useYn" id="useYn" style="width:100%;">
                      <option value="">선택</option>
                      <option value="Y">Y.사용</option>
                      <option value="N">N.미사용</option>
                    </select>
                  </td>
                </tr>
                <tr>
                  <th><span class="req">*</span>비밀번호</th>
                  <td><input type="password" name="userPw" id="userPw" class="form-control" placeholder="비밀번호를 입력하세요." style="width:100%;"></td>
                  <th><span class="req">*</span>비밀번호 확인</th>
                  <td><input type="password" name="afAuserPwd" id="afAuserPwd" class="form-control" placeholder="비밀번호를 재입력하세요." style="width:100%;"></td>
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
