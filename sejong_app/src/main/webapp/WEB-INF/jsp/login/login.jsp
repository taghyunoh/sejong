<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page isELIgnored="false" %>


<script src="https://developers.kakao.com/sdk/js/kakao.js"></script>
<script>
/* ★[2026-08-25 요청] **로그인 화면에서 ◀ 한 번이면 앱 종료.**
   종전: 여러 화면을 돌다 로그아웃하면 로그인 화면 뒤에 옛 항목(홈·연속혈당…)이 남아 있고,
         ◀ 를 누르면 그 항목으로 갔다가 세션이 없어 서버가 다시 로그인 화면으로 보낸다
         → 화면은 로그인 그대로라 "눌러도 안 나간다". 남은 항목 수만큼 눌러야 했다.
   이제: 로그인 화면을 히스토리 **첫 항목**으로 내려 둔다. 첫 항목에서 ◀ 를 누르면 안드로이드가 앱을 닫는다.

   ⚠**설치형(PWA)일 때만** 한다 — 그 창은 히스토리 첫 항목이 곧 앱 시작 화면(start_url=loginPage.do)이라
     아무리 내려가도 앱 안이다. 일반 브라우저 탭은 아래에 다른 사이트가 있을 수 있어 건드리지 않는다.
   ⚠홈 화면에는 절대 넣지 말 것 — 홈에서 내려가면 로그인 화면에 착지한다(2026-08-25 사고, docs 9~10장).
     로그인 화면은 어디로 내려가든 (세션이 없어) 결국 로그인 화면이라 안전하다. */
(function(){
  try{
    var standalone = (window.matchMedia && window.matchMedia('(display-mode: standalone)').matches)
                     || window.navigator.standalone === true;
    if (!standalone) return;
    if (history.state && history.state.__loginRoot) return;   // 이 항목에서 이미 시도했다(되풀이 방지)
    history.replaceState({ __loginRoot: 1 }, '');
    var n = history.length - 1;
    if (n > 0) history.go(-n);        // 첫 항목으로. 이미 첫 항목이면 브라우저가 무시한다
  }catch(e){}
})();
</script>
<style>
/* [로그인 화면 고정] 위/아래로 드래그하면 빈 공간(고무줄 스크롤)이 보이던 문제 —
   기존 common.css 의 .splash.login 이 103vh/103% 로 뷰포트보다 크게 잡혀 있어 발생.
   ※ 모바일(실기기, <600px)에서만 적용한다. 데스크톱(>=600px)은 app-desktop.css 의
      휴대폰 프레임(.wrap.wrap 높이)을 그대로 두어야 하므로 건드리지 않는다. */
@media (max-width: 599px) {
  html, body { height: 100%; overflow: hidden; overscroll-behavior: none; }
  .wrap.splash.login {
    min-height: 100dvh;
    height: 100dvh;
    overflow: hidden;
    overscroll-behavior: none;
    touch-action: none;
  }
}

/* [약관동의] 항목 우측 끝의 중복 화살표(>) 제거 (common.css .agreeAnchor::after) */
.agreeList .agreeAnchor::after { content: none !important; }
/* [전체 동의] 행은 상세보기 링크가 아니므로 제목 옆 화살표 제거 + 강조 */
.agreeItem.agreeAll .agreeAnchor > span { background: none; padding-right: 0; }
.agreeItem.agreeAll .agreeAnchor { color: #2b6fff; }

/* ── [2026-08-27 요청] 로그인 화면 다듬기 ──────────────────────────────
   ① 빨간 안내문 두 줄 : 글자 살짝 키우고 위아래 공간·줄간격 넓게
   ② 개인정보처리방침·회원탈퇴 줄 : 위로 (카카오 버튼을 감춘 자리)
   ③ 아래 안내 : 한 문단 → 3줄 목록
   ※ 이 화면에서만 — common.css 의 .comment 는 다른 화면도 쓰므로 건드리지 않는다. */
.loginWrap .login .form p.comment {
  font-size: calc(3.9 * var(--vwu, 1vw));       /* 3.4 → 3.9 */
  line-height: 1.7;                              /* normal → 넓게 */
  margin-top: calc(5 * var(--vwu, 1vw));
  margin-bottom: calc(1.5 * var(--vwu, 1vw));   /* ① 자동로그인 줄을 위로 — 안내문 아래 여백만 줄인다(2.5 → 1.5) */
}
/* ① 자동로그인·휴대폰번호 저장 줄을 조금 위로 (사용자 2026-08-27) — .pt15 가 !important 라 같이 걸어야 이긴다 */
.loginWrap .login .form .checkboxWrap.pt15 { padding-top: calc(1 * var(--vwu, 1vw)) !important; }
.loginWrap .login .notice_wrap {
  display: block;                                 /* flex 해제 — 여러 줄 목록이 되도록 */
  margin-top: calc(7 * var(--vwu, 1vw));          /* 살짝 위로 (10 → 7, 사용자 2026-08-27) */
}
/* 문의 메일 줄이 카드 바닥에 붙어 보인다(사용자 2026-08-27) — 카드 아래 여백을 넓힌다(5.56 → 9).
   ※ 목록에 margin-bottom 을 주는 대신 카드 padding 을 넓혔다. 밑줄(링크)까지 여유 있게 보이게. */
.loginWrap .login { padding-bottom: calc(9 * var(--vwu, 1vw)); }
.loginWrap .login .notice_wrap ul {
  /* ② 글자를 키우면서도 한 줄을 지키려면 쓸 수 있는 폭을 넓혀야 한다 —
     카드 안쪽 폭이 77.76vwu 인데 가장 긴 문구가 약 24.8em 이라, 3.0 이 한 줄의 한계였다.
     목록만 카드 좌우 여백(5.56) 안쪽으로 2vwu 씩 내밀고 들여쓰기도 줄여 4.4vwu 를 벌었다. */
  /* 왼쪽으로 내밀던 것을 되돌려 **우측으로 조금 이동**(사용자 2026-08-27) — 오른쪽만 내민 채로 둔다.
     오른쪽 여유(2vwu)는 남겨 두어야 3.0 글자가 한 줄로 유지된다. */
  margin: 0 calc(-2 * var(--vwu, 1vw)) 0 0;
  padding-left: calc(1.4 * var(--vwu, 1vw));   /* 글자를 키우려고 들여쓰기를 더 줄였다(2.2 → 1.4, 2026-08-27) */
  list-style: disc;
}
.loginWrap .login .notice_wrap li {
  /* ★[2026-08-27] 크기 내력 4.1 → 3.7 → 3.0 → 3.2(접힘) → **3.15**.
     실기기(iPhone)로 잰 결과 쓸 수 있는 폭은 **77.6vwu** 이고 각 문구의 폭은 대략
       ①「사용앱은 세종시 … 실증용입니다.」 ≈ 27.9em   ②「사용기간은 … 까지입니다.」 ≈ 24.5em   ③ 문의 ≈ 16em
     → ②가 한 줄로 남는 한계가 3.15 다(24.5 × 3.15 × 0.98 ≈ 75.6 < 77.6).
     ⚠**①은 이 폭에서 어떤 크기로도 한 줄이 안 된다**(2.84 이하라야 하는데 그건 지금보다 작다).
       ①까지 한 줄로 하려면 문구를 줄여야 한다 — 「사용앱은」 4자만 빼면 3.15 에서 한 줄이 된다. */
  font-size: calc(3.25 * var(--vwu, 1vw));
  letter-spacing: -0.03em;   /* 자간을 조금 더 좁혀 폭을 벌었다 */
  line-height: 1.5;
  word-break: keep-all;   /* 접히더라도 낱말 중간에서 끊기지 않게 */
  margin-bottom: calc(1.6 * var(--vwu, 1vw));
  /* ⚠common.css 164줄의 `ul, li { list-style: none }` 리셋이 **li 에 직접** 걸려 있어
     ul 에만 disc 를 줘서는 점이 안 나온다 — li 에서 되살린다(2026-08-27 실기기 확인). */
  list-style: disc outside;
}
.loginWrap .login .notice_wrap li:last-child { margin-bottom: 0; }
/* 문의 메일 — 밑줄 제거(사용자 2026-08-27). 눌러서 메일 앱이 열리는 것은 그대로. */
.loginWrap .login .notice_wrap a { color: inherit; text-decoration: none; border-bottom: 0; }
</style>
<!-- wrap : s -->
 <div class="wrap splash login">
   <!-- contents : s -->
   <div class="contents">
     <div class="visual loginWrap">
       <div class="header_wrap">
         <div class="logo">allCare</div>
         <p class="mt20">AI기반 디지털 헬스케어 서비스</p>
         <span>연속혈당 allCare Service</span>
       </div>
       <div class="login">
         <p class="title">휴대폰번호 인증</p>
         <div class="form">
            <div class="left_right_wrap mt20">
              <div class="inputWrap mr10">
                <input type="text" class="inpText mt0" id="authPhone" oninput="authPhoneInput(this);" maxlength="11" placeholder="휴대폰번호 입력" />
              </div>
              <div class="btnArea mt0 w50">
                <a href="#" class="btn btnLine01 round pl20 pr20"  onclick="reqAuth();"><span>인증번호 요청</span></a>
              </div>
            </div>
            <!-- [2026-08-27] 강제 줄바꿈(br) 제거 — 글자를 키우니 자연 줄바꿈과 겹쳐 「해 / 주세요」로 3줄이 됐다(실기기 확인) -->
            <p class="comment mt15 pl15">* 본인 인증을 위하여 귀하의 휴대폰번호를 입력해 주세요.(번호만)</p>
            
            <div class="left_right_wrap mt30">
              <div class="inputWrap mr10">
                <input type="password" class="inpText mt0" placeholder="인증번호 입력" id="authCode"  />
              </div>
              <div class="btnArea mt0 w80">
                <a href="#" class="btn btnCol01 round pl20 pr20" onclick="checkAuth();"><span>확 인</span></a>
              </div>
            </div>
            
            
            <p class="comment mt15 pl15">* 수신 문자를 확인 후 6자리 인증번호(숫자)를 입력하세요.</p>
            <div class="checkboxWrap pt15" >
	             <span class="inputCheckbox">
	               <input type="checkbox" id="chk_login" />
	               <label for="chk_login">자동로그인</label>
	             </span>
	             
	             <span class="inputCheckbox">
	               <input type="checkbox" id="chk_saveID" />
	               <label for="chk_saveID">휴대폰번호 저장</label>
	             </span>
            </div>
			<!-- 카카오 로그인 — 화면에서 감춤(사용자 2026-08-27 「화면에서 카카오 히든」).
			     ★지운 것이 아니라 숨긴 것뿐이다 : 아래 div 의 display:none 만 빼면 그대로 되살아난다.
			     (loginWithKakao()·Kakao SDK·서버 쪽 처리는 손대지 않았다) -->
			<div class="btnArea mt1 w100" id="kakaoLoginArea" style="display:none;">
			  <a href="#"
			     class="btn btnCol01 round pl20 pr20"  onclick="loginWithKakao();"
			     style="background-color: #FEE500; color: #000; 
			            font-weight: bold; text-align: center; text-decoration: none; line-height: 1;">
			    <span>카카오로 간편하게 시작하기</span>
			  </a>
			</div>
			<!-- 추가 영역 -->
			<div class="comment_text mt15 pl15" style="display: flex; justify-content: space-between;">
			  <a href="#" onclick="goJoin10();" >개인정보처리방침</a>
			  <div class ="pr15">
			    <a href="#" onclick="goJoin4();">회원탈퇴</a>
			  </div>  
			</div>
         </div>
         <!-- [2026-08-27 요청] 한 문단 → 3줄 목록으로 (문구도 지정하신 대로) -->
         <div class="notice_wrap">
           <ul>
             <li>사용앱은 세종시 AI기반 디지털헬스케어 서비스 실증용입니다.</li>
             <li>사용기간은 착수 시점부터 실증완료(10월) 까지입니다.</li>
             <li>문의 : <a href="mailto:service@allcare365.kr">service@allcare365.kr</a></li>
           </ul>
         </div>
       </div>
     </div>
   </div>
 </div>

 <!-- wrap : e -->
<!-- [레] : 회원인증 팝업 : s -->
<div class="popupWrap popupFull joinPopup1">
	<div class="popupContent popupInner">
		<div class="popupHead">
			<strong class="tit">회원인증</strong>
			<a href="javascript:layerPop('close' , 'joinPopup1')" class="btnPopClose">레이어 닫기</a>
		</div>
		<div class="popupCont">
			<!-- 내용 : s -->
			<ul class="stepList">
				<li class="on">
					<span class="num">1</span>
					<p class="title">회원인증</p>
				</li>
				<li>
					<span class="num">2</span>
					<p class="title">약관동의</p>
				</li>
				<li>
					<span class="num">3</span>
					<p class="title">정보입력</p>
				</li>
			</ul>
			<div class="infoBox">
				<p>‘올케어(allCare)서비스는 당뇨전 단계 회원 전용 서비스입니다. ‘회원께서는 휴대폰용 앱(app)을 통해 회원인증 후 관련정보를 입력 후 사용이 가능합니다. </p>
			</div>
			<div class="form">
				<dl class="formList">
					<dt><span class="vital">휴대폰번호</span></dt>
					<dd>
						<div class="inputWrap"><input type="text" class="inpText" id="phone" placeholder="휴대폰번호 입력" readonly></div>
					</dd>
				</dl>
				<dl class="formList">
					<dt><span class="vital">이메일정보 (카카오일 경우필요 )</span></dt>
					<dd>
						<div class="inputWrap"><input type="text" class="inpText" id="email" placeholder="이메일 입력" readonly></div>
					</dd>
				</dl>
				
				<dl class="formList">
					<dt><span class="vital">이름</span></dt>
					<dd>
						<div class="inputWrap"><input type="text" class="inpText" id="userNm" placeholder="이름을 입력하세요."></div>
					</dd>
				</dl>
				<dl class="formList">
					<dt><span class="vital">생년월일</span></dt>
					<dd>
						<div class="inputWrap"><input type="text" class="inpText" id="birth" placeholder="생년월일 8자리 예)19631126" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');" maxlength="8"></div>
					</dd>
				</dl>
			</div>

			<div class="buttonFixed">
				<div class="btnArea fix">
					<a href="#" class="btn btnCol01" onclick="cancelBtn();"><span>취소</span></a>
					<a href="#" class="btn btnCol02 next" onclick="goJoin2();"><span>다음</span></a>
				</div>
			</div>

			<!-- 내용 : e -->
		</div>
	</div>
</div>
<!-- [레] : 회원인증 팝업 : e -->

<!-- [레] : 약관 팝업 : s -->
<style>
/* 개인정보처리방침·회원탈퇴 팝업: 상단(파란 헤더)·하단(파란 버튼) 좌우 여백 살짝 + 라운딩 */
/* 상단 파란 바: 조금 아래로 내리고(위 여백) 좌우로 살짝 확장(측면 여백 축소) */
.joinPopup10 .stepList.bulcolor,
.joinPopup4 .stepList.bulcolor{ margin:10px 8px 0 8px; border-radius:8px; }
.joinPopup10 .buttonFixed .btnArea.fix,
.joinPopup4 .buttonFixed .btnArea.fix{ padding-left:12px !important; padding-right:12px !important; }
/* 하단 닫기 버튼: 살짝 위로 올림(아래 여백) + 라운딩 */
.joinPopup10 .buttonFixed .btnArea.fix .btn,
.joinPopup4 .buttonFixed .btnArea.fix .btn{ border-radius:8px; margin-bottom:14px; }

/* [회원등록 흐름] joinPopup1(회원인증)·2(약관동의)·3(정보입력) 도 개인정보처리방침과 동일한
   '상단 바 + 하단 전체폭 버튼' 형태로 통일 — 상단 단계바 여백/라운딩, 하단 버튼 전체폭/라운딩/여백 */
/* 상단 단계바 — 좌우 여백을 없애 좌우로 크게(폭만 확대) (2026-07-31 요청)
   + 단계 표시바 배경 = [다음] 버튼과 같은 파랑(btnCol02 #218ecb, 종전 #005d92) (2026-07-31 2차 요청) */
.joinPopup1 .stepList,
.joinPopup2 .stepList,
.joinPopup3 .stepList{ margin:10px 0 0 0; border-radius:8px; background:#218ecb; }
.joinPopup1 .buttonFixed .btnArea.fix,
.joinPopup2 .buttonFixed .btnArea.fix,
.joinPopup3 .buttonFixed .btnArea.fix{ padding-left:12px !important; padding-right:12px !important;
  gap:10px; }   /* 취소·다음이 같은 파랑이 되며 붙어 보임 → 살짝 간격(2026-07-31 요청) */
.joinPopup1 .buttonFixed .btnArea.fix .btn,
.joinPopup2 .buttonFixed .btnArea.fix .btn,
.joinPopup3 .buttonFixed .btnArea.fix .btn{ border-radius:8px; margin-bottom:14px; }
/* [원복 2026-07-31] 회원등록 3단계 본문 배경을 로그인 그라데이션+흰 카드로 바꿨다가
   사용자 요청("일단 원복")으로 제거 — 본문은 종전 흰 배경 그대로. 재적용 요청 시 이 이력 확인. */

/* 취소 버튼 색 (2026-07-31 확정) — [다음]/[완료] 버튼과 같은 파랑(btnCol02 #218ecb)으로 통일.
   (처음 어두운 남색 → 밝은 회색 → 사용자 요청 "취소버튼도 변경"으로 파랑 확정 — 재변경 시 이 이력 확인) */
.joinPopup1 .btnArea.fix .btn.btnCol01,
.joinPopup2 .btnArea.fix .btn.btnCol01,
.joinPopup3 .btnArea.fix .btn.btnCol01{ background:#218ecb; color:#fff; }
</style>
<div class="popupWrap popupFull joinPopup10">
	<div class="popupContent popupInner">
		<div class="popupHead">
			<strong class="tit">개인정보처리방침</strong>
			<a href="javascript:layerPop('close' , 'joinPopup10')" class="btnPopClose">레이어 닫기</a>
		</div>
		<div class="popupCont">
			<!-- 내용 : s -->
			<ul class="stepList bulcolor">
				<li class="on">
					<span class="num"></span>
					<p class="title">개인정보처리방침</p>
				</li>
			</ul>
			<div class="sign-table-container">
			  <div class="sign-table-wrapper">
			    <table class="sign-table">
			      <tbody id="signList">
			        <!-- 여기에 JS로 <tr><td>...</td></tr>가 삽입됨 -->
			      </tbody>
			    </table>
			  </div>
			</div>

		<!-- 내용 : e -->
		</div>
		<div class="buttonFixed">
			<div class="btnArea fix  ">
				<a href="#" class="btn btnCol07" onclick="cancelBtn();"><span>닫기</span></a>
			</div>
		</div>
	</div>
</div>
<div class="popupWrap popupFull joinPopup2">
	<div class="popupContent popupInner">
		<div class="popupHead">
			<strong class="tit">회원인증</strong>
			<a href="javascript:layerPop('close' , 'joinPopup2')" class="btnPopClose">레이어 닫기</a>
		</div>
		<div class="popupCont">
			<!-- 내용 : s -->
			<ul class="stepList">
				<li>
					<span class="num">1</span>
					<p class="title">회원인증</p>
				</li>
				<li class="on">
					<span class="num">2</span>
					<p class="title">약관동의</p>
				</li>
				<li>
					<span class="num">3</span>
					<p class="title">정보입력</p>
				</li>
			</ul>
			<div class="agreeList">
					<div class="agreeItem agreeAll">
						<a href="#" class="agreeAnchor" onclick="return false;"><span>전체 동의</span></a>
						<div class="checkboxWrap type02">
							<span class="inputCheckbox solo">
								<input type="checkbox" id="chk_all" onchange="toggleAllAgree(this.checked);">
								<label for="chk_all"></label>
							</span>
						</div>
					</div>
				<div class="agreeItem">
					<a href="#" class="agreeAnchor" onclick="getSignList(3);" ><span>서비스 이용약관</span></a>
					<div class="checkboxWrap type02">
						<span class="inputCheckbox solo">
							<input type="checkbox" id="chk_01">
							<label for="chk_01"></label>
						</span>
					</div>
				</div>
				<div class="agreeItem">
					<a href="#" class="agreeAnchor" onclick="getSignList(1);" ><span>개인정보 수집·이용동의</span></a>
					<div class="checkboxWrap type02">
						<span class="inputCheckbox solo">
							<input type="checkbox" id="chk_02">
							<label for="chk_02"></label>
						</span>
					</div>
				</div>
				<div class="agreeItem">
					<a href="#" class="agreeAnchor" onclick="getSignList(2);"><span>고유식별정보 처리동의</span></a>
					<div class="checkboxWrap type02">
						<span class="inputCheckbox solo">
							<input type="checkbox" id="chk_03">
							<label for="chk_03"></label>
						</span>
					</div>
				</div>
			</div>
			
			<div class="sign-table-container">
			  <div class="sign-table-wrapper">
			    <table class="sign-table">
			      <tbody id="signList">
			        <!-- 여기에 JS로 <tr><td>...</td></tr>가 삽입됨 -->
			      </tbody>
			    </table>
			  </div>
			</div>

			<div class="buttonFixed">
				<div class="btnArea fix">
					<a href="#" class="btn btnCol01" onclick="cancelBtn();"><span>취소</span></a>
					<a href="#" class="btn btnCol02 next" onclick="goJoin3();"><span>다음</span></a>
				</div>
			</div>

			<!-- 내용 : e -->
		</div>
	</div>
</div>
<!-- [레] : 약관 팝업 : e -->

<!-- [레] : 정보입력 팝업 : s -->
<div class="popupWrap popupFull joinPopup3">
	<div class="popupContent popupInner">
		<div class="popupHead">
			<strong class="tit">회원인증</strong>
			<a href="javascript:layerPop('close' , 'joinPopup3')" class="btnPopClose">레이어 닫기</a>
		</div>
		<div class="popupCont">
			<!-- 내용 : s -->
			<ul class="stepList">
				<li>
					<span class="num">1</span>
					<p class="title">회원인증</p>
				</li>
				<li>
					<span class="num">2</span>
					<p class="title">약관동의</p>
				</li>
				<li class="on">
					<span class="num">3</span>
					<p class="title">정보입력</p>
				</li>
			</ul>
			<div class="form">

				<h5 class="pt30 pb20">추가 의료정보 등록</h5>
				<dl class="formList">
					<dt><span class="vital">성별</span></dt>
					<dd>
						<div class="radioWrap typeBox02">
							<span class="inputRadio">
								<input type="radio" name="rdo_gender" id="rdo_gender01" value="M" checked>
								<label for="rdo_gender01">남성</label>
							</span>
							<span class="inputRadio">
								<input type="radio" name="rdo_gender" id="rdo_gender02" value="F">
								<label for="rdo_gender02">여성</label>
							</span>
						</div>
					</dd>
				</dl>

				<dl class="formList">
					<dt><span>키</span></dt>
					<dd>
						<div class="inputWrap"><input type="text" class="inpText" id="height" value=""><span class="add_inf">cm</span></div>
					</dd>
				</dl>

				<dl class="formList">
					<dt><span>몸무게</span></dt>
					<dd>
						<div class="inputWrap"><input type="text" class="inpText" id="weight" value=""><span class="add_inf">kg</span></div>
					</dd>
				</dl>
				<dl class="formList">
						<dt><span class="vital">당뇨 유형</span></dt>
						<dd>
							<div class="radioWrap typeBox03">
								<span class="inputRadio">
									<input type="radio" name="rdo_sugar" id="rdo_sugar01" value="1" checked>
									<label for="rdo_sugar01">1형 당뇨병</label>
								</span>
								<span class="inputRadio">
									<input type="radio" name="rdo_sugar" id="rdo_sugar02" value="2">
									<label for="rdo_sugar02">2형 당뇨병</label>
								</span>
								<span class="inputRadio">
									<input type="radio" name="rdo_sugar" id="rdo_sugar03" value="3">
									<label for="rdo_sugar03">당뇨병 전단계</label>
								</span>
								<span class="inputRadio">
									<input type="radio" name="rdo_sugar" id="rdo_sugar04" value="4">
									<label for="rdo_sugar04">임신성 당뇨병</label>
								</span>
								<span class="inputRadio">
									<input type="radio" name="rdo_sugar" id="rdo_sugar09" value="9">
									<label for="rdo_sugar09">기타</label>
								</span>
							</div>
						</dd>
			  </dl>
			</div>

			<div class="buttonFixed">
				<div class="btnArea fix">
					<%-- 취소 버튼 추가(2026-07-31) — 1·2단계와 하단 버튼 일관성(취소 + 진행) --%>
					<a href="#" class="btn btnCol01" onclick="cancelBtn();"><span>취소</span></a>
					<a href="#" class="btn btnCol02" onclick="registerUser();"><span>완료</span></a>
				</div>
			</div>

			<!-- 내용 : e -->
		</div>
	</div>
</div>
<!-- [레] : 정보입력 팝업 : e -->
<!-- 회원탈퇴 -->
<div class="popupWrap popupFull joinPopup4">
  <div class="popupContent popupInner">
    <div class="visual loginWrap">
    <!-- 팝업 본문 -->
    <div class="popupCont">
	    <!-- 팝업 헤더 -->
	    <div class="popupHead">
	      <p class="title">회원탈퇴 인증</p>
	      <a href="javascript:layerPop('close', 'joinPopup4')" class="btnPopClose" title="레이어 닫기">X</a>
	    </div>
    

	  <!-- 회원탈퇴 주의사항 -->
	  <p class="comment mt15 pl15">* 회원탈퇴 주의사항</p>	
	  <div class="notice_msg">
	     회원탈퇴 시 모든 개인정보 및 서비스 이용기록은 영구적으로 삭제되며 복구할 수 없습니다.
	  </div>
           
      <!-- 휴대폰번호 입력 -->
      <div class="left_right_wrap mt20">
        <div class="inputWrap mr10">
          <input type="text" class="inpText mt0" id="authPhone_out" placeholder="휴대폰번호 입력" maxlength="11"oninput="this.value = this.value.replace(/[^0-9]/g, '')" />
        </div>
        <div class="btnArea mt0 w50">
          <a href="#" class="btn btnLine01 round pl20 pr20" onclick="reqAuth_out();"> <span>인증번호 요청</span>
          </a>
        </div>
      </div>

      <!-- 안내문 -->
      <p class="comment mt15 pl15">* 본인 인증을 위하여 귀하의 휴대폰번호를 입력(번호만 입력)</p>
      <!-- 인증번호 입력 -->
      <div class="left_right_wrap mt20">
        <div class="inputWrap mr10">
          <input type="password" class="inpText mt0" id="authCode_out" placeholder="인증번호 입력" />
        </div>
        <%-- 확인 버튼 색·크기 통일 (2026-07-31 요청) — 위의 [인증번호 요청]과 같은 크기(w50),
             색은 어두운 회색(btnCol01 #606477) 대신 테마 블루(btnCol07 #007BFF = 하단 회원탈퇴취소와 동일) --%>
        <div class="btnArea mt0 w50">
          <a href="#" class="btn btnCol07 round pl20 pr20" onclick="checkAuth_out();">
            <span>확 인</span>
          </a>
        </div>
      </div>
     </div>
    </div> <!-- popupCont -->

     <!-- 하단 고정 버튼 -->
    <div class="buttonFixed">
       <div class="btnArea fix">
         <a href="#" class="btn btnCol07" onclick="cancelBtn();"><span>회원탈퇴취소</span></a>
       </div>
    </div>

  </div> <!-- popupContent -->
</div>
		
<script>
var phone;
var phone_out;
$(document).ready(function() {
	callAndroid("f101");
});
function userInfoCallBack(data){
	if(data == ""){
		console.log("저장 정보 없음");
	}else{
		console.log(data);
		var obj = JSON.parse(data);
		console.log(obj);
		if(obj.autoYn){
			const userData = {};
			userData.phone = obj.phone;
			CommonUtil.callAjax(CommonUtil.getContextPath() + "/autoLogin.do","POST",userData,function(response){
				if(response.IsSucceed){
					location.replace(CommonUtil.getContextPath() + "/mainPage.do");   // [2026-08-25] href→replace: 로그인 항목을 홈으로 대체해 홈이 히스토리 뿌리가 된다(홈에서 ◀=앱 종료, main.jsp 참고)
				}else{
					alert("자동 로그인 실패");
				}
			});
		}
		if(obj.saveYn){
			phone = obj.phone;
			$("#authPhone").val(phone);
			$("#chk_saveID").attr("checked", true);
		}
	}
}
function reqAuth(){
	//세션 인증시간이 1분 안지났으면 1분이내에 인증요청이력이있습니다. 확인후 다시 요청해달라고 보내고 return 
	phone = $("#authPhone").val();
	if(phone == "1855"){
		CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/testUser.do","POST",'',function(response){
			console.log(response.Data);
			alert("테스트 유저");
			location.replace(CommonUtil.getContextPath() + "/mainPage.do");   // [2026-08-25] href→replace: 로그인 항목을 홈으로 대체해 홈이 히스토리 뿌리가 된다(홈에서 ◀=앱 종료, main.jsp 참고)
		});
		return;
	}
	if(phone == "3399"){
		CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/testUser2.do","POST",'',function(response){
			console.log(response.Data);
			alert("테스트 유저");
			location.replace(CommonUtil.getContextPath() + "/mainPage.do");   // [2026-08-25] href→replace: 로그인 항목을 홈으로 대체해 홈이 히스토리 뿌리가 된다(홈에서 ◀=앱 종료, main.jsp 참고)
		//	location.href = CommonUtil.getContextPath() + "/goBloodPage.do";


		});
		return;
	}
	if(phone.length < 10){
		alert("휴대폰 번호를 정확히 입력해 주세요.");
		return;
	}
	//나중에 이로직 checkAuth 취소 (login_back 대체)
	// checkAuth() ;
   //
	//나중복구 
    //NCP 인증보내기 세션 에 인증키와 시간 등록 
 	CommonUtil.callAjax(CommonUtil.getContextPath() + "/sendSensApi.do","POST",phone,function(response){
		console.log(response.Data);
		alert(response.Message);
	}); 
	
}
function saveUserInfo(){
	const appData = {};
	appData.phone = phone;
	appData.autoYn = $("#chk_login").is(':checked');
	appData.saveYn = $("#chk_saveID").is(':checked');
	callAndroid("f102",appData); 
}
function checkAuth(){
	var authCode = $("#authCode").val(); //
	const data = {};
	data.phone = phone;
	data.authCode = authCode; 
	CommonUtil.callAjax(CommonUtil.getContextPath() + "/loginCheck.do","POST",data,function(response){
		console.log(response.Data);
		if(response.IsSucceed){
			alert(response.Message);
			if(response.Data >= 1){
				saveUserInfo();
				location.replace(CommonUtil.getContextPath() + "/mainPage.do");   // [2026-08-25] href→replace: 로그인 항목을 홈으로 대체해 홈이 히스토리 뿌리가 된다(홈에서 ◀=앱 종료, main.jsp 참고)
			}else{
				$("#email").removeAttr("readonly");
				$("#phone").val(phone);
				javascript:layerPop('open' , 'joinPopup1');
			}
		}else{
			alert(response.Message);
			//나중취소
			$("#email").removeAttr("readonly");
			$("#phone").val(phone);
			javascript:layerPop('open' , 'joinPopup1');
			//나중위소 
		} 
	});
}
//회원탈퇴  인증번호 가져올기 
function reqAuth_out(){
	//세션 인증시간이 1분 안지났으면 1분이내에 인증요청이력이있습니다. 확인후 다시 요청해달라고 보내고 return 
	phone = $("#authPhone_out").val();
	if(phone.length < 10){
		alert("휴대폰 번호를 정확히 입력해 주세요.");
		return;
	}
	//NCP 인증보내기 세션 에 인증키와 시간 등록 
	CommonUtil.callAjax(CommonUtil.getContextPath() + "/sendSensApi.do","POST",phone,function(response){
		console.log(response.Data);
		alert(response.Message);
	});
	
}
//회원탈퇴 인증번호 가져오면 확인 
function checkAuth_out(){
	var authCode = $("#authCode_out").val();
	const data = {};
	data.phone    = phone;
	data.authCode = authCode;
	CommonUtil.callAjax(CommonUtil.getContextPath() + "/loginCheck.do","POST",data,function(response){
		console.log(response.Data);
		if(response.IsSucceed){
			if(response.Data >= 1){
				  const data = {
				    userUuid : "${sessionScope.userUuid}"
				  };
				  if (confirm(`${phone} 개인 관련정보를 삭제하시겠습니까?`)) {
				      $.ajax({
					      url: CommonUtil.getContextPath() + "/alldelete.do",
					      type: "POST",
					      contentType: "application/json",
					      data: JSON.stringify([data]), // 배열로 전송
					      success: function(response) {
					         alert("개인관련 전체 정보가 삭제되었습니다.");
					      },
					      error: function(xhr, status, error) {
					    	 alert("시스템오류입니다 다시 입력하세요!");
					      }
					  });
				  }
			}else{
				alert("등록된 회원 아닙니다.");
				return;
			}
		}else{
			alert(response.Message);
		} 
	});
}
/* 취소 버튼 */
function cancelBtn(){
	location.href = CommonUtil.getContextPath() + "/loginPage.do";
}
/* [테스트] 휴대폰번호 칸에 'test' 라고 치면 인증 없이 회원가입 화면(joinPopup1)을 바로 연다 (2026-07-31, UI 확인용).
   숫자만 남기는 기존 필터는 유지하되 't'→'te'→'tes'→'test' 로 치는 중일 때만 지우지 않는다.
   실제 가입 저장은 서버 검증을 그대로 거치므로 인증 우회가 아니다(화면 확인 전용). */
function authPhoneInput(el){
	var v = el.value;
	if(/^t(e(s(t)?)?)?$/i.test(v)){
		if(/^test$/i.test(v)){
			el.value = '';
			$("#email").removeAttr("readonly");       // 실제 신규가입 흐름(checkAuth 신규 분기)과 같은 상태로
			$("#phone").val('01000000000');           // 다음 단계(goJoin2) 휴대폰번호 검증 통과용 더미
			layerPop('open', 'joinPopup1');
		}
		return;
	}
	el.value = v.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');
}
function goJoin10(){
	getSignList("1");
	javascript:layerPop('open' , 'joinPopup10');
}
/* 약관 팝업 오픈 */
function goJoin2(){
	var phone = $("#phone").val();
	var userNm = $("#userNm").val();
	var birth = $("#birth").val();
	if (phone.length < 1){
		alert("휴대폰번호를 입력해주세요.");
		return;
	}
	if(userNm.length < 1){
		alert("이름을 입력해주세요.");
		return;
	}
	if(birth.length < 8){
		alert("생년월일을 8자리로 정확히 입력해주세요.");
		return;
	}
	javascript:layerPop('close' , 'joinPopup1');
	javascript:layerPop('open' , 'joinPopup2');
	
}
/* 정보입력 팝업 오픈 */
function goJoin3(){
	var checked1 = $("#chk_01").is(':checked');
	var checked2 = $("#chk_02").is(':checked');
	var checked3 = $("#chk_03").is(':checked');
	if(!checked1) {
		alert("서비스 이용약관에 동의해주세요.");
		return;
	}
	if(!checked2) {
		alert("개인정보 수집 이용동의 항목에 동의해주세요.");
		return;
	}
	if(!checked3) {
		alert("고유식별정보 처리동의 항목에 동의해주세요.");
		return;
	}
	javascript:layerPop('close' , 'joinPopup2');
	javascript:layerPop('open' , 'joinPopup3');
}
// [전체 동의] 체크 → 개별 약관 3개 일괄 체크/해제
function toggleAllAgree(checked){
	$("#chk_01, #chk_02, #chk_03").prop("checked", checked);
}
// 개별 약관 체크 상태에 맞춰 '전체 동의' 상태 동기화
function syncAgreeAll(){
	var all = $("#chk_01").is(':checked') && $("#chk_02").is(':checked') && $("#chk_03").is(':checked');
	$("#chk_all").prop("checked", all);
}
$(document).on('change', '#chk_01, #chk_02, #chk_03', syncAgreeAll);

function goJoin4(){
	javascript:layerPop('open' , 'joinPopup4');
}

/* 사용자 정보 등*/
function registerUser() {
  // 1) 입력값 수집 & 기본 검증
  const data = {
    phone:  $.trim($("#phone").val()),
    email:  $.trim($("#email").val()),
    userNm: $.trim($("#userNm").val()),
    birth:  $.trim($("#birth").val()),
    gender: $('input[name=rdo_gender]:checked').val() || null,
    blodGb: $('input[name=rdo_sugar]:checked').val() || null, // 의도된 name/값이라면 유지
    height: $.trim($("#height").val()),
    weight: $.trim($("#weight").val())
  };

  // 간단한 유효성 체크 (필요시 강화)
  if (!data.phone || !data.userNm) {
    alert("필수 항목(전화번호/이름)을 입력해 주세요.");
    return;
  }

  // 2) 중복 클릭 방지 (버튼 비활성화)
  const $btn = $("#btnRegister"); // 실제 버튼 id로 변경
  $btn.prop("disabled", true);

  // 주의: JS 템플릿리터럴 `${ctx}` 는 JSP EL(isELIgnored=false)이 서버에서 먼저
  // 빈 문자열로 치환해 /app 컨텍스트가 사라진다. 반드시 문자열 결합으로 URL을 만든다.
  const ctx = CommonUtil.getContextPath();

  // 3) 1차 호출: /User.do
  CommonUtil.callSyncAjax(ctx + "/User.do", "POST", data, function (res1) {
    if (res1 && res1.IsSucceed) {
      // 3-1) 성공 → updateUser
      CommonUtil.callSyncAjax(ctx + "/updateUser.do", "POST", data, function (res2) {
        finalizeRegister(res2);
      });
    } else {
      // 3-2) 실패 → registerUser
      CommonUtil.callSyncAjax(ctx + "/registerUser.do", "POST", data, function (res3) {
        finalizeRegister(res3);
      });
    }
  });

  function finalizeRegister(resp) {
    try {
      console.log(resp && resp.Data);
      if (resp && resp.IsSucceed) {
        saveUserInfo();
        alert("회원가입 성공 하였습니다.");
        location.replace(ctx + "/mainPage.do");   // [2026-08-25] href→replace: 홈을 히스토리 뿌리로(홈에서 ◀=앱 종료)
      } else {
        alert("회원 가입 실패. 관리자에게 문의 부탁드립니다.");
        $btn.prop("disabled", false);
      }
    } catch (e) {
      console.error(e);
      alert("처리 중 오류가 발생했습니다.");
      $btn.prop("disabled", false);
    }
  }
}


//1. SDK 초기화 (SDK 미로드/JS키 없음이 뒤 스크립트를 깨뜨리지 않도록 방어)
try {
	if (window.Kakao && '${kakaoJsKey}') {
		if (!Kakao.isInitialized()) { Kakao.init('${kakaoJsKey}'); }
	} else {
		console.warn('카카오 SDK 미로드 또는 JS키 없음 — 카카오 로그인 비활성');
	}
} catch (e) {
	console.error('Kakao.init 실패:', e);
}

// 1-2. 저장된 카카오 토큰이 만료/무효면 페이지 로드 시 미리 비워둔다(백그라운드, 화면 영향 없음).
//   → 유효하면 그대로 둬서 로그인 클릭 시 '토큰 있음' 빠른 경로로 바로 진입(카카오 로그인 화면 깜박임 없음).
//   → 만료면 미리 비워둬서 클릭 시 제스처 안에서 한 번에 로그인(예전의 '두 번 탭' 방지).
function kakaoPurgeStaleToken() {
	try {
		if (!window.Kakao || !Kakao.isInitialized() || !Kakao.Auth.getAccessToken()) return;
		Kakao.API.request({
			url: '/v1/user/access_token_info',
			fail: function () { try { Kakao.Auth.setAccessToken(null); } catch (e) {} }
		});
	} catch (e) { console.warn('카카오 토큰 사전점검 오류:', e); }
}
kakaoPurgeStaleToken();

//3. 로그인 함수 (기존 구조 유지, 보완만 추가)
function loginWithKakao() {
	// (가드) SDK 미초기화 시 사용자에게 안내
	if (!window.Kakao || !Kakao.isInitialized()) {
	 alert("카카오 SDK가 아직 준비되지 않았습니다. 잠시 후 다시 시도해주세요.");
	 return;
	}
	
	// 내부 헬퍼들: 함수 표현식으로 선언(중첩 선언 경고/호이스팅 이슈 회피)
	const reAskEmailConsent = function () {
	 Kakao.Auth.login({
	   scope: 'account_email,profile_nickname',
	   throughTalk: false,   // PWA(브라우저)에선 카카오톡 앱으로 튕기지 않고 브라우저 안에서 로그인 → 로그인 후 복귀 안정
	   success: function () {
	     requestUserAndSend();
	   },
	   fail: function (err) {
	     console.error('이메일 동의 재요청 실패', err);
	     alert("이메일 제공 동의가 필요합니다.");
	   }
	 });
	};
	
	const requestUserAndSend = function (isRetry) {
	 Kakao.API.request({
	   url: '/v2/user/me',
	   success: function (res) {
	     // 1) 이메일 확보 로직 강화
	     var email = null;
	     if (res.kakao_account) {
	       if (res.kakao_account.email) {
	         email = res.kakao_account.email;
	       } else if (res.kakao_account.has_email === true &&
	                  res.kakao_account.email_needs_agreement === true) {
	         reAskEmailConsent();
	         return;
	       }
	     }
	
	     if (!email) {
	       alert("카카오에서 이메일 제공이 되지 않았습니다. 회원정보를 입력해 주세요.");
	       $("#phone").removeAttr("readonly");
	       $("#email").val("");
	       layerPop('open', 'joinPopup1');
	       return;
	     }
	
	     // 2) 서버로 이메일 전송 (기존 그대로 유지)
	     const userData = { email: email };
	     CommonUtil.callSyncAjax(
	       CommonUtil.getContextPath() + "/testUser3.do",
	       "POST",
	       userData,
	       function (response) {
	         console.log(response.Data);
	         if (response.Data) {
	           location.replace(CommonUtil.getContextPath() + "/mainPage.do");   // [2026-08-25] href→replace: 로그인 항목을 홈으로 대체해 홈이 히스토리 뿌리가 된다(홈에서 ◀=앱 종료, main.jsp 참고)
	         } else {
	           alert(response.message || "'확인'을 클릭하여 회원정보를 입력해주세요");
	           $("#phone").removeAttr("readonly");
	           $("#email").val(userData.email);
	           layerPop('open', 'joinPopup1');
	         }
	       },
	       function (error) {
	         console.error("Ajax 실패", error);
	         alert("서버 전송 실패");
	       }
	     );
	   },
	   fail: function (error) {
	     console.error('사용자 정보 요청 실패', error);
	     // 저장된 액세스 토큰이 만료/무효일 수 있음 → 1회에 한해 토큰 비우고 새 로그인으로 복구
	     if (!isRetry) {
	       try { Kakao.Auth.setAccessToken(null); } catch (e) {}
	       Kakao.Auth.login({
	         scope: 'account_email,profile_nickname',
	         throughTalk: false,
	         success: function () { requestUserAndSend(true); },
	         fail: function (err) {
	           console.error('재로그인 실패', err);
	           alert("카카오 로그인에 실패했습니다. 다시 시도해주세요.");
	         }
	       });
	       return;
	     }
	     // 재시도도 실패 → 실제 에러 노출(대개 카카오 콘솔 도메인/동의항목 설정 문제)
	     var _m = (error && (error.msg || error.error_description || error.error || error.code)) || '';
	     alert("사용자 정보 요청 실패" + (_m ? " (" + _m + ")" : "") + "\n카카오 개발자 콘솔의 도메인/동의항목 설정을 확인해주세요.");
	   }
	 });
	};
	
	// A. 저장된 토큰이 있으면(=로그인 상태) 바로 사용자정보 조회 → 카카오 로그인 화면이 안 떠서 깜박임 없음.
	//    토큰이 없으면(미로그인 또는 만료로 위 kakaoPurgeStaleToken 에서 사전 정리됨) 클릭 제스처 안에서 로그인.
	//    ※ 장시간 미사용으로 만료된 토큰은 페이지 로드시 미리 비워지므로 여기서 null → 아래 else 로 빠져
	//      '한 번의 탭'으로 로그인된다(제스처 안 login 이라 팝업 차단 없음). 예전의 깜박임/두 번 탭 모두 방지.
	if (Kakao.Auth.getAccessToken()) {
	 requestUserAndSend();
	} else {
	 Kakao.Auth.login({
	   scope: 'account_email,profile_nickname',
	   throughTalk: false,   // PWA(브라우저) 로그인 후 복귀 안정을 위해 브라우저 내 로그인 유지
	   success: function (authObj) {
	     console.log('로그인 성공:', authObj);
	     requestUserAndSend();
	   },
	   fail: function (err) {
	     console.error('로그인 실패', err);
	     alert("로그인 실패");
	   }
	 });
	}
}

 window.onload = function() {
    const email = "${email1}"; // 서버에서 email 세팅되었다고 가정

    if (email) {
      sendUserData(email);
    }
  };

 function sendUserData(email) {
   const userData = { email: email };

   CommonUtil.callSyncAjax(
     CommonUtil.getContextPath() + "/testUser3.do",
     "POST",
     userData,
     function(response) {
       console.log("서버 응답:", response.Data);
       location.replace(CommonUtil.getContextPath() + "/mainPage.do");   // [2026-08-25] href→replace: 로그인 항목을 홈으로 대체해 홈이 히스토리 뿌리가 된다(홈에서 ◀=앱 종료, main.jsp 참고)
     },
     function(error) {
       console.error("Ajax 실패", error);
       alert("서버 전송 실패");
     }
   );
 }
 function getSignList(termsGb) {
	  let param = {
		  termsGb :  termsGb
      };
	  fetch(CommonUtil.getContextPath() + '/getSignList.do', {
	    method: 'POST',
	    headers: {
	      'Content-Type': 'application/json'
	    },
	    body: JSON.stringify(param)
	  })
	  .then(response => response.json())
	  .then(result => {
	    if (result.IsSucceed) {
	      renderSignList(result.Data);
	    } else {
	      alert('개인정보을 불러오는 데 실패했습니다.');
	    }
	  })
	  .catch(error => {
	    console.error('Error:', error);
	  });
	}
	function renderSignList(data) {
		  // #signList 가 joinPopup10(개인정보처리방침)·joinPopup2(약관동의) 두 곳에 중복돼 있어,
		  // getElementById 는 항상 첫 번째(숨겨진 joinPopup10)만 잡는다 → 약관동의 화면에 내용이 안 뜸.
		  // 지금 열려있는 팝업 내부의 tbody 를 대상으로 한다. (element.querySelector 는 getElementById 와 달리
		  // 스코프 안에서 검색하므로 id 가 중복돼도 올바른 것을 찾는다.)
		  let list = null;
		  let scope = $('.popupWrap:visible').last()[0];
		  if (scope) { list = scope.querySelector('#signList'); }
		  if (!list) { list = document.getElementById("signList"); }
		  if (!list) { return; }
		  list.innerHTML = '';

		  data.forEach(item => {
		    const tr = document.createElement('tr');
		    
		    tr.setAttribute('data-exer-seq', item.termsSeq); // tr에 key 저장
		    
		    const tdType = document.createElement('td');
		    const name = item.termsConts || '';  // ✅ 먼저 name 변수 선언

		    if (name.length > 500) {
		      tdType.textContent = name.substring(0, 500) + '…';
			  tdType.setAttribute("data-tooltip", name);
			  tdType.classList.add("has-tooltip");
		    } else {
		      tdType.textContent = name;
		    }
		    tr.appendChild(tdType);

		    list.appendChild(tr);
		  });
	}
</script>
