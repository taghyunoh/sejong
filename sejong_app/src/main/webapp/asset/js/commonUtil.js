(function(global,$){
	'use strict';
	
	var CommonUtil = global.CommonUtil = {
		
		getContextPath : function () {
			return sessionStorage.getItem("contextPath");
		},
		
		callAjax : function(url,type,data,callbackSuccess){
			$.ajax({
				url:url,
				type: type,
				data: JSON.stringify(data),
				dataType: 'json',
				cache: false,
				global: true,
				contentType: 'application/json;charset=UTF-8',
				beforesend: function(xmlHttpRequest){
					xmlHttpRequest.setRequestHeader("AJAX","true");
				},
				success: function(response,status,xhr){
					if(callbackSuccess != null){
						callbackSuccess(response,status,xhr);
					}
				},
				error: function(xhr,status,errorThrown){
					if(xhr.status == 200){
						// getContextPath 는 함수다. 괄호 없이 쓰면 함수 소스코드가 문자열로 붙어
						// `/function () {return sessionStorage.getItem("contextPath");}/index.do` 로 이동한다.
						// [2026-07-11 근본UX] 200인데 JSON 파싱실패 시 index.do(→홈) 자동 튕김 제거.
						//   튕기지 않고 로그만 남겨 화면 유지. (연속혈당 등에서 홈/빈화면 튕김의 뿌리)
						console.warn("[commonUtil] 200 non-JSON 응답 — 자동 이동 억제. url=", url);
						return false;
					}
					
					var rData = xhr.responseJSON || '서비스 수행 중 오류가 발생했습니다.';
					//CommonJS.showError(rData);
				}
			})
		},
		
		callSyncAjax : function(url,type,data,callbackSuccess){
			$.ajax({
				url:url,
				type: type,
				data: JSON.stringify(data),
				dataType: 'json',
				cache: false,
				async: false,
				contentType: 'application/json;charset=UTF-8',
				beforesend: function(xmlHttpRequest){
					xmlHttpRequest.setRequestHeader("AJAX","true");
				},
				success: function(response,status,xhr){
					if(callbackSuccess != null){
						callbackSuccess(response,status,xhr);
					}
				},
				error: function(xhr,status,errorThrown){
					if(xhr.status == 200){
						// getContextPath 는 함수다. 괄호 없이 쓰면 함수 소스코드가 문자열로 붙어
						// `/function () {return sessionStorage.getItem("contextPath");}/index.do` 로 이동한다.
						// [2026-07-11 근본UX] 200인데 JSON 파싱실패 시 index.do(→홈) 자동 튕김 제거.
						//   튕기지 않고 로그만 남겨 화면 유지. (연속혈당 등에서 홈/빈화면 튕김의 뿌리)
						console.warn("[commonUtil] 200 non-JSON 응답 — 자동 이동 억제. url=", url);
						return false;
					}
					
					var rData = xhr.responseJSON || '서비스 수행 중 오류가 발생했습니다.';
					//CommonJS.showError(rData);
				}
			})
		},


	}

	// [세션 만료 전역 처리]
	//   서버 SessionCheckInterceptor 가 세션 만료 시 AJAX 응답을 401(sessionExpired) 로 준다.
	//   모든 jQuery $.ajax(callAjax/callSyncAjax/직접호출)는 전역 ajaxError 를 거치므로
	//   여기서 한 번만 잡아 로그인 화면으로 보낸다.
	//   → 자동로그인 켠 사용자는 loginPage 진입 즉시 저장된 폰번호로 재로그인되어 자연 복구된다.
	if ($ && typeof $.fn !== "undefined") {
		var _sessionRedirecting = false;
		$(document).ajaxError(function(event, xhr){
			if (xhr && xhr.status === 401 && !_sessionRedirecting) {
				_sessionRedirecting = true;
				var ctx = sessionStorage.getItem("contextPath") || "";
				// 이미 로그인 화면이면 다시 이동하지 않음(무한 새로고침 방지)
				if (location.pathname.indexOf("/loginPage.do") === -1) {
					location.href = ctx + "/loginPage.do";
				}
			}
		});
	}

})(window,window.jQuery);