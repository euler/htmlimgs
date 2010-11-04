#!/bin/bash
#
# Emit on stdout a simple one element  to show photos in $1 or "."
# Self contained, minimal
#

  # $v Verbose defaults off unless set in env
  dir=${1:-"."}
  [[ $v ]] && echo dir=$dir
  
cat <<END
<html>
<head>
  <title>Directory $dir</title>
  <style>
    .max90 {
       max-height:90%;
       max-width:90%;
    }
    .full {
       max-height:none;
       max-width:none;
    }
  </style>
  <script>
  photos = [
END
  for f in $dir/*.jpg
  do
  cat <<END
  "$f",
END
  done
cat <<END
  ];

function initPage() {
 h = document.getElementById("h");
 i = document.getElementById("i");
 numphotos = photos.length;
 n = 0;
 showphoto(n);
}

function showphoto(n){
 h.innerHTML = photos[n];
 i.src = photos[n];
}

function swapimgclass(){
  i.className = (i.className == "max90") ? "full" : "max90";
  return false;
}

function forward() {
 n = n + 1;
 if ( n >= numphotos ) n = 0;
 showphoto(n);
}

function backward() {
 n = n - 1;
 if ( n < 0  ) n = numphotos-1;
 showphoto(n);
}

function dokey(e){
  /* Non-IE handling only */
  var keychar = String.fromCharCode(e.which);

  /* Remember n, the photo number now being shown */
  var inbound_n = n;

  if (keychar ==  "f") forward();
  if (keychar ==  "b") backward();
  /* Arrow keys */
  if (e.keyCode == 37) backward();
  if (e.keyCode == 39) forward();

  /*
  ** If keystroke moved the photo, ignore it.
  ** Otherwise, process the event as usuual.
  */

  if (n != inbound_n) {
    /* Photo moved by this keystroke, no more processing */
    if (e.preventDefault) e.preventDefault( );
    if (e.returnValue) e.returnValue = false;
    return false;
  }
  return true;

}

</script>
</head>

<body onload="initPage();" onkeypress="dokey(event);">
<h2 id="h">$dir</h2>

<img id="i"
     src="dynamic"
     class="max90"
     onclick="swapimgclass();"
 />
<br />

</body>
</html>
END
