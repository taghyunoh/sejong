<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<link href="/bootstrap/css/bootstrap.css" rel="stylesheet">
<link href="/asset/css/common.css" rel="stylesheet">
<title>운동 기록 — ${sessionScope.userNm}</title>
<!-- jQuery + commonUtil 필수 -->
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
	$("#exerDate").val(t.toISOString().substring(0,10));
	$("#exerStime").val(pad(t.getHours())+pad(t.getMinutes())+"00");
	loadExerList();
});
function pad(n){ return (n<10?'0':'')+n; }

function saveExer(){
	var dto = {
		userUuid:  userUuid,
		exerDate:  $("#exerDate").val(),
		exerStime: $("#exerStime").val(),
		exerEtime: $("#exerEtime").val(),
		exerName:  $.trim($("#exerName").val()),
		exerInt:   $("#exerInt").val(),
		exerCnt:   $("#exerCnt").val() ? parseInt($("#exerCnt").val(),10) : 0
	};
	if (!dto.exerName) { alert("운동명을 입력하세요."); return; }
	if (!dto.exerStime || dto.exerStime.length !== 6) { alert("시작시간(HHMMSS 6자리)을 입력하세요."); return; }
	$.ajax({
		url: CommonUtil.getContextPath() + "/updateExer.do",
		type:"post",
		data: $.param(dto),
		dataType:"json",
		success:function(r){
			alert(r.IsSucceed ? "저장 완료" : "저장 실패");
			if (r.IsSucceed) { $("#exerName").val(""); loadExerList(); }
		}
	});
}

function loadExerList(){
	var d = $("#exerDate").val().replace(/-/g,'');
	$.ajax({
		url: CommonUtil.getContextPath() + "/getExerInfo.do",
		type:"post",
		data: JSON.stringify({ userUuid: userUuid, exerDate: d }),
		contentType:"application/json",
		dataType:"json",
		success:function(r){
			var rows = r && r.Data ? r.Data : [];
			if (rows.length === 0) {
				$("#exerList").html('<tr><td colspan="3" class="text-muted text-center">기록 없음</td></tr>');
				return;
			}
			var html = "";
			rows.forEach(function(row){
				html += "<tr><td>"+(row.exerStime||"")+"</td><td>"+(row.exerName||"")+"</td><td class='text-end'>"+(row.totalCnt||0)+"</td></tr>";
			});
			$("#exerList").html(html);
		}
	});
}

function back(){ location.href = CommonUtil.getContextPath() + "/main.do"; }
</script>
</head>
<body>
<div class="container py-4" style="max-width:720px;">
	<div class="d-flex justify-content-between align-items-center mb-3">
		<h3>🏃 운동 기록</h3>
		<button class="btn btn-outline-secondary btn-sm" onclick="back();">← 대시보드</button>
	</div>

	<div class="card-tile">
		<h5>새 기록</h5>
		<div class="row g-2">
			<div class="col-md-4"><label>운동일자</label><input type="date" id="exerDate" class="form-control" onchange="loadExerList();"></div>
			<div class="col-md-4"><label>시작시간 (HHMMSS)</label><input type="text" id="exerStime" class="form-control" placeholder="180000" maxlength="6"></div>
			<div class="col-md-4"><label>종료시간 (선택)</label><input type="text" id="exerEtime" class="form-control" placeholder="183000" maxlength="6"></div>
			<div class="col-md-6"><label>운동명</label><input type="text" id="exerName" class="form-control" placeholder="예: 산책"></div>
			<div class="col-md-3">
				<label>강도</label>
				<select id="exerInt" class="form-select">
					<option value="">선택</option>
					<option value="L">약함</option>
					<option value="M" selected>보통</option>
					<option value="H">강함</option>
				</select>
			</div>
			<div class="col-md-3"><label>걸음수/횟수</label><input type="text" id="exerCnt" class="form-control" placeholder="3000" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"></div>
		</div>
		<div class="text-end mt-3">
			<button class="btn btn-primary" onclick="saveExer();">저장</button>
		</div>
	</div>

	<div class="card-tile">
		<h5>오늘의 기록</h5>
		<table class="table table-sm">
			<thead><tr><th>시간</th><th>운동</th><th class="text-end">횟수</th></tr></thead>
			<tbody id="exerList"><tr><td colspan="3" class="text-muted text-center">불러오는 중...</td></tr></tbody>
		</table>
	</div>
</div>
</body>
</html>
