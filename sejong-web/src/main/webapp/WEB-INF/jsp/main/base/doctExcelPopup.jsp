<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>  
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>  
<%@ page import = "java.util.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> 
<script type="text/javascript" src="/bootstrap/js/bootstrap.bundle.js"></script> 
<script src="/js/jquery/jquery-1.10.1.js"></script>
<!-- <title>엑셀 업로드</title> -->
<title>엑셀파일 업로드</title>
  
<script type="text/javascript"> 

$(document).ready(function(){
	 
	$("#btnUpload").click(function() { 
		var file = $("#excelFile").val();
		
		if (file == "" || file == null) {
			alert("엑셀 파일을 선택해 주세요."); //"엑셀 파일을 선택해 주세요."
			return ;
		} else if (!checkFileType(file)) {
			alert("엑셀 파일만 업로드 가능합니다.");
			return ;
		}
		
		if (confirm("업로드 하시겠습니까?")) { 
			var form = $("#excelUploadForm")[0]; 
			var formData = new FormData(form); 
			 
			$.ajax( {
				url : "<c:url value='/base/doctExcelUpload.do'/>",
				processData: false,
				contentType: false,
				data: formData,
				type: 'POST',
				async : true,  
				success : function(data) {     
					if(data.error_code == '0'){
						alert("정상 업로드 처리하였습니다.");
						opener.parent.fnSearch();
						self.window.close();
					}else{
						alert("엑셀 업로드 처리 실패하였습니다.!");
					}
				}
			});
		}	 
		
	}); 
	
});
	
	function checkFileType(filePath) {
		var fileFormat = filePath.split(".");
		if (fileFormat.indexOf("xls") > -1|| fileFormat.indexOf("xlsx") > -1) {
			return true;
		} else {
			return false;
		}
	}
	
	function displayFileName() { 
	    var fileInput = document.getElementById('excelFile');
	      
	    var filename = fileInput.value.split('\\').pop(); // Get only the filename (removing the path)
	 
	    if(filename != '')
	    	$("#filename").append('파일명 : ' + filename);
	    else
	    	$("#filename").append('');
	}

</script> 
</head>
<body>   
 	<header class="modal-header">
        <h1>
         의사 정보 엑셀 업로드 
        </h1>
      </header>
      <div class="content-body">
	<section class="top-pannel upload">
          <div class="search-box">  
          
        	<form:form id="excelUploadForm" name="excelUploadForm" enctype="multipart/form-data" method="post" action="/doctExcelUpload.do">
            <div class="input-group file-box" >
	            <div class="input-group file-box">
		            <input type="file" class="form-control" style="display:none;" id="excelFile" name="excelFile" onchange="displayFileName();" accept=".xls,.xlsx" >
		            <label class="input-group-text" for="excelFile">엑셀파일 선택</label>
	           		<label class="form-title w-100"  id="filename">&nbsp;</label> 
		        </div> 
	          </div> 
            </form:form>  
	         <button class="btn btn-primary btn-icon-l btn-upload" id="btnUpload">업로드처리</button> 
            </div>
            </section>
            </div>
</body>  
</html>