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
     <div class="lyInner">
       <a href="javascript:layerPop('open' , 'infoChangePopup')" class="btn btnCol01"><span>의료정보변경</span></a>
     </div>
     <!-- <div class="lyInner">
        <a href="javascript:layerPop('open' , 'changePopup')" class="btn btnCol01"><span>비밀번호변경</span></a>
      </div> -->
</div>
<!-- contents : e -->


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
              <div class="inputWrap"><input type="text" class="inpText" id="height" value="" disabled><span
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
              <div class="radioWrap typeBox02">
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
                  <label for="rdo_sugar03">임신성 당뇨병</label>
                </span>
                <span class="inputRadio">
                  <input type="radio" name="rdo_sugar" id="rdo_sugar04" value="4">
                  <label for="rdo_sugar04">당뇨병 전단계</label>
                </span>
                <span class="inputRadio">
                  <input type="radio" name="rdo_sugar" id="rdo_sugar05" value="5">
                  <label for="rdo_sugar05">고위험군/고령: <br /> 1형당뇨병</label>
                </span>
                <span class="inputRadio">
                  <input type="radio" name="rdo_sugar" id="rdo_sugar06" value="6">
                  <label for="rdo_sugar06">고위험군/고령: 2형당뇨병</label>
                </span>
                <span class="inputRadio">
                  <input type="radio" name="rdo_sugar" id="rdo_sugar07" value="7">
                  <label for="rdo_sugar07">임신부: 1형당뇨병</label>
                </span>
                <span class="inputRadio">
                  <input type="radio" name="rdo_sugar" id="rdo_sugar08" value="8">
                  <label for="rdo_sugar08">임신부: 2형당뇨병</label>
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
  <!-- [레] : 의료정보변경 팝업 : e -->
  <!-- [레] : 비밀번호변경 팝업 : s -->
  <!-- <div class="popupWrap popupFull changePopup">
    <div class="popupContent popupInner">
      <div class="popupHead">
        <strong class="tit">비밀번호변경</strong>
        <a href="javascript:layerPop('close' , 'changePopup')" class="btnPopClose">레이어 닫기</a>
      </div>
      <div class="popupCont">
        내용 : s
        <div class="form">
          <dl class="formList">
            <dt><span class="vital">현재비밀번호</span></dt>
            <dd>
              <div class="inputWrap">
                <input type="password" class="inpText error" />
              </div>
              <p class="textMsg error">비밀번호를 입력해주세요.</p>
            </dd>
          </dl>
          <dl class="formList">
            <dt><span class="vital">변경할 비밀번호</span></dt>
            <dd>
              <div class="inputWrap">
                <input type="password" class="inpText" />
              </div>
            </dd>
          </dl>
          <dl class="formList">
            <dt><span class="vital">변경할 비밀번호 확인</span></dt>
            <dd>
              <div class="inputWrap">
                <input type="password" class="inpText" />
              </div>
            </dd>
          </dl>
        </div>
        내용 : e
      </div>
      <div class="buttonFixed">
        <div class="btnArea fix">
          <a href="#" class="btn btnCol01"><span>취소</span></a>
          <a href="#" class="btn btnCol02"><span>확인</span></a>
        </div>
      </div>
    </div>
  </div> -->
  <!-- [레] : 비밀번호변경 팝업 : e -->

 <script>
$(document).ready(function(){
	getUserInfo();
});

function getUserInfo(){
	CommonUtil.callAjax(CommonUtil.getContextPath() + "/getUserInfo.do","POST",'',function(response){
		console.log(response.Data);
		const user = response.Data;
		$("#height").val(user.height);
		$("#weight").val(user.weight);
		$('input:radio[name=rdo_sugar]:input[value='+user.blodGb+']').attr("checked", true);
	});
}

function updateUserInfo(){
	const data = {};
	data.weight = $("#weight").val();
	data.blodGb = $('input[name=rdo_sugar]:checked').val();
	CommonUtil.callAjax(CommonUtil.getContextPath() + "/updateUserInfo.do","POST",data,function(response){
		console.log(response.Data);
		alert("개인정보 설정 완료");
		window.location.reload();
	});
}
 </script>