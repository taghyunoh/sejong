<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet" />
<style>
</style>
<!-- wrap : s -->
 <div class="wrap main">
	<header class="header">
     <div class="alignTitle">
       <a href="#" class="logo"></a>
       <span>일상속의 자유로운 건강관리</span>
     </div>
      <div class="menuWrap">
        <div class="topArea">
          <div class="user util" onclick="javascript:">
          <div class="name"><strong id="subName"></strong><span>님</span>
            <div class="item notice">
              알림<span class="">새로운 알림</span>
            </div>
          </div>
          <a href="#" class="menuClose"></a>
        </div>
      </div>
      <div class="menuList">
        <div class="menu_row">
          <a class="menu_box" href="<c:url value='/goBloodPage.do'/>">
            <p class="img_box">
              <img src="<c:url value='/asset/images/common/img_menu_blood.png'/> " alt="연속혈당">
            </p>
            <span>연속혈당</span>
          </a>
          <a class="menu_box" href="<c:url value='/foodMain.do'/> ">
            <p class="img_box">
              <img src="<c:url value='/asset/images/common/img_menu_food.png'/> " alt="식사관리">
            </p>
            <span>식사관리</span>
            
          </a>
        </div>
        <div class="menu_row run">
          <a class="menu_box_run" href="<c:url value='/exerMain.do'/> ">
            <span>운동관리</span>
          </a>
        </div>
        <div class="etc_menu_list">
          <a class="etc_wrap" href="<c:url value='noticePage.do'/> ">
            <img src="<c:url value='/asset/images/common/etcmenu_img_notice.png'/> " alt="공지사항">
            <span>공지사항</span>
          </a>
          <a class="etc_wrap" href="<c:url value='faqPage.do'/> ">
            <img src="<c:url value='/asset/images/common/etcmenu_img_faq.png'/> " alt="FAQ">
            <span>FAQ</span>
          </a>
          <a class="etc_wrap" href="<c:url value='asqMain.do'/> ">
            <img src="<c:url value='/asset/images/common/etcmenu_img_qa.png'/> " alt="1:1문의">
            <span>1:1문의</span>
          </a>
          <a class="etc_wrap" href="javascript:layerPop('open' , 'infoChangePopup')">
            <img src="<c:url value='/asset/images/common/etcmenu_img_pinf.png'/> " alt="개인정보">
            <span>개인정보</span>
          </a>
          <a class="etc_wrap" href="<c:url value='settingPage.do'/> ">
            <img src="<c:url value='/asset/images/common/etcmenu_img_set.png'/> " alt="설정">
            <span>설정</span>
          </a>
        </div>
      </div>
    </div>

    <div class="alignRight">
      <a href="#" class="btnMenu"><span>메뉴</span></a>
    </div>
  </header>
   <!-- contents : s -->
   <div class="contents">
     <div class="user"><em class="name" id="name"></em> 반갑습니다.</div>
     <div class="recently">
       <p class="desc">
         혈당관리, 식사관리, 운동관리를 통한 일상속 건강관리를 해보세요.
       </p>
     </div>
     <ul class="dataList">
       <li class="dataItem">
         <a href="<c:url value='/goBloodPage.do'/> " class="inner data01">
           <p class="title">연속혈당</p>
           <div class="blood_wrap mt20">
             <div class="arrow_wrap">
               <span class="material-icons blood_arrow bl_color_stable bl_angle_slowdown">east</span>
               <!-- 화살표의 컬러는 현재 혈당수치에 따라 컬러를 적용 -->
               <!-- 화살표의 각도는 직전 혈당 수치와 비교하여 각도 적용 기획서 표 참고 -->
               <span class="diff" id="diff"></span>
             </div>
             <div class="count">
               <div class="data bl_color_stable" id="nowVal">0</div>
               <div class="time" id="formatedDate"></div>
             </div>
           </div>
           <i class="arrow">바로가기</i>
         </a>
       </li>
       <li class="dataItem">
         <a href="<c:url value='/goBloodPage2.do'/> " class="inner data02">
           <p class="title">혈당분석</p>
           <div class="ave_wrap mt20">
             <div class="ave_count bl_color_stable">
				<div class="title_group">
				  <span class="main_title">혈당/식사/운동 연관분석</span>
				</div>
             </div>
           </div>
           <i class="arrow">바로가기</i>
         </a>
       </li>
     </ul>
     <ul class="dataList">
       <li class="dataItem">
         <a href="<c:url value='/foodConsult.do'/> " class="inner data03">
           <p class="title">식사관리</p>
           <div class="ave_wrap mt20">
	             <div class="ave_count bl_color_stable">
				  <div class="title_group">
					  <span class="main_title">오늘의 식사와</span>
					  <span class="main_title">혈당분석</span>
				  </div>
				</div>
			</div>
           <i class="arrow">바로가기</i>
         </a>
       </li>
       <li class="dataItem">
         <a href="<c:url value='/exerConsult.do'/> " class="inner data04">
           <p class="title">운동관리</p>
             <div class="ave_wrap mt20">
	             <div class="ave_count bl_color_stable">
				  <div class="title_group">
				  <span class="main_title">오늘의 운동과</span>
				  <span class="main_title">혈당분석</span>
                 </div>
             </div>    
           </div>
           <i class="arrow">바로가기</i>
         </a>
       </li>
     </ul>
     <p  class="desc" id="errormsg">  </p>
     <!-- contents : e -->
   </div>

   <!-- footer Nav : s -->
   <nav class="footerNav">
     <ul>
       <li>
         <a href="<c:url value='/mainPage.do'/> ">
           <img src="<c:url value='/asset/images/blood/icon_home.png'/> " alt="">
           <span>홈</span>
         </a>
       </li>
       <li>
         <a href="<c:url value='/goBloodPage.do'/> ">
           <img src="<c:url value='/asset/images/blood/icon_blood.png'/> " alt="">
           <span>연속혈당</span>
         </a>
       </li>
       <li>
         <a href="<c:url value='/foodMain.do'/> ">
           <img src="<c:url value='/asset/images/blood/icon_food.png'/> " alt="">
           <span>식사등록</span>
         </a>
       </li>
       <li>
         <a href="<c:url value='/exerMain.do'/> ">
           <img src="<c:url value='/asset/images/fit/footer.png'/> " alt="">
           <span>운동등록</span>
         </a>
       </li>
     </ul>
   </nav>
   <!-- footer Nav : e -->

 </div>
   <!-- [레] : 의료정보변경 팝업 : s -->
  <div class="popupWrap popupFull infoChangePopup">
    <div class="popupContent popupInner">
      <div class="popupHead">
        <strong class="tit">의료정보변경</strong>
        <a href="javascript:layerPop('close' , 'infoChangePopup')" class="btnPopClose">레이어 닫기</a>
      </div>
      <div class="popupCont">
        <!-- 내용 : s -->
        <div class="form">
          <dl class="formList">
            <dt><span>키</span></dt>
            <dd>
              <div class="inputWrap"><input type="text" class="inpText" id="height" value="" disabled><span
                  class="add_inf">cm</span>
              </div>
            </dd>
          </dl>

          <dl class="formList">
            <dt><span>몸무게</span></dt>
            <dd>
              <div class="inputWrap"><input type="text" class="inpText" id="weight" value=""><span class="add_inf">kg</span>
              </div>
            </dd>
          </dl>
          <dl class="formList hide">
            <dt><span>혈액형</span></dt>
            <dd>
              <div class="selectBoxWrap">
                <select>
                  <option value="1">B+</option>
                </select>
              </div>
            </dd>
          </dl>

          <dl class="formList">
            <dt><span class="vital">당뇨 유형</span></dt>
            <dd>
              <div class="radioWrap typeBox03">
                <span class="inputRadio">
                  <input type="radio" name="rdo_sugar" id="rdo_sugar01" value="1">
                  <label for="rdo_sugar01">1형 당뇨병</label>
                </span>
                <span class="inputRadio">
                  <input type="radio" name="rdo_sugar" id="rdo_sugar02" value="2">
                  <label for="rdo_sugar02">2형 당뇨병</label>
                </span>
                <span class="inputRadio">
                  <input type="radio" name="rdo_sugar" id="rdo_sugar03" value="3" checked>
                  <label for="rdo_sugar03">당뇨병 전단계</label>
                </span>
                <span class="inputRadio">
                  <input type="radio" name="rdo_sugar" id="rdo_sugar04" value="4">
                  <label for="rdo_sugar04">임신성 당뇨병</label>
                </span>
                <span class="inputRadio">
                  <input type="radio" name="rdo_sugar" id="rdo_sugar09" value="9">
                  <label for="rdo_sugar09">기타</label>
                </span>
              </div>
            </dd>
          </dl>

          <dl class="formList hide">
            <dt><span>과거력</span></dt>
            <dd>
              <div class="radioWrap typeBox02">
                <span class="inputRadio">
                  <input type="checkbox" id="chk0101" checked />
                  <label for="chk0101">뇌졸증</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0102" />
                  <label for="chk0102">심장병</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0103" />
                  <label for="chk0103">고혈압</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0104" />
                  <label for="chk0104">당뇨병</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0105" />
                  <label for="chk0105">고지혈증</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0106" />
                  <label for="chk0106">폐결핵</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0107" />
                  <label for="chk0107">기타(암포함)</label>
                </span>
              </div>
            </dd>
          </dl>
          <dl class="formList hide">
            <dt><span>가족력</span></dt>
            <dd>
              <div class="radioWrap typeBox02">
                <span class="inputRadio">
                  <input type="checkbox" id="chk0201" checked />
                  <label for="chk0201">뇌졸중</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0202" />
                  <label for="chk0202">심장병</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0203" />
                  <label for="chk0203">고혈압</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0204" />
                  <label for="chk0204">당뇨병</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0205" />
                  <label for="chk0205">간장질환</label>
                </span>
                <span class="inputRadio">
                  <input type="checkbox" id="chk0206" />
                  <label for="chk0206">암</label>
                </span>
              </div>
            </dd>
          </dl>
        </div>
        <!-- 내용 : e -->
      </div>
      <div class="btnArea bottom">
        <a href="javascript:layerPop('close' , 'infoChangePopup')" class="btn btnCol01"><span>취소</span></a>
        <a href="#" onclick="updateUserInfo();" class="btn btnCol02"><span>확인</span></a>
      </div>
    </div>
  </div>
 <!-- wrap : e -->
<script>
var accessToken = "";
var userId = ""; 
var gender;
$(document).ready(function() {
	getUserInfo();
	var userNm = '<%=session.getAttribute("userNm")%>';
	gender = '${gender}';
	if(userNm == null || userNm == "null"){
		location.href = CommonUtil.getContextPath() + "/loginPage.do";
	}
	$("#name").text(userNm+"님");
	$("#subName").text(userNm);

	CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/tokenYn.do","POST",'',function(response){
		if(response.IsSucceed){
			getBloodUserData();
			getBloodData();
		}
	}); 
	todayBlod(); //임시 적용 원래없음 
	
	todayExecs();
	todayFood();
});
function getUserInfo(){
	CommonUtil.callAjax(CommonUtil.getContextPath() + "/getUserInfo.do","POST",'',function(response){
		console.log(response.Data);
		const user = response.Data;
		$("#height").val(user.height);
		$("#weight").val(user.weight);
		$('input:radio[name=rdo_sugar]:input[value='+user.blodGb+']').attr("checked", true);
	});
}

function updateUserInfo(){
	const data = {};
	data.weight = $("#weight").val();
	data.blodGb = $('input[name=rdo_sugar]:checked').val();
	CommonUtil.callAjax(CommonUtil.getContextPath() + "/updateUserInfo.do","POST",data,function(response){
		console.log(response.Data);
		alert("개인정보 설정 완료");
		javascript:layerPop('close' , 'infoChangePopup');
		getUserInfo();
	});
}
function getFormattedDate(date) {
	  const year = date.getFullYear();
	  const month = String(date.getMonth() + 1).padStart(2, '0'); // 월은 0부터 시작하므로 +1
	  const day = String(date.getDate()).padStart(2, '0');
	  const hours = String(date.getHours()).padStart(2, '0');
	  const minutes = String(date.getMinutes()).padStart(2, '0');
	  const seconds = String(date.getSeconds()).padStart(2, '0');

	  const timezoneOffset = -date.getTimezoneOffset(); // 분 단위 오프셋
	  const sign = timezoneOffset >= 0 ? '+' : '-';
	  const offsetHours = String(Math.floor(Math.abs(timezoneOffset) / 60)).padStart(2, '0');
	  const offsetMinutes = String(Math.abs(timezoneOffset) % 60).padStart(2, '0');
	  return year+"-"+month+"-"+day+"T"+hours+":"+minutes+":"+seconds+""+sign+""+offsetHours+":"+offsetMinutes;
	}

function getDateNDaysAgoFormatted(days) {
  const date = new Date();
  date.setDate(date.getDate() - days); // N일 전 날짜로 설정
  return getFormattedDate(date);
}
function getBloodUserData() {
    CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/getBloodUserData.do","POST",'',
  		function(response){
    		console.log(response);
      		accessToken = response.accToken;
      		userId = response.userId;
  		}
  	)
}
//혈당 데이터 가져오기
function getBloodData(){
	  var end = getDateNDaysAgoFormatted(0);
	  var start = getDateNDaysAgoFormatted(1);
	  $.ajax({
		    url: CommonUtil.getContextPath() + '/getBloodData.do',
			type: 'GET',
			async: false,
			data: {
	            start : start,
		        end: end,
	            accessToken : accessToken,
	            goTokenUrl : 'https://cgm.i-sens.com:10200/v1/public/cgms',
				  },
			success: function(response) { 
					const result = JSON.parse(response);
						if(!result.IsSucceed){
							refreshToken();
						}else{
							todayBlod();
							todayBlodAvg();
						}
				    },
			error: function(xhr, status, error) {
				   	console.log('Error: ' + error);
				 	}     
		});    
	    
}
function refreshToken(){
	  CommonUtil.callSyncAjax(CommonUtil.getContextPath() + "/refreshToken.do","POST",'',
			function(response){
				console.log(response);
				if(response.IsSucceed){
					getBloodUserData();
				    getBloodData();
				}
			}
	  
	)
}
function todayBlod() {
    $("#errormsg").empty(); // () 붙여야 정상 동작

    CommonUtil.callAjax(CommonUtil.getContextPath() + "/getTodayBlood.do", "POST", '', function(response) {
        console.log(response);
        const data = response.Data;

        if (data && data.length > 0) {
            $("#formatedDate").text(data[0].formatedDate);
            $("#nowVal").text(data[0].UPT_VALUE);

            if (data.length > 1) {
                const diff = data[0].UPT_VALUE - data[1].UPT_VALUE;
                $("#diff").text(diff);
            } else {
                $("#diff").text(0);
            }

            // 값이 0일 때만 에러메시지 출력
            if (data[0].UPT_VALUE == 0) {
                $("#errormsg").html("연속혈당값이 0입니다.<br/>케어센서 에어에 로그인 해주세요.");
            }

        } else {
            $("#formatedDate").text("-");
            $("#nowVal").text(0);
            $("#diff").text(0);

            $("#errormsg").html("연속혈당값이 전달되지 않고 있습니다.<br/>케어센서 에어에 로그인 해주세요.");
        }
    });
}

function todayBlodAvg(){
	CommonUtil.callAjax(CommonUtil.getContextPath() + "/getTodayBlodAvg.do","POST",'',function(response){
		console.log(response);
		const data = response.Data;
		$("#fastBlod").text(parseInt(data.fastBlod));
		$("#mealBlod").text(parseInt(data.mealBlod));
	});
}
//당일 운동총시간 
function todayExecs() {
    CommonUtil.callAjax(
        CommonUtil.getContextPath() + "/getTodaysumExecs.do",
        "POST",
        {},  // 빈 요청 본문
        function(response) {
            console.log(response);

            var exerName = "";

            if (response && response.Data && Array.isArray(response.Data) && response.Data.length > 0 &&
                response.Data[0].minutes != null
            ) {
                exerName = response.Data[0].minutes + "분";
            }

            $("#execsNow").text(exerName);
        }
    );
}
//당일 시작 총칼로리  
function todayFood(){
	const date = new Date();
	const formattedDate = date.toISOString().split('T')[0].replace(/-/g, '');  

	const data = { start: formattedDate };

    CommonUtil.callAjax(CommonUtil.getContextPath() + "/getTodaysumFood.do", "POST", data, function(response){
        console.log(response);
        var stanCal = "";

        if (response && response.Data && Array.isArray(response.Data) && response.Data.length > 0 &&
            response.Data[0].kCal != null
        ) {
        	stanCal = response.Data[0].kCal ;
        }

        $("#stanCal").text(stanCal);
    });
}

</script>

