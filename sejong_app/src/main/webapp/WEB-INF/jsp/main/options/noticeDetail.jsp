<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
	Date nowTime = new Date();
	SimpleDateFormat sf = new SimpleDateFormat("yyyyMMdd");
%>
<style>
  /* [2026-09-22] 관리자(sejong_web)가 textarea 로 입력한 줄바꿈(\n)이 HTML 에서 공백으로 뭉개져
     번호 목록이 한 문단으로 붙어 보였다. pre-line = \n 은 줄바꿈으로 살리고 연속 공백은 접는다.
     (<br> 치환 대신 CSS 로 푼 이유 — 값이 이스케이프 없이 나가는 자리라 마크업 가공을 늘리지 않는다) */
  .boardView .cont .text { white-space: pre-line; }
</style>
<!-- contents : s -->
    <div class="contents">
      <div class="lyInner">
        <div class="boardView">
          <div class="head">
            <p class="title">${noti.title }</p>
            <p class="date">${noti.regDtm }</p>
          </div>
          <div class="cont">
            <!-- <img src="../asset/images/_temp/@img_news.png" alt="" /> -->
            <%-- ⚠pre-line 이라 태그 안 들여쓰기 개행도 빈 줄로 보인다 — expln 을 태그에 붙여 쓸 것 --%>
            <p class="text">${noti.expln}</p>
          </div>
          <div class="btnArea tar">
            <a href="<c:url value='noticePage.do'/> " class="btn btnLine01"><span>목록</span></a>
          </div>
        </div>
      </div>
    </div>
    <!-- contents : e -->