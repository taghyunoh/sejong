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
  .table-responsive {
    max-height: 600px;
    overflow-y: auto;
    border: 1px solid #ccc;
  }

  table thead th {
    position: sticky;
    top: 0;
    background-color: #f8f9fa;
    z-index: 2;
  }

  table tbody tr:nth-child(even) {
    background-color: #f2f2f2;
  }
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
         if(data.resultCnt > 0 ){
          var dataTxt = "";
          for(var i=0 ; i < data.resultCnt; i++){
        	 if (userCheckVal === 'Y' && (data.resultLst[i].userGb === "2" || !data.resultLst[i].phone) ) {
                  continue;
             }
             var genderText = "";
             if (data.resultLst[i].gender == "F"){
                genderText = "여성";
              } else if(data.resultLst[i].gender == "M") {
                  genderText = "남성";
              }
             var userText = "";
             if (data.resultLst[i].userGb == "2"){
            	 userText = "테스트";
              } else if(data.resultLst[i].userGb == "1") {
            	  userText = "실증환자";
              }
             dataTxt = '<tr  class="" onclick="javascript:fnDtlSearch(\''+data.resultLst[i].userUuid+'\');" id="row_'+data.resultLst[i].userUuid+'">';
            dataTxt +=    "<td>" + (i+1)  + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].userId  + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].userNm  + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].phone.substring(0,3)+"-" +
                            data.resultLst[i].phone.substring(3,7)+"-" +
                            data.resultLst[i].phone.substring(7,11)+"</td>" ;

            dataTxt +=  "<td>" + genderText   + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].birth.substring(0,4)+"년&nbsp" +
                            data.resultLst[i].birth.substring(4,6)+"월&nbsp" +
                            data.resultLst[i].birth.substring(6,8)+"일" + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].dtlCodeNm   + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].height        + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].weight        + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].email  + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].joinYmd.substring(0,4)+"년&nbsp" +
                            data.resultLst[i].joinYmd.substring(4,6)+"월&nbsp" +
                            data.resultLst[i].joinYmd.substring(6,8)+"일" + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].cgmDtm        + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].cgmGap        + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].regDtm        + "</td>" ;
            dataTxt +=  "<td>" + userText   + "</td>" ;
            dataTxt +=  "</tr>";
               $("#dataArea").append(dataTxt);
            }
          // 각 행 클릭 시 모달에 데이터 전달
          $("#dataArea tr").on('click', function() {
            var userUuid = $(this).attr('id').replace('row_', '');
            var userData = data.resultLst.find(function(item) { return item.userUuid === userUuid; });

            // 모달에 데이터 채우기
            openModalWithData(userData);
          });
         }else{
             $("#dataArea").append("<tr><td colspan='12'>검색된 정보가 없습니다.</td></tr>");
        }
      }
   });
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
            $("#joinYmd").val(data.result.joinYmd);
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
                  <button type="button" class="btn btn-outline-dark" onclick="fnSyncBlood();">혈당 동기화</button>
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
                  <colgroup>
                    <col style="width: 30px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 50px">
                    <col style="width: 50px">
                    <col style="width: 80px">
                    <col style="width: 180px">
                    <col style="width: 50px">
                    <col style="width: 30px">
                    <col style="width: 30px">
                    <col style="width: 50px">
                  </colgroup>
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
        <div class="modal-footer">
          <button type="button" class="btn btn-outline-dark btn-sm" data-bs-dismiss="modal" onclick="modalClose();">목록</button>
        </div>
          <form:form commandName="DTO" id="regForm" name="regForm" method="post">
              <input type="hidden" name="iud" id="iud" />
              <input type="hidden" name="userUuid" id="userUuid" />
        <div class="modal-body">
          <div class="form-container">
            <div class="form-wrap w-50">
              <label for="" class="critical">환자이름</label>
              <input type="text" name="userNm" id="userNm" class="form-control" placeholder="사용자 명을 입력하세요.">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">아이디</label>
              <input type="text" name="userId" id="userId" class="form-control" placeholder="아이디를 입력하세요.">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">전화번호</label>
              <input type="text" id="phone" name="phone" class="form-control" value="" placeholder="전화번호를 입력하세요." onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" maxLength="11">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">가입일</label>
              <input type="text" name="joinYmd"  id="joinYmd" class="form-control" placeholder="가입일를 입력하세요.">
            </div>
            <div class="form-wrap w-70" id="birth">
              <label for="" class="critical">생년월일</label>
            <input type="text" class="form-control" name="year" id="year" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" maxLength="4">년
            <select class="form-select"   name="month" id="month" disabled>
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
              <select class="form-select"  name="day" id="day" disabled>
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
            <div class="form-wrap w-50" id="gender" class="readonly">
              <label for="" class="align-top">성별</label>
              <p>
                <input class="form-check-input" type="radio" name="gender" id="genderF" value="F" >
                <span class="ml-1">여자</span>
              </p>
              <p>
                <input class="form-check-input" type="radio" name="gender" id="genderM" value="M" >
                <span class="ml-1">남자</span>
              </p>
            </div>
             <div class="form-wrap w-50" id="userGb" class="readonly">
              <label for="" class="align-top">실증여부</label>
              <p>
                <input class="form-check-input" type="radio" name="userGb" id="user_gb1" value="1" >
                <span class="ml-1">실증환자</span>
              </p>
              <p>
                <input class="form-check-input" type="radio" name="userGb" id="user_gb2" value="2" >
                <span class="ml-1">테스트</span>
              </p>
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">가입접수일시</label>
              <input type="text" name="regDtm"  id="regDtm" class="form-control" placeholder="가입접수일시 입력하세요.">
            </div>

           <div class="form-wrap w-50">
	           <label for="">당뇨분류</label>
	            <select class="form-select" name="blodGb" id="blodGb">
	                <option value="">선택</option>
	                <c:forEach var="result" items="${cdtpList}" varStatus="status">
	                   <option value="${result.dtlCode}">${result.dtlCodeNm}</option>
	                </c:forEach>
	           </select>
           </div>

            <div class="form-wrap w-50">
              <label for="" class="critical">신장(cm)</label>
              <input type="text" id="height" name="height" class="form-control" value="" placeholder="신장을 입력하세요.">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">몸무게(kg)</label>
              <input type="text" id="weight" name="weight" class="form-control" value="" placeholder="몸무게를 입력하세요.">
            </div>
            <div class="form-wrap w-100">
              <label for="" >이메일</label>
              <input type="text" id="email" name="email" class="form-control" value="" placeholder="이메일를 입력하세요.">
            </div>
          </div>
        </div>
        </form:form>
      </div>

    </div>
  </div>
</body>
</html>
