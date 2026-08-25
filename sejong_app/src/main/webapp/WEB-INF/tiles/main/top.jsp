<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<header class="header">
      <div class="alignLeft">
        <a href="#" class="btnPrev" onclick="btnPrev();"><span>이전 페이지로 이동</span></a>
      </div>
      <div class="alignTitle">
        <h1>${menuName }</h1>
      </div>
      <div class="menuWrap">

        <div class="topArea">
          <div class="user util" onclick="javascript:">
          <div class="name"><strong id="subName"></strong><span>님</span>
            <div class="item notice">
              알림<span class="">새로운 알림</span>
            </div>
          </div>
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
             1:1문의(asqMain.do)는 기획안대로 제외. login/main.jsp 에도 같은 메뉴가 있다 — 바꿀 때 둘 다 고칠 것. --%>
        <div class="etc_menu_list etc_links">
          <a class="etc_link" href="<c:url value='noticePage.do'/> ">&gt; 공지사항 바로가기</a>
          <a class="etc_link" href="<c:url value='faqPage.do'/> ">&gt; 자주하는 질문 바로가기</a>
          <a class="etc_link" href="javascript:layerPop('open' , 'infoChangePopup')">&gt; 개인정보 변경 바로가기</a>
          <a class="etc_link" href="<c:url value='settingPage.do'/> ">&gt; 설정 바로가기</a>
        </div>
      </div>
    </div>

    <div class="alignRight">
      <a href="#" class="btnMenu"><span>메뉴</span></a>
    </div>
  </header>
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

          <%-- ★[2026-08-25 요청] 생년월일·나이 (홈 main.jsp 의 같은 팝업과 동일하게) --%>
          <dl class="formList">
            <dt><span>생년월일</span></dt>
            <dd>
              <div class="inputWrap">
                <input type="text" class="inpText" id="birthYmd" value="" maxlength="8" inputmode="numeric"
                       placeholder="8자리 예) 19631126"
                       oninput="this.value=this.value.replace(/[^0-9]/g,''); _showAge();">
                <span class="add_inf" id="ageTxt"></span>
              </div>
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
<script>
$(document).ready(function() {
	var userNm = '<%=session.getAttribute("userNm")%>';
	if(userNm == null){
		location.href = CommonUtil.getContextPath() + "/loginPage.do";
	} 
	$("#subName").text(userNm);
});
function btnPrev(){
	window.history.back();
}
</script>
<script>
$(document).ready(function(){
	getUserInfo();
});

/* ★[2026-08-25] 생년월일 8자리 → 만 나이 (홈 main.jsp 와 같은 함수) */
function _calcAge(ymd){
	if(!/^\d{8}$/.test(ymd || "")) return null;
	var y = +ymd.substr(0,4), m = +ymd.substr(4,2), d = +ymd.substr(6,2);
	if(m < 1 || m > 12 || d < 1 || d > 31) return null;
	var t = new Date(), age = t.getFullYear() - y;
	if((t.getMonth()+1) < m || ((t.getMonth()+1) === m && t.getDate() < d)) age--;
	return (age >= 0 && age < 130) ? age : null;
}
function _showAge(){
	var a = _calcAge($("#birthYmd").val().trim());
	$("#ageTxt").text(a == null ? "" : a + "세");
}
function getUserInfo(){
	CommonUtil.callAjax(CommonUtil.getContextPath() + "/getUserInfo.do","POST",'',function(response){
		console.log(response.Data);
		const user = response.Data;
		$("#height").val(user.height);
		$("#weight").val(user.weight);
		$("#birthYmd").val(user.birth || "");   // [2026-08-25]
		_showAge();
		$('input:radio[name=rdo_sugar]:input[value='+user.blodGb+']').attr("checked", true);
	});
}

function updateUserInfo(){
	const data = {};
	data.height = $("#height").val();
	data.weight = $("#weight").val();
	const _b = $("#birthYmd").val().trim();   // [2026-08-25] 비우면 안 보낸다(서버가 기존 값 유지)
	if(_b !== "" && _calcAge(_b) == null){
		alert("생년월일을 8자리로 정확히 입력해 주세요. 예) 19631126");
		$("#birthYmd").focus();
		return;
	}
	data.birth = _b;
	data.blodGb = $('input[name=rdo_sugar]:checked').val();
	CommonUtil.callAjax(CommonUtil.getContextPath() + "/updateUserInfo.do","POST",data,function(response){
		console.log(response.Data);
		alert("개인정보 설정 완료");
		javascript:layerPop('close' , 'infoChangePopup');
		getUserInfo();
	});
}
 </script>