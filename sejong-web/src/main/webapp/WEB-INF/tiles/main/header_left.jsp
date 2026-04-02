<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>  

<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="decorator" uri="http://www.opensymphony.com/sitemesh/decorator" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/page" prefix="page" %>  
	
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <link href="lnb_menu.css" rel="stylesheet" />
<%@ include file="/WEB-INF/jsp/main/com/head.jsp"%>    
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
<script type="text/javascript">
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
$(document).ready(function () {
    $('.menu-item').click(function () {
      $('.menu-item').removeClass('on');
      $(this).addClass('on');
    });
  });

</script>   
  <nav class="lnb-menu bg-light vh-100">
    <div class="lnb-wrap" id="lnb">
    	<div class="logo-wrap">
       		<img src="/asset/img/logo_01.png" alt="allCare" />
     	</div><br><br>
      <ul class="lnb-nav">
      <c:if test="${sessionScope['q_admin_yn'] == 'A'}">
	          	<li class="menu-item " data-menu="01">
		           	<a href="/admin/admin_ptList.do"><button class="btn" type="button">회원자료관리</button></a>
	          	</li><div class="line"></div>
	          	<li class="menu-item " data-menu="02">
           			<a href="/admin/admin_noticeList.do"><button class="btn" type="button">공지사항관리</button></a>
           		</li><div class="line"></div>
	          	<li class="menu-item " data-menu="03">
           			<a href="/admin/admin_faqList.do"><button class="btn" type="button">FAQ관리</button></a>
           		</li><div class="line"></div>
	          	<li class="menu-item " data-menu="04">
           			<a href="/admin/admin_auserList.do"><button class="btn" type="button">사용자관리</button></a>
           		</li><div class="line"></div>
	          	<li class="menu-item " data-menu="05">
           			<a href="/admin/admin_commList.do"><button class="btn" type="button">기준정보관리</button></a>
           		</li><div class="line"></div>
	          	<li class="menu-item " data-menu="06">
           			<a href="/doctor/serviceInfo.do"><button class="btn" type="button">서비스정보</button></a>
           		</li>
            </c:if>
			<c:if test="${sessionScope['q_admin_yn'] == 'D'}">
	          	<li class="menu-item " data-menu="01">
		           	<a href="/doctor/ptList.do"><button class="btn" type="button">회원 관리</button></a>
	          	</li><div class="line"></div>
	          	<li class="menu-item " data-menu="02">
           			<a  href="/doctor/noticeList.do"><button class="btn" type="button">공지사항</button></a>
           		</li><div class="line"></div>
	          	<li class="menu-item " data-menu="03">
           			<a href="/doctor/faq.do"><button class="btn" type="button" >FAQ</button></a>
           		</li><div class="line"></div>
	          	<li class="menu-item " data-menu="04">
           			<a  href="/doctor/serviceInfo.do"><button class="btn" type="button">서비스정보</button></a>
           		</li>
            </c:if>
            <li class="menu-item " data-menu="07">  <br><br></br><br><br><br><br><br><br><br><br><br><br><br><br><br></li>
			<li class="menu-item " data-menu="13"><span class="user-name">${sessionScope['q_user_nm']}님 &emsp;</span>
    		<a class="logout" href="/user/loginOutAct.do">
      			<button class="btn btn-sm btn-outline-dark">로그아웃</button> 
     		</a>
     		</li>
     		<button class="btn btn-sm btn-outline-dark" onclick="javascript:fnPwdChange();">비밀번호 변경</button> 
      		
        <!-- 로그인 정보 edn -->
      </ul>
    </div>
  </nav> 
</head>   

</html>
 