<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="tiles" uri="http://tiles.apache.org/tags-tiles"%>
<head>
<%-- [2026-08-25] viewport-fit=cover 는 쓰지 않는다 — 앱이 하단 네비게이션 바를 덮는다(main.jsp 주석 참고) --%>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<tiles:insertAttribute name="header" />
</head>
<body>
	<div id="wrap" class="wrap">
		<div id="header">
		</div>
		<div id="contents">
		<tiles:insertAttribute name="content" />	
		<%-- <tiles:insertAttribute name="foot" /> --%>
		</div>
	</div>
</body>

<script>

</script>