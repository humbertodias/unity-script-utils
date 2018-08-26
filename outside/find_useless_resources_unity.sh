#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

rm unused_files.log &> /dev/null

grep -r . --include=\*.meta --exclude=*{Editor,Gizmos}* -e 'guid' | while read line; do
  guuid=`echo $line | awk '{print $NF}'`
  path=`echo $line | cut -f1 -d":"`
  no_meta=`echo $path | sed "s/.meta$//"`
  # Skip if is directory
  if [[ -d $no_meta ]]; then
    continue
  fi

  filename=$(basename "$path")
  filename="${filename%.*}"

  echo -e "${GREEN}Currently searching for $guuid in $filename${NC}"
  grep -rn . --include=\*.{unity,anim,controller,prefab,mat} -e $guuid
  if [[ $? != 0 ]]; then
    echo $filename | grep .cs$ && is_script=$? || is_script=$?
    echo $filename | grep .unity$ && is_map=$? || is_map=$?

    if [[ $is_script == 0 ]]; then
      echo -e "${YELLOW}FILE $path not used directly, searching...${NC}"
      grep -rn . --include=\*.cs --exclude=$no_meta -e "${filename%.*}"
      if [[ $? != 0 ]]; then
        echo -e "${RED}FILE $path is unused!!!${NC}"
        echo $path >> unused_files.log
      fi
    elif [[ $is_map == 0 ]]; then
      echo -e "${YELLOW}FILE $path not used directly, searching...${NC}"
      grep ProjectSettings/EditorBuildSettings.asset -e `echo $no_meta | sed "s/^\.\///"`
      if [[ $? != 0 ]]; then
        echo -e "${RED}FILE $path is unused!!!${NC}"
        echo $path >> unused_files.log
      fi
    else
      echo -e "${RED}FILE $path is unused!!!${NC}"
      echo $path >> unused_files.log
    fi
  fi
done
