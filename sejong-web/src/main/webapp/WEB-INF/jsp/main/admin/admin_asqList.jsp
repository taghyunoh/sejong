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

var adminNoticeModal = new bootstrap.Modal(document.getElementById('adminModal'));
var uidGubun = "" ;

// 공통 클라이언트 페이징 (admin-paging.js)
var asqPager = new AdminPager({
	dataArea:'#dataArea', paging:'#pagingArea', pageSize:15, colspan:6,
	rowHtml:function(d, i){
		var t = '<tr class="" onclick="javascript:fnDtlSearch(\''+d.asqSeq+'\');" id="row_'+d.asqSeq+'">';
		t += "<td>" + (i+1) + "</td>";
		t += "<td>" + d.userNm + "</td>";
		t += "<td class='txt-left ellips'>" + truncateText(d.qstnConts, 50) + "</td>";
		t += "<td class='txt-left ellips'>" + truncateText(d.ansrConts, 50) + "</td>";
		t += "<td>" + d.ansrYn + "</td>";
		t += "<td>" + d.qstnYmd + "</td>";
		t += "</tr>";
		return t;
	}
});

function fnSearch() {

	$("#infoTable tr").attr("class", "");

	document.getElementById("regForm").reset();

	$("#dataArea").empty();
	$.ajax({
   	url : CommonUtil.getContextPath() + '/admin/asqList.do',
    type : 'post',
    data : {searchText : $("#searchText").val()},
	dataType : "json",
   	success : function(data) {
   		if(data.error_code != "0") return;
   		asqPager.setData(data.resultCnt > 0 ? data.resultLst : []);
      }
   });

}



function truncateText(text, length) {
    if (!text) return "";
    return text.length > length ? text.substring(0, length) + "..." : text;
}


function fnDtlSearch(data){ 
	if(data == '' || data == null) return;
	 
	document.regForm.asqSeq.value = data ; 
	
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
		$("#ansrYn").val("Y");
		
		modalOpen() ;
	
	}else if(iud == "U" || iud == "D" ){
		if($("#asqSeq").val() == ""){
			alert("선택된  정보가 없습니다.!");
			modalClose() ;
			return;
		}
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/admin/asqInfo.do",
			data : {asqSeq : $("#asqSeq").val()},
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				$("#qstnTitl").val(data.result.qstnTitl);
				$("#qstnConts").val(data.result.qstnConts);
				$("#ansrConts").val(data.result.ansrConts);
				$("#ansrYn").val(data.result.ansrYn);
			}
		});
	} else if(iud == "D"){
		fnSaveProc();
	}	
	modalOpen() ;
}
function fnSaveProc(){
	//if(!fnRequired('qstnTitl',  '질문제목을 확인 하세요.'))     return;
	if(!fnRequired('qstnConts', '질문내용을  확인하세요.'))    return;
	if(!fnRequired('ansrConts', '답변내용을  확인하세요.'))    return;
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
			url : CommonUtil.getContextPath() + "/admin/asqSaveProc.do",
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

$(document).ready(function() {
    fnSearch(); // 페이지 로드 시 실행
});

</script>
</head>
<body>  
      <div class="tab-pane">  
      <div class="content-body">
		<div class="tab-content">
		<div class="content-wrap">
		<div class="flex-left-right mb-10">
			<div class="patient-info">
				<div class="info-name">질의목록</div>
			</div>
		</div>
        <section class="top-pannel">  
          <div class="search-box">
            <label for="search" class="form-title"  onclick="">검색구분</label>
            <input type="text" name="searchText" id="searchText" class="form-control search" placeholder="검색어를 입력하세요." 
                                                                      onkeypress="if( event.keyCode == 13 ){fnSearch();}">
            <button class="buttcon" onclick="javascript:fnSearch();"><span class="icon icon-search" ></span></button>
 
          </div> 
        </section>
        <section class="main-pannel">
          <div class="main-left w-100">
            <header class="main-hd">
              <h2></h2>
              <div class="btn-box">
                <button class="btn btn-outline-dark btn-sm" onclick="fnsave('U');">답변등록</button>
              </div>
            </header>
           
            <div class="main-content">
              <!-- 테이블 샘플 -->
              <div class="container text-center">
              <div class="table-responsive">
                <table id="infoTable" class="table table-bordered" >
                  <colgroup>
                  	<col style="width: 30px">
                  	<col style="width: 100px">
                    <col style="width: 200px">
                    <col style="width: 250px">
                    <col style="width: 100px">
                    <col style="width: 50px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th>번호</th>
                      <th>질문자</th>
                      <th>질문내용</th>
                      <th>답변내용</th>
                      <th>사용여부</th>
                      <th>등록일</th>
                    </tr>
                  </thead>
                  <tbody id="dataArea"> 
        			<tr>
        				<td colspan="7">&nbsp;</td>
        			</tr>
                  </tbody>
                </table>
              </div>
              <div id="pagingArea" class="paging"></div>
            </div>
              </div>
          </div>
        </section>
      </div>
     </div>
    </div>
  <!-- 모달 -->
  <div class="modal fade" id="adminModal" tabindex="-1" aria-labelledby="adminLFaqLabel" aria-hidden="true">
    <!-- 모달 class명으로 사이즈 조절 modal-320, 410, 520, 650, 820 -->
    <div class="modal-dialog  modal-820">
            <div class="modal-content">
        <div class="modal-header reg-head">
          <h5 class="reg-modal-title">질의응답</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" onclick="modalClose();" aria-label="Close"></button>
        </div>
        <form:form commandName="DTO" id="regForm" name="regForm" method="post">
          <input type="hidden" name="iud" id="iud"/>
          <input type="hidden" name="asqSeq" id="asqSeq"/>
          <input type="hidden" name="userUuid" id="userUuid"/>
          <div class="modal-body">
            <table class="reg-table">
              <colgroup><col style="width:18%"><col style="width:82%"></colgroup>
              <tbody>
                <tr>
                  <th><span class="req">*</span>질문내용</th>
                  <td><textarea class="form-control" placeholder="질문내용을 입력하세요." readonly name="qstnConts" id="qstnConts" style="height:160px;width:100%;"></textarea></td>
                </tr>
                <tr>
                  <th><span class="req">*</span>답변내용</th>
                  <td><textarea class="form-control" placeholder="답변내용을 입력하세요." name="ansrConts" id="ansrConts" style="height:120px;width:100%;"></textarea></td>
                </tr>
                <tr>
                  <th>사용여부</th>
                  <td>
                    <select class="form-select" name="ansrYn" id="ansrYn" style="width:auto;">
                      <option value="Y">Y</option>
                      <option value="N">N</option>
                    </select>
                  </td>
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
