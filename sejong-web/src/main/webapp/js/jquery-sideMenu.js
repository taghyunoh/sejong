jQuery(function($){
	
	// Side Menu
	var lnb = $('div.lnBox');
	var sItem = lnb.find('>ul>li');
	var ssItem = lnb.find('>ul>li>ul>li');
	var lastEvent = null;
	
	sItem.find('>ul').css('display','none');
	lnb.find('>ul>li>ul>li[class=active]').parents('li').attr('class','active');
	lnb.find('>ul>li[class=active]').find('>ul').css('display','block');

	function lnbToggle(event){
		var t = $(this);
		
		if (this == lastEvent) return false;
		lastEvent = this;
		setTimeout(function(){ lastEvent=null }, 200);
		
		if (t.next('ul').is(':hidden')) {
			sItem.find('>ul').slideUp(100);
			t.next('ul').slideDown(100);
		} else if(!t.next('ul').length) {
			sItem.find('>ul').slideUp(100);
		} else {
			t.next('ul').slideUp(100);
		}
		
		if (t.parent('li').hasClass('active')){
			t.parent('li').removeClass('active');
		} else {
			sItem.removeClass('active');
			t.parent('li').addClass('active');
		}
		location.href=t.attr("href");
		
	}
	function lnbTogglef(event){
		
			var t = $(this);
			
			if (this == lastEvent) return false;
			lastEvent = this;
			setTimeout(function(){ lastEvent=null }, 200);
			
			if (t.next('ul').is(':hidden')) {
				sItem.find('>ul').slideUp(100);
				t.next('ul').slideDown(100);
			} else if(!t.next('ul').length) {
				sItem.find('>ul').slideUp(100);
			} else {
				t.next('ul').slideUp(100);
			}
			
			if (t.parent('li').hasClass('active')){
				//t.parent('li').removeClass('active');
			} else {
				//sItem.removeClass('active');
				//t.parent('li').addClass('active');
			}
			//location.href=t.attr("href");
	 }
	sItem.find('>a').focus(lnbTogglef);
	//sItem.find('>a').click(lnbToggle).focus(lnbTogglef);
	
	function subMenuActive(){
		ssItem.removeClass('active');
		$(this).parent(ssItem).addClass('active');
	}; 
	ssItem.find('>a').click(subMenuActive).focus(subMenuActive);

});



