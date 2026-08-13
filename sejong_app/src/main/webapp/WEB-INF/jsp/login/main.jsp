<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet" />
<style>
/* [슬라이드 메뉴 상단 로그아웃 버튼] 닫기(X) 왼쪽에 배치 (기존 .menuWrap .logout 스타일 재사용, 위치만 조정) */
.menuWrap .user .logout{
  right: calc(15 * var(--vwu, 1vw)); /* 닫기(X)와 간격 확보 위해 좌측으로 이동 */
  top: calc(2.2 * var(--vwu, 1vw));
  z-index: 2;
  cursor: pointer;
  text-decoration: none;
}
/* [이름 밑 선 제거] 이름/상단 행 영역의 밑줄·하단 보더·그림자 제거 */
.menuWrap .topArea,
.menuWrap .topArea .user,
.menuWrap .topArea .name,
.menuWrap .topArea .name strong,
.menuWrap .topArea .name > span{
  text-decoration: none !important;
  border-bottom: 0 !important;
  box-shadow: none !important;
}
.menuWrap .topArea .name::after,
.menuWrap .topArea .user::after{ display: none !important; }

/* 의료정보변경 팝업 취소 버튼 색·간격은 common.css 에 있다(팝업이 top.jsp·userSetting.jsp 에도 복제돼 있어 공통 처리) */

/* [메인 개편 2026-07-31 — 기획 이미지] 4카드 대신 혈당상태 카드 + AI 메뉴.
   색은 통일성: 앱 파랑(#218ecb) / 정상=초록 / 관리 필요=주황. 기존 4카드는 삭제 아닌 숨김(원복 대비, #oldMainCards) */
.mainState{ background:#fff; border:1px solid #dfe6f0; border-radius:calc(2.8 * var(--vwu,1vw));
  padding:calc(4.2 * var(--vwu,1vw)) calc(4.2 * var(--vwu,1vw)) calc(3 * var(--vwu,1vw));
  margin-top:calc(4 * var(--vwu,1vw)); box-shadow:0 2px 8px rgba(18,38,99,.08); }
/* [2026-08-05 검토회의] 홈 혈당상태 카드 글씨 키움(상태 문장·기준 안내 모두) */
.mainState .stateText{ font-size:calc(5 * var(--vwu,1vw)); color:#2d303f; font-weight:500; line-height:1.4; }
.mainState .stateText em{ font-style:normal; font-weight:800; }
.mainState .stateText em.st-good{ color:#2e7d32; }   /* 정상 */
.mainState .stateText em.st-warn{ color:#e67e22; }   /* 관리 필요 */
.mainState .stateText em.st-none{ color:#8a98a8; }   /* 측정값 없음/확인 중 */
.mainState .tirTxt{ display:block; margin-top:calc(1.6 * var(--vwu,1vw)); font-size:calc(3.8 * var(--vwu,1vw));
  line-height:1.45; color:#6b7889; word-break:keep-all; }
.mainState .stateLink{ display:block; text-align:right; margin-top:calc(2.2 * var(--vwu,1vw));
  font-size:calc(3.7 * var(--vwu,1vw)); font-weight:800; color:#218ecb; text-decoration:underline; text-underline-offset:3px; }
.mainAiMenu{ margin-top:calc(3.5 * var(--vwu,1vw)); display:flex; flex-direction:column; gap:calc(2.8 * var(--vwu,1vw)); }
.mainAiMenu .aiBtn{ display:flex; align-items:center; justify-content:space-between;
  background:#fff; border:1px solid #218ecb; border-radius:calc(2.4 * var(--vwu,1vw));
  padding:calc(3.3 * var(--vwu,1vw)) calc(4.2 * var(--vwu,1vw));
  font-size:calc(4.07 * var(--vwu,1vw)); font-weight:700; color:#2d303f; text-decoration:none; }
.mainAiMenu .aiBtn i{ font-style:normal; color:#218ecb; font-weight:800; }
/* [2026-08-01] CGM 상태 안내(#errormsg) 복원 — AI 메뉴 아래.
   예전엔 옛 4카드용 흰 글자가 배경에 그대로 얹혀 '겹쳐 보인다'는 지적으로 숨겼던 것 →
   반투명 박스로 감싸 배경(파랑 일러스트) 위에서도 읽히게 하고, 내용이 있을 때만 표시한다. */
.cgmNotice{ display:none; margin-top:calc(3.2 * var(--vwu,1vw));
  background:rgba(255,255,255,.16); border:1px solid rgba(255,255,255,.35);
  border-radius:calc(2.2 * var(--vwu,1vw));
  padding:calc(2.8 * var(--vwu,1vw)) calc(3.6 * var(--vwu,1vw));
  font-size:calc(3.4 * var(--vwu,1vw)); line-height:1.45; color:#fff; word-break:keep-all; }
</style>
<!-- wrap : s -->
 <div class="wrap main">
	<header class="header">
     <div class="alignTitle">
       <a href="#" class="logo"></a>
       <span>일상속의 자유로운 건강관리</span>
     </div>
      <div class="menuWrap">
        <div class="topArea">
          <div class="user util" onclick="javascript:">
          <div class="name"><strong id="subName"></strong><span>님</span>
            <div class="item notice">
              알림<span class="">새로운 알림</span>
            </div>
          </div>
          <a href="#" class="logout" onclick="logout(); return false;">로그아웃</a>
          <a href="#" class="menuClose"></a>
        </div>
      </div>
      <div class="menuList">
        <div class="menu_row">
          <a class="menu_box" href="<c:url value='/goBloodPage.do'/>">
            <p class="img_box">
              <img src="<c:url value='/asset/images/common/img_menu_blood.png'/> " alt="연속혈당">
            </p>
            <span>연속혈당</span>
          </a>
          <a class="menu_box" href="<c:url value='/foodMain.do'/> ">
            <p class="img_box">
              <img src="<c:url value='/asset/images/common/img_menu_food.png'/> " alt="식사관리">
            </p>
            <span>식사관리</span>
            
          </a>
        </div>
        <div class="menu_row run">
          <a class="menu_box_run" href="<c:url value='/exerMain.do'/> ">
            <span>운동관리</span>
          </a>
        </div>
        <%-- [슬라이드 메뉴 하단 변경 2026-07-31 — 기획 이미지] 아이콘 그리드 → 텍스트 바로가기 목록.
             1:1문의(asqMain.do)는 기획안대로 제외. 개인정보 변경 = 기존 의료정보변경 팝업.
             tiles/main/top.jsp 에 같은 메뉴가 하나 더 있다 — 바꿀 때 둘 다 고칠 것. --%>
        <div class="etc_menu_list etc_links">
          <a class="etc_link" href="<c:url value='noticePage.do'/> ">&gt; 공지사항 바로가기</a>
          <a class="etc_link" href="<c:url value='faqPage.do'/> ">&gt; FAQ 바로가기</a>
          <a class="etc_link" href="javascript:layerPop('open' , 'infoChangePopup')">&gt; 개인정보 변경 바로가기</a>
          <a class="etc_link" href="<c:url value='settingPage.do'/> ">&gt; 설정 바로가기</a>
        </div>
      </div>
    </div>

    <div class="alignRight">
      <a href="#" class="btnMenu"><span>메뉴</span></a>
    </div>
  </header>
   <!-- contents : s -->
   <div class="contents">
     <div class="user"><em class="name" id="name"></em> 반갑습니다.</div>
     <div class="recently">
       <p class="desc">
         혈당관리, 식사관리, 운동관리를 통한 일상속 건강관리를 해보세요.
       </p>
     </div>
     <%-- [메인 개편 2026-07-31 — 기획 이미지] 현재 혈당상태(TIR 기준) + AI 메뉴.
          · 상태 판정 = 오늘 혈당의 TIR(70~180mg/dL 범위 내 비율): 70% 이상 '정상' / 미만 '관리 필요' / 데이터 없으면 측정값 없음
          · [혈당 지표 확인] = 기존 연속혈당 화면(goBloodPage.do)
          · AI 종합분석(주간)·AI 챗봇 = 추후 연결(일단 자리만 — 준비 중 안내) --%>
     <div class="mainState">
       <p class="stateText">현재 혈당상태는 <em id="bloodState" class="st-none">확인 중</em> 입니다</p>
       <span class="tirTxt" id="bloodTir"></span>
       <a href="<c:url value='/goBloodPage.do'/>" class="stateLink">혈당 지표 확인 &nbsp;&gt;&gt;</a>
     </div>
     <div class="mainAiMenu">
       <%-- AI 종합분석(주간) = 기존 혈당분석(혈당 연관분석) 화면 호출 (2026-07-31 기획 확정) --%>
       <a href="<c:url value='/goBloodPage2.do'/>" class="aiBtn"><span>AI 종합분석(주간)</span><i>&gt;</i></a>
       <%-- AI 챗봇 = 혈당 연관분석의 Q&A 를 전체화면 오버레이로 이동(기획 7) — ?chat=1 로 진입하면 자동 오픈 --%>
       <a href="<c:url value='/goBloodPage2.do'/>?chat=1" class="aiBtn"><span>AI 챗봇</span><i>&gt;</i></a>
     </div>
     <%-- [2026-08-01] CGM 상태 안내 — 개편 전 메인에 있던 안내(센서 착용 / i-Sens 연동 필요)를
          AI 메뉴 바로 밑으로 되살렸다. 내용이 있을 때만 보인다(_setCgmNotice). --%>
     <p class="cgmNotice" id="errormsg"></p>

     <%-- 기존 4카드(연속혈당·혈당분석·식사관리·운동관리) — 삭제 아닌 숨김(원복 대비).
          todayBlod() 가 채우는 #nowVal 등도 이 안에 있어 그대로 둔다(안 보여도 무해). --%>
     <div id="oldMainCards" style="display:none;">
     <ul class="dataList">
       <li class="dataItem">
         <a href="<c:url value='/goBloodPage.do'/> " class="inner data01">
           <p class="title">연속혈당</p>
           <div class="blood_wrap mt20">
             <div class="arrow_wrap">
               <span class="material-icons blood_arrow bl_color_stable bl_angle_slowdown">east</span>
               <!-- 화살표의 컬러는 현재 혈당수치에 따라 컬러를 적용 -->
               <!-- 화살표의 각도는 직전 혈당 수치와 비교하여 각도 적용 기획서 표 참고 -->
               <span class="diff" id="diff"></span>
             </div>
             <div class="count">
               <div class="data bl_color_stable" id="nowVal">0</div>
               <div class="time" id="formatedDate"></div>
             </div>
           </div>
           <i class="arrow">바로가기</i>
         </a>
       </li>
       <li class="dataItem">
         <a href="<c:url value='/goBloodPage2.do'/> " class="inner data02">
           <p class="title">혈당분석</p>
           <div class="ave_wrap mt20">
             <div class="ave_count bl_color_stable">
				<div class="title_group">
				  <span class="main_title">혈당/식사/운동 연관분석</span>
				</div>
             </div>
           </div>
           <i class="arrow">바로가기</i>
         </a>
       </li>
     </ul>
     <ul class="dataList">
       <li class="dataItem">
         <a href="<c:url value='/foodConsult.do'/> " class="inner data03">
           <p class="title">식사관리</p>
           <div class="ave_wrap mt20">
	             <div class="ave_count bl_color_stable">
				  <div class="title_group">
					  <span class="main_title">오늘의 식사와</span>
					  <span class="main_title">혈당분석</span>
				  </div>
				</div>
			</div>
           <i class="arrow">바로가기</i>
         </a>
       </li>
       <li class="dataItem">
         <a href="<c:url value='/exerConsult.do'/> " class="inner data04">
           <p class="title">운동관리</p>
             <div class="ave_wrap mt20">
	             <div class="ave_count bl_color_stable">
				  <div class="title_group">
				  <span class="main_title">오늘의 운동과</span>
				  <span class="main_title">혈당분석</span>
                 </div>
             </div>    
           </div>
           <i class="arrow">바로가기</i>
         </a>
       </li>
     </ul>
     </div><%-- /#oldMainCards (숨김) --%>
     <!-- contents : e -->
   </div>

   <!-- footer Nav : s -->
   <nav class="footerNav">
     <ul>
       <li>
         <a href="<c:url value='/mainPage.do'/> " class="on">
           <img src="<c:url value='/asset/images/blood/icon_home.png'/> " alt="">
           <span>홈</span>
         </a>
       </li>
       <li>
         <a href="<c:url value='/goBloodPage.do'/> ">
           <img src="<c:url value='/asset/images/blood/icon_blood.png'/> " alt="">
           <span>연속혈당</span>
         </a>
       </li>
       <li>
         <a href="<c:url value='/foodMain.do'/> ">
           <img src="<c:url value='/asset/images/blood/icon_food.png'/> " alt="">
           <span>식사등록</span>
         </a>
       </li>
       <li>
         <a href="<c:url value='/exerMain.do'/> ">
           <img src="<c:url value='/asset/images/fit/footer.png'/> " alt="">
           <span>운동등록</span>
         </a>
       </li>
     </ul>
   </nav>
   <!-- footer Nav : e -->

 </div>
   <!-- [레] : 의료정보변경 팝업 : s -->
  <div class="popupWrap popupFull infoChangePopup">
    <div class="popupContent popupInner">
      <div class="popupHead">
        <strong class="tit">의료정보변경</strong>
        <a href="javascript:layerPop('close' , 'infoChangePopup')" class="btnPopClose">레이어 닫기</a>
      </div>
      <div class="popupCont">
        <!-- 내용 : s -->
        <div class="form">
          <dl class="formList">
            <dt><span>키</span></dt>
            <dd>
              <div class="inputWrap"><input type="text" class="inpText" id="height" value=""><span
                  class="add_inf">cm</span>
              </div>
            </dd>
          </dl>

          <dl class="formList">
            <dt><span>몸무게</span></dt>
            <dd>
              <div class="inputWrap"><input type="text" class="inpText" id="weight" value=""><span class="add_inf">kg</span>
              </div>
            </dd>
          </dl>
          <dl class="formList hide">
            <dt><span>혈액형</span></dt>
            <dd>
              <div class="selectBoxWrap">
                <select>
                  <option value="1">B+</option>
                </select>
              </div>
            </dd>
          </dl>

          <dl class="formList">
            <dt><span class="vital">당뇨 유형</span></dt>
            <dd>
              <div class="radioWrap typeBox03">
                <span class="inputRadio">
                  <input type="radio" name="rdo_sugar" id="rdo_sugar01" value="1">
                  <label for="rdo_sugar01">1형 당뇨병</label>
                </span>
                <span class="inputRadio">
                  <input type="radio" name="rdo_sugar" id="rdo_sugar02" value="2">
                  <label for="rdo_sugar02">2형 당뇨병</label>
                </span>
                <span class="inputRadio">
                  <input type="radio" name="rdo_sugar" id="rdo_sugar03" value="3" checked>
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

          <dl class="formList hide">
            <dt><span>과거력</span></dt>
            <dd>
              <div class="radioWrap typeBox02">
                <span class="inputRadio">
                  <input type="checkbox" id="chk0101" checked />
                  <label for="chk0101">뇌졸증</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0102" />
                  <label for="chk0102">심장병</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0103" />
                  <label for="chk0103">고혈압</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0104" />
                  <label for="chk0104">당뇨병</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0105" />
                  <label for="chk0105">고지혈증</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0106" />
                  <label for="chk0106">폐결핵</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0107" />
                  <label for="chk0107">기타(암포함)</label>
                </span>
              </div>
            </dd>
          </dl>
          <dl class="formList hide">
            <dt><span>가족력</span></dt>
            <dd>
              <div class="radioWrap typeBox02">
                <span class="inputRadio">
                  <input type="checkbox" id="chk0201" checked />
                  <label for="chk0201">뇌졸중</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0202" />
                  <label for="chk0202">심장병</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0203" />
                  <label for="chk0203">고혈압</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0204" />
                  <label for="chk0204">당뇨병</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0205" />
                  <label for="chk0205">간장질환</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0206" />
                  <label for="chk0206">암</label>
                </span>
              </div>
            </dd>
          </dl>
        </div>
        <!-- 내용 : e -->
      </div>
      <div class="btnArea bottom">
        <a href="javascript:layerPop('close' , 'infoChangePopup')" class="btn btnCol01"><span>취소</span></a>
        <a href="#" onclick="updateUserInfo();" class="btn btnCol02"><span>확인</span></a>
      </div>
    </div>
  </div>
 <!-- wrap : e -->
<script>
var accessToken = "";
var userId = "";
var gender;
var _userPhone = ""; // 로그아웃 시 자동로그인 해제용(번호 유지)
$(document).ready(function() {
	getUserInfo();
	var userNm = '<%=session.getAttribute("userNm")%>';
	gender = '${gender}';
	if(userNm == null || userNm == "null"){
		location.href = CommonUtil.getContextPath() + "/loginPage.do";
	}
	$("#name").text(userNm+"님");
	$("#subName").text(userNm);

	CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/tokenYn.do","POST",'',function(response){ window.__hasToken = !!(response && response.IsSucceed); /* [2026-07-11] 연동(토큰) 상태 저장 → 안내문구 분기용 */
		if(response.IsSucceed){
			getBloodUserData();
			getBloodData();
		}
	}); 
	todayBlod(); //임시 적용 원래없음 
	
	todayExecs();
	todayFood();
});
function getUserInfo(){
	CommonUtil.callAjax(CommonUtil.getContextPath() + "/getUserInfo.do","POST",'',function(response){
		console.log(response.Data);
		const user = response.Data;
		_userPhone = user.phone; // 로그아웃 시 자동로그인 해제에 사용
		$("#height").val(user.height);
		$("#weight").val(user.weight);
		$('input:radio[name=rdo_sugar]:input[value='+user.blodGb+']').attr("checked", true);
	});
}
// 슬라이드 메뉴 상단 로그아웃: 서버 세션 해제 + 자동로그인 해제 후 로그인 화면으로 이동.
// (자동로그인을 안 끄면 loginPage.do 진입 시 autoLogin.do 로 곧바로 재로그인되어 로그아웃이 무효가 됨)
function logout(){
	if(!confirm("로그아웃 하시겠습니까?")) return;
	try { callAndroid("f102", { phone: _userPhone, autoYn: false, saveYn: true }); } catch(e){ console.warn("자동로그인 해제 실패:", e); }
	CommonUtil.callAjax(CommonUtil.getContextPath() + "/logout.do","POST",'',function(response){
		location.href = CommonUtil.getContextPath() + "/loginPage.do";
	});
}

function updateUserInfo(){
	const data = {};
	data.height = $("#height").val();
	data.weight = $("#weight").val();
	data.blodGb = $('input[name=rdo_sugar]:checked').val();
	CommonUtil.callAjax(CommonUtil.getContextPath() + "/updateUserInfo.do","POST",data,function(response){
		console.log(response.Data);
		alert("개인정보 설정 완료");
		javascript:layerPop('close' , 'infoChangePopup');
		getUserInfo();
	});
}
function getFormattedDate(date) {
	  const year = date.getFullYear();
	  const month = String(date.getMonth() + 1).padStart(2, '0'); // 월은 0부터 시작하므로 +1
	  const day = String(date.getDate()).padStart(2, '0');
	  const hours = String(date.getHours()).padStart(2, '0');
	  const minutes = String(date.getMinutes()).padStart(2, '0');
	  const seconds = String(date.getSeconds()).padStart(2, '0');

	  const timezoneOffset = -date.getTimezoneOffset(); // 분 단위 오프셋
	  const sign = timezoneOffset >= 0 ? '+' : '-';
	  const offsetHours = String(Math.floor(Math.abs(timezoneOffset) / 60)).padStart(2, '0');
	  const offsetMinutes = String(Math.abs(timezoneOffset) % 60).padStart(2, '0');
	  return year+"-"+month+"-"+day+"T"+hours+":"+minutes+":"+seconds+""+sign+""+offsetHours+":"+offsetMinutes;
	}

function getDateNDaysAgoFormatted(days) {
  const date = new Date();
  date.setDate(date.getDate() - days); // N일 전 날짜로 설정
  return getFormattedDate(date);
}
function getBloodUserData() {
    CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/getBloodUserData.do","POST",'',
  		function(response){
    		console.log(response);
      		accessToken = response.accToken;
      		userId = response.userId;
  		}
  	)
}
//혈당 데이터 가져오기
function getBloodData(){
	  var end = getDateNDaysAgoFormatted(0);
	  var start = getDateNDaysAgoFormatted(1);
	  $.ajax({
		    url: CommonUtil.getContextPath() + '/getBloodData.do',
			type: 'GET',
			async: true,   /* [2026-07-11] 외부 CGM 재수집을 비동기로 — 화면 로딩이 외부응답을 기다리지 않음(완료 시 todayBlod/todayBlodAvg로 갱신) */
			data: {
	            start : start,
		        end: end,
	            accessToken : accessToken,
	            goTokenUrl : 'https://cgm.i-sens.com:10200/v1/public/cgms',
				  },
			success: function(response) { 
					const result = JSON.parse(response);
						if(!result.IsSucceed){
							refreshToken();
						}else{
							todayBlod();
							todayBlodAvg();
						}
				    },
			error: function(xhr, status, error) {
				   	console.log('Error: ' + error);
				 	}     
		});    
	    
}
function refreshToken(){
	  CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/refreshToken.do","POST",'',
			function(response){
				console.log(response);
				if(response.IsSucceed){
					getBloodUserData();
				    getBloodData();
				}
			}
	  
	)
}
/* [메인 개편 2026-07-31] 오늘 혈당의 TIR(70~180mg/dL 범위 내 비율)로 상태 표시.
   기준: TIR 70% 이상 = '정상'(초록) / 미만 = '관리 필요'(주황) / 유효 측정값 없음 = 회색 안내.
   원천 = todayBlod() 가 이미 받아오는 getTodayBlood.do(오늘 측정 목록) — 추가 조회 없음. */
/* [2026-07-31] 같은 내용이면 DOM 을 건드리지 않는다 — todayBlod() 가 진입 시 1회,
   외부 CGM 재수집(getBloodData) 성공 후 1회 더 불려 글자가 두 번 바뀌며 깜빡였다. */
function _setStable(sel, txt, cls){
    var $e = $(sel); if(!$e.length) return;
    if($e.text() === txt && (cls == null || $e.attr('class') === cls)) return;
    $e.text(txt); if(cls != null) $e.attr('class', cls);
}
/* [2026-08-01] CGM 상태 안내 — 내용이 있을 때만 보인다.
   todayBlod() 가 진입 시 1회 + 외부 CGM 재수집 후 1회 더 불리므로, 같은 내용이면 DOM 을 안 건드린다(깜빡임 방지). */
function _setCgmNotice(html){
    var $e = $("#errormsg"); if(!$e.length) return;
    html = html || "";
    if($e.data('cgmMsg') !== html){
        $e.data('cgmMsg', html).html(html);
    }
    $e.css('display', html ? 'block' : 'none');
}
/* [2026-08-05 검토회의 — 홈 혈당상태 기준 변경] '오늘 하루' → '오늘 기준 과거 일주일'.
   Case1(최근 일주일에 측정값 있음) : "오늘 기준 과거 일주일간 발생한 혈당지표 상태입니다."
   Case2(최근 일주일에 측정값 없음) : "<마지막 측정일> 이후 발생한 혈당 측정값이 없습니다
                                    (마지막 일주일 기준 상태입니다)"
     → Case2 는 마지막 측정일로 끝나는 일주일로 상태를 계산해 표시한다.
   상태 판정은 종전과 동일하게 TIR(70~180 mg/dL 범위 내 비율) 70% 기준. */
function _ymd(d){
    return d.getFullYear() + '-' + ('0'+(d.getMonth()+1)).slice(-2) + '-' + ('0'+d.getDate()).slice(-2);
}
/* 일주일(끝나는 날 포함 7일) 범위의 측정값을 받아 TIR 계산 → cb(tir 또는 null) */
function _weekTir(uid, endDate, cb){
    var start = new Date(endDate.getFullYear(), endDate.getMonth(), endDate.getDate());
    start.setDate(start.getDate() - 6);
    CommonUtil.callAjax(CommonUtil.getContextPath() + "/getBloodChartData.do","POST",
        { userId: uid, start: _ymd(start)+"T00:00:00", end: _ymd(endDate)+"T23:59:59" }, function(list){
            list = Array.isArray(list) ? list : [];
            var vals = [];
            list.forEach(function(r){
                var v = parseInt(r.UPT,10);
                if(!isNaN(v) && v > 0) vals.push(v);
            });
            if(!vals.length){ cb(null); return; }
            var inR = vals.filter(function(v){ return v >= 70 && v <= 180; }).length;
            cb(Math.round(inR * 100 / vals.length));
        });
}
function _paintBloodState(tir, tirTxt){
    _setStable('#bloodState', (tir>=70) ? "'정상'" : "'관리 필요'", (tir>=70) ? 'st-good' : 'st-warn');
    _setStable('#bloodTir', tirTxt);
}
function updateBloodState(data){
    var el = $("#bloodState");
    if(!el.length) return;
    var uid = (typeof userId !== 'undefined' && userId && userId !== "null") ? userId : "";
    if(!uid){
        _setStable('#bloodState', "측정값 없음", 'st-none');
        _setStable('#bloodTir', "혈당기(CGM) 측정값이 들어오면 상태가 표시됩니다");
        return;
    }
    // [2026-07-31 깜빡임 개선] 조회 전에는 초기 '확인 중'을 유지하고, 결과가 나온 뒤 한 번만 반영한다.
    _weekTir(uid, new Date(), function(tir){
        if(tir != null){   // Case1 — 최근 일주일에 측정값 있음
            _paintBloodState(tir, "오늘 기준 과거 일주일간 발생한 혈당지표 상태입니다.");
            return;
        }
        // Case2 — 최근 일주일에 측정값 없음 → 마지막 측정일 기준 일주일로 대체 표시
        CommonUtil.callAjax(CommonUtil.getContextPath() + "/getLastBloodDate.do","POST",{ userId: uid },function(res){
            if(!(res && res.IsSucceed && res.Data)){
                _setStable('#bloodState', "측정값 없음", 'st-none');
                _setStable('#bloodTir', "혈당기(CGM) 측정값이 들어오면 상태가 표시됩니다");
                return;
            }
            var day  = String(res.Data).substring(0,10);                       // 'YYYY-MM-DD'
            var parts = day.split('-');
            var lastD = new Date(+parts[0], +parts[1]-1, +parts[2]);
            var msg   = day + " 이후 발생한 혈당 측정값이 없습니다 (마지막 일주일 기준 상태입니다)";
            _weekTir(uid, lastD, function(lastTir){
                if(lastTir == null){
                    _setStable('#bloodState', "측정값 없음", 'st-none');
                    _setStable('#bloodTir', msg);
                    return;
                }
                _paintBloodState(lastTir, msg);
            });
        });
    });
}
function todayBlod() {
    CommonUtil.callAjax(CommonUtil.getContextPath() + "/getTodayBlood.do", "POST", '', function(response) {
        console.log(response);
        const data = response.Data;
        updateBloodState(data);   // [메인 개편] 혈당상태(TIR) 카드 갱신

        if (data && data.length > 0) {
            $("#formatedDate").text(data[0].formatedDate);
            $("#nowVal").text(data[0].UPT_VALUE);

            if (data.length > 1) {
                const diff = data[0].UPT_VALUE - data[1].UPT_VALUE;
                $("#diff").text(diff);
            } else {
                $("#diff").text(0);
            }

            // [2026-07-11] 값이 0일 때: 연동(토큰) 상태로 안내 구분 (연동됨 → 센서착용 / 미연동 → 연동필요)
            _setCgmNotice(data[0].UPT_VALUE == 0
                ? (window.__hasToken
                    ? "혈당기(CGM)를 착용하면 측정값이 표시됩니다"
                    : "케어센서 에어(i-Sens) 연동이 필요합니다.<br/>연속혈당 메뉴에서 로그인해 주세요.")
                : "");

        } else {
            $("#formatedDate").text("-");
            $("#nowVal").text(0);
            $("#diff").text(0);

            // [2026-07-11] 데이터 없음: 연동됨이면 센서착용 안내, 미연동이면 연동필요 안내 (오표시 '로그인 해주세요' 방지)
            _setCgmNotice(window.__hasToken
                ? "혈당기(CGM)를 착용하면 측정값이 표시됩니다"
                : "케어센서 에어(i-Sens) 연동이 필요합니다.<br/>연속혈당 메뉴에서 로그인해 주세요.");
        }
    });
}

function todayBlodAvg(){
	CommonUtil.callAjax(CommonUtil.getContextPath() + "/getTodayBlodAvg.do","POST",'',function(response){
		console.log(response);
		const data = response.Data;
		$("#fastBlod").text(parseInt(data.fastBlod));
		$("#mealBlod").text(parseInt(data.mealBlod));
	});
}
//당일 운동총시간 
function todayExecs() {
    CommonUtil.callAjax(
        CommonUtil.getContextPath() + "/getTodaysumExecs.do",
        "POST",
        {},  // 빈 요청 본문
        function(response) {
            console.log(response);

            var exerName = "";

            if (response && response.Data && Array.isArray(response.Data) && response.Data.length > 0 &&
                response.Data[0] && response.Data[0].minutes != null
            ) {
                exerName = response.Data[0].minutes + "분";
            }

            $("#execsNow").text(exerName);
        }
    );
}
//당일 시작 총칼로리  
function todayFood(){
	const date = new Date();
	const formattedDate = date.toISOString().split('T')[0].replace(/-/g, '');  

	const data = { start: formattedDate };

    CommonUtil.callAjax(CommonUtil.getContextPath() + "/getTodaysumFood.do", "POST", data, function(response){
        console.log(response);
        var stanCal = "";

        if (response && response.Data && Array.isArray(response.Data) && response.Data.length > 0 &&
            response.Data[0] && response.Data[0].kCal != null
        ) {
        	stanCal = response.Data[0].kCal ;
        }

        $("#stanCal").text(stanCal);
    });
}

</script>

