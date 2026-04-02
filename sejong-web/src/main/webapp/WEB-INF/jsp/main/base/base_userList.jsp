<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>  
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>  
<%@ page import = "java.util.*" %>
<style>
.modal-dialog {
    margin: auto; /* 모달 중앙 정렬 */
}
</style> 
<html>
<head>  
<!-- 스크립트 -->
<!-- 달력(일자, 월별) 사용시 추가 필요함 -->  
<script src="/js/main.js"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
<script type="text/javaScript"> 
var adminModal = new bootstrap.Modal(document.getElementById('adminModal'));
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
	   	url : CommonUtil.getContextPath() + '/base/ctl_userList.do',
	    type : 'post',
	    data: { hosp_cd: "12345678" ,  user_nm: $("#searchText").val() },
	   	dataType : "json",
	   	success : function(data) {
	   		if(data.error_code != "0") return;
	   		if(data.resultCnt > 0 ){
	    		var dataTxt = "";
	    		for(var i=0 ; i < data.resultCnt; i++){
	    			var depnmText = "";
		    		if (data.resultLst[i].main_gu == "1"){
		    			depnmText = "총관리자";
		    	    } else if(data.resultLst[i].main_gu == "2") {
		    	    	depnmText = "부관리자";
		    	    } 
	    			dataTxt = '<tr class="" onclick="javascript:fnDtlSearch(\'' 
						        +data.resultLst[i].hosp_uuid +'\',\''+data.resultLst[i].user_id+'\',\''+data.resultLst[i].start_dt+'\');" id="row_'
				                +data.resultLst[i].hosp_uuid + data.resultLst[i].user_id + data.resultLst[i].start_dt+'">';
	        
					dataTxt += 	"<td>" + (i+1)  + "</td>" ; 
					dataTxt +=  "<td>" + data.resultLst[i].hosp_cd  + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].user_id  + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].user_nm  + "</td>" ;
					dataTxt +=  "<td>" + depnmText   + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].start_dt  + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].end_dt  + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].use_yn + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].upd_user  + "</td>" ;
					dataTxt +=  "<td>" + data.resultLst[i].upd_dttm  + "</td>" ;
					dataTxt +=  "</tr>";
		            $("#dataArea").append(dataTxt);
	        	 }
		 	  }else{
					 $("#dataArea").append("<tr><td colspan='12'>검색된 정보가 없습니다.</td></tr>");
			  }
	      }
	   });
}
function fnDtlSearch(hosp_uuid ,user_id , start_dt){ 
	if (!hosp_uuid || !user_id || !start_dt) return;
	document.regForm.iud.value  = "U";
	document.regForm.hosp_uuid.value  = hosp_uuid ; 
	document.regForm.user_id.value  = user_id ; 
	document.regForm.start_dt.value = start_dt ;
	
    $("#infoTable tr").removeClass("tr-primary");
    $("#infoTable #row_" + hosp_uuid + user_id + start_dt).addClass("tr-primary");
}
//입력,수정 , 비밀번호 초기화  버큰 클릭시
function fnSave(iud){
	$("#iud").val(iud);  // 입력(I), 수정(U), 삭제(D) 
	uidGubun = iud ;
	if(iud == "I"){
		//등록폼 초기화
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/base/ctl_getHospmst.do",
			data : {hosp_uuid: "${sessionScope['q_uuid']}"},
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				$("#hosp_cd").val(data.result.hosp_cd);
			}	
		} );
		
		$("#hosp_cd").prop("readonly","true");
		$("#user_id").prop("readonly","");
		document.getElementById("regForm").reset();
		$("#main_gu").val("2");
		$("#start_dt").prop("readonly","true");
		$("#end_dt").prop("readonly","true");
		modalOpen();
		
	}else if(iud == "U"){
		if ($("#hosp_uuid").val() == "" || $("#user_id").val() == "" ){
			alert("선택된  정보가 없습니다.!");
			modalClose() ;
			return;
		}
    		
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/base/userInfo.do",
			data : {hosp_uuid: $("#hosp_uuid").val() , 
				    user_id : $("#user_id").val(), 
				    start_dt : $("#start_dt").val() },
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				$("#hosp_cd").val(data.result.hosp_cd);
				$("#user_id").val(data.result.user_id);
				$("#user_nm").val(data.result.user_nm);
				$("#pass_wd").val(data.result.pass_wd);
				$("#af_pass_wd").val(data.result.pass_wd);
				$("#main_gu").val(data.result.main_gu);
				$("#bigo").val(data.result.bigo);
				$("#upt_user").val(data.result.upt_user);
				$("#upt_dttm").val(data.result.upt_dttm);
				$("#start_dt").val(data.result.start_dt);
				$("#email").val(data.result.email);
				$("#user_tel").val(data.result.user_tel);
				$("#end_dt").val(data.result.end_dt);
				$("#use_yn").val(data.result.use_yn);
				$("#winner_yn").val(data.result.winner_yn);
				$("#hosp_cd").prop("readonly","true");
				$("#user_id").prop("readonly","true");
				$("#start_dt").prop("readonly","true");
			}
		});
		modalOpen();
	}else
		return;
	}
function fnSaveProc(){
	if(!fnRequired('user_id', '아이디를  확인하세요.'))  return;
	if(!fnRequired('user_nm', '성명을 확인 하세요.'))   return;
	if(!fnRequired('main_gu', '관리구분을 선택하세요.'))   return;
	if(!fnRequired('start_dt', '시작일자를 선택하세요.'))   return;
	if(!fnRequired('end_dt',   '종료일자를 선택하세요.'))   return;
	let hasPermission = true ;
	$.ajax( {
		type : "post",
		url : CommonUtil.getContextPath() + '/base/ctl_gethospconInfo.do',
		data : {hosp_uuid : $("#hosp_uuid").val() , start_dt : $("#start_dt").val() , end_dt : $("#end_dt").val() },
        dataType: "json",
        async: false, // 동기화 호출로 변경 (필요 시 사용)
        success: function(data) {
            if (data.error_code != "0") {
                hasPermission = false; // 실행 중지 설정
                return;
            }
            if (data.conyn !== "Y") {
                alert("사용자 작성권한이 없습니다!");
                $("#user_id").val("");
                document.getElementById("user_id").focus();
                hasPermission = false; // 실행 중지 설정
                return;
            }
        },
        error: function(xhr, status, error) {
            console.error("Error:", error);
            hasPermission = false; // 실행 중지 설정
        }
    });

	if (!hasPermission) {
		alert("권한이 없으므로 이후 로직을 중지합니다.");
	    return;
	}

	if (iud == "I") {
		if(($("#dupchk").val() == "Y" || $("#dupchk").val() == "X")) {
			alert("코드 중복체크 여부를 확인하세요.!");
			return;
		}	
    }	
	if($("#pass_wd").val() == ""){
		alert("비밀번호를 입력하세요.!");
		document.getElementById("pass_wd").focus();
		return;
	}
	if($("#af_pass_wd").val() == ""){
		alert("비밀번호를 입력하세요.!");
		document.getElementById("af_pass_wd").focus();
		return;
	}
	var formData = $("form[name='regForm']").serialize();
	var msg = "" ;
	if (uidGubun == "U"){
		msg = "수정 하시겠습니다?" ;
	}else if (uidGubun == "D"){
		msg = "삭제 하시겠습니다?" ;
	}else{
		if ( $("#pass_wd").val() != $("#af_pass_wd").val() ){
			alert("비빌번호가 상호 상이합니다  .!");
			document.getElementById("af_pass_wd").focus();
			return;			
		}
		msg = "입력 하시겠습니다?" ;
	}
	if(confirm(""+ msg)) {
		$.ajax( {
			type : "post" ,                       
			url : CommonUtil.getContextPath() + "/base/UserSaveAct.do",
			data : formData,
			dataType : "json",
			success : function(data) {    
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
		        fnSearch();
		        modalClose() ;
      
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
function fnDupchk(){
	if(!fnRequired('user_id', '사용자 아이디를 입력하세요')) return;
	$.ajax( {
		type : "post",
		url : CommonUtil.getContextPath() + "/base/getUserInfo.do",
		data : {user_id : $("#user_id").val() },
		dataType : "json",
		success : function(data) {    
			if(data.error_code != "0") return;
			if(data.dupchk == "Y"){  
				alert("해당 사용자정보는 이미 존재하는 아이디입니다.");
				$("#user_id").val("");
				$("#user_id").focus();
				$("#dupchk").val("Y");
				return;
			}
			alert("사용가능한 사용자아이디 입니다.");
			$("#dupchk").val("N");
		}
	});
}	
//검색 모달 띄우기
function openSearchModal(event) {
    if (event) {
        event.preventDefault(); // 기본 동작 방지
    }
    const searchModal = document.getElementById('searchModal');
    searchModal.style.marginLeft = '10%'; // 모달을 왼쪽으로 이동
    $('#searchModal').modal('show'); // 검색 모달 띄우기
}

// 검색 수행
function searchUser(event) {
    event.preventDefault(); // 기본 동작 방지
    const userResultsTable = document.getElementById('searchResults');
    userResultsTable.innerHTML = ''; // 초기화

    $.ajax({
        url: CommonUtil.getContextPath() + "/base/ctl_getmbrList.do",
        type: "post",
        data: {
            hosp_cd: '11282347',
            mbr_nm: $("#search_user_nm").val() // 검색어
        },
        dataType: "json",
        success: function (data) {
            if (data.error_code === "0") {
                const resultLst = data.resultLst;

                if (resultLst.length > 0) {
                    resultLst.forEach(hospuser => {
                        const row = createSearchResultRow(hospuser);
                        userResultsTable.appendChild(row);
                    });
                } else {
                    userResultsTable.innerHTML = "<tr><td colspan='6'>검색된 정보가 없습니다.</td></tr>";
                }
            } else {
                userResultsTable.innerHTML = "<tr><td colspan='6'>검색된 정보가 없습니다.</td></tr>";
            }
        },
        error: function () {
            alert('AJAX 요청 중 문제가 발생했습니다.');
        }
    });
}

// 검색 결과 행 생성
function createSearchResultRow(hospuser) {
    const row = document.createElement('tr');
    const columns = [
        hospuser.hosp_cd,
        hospuser.mbr_nm,
        hospuser.email,
        hospuser.sub_nm,
        hospuser.start_dt,
        hospuser.end_dt,
        hospuser.sub_nm1,
        hospuser.start_dt1,
        hospuser.end_dt1
        ];

    columns.forEach(content => {
        const cell = document.createElement('td');
        cell.textContent = content || 'N/A';
        row.appendChild(cell);
    });

    // 행 클릭 시 데이터 전달
    row.addEventListener('click', function () {
        selectUser(hospuser);
    });

    return row;
}

// 선택된 데이터를 메인 모달로 전달
function selectUser(hospuser) {
    document.getElementById('hosp_cd').value = hospuser.hosp_cd;
    document.getElementById('user_nm').value = hospuser.mbr_nm;
    document.getElementById('email').value = hospuser.email;
    document.getElementById('user_tel').value = hospuser.mbr_tel || '';
    document.getElementById('pass_wd').value = hospuser.pass_wd || '';
    document.getElementById('af_pass_wd').value = hospuser.pass_wd || '';
    if (hospuser.start_dt) { 
       document.getElementById('start_dt').value = hospuser.start_dt || '';
       document.getElementById('end_dt').value = hospuser.end_dt || '';
    }else{
        document.getElementById('start_dt').value = hospuser.start_dt1 || '';
        document.getElementById('end_dt').value = hospuser.end_dt1 || '';    	
    }
    document.getElementById('hosp_uuid').value = hospuser.hosp_uuid || '';

    $('#searchModal').modal('hide'); // 검색 모달 닫기
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
					<div class="info-name">사용자 목록</div>
				</div>
			</div>
        <section class="top-pannel">  
          <div class="search-box">
            <label for="search" class="form-title" onclick="">검색어 입력</label>
            <input type="text" name="searchText" id="searchText" class="form-control search" placeholder="아이디 및 사요자명를 입력하세요." 
                                                                               onkeypress="if( event.keyCode == 13 ){fnSearch();}">
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
                  	<col style="width: 50px">
                    <col style="width: 100px">
                    <col style="width: 200px">
                    <col style="width: 200px">
                    <col style="width: 200px">
                    <col style="width: 200px">
                    <col style="width: 100px">
                    <col style="width: 100px">
                    <col style="width: 100px">
                  </colgroup>
                  <thead>
                    <tr>
                      <th>번호</th>
                      <th>요양기관</th>
                      <th>사용자</th>
                      <th>사용자성명</th>
                      <th>사용자구분</th>
                      <th>시작일자</th>
                      <th>종료일자</th>
                      <th>권한여부</th>
                      <th>등록자</th>
                      <th>등록일자</th>
                    </tr>
                  </thead>
                  <tbody id="dataArea"> 
        			<tr>
        				<td colspan="10">&nbsp;</td>
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
        <div class="modal-footer">
          <button type="button" class="btn btn-primary btn-sm"  onclick="fnSaveProc();">저장</button>
          <button type="button" class="btn btn-outline-dark btn-sm" data-bs-dismiss="modal" onclick="modalClose();">목록</button>
        </div>
    		<form:form commandName="DTO" id="regForm" name="regForm" method="post"> 
              <input type="hidden" name="iud" id="iud" />
              <input type="hidden" name="dupchk" id="dupchk" value="X" />
              <input type="hidden" name="hosp_uuid" id="hosp_uuid" />
        <div class="modal-body">
          <div class="form-container"> 
            <div class="form-wrap w-50">
              <label for="" class="critical">요양기관</label>
              <input type="text" name="hosp_cd" id="hosp_cd" class="form-control" placeholder="요양기관를 입력하세요.">
            </div>
            <div class="form-wrap w-50">
                <label for="" class="critical">사용자명</label>
                <input type="text" name="user_nm" id="user_nm" class="form-control" placeholder="사용자명을 입력하세요.">
                <button type="button" class="btn btn-outline-dark" onclick="openSearchModal()">검색</button>
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">아이디</label>
              <input type="text" name="user_id" id="user_id" class="form-control" placeholder="아이디를 입력하세요.">
              <button type="button" class="btn btn-outline-dark" id="mstdupid" onclick="fnDupchk();">중복체크</button>
            </div>
           <div class="form-wrap w-50">
	           <label for="">관리자구분</label> 
	            <select class="form-select" name="main_gu" id="main_gu"> <!-- readonly -->
	                <option value="">선택</option> 
	                <c:forEach var="result" items="${codegbList}" varStatus="status">
	                   <option value="${result.sub_code}">${result.sub_code_nm}</option>
	                </c:forEach> 
	           </select>
           </div> 
            <div class="form-wrap w-50">
              <label for="" class="critical">이메일</label>
              <input type="text" name="email" id="email" class="form-control" placeholder="이메일를 입력하세요.">
            </div>    
            <div class="form-wrap w-50">
              <label for="" class="critical">전화번호</label>
              <input type="text" name="user_tel" id="user_tel" class="form-control" placeholder="전화번호를  입력하세요.">
            </div>               
            <div class="form-wrap w-50">
              <label for="" class="critical">시작일</label>
              <input type="text" name="start_dt" id="start_dt" class="form-control" placeholder="시작일를  입력하세요.">
            </div>    
            <div class="form-wrap w-50">
              <label for="" class="critical">종료일</label>
              <input type="text" name="end_dt" id="end_dt" class="form-control" placeholder="종료일를  입력하세요.">
            </div>    
            <div class="form-wrap w-100">
              <label for="" class="critical">비고</label>
              <input type="text" name="bigo" id="bigo" class="form-control" placeholder="바고사항 을 입력하세요.">
            </div>
            <div class="form-wrap w-50">
	              <label for=""class="critical">권한여부</label>
	       		  <select class="form-select" name="use_yn" id="use_yn">
	                <option value="">선택</option> 
	                <option value="Y">Y</option>
	                <option value="N">N</option>
	              </select> 
		    </div>                                    
            <div class="form-wrap w-50">
	              <label for=""class="critical">위너넷구분</label>
	       		  <select class="form-select" name="winner_yn" id="winner_yn">
	                <option value="">선택</option> 
	                <option value="Y">Y</option>
	                <option value="N">N</option>
	              </select> 
		    </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">비밀번호</label>
              <input type="password" name="pass_wd" id="pass_wd" class="form-control" placeholder="비밀번호를 입력하세요.">
            </div>
            <div class="form-wrap w-50">
              <label for="" class="critical">비밀번호 확인</label>
              <input type="password" name="af_pass_wd" id="af_pass_wd" class="form-control" placeholder="비밀번호를 재입력하세요.">
            </div>
          </div> 
        </div>
        </form:form>
      </div>
      
    </div>
  </div>
<div class="modal fade" id="searchModal" tabindex="-1" aria-labelledby="searchModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-820 mx-auto" style="max-width: 80%; transform: translate(-23%, 12%);"> <!-- 아래로 이동 -->
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="searchModalLabel">사용자 검색</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="form-container">
                    <div class="d-flex justify-content-between align-items-end mb-3"> <!-- 검색 필드 정렬 -->
                        <div class="form-group me-2 w-75">
                            <label for="search_user_nm" class="form-label">사용자명</label>
                            <input type="text" id="search_user_nm" class="form-control" placeholder="사용자명을 입력하세요">
                        </div>
                        <button type="button" class="btn btn-primary" onclick="searchUser(event)">검색</button>
                    </div>
                    <div class="table-responsive"> <!-- 테이블 가로 스크롤 대응 -->
                        <table class="table table-striped table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th>병원코드</th>
                                    <th>성명</th>
                                    <th>이메일</th>
                                    <th>계약내용</th>
                                    <th>시작일</th>
                                    <th>종료일</th>
                                    <th>계약내용</th>
                                    <th>시작일</th>
                                    <th>종료일</th>
                                </tr>
                            </thead>
                            <tbody id="searchResults">
                                <tr>
                                    <td colspan="9" class="text-center text-muted">검색된 결과가 없습니다.</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

</body>
</html>
