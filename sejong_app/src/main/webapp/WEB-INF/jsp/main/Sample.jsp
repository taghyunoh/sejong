<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div>
	<h1>Sample Page</h1>
	<button class="login__btn" id="blodBtn">혈당연동</button>
	<button class="login__btn" id="cameraBtn">푸드카메라</button>
	<button class="login__btn" id="foodDetailBtn" value="15">상세보기</button>
	<p id="FoodData">Data</p>
</div>
<script>
/* console.log("Sample");
console.log(CommonUtil.getContextPath());
var data = '{"eatDate":"2024-08-09 16:30:41","eatType":5,"foodPositionList":[{"eatAmount":1.0,"foodCandidates":[{"foodId":5698,"foodName":"마가렛트","keyName":"margaret","manufacturer":"롯데제과(주)","nutrition":{"calcium":0.0,"calories":110.0,"carbonhydrate":13.0,"cholesterol":5.0,"customFoodInfo":false,"dietrayfiber":0.0,"fat":6.0,"foodtype":"","protein":1.0,"rawCalories":0.0,"rawTotalGram":0.0,"saturatedfat":3.0,"sodium":60.0,"sugar":6.0,"totalgram":22.0,"transfat":0.2,"unit":"봉","vitamina":0.0,"vitaminb":0.0,"vitaminc":0.0,"vitamind":0.0,"vitamine":0.0}},{"foodId":278,"foodName":"호두파이","keyName":"walnut_pie","manufacturer":""},{"foodId":2362,"foodName":"초코아이스크림","keyName":"ice_cream_choco","manufacturer":""},{"foodId":6298,"foodName":"마켓오 리얼 브라우니","keyName":"orion_real_brownie","manufacturer":"오리온"},{"foodId":13535,"foodName":"오븐에구운도넛","keyName":"pocketdosilak_oven_doughnut","manufacturer":"삼립식품"}],"foodImagepath":"/data/user/0/com.dca.sejong/files/temp/0.jpg","imagePosition":{"xmax":865,"xmin":39,"ymax":1015,"ymin":60},"userSelectedFood":{"foodId":5698,"foodName":"마가렛트","keyName":"margaret","nutrition":{"calcium":0.0,"calories":110.0,"carbonhydrate":13.0,"cholesterol":5.0,"customFoodInfo":false,"dietrayfiber":0.0,"fat":6.0,"foodtype":"","protein":1.0,"rawCalories":0.0,"rawTotalGram":0.0,"saturatedfat":3.0,"sodium":60.0,"sugar":6.0,"totalgram":22.0,"transfat":0.2,"unit":"봉","vitamina":0.0,"vitaminb":0.0,"vitaminc":0.0,"vitamind":0.0,"vitamine":0.0}}},{"eatAmount":1.0,"foodCandidates":[{"foodId":56,"foodName":"김치볶음밥","keyName":"kimchi_fryed_rice","nutrition":{"calcium":51.25,"calories":432.8,"carbonhydrate":72.0,"cholesterol":13.37,"customFoodInfo":false,"dietrayfiber":3.32,"fat":8.5,"foodtype":"","protein":13.8,"rawCalories":0.0,"rawTotalGram":0.0,"saturatedfat":1.42,"sodium":434.0,"sugar":2.64,"totalgram":329.0,"transfat":0.08,"unit":"공기","vitamina":69.99,"vitaminb":0.16,"vitaminc":6.71,"vitamind":0.0,"vitamine":4.06}}],"userSelectedFood":{"foodId":56,"foodName":"김치볶음밥","keyName":"kimchi_fryed_rice","nutrition":{"calcium":51.25,"calories":432.8,"carbonhydrate":72.0,"cholesterol":13.37,"customFoodInfo":false,"dietrayfiber":3.32,"fat":8.5,"foodtype":"","protein":13.8,"rawCalories":0.0,"rawTotalGram":0.0,"saturatedfat":1.42,"sodium":434.0,"sugar":2.64,"totalgram":329.0,"transfat":0.08,"unit":"공기","vitamina":69.99,"vitaminb":0.16,"vitaminc":6.71,"vitamind":0.0,"vitamine":4.06}}},{"eatAmount":1.0,"foodCandidates":[{"foodId":799,"foodName":"닭가슴살","keyName":"chicken_breast_boiled","nutrition":{"calcium":1.8,"calories":57.6,"carbonhydrate":0.0,"cholesterol":33.54,"customFoodInfo":false,"dietrayfiber":0.0,"fat":0.4,"foodtype":"","protein":12.6,"rawCalories":0.0,"rawTotalGram":0.0,"saturatedfat":0.17,"sodium":18.0,"sugar":0.0,"totalgram":45.0,"transfat":0.0,"unit":"접시(소)","vitamina":3.6,"vitaminb":0.09,"vitaminc":0.0,"vitamind":0.0,"vitamine":0.03}}],"userSelectedFood":{"foodId":799,"foodName":"닭가슴살","keyName":"chicken_breast_boiled","nutrition":{"calcium":1.8,"calories":57.6,"carbonhydrate":0.0,"cholesterol":33.54,"customFoodInfo":false,"dietrayfiber":0.0,"fat":0.4,"foodtype":"","protein":12.6,"rawCalories":0.0,"rawTotalGram":0.0,"saturatedfat":0.17,"sodium":18.0,"sugar":0.0,"totalgram":45.0,"transfat":0.0,"unit":"접시(소)","vitamina":3.6,"vitaminb":0.09,"vitaminc":0.0,"vitamind":0.0,"vitamine":0.03}}}],"mealType":"afternoon_snack","predictedImagePath":"/data/user/0/com.dca.sejong/files/temp/orgimg.jpg","version":1}';
//console.log(data);
console.log(JSON.parse(data));
console.log(JSON.stringify(data));
var data2 = {};
data2.eatDate = "2024-08-09";
data2.test = "assd";
console.log(data2);
console.log(JSON.stringify(data2)); 
//JSON.parse(data)
CommonUtil.callAjax(CommonUtil.getContextPath() + "/insertFoodData.do","POST",data,function(response){
	console.log(response);
}) */

$("#blodBtn").click(function () {
	console.log("혈당연동버튼 클릭 ");
	callAndroid2("f200");
});

$("#cameraBtn").click(function () {
	console.log("푸드카메라버튼 클릭 ");
	callAndroid2("f201");
});

$("#foodDetailBtn").click(function () {
	console.log("상세보기버튼 클릭 ");
	const data ={};
	data.foodhisSeq = $("#foodDetailBtn").val();
	console.log(data);
	CommonUtil.callAjax(CommonUtil.getContextPath() + "/getFoodDetail.do","POST",data,function(response){
		console.log(JSON.parse(response.Data));
		const appData = {};
		appData.result = JSON.parse(response.Data);
		callAndroid("f202",appData);
	});
});
</script>