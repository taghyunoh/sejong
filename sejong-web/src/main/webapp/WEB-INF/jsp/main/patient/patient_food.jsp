<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<link href="/bootstrap/css/bootstrap.css" rel="stylesheet">
<link href="/asset/css/common.css" rel="stylesheet">
<title>식사 기록 — ${sessionScope.userNm}</title>
<!-- jQuery 먼저 로드 후 main.js (main.js 가 jQuery 의존) -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<script src="/bootstrap/js/bootstrap.bundle.js"></script>
<script src="/asset/js/commonUtil.js"></script>
<script>
  sessionStorage.setItem("contextPath", '<c:out value="${pageContext.request.contextPath}"/>');
</script>
<style>
  body { background:#f8f9fa; }
  .card-tile { background:#fff; border-radius:8px; padding:16px; margin-bottom:12px; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
</style>
<script>
var userUuid = "${sessionScope.userUuid}";
$(function(){
	var t = new Date();
	$("#eatDate").val(t.toISOString().substring(0,10));
	$("#eatStime").val(pad(t.getHours())+pad(t.getMinutes())+"00");
	loadFoodList();
});
function pad(n){ return (n<10?'0':'')+n; }

function saveFood(){
	var dto = {
		userUuid: userUuid,
		eatDate:  $("#eatDate").val(),
		eatStime: $("#eatStime").val(),
		eatEtime: $("#eatEtime").val(),
		foodName: $.trim($("#foodName").val()),
		foodDanwi:$.trim($("#foodDanwi").val()),
		foodAcnt: $.trim($("#foodAcnt").val())
	};
	if (!dto.foodName) { alert("음식명을 입력하세요."); return; }
	if (!dto.eatStime || dto.eatStime.length !== 6) { alert("시작시간(HHMMSS 6자리)을 입력하세요."); return; }
	$.ajax({
		url: CommonUtil.getContextPath() + "/updateFood.do",
		type:"post",
		data: $.param(dto),
		dataType:"json",
		success:function(r){
			alert(r.IsSucceed ? "저장 완료" : "저장 실패");
			if (r.IsSucceed) { $("#foodName").val(""); loadFoodList(); }
		}
	});
}

function loadFoodList(){
	var d = $("#eatDate").val().replace(/-/g,'');
	$.ajax({
		url: CommonUtil.getContextPath() + "/getFoodInfo.do",
		type:"post",
		data: JSON.stringify({ userUuid: userUuid, eatDate: d }),
		contentType:"application/json",
		dataType:"json",
		success:function(r){
			var rows = r && r.Data ? r.Data : [];
			if (rows.length === 0) {
				$("#foodList").html('<tr><td colspan="3" class="text-muted text-center">기록 없음</td></tr>');
				return;
			}
			var html = "";
			rows.forEach(function(row){
				html += "<tr><td>"+(row.eatStime||"")+"</td><td>"+(row.foodName||"")+"</td><td class='text-end'>"+(row.foodCnt||0)+"</td></tr>";
			});
			$("#foodList").html(html);
		}
	});
}

function back(){ location.href = CommonUtil.getContextPath() + "/main.do"; }
</script>
</head>
<body>
<div class="container py-4" style="max-width:720px;">
	<div class="d-flex justify-content-between align-items-center mb-3">
		<h3>🍱 식사 기록</h3>
		<button class="btn btn-outline-secondary btn-sm" onclick="back();">← 대시보드</button>
	</div>

	<div class="card-tile">
		<h5>새 기록</h5>
		<div class="row g-2">
			<div class="col-md-4"><label>식사일자</label><input type="date" id="eatDate" class="form-control" onchange="loadFoodList();"></div>
			<div class="col-md-4"><label>시작시간 (HHMMSS)</label><input type="text" id="eatStime" class="form-control" placeholder="120000" maxlength="6"></div>
			<div class="col-md-4"><label>종료시간 (선택)</label><input type="text" id="eatEtime" class="form-control" placeholder="123000" maxlength="6"></div>
			<div class="col-md-6"><label>음식명</label><input type="text" id="foodName" class="form-control" placeholder="예: 김치찌개"></div>
			<div class="col-md-3"><label>단위</label><input type="text" id="foodDanwi" class="form-control" placeholder="공기 / g / 개"></div>
			<div class="col-md-3"><label>개수(실제)</label><input type="text" id="foodAcnt" class="form-control" placeholder="1"></div>
		</div>
		<div class="text-end mt-3">
			<button class="btn btn-primary" onclick="saveFood();">저장</button>
		</div>
	</div>

	<div class="card-tile">
		<h5>오늘의 기록</h5>
		<table class="table table-sm">
			<thead><tr><th>시간</th><th>음식</th><th class="text-end">개수</th></tr></thead>
			<tbody id="foodList"><tr><td colspan="3" class="text-muted text-center">불러오는 중...</td></tr></tbody>
		</table>
	</div>
</div>
</body>
</html>
