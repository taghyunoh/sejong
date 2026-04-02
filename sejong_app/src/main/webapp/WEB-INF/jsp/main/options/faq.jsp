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
.swipeTab {
    position: fixed;
    top: 38px;          /* header 바로 아래 */
    left: 0;
    width: 100%;
    background-color: #005b8e;
    z-index: 999;       /* header보다 낮게 */
}

.contents.faq {
    margin-top: 50px;  /* header(60px) + swipeTab 높이만큼 밀어줌 */
}
</style>
<!-- contents : s -->
    <div class="contents faq">
	  <ul class="swipeTab" style="overflow:hidden;">
		  <li><a href="#" class="anchor on">자주하는 질문</a></li>
	  </ul>
      <div class="lyInner">
		<div class="modal fade" id="faqModal" tabindex="-1">
		  <div class="modal-dialog modal-lg">
		    <div class="modal-content">
		      <div class="modal-body" style="max-height:700px;overflow-y:auto;">
		        <div id="faqAccordion" class="accordionList"><ul></ul></div>
		      </div>
		    </div>
		  </div>
		</div>
      </div>
    </div>
    <!-- contents : e -->
<script>  
	//중복 호출 방지 플래그
	let _faqLoading = false;
	let _faqLoaded  = false;
	
	function loadFaqData(force=false) {
	  if (_faqLoading) return;
	  if (_faqLoaded && !force) return;
	
	  _faqLoading = true;

	  const $listRoot = $("#faqAccordion > ul");
	  if ($listRoot.length === 0) { _faqLoading=false; return; }
	
	  $listRoot.html(`<li class="text-muted text-center">불러오는 중…</li>`);
	
	  fetch('/getFaqList.do', {
	    method: 'POST',
	    headers: { 'Content-Type': 'application/json' },
	    body: JSON.stringify({})
	  })
	  .then(r => { if (!r.ok) throw new Error("네트워크 응답에 문제가 있습니다."); return r.json(); })
	  .then(result => {
	    const ok = result?.error_code === "0" || result?.IsSucceed === true || result?.success === true;
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
	      return;
	    }
	
	    $listRoot.empty();
	    list.forEach((asq, i) => {
	      const question = (asq?.qstnConts ?? asq?.question ?? "질문이 없습니다.").toString().trim();
	      const answer   = (asq?.ansrConts ?? asq?.answer   ?? "답변이 없습니다.").toString().trim();
	      const category =
	        asq?.category ?? asq?.cate ?? asq?.cat ?? asq?.categoryName ?? asq?.ctgryNm ?? asq?.grpNm ?? "질문";
	
	      const $li = $(`
	        <li class="cardItem faq" data-index="${i}">
	          <a href="#" class="accordionAnchor">
	            <p class="category"></p>
	            <p class="question"></p>
	          </a>
	          <div class="cont" style="display:none;">
	            <div class="answer"></div>
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
	
	// ✅ 페이지 DOM이 준비되면 자동 로드
	$(function() {
	  // 컨테이너가 있을 때만 로드 (필요 시 조건 제거 가능)
	  if ($("#faqAccordion").length) loadFaqData();
	});
	
	// 아코디언 토글 (하나만 열기)
	$(document).on("click", ".accordionList .accordionAnchor", function(e) {
	  e.preventDefault();
	  const $li = $(this).closest("li.cardItem.faq");
	  const isOpen = $li.hasClass("active");
	  $(".accordionList li.cardItem.faq").removeClass("active").find(".cont").slideUp(150);
	  if (!isOpen) $li.addClass("active").find(".cont").slideDown(150);
	});
	// 모달이 처음 열릴 때 1회 로드 (중복 방지)
	$('#faqModal').one('shown.bs.modal', function () {
	  loadFaqData(); // 위에 정의한 동일 함수 사용
	});
</script>