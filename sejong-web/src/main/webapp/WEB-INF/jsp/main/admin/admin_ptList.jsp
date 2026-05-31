<%@ page   language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
  /* 회원가입 컨셉 — 청록 포인트 컬러 */
  :root {
    --reg-teal:        #1f9b8e;
    --reg-teal-dark:   #178074;
    --reg-teal-border: #bfe0db;
    --reg-teal-bg:     #eaf6f4;
  }

  /* ① 콘텐츠 래퍼 좌우 폭 확대
     공통 .content-body 가 display:flex + align-items:flex-start 라서 자식 래퍼가
     내용 폭만큼만 줄어들어 우측 여백이 크게 남는다. stretch + width:100% 로 꽉 채움. */
  .tab-pane .content-body { align-items: stretch; }
  .tab-pane .content-body .tab-content,
  .tab-pane .content-body .content-wrap { width: 100%; }

  /* ① 좌우 그리드 확대 — 테이블이 가용 폭을 꽉 채우도록 */
  .table-responsive {
    max-height: 640px;
    overflow-y: auto;
    overflow-x: auto;
    border: 1px solid #ccc;
  }
  #infoTable { width: 100%; table-layout: auto; }

  #infoTable thead th {
    position: sticky;
    top: 0;
    background-color: #d9edf7 !important;
    color: #000000 !important;
    z-index: 2;
    white-space: nowrap;
  }

  #infoTable tbody tr:nth-child(even) {
    background-color: #f2f2f2;
  }
  #infoTable tbody tr { cursor: pointer; }
  #infoTable tbody tr:hover { background-color: #f2f2f2; }

  /* ② 하단 페이징 */
  .paging { display:flex; justify-content:center; align-items:center; gap:4px; margin:14px 0 4px; flex-wrap:wrap; }
  .paging .pg-btn { min-width:32px; height:32px; padding:0 8px; border:1px solid var(--reg-teal-border); background:#fff; color:#333; border-radius:4px; cursor:pointer; font-size:13px; line-height:1; }
  .paging .pg-btn:hover:not(:disabled) { background:var(--reg-teal-bg); }
  .paging .pg-btn.active { background:var(--reg-teal); border-color:var(--reg-teal); color:#fff; font-weight:700; }
  .paging .pg-btn:disabled { opacity:.4; cursor:default; }

  /* ③ 모달폼 — 회원가입(거래처정보) 테이블 컨셉 */
  .reg-table { width:100%; border-collapse:collapse; table-layout:fixed; }
  .reg-table th, .reg-table td { border:1px solid var(--reg-teal-border); padding:9px 12px; vertical-align:middle; font-size:14px; }
  .reg-table th { background:var(--reg-teal-bg); color:var(--reg-teal); font-weight:600; text-align:left; width:16%; white-space:nowrap; }
  .reg-table td { background:#fff; }
  .reg-table .req { color:#dc3545; margin-right:3px; font-weight:700; }
  .reg-table input.form-control, .reg-table select.form-select { height:34px; font-size:14px; display:inline-block; width:auto; }
  .reg-table input.form-control.full { width:100%; }
  .reg-table .radio-wrap label { margin:0 18px 0 0; font-weight:500; cursor:pointer; }
  .reg-table .birth-wrap { display:flex; align-items:center; gap:6px; flex-wrap:wrap; }
  .reg-table .birth-wrap input.form-control { width:80px; }
  .modal-header.reg-head { border-bottom:2px solid var(--reg-teal); }
  .reg-modal-title { color:var(--reg-teal); font-weight:700; font-size:18px; margin:0; }
</style>
<script>
var totCnt ;
var userCheckVal ;
$(document).ready(function () {
	fnSearch() ;
})
</script>
<script type="text/javaScript">

var adminModal = new bootstrap.Modal(document.getElementById('adminModal'));

// ── 클라이언트 페이징 상태 ──
var gPatientList = [];   // 필터 적용된 전체 결과
var gPageSize    = 15;   // 한 페이지 행 수
var gCurPage     = 1;    // 현재 페이지

// 날짜 문자열을 'YYYY년 MM월 DD일'로 포맷.
// joinYmd 는 'YYYY-MM-DD HH:mm:ss', birth 는 'YYYYMMDD' 등 형식이 섞여 있어
// 숫자만 추출 후 앞 8자리(연·월·일)만 사용한다.
function fmtYmd(s){
   var digits = (s == null ? "" : ("" + s)).replace(/[^0-9]/g, "");
   if(digits.length < 8) return (s == null ? "" : s);
   return digits.substring(0,4) + "년&nbsp" + digits.substring(4,6) + "월&nbsp" + digits.substring(6,8) + "일";
}
// 날짜 문자열을 'YYYY-MM-DD'(날짜만)로 포맷 — 모달 가입일 입력칸용
function fmtYmdDash(s){
   var digits = (s == null ? "" : ("" + s)).replace(/[^0-9]/g, "");
   if(digits.length < 8) return (s == null ? "" : s);
   return digits.substring(0,4) + "-" + digits.substring(4,6) + "-" + digits.substring(6,8);
}

function fnSearch() {
    $("#infoTable tr").attr("class", "");
    document.getElementById("regForm").reset();

    $("#dataArea").empty();
    if ($("#user_gubun").is(':checked')) {
    	userCheckVal = "Y";
   	}else{
   		userCheckVal = "N";
   	}
    $.ajax({
      url : CommonUtil.getContextPath() + '/admin/selectPatientList.do',
    type : 'post',
    data : {userNm : $("#searchText").val() ,
    	    userCheck : userCheckVal,
           },
      dataType : "json",
      success : function(data) {
         if(data.error_code != "0") return;
         var list = [];
         if(data.resultCnt > 0){
            for(var i=0 ; i < data.resultCnt; i++){
               var row = data.resultLst[i];
               if (userCheckVal === 'Y' && (row.userGb === "2" || !row.phone)) {
                  continue;
               }
               list.push(row);
            }
         }
         gPatientList = list;
         gCurPage = 1;
         renderPage();
      }
   });
}

// 현재 페이지(gCurPage) 행만 렌더링 + 하단 페이징 갱신
function renderPage(){
   $("#dataArea").empty();
   var total = gPatientList.length;
   if(total === 0){
      $("#dataArea").append("<tr><td colspan='15'>검색된 정보가 없습니다.</td></tr>");
      renderPaging(0);
      return;
   }
   var totalPages = Math.ceil(total / gPageSize);
   if(gCurPage > totalPages) gCurPage = totalPages;
   if(gCurPage < 1) gCurPage = 1;

   var start = (gCurPage - 1) * gPageSize;
   var end   = Math.min(start + gPageSize, total);
   var dataTxt = "";
   for(var i = start; i < end; i++){
      var d = gPatientList[i];
      var genderText = (d.gender == "F") ? "여성" : ((d.gender == "M") ? "남성" : "");
      var userText   = (d.userGb == "2") ? "테스트" : ((d.userGb == "1") ? "실증환자" : "");
      dataTxt += '<tr class="" ondblclick="javascript:fnDtlSearch(\''+d.userUuid+'\');" id="row_'+d.userUuid+'">';
      dataTxt += "<td>" + (i+1) + "</td>";
      dataTxt += "<td>" + d.userId + "</td>";
      dataTxt += "<td>" + d.userNm + "</td>";
      dataTxt += "<td>" + d.phone.substring(0,3)+"-"+d.phone.substring(3,7)+"-"+d.phone.substring(7,11) + "</td>";
      dataTxt += "<td>" + genderText + "</td>";
      dataTxt += "<td>" + fmtYmd(d.birth) + "</td>";
      dataTxt += "<td>" + d.dtlCodeNm + "</td>";
      dataTxt += "<td>" + d.height + "</td>";
      dataTxt += "<td>" + d.weight + "</td>";
      dataTxt += "<td>" + d.email + "</td>";
      dataTxt += "<td>" + fmtYmd(d.joinYmd) + "</td>";
      dataTxt += "<td>" + d.cgmDtm + "</td>";
      dataTxt += "<td>" + d.cgmGap + "</td>";
      dataTxt += "<td>" + d.regDtm + "</td>";
      dataTxt += "<td>" + userText + "</td>";
      dataTxt += "</tr>";
   }
   $("#dataArea").append(dataTxt);

   // 각 행 더블클릭 시 모달에 데이터 전달
   $("#dataArea tr").on('dblclick', function() {
      var userUuid = $(this).attr('id').replace('row_', '');
      var userData = gPatientList.find(function(item){ return item.userUuid === userUuid; });
      openModalWithData(userData);
   });

   renderPaging(totalPages);
}

// 하단 페이징 버튼 렌더 (10개 블록 단위)
function renderPaging(totalPages){
   var $p = $("#pagingArea");
   $p.empty();
   if(totalPages < 1) return;   // 데이터가 있으면 1페이지여도 페이징 바 표시
   var block = 10;
   var startPage = Math.floor((gCurPage - 1) / block) * block + 1;
   var endPage   = Math.min(startPage + block - 1, totalPages);
   var html = "";
   html += '<button class="pg-btn" '+(gCurPage===1?'disabled':'')+' onclick="goPage(1)">&laquo;</button>';
   html += '<button class="pg-btn" '+(gCurPage===1?'disabled':'')+' onclick="goPage('+(gCurPage-1)+')">&lsaquo;</button>';
   for(var p = startPage; p <= endPage; p++){
      html += '<button class="pg-btn '+(p===gCurPage?'active':'')+'" onclick="goPage('+p+')">'+p+'</button>';
   }
   html += '<button class="pg-btn" '+(gCurPage===totalPages?'disabled':'')+' onclick="goPage('+(gCurPage+1)+')">&rsaquo;</button>';
   html += '<button class="pg-btn" '+(gCurPage===totalPages?'disabled':'')+' onclick="goPage('+totalPages+')">&raquo;</button>';
   $p.html(html);
}

function goPage(p){
   if(p < 1) return;
   gCurPage = p;
   renderPage();
}
//모달에 데이터를 전달하여 여는 함수
function openModalWithData(userData) {
  var modalElement = document.getElementById('adminModal');
  if (modalElement) {
    var adminModal = new bootstrap.Modal(modalElement);

    // 모달에 데이터 채우기
    $('#modalUserId').val(userData.userId);
    $('#modalUserNm').val(userData.userNm);
    $('#modalPhone').val(userData.phone);
    $('#modalGender').val(userData.gender === 'F' ? '여성' : '남성');
    $('#modalEmail').val(userData.email);
    $('#modalJoinDate').val(userData.joinYmd.substring(0, 4) + '-' + userData.joinYmd.substring(4, 6) + '-' + userData.joinYmd.substring(6, 8));

    // 모달 열기
    adminModal.show();
  }
}
function ExcelDownLoad() {
	  location.href =  CommonUtil.getContextPath() +  "/admin/PrintExcel.do" ;
}

// 선택된 환자의 i-Sens 혈당 데이터 수동 동기화 (마지막 측정시각 ~ 현재)
function fnSyncBlood() {
	var userUuid = $("#userUuid").val();
	if (!userUuid) {
		alert("먼저 환자 행을 클릭하여 선택하세요.");
		return;
	}
	if (!confirm("선택한 환자의 i-Sens 혈당 데이터를 동기화하시겠습니까?\n(마지막 측정시각 이후 ~ 현재까지)")) return;

	$.ajax({
		type: "post",
		url: CommonUtil.getContextPath() + "/syncPatientBlood.do",
		data: JSON.stringify({ userUuid: userUuid }),
		contentType: "application/json",
		dataType: "json",
		success: function(data) {
			if (data.IsSucceed) {
				alert(data.Message || ("동기화 완료: " + data.Data + " 건"));
				fnSearch();
			} else {
				alert("동기화 실패: " + (data.Message || ""));
			}
		},
		error: function(xhr, status, error) {
			alert("동기화 요청 중 오류가 발생했습니다.");
			console.error(status, error);
		}
	});
}

function fnDtlSearch(data){
   if(data == '' || data == null) return;

   document.regForm.iud.value  = "U";
   document.regForm.userUuid.value = data ;

   //row 클릭시 바탕색 변경 처리 Start
   $("#infoTable tr").attr("class", "");
   $("#infoTable #"+data).attr("checked", true);
   $("#infoTable #row_"+data).attr("class", "tr-primary");
   fnSave('U') ;
}

//입력,수정 , 비밀번호 초기화  버큰 클릭시
function fnSave(iud){
   $("#iud").val(iud);
   uidGubun = iud ;
   if(iud == "I"){
      //등록폼 초기화
      document.getElementById("regForm").reset();
      $("#adminModal").modal("show");

   }else if(iud == "U"){

      if($("#userUuid").val() == ""){
         alert("선택된  정보가 없습니다.!");
         $("#adminModal").modal("hide");
         return;
      }

      $.ajax( {
         type : "post",
         url : CommonUtil.getContextPath() + "/admin/PatientInfo.do",
         data : {userUuid : $("#userUuid").val()},
         dataType : "json",
         success : function(data) {
            if(data.error_code != "0") {
               alert(data.error_msg);
               return;
            }
            console.log(data.result);
            $("#email").prop("readonly","true");
            $("#userNm").prop("readonly","true");
            $("#phone").prop("readonly","true");
            $("#userId").prop("readonly","true");
            $("#birth").prop("readonly","true");
            $("#year").prop("readonly","true");
            $("#month").prop("readonly","true");
            $("#day").prop("readonly","true");
            $("#gender").prop("readonly","true");
            $("#dtlCodeNm").prop("readonly","true");
            $("#height").prop("readonly","true");
            $("#weight").prop("readonly","true");
            $("#joinYmd").prop("readonly","true");
            $("#genderF").prop("readonly","true");
            $("#genderM").prop("readonly","true");
            $("#blodGb").prop("readonly","true");


            $("#phone").val(data.result.phone);
            $("#userId").val(data.result.userId);
            $("#email").val(data.result.email);
            $("#userNm").val(data.result.userNm);
            $("#regDtm").val(data.result.regDtm);

            $("#birth").val(data.result.birth);
            $("#year").val(data.result.birth.substring(0,4));
            $("#month").val(data.result.birth.substring(4,6));
            $("#day").val(data.result.birth.substring(6,8));

            $("#gender").val(data.result.gender).attr("onclick", "return false;");;
            $("#dtlCodeNm").val(data.result.dtlCodeNm);
            $("#height").val(data.result.height);
            $("#weight").val(data.result.weight);
            $("#joinYmd").val(fmtYmdDash(data.result.joinYmd));
            $("#blodGb").val(data.result.blodGb);
            $("#userGb").val(data.result.userGb);
            if(data.result.gender == "F")
               $("#genderF").prop("checked","checked");
            else
               $("#genderM").prop("checked","checked");

            if(data.result.userGb == "1")
                $("#user_gb1").prop("checked","checked");
            else
                $("#user_gb2").prop("checked","checked");

         }
      });
      $("#adminModal").modal("show");
   }else
      return;
   }
function fnSaveProc(){
   if(!fnRequired('userNm', '성명을 확인 하세요.'))   return;
   if(!fnRequired('phone', '전화번호를  확인하세요.'))  return;
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
         url : CommonUtil.getContextPath() + "/admin/PatientSaveAct.do",
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

function modalClose(){
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
				<div class="info-name">환자 목록</div>
			</div>
		</div>
        <section class="top-pannel">
          <div class="search-box">
            <label for="search" class="form-title" onclick="">검색어 입력</label>
            <input type="text" name="searchText" id="searchText" class="form-control search" placeholder="환자명 또는 전화번호를 입력하세요." onkeypress="if( event.keyCode == 13 ){fnSearch();}">
            <button class="buttcon" onclick="javascript:fnSearch();"><span class="icon icon-search" ></span></button>
            <input class="form-check-input" type="checkbox" name="user_gubun"  onchange="fnSearch()"
						id="user_gubun" value="Y"> <span class="ml-1">모니터링(미등록 1일이상 경과)</span>
			<input type="hidden" name="userCheck" id="userCheck" />
          </div>
          <div class="align-right">
                  <button type="button" class="btn btn-outline-dark" onclick="ExcelDownLoad();">모니터링대상자출력</button>
          </div>
        </section>

        <section class="main-pannel">
          <div class="main-left w-100">
            <header class="main-hd">
               <h2></h2>
            </header>
            <div class="main-content">
              <!-- 테이블 샘플 -->
              <div class="table-responsive">
                <table id="infoTable" class="table table-bordered">
                  <thead>
                    <tr>
                      <th>번호</th>
                      <th>아이디</th>
                      <th>이름</th>
                      <th>연락처</th>
                      <th>성별</th>
                      <th>생년월일</th>
                      <th>당뇨구분</th>
                      <th>신장</th>
                      <th>몸무게</th>
                      <th>이메일</th>
                      <th>가입일</th>
                      <th>최종검사</th>
                      <th>경과일</th>
                      <th>가입접수일시</th>
                      <th>실증환자</th>
                    </tr>
                  </thead>
                  <tbody id="dataArea">
                 <tr>
                    <td colspan="12">&nbsp;</td>
                 </tr>
                  </tbody>
                </table>
              </div>
              <!-- ② 하단 페이징 -->
              <div id="pagingArea" class="paging"></div>
            </div>
          </div>
        </section>
      </div>
     </div>
  </div>
  <!-- 모달 -->
  <div class="modal fade" id="adminModal" tabindex="-1" aria-labelledby="adminModallLabel" aria-hidden="true">
    <div class="modal-dialog  modal-820">

      <div class="modal-content">
        <div class="modal-header reg-head">
          <h5 class="reg-modal-title">환자 정보</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" onclick="modalClose();" aria-label="Close"></button>
        </div>
          <form:form commandName="DTO" id="regForm" name="regForm" method="post">
              <input type="hidden" name="iud" id="iud" />
              <input type="hidden" name="userUuid" id="userUuid" />
        <div class="modal-body">
          <table class="reg-table">
            <colgroup>
              <col style="width:16%"><col style="width:34%"><col style="width:16%"><col style="width:34%">
            </colgroup>
            <tbody>
              <tr>
                <th><span class="req">*</span>환자이름</th>
                <td><input type="text" name="userNm" id="userNm" class="form-control full" placeholder="사용자 명을 입력하세요."></td>
                <th><span class="req">*</span>아이디</th>
                <td><input type="text" name="userId" id="userId" class="form-control full" placeholder="아이디를 입력하세요."></td>
              </tr>
              <tr>
                <th><span class="req">*</span>전화번호</th>
                <td><input type="text" id="phone" name="phone" class="form-control full" value="" placeholder="전화번호를 입력하세요." onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" maxLength="11"></td>
                <th><span class="req">*</span>가입일</th>
                <td><input type="text" name="joinYmd" id="joinYmd" class="form-control full" placeholder="가입일를 입력하세요."></td>
              </tr>
              <tr>
                <th><span class="req">*</span>생년월일</th>
                <td colspan="3" id="birth">
                  <div class="birth-wrap">
                    <input type="text" class="form-control" name="year" id="year" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" maxLength="4">년
                    <select class="form-select" name="month" id="month" disabled>
                      <option value="">선택</option>
                      <option value="01">1월</option>
                      <option value="02">2월</option>
                      <option value="03">3월</option>
                      <option value="04">4월</option>
                      <option value="05">5월</option>
                      <option value="06">6월</option>
                      <option value="07">7월</option>
                      <option value="08">8월</option>
                      <option value="09">9월</option>
                      <option value="10">10월</option>
                      <option value="11">11월</option>
                      <option value="12">12월</option>
                    </select>월
                    <select class="form-select" name="day" id="day" disabled>
                      <option value="">선택</option>
                      <option value="01">1</option>
                      <option value="02">2</option>
                      <option value="03">3</option>
                      <option value="04">4</option>
                      <option value="05">5</option>
                      <option value="06">6</option>
                      <option value="07">7</option>
                      <option value="08">8</option>
                      <option value="09">9</option>
                      <option value="10">10</option>
                      <option value="11">11</option>
                      <option value="12">12</option>
                      <option value="13">13</option>
                      <option value="14">14</option>
                      <option value="15">15</option>
                      <option value="16">16</option>
                      <option value="17">17</option>
                      <option value="18">18</option>
                      <option value="19">19</option>
                      <option value="20">20</option>
                      <option value="21">21</option>
                      <option value="22">22</option>
                      <option value="23">23</option>
                      <option value="24">24</option>
                      <option value="25">25</option>
                      <option value="26">26</option>
                      <option value="27">27</option>
                      <option value="28">28</option>
                      <option value="29">29</option>
                      <option value="30">30</option>
                      <option value="31">31</option>
                    </select>일
                  </div>
                </td>
              </tr>
              <tr>
                <th>성별</th>
                <td id="gender" class="readonly">
                  <div class="radio-wrap">
                    <label><input class="form-check-input" type="radio" name="gender" id="genderF" value="F"> 여자</label>
                    <label><input class="form-check-input" type="radio" name="gender" id="genderM" value="M"> 남자</label>
                  </div>
                </td>
                <th>실증여부</th>
                <td id="userGb" class="readonly">
                  <div class="radio-wrap">
                    <label><input class="form-check-input" type="radio" name="userGb" id="user_gb1" value="1"> 실증환자</label>
                    <label><input class="form-check-input" type="radio" name="userGb" id="user_gb2" value="2"> 테스트</label>
                  </div>
                </td>
              </tr>
              <tr>
                <th><span class="req">*</span>가입접수일시</th>
                <td><input type="text" name="regDtm" id="regDtm" class="form-control full" placeholder="가입접수일시 입력하세요."></td>
                <th>당뇨분류</th>
                <td>
                  <select class="form-select" name="blodGb" id="blodGb" style="width:100%;">
                    <option value="">선택</option>
                    <c:forEach var="result" items="${cdtpList}" varStatus="status">
                      <option value="${result.dtlCode}">${result.dtlCodeNm}</option>
                    </c:forEach>
                  </select>
                </td>
              </tr>
              <tr>
                <th><span class="req">*</span>신장(cm)</th>
                <td><input type="text" id="height" name="height" class="form-control full" value="" placeholder="신장을 입력하세요."></td>
                <th><span class="req">*</span>몸무게(kg)</th>
                <td><input type="text" id="weight" name="weight" class="form-control full" value="" placeholder="몸무게를 입력하세요."></td>
              </tr>
              <tr>
                <th>이메일</th>
                <td colspan="3"><input type="text" id="email" name="email" class="form-control full" value="" placeholder="이메일를 입력하세요."></td>
              </tr>
            </tbody>
          </table>
        </div>
        </form:form>
        <div class="modal-footer">
          <button type="button" class="btn btn-outline-dark btn-sm" data-bs-dismiss="modal" onclick="modalClose();">목록</button>
        </div>
      </div>

    </div>
  </div>
</body>
</html>
