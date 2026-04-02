<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>  
<%@ page import = "java.util.*" %>
<!DOCTYPE html>
<html>
 <head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" /> 
<!-- Bootstrap CSS -->
<link href="/bootstrap/css/bootstrap.css" rel="stylesheet">
<link href="/asset/css/common.css" rel="stylesheet">
<link href="/css/login.css" rel="stylesheet">
<!-- 부트스트랩 js -->
<script src="/bootstrap/js/bootstrap.bundle.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<script type="text/javascript" src='/js/jqgrid_common.js'></script> 
<script type="text/javascript" src='/js/jquery/common.js'></script> 
<title>비밀번호 초기화</title>
<script type="text/javaScript"> 
	
	function fnSave(){ 
		 
		if( $("#user_id").val() == ""){
			alert("사용자 ID를 입력하세요.!");
			$("#user_id").focus();
			return;
		}
		
		if(!confirm("해당 사용자의 비밀번호를 초기화하시겠습니까?")) return;
		
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/json/user/pwdresetAct.do",
			data : {user_id : $("#user_id").val()},
			dataType : "json",
			success : function(data) {   
				if(data.error_code != "0"){
					if(data.error_code == "20000"){ 
						alert(data.error_msg);
						$("#user_id").focus();
					}	
					else{ 
						alert(data.error_msg);
						$("#user_id").focus();
					}
				}else{
					alert("비밀번호가 '1234'로 초기화되었습니다.\n비밀번호를 변경 후 로그인 하세요.");
					
					fnPwdChange();
				}
			}
		}); 
		
	}
	function fnPwdChange(){ 
		var popupwidth = '550';
		var popupheight = '400';  
		var url = CommonUtil.getContextPath() + "/popup/pwdchg.do";   
		 		
		var LeftPosition = (screen.width-popupwidth)/2;
		var TopPosition  = (screen.height-popupheight)/2; 
		var oPopup = window.open(url,"비밀번호변경","width="+popupwidth+",height="+popupheight+",top="+TopPosition+",left="+LeftPosition+", scrollbars=no");
		if(oPopup){oPopup.focus();}
		   
	}
</script>    
 
</head>

<body>  
  
  <div id="login" class="container">

    <div class="set-pass-box">
      <div class="set-pass-wrap">
        <h3>비밀번호 초기화</h3>
        <div class="pass-box w-100">
          <input name="user_id" class="form-control" type="text" id="user_id" placeholder="사용자ID" aria-label="사용자ID"> 
        </div> 
        <div class="set-btn-box w-100">
          <button type="button" class="btn btn-outline-dark" onclick="window.close();">취소</button>
          <button type="button" class="btn btn-primary" onclick="javascript:fnSave();">변경</button>
        </div>
      </div>
    </div>

  </div>


  </body>
</html>
