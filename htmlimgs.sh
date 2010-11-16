#!/bin/bash
#
# htmlimgs.sh
#
# Emit an HTML file on stdout which can browse the images in
# the directory given in $1
#
# Optionally, the agruments can be full "find" command arguments.
# See "man find".
#
# Show one photo at a time, scaled to fit the browser window.
# See usage() below for interactive controls.
#
# Goals:
#   - This generator to depend only on common Linux/OSX utilties
#   - HTML browser file to be self contained, without dependencies
#

# Use given directory or "." if none given
# In truth, $dir is really a full "find" command argument set
# 
# E.g., sh one.sh ~ /tmp -maxdepth 1

VERSION="v0.61"

function usage() { 
cat 1>&2 <<ENDUSAGE
$0 $VERSION: $1

Generate an html file to browse a set of images
Usage:
   $0 directory >showphotos.html
   -or- 
   $0 [find command args] >showphotos.html
Examples:
   $0 . >index.html
   $0 ~/Desktop/panos >/tmp/wide.html
   $0 ~/Desktop/panos . --newer ~/Desktop/previous >/tmp/wide.html

See bottom of source file $0 for credits and license.
ENDUSAGE
}

# "dir" may also be a generalized find command argument set
  dir="$*"

# Maybe emit usage statment for help request
  if [[ "$dir" =~ (^$)|^(-[?hHv]|-help|--help|-version|--version)$ ]]
  then 
    usage
    exit 1
  fi
  
# Emit first part of html file
cat <<END
<html>
<head>
  <title>Photos in $dir</title>
  <style>
    html, body {
       margin: 0;
       padding: 0;
       height: 100%;
    }
    div {
       height: 95%;
       margin: 0;
       padding: 0;
    }
    body {
       background: black;
       color: #cccccc;
       margin: 0;
       padding: 0;
    }
    .max90 {
       max-height:95%;
       max-width: 100%;
       margin: 0;
       padding: 0;
       text-align: center;
    }
    .full {
       max-height: none;
       max-width: none;
       margin: 0;
       text-align: center;
    }
    .boxedimg {
       max-height: inherit;
       max-width: inherit;
       margin: 0;
       padding: 0;
    }
    .center {
       text-align: center;
       margin: 0;
       padding: 0;
    }
    .label {
       font-family: helvetica;
       font-style: bold;
       text-align: center;
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
 /* Init global variables */
 fname = document.getElementById("fname");
 img = document.getElementById("img");
 imgbox = document.getElementById("imgbox");
 numphotos = photos.length;
 n = 0;
 actions = 0;

 /* Action keys. Case-insensitive regular expresions */
 fwdchars = /[fjln ]/i;
 bckchars = /[bkhp]/i;
 gotonchars = /[g]/i;
 sizechars = /[-+_=]/;

 showphoto(n);
}

function showphoto(num){
 n = num;
 /* Clip n to array bounds */
 if ( n >= numphotos ) n = numphotos-1;
 if ( n < 0  ) n = 0;

 /* Show file name and photo number */
 fname.innerHTML = photos[n];
 xofn.innerHTML = "Photo " + (n+1) + " of " + numphotos + ".";

 /* Increment global actions counter for higher level keystroke filter */
 actions++;
 /* Start loading */
 img.src = photos[n];
}

function swapimgboxclass(){
  imgbox.className = (imgbox.className == "max90") ? "full" : "max90";
  actions++;
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

function goton() {
  var nstr = prompt("Go to photo 1 to " + numphotos + "? ", (n+1) + "");
  n = parseInt(nstr) - 1;
  if (isNaN(n)) n = 0;
  showphoto(n);
}

function dokey(e){
  /* Non-IE handling only */
  var keychar = String.fromCharCode(e.which);

  /* Remember actions, the global count of display actions */
  var inbound_actions = actions;

  if (fwdchars.test(keychar)) forward();
  if (bckchars.test(keychar)) backward();
  if (gotonchars.test(keychar)) goton(); 
  if (sizechars.test(keychar)) swapimgboxclass(); 

  /* Arrow keys */
  if (e.keyCode == 37) backward();
  if (e.keyCode == 39) forward();

  /*
  ** If keystroke caused action, do no more processing.
  ** Otherwise, process the event as usuual.
  */

  if (actions != inbound_actions) {
    /* Keystroke caused action, no more processing */
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
(Forward, back with "f","b", space, arrow, editor keys; click|+- toggle size,"g" goto)
</div>
</div>

</body>
</html>
END

exit 0

/* 

Concept and design by Matt Niemeir.
Code by Ray Niemeir.

Copyright (c) 2010, Raymond L. Niemeir

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.

*/

