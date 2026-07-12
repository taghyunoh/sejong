<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%
    String uri = request.getRequestURI();
    String contextPath = request.getContextPath();
    String currentPage = uri.substring(contextPath.length());
    // 현재 페이지가 속한 섹션에 따라 하단탭 선택표시(class="on") 부여
    String p = currentPage.toLowerCase();
    String onHome  = p.contains("mainpage") ? "on" : "";
    String onBlood = (p.contains("blood") || p.contains("fahr")) ? "on" : "";
    String onFood  = p.contains("food") ? "on" : "";
    String onExer  = p.contains("exer") ? "on" : "";
%>
<!-- footer Nav : s -->
<nav class="footerNav">
  <ul>
       <li>
         <a href="<c:url value='/mainPage.do'/> " class="<%= onHome %>">
           <img src="<c:url value='/asset/images/blood/icon_home.png'/> " alt="">
           <span>홈</span>
         </a>
       </li>
       <li>
         <a href="<c:url value='/goBloodPage.do'/> " class="<%= onBlood %>">
           <img src="<c:url value='/asset/images/blood/icon_blood.png'/> " alt="">
           <span>연속혈당</span>
         </a>
       </li>
		<!-- 식사화면일 때 → 운동등록 메뉴 강조 -->
	   <li>
		 <a href="<c:url value='/foodMain.do'/>" class="<%= onFood %>">
		   <img src="<c:url value='/asset/images/blood/icon_food.png'/>" alt="">
		    <span>식사등록</span>
		 </a>
	   </li>
 	   <li>
	     <a href="<c:url value='/exerMain.do'/>" class="<%= onExer %>">
	       <img src="<c:url value='/asset/images/fit/footer.png'/>" alt="">
	       <span>운동등록</span>
	     </a>
	   </li>
  </ul>
</nav>
<!-- footer Nav : e -->
