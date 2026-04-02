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
<script type="text/javaScript"> 

var patientModal = new bootstrap.Modal(document.getElementById('patientModal'));

function fnSearch() {

	 $("#infoTable tr").attr("class", ""); 
	
	 document.getElementById("regForm").reset();
	 
	 $("#dataArea").empty();
//	 	if($('#searchText').val() == "") {
//		alert("검색어를 입력하세요.");
//		$('#searchText').focus();
//		return; 
//	 }

	$.ajax({
   	url :  CommonUtil.getContextPath() + '/doctor/selectPatientList.do',
    type : 'post',
    data : {user_nm : $("#searchText").val()},
   	dataType : "json",
   	success : function(data) {
   		if(data.error_code != "0") return;
   		if(data.resultCnt > 0 ){
    		var dataTxt = "";
    		for(var i=0 ; i < data.resultCnt; i++){
    			//성별 구분
    			var genderText = "";
	    		if (data.resultLst[i].gender == "F"){
	    			genderText = "여성";
	    	    } else if(data.resultLst[i].gender == "M") {
	    	        genderText = "남성";
	    	    } 
	    		
	    		//만나이 계산
    		    // 현재 날짜를 가져옵니다.
	    		  var birthYear = data.resultLst[i].birth.substring(0,4);
				  var birthMonth = data.resultLst[i].birth.substring(4,6);
				  var birthDay = data.resultLst[i].birth.substring(6,8);
				  var birthDate = birthYear+ "-" + birthMonth +"-" + birthDay;
					  
				  var currentDate = new Date();
				  var currentYear = currentDate.getFullYear();
				  var currentMonth = currentDate.getMonth();
				  var currentDay = currentDate.getDate();
				  
				  var age = currentYear - birthYear;
				  if (currentMonth < birthMonth) {
					    age-1;
					  }
					  // 현재 월과 생일의 월이 같은 경우, 현재 일과 생일의 일을 비교합니다.
					  else if (currentMonth === birthMonth && currentDay < birthDay) {
					    age-1;
					  }else{
						age;
					  }
				  
					  
	    		  
    			dataTxt = '<tr  class="" onclick="javascript:fnDtlSearch(\''+data.resultLst[i].user_nm+'\');" id="row_'+data.resultLst[i].user_nm+'">'; 
				dataTxt += 	"<td>" + (i+1)  + "</td>" ; 
				dataTxt +=  "<td>" + data.resultLst[i].user_nm  + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].phone.substring(0,3)+"-****-" + 
									 data.resultLst[i].phone.substring(7,11)+"</td>" ;
				dataTxt +=  "<td>" + genderText   + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].birth.substring(0,4)+"년&nbsp" + 
									 data.resultLst[i].birth.substring(4,6)+"월&nbsp" + 
									 data.resultLst[i].birth.substring(6,8)+"일" + "</td>" ;
				dataTxt +=  "<td>" + age   + "</td>" ;
				dataTxt +=  "<td>" + data.resultLst[i].joinYmd.substring(0,4)+"년&nbsp" + 
									 data.resultLst[i].joinYmd.substring(4,6)+"월&nbsp" + 
									 data.resultLst[i].joinYmd.substring(6,8)+"일" + "</td>" ;
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
		 
		document.regForm.iud.value  = "U";
		document.regForm.user_nm.value = data ; 
		
		//row 클릭시 바탕색 변경 처리 Start 
		$("#infoTable tr").attr("class", ""); 
		$("#infoTable #"+data).attr("checked", true);
		$("#infoTable #row_"+data).attr("class", "tr-primary");
 
	}
	
	 //입력,수정 , 비밀번호 초기화  버큰 클릭시
	function fnSave(iud){
		
		$("#iud").val(iud);
		if(iud == "I"){
			//등록폼 초기화
			document.getElementById("regForm").reset();
			  
			/* $("#dataArea").empty();  
			setCurrDate("start_date");
			$("#end_date").val("9999-12-31");
			$("#user_id").prop("readonly",""); */
			$("#patientModal").modal("show");
			
		}else if(iud == "U"){
			
			if(!fnRequired('user_nm', '선택된 정보가 없습니다.')) return;

			$.ajax( {
				type : "post",
				url : "/doctor/PatientInfo.do",
				data : {user_nm : $("#user_nm").val()},
				dataType : "json",
				success : function(data) {    
					if(data.error_code != "0") {
						alert(data.error_msg);
						return;
					}
					console.log(data.result);
					$("#phone").val(data.result.phone);
					$("#user_id").val(data.result.user_id);
					$("#email").val(data.result.email);
					$("#user_id").prop("readonly","true");
					$("#user_nm").val(data.result.user_nm);
					$("#gender").prop("readonly","true");

					$("#birth").val(data.result.birth);
					$("#year").val(data.result.birth.substring(0,4));
					$("#month").val(data.result.birth.substring(4,6));
					$("#day").val(data.result.birth.substring(6,8));
					
					$("#gender").val(data.result.gender);
					if(data.result.gender == "F")
						$("#genderF").prop("checked","checked");
					else
						$("#genderM").prop("checked","checked");
					
					
				}
			});
			$("#patientModal").modal("show");
		}else
				return;
		}
		

	//
	function modalClose(){
		//모달이 있을 경우
		$("#patientModal").modal("hide");
	}
	

	
</script>
</head>
<body>  


      <header class="header">
        <h1>
         &nbsp 환자 정보관리
        </h1>
      </header>
      <div class="content-body">
        <section class="top-pannel">  
          <div class="search-box">
            <label for="search" class="form-title" onclick="">검색어 입력</label>
            <input type="text" name="searchText" id="searchText" class="form-control search" placeholder="환자명 또는 전화번호를 입력하세요." onkeypress="if( event.keyCode == 13 ){fnSearch();}">
            <button class="buttcon" onclick="javascript:fnSearch();"><span class="icon icon-search" ></span></button>
          </div> 
        </section>
        
        <section class="main-pannel">
          <div class="main-left w-100">
            <header class="main-hd">
              <h2>&nbsp 환자 목록</h2>
             <!--  <div class="btn-box"> 
                <button class="btn btn-outline-dark btn-sm" onclick="fnSave('U');">수정</button>
                <button class="btn btn-primary btn-sm" onclick="fnSave('I');" >입력</button>
              </div> -->
            </header>
            <div class="main-content">
              <!-- 테이블 샘플 -->
              <div class="table-responsive">
                <table id="infoTable" class="table table-bordered">
                  <colgroup>
                  	<col style="width: 50px">
                    <col style="width: 100px">
                    <col style="width: 200px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 80px">
                    <col style="width: 180px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th>번호</th>
                      <th>이름</th>
                      <th>연락처</th>
                      <th>성별</th>
                      <th>나이</th>
                      <th>생년월일</th>
                      <th>가입일</th>
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
  
  <!-- 모달 -->
  <div class="modal fade" id="patientModal" tabindex="-1" aria-labelledby="PatientModallLabel" aria-hidden="true">
    <!-- 모달 class명으로 사이즈 조절 modal-320, 410, 520, 650, 820 -->
    <div class="modal-dialog  modal-820">
       
      <div class="modal-content">
        <div class="modal-footer">
          <button type="button" class="btn btn-primary btn-sm" onclick="fnSaveProc();">저장</button>
          <button type="button" class="btn btn-outline-dark btn-sm" data-bs-dismiss="modal" onclick="modalClose();">목록</button>
        </div>
    		<form:form commandName="DTO" id="regForm" name="regForm" method="post"> 
              <input type="hidden" name="iud" id="iud" />
        <div class="modal-body">
          <div class="form-container"> 
            <div class="form-wrap w-50">
              <label for="" class="critical">환자이름</label>
              <input type="text" name="user_nm" id="user_nm" class="form-control" placeholder="사용자 명을 입력하세요.">
            </div>
            <div class="form-wrap w-50"></div>
            <div class="form-wrap w-50">
              <label for="" class="critical">아이디</label>
              <input type="text" name="user_id" id="user_id" class="form-control" placeholder="아이디를 입력하세요.">
            </div>
            <div class="form-wrap w-50"></div>
            <div class="form-wrap w-50">
              <label for="" class="critical">비밀번호</label>
              <input type="password" name="user_pw" id="user_pw" class="form-control" placeholder="비밀번호를 입력하세요.">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">비밀번호 확인</label>
              <input type="password" id="user_pw2" class="form-control" placeholder="비밀번호를 재입력하세요.">
            </div>
            <div class="form-wrap w-100">
              <label for="" class="critical">전화번호</label>
              <input type="text" id="phone" name="phone" class="form-control" value="" placeholder="전화번호를 입력하세요." onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" maxLength="11">
            </div>
            <!-- <div class="form-wrap w-50">
              <label for="">사용자 구분</label>
              <input type="text" id="user_gb" name="user_gb" class="form-control" value="P" readonly>
    		  <select class="form-select" name="user_gb" id="user_gb">
                <option value="">선택</option> 
       			<option value="P">환자</option>
                <option value="D">의사</option>
                <option value="A">관리자</option>
              </select> 
            </div>-->
            <div class="form-wrap w-70" id="birth">
              <label for="" class="critical">생년월일</label>
				<input type="text" class="form-control" name="year" id="year" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" maxLength="4">년
				<select class="form-select"	name="month" id="month">
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
              <select class="form-select"	name="day" id="day">
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
            <div class="form-wrap w-50" id="gender">
              <label for="" class="align-top">성별</label>
              <p>
                <input class="form-check-input" type="radio" name="gender" id="genderF" value="F">
                <span class="ml-1">여자</span>
              </p>
              <p>
                <input class="form-check-input" type="radio" name="gender" id="genderM" value="M">
                <span class="ml-1">남자</span>
              </p>
            </div>
            <div class="form-wrap w-100">
              <label for="" >이메일</label>
              <input type="text" id="email" name="email" class="form-control" value="" >
            </div>
          </div> 
        </div>
        </form:form>
      </div>
      
    </div>
  </div>
</body>
</html>
