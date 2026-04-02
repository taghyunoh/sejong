
var wkdyList = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" ,"Sunday"];

$(document).ready(function(){
	//최초 Grid width(넓이) - 수정된 내용
	var gwidth =$(".inquiry__result-section").width();    
	var height =$(".inquiry__result-section").height()*0.88;
	gwidth = parseInt(gwidth) -20 ;  
	
	// grid가 3개인 경우 width 정의	
	var gwidth1 = $(".grid1").width();
	var gwidth2 = $(".grid2").width();
	var gwidth3 = $(".grid3").width();
	
	
	var wkdy = wkdyList[$("#tabIndex").val()];
	fn_wkdyGrid("#list1",gwidth1*0.98,height*0.70,wkdy);
	
	$('#strt_time_val').on('keyup',addColon);
	$('#end_time_val').on('keyup',addColon);
	$('#break_strt_time_val').on('keyup',addColon);
	$('#break_end_time_val').on('keyup',addColon);
	
	$('#list8').jqGrid({  
		mtype:'POST', datatype : "local", 
		colNames:['병원코드','변동사유'],
		colModel:[
			{ name: 'hspt_id', 		index: 'hspt_id',		width: 0,	hidden:true},
			{ name: 'hldy_text', 	index: 'hldy_text', width:'100', align:"center"}
			], 
		jsonReader: {
			repeatitems: false,
			root:'rows', 		
			records:'records'  
		}, 
		width:gwidth2*0.98,                 
		height:height*0.30, //테이블의 세로 크기, Grid의 높이         
		loadtext :"자료 조회중입니다. 잠시만 기다리세요...",       
		emptyrecords: "Nothing to display",    
		caption: "예약변동내역", 
		rowNum:100,  rownumbers: true, gridview : true, 
		onSelectRow: function(rowid) {
			var rowObject = $("#list4").jqGrid('getRowData',rowid);  
		} 
	})
	
	$('#list9').jqGrid({
			mtype:'POST', datatype : "json", 
			colNames:[ 'iud', 'imgn_room_cd', 'hspt_id', '요일', '시작', '종료', '외래', '입원', '건진'],
			colModel:[
				{ name: 'iud'		           , index: 'iud', width: 0 ,hidden:true},
				{ name: 'imgn_room_cd'         , index: 'imgn_room_cd', width: 0 ,hidden:true},
				{ name: 'hspt_id'	           , index: 'hspt_id', width: 0 ,hidden:true},
				{ name: 'wkdy'		           ,	index: 'wkdy', width: 0 ,hidden:true},
				{ name: 'strt_time'            , index: 'strt_time',  editable:true, editoptions:{maxlength:5}, width: 60 ,align:"center"}, 
				{ name: 'end_time'             , index: 'end_time' ,  editable:true, editoptions:{maxlength:5}, width: 60 ,align:"center"}, 
				{ name: 'appn_outp_pssb_cnt'   , index: 'appn_outp_pssb_cnt',editable:true, editoptions:{maxlength:3, dataInit:onlyInt}, width: 60 ,align:"center"}, 
				{ name: 'appn_inpt_pssb_cnt'   , index: 'appn_inpt_pssb_cnt',editable:true, editoptions:{maxlength:3, dataInit:onlyInt}, width: 60 ,align:"center"}, 
				{ name: 'appn_hlxm_pssb_cnt'   , index: 'appn_hlxm_pssb_cnt',editable:true, editoptions:{maxlength:3, dataInit:onlyInt}, width: 60 ,align:"center"}
				], 
			jsonReader: {
				repeatitems: false, 
				root:'rows',
				records:'records'  
			}, 
			width:gwidth3*0.98,                 
			height:height,
			caption:" ",
			loadtext :"자료 조회중입니다. 잠시만 기다리세요...",       
			emptyrecords: "Nothing to display",
			multiselect : true,
			hidegrid:false,
			rowNum:-1,  
			rownumbers: true,         
			gridview : true,  
			onSelectRow: function(rowid) {
				var rowObject = $(id).jqGrid('getRowData',rowid);
				
		} 
	})
});
var caption = "요일 설정&nbsp;&nbsp;&nbsp;"
	caption +="<a href=\'javascript:fn_add();'\><button class='process__btn2'>&nbsp;<img src='/images/jqgrid/btn_add.png' alt='추가' width='16px' /><span>&nbsp;행 추가&nbsp;</span></button></a>"+
			  "<a href=\'javascript:fn_edit();'\><button class='process__btn2'>&nbsp;<img src='/images/jqgrid/btn_update.png' alt='수정' width='16px'/><span>&nbsp;행 수정&nbsp;</span></button></a>" +
	          "<a href=\'javascript:fn_delete();'\><button class='process__btn2'>&nbsp;<img src='/images/jqgrid/btn_delete.png' alt='삭제' width='16px' /><span>&nbsp;행 삭제&nbsp;</span></button></a>"+
	          "&nbsp;&nbsp;&nbsp;&nbsp;"+
	          "<a href=\'javascript:fn_save();'\><button class='process__btn2'>&nbsp;<img src='/images/jqgrid/btn_save.png' alt='저장' width='16px' /><span>&nbsp;저 장&nbsp;</span></button></a>";

var caption2 =  "<a href=\''\><button class='process__btn2'>&nbsp;<img src='/images/jqgrid/btn_add.png' alt='추가' width='16px' /><span>&nbsp;행 추가&nbsp;</span></button></a>"+
				"<a href=\''\><button class='process__btn2'>&nbsp;<img src='/images/jqgrid/btn_update.png' alt='수정' width='16px'/><span>&nbsp;행 수정&nbsp;</span></button></a>" +
				"<a href=\''\><button class='process__btn2'>&nbsp;<img src='/images/jqgrid/btn_delete.png' alt='삭제' width='16px' /><span>&nbsp;행 삭제&nbsp;</span></button></a>"+
				"<a href=\''\><button class='process__btn2'>&nbsp;<img src='/images/jqgrid/btn_save.png' alt='저장' width='16px' /><span>&nbsp;저 장&nbsp;</span></button></a>";

function fn_wkdyGrid (id,gwidth,gheight,weekday){
	$(id).jqGrid({
			url: "/json/appn/selectRis0210List.do",
			postData : {
				hspt_id:$("#session_hspt_id").val(),     
				wkdy:weekday,        
				imgn_room_cd:$("#select_imgn_room_cd").val()
			 },
		    mtype:'POST', datatype : "json", 
		    colNames:[ 'iud', 'imgn_room_cd', 'hspt_id', '요일', '시작', '종료', '외래', '입원', '건진'],
		    colModel:[
				{ name: 'iud'		           , index: 'iud', width: 0 ,hidden:true},
				{ name: 'imgn_room_cd'         , index: 'imgn_room_cd', width: 0 ,hidden:true},
				{ name: 'hspt_id'	           , index: 'hspt_id', width: 0 ,hidden:true},
				{ name: 'wkdy'		           ,	index: 'wkdy', width: 0 ,hidden:true},
			    { name: 'strt_time'            , index: 'strt_time',  editable:true, editoptions:{maxlength:5}, width: 60 ,align:"center"}, 
			    { name: 'end_time'             , index: 'end_time' ,  editable:true, editoptions:{maxlength:5}, width: 60 ,align:"center"}, 
				{ name: 'appn_outp_pssb_cnt'   , index: 'appn_outp_pssb_cnt',editable:true, editoptions:{maxlength:3, dataInit:onlyInt}, width: 60 ,align:"center"}, 
				{ name: 'appn_inpt_pssb_cnt'   , index: 'appn_inpt_pssb_cnt',editable:true, editoptions:{maxlength:3, dataInit:onlyInt}, width: 60 ,align:"center"}, 
				{ name: 'appn_hlxm_pssb_cnt'   , index: 'appn_hlxm_pssb_cnt',editable:true, editoptions:{maxlength:3, dataInit:onlyInt}, width: 60 ,align:"center"}
			    ], 
		    jsonReader: {
			    repeatitems: false, 
			    root:'rows',
			    records:'records'  
		    }, 
		    width:gwidth,                 
		    height:gheight,
		    caption:caption,
		    loadtext :"자료 조회중입니다. 잠시만 기다리세요...",       
		    emptyrecords: "Nothing to display",
		    multiselect : true,
		    hidegrid:false,
		    rowNum:-1,  
	        rownumbers: true,         
		    gridview : true,  
			onSelectRow: function(rowid) {
	          	var rowObject = $(id).jqGrid('getRowData',rowid);
	          	
	        } 
	}) 
}

function fn_add(){
	var tabIndex = $("#tabIndex").val();
	var id = "#list"+(parseInt(tabIndex)+1)
	var wkdy = wkdyList[tabIndex];
	var imgn_room_cd = $("#select_imgn_room_cd").val()
	
	var rowData ={"iud":"I","imgn_room_cd":imgn_room_cd,"wkdy":wkdy};	
	
	var ids = $(id).getDataIDs();
	var rowId = Math.max.apply(null,ids)+1
	if(ids.length < 1){
		jQuery(id).jqGrid('clearGridData');
		rowId = 1;
	}
	if($(id).getGridParam( "selrow" ) == null){
		$(id).jqGrid("addRowData",rowId,rowData); // 첫 행에 Row 추가 
		jQuery(id).jqGrid('editRow',rowId,false);
	}else{
		$(id).jqGrid("addRowData",rowId,rowData,'after',$(id).getGridParam( "selrow" )); //선택된 행 뒤에 Row추가
		jQuery(id).jqGrid('editRow',rowId,false);
	}
	$('#' + rowId + '_' + 'strt_time').attr('onkeypress',"return isTimeKey(event);");
	$('#' + rowId + '_' + 'end_time').attr('onkeypress',"return isTimeKey(event);");
	$('#' + rowId + '_' + 'strt_time').on('keyup',addColon);
	$('#' + rowId + '_' + 'end_time').on('keyup',addColon);
	$('#' + rowId + '_' + 'appn_outp_pssb_cnt').attr('onkeypress',"return isNumberKey(event);");
	$('#' + rowId + '_' + 'appn_inpt_pssb_cnt').attr('onkeypress',"return isNumberKey(event);");
	$('#' + rowId + '_' + 'appn_hlxm_pssb_cnt').attr('onkeypress',"return isNumberKey(event);");
}

function fn_delete(){
	var tabIndex = $("#tabIndex").val();
	var id = "#list"+(parseInt(tabIndex)+1)
	
	var checkedRows = $(id).getGridParam( "selarrrow" );
	var rowNum = checkedRows.length;
	if(rowNum == 0){
		alert("삭제할 행이 없습니다.");
		return
	};
	for (var i = rowNum - 1; i >= 0; i--) {
		var iud = $(id).getCell(checkedRows[i], "iud");
		if(iud == "I"){ 
			$(id).jqGrid("delRowData", checkedRows[i]); 
		}else{
			$(id).jqGrid('setRowData', checkedRows[i], { iud: "D"});
		}
	}
}

function fn_edit(){
	var tabIndex = $("#tabIndex").val();
	var id = "#list"+(parseInt(tabIndex)+1);
	var checkedRows = $(id).getGridParam( "selarrrow" );
	var rowNum = checkedRows.length;
	
	if(rowNum == 0){
		alert("수정할 정보가 존재하지 않습니다.");
		return
	};
	for (var i = rowNum - 1; i >= 0; i--) {
		var iud = $(id).getCell(checkedRows[i], "iud");
		if(iud == "I") return;
		$(id).editRow(checkedRows[i]);
		$(id).jqGrid('setRowData', checkedRows[i], { iud: "U"});
	}
}

function fn_reset(){
	document.regfrm.iud  		           = "";
	document.regfrm.hspt_id  	           = "";
	document.regfrm.imgn_room_cd           = "";
	document.regfrm.wkdy    	           = "";
	document.regfrm.strt_time              = "";
	document.regfrm.end_time               = "";
	document.regfrm.appn_outp_pssb_cnt     = "";
	document.regfrm.appn_inpt_pssb_cnt     = "";
	document.regfrm.appn_hlxm_pssb_cnt     = "";
}


//저장	
function fn_save(){
	for (j=1;j<8;j++) {
		var listId = "#list"+j
		
		var ids = $(listId).getDataIDs();
		var resultTxt = "";
		var cnt=0;
		var iud =""; 
		for(var i=0; i < ids.length;i++){ 
			var rowId = parseInt(i)+1;  
			$(listId).jqGrid('saveRow',ids[i]);  
			var iud = $(listId).getCell(ids[i], "iud");
			
			
			//초기화
			fn_reset();    		
			if(iud == "I" ||iud == "U" ||iud == "D" ) {
				document.regfrm.iud.value  					= iud;                                          
				document.regfrm.hspt_id.value  				= $(listId).getCell(ids[i],  "hspt_id");       
				document.regfrm.imgn_room_cd.value  		= $(listId).getCell(ids[i],  "imgn_room_cd");
				document.regfrm.wkdy.value    				= $(listId).getCell(ids[i],  "wkdy");
				document.regfrm.strt_time.value    			= $(listId).getCell(ids[i],  "strt_time");
				document.regfrm.end_time.value    			= $(listId).getCell(ids[i],  "end_time");
				document.regfrm.appn_outp_pssb_cnt.value    = $(listId).getCell(ids[i],  "appn_outp_pssb_cnt");
				document.regfrm.appn_inpt_pssb_cnt.value    = $(listId).getCell(ids[i],  "appn_inpt_pssb_cnt");
				document.regfrm.appn_hlxm_pssb_cnt.value    = $(listId).getCell(ids[i],  "appn_hlxm_pssb_cnt");
				
				
				var authok = $("form[name='regfrm']").serialize();
				//
				$.ajax( {
					type : "post",
					url : "/json/appn/Ris0210Save.do",
					data : authok,
					dataType : "json",
					error : function(){
						alert("[전산오류]처리시 오류가 발생하였습니다. 전산실에 문의하세요.!");
						$(listId).jqGrid('restoreRow'  , rowId);
						$(listId).jqGrid('setSelection', rowId, true);     
					},
					success : function(data) {   
						if(data.error_code != "0"){
							alert( parseInt(i)+1 + "행의 정보 저장시 오류가 발생하였습니다.");
							return;
						}else{   
							cnt = cnt + 1;  
							//alert("정상 등록처리되었습니다." + cnt);  
						}
						
					}
				});
				
			}else{

			}
		
		}
		cnt = cnt + 1;  
		resultTxt = "총 " + cnt + " 건이 처리되었습니다."; 
	}

	if(cnt > 0){
		alert(resultTxt);
		//fn_query();
	}else{
		alert("저장할 정보가 없습니다.");
	}
}

function fn_add_wkdy(){
	if ($("#monToFri").is(':checked')){
		fn_add_time(0);
		fn_add_time(1);
		fn_add_time(2);
		fn_add_time(3);
		fn_add_time(4);
	} else {
		var indexNum = $("#tabIndex").val();
		fn_add_time(indexNum);
	}
}

//시간관리 행추가
function fn_add_time(indexNum){
	//날짜 선택 확인
	var tabIndex = indexNum;
	var id = "#list"+(parseInt(tabIndex)+1);
	var wkdy = wkdyList[tabIndex];
	var imgn_room_cd = $("#select_imgn_room_cd").val();
	var hspt_id = $("#session_hspt_id").val();
	var ids = $(id).getDataIDs();
	var rowId = Math.max.apply(null,ids)+1
	if(ids.length < 1){
		jQuery(id).jqGrid('clearGridData');
		rowId = 1;
	}
	
	var a = $("#strt_time_val").val();
	var b = $("#end_time_val").val();
	var c = $("#interval_val").val();
	var outp_val = $("#appn_outp_pssb_cnt_val").val();
	var inpt_val = $("#appn_inpt_pssb_cnt_val").val();
	var hlxm_val = $("#appn_hlxm_pssb_cnt_val").val();
	var break_start = $("#break_strt_time_val").val();
	var break_end = $("#break_end_time_val").val();
	
	var strt_time_from = parseInt(a.substring(0,2))*60+parseInt(a.substring(3,5));
	var end_time_to = parseInt(b.substring(0,2))*60+parseInt(b.substring(3,5));
	break_start = parseInt(break_start.substring(0,2))*60+parseInt(break_start.substring(3,5));
	break_end = parseInt(break_end.substring(0,2))*60+parseInt(break_end.substring(3,5));

	var time = (end_time_to-strt_time_from);
	var interval = parseInt(c);
	outp_val = parseInt(outp_val)|| 0;
	inpt_val = parseInt(inpt_val)|| 0;
	hlxm_val = parseInt(hlxm_val)|| 0;
	
	for (i=0; i*interval < time;i++){
		if (((break_start >= (strt_time_from+((i+1)*interval)))&& (break_start > (strt_time_from+((i)*interval))))||
		((break_end <=(strt_time_from+((i)*interval)))&&(break_end<(strt_time_from+((i+1)*interval))))){
		var strt_time = fn_toTime(strt_time_from+(i*interval));
		var end_time  = fn_toTime(strt_time_from+((i+1)*interval));
		var rowData ={"iud":"I", "imgn_room_cd":imgn_room_cd, "hspt_id":hspt_id, "wkdy":wkdy, "strt_time": strt_time, "end_time": end_time, 
		"appn_outp_pssb_cnt":outp_val, "appn_inpt_pssb_cnt":inpt_val, "appn_hlxm_pssb_cnt":hlxm_val};
		$(id).jqGrid("addRowData",rowId+i,rowData); 
		$(id).jqGrid('editRow',rowId+i,false);
		$('#' + rowId+i + '_strt_time').attr('onkeypress',"return isTimeKey(event);");
		$('#' + rowId+i + '_end_time').attr('onkeypress',"return isTimeKey(event);");
		$('#' + rowId+i + '_strt_time').on('keyup',addColon);
		$('#' + rowId+i + '_end_time').on('keyup',addColon);
		$('#' + rowId+i + '_appn_outp_pssb_cnt').attr('onkeypress',"return isNumberKey(event);");
		$('#' + rowId+i + '_appn_inpt_pssb_cnt').attr('onkeypress',"return isNumberKey(event);");
		$('#' + rowId+i + '_appn_hlxm_pssb_cnt').attr('onkeypress',"return isNumberKey(event);");
		}
	}
}


function fn_query(){
	for (i=0;i<7;i++){
		
		var listId = "#list"+(i+1);
		var wkdy = wkdyList[i];
		
		$(listId).clearGridData();
		$(listId).jqGrid("setGridParam",{       
			postData: {
				hspt_id:$("#session_hspt_id").val(),     
				wkdy:wkdy,        
				imgn_room_cd:$("#select_imgn_room_cd").val()
			},         
			datatype:"json"     
		}).trigger("reloadGrid"); 
	}
}




