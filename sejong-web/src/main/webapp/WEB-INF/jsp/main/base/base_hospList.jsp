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
											+ data.resultLst[i].hosp_cd	+ '\', \''+ data.resultLst[i].start_dt + '\');" id="row_'
											+ data.resultLst[i].hosp_cd  + data.resultLst[i].start_dt + '">';
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
	function fnDtlSearch(hosp_cd, start_dt) {
		if (!hosp_cd || !start_dt)
			return;

		document.regForm.gbn.value = "M";
		document.regForm.iud.value = "U";
		document.regForm.hosp_cd.value = hosp_cd;
		document.regForm.start_dt.value = start_dt;
		document.regFormD.hosp_cd2.value = hosp_cd;
		document.regFormD.start_ym.value = "";

		//row 클릭시 바탕색 변경 처리 Start		
		$("#infoTable tr").attr("class", "");
		$("#infoTable2 tr").attr("class", "");

		$("#infoTable #" + hosp_cd + start_dt).attr("checked", true);
		$("#infoTable tr").removeClass("tr-primary");
		$("#infoTable #row_" + hosp_cd + start_dt).attr("class", "tr-primary");
		//row 클릭시 바탕색 변경 처리 End

		$("#dataArea2").empty();
	   	   $.ajax({
					type : "post",
					url : CommonUtil.getContextPath()+ "/base/ctl_hospDtlList.do",
					data : {hosp_cd : hosp_cd},
					dataType : "json",
					success : function(data) {
						if (data.error_code != "0")
							return;

						if (data.resultCnt > 0) {
							var dataTxt = "";

							for (var i = 0; i < data.resultCnt; i++) {
								dataTxt = '<tr class="" onclick="javascript:fnDtlSearch2(\''
										+ hosp_cd + '\',\''+ data.resultLst[i].start_ym + '\');" id="dtlrow_'
										+ hosp_cd + data.resultLst[i].start_ym + '">';
								dataTxt += "<td>" 	+ data.resultLst[i].start_ym.substring(0, 4) + "년  "
							                    	+ data.resultLst[i].start_ym.substring(4, 6) + "월</td>";
								dataTxt += "<td>" + data.resultLst[i].doccnt + "</td>";
								dataTxt += "<td>" + data.resultLst[i].wardcnt + "</td>";
								dataTxt += "<td>" + data.resultLst[i].icucnt + "</td>";
								dataTxt += "<td>" + data.resultLst[i].ercnt	+ "</td>";
								dataTxt += "</tr>";
								$("#dataArea2").append(dataTxt);
							}
							$.ajax({
								type : "post",
								url : "/json/base/yearChk.do",
								data : {
									hosp_cd : hosp_cd
								},
								dataType : "json",
								success : function(data) {
									if (data.error_code != "0")
										return;
									if (data.yearChk == "Y") {
										$("#allSaveChk").prop("disabled",
												"true"); //버튼 비활성화
									} else {
										$("#allSaveChk").prop("disabled", "");
									}
								}
							});
						} else {
							$("#allSaveChk").prop("disabled", ""); //버튼 활성화
							$("#dataArea2").append("<tr><td colspan='8'>자료가 존재하지 않습니다.</td></tr>");
						}
					}
			});
	}

	//상세코드 정보 선택시
	function fnDtlSearch2(hosp_cd, start_ym) {

		document.regFormD.iud2.value = "DU";
		document.regFormD.hosp_cd2.value = hosp_cd;
		document.regFormD.start_ym.value = start_ym;

		//row 클릭시 바탕색 변경 처리 Start		
		$("#infoTable2 #" + hosp_cd + start_ym).attr("checked", true);
		$("#infoTable2 tr").attr("class", "");
		$("#infoTable2 #dtlrow_" + hosp_cd + start_ym).attr("class","tr-primary");
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
					$("#start_dt").prop("readonly", "true");
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
	//수정, 입력, 삭제 버튼  => fnsave(gbn), fnSave(iud)참고
	function fnSaveDtl(gbn2) {
		var val = gbn2.substring(0, 1);
		var iud2 = gbn2.substring(1, 2);
		var hosp_cd = $("#hosp_cd").val();
		var hosp_cd2 = $("#hosp_cd").val();

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
					document.getElementById("regFormD").reset();

					$("#year").prop("readonly", "");
					document.getElementById("month").disabled = false;

					hsptModalD.show();
					$("#infoTable2 tr").attr("class", "");

				} else if (iud2 == "U") {

					if ($("#start_ym").val() == "") {
						alert("선택된 월별 상세 정보가 없습니다.!");
						hsptModalD.hide();
						return;
					}

					$("#year").prop("readonly", "true");
					document.getElementById("month").disabled = true;

					$.ajax({
						type : "post",
						url : CommonUtil.getContextPath()+ "/base/ctl_hospDtlInfo.do",
						data : {
							hosp_cd2 : $("#hosp_cd2").val(),
							start_ym : $("#start_ym").val()
						},
						dataType : "json",
						success : function(data) {
							if (data.error_code != "0")
								return;

							$("#hosp_cd2").val(data.VO.hosp_cd2);
							$("#year").val(data.VO.start_ym.substring(0, 4));
							$("#month").val(data.VO.start_ym.substring(4, 6));
							$("#wardcnt").val(data.result.wardcnt);
							$("#icucnt").val(data.result.icucnt);
							$("#ercnt").val(data.result.ercnt);
							$("#doccnt").val(data.result.doccnt);
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

		if (iud == "I" && !fnRequired('year', '해당 연도를 선택하세요.'))
			return;
		if (iud == "I" && !fnRequired('month', '해당 월을 선택하세요.'))
			return;

		$("#year").prop("readonly", "");
		document.getElementById("month").disabled = false;

		var formDataD = $("form[name='regFormD']").serialize();

		if (iud != "D") {
			if (val == "D") {
				confirm("병원상세정보를 저장하시겠습니까?");
				$.ajax({
					type : "post",
					url : CommonUtil.getContextPath() + "/base/HospdtlSaveAct.do",
					data : formDataD,
					dataType : "json",
					success : function(data) {
						if (data.error_code != "0") {
							alert("처리실패하였습니다.");
							return;
						} else {
							modalCloseD();
							alert("정상 처리되었습니다.");

							fnDtlSearch($("#hosp_cd").val());
						}
					}
				});
			}
		}
	}
	
	//기본값  일괄생성 처리
	function allSaveProc() {
		var now = new Date();
		var curYear = now.getFullYear();
		if ($("#hosp_cd").val() == "") {
			alert("요양기관정보를 선택하세요.")
			return;
		}
		var reg_user = "${sessionScope['q_user_id']}";
		if (confirm(curYear + "년월별 목록을 일괄 생성 하시겠습니까?")) {
			$.ajax({
				type : "post",
				url : CommonUtil.getContextPath() +  "/base/insertHospDtlMonList.do",
				data : {
					hosp_cd : $("#hosp_cd").val(),
					reg_user : reg_user
				},
				dataType : "json",
				success : function(data) {
					if (data.error_code != "0") {
						alert("처리실패하였습니다.");
						return;
					} else {
						alert("정상 처리되었습니다. 다시 조회하시길 바랍니다.");
					}
				}
			});
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

</script>
</head>

<body id="BodyArea">
	<div class="tab-pane">
		<div class="content-body">
			<div class="tab-content">
				<div class="flex-left-right mb-10">
					<div class="patient-info">
						<div class="info-name">병원정보 목록</div>
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
					<div class="main-right">
						<header class="main-hd">
							<h2>요양기관 목록</h2>
							<div class="btn-box">
								<button class="btn btn-outline-dark btn-sm"
									onclick="fnSave('MU');">수정</button>
							<!--  	<button class="btn btn-primary btn-sm" onclick="fnSave('MI');">입력</button> -->
							</div>
						
						</header>
						<div class="main-content">
							<!-- 테이블 샘플 -->
							<div class="table-responsive">
								<table id="infoTable" class="table table-bordered">
									<colgroup>
										<col style="width: 50px">
										<col style="width: 100px">
										<col style="width: auto; min-width: 150px">
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
					<div class="main-left">
						<header class="main-hd">
							<h2>병원 월별 상세 목록</h2>
							<div class="btn-box">
							  	<button class="btn btn-outline-dark btn-sm" id="allSaveChk"
									onclick="allSaveProc();" disabled>일괄생성</button> 
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
									</colgroup>
									<thead>
										<tr>
											<th>년/월</th>
											<th>전문의 수</th>
											<th>입원 병상수</th>
											<th>중환자실 병상수</th>
											<th>응급실 병상수</th>
										</tr>
									</thead>
									<tbody id="dataArea2">
										<tr>
											<td colspan="8">&nbsp;</td>
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
					<input type="hidden" name="start_ym" id="start_ym" />
					<input type="hidden" name="yearChk" id="yearChk" value="X" />
					<div class="modal-body">
						<div class="form-container">
							<div class="form-wrap w-50">
								<label for="" class="critical">해당 연도</label> <input type="text"
									class="form-control" name="year" id="year"
									onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
									maxLength="4">
							</div>
							<div class="form-wrap w-50">
								<label for="" class="critical">해당 월</label> <select
									class="form-select" name="month" id="month">
									<option value="">선택</option>
									<option value="01">1월</option>
									<option value="02">2월</option>
									<option value="03">3월</option>
									<option value="04">4월</option>
									<option value="05">5월</option>
									<option value="06">6월</option>
									<option value="07">7월</option>
									<option value="08">8월</option>
									<option value="09">9월</option>
									<option value="10">10월</option>
									<option value="11">11월</option>
									<option value="12">12월</option>
								</select>
							</div>
							<div class="form-wrap w-50">
								<label for="">전문의 수</label> <input type="number"
									class="form-control" placeholder="전문의 수를 입력하세요." name="doccnt"
									id="doccnt" value="">
							</div>
							<div class="form-wrap w-50">
								<label for="">입원 병상수</label> <input type="number"
									class="form-control" placeholder=" 입원 병상수를 입력하세요."
									name="wardcnt" id="wardcnt" value="">
							</div>
							<div class="form-wrap w-50">
								<label for="">중환자실 병상수</label> <input type="number"
									class="form-control" placeholder="중환자실 병상수를 입력하세요."
									name="icucnt" id="icucnt" value="">
							</div>
							<div class="form-wrap w-50">
								<label for="">응급실 병상수</label> <input type="number"
									class="form-control" placeholder="응급실 병상수를 입력하세요." name="ercnt"
									id="ercnt" value="">
							</div>
						</div>
					</div>
				</form:form>
			</div>
		</div>
	</div>
</body>
</html>