#!/bin/bash
#
# Emit on stdout a simple index.html to show photos in $1 or "."
#

  # Verbose defaults unless set in env
  v=${v:-"t"}
  dir=${1:-"."}
  [[ $v ]] && echo dir=$dir
  
cat <<END
<html>
<head>
  <title>Directory $dir</title>
</head>
<body>
<h2>$dir</h2>
END

  for f in $dir/*.jpg
  do
  cat <<END
<a href="$f">
<img src="$f" width="85%">
</a><br />
END
  done

cat <<END
</body>
</html>
END
