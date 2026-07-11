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
	
})(window,window.jQuery);