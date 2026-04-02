<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
	Date nowTime = new Date();
	SimpleDateFormat sf = new SimpleDateFormat("yyyyMMdd");
%>
<!-- contents : s -->
 <div class="contents">
   <div class="lyInner">

     <!-- 혈당알림 / 시스템 공지 탭 -->
     <div class="tabGroup hide">
       <ul class="tabs">
         <li class="on">
           <a href="#"><span>혈당 알림</span></a>
         </li>
         <li class="">
           <a href="#"><span>시스템 공지</span></a>
         </li>
       </ul>
     </div>
     <!-- //혈당알림 / 시스템 공지 탭 -->

     <p class="filterTxt" id="notiCnt"></p>


     <!-- 시스템 공지 -->
     <ul class="noticeList" id="notiSection">
     </ul>
     <!-- //시스템 공지 -->
     <!-- <div class="btnArea tac">
       <a href="#" class="btn btnMore">더보기 ( <em>1</em> / 10 )</a>
     </div> -->
   </div>
 </div>
 <!-- contents : e -->
<script type="text/x-tmpl" id="template-notiList">
	{% for(var i = 0, data; data = o[i]; i++){ %}
     <li class="cardItem notice">
         <a href="#" onclick="notiDetail({%=data.notiSeq%});">
           <p class="date">{%=data.regDtm%}</p>
           <p class="title ellipsis">{%=data.title%}</p>
         </a>
       </li>
	{% } %}
</script>
 <script>
 $(document).ready(function() {
	 CommonUtil.callAjax(CommonUtil.getContextPath() + "/getNotiList.do","POST",'',function(response){
			console.log(response);
			$("#notiCnt").text("전체 ("+response.Data.length +")")
			$("#notiSection").empty();
			$("#notiSection").append(tmpl("template-notiList",response.Data));
	 });
 });
 
 function notiDetail(seq){
	 console.log(seq);
	 location.href = CommonUtil.getContextPath() + "/notiDetail.do?notiSeq="+seq;
 }
 </script>