<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

    <div id="content">
        <!-- [2026-07-11] 흰 빈화면 방지 폴백 안내.
             정상 페이지는 tiles가 본문을 직접 렌더하므로 이 셸이 안 보이고,
             콘텐츠가 채워지지 않은 상태(리다이렉트/로드실패 등)에서만 이 안내가 노출됨. -->
        <div class="content-empty-fallback"
             style="display:flex; flex-direction:column; align-items:center; justify-content:center;
                    min-height:60vh; padding:32px 24px; box-sizing:border-box; text-align:center; color:#8a94a6;">
            <div style="font-size:44px; line-height:1; margin-bottom:14px;">💧</div>
            <div style="font-size:16px; font-weight:700; color:#5b6472; margin-bottom:8px;">표시할 내용이 없습니다</div>
            <div style="font-size:13px; line-height:1.6;">
                혈당기(CGM 센서)를 착용하면 측정값이 표시됩니다.<br>
                화면이 계속 비어 있으면 아래 메뉴에서 다시 선택해 주세요.
            </div>
        </div>
    </div>
