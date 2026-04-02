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
      <ul class="swipeTab">
        <li><a href="#" class="anchor on">전체</a></li>
        <li><a href="#" class="anchor">연속혈당</a></li>
        <li><a href="#" class="anchor">식사촬영</a></li>
        <li><a href="#" class="anchor">운동</a></li>
        <li><a href="#" class="anchor">회원정보</a></li>
      </ul>
      <div class="lyInner">
        <p class="filterTxt">전체 (12개)</p>
        <div class="boxHorizontal mb30">
          <div class="inputWrap">
            <input type="text" class="inpText" placeholder="검색어를 입력하세요." value="">
          </div>
          <div class="btnArea mt0">
            <a href="#" class="btn btnCol02"><span>검색</span></a>
          </div>
        </div>
        <div class="accordionList">
          <ul>
            <li class="cardItem faq">
              <a href="#" class="accordionAnchor">
                <p class="category">Android</p>
                <p class="question">앱 일시 중지 기능을 종료하고 싶습니다.</p>
              </a>
              <div class="cont">
                <div class="answer">
                  Android 10 이상에서 일시 중지는 앱을 일시적으로 비활성화합니다. 일시중지 상태에서는 알림이 오지 않으며 앱을 실행하면 다시 정상적으로 동작합니다. 일시 중지를 해제하려면 앱을
                  실행하거나 설정에서 일시 중지를 해제할 수 있습니다. 일시 중지를 해제하면 앱이 다시 정상적으로 동작합니다. 일시 중지를 종료하는 방법은 다음과 같습니다. 1. 앱을 실행합니다. 2.
                  설정 > 앱 > allCare > 일시 중지를 해제합니다.
                </div>
              </div>
            </li>
            <li class="cardItem faq">
              <a href="#" class="accordionAnchor">
                <p class="category">알림</p>
                <p class="question">앱 일시 중지 기능을 종료하고 싶습니다.</p>
              </a>
              <div class="cont">
                <div class="answer">
                  Android 10 이상에서 일시 중지는 앱을 일시적으로 비활성화합니다. 일시중지 상태에서는 알림이 오지 않으며 앱을 실행하면 다시 정상적으로 동작합니다. 일시 중지를 해제하려면 앱을
                  실행하거나 설정에서 일시 중지를 해제할 수 있습니다. 일시 중지를 해제하면 앱이 다시 정상적으로 동작합니다. 일시 중지를 종료하는 방법은 다음과 같습니다. 1. 앱을 실행합니다. 2.
                  설정 > 앱 > allCare > 일시 중지를 해제합니다.
                </div>
              </div>
            </li>
            <li class="cardItem faq">
              <a href="#" class="accordionAnchor">
                <p class="category">기타</p>
                <p class="question">앱 일시 중지 기능을 종료하고 싶습니다.</p>
              </a>
              <div class="cont">
                <div class="answer">
                  Android 10 이상에서 일시 중지는 앱을 일시적으로 비활성화합니다. 일시중지 상태에서는 알림이 오지 않으며 앱을 실행하면 다시 정상적으로 동작합니다. 일시 중지를 해제하려면 앱을
                  실행하거나 설정에서 일시 중지를 해제할 수 있습니다. 일시 중지를 해제하면 앱이 다시 정상적으로 동작합니다. 일시 중지를 종료하는 방법은 다음과 같습니다. 1. 앱을 실행합니다. 2.
                  설정 > 앱 > allCare > 일시 중지를 해제합니다.
                </div>
              </div>
            </li>

          </ul>
        </div>
        <div class="btnArea tac">
          <a href="#" class="btn btnMore">더보기 ( <em>1</em> / 10 )</a>
        </div>
      </div>
    </div>
    <!-- contents : e -->