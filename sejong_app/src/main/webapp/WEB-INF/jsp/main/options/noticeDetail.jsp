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
        <div class="boardView">
          <div class="head">
            <p class="title">${noti.title }</p>
            <p class="date">${noti.regDtm }</p>
          </div>
          <div class="cont">
            <!-- <img src="../asset/images/_temp/@img_news.png" alt="" /> -->
            <p class="text">
              ${noti.expln }
            </p>
          </div>
          <div class="btnArea tar">
            <a href="<c:url value='noticePage.do'/> " class="btn btnLine01"><span>목록</span></a>
          </div>
        </div>
      </div>
    </div>
    <!-- contents : e -->