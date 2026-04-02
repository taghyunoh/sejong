<%-- <%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
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
<title>로그인</title>
<script type="text/javaScript"> 
/*  Main Grid  *//*서브그리드 필요*/
$(document).ready(function(){ 
	$("#user_id2").focus();
});
 
function loginproc2(){
	 
	if( $("#user_id").val() == ""){
		alert("사용자 ID를 입력하세요.!");
		$("#user_id").focus();
		return;
	}else if( $("#user_pw").val() == "") {
		alert("비밀번호를 입력하세요.!");
		$("#user_pw").focus();
		return;
	}
	//location.href="/com/main.do" ;
	
	$.ajax( {
		type : "post",
		url : "/user/loginAct.do",
		data : {user_id : $("#user_id").val(), 
			    user_pw : $("#user_pw").val()},
		dataType : "json",
		success : function(data) {   
			
			if(data.error_code != "00000"){
				if(data.error_code == "20000"){ 
					alert(data.error_msg);
					$("#user_id").focus();
				}else if(data.error_code == "10000"){   //비밀번호 초기화 
					alert(data.error_msg);
					fnPwdChange();
				}	
				else{  
					alert(data.error_msg);
					$("#user_id").focus();
				}
			}else{
				//메인페이지로 이동
				location.href="/main.do" 
			}
		} 
	});
 
}
function logout(){
	$.ajax( {
		type : "post",
		url : "/com/loginOut.do",
		dataType : "json",
		success : function(data) {
		}
		})
		location.reload();		
}

function hitEnterKey(e){
	
	  if(e.keyCode == 13){ 
		loginproc2();
	  }else{
	   	e.keyCode == 0;
	  	return;
	  }
}  

function fnPwdChange(){ 
	
	var popupwidth = '550';
	var popupheight = '400';  
	var url = "/popup/pwdchg.do";   
	 		
	var LeftPosition = (screen.width-popupwidth)/2;
	var TopPosition  = (screen.height-popupheight)/2; 
	var oPopup = window.open(url,"비밀번호변경","width="+popupwidth+",height="+popupheight+",top="+TopPosition+",left="+LeftPosition+", scrollbars=no");
	if(oPopup){oPopup.focus();}
	   
}

//비밀번호 초기화
function fnPwdClear(){ 

	var popupwidth = '500';
	var popupheight = '200'; 
	var url = "";  

	url = "/popup/pwdclear.do";
	 		
 	var LeftPosition = (screen.width-popupwidth)/2;
	var TopPosition  = (screen.height-popupheight)/2;

	var oPopup = window.open(url,"비밀번호변경","width="+popupwidth+",height="+popupheight+",top="+TopPosition+",left="+LeftPosition+", scrollbars=no");
	if(oPopup){oPopup.focus();}
   
}

</script>    
 
</head>

<body> 
<div class="layout">
		<tiles:insertAttribute name="nolayout" />
	</div>
  <div id="login" class="container">

    <div class="login-box">
      <div class="login-wrap">
        <h1>진료비 분석 시스템</h1>
        <div class="id-box w-100">
          <input name="user_id" class="form-control" type="text" id="user_id" placeholder="사용자ID" aria-label="사용자ID">
          <input type="password" class="form-control mt-3" id="user_pw" placeholder="비밀번호" onKeypress="hitEnterKey(event);">
        </div>
        
        <button type="submit" class="btn btn-primary btn-lg w-100 mt-2" onclick="javascript:loginproc2();">로그인</button>
       
        <div class="set-btn-box  w-100">
          
          	<button type="button" class="btn btn-outline-dark" onclick="javascript:fnPwdClear();">비밀번호 초기화</button> 
          	<button type="button" class="btn btn-outline-dark" onclick="javascript:fnPwdChange();">비밀번호 변경</button> 
        </div>
      </div>
    </div>

  </div>

  </body>
</html>
 --%>