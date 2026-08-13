<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%--
  welcome-file(web.xml). 컨텍스트 루트로 들어온 요청을 정식 진입점으로 넘긴다.
    운영 https://allcare24.kr/app/  ·  로컬 http://localhost:9060/

  index.do 가 세션을 보고 갈 곳을 정한다 — 로그인 상태면 mainPage.do, 아니면 loginPage.do.

  [2026-08-13] 종전에는 여기에 옛 로그인 화면(ID/PW 입력폼)이 그대로 있었다.
    실제 로그인은 휴대폰 인증 방식(loginPage.do)으로 바뀐 지 오래고,
    이 파일이 참조하던 /css/login.css · /js/jquery-3.5.1.min.js 는 이 앱에 없는 파일이라
    운영(컨텍스트 /app)에서는 루트의 다른 앱(sejong-web) 것을 주워 쓰거나 404 였다.
    → 화면을 지우고 진입로만 남긴다. 주소를 북마크해 둔 사용자도 그대로 들어온다.

  ※ PWA 시작 주소는 manifest.webmanifest 의 start_url(loginPage.do) 이라 이 파일과 무관하다.
--%><%
    response.sendRedirect(request.getContextPath() + "/index.do");
%>
