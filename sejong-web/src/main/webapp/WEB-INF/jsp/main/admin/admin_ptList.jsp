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
    max-height: 600px; /* 적당한 높이 설정 (10개 행 기준으로 조정) */
    overflow-y: auto; /* 수직 스크롤 활성화 */
    border: 1px solid #ccc; /* 테두리 추가 */
  }

  table thead th {
    position: sticky;
    top: 0; /* 헤더 고정 */
    background-color: #f8f9fa; /* 헤더 배경색 */
    z-index: 2; /* 헤더가 데이터보다 위에 위치하도록 설정 */
  }

  table tbody tr:nth-child(even) {
    background-color: #f2f2f2; /* 짝수행 배경색 설정 (가독성 개선) */
  }
</style>
<script>
var totCnt ;
var user_check ;
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
//       if($('#searchText').val() == "") {
//      alert("검색어를 입력하세요.");
//      $('#searchText').focus();
//      return; 
//    }
    if ($("#user_gubun").is(':checked')) {
    	user_check = "Y";
   	}else{
   		user_check = "N";
   	} 
    $.ajax({
      url : CommonUtil.getContextPath() + '/admin/selectPatientList.do',
    type : 'post',
    data : {user_nm : $("#searchText").val() , 
    	    user_check : user_check,
           },
      dataType : "json",
      success : function(data) {
         if(data.error_code != "0") return;
         if(data.resultCnt > 0 ){
          var dataTxt = "";
          for(var i=0 ; i < data.resultCnt; i++){
        	 if (user_check === 'Y' && (data.resultLst[i].user_gb === "2" || !data.resultLst[i].phone) ) {
                  continue; // "2"인 경우 건너뜀
             }   
             var genderText = "";
             if (data.resultLst[i].gender == "F"){
                genderText = "여성";
              } else if(data.resultLst[i].gender == "M") {
                  genderText = "남성";
              } 
             var userText = "";
             if (data.resultLst[i].user_gb == "2"){
            	 userText = "테스트";
              } else if(data.resultLst[i].user_gb == "1") {
            	  userText = "실증환자";
              }              
             dataTxt = '<tr  class="" onclick="javascript:fnDtlSearch(\''+data.resultLst[i].user_uuid+'\');" id="row_'+data.resultLst[i].user_uuid+'">'; 
            dataTxt +=    "<td>" + (i+1)  + "</td>" ; 
            dataTxt +=  "<td>" + data.resultLst[i].user_id  + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].user_nm  + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].phone.substring(0,3)+"-" + 
                            data.resultLst[i].phone.substring(3,7)+"-" + 
                            data.resultLst[i].phone.substring(7,11)+"</td>" ;
                      
            dataTxt +=  "<td>" + genderText   + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].birth.substring(0,4)+"년&nbsp" + 
                            data.resultLst[i].birth.substring(4,6)+"월&nbsp" + 
                            data.resultLst[i].birth.substring(6,8)+"일" + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].dtl_code_nm   + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].height        + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].weight        + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].email  + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].join_ymd.substring(0,4)+"년&nbsp" + 
                            data.resultLst[i].join_ymd.substring(4,6)+"월&nbsp" + 
                            data.resultLst[i].join_ymd.substring(6,8)+"일" + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].cgm_dtm        + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].cgm_gap        + "</td>" ;
            dataTxt +=  "<td>" + data.resultLst[i].reg_dtm        + "</td>" ;     
            dataTxt +=  "<td>" + userText   + "</td>" ;             
            dataTxt +=  "</tr>";
               $("#dataArea").append(dataTxt);
            }
          // 각 행 클릭 시 모달에 데이터 전달
          $("#dataArea tr").on('click', function() {
            var user_uuid = $(this).attr('id').replace('row_', ''); // 행 ID에서 user_uuid 추출
            var userData = data.resultLst.find(function(item) { return item.user_uuid === user_uuid; });

            // 모달에 데이터 채우기
            openModalWithData(userData);  // 사용자 데이터를 모달로 전달
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
    $('#modalUserId').val(userData.user_id);
    $('#modalUserNm').val(userData.user_nm);
    $('#modalPhone').val(userData.phone);
    $('#modalGender').val(userData.gender === 'F' ? '여성' : '남성');
    $('#modalEmail').val(userData.email);
    $('#modalJoinDate').val(userData.join_ymd.substring(0, 4) + '-' + userData.join_ymd.substring(4, 6) + '-' + userData.join_ymd.substring(6, 8));
    
    // 모달 열기
    adminModal.show();
  }
}
function ExcelDownLoad() { 
	  location.href =  CommonUtil.getContextPath() +  "/admin/PrintExcel.do" ;
}
   
function fnDtlSearch(data){ 
   if(data == '' || data == null) return;
    
   document.regForm.iud.value  = "U";
   document.regForm.user_uuid.value = data ; 
   
   //row 클릭시 바탕색 변경 처리 Start 
   $("#infoTable tr").attr("class", ""); 
   $("#infoTable #"+data).attr("checked", true);
   $("#infoTable #row_"+data).attr("class", "tr-primary");
   fnSave('U') ; //선택하고 바로 뜨게 그리드 클릭 
}

//입력,수정 , 비밀번호 초기화  버큰 클릭시
function fnSave(iud){
   $("#iud").val(iud);  // 입력(I), 수정(U), 삭제(D) 
   uidGubun = iud ;   
   if(iud == "I"){
      //등록폼 초기화
      document.getElementById("regForm").reset();
        
      /* $("#dataArea").empty();  
      setCurrDate("start_date");
      $("#end_date").val("9999-12-31");
      $("#user_id").prop("readonly",""); */
      $("#adminModal").modal("show");
      
   }else if(iud == "U"){
      
      if($("#user_uuid").val() == ""){
         alert("선택된  정보가 없습니다.!");
         $("#adminModal").modal("hide");
         return;
      }

      $.ajax( {
         type : "post",
         url : CommonUtil.getContextPath() + "/admin/PatientInfo.do",
         data : {user_uuid : $("#user_uuid").val()},
         dataType : "json",
         success : function(data) {    
            if(data.error_code != "0") {
               alert(data.error_msg);
               return;
            }
            console.log(data.result);
            $("#email").prop("readonly","true");
            $("#user_nm").prop("readonly","true");
            $("#phone").prop("readonly","true");
            $("#user_id").prop("readonly","true");
            $("#birth").prop("readonly","true");
            $("#year").prop("readonly","true");
            $("#month").prop("readonly","true");
            $("#day").prop("readonly","true");
            $("#gender").prop("readonly","true");
            $("#dtl_code_nm").prop("readonly","true");
            $("#height").prop("readonly","true");
            $("#weight").prop("readonly","true");
            $("#join_ymd").prop("readonly","true");
            $("#genderF").prop("readonly","true");
            $("#genderM").prop("readonly","true");
            $("#blod_gb").prop("readonly","true"); 
            
            
            $("#phone").val(data.result.phone);
            $("#user_id").val(data.result.user_id);
            $("#email").val(data.result.email);
            $("#user_nm").val(data.result.user_nm);
            $("#reg_dtm").val(data.result.reg_dtm);

            $("#birth").val(data.result.birth);
            $("#year").val(data.result.birth.substring(0,4));
            $("#month").val(data.result.birth.substring(4,6));
            $("#day").val(data.result.birth.substring(6,8));
            
            $("#gender").val(data.result.gender).attr("onclick", "return false;");;
            $("#dtl_code_nm").val(data.result.dtl_code_nm);
            $("#height").val(data.result.height);
            $("#weight").val(data.result.weight);   
            $("#join_ymd").val(data.result.join_ymd);
            $("#blod_gb").val(data.result.blod_gb);
            $("#user_gb").val(data.result.user_gb);
            if(data.result.gender == "F")
               $("#genderF").prop("checked","checked");
            else
               $("#genderM").prop("checked","checked");
            
            if(data.result.user_gb == "1")
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
   if(!fnRequired('user_nm', '성명을 확인 하세요.'))   return;
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
				<div class="info-name">환자 목록</div>
			</div>
		</div>
   <!--     <header class="header"> 원래 
        <h1>
         &nbsp 환자 정보관리
        </h1>
      </header>
      <div class="tab-pane"> 
      <div class="content-body">
    -->  
        <section class="top-pannel">  
          <div class="search-box">
            <label for="search" class="form-title" onclick="">검색어 입력</label>
            <input type="text" name="searchText" id="searchText" class="form-control search" placeholder="환자명 또는 전화번호를 입력하세요." onkeypress="if( event.keyCode == 13 ){fnSearch();}">
            <button class="buttcon" onclick="javascript:fnSearch();"><span class="icon icon-search" ></span></button>
            <input class="form-check-input" type="checkbox" name="user_gubun"  onchange="fnSearch()"
						id="user_gubun" value="Y"> <span class="ml-1">모니터링(미등록 1일이상 경과)</span>
			<input type="hidden" name="user_check" id="user_check" />
          </div> 
          <div class="align-right">
                  <button type="button" class="btn btn-outline-dark" onclick="ExcelDownLoad();">모니터링대상자출력</button>
          </div>
        </section>
        
        <section class="main-pannel">
          <div class="main-left w-100">
            <header class="main-hd">
             <!--  <h2>&nbsp 환자 목록</h2> 원래 -->  
               <h2></h2>
              <!--  
              <div class="btn-box"> 
                <button class="btn btn-outline-dark btn-sm" onclick="fnSave('U');">수정</button>
                <button class="btn btn-primary btn-sm" onclick="fnSave('I');" >입력</button>
              </div>
              -->
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
   <!--   원래 밑에 없음  -->  
  </div>  
  <!-- 모달 -->
  <div class="modal fade" id="adminModal" tabindex="-1" aria-labelledby="adminModallLabel" aria-hidden="true">
    <!-- 모달 class명으로 사이즈 조절 modal-320, 410, 520, 650, 820 -->
    <div class="modal-dialog  modal-820">
       
      <div class="modal-content">
        <div class="modal-footer">
         <!--   <button type="button" class="btn btn-primary btn-sm" onclick="fnSaveProc();">저장</button> -->
          <button type="button" class="btn btn-outline-dark btn-sm" data-bs-dismiss="modal" onclick="modalClose();">목록</button>
        </div>
          <form:form commandName="DTO" id="regForm" name="regForm" method="post"> 
              <input type="hidden" name="iud" id="iud" />
              <input type="hidden" name="user_uuid" id="user_uuid" />
        <div class="modal-body">
          <div class="form-container"> 
            <div class="form-wrap w-50">
              <label for="" class="critical">환자이름</label>
              <input type="text" name="user_nm" id="user_nm" class="form-control" placeholder="사용자 명을 입력하세요.">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">아이디</label>
              <input type="text" name="user_id" id="user_id" class="form-control" placeholder="아이디를 입력하세요.">
            </div>
            <!-- 
            <div class="form-wrap w-50">
              <label for="" class="critical">비밀번호</label>
              <input type="password" name="user_pw"  id="user_pw" class="form-control" placeholder="비밀번호를 입력하세요.">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">비밀번호 확인</label>
              <input type="password" name="user_pw2"  id="user_pw2" class="form-control" placeholder="비밀번호를 재입력하세요.">
            </div>
            -->
            <div class="form-wrap w-50">
              <label for="" class="critical">전화번호</label>
              <input type="text" id="phone" name="phone" class="form-control" value="" placeholder="전화번호를 입력하세요." onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" maxLength="11">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">가입일</label>
              <input type="text" name="join_ymd"  id="join_ymd" class="form-control" placeholder="가입일를 입력하세요.">
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
             <div class="form-wrap w-50" id="user_gb" class="readonly">
              <label for="" class="align-top">실증여부</label>
              <p>
                <input class="form-check-input" type="radio" name="user_gb" id="user_gb1" value="1" >
                <span class="ml-1">실증환자</span>
              </p>
              <p>
                <input class="form-check-input" type="radio" name="user_gb" id="user_gb2" value="2" >
                <span class="ml-1">테스트</span>
              </p>
            </div>  
            <div class="form-wrap w-50">
              <label for="" class="critical">가입접수일시</label>
              <input type="text" name="reg_dtm"  id="reg_dtm" class="form-control" placeholder="가입접수일시 입력하세요.">
            </div>          
             
           <div class="form-wrap w-50">
	           <label for="">당뇨분류</label> 
	            <select class="form-select" name="blod_gb" id="blod_gb"> <!-- readonly -->
	                <option value="">선택</option> 
	                <c:forEach var="result" items="${cdtpList}" varStatus="status">
	                   <option value="${result.dtl_code}">${result.dtl_code_nm}</option>
	                </c:forEach> 
	           </select>
           </div>
             
   <!-- 
            <div class="form-wrap w-50">
              <label for="" class="critical">당뇨구분</label>
              <input type="text" id="dtl_code_nm" name="dtl_code_nm" class="form-control" value="" placeholder="당뇨을 입력하세요.">
            </div>
    -->
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
