#!/bin/bash

echo ${@: 1:$#-2}
echo ${@: -1}
echo ${@: -2:1}

set -x
ffmpeg -hide_banner -i ${@: 1:$#-2} -c:v pam -f image2pipe - | convert -delay ${@: -2:1} - -loop 0 -layers optimize ${@: -1}

