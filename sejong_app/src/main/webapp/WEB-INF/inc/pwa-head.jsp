<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%-- [PWA] 매니페스트 / 아이콘 / 테마색 / 서비스워커 등록.
     모든 페이지 <head> 에서 static include 로 삽입한다:
       <%@ include file="/WEB-INF/inc/pwa-head.jsp" %>
     경로는 루트(/) 배포 기준의 절대경로. --%>
<link rel="manifest" href="${pageContext.request.contextPath}/manifest.webmanifest">
<meta name="theme-color" content="#005b8e">
<link rel="icon" type="image/png" sizes="192x192" href="${pageContext.request.contextPath}/asset/images/pwa/icon-192.png">
<link rel="apple-touch-icon" href="${pageContext.request.contextPath}/asset/images/pwa/apple-touch-icon.png">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="default">
<meta name="apple-mobile-web-app-title" content="allCare">
<script>
  // 서비스워커 등록 (https 또는 localhost 에서만 동작)
  // 컨텍스트 경로(/app 등) 아래 배포이므로 scope 도 컨텍스트로 제한한다.
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', function () {
      navigator.serviceWorker.register('${pageContext.request.contextPath}/sw.js', { scope: '${pageContext.request.contextPath}/' })
        .catch(function (e) { console.warn('SW 등록 실패:', e); });
    });
  }
</script>
