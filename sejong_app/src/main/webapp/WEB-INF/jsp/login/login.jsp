<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page isELIgnored="false" %>


<script src="https://developers.kakao.com/sdk/js/kakao.js"></script>
<!-- wrap : s -->
 <div class="wrap splash login">
   <!-- contents : s -->
   <div class="contents">
     <div class="visual loginWrap">
       <div class="header_wrap">
         <div class="logo">allCare</div>
         <p class="mt20">AI기반 디지털 헬스케어 서비스</p>
         <span>연속혈당 allCare Service</span>
       </div>
       <div class="login">
         <p class="title">휴대폰번호 인증</p>
         <div class="form">
            <div class="left_right_wrap mt20">
              <div class="inputWrap mr10">
                <input type="text" class="inpText mt0" id="authPhone" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');" maxlength="11" placeholder="휴대폰번호 입력" />
              </div>
              <div class="btnArea mt0 w50">
                <a href="#" class="btn btnLine01 round pl20 pr20"  onclick="reqAuth();"><span>인증번호 요청</span></a>
              </div>
            </div>
            <p class="comment mt15 pl15">* 본인 인증을 위하여 귀하의 휴대폰번호를 입력해 <br> 주세요.(번호만)</p>
            
            <div class="left_right_wrap mt30">
              <div class="inputWrap mr10">
                <input type="password" class="inpText mt0" placeholder="인증번호 입력" id="authCode"  />
              </div>
              <div class="btnArea mt0 w80">
                <a href="#" class="btn btnCol01 round pl20 pr20" onclick="checkAuth();"><span>확 인</span></a>
              </div>
            </div>
            
            <p class="comment mt15 pl15">* 수신 문자를 확인 후 6자리 인증번호(숫자)를 입력 <br> 하세요</p>
            <div class="checkboxWrap pt15" >
	             <span class="inputCheckbox">
	               <input type="checkbox" id="chk_login" />
	               <label for="chk_login">자동로그인</label>
	             </span>
	             
	             <span class="inputCheckbox">
	               <input type="checkbox" id="chk_saveID" />
	               <label for="chk_saveID">휴대폰번호 저장</label>
	             </span>
            </div>
			<div class="btnArea mt1 w100">
			  <a href="#"
			     class="btn btnCol01 round pl20 pr20"  onclick="loginWithKakao();"
			     style="background-color: #FEE500; color: #000; 
			            font-weight: bold; text-align: center; text-decoration: none; line-height: 1;">
			    <span>카카오로 간편하게 시작하기</span>
			  </a>
			</div>
			<!-- 추가 영역 -->
			<div class="comment_text mt20 pl15" style="display: flex; justify-content: space-between;">
			  <a href="#" onclick="goJoin10();" >개인정보처리방침</a>
			  <div class ="pr15">
			    <a href="#" onclick="goJoin4();">회원탈퇴</a>
			  </div>  
			</div>
         </div>

         <div class="notice_wrap">
           ※ 사용하시는 앱은 세종시 AI기반 디지털 헬스케어서비스 실증을 위한 체험형 혈당관리용 앱입니다. 
         </div>
       </div>
     </div>
   </div>
 </div>

 <!-- wrap : e -->
<!-- [레] : 회원인증 팝업 : s -->
<div class="popupWrap popupFull joinPopup1">
	<div class="popupContent popupInner">
		<div class="popupHead">
			<strong class="tit">회원인증</strong>
			<a href="javascript:layerPop('close' , 'joinPopup1')" class="btnPopClose">레이어 닫기</a>
		</div>
		<div class="popupCont">
			<!-- 내용 : s -->
			<ul class="stepList">
				<li class="on">
					<span class="num">1</span>
					<p class="title">회원인증</p>
				</li>
				<li>
					<span class="num">2</span>
					<p class="title">약관동의</p>
				</li>
				<li>
					<span class="num">3</span>
					<p class="title">정보입력</p>
				</li>
			</ul>
			<div class="infoBox">
				<p>‘올케어(allCare)서비스는 당뇨전 단계 회원 전용 서비스입니다. ‘회원께서는 휴대폰용 앱(app)을 통해 회원인증 후 관련정보를 입력 후 사용이 가능합니다. </p>
			</div>
			<div class="form">
				<dl class="formList">
					<dt><span class="vital">휴대폰번호</span></dt>
					<dd>
						<div class="inputWrap"><input type="text" class="inpText" id="phone" placeholder="휴대폰번호 입력" readonly></div>
					</dd>
				</dl>
				<dl class="formList">
					<dt><span class="vital">이메일정보 (카카오일 경우필요 )</span></dt>
					<dd>
						<div class="inputWrap"><input type="text" class="inpText" id="email" placeholder="이메일 입력" readonly></div>
					</dd>
				</dl>
				
				<dl class="formList">
					<dt><span class="vital">이름</span></dt>
					<dd>
						<div class="inputWrap"><input type="text" class="inpText" id="userNm" placeholder="이름을 입력하세요."></div>
					</dd>
				</dl>
				<dl class="formList">
					<dt><span class="vital">생년월일</span></dt>
					<dd>
						<div class="inputWrap"><input type="text" class="inpText" id="birth" placeholder="생년월일 8자리 예)19631126" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');" maxlength="8"></div>
					</dd>
				</dl>
			</div>

			<div class="buttonFixed">
				<div class="btnArea fix">
					<a href="#" class="btn btnCol01" onclick="cancelBtn();"><span>취소</span></a>
					<a href="#" class="btn btnCol02 next" onclick="goJoin2();"><span>다음</span></a>
				</div>
			</div>

			<!-- 내용 : e -->
		</div>
	</div>
</div>
<!-- [레] : 회원인증 팝업 : e -->

<!-- [레] : 약관 팝업 : s -->
<div class="popupWrap popupFull joinPopup10">
	<div class="popupContent popupInner">
		<div class="popupHead">
			<strong class="tit">개인정보처리방침</strong>
			<a href="javascript:layerPop('close' , 'joinPopup10')" class="btnPopClose">레이어 닫기</a>
		</div>
		<div class="popupCont">
			<!-- 내용 : s -->
			<ul class="stepList bulcolor">
				<li class="on">
					<span class="num"></span>
					<p class="title">개인정보처리방침</p>
				</li>
			</ul>
			<div class="sign-table-container">
			  <div class="sign-table-wrapper">
			    <table class="sign-table">
			      <tbody id="signList">
			        <!-- 여기에 JS로 <tr><td>...</td></tr>가 삽입됨 -->
			      </tbody>
			    </table>
			  </div>
			</div>

		<!-- 내용 : e -->
		</div>
		<div class="buttonFixed">
			<div class="btnArea fix  ">
				<a href="#" class="btn btnCol07" onclick="cancelBtn();"><span>닫기</span></a>
			</div>
		</div>
	</div>
</div>
<div class="popupWrap popupFull joinPopup2">
	<div class="popupContent popupInner">
		<div class="popupHead">
			<strong class="tit">회원인증</strong>
			<a href="javascript:layerPop('close' , 'joinPopup2')" class="btnPopClose">레이어 닫기</a>
		</div>
		<div class="popupCont">
			<!-- 내용 : s -->
			<ul class="stepList">
				<li>
					<span class="num">1</span>
					<p class="title">회원인증</p>
				</li>
				<li class="on">
					<span class="num">2</span>
					<p class="title">약관동의</p>
				</li>
				<li>
					<span class="num">3</span>
					<p class="title">정보입력</p>
				</li>
			</ul>
			<div class="agreeList">
				<div class="agreeItem">
					<a href="#" class="agreeAnchor" onclick="getSignList(3);" ><span>서비스 이용약관</span></a>
					<div class="checkboxWrap type02">
						<span class="inputCheckbox solo">
							<input type="checkbox" id="chk_01" checked>
							<label for="chk_01"></label>
						</span>
					</div>
				</div>
				<div class="agreeItem">
					<a href="#" class="agreeAnchor" onclick="getSignList(1);" ><span>개인정보 수집·이용동의</span></a>
					<div class="checkboxWrap type02">
						<span class="inputCheckbox solo">
							<input type="checkbox" id="chk_02">
							<label for="chk_02"></label>
						</span>
					</div>
				</div>
				<div class="agreeItem">
					<a href="#" class="agreeAnchor" onclick="getSignList(2);"><span>고유식별정보 처리동의</span></a>
					<div class="checkboxWrap type02">
						<span class="inputCheckbox solo">
							<input type="checkbox" id="chk_03">
							<label for="chk_03"></label>
						</span>
					</div>
				</div>
			</div>
			
			<div class="sign-table-container">
			  <div class="sign-table-wrapper">
			    <table class="sign-table">
			      <tbody id="signList">
			        <!-- 여기에 JS로 <tr><td>...</td></tr>가 삽입됨 -->
			      </tbody>
			    </table>
			  </div>
			</div>

			<div class="buttonFixed">
				<div class="btnArea fix">
					<a href="#" class="btn btnCol01" onclick="cancelBtn();"><span>취소</span></a>
					<a href="#" class="btn btnCol02 next" onclick="goJoin3();"><span>다음</span></a>
				</div>
			</div>

			<!-- 내용 : e -->
		</div>
	</div>
</div>
<!-- [레] : 약관 팝업 : e -->

<!-- [레] : 정보입력 팝업 : s -->
<div class="popupWrap popupFull joinPopup3">
	<div class="popupContent popupInner">
		<div class="popupHead">
			<strong class="tit">회원인증</strong>
			<a href="javascript:layerPop('close' , 'joinPopup3')" class="btnPopClose">레이어 닫기</a>
		</div>
		<div class="popupCont">
			<!-- 내용 : s -->
			<ul class="stepList">
				<li>
					<span class="num">1</span>
					<p class="title">회원인증</p>
				</li>
				<li>
					<span class="num">2</span>
					<p class="title">약관동의</p>
				</li>
				<li class="on">
					<span class="num">3</span>
					<p class="title">정보입력</p>
				</li>
			</ul>
			<div class="form">

				<h5 class="pt30 pb20">추가 의료정보 등록</h5>
				<dl class="formList">
					<dt><span class="vital">성별</span></dt>
					<dd>
						<div class="radioWrap typeBox02">
							<span class="inputRadio">
								<input type="radio" name="rdo_gender" id="rdo_gender01" value="M" checked>
								<label for="rdo_gender01">남성</label>
							</span>
							<span class="inputRadio">
								<input type="radio" name="rdo_gender" id="rdo_gender02" value="F">
								<label for="rdo_gender02">여성</label>
							</span>
						</div>
					</dd>
				</dl>

				<dl class="formList">
					<dt><span>키</span></dt>
					<dd>
						<div class="inputWrap"><input type="text" class="inpText" id="height" value=""><span class="add_inf">cm</span></div>
					</dd>
				</dl>

				<dl class="formList">
					<dt><span>몸무게</span></dt>
					<dd>
						<div class="inputWrap"><input type="text" class="inpText" id="weight" value=""><span class="add_inf">kg</span></div>
					</dd>
				</dl>
				<dl class="formList">
						<dt><span class="vital">당뇨 유형</span></dt>
						<dd>
							<div class="radioWrap typeBox03">
								<span class="inputRadio">
									<input type="radio" name="rdo_sugar" id="rdo_sugar01" value="1" checked>
									<label for="rdo_sugar01">1형 당뇨병</label>
								</span>
								<span class="inputRadio">
									<input type="radio" name="rdo_sugar" id="rdo_sugar02" value="2">
									<label for="rdo_sugar02">2형 당뇨병</label>
								</span>
								<span class="inputRadio">
									<input type="radio" name="rdo_sugar" id="rdo_sugar03" value="3">
									<label for="rdo_sugar03">당뇨병 전단계</label>
								</span>
								<span class="inputRadio">
									<input type="radio" name="rdo_sugar" id="rdo_sugar04" value="4">
									<label for="rdo_sugar04">임신성 당뇨병</label>
								</span>
								<span class="inputRadio">
									<input type="radio" name="rdo_sugar" id="rdo_sugar09" value="9">
									<label for="rdo_sugar09">기타</label>
								</span>
							</div>
						</dd>
			  </dl>
			</div>

			<div class="buttonFixed">
				<div class="btnArea fix">
					<a href="#" class="btn btnCol02" onclick="registerUser();"><span>완료</span></a>
				</div>
			</div>

			<!-- 내용 : e -->
		</div>
	</div>
</div>
<!-- [레] : 정보입력 팝업 : e -->
<!-- 회원탈퇴 -->
<div class="popupWrap popupFull joinPopup4">
  <div class="popupContent popupInner">
    <div class="visual loginWrap">
    <!-- 팝업 본문 -->
    <div class="popupCont">
	    <!-- 팝업 헤더 -->
	    <div class="popupHead">
	      <p class="title">회원탈퇴 인증</p>
	      <a href="javascript:layerPop('close', 'joinPopup4')" class="btnPopClose" title="레이어 닫기">X</a>
	    </div>
    

	  <!-- 회원탈퇴 주의사항 -->
	  <p class="comment mt15 pl15">* 회원탈퇴 주의사항</p>	
	  <div class="notice_msg">
	     회원탈퇴 시 모든 개인정보 및 서비스 이용기록은 영구적으로 삭제되며 복구할 수 없습니다.
	  </div>
           
      <!-- 휴대폰번호 입력 -->
      <div class="left_right_wrap mt20">
        <div class="inputWrap mr10">
          <input type="text" class="inpText mt0" id="authPhone_out" placeholder="휴대폰번호 입력" maxlength="11"oninput="this.value = this.value.replace(/[^0-9]/g, '')" />
        </div>
        <div class="btnArea mt0 w50">
          <a href="#" class="btn btnLine01 round pl20 pr20" onclick="reqAuth_out();"> <span>인증번호 요청</span>
          </a>
        </div>
      </div>

      <!-- 안내문 -->
      <p class="comment mt15 pl15">* 본인 인증을 위하여 귀하의 휴대폰번호를 입력(번호만 입력)</p>
      <!-- 인증번호 입력 -->
      <div class="left_right_wrap mt20">
        <div class="inputWrap mr10">
          <input type="password" class="inpText mt0" id="authCode_out" placeholder="인증번호 입력" />
        </div>
        <div class="btnArea mt0 w50">
          <a href="#" class="btn btnCol01 round pl20 pr20" onclick="checkAuth_out();">
            <span>확 인</span>
          </a>
        </div>
      </div>
     </div>
    </div> <!-- popupCont -->

     <!-- 하단 고정 버튼 -->
    <div class="buttonFixed">
       <div class="btnArea fix">
         <a href="#" class="btn btnCol07" onclick="cancelBtn();"><span>회원탈퇴취소</span></a>
       </div>
    </div>

  </div> <!-- popupContent -->
</div>
		
<script>
var phone;
var phone_out;
$(document).ready(function() {
	callAndroid("f101");
});
function userInfoCallBack(data){
	if(data == ""){
		console.log("저장 정보 없음");
	}else{
		console.log(data);
		var obj = JSON.parse(data);
		console.log(obj);
		if(obj.autoYn){
			const userData = {};
			userData.phone = obj.phone;
			CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/autoLogin.do","POST",userData,function(response){
				if(response.IsSucceed){
					location.href = CommonUtil.getContextPath() + "/mainPage.do";
				}else{
					alert("자동 로그인 실패");
				}
			});
		}
		if(obj.saveYn){
			phone = obj.phone;
			$("#authPhone").val(phone);
			$("#chk_saveID").attr("checked", true);
		}
	}
}
function reqAuth(){
	//세션 인증시간이 1분 안지났으면 1분이내에 인증요청이력이있습니다. 확인후 다시 요청해달라고 보내고 return 
	phone = $("#authPhone").val();
	if(phone == "1855"){
		CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/testUser.do","POST",'',function(response){
			console.log(response.Data);
			alert("테스트 유저");
			location.href = CommonUtil.getContextPath() + "/mainPage.do";
		});
		return;
	}
	if(phone == "3399"){
		CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/testUser2.do","POST",'',function(response){
			console.log(response.Data);
			alert("테스트 유저");
			location.href = CommonUtil.getContextPath() + "/mainPage.do";
		//	location.href = CommonUtil.getContextPath() + "/goBloodPage.do";
			
		
		});
		return;
	}
	if(phone.length < 10){
		alert("휴대폰 번호를 정확히 입력해 주세요.");
		return;
	}
	//나중에 이로직 checkAuth 취소 (login_back 대체)
	// checkAuth() ;
   //
	//나중복구 
    //NCP 인증보내기 세션 에 인증키와 시간 등록 
 	CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/sendSensApi.do","POST",phone,function(response){
		console.log(response.Data);
		alert(response.Message);
	}); 
	
}
function saveUserInfo(){
	const appData = {};
	appData.phone = phone;
	appData.autoYn = $("#chk_login").is(':checked');
	appData.saveYn = $("#chk_saveID").is(':checked');
	callAndroid("f102",appData); 
}
function checkAuth(){
	var authCode = $("#authCode").val(); //
	const data = {};
	data.phone = phone;
	data.authCode = authCode; 
	CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/loginCheck.do","POST",data,function(response){
		console.log(response.Data);
		if(response.IsSucceed){
			alert(response.Message);
			if(response.Data >= 1){
				saveUserInfo();
				location.href = CommonUtil.getContextPath() + "/mainPage.do";
			}else{
				$("#email").removeAttr("readonly");
				$("#phone").val(phone);
				javascript:layerPop('open' , 'joinPopup1');
			}
		}else{
			alert(response.Message);
			//나중취소
			$("#email").removeAttr("readonly");
			$("#phone").val(phone);
			javascript:layerPop('open' , 'joinPopup1');
			//나중위소 
		} 
	});
}
//회원탈퇴  인증번호 가져올기 
function reqAuth_out(){
	//세션 인증시간이 1분 안지났으면 1분이내에 인증요청이력이있습니다. 확인후 다시 요청해달라고 보내고 return 
	phone = $("#authPhone_out").val();
	if(phone.length < 10){
		alert("휴대폰 번호를 정확히 입력해 주세요.");
		return;
	}
	//NCP 인증보내기 세션 에 인증키와 시간 등록 
	CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/sendSensApi.do","POST",phone,function(response){
		console.log(response.Data);
		alert(response.Message);
	});
	
}
//회원탈퇴 인증번호 가져오면 확인 
function checkAuth_out(){
	var authCode = $("#authCode_out").val();
	const data = {};
	data.phone    = phone;
	data.authCode = authCode;
	CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/loginCheck.do","POST",data,function(response){
		console.log(response.Data);
		if(response.IsSucceed){
			if(response.Data >= 1){
				  const data = {
				    userUuid : "${sessionScope.userUuid}"
				  };
				  if (confirm(`${phone} 개인 관련정보를 삭제하시겠습니까?`)) {
				      $.ajax({
					      url: "/alldelete.do",
					      type: "POST",
					      contentType: "application/json",
					      data: JSON.stringify([data]), // 배열로 전송
					      success: function(response) {
					         alert("개인관련 전체 정보가 삭제되었습니다.");
					      },
					      error: function(xhr, status, error) {
					    	 alert("시스템오류입니다 다시 입력하세요!");
					      }
					  });
				  }
			}else{
				alert("등록된 회원 아닙니다.");
				return;
			}
		}else{
			alert(response.Message);
		} 
	});
}
/* 취소 버튼 */
function cancelBtn(){
	location.href = CommonUtil.getContextPath() + "/loginPage.do";
}
function goJoin10(){
	getSignList("1");
	javascript:layerPop('open' , 'joinPopup10');
}
/* 약관 팝업 오픈 */
function goJoin2(){
	var phone = $("#phone").val();
	var userNm = $("#userNm").val();
	var birth = $("#birth").val();
	if (phone.length < 1){
		alert("휴대폰번호를 입력해주세요.");
		return;
	}
	if(userNm.length < 1){
		alert("이름을 입력해주세요.");
		return;
	}
	if(birth.length < 8){
		alert("생년월일을 8자리로 정확히 입력해주세요.");
		return;
	}
	javascript:layerPop('close' , 'joinPopup1');
	javascript:layerPop('open' , 'joinPopup2');
	
}
/* 정보입력 팝업 오픈 */
function goJoin3(){
	var checked1 = $("#chk_01").is(':checked');
	var checked2 = $("#chk_02").is(':checked');
	var checked3 = $("#chk_03").is(':checked');
	if(!checked1) {
		alert("서비스 이용약관에 동의해주세요.");
		return;
	}
	if(!checked2) {
		alert("개인정보 수집 이용동의 항목에 동의해주세요.");
		return;
	}
	if(!checked3) {
		alert("고유식별정보 처리동의 항목에 동의해주세요.");
		return;
	}
	javascript:layerPop('close' , 'joinPopup2');
	javascript:layerPop('open' , 'joinPopup3');
}

function goJoin4(){
	javascript:layerPop('open' , 'joinPopup4');
}

/* 사용자 정보 등*/
function registerUser() {
  // 1) 입력값 수집 & 기본 검증
  const data = {
    phone:  $.trim($("#phone").val()),
    email:  $.trim($("#email").val()),
    userNm: $.trim($("#userNm").val()),
    birth:  $.trim($("#birth").val()),
    gender: $('input[name=rdo_gender]:checked').val() || null,
    blodGb: $('input[name=rdo_sugar]:checked').val() || null, // 의도된 name/값이라면 유지
    height: $.trim($("#height").val()),
    weight: $.trim($("#weight").val())
  };

  // 간단한 유효성 체크 (필요시 강화)
  if (!data.phone || !data.userNm) {
    alert("필수 항목(전화번호/이름)을 입력해 주세요.");
    return;
  }

  // 2) 중복 클릭 방지 (버튼 비활성화)
  const $btn = $("#btnRegister"); // 실제 버튼 id로 변경
  $btn.prop("disabled", true);

  const ctx = CommonUtil.getContextPath();

  // 3) 1차 호출: /User.do
  CommonUtil.callSyncAjax(`${ctx}/User.do`, "POST", data, function (res1) {
    if (res1 && res1.IsSucceed) {
      // 3-1) 성공 → updateUser
      CommonUtil.callSyncAjax(`${ctx}/updateUser.do`, "POST", data, function (res2) {
        finalizeRegister(res2);
      });
    } else {
      // 3-2) 실패 → registerUser
      CommonUtil.callSyncAjax(`${ctx}/registerUser.do`, "POST", data, function (res3) {
        finalizeRegister(res3);
      });
    }
  });

  function finalizeRegister(resp) {
    try {
      console.log(resp && resp.Data);
      if (resp && resp.IsSucceed) {
        saveUserInfo();
        alert("회원가입 성공 하였습니다.");
        location.href = `${ctx}/mainPage.do`;
      } else {
        alert("회원 가입 실패. 관리자에게 문의 부탁드립니다.");
        $btn.prop("disabled", false);
      }
    } catch (e) {
      console.error(e);
      alert("처리 중 오류가 발생했습니다.");
      $btn.prop("disabled", false);
    }
  }
}


//1. SDK 초기화

Kakao.init('${kakaoJsKey}');
if (!Kakao.isInitialized()) {
    alert('카카오 SDK 초기화 실패');
} else {
//	alert('${kakaoJsKey}' + " 카카오 SDK 초기화 성공");
}

//3. 로그인 함수 (기존 구조 유지, 보완만 추가)
function loginWithKakao() {
	// (가드) SDK 미초기화 시 사용자에게 안내
	if (!window.Kakao || !Kakao.isInitialized()) {
	 alert("카카오 SDK가 아직 준비되지 않았습니다. 잠시 후 다시 시도해주세요.");
	 return;
	}
	
	// 내부 헬퍼들: 함수 표현식으로 선언(중첩 선언 경고/호이스팅 이슈 회피)
	const reAskEmailConsent = function () {
	 Kakao.Auth.login({
	   scope: 'account_email,profile_nickname',
	   success: function () {
	     requestUserAndSend();
	   },
	   fail: function (err) {
	     console.error('이메일 동의 재요청 실패', err);
	     alert("이메일 제공 동의가 필요합니다.");
	   }
	 });
	};
	
	const requestUserAndSend = function () {
	 Kakao.API.request({
	   url: '/v2/user/me',
	   success: function (res) {
	     // 1) 이메일 확보 로직 강화
	     var email = null;
	     if (res.kakao_account) {
	       if (res.kakao_account.email) {
	         email = res.kakao_account.email;
	       } else if (res.kakao_account.has_email === true &&
	                  res.kakao_account.email_needs_agreement === true) {
	         reAskEmailConsent();
	         return;
	       }
	     }
	
	     if (!email) {
	       alert("카카오에서 이메일 제공이 되지 않았습니다. 회원정보를 입력해 주세요.");
	       $("#phone").removeAttr("readonly");
	       $("#email").val("");
	       layerPop('open', 'joinPopup1');
	       return;
	     }
	
	     // 2) 서버로 이메일 전송 (기존 그대로 유지)
	     const userData = { email: email };
	     CommonUtil.callSyncAjax(
	       CommonUtil.getContextPath() + "/testUser3.do",
	       "POST",
	       userData,
	       function (response) {
	         console.log(response.Data);
	         if (response.Data) {
	           location.href = CommonUtil.getContextPath() + "/mainPage.do";
	         } else {
	           alert(response.message || "'확인'을 클릭하여 회원정보를 입력해주세요");
	           $("#phone").removeAttr("readonly");
	           $("#email").val(userData.email);
	           layerPop('open', 'joinPopup1');
	         }
	       },
	       function (error) {
	         console.error("Ajax 실패", error);
	         alert("서버 전송 실패");
	       }
	     );
	   },
	   fail: function (error) {
	     console.error('사용자 정보 요청 실패', error);
	     alert("사용자 정보 요청 실패");
	   }
	 });
	};
	
	// A. 현재 Kakao Auth 상태 확인
	// * SDK v2 기준: getStatusInfo가 일반적입니다.
	Kakao.Auth.getStatusInfo(function (statusObj) {
	 if (statusObj.status === 'connected') {
	   requestUserAndSend();
	 } else {
	   Kakao.Auth.login({
	     scope: 'account_email,profile_nickname',
	     success: function (authObj) {
	       console.log('로그인 성공:', authObj);
	       requestUserAndSend();
	     },
	     fail: function (err) {
	       console.error('로그인 실패', err);
	       alert("로그인 실패");
	     }
	   });
	 }
	});
}

 window.onload = function() {
    const email = "${email1}"; // 서버에서 email 세팅되었다고 가정

    if (email) {
      sendUserData(email);
    }
  };

 function sendUserData(email) {
   const userData = { email: email };

   CommonUtil.callSyncAjax(
     CommonUtil.getContextPath() + "/testUser3.do",
     "POST",
     userData,
     function(response) {
       console.log("서버 응답:", response.Data);
       location.href = CommonUtil.getContextPath() + "/mainPage.do";
     },
     function(error) {
       console.error("Ajax 실패", error);
       alert("서버 전송 실패");
     }
   );
 }
 function getSignList(termsGb) {
	  let param = {
		  termsGb :  termsGb
      };
	  fetch('/getSignList.do', {
	    method: 'POST',
	    headers: {
	      'Content-Type': 'application/json'
	    },
	    body: JSON.stringify(param)
	  })
	  .then(response => response.json())
	  .then(result => {
	    if (result.IsSucceed) {
	      renderSignList(result.Data);
	    } else {
	      alert('개인정보을 불러오는 데 실패했습니다.');
	    }
	  })
	  .catch(error => {
	    console.error('Error:', error);
	  });
	}
	function renderSignList(data) {
		  let list = document.getElementById("signList");
		  list.innerHTML = '';

		  data.forEach(item => {
		    const tr = document.createElement('tr');
		    
		    tr.setAttribute('data-exer-seq', item.termsSeq); // tr에 key 저장
		    
		    const tdType = document.createElement('td');
		    const name = item.termsConts || '';  // ✅ 먼저 name 변수 선언

		    if (name.length > 500) {
		      tdType.textContent = name.substring(0, 500) + '…';
			  tdType.setAttribute("data-tooltip", name);
			  tdType.classList.add("has-tooltip");
		    } else {
		      tdType.textContent = name;
		    }
		    tr.appendChild(tdType);

		    list.appendChild(tr);
		  });
	}
</script>
