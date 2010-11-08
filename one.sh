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
# Refinement $dir is really a full "find" command argument set
# 
# E.g., sh one.sh ~ /tmp -maxdepth 1
  dir="$*"
  dir=${dir:-"."}
  
# Emit first part of html file
cat <<END
<html>
<head>
  <title>Photos in $dir</title>
  <style>
    html, body, div {
       height: 100%;
    }
    .max90 {
       max-height:90%;
       max-width:90%;
    }
    .full {
       max-height: none;
       max-width: none;
    }
    .boxedimg {
       max-height: inherit;
       max-width: inherit;
    }
    .center {
       text-align: center;
    }
    .label {
       font-family: helvetica;
       font-style: bold;
    }
  </style>
  <script>
//  Array of photo file names created $(date)
//  by script: $0 $dir
  photos = [
END

# Emit the elements of the photo file name array
  find "$dir" | egrep -i 'jpg$|jpeg$|png$|tiff$|tif$' | sort |
  while read -r f
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
 imgbox = document.getElementById("imgbox");
 numphotos = photos.length;
 n = 0;
 showphoto(n);
}

function showphoto(n){
 fname.innerHTML = photos[n];
 xofn.innerHTML = "Photo " + (n+1) + " of " + numphotos + ".";
 img.src = photos[n];
}

function swapimgboxclass(){
  imgbox.className = (imgbox.className == "max90") ? "full" : "max90";
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

  /* Movement keys. Case-insensitive regular expresions */
  fwdchars = /[fjln ]/i;
  bckchars = /[bkhp]/i;

  if (fwdchars.test(keychar)) forward();
  if (bckchars.test(keychar)) backward();

  /* Arrow keys */
  if (e.keyCode == 37) backward();
  if (e.keyCode == 39) forward();

  /*
  ** If keystroke moved the photo, do no more processing.
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
  <div id="imgbox" class="max90">
  <img id="img" class="boxedimg"
     src="dynamic"
     onclick="swapimgboxclass();"/>
<ul class="label">
 <li id="fname">File Name</li>
 <li id="xofn">Photo x of N</li>
</ul>
(Forward, backward with "f","b", space, arrow or editor keys)
</div>
</div>

</body>
</html>
END
