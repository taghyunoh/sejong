<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>  
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="decorator" uri="http://www.opensymphony.com/sitemesh/decorator" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/page" prefix="page" %>
<%@ page import ="java.util.Date" %>
<%
	Date nowTime = new Date();
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<%@ include file="/WEB-INF/jsp/main/com/head.jsp"%>     

<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> </meta>
<meta http-equiv="X-UA-Compatible" content="IE=edge"> </meta>
<meta name="description" content="">  </meta>

<!-- 부트스트랩 js -->
<script type="text/javascript" src="/bootstrap/js/bootstrap.bundle.js"></script> 
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<!-- datepicker js -->
<script type="text/javascript" src="/asset/js/datepicker/jquery.min.js"></script>
<script type="text/javascript" src="/asset/js/datepicker/moment.min.js"></script>
<script type="text/javascript" src="/asset/js/datepicker/daterangepicker.min.js"></script>
<!-- Page js -->   
<script type="text/javascript" src="/asset/js/pagination.js"></script>
<!-- 데이트피커 년월 js -->
<script type="text/javascript" src="/asset/js/monthpicker/bootstrap-monthpicker.js"></script>
<script src="/js/layout.js"></script>   
<script src="/js/common.js"></script> 
<script type="text/javascript" src='/asset/js/jquery/common.js'></script>

<script type="text/javascript">
 sessionStorage.setItem("contextPath", '<c:out value="${pageContext.request.contextPath}"/>');
</script>

<!-- Font 및 animate 추후 수정  -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" />
<link rel="stylesheet" type="text/css" href="<c:url value='/asset/css/style.css'/>"/>	
	
<!-- JQuery 관련 -->
<!-- <script type="text/javascript" src='/asset/js/jquery/common.js'></script>  --> 
<script type="text/javascript" src="<c:url value='/asset/js/jquery/common.js'/>"></script> 
<link   rel="stylesheet" href="/js/jquery/grid/css/jquery-ui.css" />
<script type="text/javascript" src="<c:url value='/asset/js/jquery-3.5.1.min.js'/>"></script> 
<script type="text/javascript" src="<c:url value='/asset/js/commonUtil.js'/>?date=<%= nowTime %>"></script> 
<script type="text/javascript" src="<c:url value='/asset/js/app-common.js'/>?date=<%= nowTime %>"></script> 
<script type="text/javascript" src="<c:url value='/asset/js/plugins.min.js'/>"></script>
<script type="text/javascript" src="<c:url value='/asset/js/default.js'/>"></script>
<script type="text/javascript" src="<c:url value='/asset/js/tmpl.min.js' />"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script> 
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>  
</head>  
<body>
<!-- 페이지 콘텐츠를 동적으로 업데이트할 div  -->
 <div id="contentArea"> 
 
  <nav class="navbar navbar-expand-lg bg-primary-v1 gnb-container"> 
    <div class="container-fluid">
         <div class="logo-wrap">
               <img src="/asset/img/logo_01.png" alt="allCare" />
        </div> 
      <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav">
			<c:if test="${sessionScope['q_admin_yn'] == 'A'}">
	          	<li class="menu-item" data-menu="01">
		           	<a href="javascript:void(0);" onclick="loadPage('/admin/admin_ptList.do');"><button class="btn" type="button">회원자료관리</button></a> 
	          	</li>
	          	<li class="menu-item" data-menu="02">
           			<a href="javascript:void(0);" onclick="loadPage('/admin/admin_noticeList.do');"><button class="btn" type="button">공지사항관리</button></a>
           		</li>
	          	<li class="menu-item" data-menu="03">
           			<a href="javascript:void(0);" onclick="loadPage('/admin/admin_faqList.do');"><button class="btn" type="button">FAQ관리</button></a>
           		</li>
	          	<li class="menu-item" data-menu="04">
           			<a href="javascript:void(0);" onclick="loadPage('/admin/admin_auserList.do');"><button class="btn" type="button">사용자관리</button></a>
           		</li>
	          	<li class="menu-item" data-menu="05">
           			<a href="javascript:void(0);" onclick="loadPage('/admin/admin_commList.do');"><button class="btn" type="button">기준정보관리</button></a>
           		</li>
	          	<li class="menu-item" data-menu="06">
           			<a href="javascript:void(0);" onclick="loadPage('/doctor/serviceInfo.do');"><button class="btn" type="button">서비스정보</button></a>
           		</li>
            </c:if>
			<c:if test="${sessionScope['q_admin_yn'] == 'D'}">
	          	<li class="menu-item" data-menu="01">
		           	<a href="javascript:void(0);" onclick="loadPage('/doctor/ptList.do');"><button id="myButton" class="btn" type="button">회원 관리</button></a>  
	          	</li>
	          	<li class="menu-item" data-menu="02">
           			<a href="javascript:void(0);" onclick="loadPage('/doctor/noticeList.do');"><button class="btn" type="button">공지사항</button></a>
           		</li>
	          	<li class="menu-item" data-menu="03">
           			<a href="javascript:void(0);" onclick="loadPage('/doctor/faq.do');"><button class="btn" type="button">FAQ</button></a>
           		</li>
	          	<li class="menu-item" data-menu="04">
           			<a href="javascript:void(0);" onclick="loadPage('/doctor/serviceInfo.do');"><button class="btn" type="button">서비스정보</button></a>
           		</li>
            </c:if>
        </ul>
      </div>
      <div class="login-info">
			<span class="user-name">${sessionScope['q_user_nm']}님</span>
        <button class="btn btn-sm btn-outline-dark" onclick="javascript:fnPwdChange();">비밀번호 변경</button> 
        <a class="logout" href="/user/loginOutAct.do">
          <img src="/asset/img/icon_logout_white.png" alt="로그아웃" />
        </a>
      </div>
    </nav>
    
  </div>
</body>
<script>
  // 메뉴 클릭 시 AJAX로 페이지 콘텐츠 로드
  function loadPage(url, clickedElement) {
    // 중복된 메뉴를 방지하려면 기존에 로드된 콘텐츠를 지웁니다
    $('#contentArea').empty(); // 기존 콘텐츠 제거

    // 메뉴가 이미 로드된 상태에서 클릭한 메뉴의 콘텐츠를 다시 로드하지 않도록 처리
    $(clickedElement).closest('li').addClass('active').siblings().removeClass('active');

    $.ajax({
      url: url,  // 요청할 URL
      method: "GET",  // HTTP 메소드
      success: function(response) {
        // 서버에서 받은 HTML을 contentArea에 삽입
        $('#contentArea').html(response);
      },
      error: function(xhr, status, error) {
        alert("페이지 로드 실패: " + error);
      }
    });
  }
</script>

<script type="text/javascript"> 
//--주메인 화면 들어오자마자 환자목록 뛰우기 jsp 에서는 변수처리 않됨 글로발 세션처리 한번만 타게 
//  window.onload 만 실행하면 반복적으로 실행되는 문제 처리  window.onload = null 않됨  
//
window.onload = function(){
    handleMenuClick() ;
} 
function handleMenuClick() {
 // controller단 에서 한번타고 admingu 초기화 
  if ("${sessionScope['admingu']}" == 'D')  {
	   document.getElementById("myButton").click();
  }
//  window.onload = null ;
}
$(document).ready(function () {
    $('.menu-item').click(function () {
    $('.menu-item').removeClass('on');
    $(this).addClass('on');
  
   });
});

//비밀번호 초기화
function fnPwdChange(){ 
	
	var popupwidth = '550';
	var popupheight = '400';  
	var url = "/popup/Hpwdchg.do";   
	 		
	var LeftPosition = (screen.width-popupwidth)/2;
	var TopPosition  = (screen.height-popupheight)/2; 
	var oPopup = window.open(url,"비밀번호변경","width="+popupwidth+",height="+popupheight+",top="+TopPosition+",left="+LeftPosition+", scrollbars=no");
	if(oPopup){oPopup.focus();}
	   
}
                                 
</script>  
</html>
 