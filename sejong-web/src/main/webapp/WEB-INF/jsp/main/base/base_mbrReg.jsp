<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>  
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>  
<%@ page import = "java.util.*" %>
<style>
    /* 모달 창의 스타일 */
</style> 
<html>
<head>  
<!-- 달력(일자, 월별) 사용시 추가 필요함 -->  
<script src="/js/main.js"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
<script type="text/javaScript"> 
var confirm_red = [];   

window.onload = function() {
    document.getElementById("regForm").reset();
};

function emailcheck() {
    // 이메일 도메인 선택 시
    const emailField = document.getElementById('email');
    const emailList  = document.getElementById('emailList');

    // 이메일 도메인 리스트 변경 이벤트 처리
    emailList.addEventListener('change', function() {
        const email = emailField.value.split('@')[0]; // '@' 앞부분만 추출
        const selectedDomain = this.value;

        // 이메일 입력이 있고, 도메인 리스트에서 선택된 도메인이 있다면, 이메일 필드를 업데이트
        if (selectedDomain && email) {
            emailField.value = email + "@" + selectedDomain;
        } else if (selectedDomain && !email) {
            // 이메일 입력이 없으면 기본 'user@domain' 형태로 입력
            emailField.value = "user@" + selectedDomain;
        }
        emailField.dispatchEvent(new Event('input'));
    });

    // 사용자가 이메일을 입력할 때, '@' 이후의 도메인을 자동으로 선택하는 기능
    emailField.addEventListener('input', function() {
        const email = emailField.value;
        const domainList = emailList;

        // '@'가 포함되면 이메일 도메인 선택을 초기화
        if (email.includes('@')) {
            const domain = email.split('@')[1];  // 이메일 '@' 이후의 부분을 추출
            // 이메일의 도메인이 변경되면 이메일 리스트의 도메인도 변경
            if (domain !== domainList.value) {
                domainList.value = domain || ''; // 도메인 리스트에서 해당 도메인을 선택
            }
        }
    });

    // 페이지 로드 후 즉시 emailcheck을 적용하여 첫 선택 시부터 동작하도록 처리
    const emailValue = emailField.value;
    const selectedDomain = emailList.value;

    if (emailValue && selectedDomain) {
        // 이메일 입력이 있을 때, 도메인 리스트가 선택되어 있으면 이메일 필드를 업데이트
        emailField.value = emailValue.split('@')[0] + '@' + selectedDomain;
    } else if (!emailValue && selectedDomain) {
        // 이메일이 비어있고 도메인이 선택되었으면 기본 'user@domain' 형태로 이메일 업데이트
        emailField.value = "user@" + selectedDomain;
    }
}

// 페이지 로드 후 emailcheck() 함수 호출
document.addEventListener('DOMContentLoaded', function() {
    emailcheck();
});
// 동의 세부 확인 모달 열기
function openModal(headerValue , code_cd) {
	const modal = document.getElementById('termsModal');
    const modalName = document.getElementById('modalname');
    modalName.textContent = "(필수)" + headerValue; 
    $.ajax( {
		url : CommonUtil.getContextPath() + "/base/ctl_selCommDtlInfo.do",
		type : "post",
		data : {code_cd : code_cd},
		dataType : "json",
		success : function(data) {    
			if(data.error_code != "0") {
				alert(data.error_msg);
				return;
			}
			var dataTxt = "";

			for (var i = 0; i < data.resultCnt; i++) {
				dataTxt += data.resultList[i].sub_code_nm
			}	
			$("#sub_code_nm").val(dataTxt);
		}
	});
    
    switch(code_cd){
	    case "per_use_cd":
	    	confirm_red[0] = 'Y'; // 배열에 '1' 추가
	    	break;
	    case "per_info_cd" :
	    	confirm_red[1] = 'Y'; // 배열에 '1' 추가
	    	break ;   	
	    case "per_pro_cd" :
	    	confirm_red[2] = 'Y'; // 배열에 '1' 추가
	    	break ;  
	    default:
	    	break ;  
    } 
	modal.style.display = "flex";
    modal.style.justifyContent = "center";
    modal.style.alignItems = "center";
}

// 모달 닫기
function closeModal() {
    document.getElementById('termsModal').style.display = "none";
}
function mainModalClose() {
    document.getElementById('mainModal').style.display = "none";
}
// 전체 동의/취소 기능
function toggleAllAgreement() {
    const isChecked = document.getElementById('allAgree').checked;
    document.querySelectorAll('.checkbox-group input[type="checkbox"]').forEach(function(checkbox) {
        checkbox.checked = isChecked;
    });
    checkAction() ;
}
function confirmAction() {
	$("#per_use_red").val(confirm_red[0]);
	$("#per_info_red").val(confirm_red[1]);
	$("#per_pro_red").val(confirm_red[2]);
	closeModal() ;
}
function checkAction() {
	$("#per_use_yn").val($("#peruseyn").prop("checked") ? "Y" : "N");
    $("#per_info_yn").val($("#perinfoyn").prop("checked") ? "Y" : "N");
    $("#per_pro_yn").val($("#perproyn").prop("checked") ? "Y" : "N");
}
function fnSaveProc(iud) {
	const fields = ['per_use_yn', 'per_info_yn', 'per_pro_yn'];
	for (let field of fields){
		if (document.getElementById(field).value !== "Y"){
			alert("전체 약관동의를 하여야 합니다 ");
			return;
		}
	} 
	$("#iud").val(iud);  // 입력(I), 수정(U), 삭제(D) 
	if(!fnRequired('hosp_cd', '요양기관기호를 확인하세요.'))  return;
	if(!fnRequired('hosp_nm', '요양기관명을 확인하세요.'))   return;
	if(!fnRequired('mbr_nm', '담당자명을 확인하세요.'))   return;
	if(!fnRequired('mbr_tel', '담당전화를 확인하세요.'))   return;
	if(!fnRequired('email', '이메일를 확인하세요.'))   return;
	if(($("#dupchk").val() == "Y" || $("#dupchk").val() == "X")) {
		alert("코드 중복체크 여부를 확인하세요.!");
		return;
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
	if ( $("#pass_wd").val() != $("#af_pass_wd").val() ){
		alert("비빌번호가 상호 상이합니다  .!");
		document.getElementById("af_pass_wd").focus();
		return;			
	}
	$("#per_use_cd").val("PER_USE_CD") ;
	$("#per_info_cd").val("PER_INFO_CD") ;
	$("#per_pro_cd").val("PER_PRO_CD") ;
	var formData = $("form[name='regForm']").serialize() ;
	if (!confirm("입력 하시겠습니다?")) {
        return;  
    }
	$.ajax( {
		type : "post" ,                      
		url  : CommonUtil.getContextPath() + "/base/MemberSaveAct.do",
		data : formData,
		dataType : "json",
		success : function(data) {    
			if(data.error_code != "0") {
			   alert(data.error_msg);
			   return;
			}else{
		 	   modalClose();
            }
		}	
	});
	mainModalClose() ;
}
function fnDupchk(){
	if(!fnRequired('hosp_cd', '병원정보를 입력하세요')) return;
	if(!fnRequired('email', '이메일정보를 입력하세요')) return;
	$.ajax( {
		type : "post",
		url : CommonUtil.getContextPath() + "/base/MberDupChk.do",
		data : {hosp_cd : $("#hosp_cd").val(),email : $("#email").val()},
		dataType : "json",
		success : function(data) {    
			if(data.error_code != "0") return;
			if(data.dupchk == "Y"){  
				alert("해당 코드정보는 이미 존재하는 코드입니다.");
				$("#hosp_cd").val("");
				$("#hosp_cd").focus();
				$("#dupchk").val("Y");
				return;
			}
			alert("사용 가능한 코드 정보입니다.");
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
function searchHosp(event) {
	if(!fnRequired('sub_hosp_nm', '병원명을 입력하세요')) return;
    event.preventDefault(); // 기본 동작 방지
    const hospResultsTable = document.getElementById('searchResults');
    hospResultsTable.innerHTML = ''; // 초기화
    $.ajax({
        url: CommonUtil.getContextPath() +  "/base/ctl_hospList.do",
        type: "post",
        data: {hosp_cd: $("#sub_hosp_nm").val() },
		dataType : "json",
		success: function(data) {
		    if (data.error_code === "0") {
		        // 결과 처리             
		        const resultLst = data.resultLst;

                if (resultLst.length > 0) {
                    resultLst.forEach(hospnm => {
                        const row = createSearchResultRow(hospnm);
                        hospResultsTable.appendChild(row);
                    });
                } else {
                	hospResultsTable.innerHTML = "<tr><td colspan='3'>검색된 정보가 없습니다.</td></tr>";
                }
            } else {
            	hospResultsTable.innerHTML = "<tr><td colspan='3'>검색된 정보가 없습니다.</td></tr>";
            }
        },
        error: function () {
            alert('AJAX 요청 중 문제가 발생했습니다.');
        }
    });
}
//검색 결과 행 생성
function createSearchResultRow(hospnm) {
    const row = document.createElement('tr');
    const columns = [
    	hospnm.hosp_cd,
    	hospnm.hosp_nm,
    	hospnm.hosp_addr
        ];
    columns.forEach(content => {
        const cell = document.createElement('td');
        cell.textContent = content || 'N/A';
        row.appendChild(cell);
    });
    // 행 클릭 시 데이터 전달
    row.addEventListener('click', function () {
    	selectHospnm(hospnm);
    });
    return row;
}
// 선택된 데이터를 메인 모달로 전달
function selectHospnm(hospnm) {
    document.getElementById('hosp_cd').value   = hospnm.hosp_cd;
    document.getElementById('hosp_nm').value   = hospnm.hosp_nm;
    document.getElementById('hosp_uuid').value = hospnm.hosp_uuid; // 병원 UUID 저장

    $('#searchModal').modal('hide'); // 검색 모달 닫기
}
</script>
</head>
<body>
	<div id="mainModal" class="modal-dialog  modal-820" style="margin-top: -100px;">
		<div class="modal-content">
			<div class="modal-footer">
				<button type="button" class="btn btn-primary btn-sm"
					onclick="fnSaveProc('I');">회원가입</button>
				<button type="button" class="btn btn-outline-dark btn-sm"
					data-bs-dismiss="modal" onclick="mainModalClose();">취소</button>
			</div>
			<div class="modal-body">
				<div class="form-container">
    		      <form commandName="DTO" id="regForm" name="regForm" method="post">
				    	<input type="hidden" name="iud" id="iud" />
					    <input type="hidden" name="dupchk" id="dupchk" value="X" />
	                    <input type="hidden" name="per_use_red" id="per_use_red" />	  
	                    <input type="hidden" name="per_info_red" id="per_info_red" />	
	                    <input type="hidden" name="per_pro_red" id="per_pro_red" />	  
	                     
	                    <input type="hidden" name="per_use_yn" id="per_use_yn" />	  
	                    <input type="hidden" name="per_info_yn" id="per_info_yn" />	
	                    <input type="hidden" name="per_pro_yn" id="per_pro_yn" />

	                    <input type="hidden" name="per_use_cd" id="per_use_cd" />	  
	                    <input type="hidden" name="per_info_cd" id="per_info_cd" />	
	                    <input type="hidden" name="per_pro_cd" id="per_pro_cd" />
	                    <input type="hidden" name="hosp_uuid" id="hosp_uuid" />
	                    
						<div class="form-wrap w-100" style="margin-bottom: 20px;"> 
							<label for="" style="font-size: 20px;">회원등록</label> 
						</div>
						<div class="form-wrap w-100">
							<label for="" class="critical">병원코드</label> <input type="text"
								name="hosp_cd" id="hosp_cd" class="form-control" placeholder="">
			              <button type="button" class="btn btn-outline-dark" id="mstdupid" onclick="fnDupchk();">중복체크</button>
						</div>

						<div class="form-wrap w-100" style="margin-bottom: 30px;"> 
							<label for="" class="critical">병원명</label> 
  							<input type="text"name="hosp_nm" id="hosp_nm" class="form-control" placeholder="">
                            <button type="button" class="btn btn-outline-dark" onclick="openSearchModal()">검색</button>	
						</div>
						<!-- 이메일 입력 필드 및 이메일 리스트 콤보박스 -->
						<div class="form-wrap w-100">
						    <label for="" class="critical">이메일</label> 
						    <input type="email" id="email" name="email" class="form-control" placeholder="" /> 
						    <select id="emailList" name="emailList" class="form-select" onchange="emailcheck()">
						        <option value="">이메일 선택</option>
						        <c:forEach var="result" items="${commList}" varStatus="status">
						            <option value="${result.sub_code}">${result.sub_code_nm}</option>
						        </c:forEach>
						    </select>
						</div>
						<!-- 패스워드 -->
						<div class="form-wrap w-70">
							<label for="" class="critical">비밀번호</label> <input
								type="password" id="pass_wd" name="pass_wd" class="form-control"
								placeholder="">
						</div>
						<div class="form-wrap w-70" style="margin-bottom: 30px;"> 
							<label for="" class="critical"> 비밀번호확인</label> <input
								type="password" id="af_pass_wd" name="af_pass_wd"
								class="form-control" placeholder="">
						</div>

						<!-- 담당자 정보 -->
						<div class="form-wrap w-70">
							<label for="" class="critical">담당자명</label> <input
								type="text" id="mbr_nm" name="mbr_nm" class="form-control"
								placeholder="">
						</div>

						<div class="form-wrap w-70" style="margin-bottom: 30px;"> 
							<label for="" class="critical"> 전화번호</label> <input
								type="text" id="mbr_tel" name="mbr_tel" class="form-control"
								placeholder="">
						</div>
					    <div class="form-wrap w-70">
							<div class="form-wrap w-70" >
						        <label style="margin-right:10px;">  </label>
							</div>    
						    <!-- 나머지 체크박스 그룹 -->
						    <div class="checkbox-group">
								<div class="form-wrap w-70" style="margin-bottom: 20px;"> 
								    <!-- '모두동의 합니다'를 상단으로 이동 -->
								    <div class="whole-agreement">
								        <label><input type="checkbox" id="allAgree" onclick="toggleAllAgreement()"> 모두동의 합니다</label>
								    </div>
								</div> 
						        <div class="form-wrap w-70">
						            <label style="margin-right: 70px;"> 
						                <input type="checkbox" id="peruseyn"   onchange="checkAction()"> 이용약관 동의
						            </label>
						            <button type="button" class="btn btn-outline-dark btn-sm" 
						                                 onclick="openModal('이용약관 동의','per_use_cd')">세부확인</button>
						            <br>
						        </div>
						        <div class="form-wrap w-70">
						            <label style="margin-right: 70px;"> 
						                <input type="checkbox" id="perinfoyn"  onchange="checkAction()"> 개인정보 수집 및 이용 동의
						            </label>
						            <button type="button" class="btn btn-outline-dark btn-sm" 
						                                  onclick="openModal('개인정보 수집 및 이용 동의','per_info_cd')">세부확인</button>
						            <br>
						        </div>
						        <div class="form-wrap w-70">
						            <label style="margin-right: 70px;"> 
						                <input type="checkbox" id="perproyn"  onchange="checkAction()"> 개인정보 처리위탁 동의
						            </label>
						            <button type="button" class="btn btn-outline-dark btn-sm" 
						                                  onclick="openModal('개인정보 처리위탁 동의','per_pro_cd')">세부확인</button>
						            <br>
						        </div>
						        
						    </div>
						</div>
			    	  </form>
				    </div>
			  </div>
		 </div>
	</div>
   
	<!-- Modal 동의서 확인 -->
	<div id="termsModal" class="modal" style="display: none; justify-content: center; align-items: center;">
		<div class="modal-dialog" style="height: 80%; width: 70%; max-width: 820px; position: relative;">
		    <div class="modal-content" style="height: 100%; display: flex; flex-direction: column; position: relative;">
	            <div style="margin-bottom: 20px;"> </div>
		        <div style="text-align: left; font-size: 20px; padding-left: 200px;">
		             <span type=""> <span id="modalname"></span></span>
		        </div>
		        <div  style="flex-grow: 1; overflow-y: auto; display: flex; justify-content: center; align-items: center;">
		            <label for=""  style="right"></label>
	                    <input type="hidden" name="code_cd" id="code_cd" />	            
		                <textarea class="form-control" aria-label="With textarea" 
		                          name="sub_code_nm" id="sub_code_nm" style="width: 100%; height: 90%; font-size: 16px;"></textarea>
	            </div>
	            <div style="text-align: center; padding: 10px;">
                  <button class="btn btn-primary btn-sm" onclick="confirmAction()" style="width: 100%; 
                            padding: 10px 20px; font-size: 16px; cursor: pointer; box-sizing: border-box;">확인</button>
                </div>
             
	        </div>
	    </div>
	</div>
	
	<!--  병원검색모달   -->
	<div class="modal fade" id="searchModal" tabindex="-1" aria-labelledby="searchModalLabel" aria-hidden="true">
	    <div class="modal-dialog modal-820 mx-auto" style="max-width: 80%; transform: translate(-23%, 5%);"> <!-- 아래로 이동 -->
	        <div class="modal-content">
	            <div class="modal-header bg-primary text-white">
	                <h5 class="modal-title" id="searchModalLabel">병원 검색</h5>
	                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
	            </div>
	            <div class="modal-body">
	                <div class="form-container">
	                    <div class="d-flex justify-content-between align-items-end mb-3"> <!-- 검색 필드 정렬 -->
	                        <div class="form-group me-2 w-75">
	                            <label for="sub_hosp_nm" class="form-label">병원명</label>
	                            <input type="text" id="sub_hosp_nm" class="form-control" placeholder="병원명을 입력하세요">
	                        </div>
	                        <button type="button" class="btn btn-primary" onclick="searchHosp(event)">검색</button>
	                    </div>
	                    <div class="table-responsive"> <!-- 테이블 가로 스크롤 대응 -->
	                        <table class="table table-striped table-hover">
	                            <thead class="table-light">
	                                <tr>
	                                    <th>병원코드</th>
	                                    <th>병원명</th>
	                                    <th>주소</th>
	                                </tr>
	                            </thead>
	                            <tbody id="searchResults">
	                                <tr>
	                                 <td colspan="3" class="text-center text-muted">검색된 결과가 없습니다.</td>
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

