<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
	Date nowTime = new Date();
	SimpleDateFormat sf = new SimpleDateFormat("yyyyMMdd");
%>
<!-- contents : s -->
    <div class="contents">
      <div class="settings">
        <div class="section">
          <p class="sectionTitle">로그인/회원정보</p>
          <div class="list">
            <div class="item">
              <div class="labelArea">
                <p class="label" id="userNm"></p>
              </div>
              <div class="right">
                <a href="#" onclick="logout();" class="textBtn">로그아웃</a>
              </div>
            </div>
            <div class="item">
              <div class="labelArea">
                <p class="label">자동 로그인</p>
              </div>
              <div class="right">
                <label class="switch">
                  <input type="checkbox" id="autoYn" />
                  <span class="slider"></span>
                </label>
              </div>
            </div>
          </div>
        </div>
        <div class="section hide">
          <p class="sectionTitle">공동인증서</p>
          <div class="list">
            <a href="#" class="item">
              <div class="labelArea">
                <p class="label">공동인증서 가져오기</p>
              </div>
            </a>
            <a href="#" class="item">
              <div class="labelArea">
                <p class="label">자동 로그인</p>
              </div>
            </a>
          </div>
        </div>
        <div class="section">
          <p class="sectionTitle">알림 설정</p>
          <div class="list">
            <div class="item">
              <div class="labelArea">
                <p class="label">알림 PUSH 설정</p>
                <p class="desc hide">
                  건강정보, 건강소식, 복약 관리, 공지 등 사용자님을 위한
                  정보를 알려드립니다.
                </p>
              </div>
              <div class="right">
                <label class="switch">
                  <input type="checkbox" id="pushYn"/>
                  <span class="slider"></span>
                </label>
              </div>
            </div>
          </div>
        </div>
        <div class="section hide">
          <p class="sectionTitle">공동인증서</p>
          <div class="list">
            <a href="#" class="item">
              <div class="labelArea">
                <p class="label">가족 회원관리</p>
              </div>
            </a>
            <div class="item">
              <div class="labelArea">
                <p class="label">가족 회원관리</p>
                <p class="desc">연동된 가족회원이 없습니다.</p>
              </div>
            </div>
          </div>
        </div>
		<div class="section">
		  <p class="sectionTitle">약관</p>
		  <div class="list">
		    <div class="item">
		      <div class="labelArea">
		        <a href="#" class="agreeAnchor" onclick="getSignList(3);"><span>서비스 이용약관</span></a>
              </div>
		    </div>
		    <div class="item">
		      <div class="labelArea">
		        <a href="#" class="agreeAnchor" onclick="getSignList(1);" ><span>개인정보 취급방침</span></a>
		      </div>
		    </div>
		    <div class="item">
		      <div class="labelArea">
		       <a href="#" class="agreeAnchor" onclick="getSignList(2);"><span>민감정보 취급방침</span></a>
		      </div>
		    </div>
		  </div>
		</div>
       	<div id="sign-table-container" class="sign-table-container">
		  <div class="sign-table-wrapper">
		    <table class="sign-table">
		      <tbody id="signList">
		      </tbody>
		    </table>
		  </div>
		</div>
        <div class="section">
          <p class="sectionTitle">앱 버전정보</p>
          <div class="list"><!-- 
            <div class="item">
              <div class="labelArea">
                <p class="label">현재 버전 V0.0.1</p>
              </div>
              <div class="right">
                <a href="#" class="textBtn">업데이트하기</a>
              </div>
            </div> -->
            <div class="item">
              <div class="labelArea">
                <p class="label">현재 버전 V1.0</p>
                <p class="desc">최신버전입니다.</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
<!-- contents : e -->
<script>
var phone;
$(document).ready(function(){
	getUserInfo();
});
function getUserInfo(){
	CommonUtil.callAjax(CommonUtil.getContextPath() + "/getUserInfo.do","POST",'',function(response){
		console.log(response.Data);
		const user = response.Data;
		phone = user.phone;
		if(user.pushYn == "Y") $("#pushYn").attr("checked", true);
		
		$("#userNm").text(user.userNm);
	});
}
function saveUserInfo(){
	const appData = {};
	appData.phone = phone;
	appData.autoYn = $("#autoYn").is(':checked');
	appData.saveYn = true;
	callAndroid("f102",appData); 
}
function logout(){
	CommonUtil.callAjax(CommonUtil.getContextPath() + "/logout.do","POST",'',function(response){
		
		saveUserInfo();
		alert("로그아웃 성공");
		location.href = CommonUtil.getContextPath() + "/loginPage.do";
	});
}
let openedTermsGb = ""; // 현재 열려 있는 약관 ID를 저장	

function getSignList(termsGb) {
  // 이미 열려있는 걸 다시 클릭하면 닫기
  if (openedTermsGb === termsGb) {
    closeSignList(); 
    openedTermsGb = "";
    return;
  }

  let param = { termsGb: termsGb };

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
        openedTermsGb = termsGb; // 열린 상태 저장
      } else {
        alert('개인정보를 불러오는 데 실패했습니다.');
      }
    })
    .catch(error => {
      console.error('Error:', error);
    });
}

// 닫기 함수 (tbody 내용만 지움)
function closeSignList() {
  const tbody = document.getElementById("signList");
  if (tbody) {
    tbody.innerHTML = ""; // 내용만 제거 (테이블 구조 유지)
  }
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