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
<title>비밀번호 변경</title>
<script type="text/javaScript"> 
	
	function fnSave(){
		 
		if( $("#user_id").val() == ""){
			alert("사용자 ID를 입력하세요.!");
			$("#user_id").focus();
			return;
		}else if( $("#user_pw").val() == "") {
			alert("비밀번호를 입력하세요.!");
			$("#user_pw").focus();
			return;
		}else if( $("#bf_user_pwd").val() != $("#af_user_pwd").val()) {
			alert("변경할 비밀번호를 확인하세요.!");
			$("#bf_user_pwd").focus();
			return;
		}

		var formData = $("form[name='regForm']").serialize();

		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/json/user/pwdchgAct.do",
			data : formData,
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
					alert("비밀번호가 변경되었습니다.");
					window.close(); 
				}
			}
		}); 
		
	}

</script>    
 
</head>

<body>  
  
  <div id="login" class="container">

    <div class="set-pass-box">
      <div class="set-pass-wrap">
       <form:form commandName="DTO" id="regForm" name="regForm" method="post">
        <h3>비밀번호 변경</h3>
        <div class="pass-box w-100">
          <input name="user_id" class="form-control" type="text" id="user_id" placeholder="사용자ID">
          <input type="password" class="form-control mt-2" id="user_pw" name="user_pw" placeholder="현재 비밀번호">
          <input type="password" class="form-control mt-2" id="bf_user_pwd" name="bf_user_pwd"  placeholder="변경 비밀번호">
          <input type="password" class="form-control mt-2" id="af_user_pwd" name="af_user_pwd"  placeholder="변경 비밀번호 확인">
        </div>
		</form:form>
        <div class="set-btn-box w-100">
          <button type="button" class="btn btn-outline-dark" onclick="window.close();">취소</button>
          <button type="button" class="btn btn-primary" onclick="javascript:fnSave();">변경</button>
        </div>
      </div>
    </div>

  </div>


  </body>
</html>
