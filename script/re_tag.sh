[alias]
  tag-new = "!f () {\
    if [ \"$1\" = \"-v\" ];then \
      tag=\"$2\";\
      shift;shift;\
    else \
      tag=v$(git tag|sed s/v//g|sort -t . -n -k1,1 -k2,2 -k3,3|tail -n1);\
      tag_minor=${tag##*.};\
      ((tag_minor++));\
      tag=${tag%.*}.${tag_minor};\
    fi;\
    if [ $# -ne 0 ];then \
      comment=\"$*\";\
    else \
      comment=\"$(git log -1|tail -n +5)\";\
    fi;\
    echo comment: $comment;\
    tagcheck=$(git tag|grep ${tag});\
    if [ \"$tagcheck\" != \"\" ];then \
      echo \"tag: ${tag} exists\"\
      echo \"Please check tag or use tag-renew.\"\
      return 1;\
    fi;\
    git tag -a ${tag} -m \"${comment}\";\
    git push --tag;\
  };f"
