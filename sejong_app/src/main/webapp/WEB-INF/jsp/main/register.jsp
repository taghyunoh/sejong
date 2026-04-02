<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">


</head>
<body>
<!-- wrap : s -->
 

    <!-- contents : s -->
    <div class="contents">
    
	<form id="regiForm"  method="POST">
    	<label for="name">name:</label>
    	<input type="text" id="name" name="name" placeholder="Enter your name">
    <br>
    	<label for="password">password:</label>
    	<input type="password" id="password" name="password" placeholder="Enter your password">
    <br>
    	<label for="email">email:</label>
    	<input type="text" id="email" name="email" placeholder="Enter your email">
    <br>
    <div class="time_wrap mt20">
    	<button id="btnRegister"  class="btn btn_sm btnCol06"  >register</button>
    	<button id="getAuth" class="btn btn_sm btnCol06" >1.getAuth</button>	
		<button id="getToken" class="btn btn_sm btnCol06" >2.getToken</button>
		<!--  <button id="updToken" type="button">3.updToken</button>-->
		<button id="authToken" class="btn btn_sm btnCol06">4.authToken</button>
		<!--  <button id="creSampleData" class="btn btn_sm btnCol06" >5.creSampleData</button>-->
		<button id="getBloodData" class="btn btn_sm btnCol06" >6.getBloodData</button>
		<button id="getSensorInfo" class="btn btn_sm btnCol06" >7.getSensorInfo</button>
		</div>
	
	</form>
	</div>

	
	

<script>



		$(document).ready(function() {
		    $('#btnRegister').click(function(event) {
		    event.preventDefault(); // 폼 제출 방지	
			
			
		    var formData = {
				nm : $('#name').val(),
				pw : $('#password').val(),
				email : $('#email').val()
			}
			
			console.log("formData"+ JSON.stringify(formData));
			
		    CommonUtil.callAjax(CommonUtil.getContextPath() + "/register.do","POST",JSON.stringfy(formData),
		    		function(response){console.log(response);}
		    )
		
		    });
	});


		
		$(document).ready(function() {
		    $('#getAuth').click(function(event) {
		        event.preventDefault(); 

		        var formData = {
		            client_id: '6e40317a-7072-49f7-8bfd-e738402d677e',
		            redirect_uri: 'https://f00c-122-39-139-8.ngrok-free.app/goRegisterPage.do'
		        };

		        $.ajax({
		            url: '/getAuth.do',
		            type: 'POST',
		            data: JSON.stringify(formData),
		            contentType: 'application/json',
		            success: function(response) {
		           
		                if (typeof response === "string") {
		                    response = JSON.parse(response);
		                }
		                console.log("Response received from server:", response); // 서버 응답을 콘솔에 출력

		            	
		            	if (response && response.redirectUrl) {
		                    alert('Redirecting to: ' + response.redirectUrl); // 확인 메시지 출력
		                    window.location.href = response.redirectUrl; // 리디렉션 수행
		                } else {
		                    console.log('No redirectUrl found in response');
		                }
		                
		            },
		            error: function(xhr, status, error) {
		                console.log('Error: ' + error);
		            }
		        });
		    });
		});

		var accessToken = "";
		
		$(document).ready(function() {
		    $('#getToken').click(function(event) {
		    	event.preventDefault(); 	
			
		
		    	const urlParams = new URLSearchParams(window.location.search);
		    	console.log("urlParams :" + urlParams);
	
		    
		    	var formData = {
		    		client_id : '6e40317a-7072-49f7-8bfd-e738402d677e',
		    		client_secret : 'cSiZ4u9uZqW7KCuYEi3CyhDPeA5Jf0BI7JHrw-TsoQM',
		    		redirect_uri : 'https://f00c-122-39-139-8.ngrok-free.app',
		    		code : urlParams.get('code')
		    	
				}
			
				console.log("토큰 받아오기 : "+ JSON.stringify(formData));
			
		    	CommonUtil.callAjax(CommonUtil.getContextPath() + "/getToken.do","POST",formData,
		    			function(response){
		    				accessToken = response;
							console.log("accessToken : " + accessToken);
		    			}
		    	)
		    });
		});
		
		/*
		$('#authToken').click(function(event) {
	        event.preventDefault();
	        console.log("44!  accessToken : " + accessToken);
	        
	        CommonUtil.callAjax(CommonUtil.getContextPath() + "/authToken.do","POST",{accessToken : accessToken },
	    			function(response){
	        	 		console.log("auth token success :", response);
	    			}
	    	)
	    	
			
	    });
		*/
		
		var useUUId = "";

		$('#authToken').click(function(event) {
	        event.preventDefault();
	        console.log("4444 accessToken : " + accessToken);
	       
			$.ajax({
				url: '/authToken.do',
				type: 'GET',
				data: {
			            accessToken : accessToken,
			            goTokenUrl : 'https://accounts.i-sens.com/oauth2/token/validate'
					  },
				dataType: 'json',
				success: function(response) {
					console.log("토큰 유효성 검증 완료 : ", response);
		
		            if (typeof response === 'string') {
		                try {
		                    var jsonResponse = JSON.parse(response);
		                    console.log("Parsed JSON Response: ", jsonResponse);
		                    useUUId = jsonResponse.user_id;
		                    console.log(">>>> User UU ID: ", useUUId);
		                } catch (e) {
		                    console.error("Error parsing JSON: ", e);
		                }
		            } else {
		                console.log("Non-string response: ", response);
		                var userId = response.user_id;
		                console.log("User ID: ", userId);
		            }
		            
					},
				error: function(xhr, status, error) {
					console.log('Error: ' + error);
					}
			});
	       
		});
		
		
		
		
		
		$('#creSampleData').click(function(event) {
	        event.preventDefault();
	        console.log("555 !!!accessToken : " + accessToken);
	        
	        CommonUtil.callAjax(CommonUtil.getContextPath() + "/creSampleData.do","POST",{accessToken : accessToken },
	    			function(response){
	        	 		console.log("create Data success :", response);
						console.log("accessToken : " + accessToken);
	    			}
	    	)
	    	
			
	    });
		
		
		
		$('#getBloodData').click(function(event) {
	        event.preventDefault();
	        console.log("666 !!!accessToken : " + accessToken);
	        console.log("666 !!!useUUId : " + useUUId);
	        $.ajax({
			    url: '/getBloodData.do',
				type: 'GET',
				data: {
					start: '2024-08-18T00:00:00+09:00', // 시작 시간
		            end: '2024-08-20T23:00:00+09:00',    // 종료 시간
		            accessToken : accessToken,
		            userId : useUUId,
		            goTokenUrl : 'https://cgm.i-sens.com:10200/v1/public/cgms'  //'https://api.i-sens.com/v1/public/cgms',
					  },
				success: function(response) {
					    console.log("Blood Data received:", response);
					    },
				error: function(xhr, status, error) {
					   	console.log('Error: ' + error);
					 	}     
			});    

	    
	    	
			
	    });
		
		

	

	    $('#getSensorInfo').click(function(event) {
	        event.preventDefault();
	        console.log("777 accessToken : " + accessToken);
	        //getTokenFunc();
			$.ajax({
				url: '/getData.do',
				type: 'GET',
				data: {
						start: '2024-08-11T00:00:00+09:00', // 시작 시간
			            end: '2024-08-27T23:00:00+09:00',    // 종료 시간
			            accessToken : accessToken,
			            goTokenUrl : 'https://cgm.i-sens.com:10200/v1/public/sensors'  //'https://api.i-sens.com/v1/public/sensors'
					  },
				success: function(response) {
					console.log("sensor Data received:", response);
					},
				error: function(xhr, status, error) {
					console.log('Error: ' + error);
					}
			});
	       
		});


	 	// 함수 정의
        function getTokenFunc() {
            console.log("get Token function");
            
         	
            const queryString = window.location.search;           
            const urlParams = new URLSearchParams(queryString);

            const code = urlParams.get('code');
            const state = urlParams.get('state');
			console.log('Code:', code, ' / State:', state);
            
            CommonUtil.callAjax(CommonUtil.getContextPath() + "/creSampleData.do","POST",{accessToken : accessToken },
	    			function(response){
	        	 		console.log("create Data success :", response);
						console.log("accessToken : " + accessToken);
	    			}
	    	)
        }
		
</script>
				
</body>
</html>				
