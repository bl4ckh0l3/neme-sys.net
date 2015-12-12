function preloadSelectedImages(images) {
    if (document.images) {
        var i = 0;
        var imageArray = new Array();
        imageArray = images.split(',');
        var imageObj = new Image();
        for(i=0; i<=imageArray.length-1; i++) {
            //document.write('<img src="' + imageArray[i] + '" />');// Write to page (uncomment to check images)
            imageObj.src=imageArray[i];
			//alert(imageArray[i]);
        }
    }
}

function openWin(url_pag,windowsname,dime,dimes,left,top){
	var hWnd=window.open(url_pag,windowsname,"toolbar=no,width="+dime+",height="+dimes+",left="+left+",top="+top+",directories=no,status=no,statusbar=no,resizable=1,menubar=no,scrollbars=yes");
	if(!hWnd.opener) hWnd.opener=self;
	if(hWnd.focus!=null) hWnd.focus();
}

function openWinExcel(url_pag,windowsname,dime,dimes,left,top){
	var hWnd=window.open(url_pag,windowsname,"toolbar=no,width="+dime+",height="+dimes+",left="+left+",top="+top+",directories=no,status=no,statusbar=no,resizable=1,menubar=yes,scrollbars=yes");
	if(!hWnd.opener) hWnd.opener=self;
	if(hWnd.focus!=null) hWnd.focus();
}

function isNumerico(inputStr) {	
	for (var i = 0; i < inputStr.length; i++) {
		var oneChar = inputStr.substring(i, i + 1)
		if (oneChar < "0" || oneChar > "9") {

			return false;
		}
	}
	return true;
}

//consente di digitare numeri e il punto
function isDecimal(e){
	var key = window.event ? e.keyCode : e.which;	
	var keychar = String.fromCharCode(key);		
	if (isNumerico(keychar) || key==8 || key==9 || key==0 || key==46){					
		return true;
	}
	return false;
}

//consente di digitare numeri e il punto
function isDouble(e){
	var key = window.event ? e.keyCode : e.which;	
	var keychar = String.fromCharCode(key);		
	if (isNumerico(keychar) || key==8 || key==9 || key==0 || key==46 || key==44){					
		return true;
	}
	return false;
}

//consente di digitare numeri fino a tre cifre intere e due punti decimali
function checkDoubleFormat(field){
	var fieldVal = field;	
	/*alert("fieldVal: " + fieldVal);
	
	var expr1 = /^\d+,\d+$/;
	var expr2 = /^\d+$/;
			
	var expr3 = /(^\d$)|(^\d,\d$)|(^10$)|(^10,0$)/;
	var expr4 = /(^\d{4}\/([1-9]|10|11|12)$)/;
	var expr5 = /^[0-9]$/*/
	
	var expr =/(^\d{1,3}$)|(^\d{1,3}\,\d{1,2}$)/;
	var ok = expr.test(fieldVal);
	//alert("ok: " + ok);
	
	
	/*
	var exprA0 = /^\d$/;
	var exprA1 = /^\d,\d$/;
	var exprA2 = /^10$/;
	var exprA3 = /^10,0$/;
	
	ar ok = exprA0.test(fieldVal);
	alert("ok0: " + ok);	
	ok = (ok || exprA1.test(fieldVal));		
	alert("ok1: " + ok);
	ok = (ok || exprA2.test(fieldVal));
	alert("ok2: " + ok);
	ok = (ok || exprA3.test(fieldVal));
	alert("ok3: " + ok);
	
	alert("ok: " + ok);	
	*/
	
	return ok;
}

//consente di digitare numeri e il punto
function checkDoubleFormatExt(field){
	var fieldVal = field;	
	
	var expr =/^\d+.?\d*$/;
	var ok = expr.test(fieldVal);
	
	return ok;
}


//consente di digitare numeri
function isInteger(e){
	var key = window.event ? e.keyCode : e.which;	
	var keychar = String.fromCharCode(key);		
	if (isNumerico(keychar) || key==8 || key==9 || key==0){					
		return true;
	}
	return false;
}

//consente di digitare numeri con segno
function isIntegerUnsigned(e){
	var key = window.event ? e.keyCode : e.which;	
	var keychar = String.fromCharCode(key);		
	if (isNumerico(keychar) || key==8 || key==9 || key==0 || key==109 || key==189 || key==45){					
		return true;
	}
	return false;
}

//non consente di digitare caratteri speciali
function notSpecialChar(e){
	var key = window.event ? e.keyCode : e.which;	
	var keychar = String.fromCharCode(key);	
	// lista caratteri non validi: 
	// - tutti i tasti speciali e combinazioni (tab, alt, alt+tab, ctrl, del, ...) - in parte usano (key!0 && key!=8) quindi le lascio attive
	// - |!"�$%&/()=?'^*+#@_.:,;
 	
	//alert("key: "+key+" - keychar: "+keychar);
	if (key!=0 && key!=9 && key!=13 && key!=16 && key!=17 && key!=18 && key!=19 && key!=20 && key!=27 && key!=33 && key!=34 && key!=35 && key!=36 && key!=37 && key!=38 && key!=39 && key!=40 && key!=41 && key!=42 && key!=43 && key!=44 && key!=46 && key!=47 && key!=58 && key!=59 && key!=60 && key!=61 && key!=62 && key!=63 && key!=64 && key!=94 && key!=95 && key!=124 && key!=163 && key!=176 && key!=167/* && key!=224 && key!=231 && key!=232 && key!=233 && key!=236 && key!=242 && key!=249*/){					
		return true;
	}
	return false;
}

//non consente di digitare caratteri speciali e lo spazio
function notSpecialCharAndSpace(e){
	var key = window.event ? e.keyCode : e.which;	
	var keychar = String.fromCharCode(key);	
	// lista caratteri non validi: 
	// - tutti i tasti speciali e combinazioni (tab, alt, alt+tab, ctrl, del, ...) - in parte usano (key!0 && key!=8) quindi le lascio attive
	// - |!"�$%&/()=?'^*+#@_.:,;
 	
	//alert("key: "+key+" - keychar: "+keychar);
	if (key!=0 && key!=9 && key!=13 && key!=16 && key!=17 && key!=18 && key!=19 && key!=20 && key!=27 && key!=32 && key!=33 && key!=34 && key!=35 && key!=36 && key!=37 && key!=38 && key!=39 && key!=40 && key!=41 && key!=42 && key!=43 && key!=44 && key!=46 && key!=47 && key!=58 && key!=59 && key!=60 && key!=61 && key!=62 && key!=63 && key!=64 && key!=94 && key!=95 && key!=124 && key!=163 && key!=231 && key!=176 && key!=167 && key!=232 && key!=233 && key!=242 && key!=224 && key!=249 && key!=236){					
		return true;
	}
	return false;
}

//non consente di digitare caratteri speciali e lo spazio
function notSpecialCharButUnderscore(e){
	var key = window.event ? e.keyCode : e.which;	
	var keychar = String.fromCharCode(key);	
	// lista caratteri non validi: 
	// - tutti i tasti speciali e combinazioni (tab, alt, alt+tab, ctrl, del, ...) - in parte usano (key!0 && key!=8) quindi le lascio attive
	// - |!"�$%&/()=?'^*+#@_.:,;
 	
	//alert("key: "+key+" - keychar: "+keychar);
	if (key!=0 && key!=9 && key!=13 && key!=16 && key!=17 && key!=18 && key!=19 && key!=20 && key!=27 && key!=32 && key!=33 && key!=34 && key!=35 && key!=36 && key!=37 && key!=38 && key!=39 && key!=40 && key!=41 && key!=42 && key!=43 && key!=44 && key!=45 && key!=46 && key!=47 && key!=58 && key!=59 && key!=60 && key!=61 && key!=62 && key!=63 && key!=64 && key!=94 && key!=124 && key!=163 && key!=231 && key!=176 && key!=167 && key!=232 && key!=233 && key!=242 && key!=224 && key!=249 && key!=236){	/* && key!=95*/				
		return true;
	}
	return false;
}

//non consente di digitare caratteri speciali e lo spazio
function notSpecialCharButUnderscoreAndMinus(e){
	var key = window.event ? e.keyCode : e.which;	
	var keychar = String.fromCharCode(key);	
	// lista caratteri non validi: 
	// - tutti i tasti speciali e combinazioni (tab, alt, alt+tab, ctrl, del, ...) - in parte usano (key!0 && key!=8) quindi le lascio attive
	// - |!"�$%&/()=?'^*+#@_.:,;
 	
	//alert("key: "+key+" - keychar: "+keychar);
	if (key!=0 && key!=9 && key!=13 && key!=16 && key!=17 && key!=18 && key!=19 && key!=20 && key!=27 && key!=32 && key!=33 && key!=34 && key!=35 && key!=36 && key!=37 && key!=38 && key!=39 && key!=40 && key!=41 && key!=42 && key!=43 && key!=44 && key!=46 && key!=47 && key!=58 && key!=59 && key!=60 && key!=61 && key!=62 && key!=63 && key!=64 && key!=94 && key!=124 && key!=163 && key!=231 && key!=176 && key!=167 && key!=232 && key!=233 && key!=242 && key!=224 && key!=249 && key!=236){	/* && key!=95*/				
		return true;
	}
	return false;
}

//non consente di digitare caratteri speciali e lo spazio
function notSpecialCharButUnderscoreAndMinusAndSlashAndDot(e){
	var key = window.event ? e.keyCode : e.which;	
	var keychar = String.fromCharCode(key);	
	// lista caratteri non validi: 
	// - tutti i tasti speciali e combinazioni (tab, alt, alt+tab, ctrl, del, ...) - in parte usano (key!0 && key!=8) quindi le lascio attive
	// - |!"�$%&/()=?'^*+#@_.:,;
 	
	//alert("key: "+key+" - keychar: "+keychar);
	if (key!=0 && key!=9 && key!=13 && key!=16 && key!=17 && key!=18 && key!=19 && key!=20 && key!=27 && key!=32 && key!=33 && key!=34 && key!=35 && key!=36 && key!=37 && key!=38 && key!=39 && key!=40 && key!=41 && key!=42 && key!=43 && key!=44 && key!=58 && key!=59 && key!=60 && key!=61 && key!=62 && key!=63 && key!=64 && key!=94 && key!=124 && key!=163 && key!=231 && key!=176 && key!=167 && key!=232 && key!=233 && key!=242 && key!=224 && key!=249 && key!=236){	/* && key!=95*/				
		return true;
	}
	return false;
}

//non consente di digitare caratteri speciali e lo spazio
function notSpecialCharButUnderscoreAndMinusAndDot(e){
	var key = window.event ? e.keyCode : e.which;	
	var keychar = String.fromCharCode(key);	
	// lista caratteri non validi: 
	// - tutti i tasti speciali e combinazioni (tab, alt, alt+tab, ctrl, del, ...) - in parte usano (key!0 && key!=8) quindi le lascio attive
	// - |!"�$%&/()=?'^*+#@_:,;
 	
	//alert("key: "+key+" - keychar: "+keychar);
	if (key!=0 && key!=9 && key!=13 && key!=16 && key!=17 && key!=18 && key!=19 && key!=20 && key!=27 && key!=32 && key!=33 && key!=34 && key!=35 && key!=36 && key!=37 && key!=38 && key!=39 && key!=40 && key!=41 && key!=42 && key!=43 && key!=44 && key!=47 && key!=58 && key!=59 && key!=60 && key!=61 && key!=62 && key!=63 && key!=64 && key!=94 && key!=124 && key!=163 && key!=231 && key!=176 && key!=167 && key!=232 && key!=233 && key!=242 && key!=224 && key!=249 && key!=236){	/* && key!=95*/				
		return true;
	}
	return false;
}

//non consente di digitare caratteri speciali e lo spazio ma permette il click sul tasto return
function notSpecialCharAndSpaceButReturn(e){
	var key = window.event ? e.keyCode : e.which;	
	var keychar = String.fromCharCode(key);	
	// lista caratteri non validi: 
	// - tutti i tasti speciali e combinazioni (tab, alt, alt+tab, ctrl, del, ...) - in parte usano (key!0 && key!=8) quindi le lascio attive
	// - |!"�$%&/()=?'^*+#@_.:,;
 	
	//alert("key: "+key+" - keychar: "+keychar);
	if (key!=0 && key!=9 && key!=16 && key!=17 && key!=18 && key!=19 && key!=20 && key!=27 && key!=32 && key!=33 && key!=34 && key!=35 && key!=36 && key!=37 && key!=38 && key!=39 && key!=40 && key!=41 && key!=42 && key!=43 && key!=44 && key!=46 && key!=47 && key!=58 && key!=59 && key!=60 && key!=61 && key!=62 && key!=63 && key!=64 && key!=94 && key!=95 && key!=124 && key!=163 && key!=231 && key!=176 && key!=167 && key!=232 && key!=233 && key!=242 && key!=224 && key!=249 && key!=236){					
		return true;
	}
	return false;
}

function isSpecialChar(inputStr) {
	for (var i = 0; i < inputStr.length; i++) {
		var oneChar = inputStr.charCodeAt(i);
		if (oneChar==0 || oneChar==9 || oneChar==13 || oneChar==16 || oneChar==17 || oneChar==18 || oneChar==19 || oneChar==20 || oneChar==27 || oneChar==33 || oneChar==34 || oneChar==35 || oneChar==36 || oneChar==37 || oneChar==38 || oneChar==39 || oneChar==40 || oneChar==41 || oneChar==42 || oneChar==43 || oneChar==44 || oneChar==46 || oneChar==47 || oneChar==58 || oneChar==59 || oneChar==60 || oneChar==61 || oneChar==62 || oneChar==63 || oneChar==64 || oneChar==94 || oneChar==95 || oneChar==124 || oneChar==163) {
			return true;
		}
	}
	return false;
}

function isSpecialCharButUnderscoreAndMinus(inputStr) {
	for (var i = 0; i < inputStr.length; i++) {
		var oneChar = inputStr.charCodeAt(i);
		if (oneChar==0 || oneChar==9 || oneChar==13 || oneChar==16 || oneChar==17 || oneChar==18 || oneChar==19 || oneChar==20 || oneChar==27 || oneChar==32 || oneChar==33 || oneChar==34 || oneChar==35 || oneChar==36 || oneChar==37 || oneChar==38 || oneChar==39 || oneChar==40 || oneChar==41 || oneChar==42 || oneChar==43 || oneChar==44 || oneChar==46 || oneChar==47 || oneChar==58 || oneChar==59 || oneChar==60 || oneChar==61 || oneChar==62 || oneChar==63 || oneChar==64 || oneChar==94 || oneChar==124 || oneChar==163) {
			return true;
		}
	}
	return false;
}


/*function dynamiccontentNS6(elementid,content){
	if (document.getElementById && !document.all){
		//(rng = document.createRange();
		var fragment = document.createDocumentFragment();
		el = document.getElementById(elementid);
		//alert("elementid: " + elementid);
		//alert("content: " + content);
		//alert("el id: " + el.id);
		//alert("el name: " + el.nodeName);
		//alert("el value: " + el.nodeValue);
		//rng.setStartBefore(el);
		//htmlFrag = rng.createContextualFragment(content);	
		fragment.appendChild(content);
		//alert("fragment: " + fragment);
		while (el.hasChildNodes())
			el.removeChild(el.lastChild);
		
		//el.appendChild(htmlFrag);
		el.appendChild(fragment);
	}
}*/

function dynamiccontentNS6(elementid,content){
	if (document.getElementById && !document.all){
		rng = document.createRange();
		el = document.getElementById(elementid);
		rng.setStartBefore(el);
		htmlFrag = rng.createContextualFragment(content);
		while (el.hasChildNodes())
			el.removeChild(el.lastChild);
		el.appendChild(htmlFrag);
	}
}

function updateDOM(inputField, newVal) {
    // if the inputField ID string has been passed in, get the inputField object
    if (typeof inputField == "string") {
        inputField = document.getElementById(inputField);
    }
    
    /*alert("inputField: " +inputField.name);
    alert("inputField.value before: " +inputField.value);
    alert("inputField.type: " +inputField.type);
    alert("newVal: " +newVal);*/

    if (inputField.type == "select-one") {
        for (var i=0; i<inputField.options.length; i++) {
            //if (i == inputField.selectedIndex) {
	    if (i == newVal) {
                inputField.options[inputField.selectedIndex].setAttribute("selected","selected");
            }
        }
    } else if (inputField.type == "text" || inputField.type == "textarea" || inputField.type == "hidden") {
        //inputField.setAttribute("value",inputField.value);
        inputField.setAttribute("value",newVal);
    } else if ((inputField.type == "checkbox") || (inputField.type == "radio")) {
        if (inputField.checked) {
            inputField.setAttribute("checked","checked");
        } else {
            inputField.removeAttribute("checked");
        }
    }
    /*alert("inputField.value: " +inputField.value);
    alert("inputField.getAttribute(value): " +inputField.getAttribute("value"));*/
}


var ns4,op5,op6,agt,mac,ie,mac_ie = null;

function sniffBrowsers() {
	ns4 = document.layers;
	op5 = (navigator.userAgent.indexOf("Opera 5")!=-1) 
		||(navigator.userAgent.indexOf("Opera/5")!=-1);
	op6 = (navigator.userAgent.indexOf("Opera 6")!=-1) 
		||(navigator.userAgent.indexOf("Opera/6")!=-1);
	agt=navigator.userAgent.toLowerCase();
	mac = (agt.indexOf("mac")!=-1);
	ie = (agt.indexOf("msie") != -1); 
	mac_ie = mac && ie;
}

function resizeimagesByID(idImage, maxWidth){
	var agt=navigator.userAgent.toLowerCase();
	var ie7 = (agt.indexOf("msie 7.0") != -1);
	var max_width = maxWidth;
	var img_width, img_height;
	var img = document.getElementById(idImage);
	
	if(img){
		img_width = getImageWidth(idImage);
		img_height = getImageHeight(idImage);
	
		if(!ie7){
			if ( img.width > max_width){
				var old_width = img.width;
				var old_height = img.height;
				img.width = max_width;
				img.height = Math.round(old_height * max_width / old_width);
			} 
		}else{
			img.width = max_width;			
		}
	}
}

function getImageWidth(myImage) {
	var x, obj;
	if (document.layers) {
		var img = getImage(myImage);
		return img.width;
	} else {
		return getElementWidth(myImage);
	}
	return -1;
}

function getImageHeight(myImage) {
	var y, obj;
	if (document.layers) {
		var img = getImage(myImage);
		return img.height;
	} else {
		return getElementHeight(myImage);
	}
	return -1;
}

function getElementHeight(Elem) {
	if (ns4) {
		var elem = getObjNN4(document, Elem);
		return elem.clip.height;
	} else {
		if(document.getElementById) {
			var elem = document.getElementById(Elem);
		} else if (document.all){
			var elem = document.all[Elem];
		}
		if (op5) { 
			xPos = elem.style.pixelHeight;
		} else {
			xPos = elem.offsetHeight;
		}
		return xPos;
	} 
}

function getElementWidth(Elem) {
	if (ns4) {
		var elem = getObjNN4(document, Elem);
		return elem.clip.width;
	} else {
		if(document.getElementById) {
			var elem = document.getElementById(Elem);
		} else if (document.all){
			var elem = document.all[Elem];
		}
		if (op5) {
			xPos = elem.style.pixelWidth;
		} else {
			xPos = elem.offsetWidth;
		}
		return xPos;
	}
}

function findImage(name, doc) {
	var i, img;
	for (i = 0; i < doc.images.length; i++) {
    	if (doc.images[i].name == name) {
			return doc.images[i];
		}
	}
	for (i = 0; i < doc.layers.length; i++) {
    	if ((img = findImage(name, doc.layers[i].document)) != null) {
			img.container = doc.layers[i];
			return img;
    	}
	}
	return null;
}

function getImage(name) {
	if (document.layers) {
    	return findImage(name, document);
	}
	return null;
}

function getObjNN4(obj,name)
{
	var x = obj.layers;
	var foundLayer;
	for (var i=0;i<x.length;i++)
	{
		if (x[i].id == name)
		 	foundLayer = x[i];
		else if (x[i].layers.length)
			var tmp = getObjNN4(x[i],name);
		if (tmp) foundLayer = tmp;
	}
	return foundLayer;
}

function showHideDiv(elemID){
	var element = document.getElementById(elemID);
	if(element.style.visibility == 'visible'){
		element.style.visibility = 'hidden';
		element.style.display = "none";
	}else if(element.style.visibility == 'hidden'){
		element.style.visibility = 'visible';		
		element.style.display = "block";
	}
}

function changeInputBox(display, hide, field){
  document.getElementById(hide).style.display='none';
  document.getElementById(display).style.display='';
  document.getElementById(field).focus();
}

function restoreInputBox(display, hide, field){
	if(document.getElementById(field).value==''){
	  document.getElementById(display).style.display='';
	  document.getElementById(hide).style.display='none';
	}
}
				
function cleanInputField(formfieldId){
  var elem = document.getElementById(formfieldId);
  elem.value="";
}

function restoreInputField(formfieldId, valueField){
  var elem = document.getElementById(formfieldId);
  if(elem.value==''){
	elem.value=valueField;
  }
}

function salvaPreferiti() { 
	var strBrowser;
	strBrowser=navigator.appName;
	if (strBrowser.search("Explorer") != -1){
		window.external.AddFavorite('http://www.blackholenet.com','BHN-nemesi Online Technology Merchant');
	}
	/*else{
		alert("Per aggiungere la pagina fra i preferiti in un browser diverso da Internet Explorer, � possibile premere CTRL+D oppure cercare la relativa voce fra i menu.");
	}*/
}

// JavaScript Document

// Correctly handle PNG transparency in Win IE 5.5 or higher.
// http://homepage.ntlworld.com/bobosola. Updated 02-March-2004

function correctPNG(){
	for(var i=0; i<document.images.length; i++){
		var img = document.images[i]
		var imgName = img.src.toUpperCase()
		if (imgName.substring(imgName.length-3, imgName.length) == "PNG"){
			var imgID = (img.id) ? "id='" + img.id + "' " : ""
			var imgClass = (img.className) ? "class='" + img.className + "' " : ""
			var imgTitle = (img.title) ? "title='" + img.title + "' " : "title='" + img.alt + "' "
			var imgStyle = "display:inline-block;" + img.style.cssText 
			if (img.align == "left") imgStyle = "float:left;" + imgStyle
			if (img.align == "right") imgStyle = "float:right;" + imgStyle
			if (img.parentElement.href) imgStyle = "cursor:hand;" + imgStyle        
			var strNewHTML = "<span " + imgID + imgClass + imgTitle
			+ " style=\"" + "width:" + img.width + "px; height:" + img.height + "px;" + imgStyle + ";"
			+ "filter:progid:DXImageTransform.Microsoft.AlphaImageLoader"
			+ "(src=\'" + img.src + "\', sizingMethod='scale');\"></span>" 
			img.outerHTML = strNewHTML
			i = i-1
		}
	}
}

if(ie||mac_ie){
	window.attachEvent("onload", correctPNG);
}

/************************* funzione avanzata di riconoscimento dei browser **************************/

var BrowserDetect = {
	init: function () {
		this.browser = this.searchString(this.dataBrowser) || "An unknown browser";
		this.version = this.searchVersion(navigator.userAgent)
			|| this.searchVersion(navigator.appVersion)
			|| "an unknown version";
		this.OS = this.searchString(this.dataOS) || "an unknown OS";
	},
	searchString: function (data) {
		for (var i=0;i<data.length;i++)	{
			var dataString = data[i].string;
			var dataProp = data[i].prop;
			this.versionSearchString = data[i].versionSearch || data[i].identity;
			if (dataString) {
				if (dataString.indexOf(data[i].subString) != -1)
					return data[i].identity;
			}
			else if (dataProp)
				return data[i].identity;
		}
	},
	searchVersion: function (dataString) {
		var index = dataString.indexOf(this.versionSearchString);
		if (index == -1) return;
		return parseFloat(dataString.substring(index+this.versionSearchString.length+1));
	},
	dataBrowser: [
		{
			string: navigator.userAgent,
			subString: "Chrome",
			identity: "Chrome"
		},
		{ 	string: navigator.userAgent,
			subString: "OmniWeb",
			versionSearch: "OmniWeb/",
			identity: "OmniWeb"
		},
		{
			string: navigator.vendor,
			subString: "Apple",
			identity: "Safari",
			versionSearch: "Version"
		},
		{
			prop: window.opera,
			identity: "Opera"
		},
		{
			string: navigator.vendor,
			subString: "iCab",
			identity: "iCab"
		},
		{
			string: navigator.vendor,
			subString: "KDE",
			identity: "Konqueror"
		},
		{
			string: navigator.userAgent,
			subString: "Firefox",
			identity: "Firefox"
		},
		{
			string: navigator.vendor,
			subString: "Camino",
			identity: "Camino"
		},
		{		// for newer Netscapes (6+)
			string: navigator.userAgent,
			subString: "Netscape",
			identity: "Netscape"
		},
		{
			string: navigator.userAgent,
			subString: "MSIE",
			identity: "Explorer",
			versionSearch: "MSIE"
		},
		{
			string: navigator.userAgent,
			subString: "Gecko",
			identity: "Mozilla",
			versionSearch: "rv"
		},
		{ 		// for older Netscapes (4-)
			string: navigator.userAgent,
			subString: "Mozilla",
			identity: "Netscape",
			versionSearch: "Mozilla"
		}
	],
	dataOS : [
		{
			string: navigator.platform,
			subString: "Win",
			identity: "Windows"
		},
		{
			string: navigator.platform,
			subString: "Mac",
			identity: "Mac"
		},
		{
			   string: navigator.userAgent,
			   subString: "iPhone",
			   identity: "iPhone/iPod"
	    },
		{
			string: navigator.platform,
			subString: "Linux",
			identity: "Linux"
		}
	]

};
BrowserDetect.init();