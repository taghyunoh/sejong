<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Date nowTime = new Date();
    SimpleDateFormat sfDate = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat sfTime = new SimpleDateFormat("HH:mm");
    String todayDate  = sfDate.format(nowTime);

    Calendar cal = Calendar.getInstance();
    cal.setTime(nowTime);
    cal.add(Calendar.HOUR_OF_DAY, -1);
    Date preTime = cal.getTime();
    String preTimeStr = sfTime.format(preTime);

    String nowTimeStr = sfTime.format(nowTime);
    String endDate    = sfDate.format(nowTime);

    cal.setTime(nowTime);
    cal.add(Calendar.DATE, -6);
    String startDate = sfDate.format(cal.getTime());
%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>운동 기록</title>
  <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.7/main.min.css" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
  <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.7/main.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
  <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
  <link href="/asset/css/comm_style.css?v=123" rel="stylesheet">
  <link href="/asset/css/asq_style.css?v=123" rel="stylesheet">

<style>
/* 안내 박스 */
.notice-box {
  background-color: #f0f0f0;
  border-radius: 10px;
  padding: 12px;
  font-size: 14px;
  line-height: 1.5;
  color: #333;
  margin-bottom: 10px;
}

/* 등록 테이블 */
.asq-table { width: 100%; table-layout: fixed; border-collapse: collapse; }
.asq-table th:first-child, .asq-table td:first-child { width: 80%; }
.asq-table th:last-child,  .asq-table td:last-child  { width: 20%; }
.asq-table td, .asq-table th {
  text-align: left; padding: 10px;
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}

/* 카드 공통 */
.asq-item {
  border: 1px solid #ccc; margin-bottom: 8px; border-radius: 5px;
  background: #fff !important; color: #000 !important;
}

/* 질문 요약 바 (화살표 분리 고정 버전) */
.asq-question {
  position: relative;
  cursor: pointer;
  font-weight: bold;
  display: block;
  padding: 11px 40px 11px 11px;  /* 오른쪽 공간 확보 */
  background: #fff !important;
  color: #000 !important;
  border-bottom: 1px solid #ccc;
  line-height: 1.3;
}

.asq-question .title {
  display: block;
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
  min-width: 0;
}
.asq-question .arrow {
  position: absolute;
  top: 0; right: 0;
  width: 36px;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  border-left: 1px solid #e5e5e5;
  font-size: 16px;
  pointer-events: auto;
}

/* 답변 바깥 래퍼 */
.asq-answer {
  padding: 10px; background: #fff !important; color: #000 !important;
  display: none; overflow: visible;
}

/* 질문 제목(답변 상단) */
.asq-qhead { white-space: pre-wrap; font-weight: 600; margin-bottom: 8px; }

/* 질문+답변 스크롤 */
.asq-answer .asq-scroll {
  max-height: 150vh;
  overflow: auto;
  padding: 8px 0;
  box-sizing: border-box;
}

/* 상위에서 스크롤 제한하지 않도록 */
.asq-item, #asqhisList { overflow: visible; }

/* Summernote 내용 영역 */
.note-editor .note-editable {
  background: #fff !important; color: #000 !important;
  font-size: 14px !important; white-space: pre-wrap;
  overflow: visible !important; max-height: none !important;
}

/* 자잘한 UI */
#historyTab { margin-left: -9px; background:#fff !important; color:#000 !important; }
.btn-small { height: 30px; font-size: 13px; padding: 2px 8px; }
.label-bold { font-weight: bold; }

/* 펼쳤을 때 제목에 밑줄 */
.asq-item.active .asq-qhead {
  text-decoration: underline; text-decoration-thickness: 1px; text-underline-offset: 3px;
}

/* 에디터 영역 높이 자동 */
.note-editor {
  height: auto !important;
  max-height: none !important;
  overflow: visible !important;
  width: 100%;
}
.note-editor .note-editable {
  height: auto !important;
  max-height: none !important;
  overflow: visible !important;
  white-space: pre-wrap;
}

/* FAQ 답변 글자 크게 */
#asqhisList .answer {
  font-size: 0.9rem;
  line-height: 1.6;
}

/* 탭 메뉴 */
.tab-menu {
  display: flex;
  overflow-x: hidden;
  white-space: nowrap;
  position: fixed;
  top: 14px;
  left: 17px;
  width: 90%;
  z-index: 999;
}

/* 탭 내용 영역 */
.tab-content {
  display: none;
  max-height: 700px;
  overflow-y: auto;
}
.tab-content.active {
  display: block;
}

.btn-cancel {
  height: 30px;
  padding: 5px 10px;
  background-color: #ccc;
  font-size: 12px;
}

/* 밀집 모드 - 느슨하게 조정 */
.asq--dense .asq-item {
  margin-bottom: 10px; /* 기존 6px → 10px */
}

.asq--dense .asq-question {
  padding: 10px 36px 10px 12px; /* 기존보다 여유 있게 */
  font-size: 14px;              /* 글씨 조금 키움 */
  line-height: 1.5;             /* 줄 간격 넉넉하게 */
}
.asq--dense .asq-question .arrow {
  width: 32px;
  font-size: 15px;
}

/* 답변 글자 축소 */
.asq--dense #asqhisList .answer {
  font-size: 0.85rem;
}

@media (max-width: 480px) {
  .asq--dense .asq-question {
    padding-right: 50px; /* 기본 32px → 모바일은 50px 확보 */
  }
}
/* 앵커에 우측 화살표 영역 확보 */
#asqhisList .accordionAnchor {
  position: relative;
  display: block;
  padding: 11px 40px 11px 11px; /* 오른쪽 화살표 공간 */
  background: #fff;
  color: #000;
  text-decoration: none;
  border-bottom: 1px solid #ccc;
  line-height: 1.3;
}

/* 화살표: 텍스트와 완전 분리, 우측 끝 고정 */
#asqhisList .accordionAnchor .arrow {
  position: absolute;
  right: 10px;
  top: 50%;
  transform: translateY(-50%) rotate(0deg);
  transition: transform 0.2s ease;
  pointer-events: none; /* 클릭 방해 X */
  font-size: 14px;
}

/* 열림 상태 화살표 회전 */
#asqhisList li.cardItem.faq.active .accordionAnchor .arrow {
  transform: translateY(-50%) rotate(180deg);
}

/* 내용 영역 */
#asqhisList .cont {
  display: none;
  background: #fafafa;
  border-bottom: 1px solid #eee;
  padding: 12px 11px 14px 11px;
  line-height: 1.6;
}

</style>
</head>
<body>
<div class="contents">
  <div class="lyInner">
    <!-- 탭 -->
    <div class="tab-menu">
      <button class="tab-btn active" onclick="showTab(event, 'historyTab')">1:1문의이력</button>
      <button class="tab-btn"        onclick="showTab(event, 'inputTab')">1:1문의등록</button>
    </div>

    <!-- 등록 탭 -->
    <section id="inputTab" class="tab-content">
      <form id="asqForm">
        <input type="hidden" id="userUuid" value="${sessionScope.userUuid}">
        <div class="input-group" style="width:100%;">
          <div class="notice-box">
            진료와 관련된 부분은 제한 되며 진료시 의료진과<br>
            상담 하셔야 합니다. 실증 및 체험진행과 관련한<br>
            질문만 가능합니다.
          </div>
          <label for="qstnConts" class="label-bold">질문입력</label>
          <textarea id="qstnConts" name="qstnConts" rows="7"
            style="width:100%; font-size:16px; padding:10px; box-sizing:border-box; resize:none;" required></textarea>
        </div>
        <button type="button" onclick="saveAsq()" class="btn-small">등록</button>
      </form>

      <table class="asq-table">
        <thead><tr><th>질문내용</th><th>삭제</th></tr></thead>
        <tbody id="asqList"></tbody>
      </table>
    </section>

    <!-- 이력 탭 -->
    <section id="historyTab" class="tab-content active">
      <div class="input-group" style="width:100%;">
	        <button type="button" class="btn-small btn-cancel" style="visibility: hidden; height: 0px; padding: 0; font-size: 12px;">등록</button>
			<div class="lyInner">
			  <!-- FAQ 모달 -->
			  <div class="modal fade" id="faqModal" tabindex="-1" aria-labelledby="faqModalLabel" aria-hidden="true">
			    <div class="modal-dialog modal-lg modal-dialog-scrollable">
			      <div class="modal-content">
			        <div class="modal-header">
			          <h5 id="faqModalLabel" class="modal-title">질문목록</h5>

			        </div>
			         <div class="modal-body" style="max-height:700px;overflow-y:auto;">
			         <div id="asqhisList" class="accordionList"><ul></ul></div>
			       </div>
			      </div>
			    </div>
			  </div>
			</div>
       </div>
    </section>
    
  </div>  
</div>

<script>
let asqData = [];
const asqStore = new Map(); // key: asqSeq

function saveAsq() {
  const userUuidEl = document.getElementById("userUuid");
  const qstnTitlEl = document.getElementById("qstnTitl");
  const qstnContsEl = document.getElementById("qstnConts");
  if (!userUuidEl) { alert("userUuid 요소가 없습니다."); return; }

  const data = {
    userUuid:  userUuidEl.value || "",
    qstnTitl:  (qstnTitlEl?.value || "").trim(),
    qstnConts: (qstnContsEl?.value || "").trim()
  };
  if (!data.qstnConts) { alert("질문내용을 입력하세요."); return; }

  if (confirm("입력하시겠습니까?")) {
    $.ajax({
      url: "/updateAsq.do",
      type: "POST",
      contentType: "application/json",
      data: JSON.stringify([data]),
      success: function() {
        alert("질문내용이 저장되었습니다.");
        if (qstnContsEl) qstnContsEl.value = "";
        getAsqList();
      },
      error: function() { alert("시스템 오류입니다. 다시 입력하세요!"); }
    });
  }
}

function delAsq(asqSeq, rowElement) {
  const userUuidEl = document.getElementById("userUuid");
  if (!userUuidEl) { alert("userUuid 요소가 없습니다."); return; }
  const data = { userUuid: userUuidEl.value || "", asqSeq };

  $.ajax({
    url: "/deleteAsq.do",
    type: "POST",
    contentType: "application/json",
    data: JSON.stringify([data]),
    success: function() {
      alert("질문내용이 삭제되었습니다.");
      if (rowElement) rowElement.remove();
      getAsqList();
    },
    error: function() { alert("시스템 오류입니다. 다시 시도하세요!"); }
  });
}

function showTab(event, tabId) {
  document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
  document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
  document.getElementById(tabId)?.classList.add('active');
  event.target.classList.add('active');
  if (tabId === "historyTab") loadFaqData();
}

function getAsqList() {
  const userUuidEl = document.getElementById("userUuid");
  if (!userUuidEl) { alert("userUuid 요소가 없습니다."); return; }
  const param = { userUuid: userUuidEl.value || "" };

  fetch('/getAsqList.do', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(param)
  })
  .then(res => res.json())
  .then(result => {
    if (result?.IsSucceed) renderAsqList(result.Data || []);
    else { alert('질문내용을 불러오는 데 실패했습니다.'); renderAsqList([]); }
  })
  .catch(() => { alert('통신 오류가 발생했습니다.'); });
}

function renderAsqList(data) {
  const list = document.getElementById("asqList");
  if (!list) return;
  list.innerHTML = '';
  asqStore.clear();

  (data || []).forEach(item => {
    asqStore.set(item.asqSeq, item);
    const tr = document.createElement('tr');
    tr.dataset.asqSeq = item.asqSeq;

    const tdType = document.createElement('td');
    const name = (item.qstnConts || '').trim();
    if (name.length > 40) {
      tdType.textContent = name.substring(0, 40) + '…';
      tdType.title = name;
      tdType.classList.add("has-tooltip");
    } else {
      tdType.textContent = name || '(제목 없음)';
    }
    tdType.style.textAlign = "left";
    tdType.style.verticalAlign = "middle";

    const tdDelete = document.createElement('td');
    tdDelete.textContent = '🗑️';
    tdDelete.style.textAlign = 'center';
    tdDelete.style.verticalAlign = 'middle';
    tdDelete.style.cursor = 'pointer';
    tdDelete.title = '삭제';
    tdDelete.addEventListener('click', function (e) {
      e.stopPropagation();
      if (confirm(`${item.qstnTitl || '해당'} 질문내용을 삭제하시겠습니까?`)) {
        delAsq(item.asqSeq, this.closest('tr'));
      }
    });

    tr.addEventListener('click', function () {
      const seq = this.dataset.asqSeq;
      fillAsqDetail(asqStore.get(seq));
    });

    tr.appendChild(tdType);
    tr.appendChild(tdDelete);
    list.appendChild(tr);
  });
}

window.onload = function() {
  try {
    const stored = JSON.parse(localStorage.getItem("asqRecords"));
    if (Array.isArray(stored)) asqData = stored;
  } catch (e) {
    console.warn("로컬 기록 초기화됨:", e?.message);
    asqData = []; localStorage.removeItem("asqRecords");
  }
  const textarea = document.getElementById('qstnTitl');
  if (textarea) textarea.addEventListener('input', function () {
    this.style.height = 'auto'; this.style.height = this.scrollHeight + 'px';
  });
  loadFaqData();
  getAsqList();
};

const $qstnTitl  = document.getElementById('qstnTitl1');
const $qstnConts = document.getElementById('qstnConts1');
const $ansrConts = document.getElementById('ansrConts');

function fillAsqDetail(item) {
  if (!item || !$qstnTitl || !$qstnConts || !$ansrConts) return;
  $qstnTitl.value  = item.qstnTitl  ?? '';
  $qstnConts.value = item.qstnConts ?? '';
  $ansrConts.value = item.ansrConts ?? '';
  [$qstnTitl, $qstnConts, $ansrConts].forEach(ta => {
    ta.style.height = 'auto'; ta.style.height = (ta.scrollHeight) + 'px';
  });
  $qstnTitl.scrollIntoView({ behavior: 'smooth', block: 'center' });
}

//중복 호출 방지 플래그
let _faqLoading = false;
let _faqLoaded  = false;

function loadFaqData(force = false) {
  const userUuidEl = document.getElementById("userUuid");
  if (!userUuidEl) { alert("userUuid 요소가 없습니다."); return; }

  const param = { userUuid: userUuidEl.value || "" };	
  if (_faqLoading) return;
  if (_faqLoaded && !force) return;

  _faqLoading = true;

  // ✅ 모달 내부 리스트 컨테이너에 맞춤
  const $listRoot = $("#asqhisList > ul");
  if ($listRoot.length === 0) { _faqLoading = false; return; }

  $listRoot.html(`<li class="text-muted text-center">불러오는 중…</li>`);

  fetch('/getAsqList.do', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(param)
  })
  .then(r => { if (!r.ok) throw new Error("네트워크 응답에 문제가 있습니다."); return r.json(); })
  .then(result => {
    const ok = result?.error_code === "0" || result?.IsSucceed === true || result?.success === true;

    // ✅ 데이터 경로 유연 처리
    const list =
      Array.isArray(result?.data) ? result.data :
      Array.isArray(result?.Data) ? result.Data :
      Array.isArray(result?.result?.data) ? result.result.data : [];

    const escapeHtml = (str) =>
      String(str ?? "").replace(/[&<>"'`=\/]/g, s => ({
        '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;','/':'&#x2F;','`':'&#x60;','=':'&#x3D;'
      }[s] || s));
    const nl2br = (str) => escapeHtml(str).replace(/\r?\n/g, "<br>");

    if (!ok || list.length === 0) {
      $listRoot.html(`<li class="text-muted text-center">검색된 결과가 없습니다.</li>`);
      console.log("응답 원문:", result);
      _faqLoaded = true; // 빈 결과라도 다시 불필요 호출 방지
      return;
    }

    $listRoot.empty();

    list.forEach((asq, i) => {
      const question = (
        asq?.QSTN_CONTS ?? asq?.qstnConts ?? asq?.question ?? "질문이 없습니다."
      ).toString().trim();

      const answer = (
        asq?.ANSR_CONTS ?? asq?.ansrConts ?? asq?.answer ?? "답변이 없습니다."
      ).toString().trim();

      // 카테고리(옵션): 백엔드에 따라 다양하게 대응, 없으면 "질문"
      const category =
        asq?.CATEGORY ?? asq?.category ?? asq?.cate ?? asq?.cat ??
        asq?.categoryName ?? asq?.ctgryNm ?? asq?.grpNm ?? "질문";

      const $li = $(`
        <li class="cardItem faq" data-index="${i}">
          <a href="#" class="accordionAnchor" role="button" aria-expanded="false">
            <p class="category mb-1"></p>
            <p class="question fw-semibold"></p>
            <span class="arrow" aria-hidden="true"></span>
          </a>
          <div class="cont" style="display:none;">
            <div class="answer mt-2"></div>
          </div>
        </li>
      `);

      $li.find(".category").html(escapeHtml(category));
      $li.find(".question").html(escapeHtml(question));
      $li.find(".answer").html(nl2br(answer));

      $listRoot.append($li);
    });

    _faqLoaded = true;
  })
  .catch(err => {
    console.error("FAQ 데이터 요청 실패:", err);
    $listRoot.html(`<li class="text-danger text-center">FAQ 데이터를 불러오는 중 오류가 발생했습니다.</li>`);
  })
  .finally(() => { _faqLoading = false; });
}

// ✅ 모달이 처음 열릴 때 1회 로드 (중복 방지)
$('#faqModal').one('shown.bs.modal', function () {
  loadFaqData(true);
});

// ✅ 아코디언 토글 (하나만 열기 + 화살표 회전 + aria 갱신)
$(document).on("click", "#asqhisList .accordionAnchor", function (e) {
  e.preventDefault();
  const $li = $(this).closest("li.cardItem.faq");
  const $cont = $li.find(".cont");
  const isOpen = $li.hasClass("active");

  // 애니메이션 충돌 방지
  $("#asqhisList li.cardItem.faq .cont").stop(true, true).slideUp(150);
  $("#asqhisList li.cardItem.faq").removeClass("active").find(".accordionAnchor").attr("aria-expanded", "false");

  if (!isOpen) {
    $li.addClass("active");
    $cont.stop(true, true).slideDown(150);
    $li.find(".accordionAnchor").attr("aria-expanded", "true");
  }
});

// (선택) 키보드 접근성: Enter/Space로 토글
$(document).on("keydown", "#asqhisList .accordionAnchor", function (e) {
  if (e.key === "Enter" || e.key === " ") {
    e.preventDefault();
    $(this).trigger("click");
  }
});


</script>
</body>
</html>
