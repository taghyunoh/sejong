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
<title>로그인 페이지</title>
<script type="text/javaScript"> 

window.onload = function() {
	
    var userIdInput = document.getElementById("user_id");
    // Check if the user_id field has a value
    if (userIdInput.value.trim() !== "") {
     // userIdInput.disabled = true;  // Disable the input field if it has a value
    } else {
      userIdInput.disabled = false;  // Enable the input field if it's empty
    }
  };
  
	function fnSave(){
		 
		if( $("#pass_wd").val() == "") {
			alert("비밀번호를 입력하세요.!");
			$("#pass_wd").focus();
			return;
		}else if( $("#bf_pass_wd").val() != $("#af_pass_wd").val()) {
			alert("변경할 비밀번호를 확인하세요.!");
			$("#bf_user_pwd").focus();
			return;
		}

		var formData = $("form[name='regForm']").serialize();
		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/base/pwdchgAct.do",
			data : formData,
			dataType : "json",
			success : function(data) {
				if(data.error_code != "0") {
					alert(data.error_msg);
					return;
				}
				alert("비밀번호가 변경되었습니다.");
				window.close(); 
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
	        <div class="pass-box w-100">                                               <!--  "${sessionScope['q_user_id']}"  -->
			  <input type="text" name="user_id" class="form-control mt-2" id="user_id"  value="" placeholder="사용자ID"/>
	          <input type="password" class="form-control mt-2" id="pass_wd" name="pass_wd" placeholder="현재 비밀번호">
	          <input type="password" class="form-control mt-2" id="bf_pass_wd" name="bf_pass_wd"  placeholder="변경 비밀번호">
	          <input type="password" class="form-control mt-2" id="af_pass_wd" name="af_pass_wd"  placeholder="변경 비밀번호 확인">
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
