<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="java.util.*"%>
<html>
<style>
/* addressModal 스타일 수정 */
#addressModal {
    position: fixed;
    top: 0;
    left: calc(51% - 520px - 378px);  /* 50%에서 520px (너비)와 378px (10cm 이동)을 빼기 */
    transform: none;  /* transform을 사용하지 않음 */
    width: 520px;  /* 너비는 520px로 설정 */
    z-index: 1050;  /* 모달이 다른 콘텐츠 위에 보이도록 설정 */
}
/* modal-content 스타일 수정 */
#addressModal .modal-content {
    padding: 20px;
    background-color: #fff; 
    border-radius: 8px;
    position: relative; /* 종료 버튼 위치를 상대적으로 설정 */
    width: 100%;  /* 부모 width를 100%로 설정하여 크기 맞추기 */
}

/* 종료 버튼 스타일 수정 */
.close-btn {
    font-size: 1.5rem;
    position: absolute;
    top: 10px; /* 상단에서 10px 만큼 떨어짐 */
    right: 10px; /* 우측에서 10px 만큼 떨어짐 */
    cursor: pointer;
    color: #333; /* 버튼 색상 */
    z-index: 1060; /* 버튼이 내용 위에 표시되도록 */
}
</style>
<head>
<script src="/js/main.js"></script>
<meta name="viewport" content="width=device-width, initial-scale=0.8">
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script type="text/javaScript">
	var hsptModal = new bootstrap.Modal(document.getElementById('hsptModal'));
	var hsptModalD = new bootstrap.Modal(document.getElementById('hsptModalD'));

	function fnSearch(gbn) {

		document.getElementById("regForm").reset();

		if (gbn == 'M') {
			$("#dataArea1").empty();
				$.ajax({
						type : "post",
						url : CommonUtil.getContextPath()+ '/base/ctl_hospList.do',
						data : {hosp_cd : $("#searchText").val()},
						dataType : "json",
						success : function(data) {
							if (data.error_code != "0")
								return;

							if (data.resultCnt > 0) {
								var dataTxt = "";

								for (var i = 0; i < data.resultCnt; i++) {
									dataTxt = '<tr class="" onclick="javascript:fnDtlSearch(\''
											+ data.resultLst[i].hosp_cd	+ '\', \''+ data.resultLst[i].hosp_uuid + '\');" id="row_'
											+ data.resultLst[i].hosp_cd  + data.resultLst[i].hosp_uuid + '">';
									dataTxt += '<td>' + (i + 1) + '</td>';
									dataTxt += "<td>"+ data.resultLst[i].hosp_cd+ "</td>";
									dataTxt += "<td class='txt-left ellips'>"+ data.resultLst[i].hosp_nm + "</td>";
									dataTxt += "<td>"+ data.resultLst[i].join_dt+ "</td>";
									dataTxt += "<td>"+ data.resultLst[i].start_dt+ "</td>";
									dataTxt += "<td>"+ data.resultLst[i].end_dt+ "</td>";
									dataTxt += "<td>"+ data.resultLst[i].accept_dt+ "</td>";
									dataTxt += "<td>"+ data.resultLst[i].close_dt+ "</td>";
									dataTxt += "<td>"+ data.resultLst[i].upd_dttm+ "</td>";
									dataTxt += "</tr>";
									$("#dataArea1").append(dataTxt);
								}
							} else {
								$("#dataArea1").append("<tr><td colspan='16'>자료가 존재하지 않습니다.</td></tr>");
							}
						}
					});
		}
	}

	//상세코드 정보 조회
	function fnDtlSearch(hosp_cd, hosp_uuid) {
		if (!hosp_cd || !hosp_uuid)
			return;

		document.regForm.gbn.value = "M";
		document.regForm.iud.value = "U";
		document.regForm.hosp_cd.value = hosp_cd;
		document.regForm.hosp_uuid.value = hosp_uuid;

		//row 클릭시 바탕색 변경 처리 Start		
		$("#infoTable tr").attr("class", "");
		$("#infoTable2 tr").attr("class", "");

		$("#infoTable #" + hosp_cd + hosp_uuid).attr("checked", true);
		$("#infoTable tr").removeClass("tr-primary");
		$("#infoTable #row_" + hosp_cd + hosp_uuid).attr("class", "tr-primary");
		//row 클릭시 바탕색 변경 처리 End

		$("#dataArea2").empty();
	   	   $.ajax({
					type : "post",
					url : CommonUtil.getContextPath()+ "/base/ctl_hospConList.do",
					data : {hosp_uuid2 : hosp_uuid},
					dataType : "json",
					success : function(data) {
						if (data.error_code != "0")
							return;
						if (data.resultCnt > 0) {
							var dataTxt = "";
							for (var i = 0; i < data.resultCnt; i++) {
								dataTxt = '<tr class="" onclick="javascript:fnDtlSearch2(\''
									+ hosp_cd + '\',\'' + data.resultLst[i].hosp_uuid + '\',\'' + data.resultLst[i].start_dt + '\',\'' 
									+ data.resultLst[i].end_dt + '\',\'' + data.resultLst[i].conact_gb + '\');" id="dtlrow_' 
					                + hosp_cd + data.resultLst[i].hosp_uuid + data.resultLst[i].start_dt + data.resultLst[i].end_dt + data.resultLst[i].conact_gb + '">';
					            dataTxt += '<td>'+(i+1) +'</td>'; 
					            dataTxt += "<td>" + data.resultLst[i].sub_code_nm + "</td>"; 
					            dataTxt += "<td>" + data.resultLst[i].start_dt+ "</td>";    
					            dataTxt += "<td>" + data.resultLst[i].end_dt+ "</td>";  
								dataTxt += "<td>" + data.resultLst[i].join_dt	+ "</td>";
								dataTxt += "<td>" + data.resultLst[i].accept_dt	+ "</td>";
								dataTxt += "<td>" + data.resultLst[i].close_dt	+ "</td>";
								dataTxt += "<td>" + data.resultLst[i].use_yn	+ "</td>";
					            dataTxt += "<td>" + data.resultLst[i].ocs_company + "</td>";
								dataTxt += "<td>" + data.resultLst[i].ocs_user_id + "</td>";
								dataTxt += "<td>" + data.resultLst[i].ocs_user_pw + "</td>";
								dataTxt += "</tr>";
								$("#dataArea2").append(dataTxt);
							}
						} else {
							$("#dataArea2").append("<tr><td colspan='8'>자료가 존재하지 않습니다.</td></tr>");
						}
					}
			});
	}

	//상세코드 정보 선택시
	function fnDtlSearch2(hosp_cd, hosp_uuid, start_dt, end_dt , conact_gb) {

		document.regFormD.iud2.value = "DU";
		document.regFormD.hosp_cd2.value = hosp_cd;
		document.regFormD.hosp_uuid2.value = hosp_uuid;
		document.regFormD.start_dt2.value = start_dt;
		document.regFormD.end_dt2.value = end_dt;
		document.regFormD.conact_gb.value = conact_gb;

		//row 클릭시 바탕색 변경 처리 Start		
		$("#infoTable2 #" + hosp_cd + hosp_uuid + start_dt + end_dt + conact_gb).attr("checked", true);
		$("#infoTable2 tr").attr("class", "");
		$("#infoTable2 #dtlrow_" + hosp_cd + hosp_uuid + start_dt + end_dt + conact_gb).attr("class","tr-primary");
		//row 클릭시 바탕색 변경 처리 End 
	}

	//수정, 입력, 삭제 버튼  => fnsave(gbn), fnSave(iud)참고
	function fnSave(gbn) {
		var val = gbn.substring(0, 1);
		var iud = gbn.substring(1, 2);

		$("#gbn").val(val); // 마스터(M),상세코드(D)
		$("#iud").val(gbn); // 입력(I), 수정(U), 삭제(D) 

		if (iud == "D")
			fnSaveProc(); //삭제 -버튼없음
		else {
			if (val == 'M') {
				if (iud == "I") {
					document.getElementById("regForm").reset();

					setCurrDate("start_dt");
					$("#end_dt").val("9999-12-31");
					$("#hsptChkBtn").prop("style", "");
					$("#dupchk").val("X");
					$("#hosp_cd").prop("readonly", "");
					$("#start_dt").prop("readonly", "");

					hsptModal.show();
				      
					$("#infoTable2 tr").attr("class", "");

				} else if (iud == "U") {
					if ($("#hosp_cd").val() == "") {
						alert("선택된 병원 정보가 없습니다.!");
						hsptModal.hide();
						return;
					}
					$("#hosp_cd").prop("readonly", "true");
					$("#hsptChkBtn").prop("style", "display:none");
					$("#dupchk").val("N");
				     $.ajax({
							type : "post",
							url : CommonUtil.getContextPath()+ "/base/hospInfo.do",
							data : {
								hosp_cd : $("#hosp_cd").val()
							},
							dataType : "json",
							success : function(data) {
								if (data.error_code != "0") {
									alert(data.error_msg);
									return;
								}
								$("#hosp_cd").val(data.result.hosp_cd);
								$("#hosp_uuid").val(data.result.hosp_uuid);
								$("#hosp_nm").val(data.result.hosp_nm);
								$("#zip_cd").val(data.result.zip_cd);
								$("#hosp_addr").val(data.result.hosp_addr);
								$("#hosp_extradr").val(data.result.hosp_extradr);
								$("#hosp_tel").val(data.result.hosp_tel);
								$("#hosp_fax").val(data.result.hosp_fax);
								$("#start_dt").val(data.result.start_dt);
								$("#join_dt").val(data.result.join_dt);
								$("#end_dt").val(data.result.end_dt);
								$("#accept_dt").val(data.result.accept_dt);
								$("#close_dt").val(data.result.close_dt);
								$("#wardcnt").val(data.result.wardcnt);
								$("#hosp_cd").prop("readonly", "true");
							}
					 });
					hsptModal.show();
					$("#infoTable2 tr").attr("class", "");
				}
			}
		}
	}
	function fnSaveDtl(gbn2) {
		var val = gbn2.substring(0, 1);
		var iud2 = gbn2.substring(1, 2);
		var hosp_cd = $("#hosp_cd").val();
		var hosp_cd2 = $("#hosp_cd").val();
		var hosp_uuid2 = $("#hosp_uuid").val();

		$("#gbn2").val(val); // 마스터(M),상세코드(D)
		$("#iud2").val(gbn2); // 입력(I), 수정(U), 삭제(D)

		if (iud2 == "D")
			fnSaveDtlProc(); //삭제 -버튼없음
		else {
			if (val == 'D') {
				if ($("#hosp_cd").val() == "") {
					alert("선택된 병원 정보가 없습니다.!");
					hsptModalD.hide();
					return;
				}
				if (iud2 == "I") {
					$("#conact_gb").css("pointer-events", "auto").css("background-color", ""); // 콤보박스 활성화 
					document.getElementById("regFormD").reset();
					setCurrDate("start_dt2");
					$("#end_dt2").val("9999-12-31");
					$("#hosp_cd2").val($("#hosp_cd").val());
					$("#hosp_uuid2").val($("#hosp_uuid").val());
					$("#start_dt2").prop("readonly", "");
					$("#end_dt2").prop("readonly", "");
					hsptModalD.show();
					$("#infoTable2 tr").attr("class", "");

				} else if (iud2 == "U") {

					if ($("#conact_gb").val() == "") {
						alert("병원계약정보가 없습니다.!");
						hsptModalD.hide();
						return;
					}
					$("#conact_gb").css("pointer-events", "none").css("background-color", "#e9ecef"); // 콤보박스 비활성화 
					$.ajax({
						type : "post",
						url : CommonUtil.getContextPath()+ "/base/ctl_hospconInfo.do",
						data : {
							hosp_uuid2 : $("#hosp_uuid2").val(),
							start_dt2  : $("#start_dt2").val(),
							end_dt2   : $("#end_dt2").val(),
							conact_gb : $("#conact_gb").val()
						},
						dataType : "json",
						success : function(data) {
							if (data.error_code != "0")
								return;

							$("#conact_gb").val(data.result.conact_gb);
							$("#start_dt2").val(data.result.start_dt);
							$("#end_d2").val(data.result.end_dt);
							$("#join_dt2").val(data.result.join_dt);
							$("#accept_dt2").val(data.result.accept_dt);
							$("#close_dt2").val(data.result.close_dt);
							$("#use_yn").val(data.result.use_yn);
							$("#con_content").val(data.result.con_content);
							$("#ocs_company").val(data.result.ocs_company);
							$("#ocs_user_id").val(data.result.ocs_user_id);
							$("#ocs_user_pw").val(data.result.ocs_user_pw);
							$("#conact_gb").prop("readonly", "true");
							$("#start_dt2").prop("readonly","true");
							$("#end_dt2").prop("readonly","true");
						}
					});
					hsptModalD.show();
				}
			}
		}
	}
	//fnDupchk()참고
	function fnHsptChk() {
		if (!fnRequired('hosp_cd', '요양기관을 입력하세요'))
			return;

		$.ajax({
			type : "post",
			url : CommonUtil.getContextPath() + "/base/ctl_hospChk.do",
			data : {
				hosp_cd : $("#hosp_cd").val()
			},
			dataType : "json",
			success : function(data) {
				if (data.error_code != "0")
					return;
				if (data.dupchk == "Y") {
					alert("이미 존재하는 병원정보 입니다.");
					$("#hosp_cd").val("");
					$("#hosp_cd").focus();
					$("#dupchk").val("Y");
					return;
				}
				alert("등록 가능 합니다.");
				$("#dupchk").val("N");
			}
		});

	}

	//fnSaveProc 참고
	function fnSaveProc() {
		var val = $("#gbn").val(); // 공통코드 마스터/상세 구분
		var iud = $("#iud").val().substring(1, 2); // 입력,수정,삭제 구분

		if (iud != "D" && val == "M"
				&& !fnRequired('hosp_cd', '요양기관번호를 확인하세요.'))
			return;
		if (iud != "D" && val == "M"
				&& !fnRequired('start_dt', '적용시작일자 정보를 확인하세요.'))
			return;
		if (iud != "D" && val == "M"
				&& !fnRequired('end_dt', '적용종료일자 정보를 확인하세요.'))
			return;
		if (iud != "D" && val == "M" && !fnRequired('hosp_nm', '병원명을 확인하세요.'))
			return;
		if (val == "M"
				&& ($("#dupchk").val() == "Y" || $("#dupchk").val() == "X")) {
			alert("요양기관번호 중복체크를 하세요.!");
			return;
		}

		var formData = $("form[name='regForm']").serialize();

		if (iud != "D") {
			if (val == "M") {
				confirm("병원 정보를 저장하시겠습니까?");
				$.ajax({
					type : "post",
					url : CommonUtil.getContextPath() + "/base/HospSaveAct.do",
					data : formData,
					dataType : "json",
					success : function(data) {
						if (data.error_code != "0") {
							alert("처리실패하였습니다.");
							return;
						} else {
							modalClose();
							alert("정상 처리되었습니다.");

							fnSearch(gbn);
						}
					}
				});
			}
		}
	}
	function fnSaveDtlProc() {
		var val = $("#gbn2").val(); // 공통코드 마스터/상세 구분
		var iud = $("#iud2").val().substring(1, 2); // 입력,수정,삭제 구분

		if (iud == "I" && !fnRequired('conact_gb', '계약관계를 선택하세요.'))
			return;
		if (iud == "I" && !fnRequired('start_dt2', '계약시작일자를 선택하세요.'))
			return;
		if (iud == "I" && !fnRequired('end_dt2', '계약종료일자를 선택하세요.'))
			return;
	
		var formDataD = $("form[name='regFormD']").serialize();

		if (iud != "D") {
			if (val == "D") {
				confirm("병원계약정보를 저장하시겠습니까?");
				$.ajax({
					type : "post",
					url : CommonUtil.getContextPath() + "/base/HospconSaveAct.do",
					data : formDataD,
					dataType : "json",
					success : function(data) {
						if (data.error_code != "0") {
							alert("처리실패하였습니다.");
							return;
						} else {
							modalCloseD();
							alert("정상 처리되었습니다.");

							fnDtlSearch($("#hosp_cd").val() ,$("#hosp_uuid2").val() );
						}
					}
				});
			}
		}
	}
	
	function modalClose() {
		if ($("#gbn").val() == "D") {
			$("#infoTable2 tr").attr("class", "");
		} else {
			$("#infoTable tr").attr("class", "");
		}
		hsptModal.hide();
		fnSearch('M');
	}

	function modalCloseD() {
		if ($("#gbn").val() == "D") {
			$("#infoTable2 tr").attr("class", "");
		} else {
			$("#infoTable tr").attr("class", "");
		}
		hsptModalD.hide();
	}
   
    function openAddressSearch(event) {
        event.preventDefault(); // 버튼 기본 동작(폼 제출, 페이지 새로 고침) 방지
        document.getElementById('addressModal').style.display = 'block'; // 모달 보이기
        new daum.Postcode({
            oncomplete: function(data) {
                var addr = '';
                var extraAddr = '';
                if (data.userSelectedType === 'R') {
                    addr = data.roadAddress;
                } else {
                    addr = data.jibunAddress;
                }

                if (data.userSelectedType === 'R') {
                    if (data.bname !== '' && /[동|로|가]$/g.test(data.bname)) {
                        extraAddr += data.bname;
                    }
                    if (data.buildingName !== '' && data.apartment === 'Y') {
                        extraAddr += (extraAddr !== '' ? ', ' + data.buildingName : data.buildingName);
                    }
                    if (extraAddr !== '') {
                        extraAddr = ' (' + extraAddr + ')';
                    }
                } else {
                    extraAddr = '';
                }
                $("#zip_cd").val(data.zonecode);
                $("#hosp_addr").val(addr + extraAddr);
 
                
                closeModal(); // 주소 선택 후 모달 닫기
            },
            width: '100%',
            height: '400px'
            
            //	data.jibunAddress || data.roadAddress
        }).embed(document.getElementById('addressSearchResult'));
    }

    // 모달 닫기
    function closeModal() {
        document.getElementById('addressModal').style.display = 'none'; // 모달 닫기
    }
    window.fileHandlerInitialized = false;
  //전역 변수로 초기화 상태 관리
  if (!window.fileHandlerInitialized) {
  	window.fileHandlerInitialized = true;
      // 요소 가져오기
      const dragArea = document.getElementById("drag-area");
      const fileInput = document.getElementById("file-input");
      const fileList = document.getElementById("file-list");

      // 이벤트 핸들러
      function dragOverHandler(event) {
          event.preventDefault(); // 기본 동작 방지
          dragArea.style.borderColor = "blue"; // 드래그 효과
      }

      function dragLeaveHandler() {
          dragArea.style.borderColor = "#ccc"; // 원래 색상 복구
      }

      function dropHandler(event) {
          event.preventDefault(); // 기본 동작 방지
          dragArea.style.borderColor = "#ccc"; // 색상 복구
          const files = event.dataTransfer.files; // 드래그된 파일 가져오기
          handleFiles(files);
      }

      function changeHandler(event) {
          const files = event.target.files; // 파일 입력 값 가져오기
          handleFiles(files);
          fileInput.value = ""; // 파일 입력 초기화
      }

      function openFileInput(event) {
          event.preventDefault(); // 기본 동작 방지
          fileInput.click(); // 파일 선택 창 열기
      }

      function handleFiles(files) {
          // 파일 목록 초기화 (필요 시 주석 처리 가능)
          // fileList.innerHTML = "";

          for (let i = 0; i < files.length; i++) {
              const file = files[i];
              const fileItem = document.createElement('div');
              fileItem.classList.add('file-item');
              fileItem.textContent = file.name;

              // 삭제 버튼 추가
              const deleteBtn = document.createElement('button');
              deleteBtn.textContent = '삭제';
              deleteBtn.classList.add('delete-btn');
              deleteBtn.style.marginLeft = "10px";
              deleteBtn.addEventListener('click', function() {
                  fileItem.remove(); // 해당 파일 항목 삭제
              });

              fileItem.appendChild(deleteBtn);
              fileList.appendChild(fileItem);
          }
      }

      // 이벤트 리스너 등록
      dragArea.addEventListener("dragover", dragOverHandler);
      dragArea.addEventListener("dragleave", dragLeaveHandler);
      dragArea.addEventListener("drop", dropHandler);
      fileInput.addEventListener("change", changeHandler);
  }
  function saveFileListToStorage() {
      const fileItems = document.querySelectorAll('.file-item');
      const fileNames = Array.from(fileItems).map(item => item.textContent.replace('삭제', '').trim());
      localStorage.setItem('fileList', JSON.stringify(fileNames));
  }

  function loadFileListFromStorage() {
      const savedFileList = JSON.parse(localStorage.getItem('fileList') || '[]');
      savedFileList.forEach(fileName => {
          const fileItem = document.createElement('div');
          fileItem.classList.add('file-item');
          fileItem.textContent = fileName;

          const deleteBtn = document.createElement('button');
          deleteBtn.textContent = '삭제';
          deleteBtn.classList.add('delete-btn');
          deleteBtn.style.marginLeft = "10px";
          deleteBtn.addEventListener('click', function() {
              fileItem.remove();
              saveFileListToStorage();
          });

          fileItem.appendChild(deleteBtn);
          fileList.appendChild(fileItem);
      });
  }
  // 초기 로드 시 파일 목록 복구
  loadFileListFromStorage();

  function dragOverHandler(event) {
      event.preventDefault();
      dragArea.style.borderColor = "blue";
      dragArea.style.backgroundColor = "#f0f8ff"; // 연한 배경색 추가
  }

  function dragLeaveHandler() {
      dragArea.style.borderColor = "#ccc";
      dragArea.style.backgroundColor = "white"; // 기본 배경색 복구
  }   
</script>
</head>

<body id="BodyArea">
	<div class="tab-pane">
		<div class="content-body">
			<div class="tab-content">
				<div class="flex-left-right mb-10"> 
					<div class="patient-info">
						<div class="info-name">병원계약정보 목록</div>
					</div>
				</div>
				<section class="top-pannel">
					<div class="search-box">
						<label for="search" class="form-title">검색어 입력</label> <input
							name="searchText" id="searchText" type="text"
							class="form-control" placeholder="병원명을 입력하세요"
							onkeypress="if( event.keyCode == 13 ){fnSearch();}">
						<button class="buttcon" onclick="fnSearch('M');">
							<span class="icon icon-search"></span>
						</button>
					</div>
				</section>
				<section class="main-pannel">
					<div class="main-right" style="width: 60%;">
						<header class="main-hd">
							<h2>요양기관 목록</h2>
							<div class="btn-box">
								<button class="btn btn-outline-dark btn-sm"
									onclick="fnSave('MU');">수정</button>
								<button class="btn btn-primary btn-sm" onclick="fnSave('MI');">입력</button>
							</div>
						
						</header>
						<div class="main-content">
							<!-- 테이블 샘플 -->
							<div class="table-responsive">
								<table id="infoTable" class="table table-bordered">
									<colgroup>
										<col style="width: 50px">
										<col style="width: 100px">
										<col style="width: auto; min-width: 120px">
										<col style="width: 120px">
										<col style="width: 150px">
										<col style="width: 100px">
										<col style="width: 100px">
										<col style="width: 100px">
										<col style="width: 100px">
									</colgroup>
									<thead>
										<tr>
											<th>번호</th>
											<th>요양기관번호</th>
											<th>병원명</th>
											<th>가입일</th>
											<th>계약시작</th>
											<th>계약종료</th>
											<th>승인일자</th>
											<th>중지일자</th>
											<th>등록일자</th>
										</tr>
									</thead>
									<tbody id="dataArea1">
										<tr>
											<td colspan="16">&nbsp;</td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
					</div>
					<div class="main-left" style="width: 40%;">
						<header class="main-hd">
							<h2>계약상세내역</h2>
							<div class="btn-box">
								<button class="btn btn-outline-dark btn-sm"
									onclick="fnSaveDtl('DU');">수정</button>
								<button class="btn btn-primary btn-sm"
									onclick="fnSaveDtl('DI');">입력</button>
							</div>
						</header>
						<div class="main-content">
							<!-- 테이블 샘플 -->
							<div class="table-responsive">
								<table id="infoTable2" class="table table-bordered">
									<colgroup>
										<col style="width: 50px">
										<col style="width: 100px">
										<col style="width: 100px">
										<col style="width: 100px">
										<col style="width: 100px">
										<col style="width: 100px">
										<col style="width: 100px">
										<col style="width: 100px">
										<col style="width: 100px">
										<col style="width: 100px">
										<col style="width: 100px">
									</colgroup>
									<thead>
										<tr>
											<th>번호</th>
											<th>계약구분</th>
											<th>계약시작일</th>
											<th>계약종료일</th>
											<th>가입일</th>
											<th>승인일</th>
											<th>중지일</th>
											<th>승인여부</th>
											<th>ocs회사</th>
											<th>ocs아이디</th>
											<th>비밀번호</th>
										</tr>
									</thead>
									<tbody id="dataArea2">
										<tr>
											<td colspan="11">&nbsp;</td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
				</section>
			</div>
		</div>
	</div>
	
			    
 	<div class="modal fade" id="hsptModal" tabindex="-1" aria-labelledby="exampleModalLabel" > 
		<!-- 모달 class명으로 사이즈 조절 modal-320, 410, 520, 650, 820 -->
		<div class="modal-dialog  modal-820">
			<div class="modal-content">
				<div class="modal-footer">
					<button type="button" class="btn btn-primary btn-sm"
						onclick="fnSaveProc();">저장</button>
					<button type="button" class="btn btn-outline-dark btn-sm"
						data-bs-dismiss="modal" onclick="modalClose();">목록</button>
				</div>
				<form:form commandName="VO" id="regForm" name="regForm"	method="post">
					<input type="hidden" name="gbn" id="gbn" />
					<input type="hidden" name="iud" id="iud" />
					<input type="hidden" name="hosp_uuid" id="hosp_uuid" />
					<input type="hidden" name="dupchk" id="dupchk" value="X" />
					<div class="modal-body">
						<div class="form-container">
							<div class="form-wrap w-50">
								<label ="" class="critical">요양기관</label> <input type="text"
									name="hosp_cd" id="hosp_cd" class="form-control"
									placeholder="요양기관를 입력하세요.">
								<button type="button" class="btn btn-outline-dark"
									id="hsptChkBtn" onclick="fnHsptChk('M');">중복체크</button>
								<input type="hidden" name="ncisDupchk" value="uncheck" />
							</div>
							<div class="form-wrap w-100">
								<label for="" class="critical">요양기관명</label> <input type="text"
									name="hosp_nm" id="hosp_nm" class="form-control"
									placeholder="요양기관명을 입력하세요.">
							</div>		
							<div class="form-wrap w-50">
								<label for="" class="critical">가입일</label> <input type="text"
									name="join_dt" id="join_dt" class="form-control"
									placeholder="가입일을  입력하세요.">
							</div>				
							<div class="form-wrap w-100">
								<label for="" class="critical">우편번호</label> <input type="text"
									name="zip_cd" id="zip_cd" class="form-control"
									placeholder="우편번호를 입력하세요.">
								<button class="button" onclick="openAddressSearch(event)">
								    <span class="icon icon-search"></span>
								</button>
		
							</div>
							<div class="form-wrap w-100">
								<label for="" class="critical">주소</label> <input type="text"
									name="hosp_addr" id="hosp_addr" class="form-control"
									placeholder="주소를 입력하세요.">
							</div>
							<div class="form-wrap w-100">
								<label for="" class="critical">상세주소</label> <input type="text"
									name="hosp_extradr" id="hosp_extradr" class="form-control"
									placeholder="상세주소를 입력하세요.">
							</div>
							<div class="form-wrap w-50">
								<label for="" class="critical">연락처</label> <input
									type="text" name="hosp_tel" id="hosp_tel" class="form-control"
									placeholder="연락처를 입력하세요.">
							</div>
							<div class="form-wrap w-50">
								<label for="" class="critical">Fax</label> <input type="text"
									name="hosp_fax" id="hosp_fax" class="form-control"
									placeholder="fax번호를 입력하세요.">
							</div>
							<div class="form-wrap w-50">
								<label for="" class="critical">시작일</label> <input type="text"
									name="start_dt" id="start_dt" class="form-control"
									placeholder="시작일를  입력하세요.">
							</div>
							<div class="form-wrap w-50">
								<label for="" class="critical">종료일</label> <input type="text"
									name="end_dt" id="end_dt" class="form-control"
									placeholder="종료일를  입력하세요.">
							</div>
							<div class="form-wrap w-50">
								<label for="" class="critical">승인일</label> <input type="text"
									name="accept_dt" id="accept_dt" class="form-control"
									placeholder="승인일를  입력하세요.">
							</div>
							<div class="form-wrap w-50">
								<label for="" class="critical">중지일</label> <input type="text"
									name="close_dt" id="close_dt" class="form-control"
									placeholder="중지일를  입력하세요.">
							</div>
							<div class="form-wrap w-50">
								<label for="" class="critical">가용병상</label> <input type="number"
									name="wardcnt" id="wardcnt" class="form-control"
									placeholder="가용병상을  입력하세요.">
							</div>							
						</div>
					</div>
				</form:form>
			</div>
			<div id="addressModal" class="modal-dialog modal-520" style="display:none;">
			    <div class="modal-content">
			        <span class="close-btn" onclick="closeModal()">&times;</span> 
			        <div id="addressSearchResult"></div>
			    </div>
			</div>
		</div>
	</div>
	<!-- 상세 모달 -->
	<div class="modal fade" id="hsptModalD" tabindex="-1"
		aria-labelledby="exampleModalLabel" aria-hidden="true">
		<!-- 모달 class명으로 사이즈 조절 modal-320, 410, 520, 650, 820 -->
		<div class="modal-dialog  modal-820">
			<div class="modal-content">
				<div class="modal-footer">
					<button type="button" class="btn btn-primary btn-sm"
						onclick="fnSaveDtlProc();">저장</button>
					<button type="button" class="btn btn-outline-dark btn-sm"
						data-bs-dismiss="modal" onclick="modalCloseD();">목록</button>
				</div>
				<form:form commandName="VO" id="regFormD" name="regFormD"
					method="post">
					<input type="hidden" name="gbn2" id="gbn2" />
					<input type="hidden" name="iud2" id="iud2" />
					<input type="hidden" name="hosp_cd2" id="hosp_cd2" />
					<input type="hidden" name="hosp_uuid2" id="hosp_uuid2" />
					<input type="hidden" name="yearChk" id="yearChk" value="X" />
					<div class="modal-body">
						<div class="form-container">
				           <div class="form-wrap w-50">
					           <label for="">계약구분</label> 
					            <select class="form-select" name="conact_gb" id="conact_gb"> <!-- readonly -->
					                <option value="">선택</option> 
					                <c:forEach var="result" items="${commList}" varStatus="status">
					                   <option value="${result.sub_code}">${result.sub_code_nm}</option>
					                </c:forEach> 
					           </select>
				           </div>						
                            <div class="form-wrap w-50">
							</div>				
							<div class="form-wrap w-50">
								<label for="">계약시작일자</label> <input type="text"
									class="form-control" placeholder="계약시작일자 입력하세요."  name="start_dt2" id="start_dt2">
							</div>
							<div class="form-wrap w-50">
								<label for="">계약종료일자</label> <input type="text"
									class="form-control" placeholder="계약종료일자 입력하세요." name="end_dt2"	id= "end_dt2">
							</div>
							<div class="form-wrap w-100">
								<label for="">계약세부내용</label> <input type="text"
									class="form-control" placeholder="계약세부네용 입력하세요." name="con_content"
									id= "con_content" value="">
							</div>	
							<div class="form-wrap w-50">
								<label for="">가입일자</label> <input type="text"
									class="form-control" placeholder="가입일자를 입력하세요."	name="join_dt2" id="join_dt2" value="">
							</div>
							<div class="form-wrap w-50">
								<label for="">승인일자</label> <input type="text"
									class="form-control" placeholder="승인일자를 입력하세요." 	name="accept_dt2" id="accept_dt2" value="">
							</div>
							<div class="form-wrap w-50">
								<label for="">중지일자</label> <input type="text"
									class="form-control" placeholder="중지일자를 입력하세요."
									name="close_dt2" id="close_dt2" value="">
							</div>
							<div class="form-wrap w-50">
								<label for="">사용회사</label> <input type="text"
									class="form-control" placeholder="사용회사를 입력하세요."
									name="ocs_company" id="ocs_company" value="">
							</div>
							<div class="form-wrap w-50">
								<label for="">사용아이디</label> <input type="text"
									class="form-control" placeholder="사용아이디를 입력하세요."
									name="ocs_user_id" id="ocs_user_id" value="">
							</div>
							<div class="form-wrap w-50">
								<label for="">사용패스워드</label> <input type="text"
									class="form-control" placeholder="사용패스워드를 입력하세요."
									name="ocs_user_pw" id="ocs_user_pw" value="">
							</div>
				            <div class="form-wrap w-50">
				              <label for=""class="critical">승인여부</label>
				       		  <select class="form-select" name="use_yn" id="use_yn">
				                <option value="">선택</option> 
				                <option value="Y">Y</option>
				                <option value="N">N</option>
				              </select> 
				            </div>
						</div>
			             <div class="form-wrap w-80">
			              <label for="" class="critical">파일업로드</label>
				            <div class="btn-box">
				                <button class="btn btn-primary btn-sm"  onclick="openFileInput(event)">파일 선택</button>
				            </div>
							<div id="drag-area">
							  <p>파일을 여기에 드래그 하세요.</p>
							  <input type="file" id="file-input" multiple style="display: none;">
							  <div id="file-list" class="file-list-container"></div>
							</div>
						</div>
					</div>
		
				</form:form>
			</div>
		</div>
	</div>
</body>
</html>
