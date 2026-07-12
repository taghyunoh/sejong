<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%
    // 현재 페이지가 속한 섹션에 따라 하단탭 선택표시(class="on") 부여.
    // ※ Tiles include 안에서는 request.getRequestURI() 가 원래 .do 가 아니라 템플릿 경로로 잡힐 수 있어,
    //   컨트롤러가 넣어주는 menuName 를 1순위로 사용하고 URI 는 보조로만 쓴다.
    String menu = (String) request.getAttribute("menuName");
    if (menu == null) menu = (String) session.getAttribute("menuName");
    if (menu == null) menu = "";
    String uri = request.getRequestURI();
    String u = (uri == null) ? "" : uri.toLowerCase();

    // 우선순위 중요: '식사연관 혈당분석'/'운동연관 혈당분석' 처럼 이름에 '혈당'이 겹치므로
    // 운동 → 식사 → 혈당 순으로 판정한다.
    String onHome = "", onBlood = "", onFood = "", onExer = "";
    if (menu.contains("운동") || u.contains("exer")) {
        onExer = "on";
    } else if (menu.contains("식사") || u.contains("food")) {
        onFood = "on";
    } else if (menu.contains("혈당") || u.contains("blood") || u.contains("fahr")) {
        onBlood = "on";
    } else if (u.contains("mainpage")) {
        onHome = "on";
    }
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
