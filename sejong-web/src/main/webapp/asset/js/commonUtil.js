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
						location.href = CommonUtil.getContextPath + "/index.do";
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
						location.href = CommonUtil.getContextPath + "/index.do";
						return false;
					}
					
					var rData = xhr.responseJSON || '서비스 수행 중 오류가 발생했습니다.';
					//CommonJS.showError(rData);
				}
			})
		},
		
		
	}
	
})(window,window.jQuery);