#!/bin/bash
#
# Simple, self-contained static HTML photo browser
#
# Emit an HTML file on stdout which references the photos in
# the directory given in $1, or "." 
#
# Show one photo at a time, scaled to fit the browser window.
# Toggle actual size display on click of the image.
# Arrow keys and "f", "b" move through the list of images
#
# Goals:
#   - This generator to depend only on common Linux/OSX utilties
#   - HTML browser file to be self contained, without dependencies
#

# Use given directory or "." if none given
  dir=${1:-"."}
  
# Emit first part of html file
cat <<END
<html>
<head>
  <title>Photos in $dir</title>
  <style>
    .max90 {
       max-height:90%;
       max-width:90%;
    }
    .full {
       max-height:none;
       max-width:none;
    }
    .center {
       text-align: center;
    }
  </style>
  <script>
//  Array of photo file names created $(date)
//  by script: $0 $dir
  photos = [
END

# Emit the elements of the photo file name array
  for f in `find $dir -maxdepth 1 | egrep -i 'jpg$|jpeg$|png$|tiff$|tif$'`
  do
  cat <<END
  "$f",
END
  done

# End the file name array, and emit the rest of the html 
cat <<END
  ];

function initPage() {
 fname = document.getElementById("fname");
 img = document.getElementById("img");
 numphotos = photos.length;
 n = 0;
 showphoto(n);
}

function showphoto(n){
 fname.innerHTML = photos[n];
 xofn.innerHTML = "Photo " + (n+1) + " of " + numphotos + ".";
 img.src = photos[n];
}

function swapimgclass(){
  img.className = (img.className == "max90") ? "full" : "max90";
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
  if (keychar ==  " ") forward();
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
  /* Pass the event/keystroke along for higher level processing */
  return true;

}

</script>
</head>

<body onload="initPage();" onkeypress="dokey(event);">

<div class="center">
<img id="img"
     src="dynamic"
     class="max90"
     onclick="swapimgclass();"
 />
<br />
<ul>
 <li id="fname">File Name</li>
 <li id="xofn">Photo x of N</li>
</ul>
</div>

</body>
</html>
END
