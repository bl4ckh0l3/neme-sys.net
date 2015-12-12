function checkBrowser(){
this.ver=navigator.appVersion
this.dom=document.getElementById?1:0
this.ie5=(this.ver.indexOf("MSIE 5")>-1 && this.dom)?1:0;
this.ie4=(document.all && !this.dom)?1:0;
this.ns5=(this.dom && parseInt(this.ver) >= 5) ?1:0;
this.ns4=(document.layers && !this.dom)?1:0;
this.bwb=(this.ie5 || this.ie4 || this.ns4 || this.ns5)
return this
}
bwb=new checkBrowser()

var speed=35
var vel_scroll=1
var st=0
var loaded
var loop, timer

function makeObj(obj,nest){
nest=(!nest) ? '':'document.'+nest+'.'
this.el=bwb.dom?document.getElementById(obj):bwb.ie4?document.all[obj]:bwb.ns4?MM_findObj("divText"):0;
this.css=bwb.dom?document.getElementById(obj).style:bwb.ie4?document.all[obj].style:bwb.ns4?MM_findObj("divText"):0;
this.scrollHeight=bwb.ns4?this.css.document.height:this.el.offsetHeight
this.clipHeight=bwb.ns4?this.css.clip.height:this.el.offsetHeight
this.up=goUp;this.down=goDown;
this.moveIt=moveIt; this.x; this.y;
this.obj = obj + "Object"
eval(this.obj + "=this")
return this
}
function MM_setTextOfLayer(objName,x,newText) { //v4.01
  if ((obj=MM_findObj(objName))!=null){ with (obj)
    if (document.layers) {document.write(unescape(newText)); document.close();}
    else innerHTML = unescape(newText);
	}
	
oCont=new makeObj('divCont')
oScroll=new makeObj('divText','divCont')
oScroll.moveIt(0,85)
oCont.css.visibility='visible'
loaded=true;
scroll(vel_scroll);
}
function moveIt(x,y){
this.x=x;this.y=y
this.css.left=this.x
this.css.top=this.y
}
var sa='';
function goDown(move){
oCont.clipHeight=85;
if(this.scrollHeight==0){
	this.scrollHeight=bwb.ns4?this.css.document.height:this.el.offsetHeight;
	//oCont.clipHeight=bwb.ns4?oCont.css.clip.height:oCont.el.offsetHeight
}
if(this.y>-this.scrollHeight+oCont.clipHeight-75){
//alert(this.y+'aaa'+this.scrollHeight+'aaa'+oCont.clipHeight)
this.moveIt(0,this.y-move)
if(loop) timer=setTimeout(this.obj+".down("+move+")",speed)
}
else {
noScroll();
this.moveIt(0,85);
noScroll();
scroll(vel_scroll);
};
}

function goUp(move){
if(this.y<0){
this.moveIt(0,this.y-move)
if(loop) timer=setTimeout(this.obj+".up("+move+")",speed)
}
}

function scroll(speed){
if(st==0) {
if(loaded){
st=1;
loop=true;
if(speed>0) oScroll.down(speed)
else oScroll.up(speed)
}
}
}

function noScroll(){
loop=false
st=0;
if(timer) clearTimeout(timer)
}
function MM_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}
function news(){
str='';
nwl=nw[0].length;
numrep=8;
for(i=0;i<nwl*numrep;i++) str+='<a href="#" class="txt10" onmouseover="noScroll()" onmouseout="scroll(vel_scroll)">'+nw[0][i%nwl]+'</a><br><br>';
MM_setTextOfLayer('divText','',str);
}

