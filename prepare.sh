#!/usr/bin/env bash
set -e

NAME="$1"
if [ -z "$NAME" ]; then
  echo "usage: prepare.sh NAME_OF_YOUR_WROMO" >&2
  exit 1
fi

WROMONAME=$(echo $NAME | tr '[A-Z]' '[a-z]')
ENVNAME="$(echo $NAME | tr '[a-z-]' '[A-Z_]')_ROOT"

echo "Preparing your '$WROMONAME' wromo!"

if [ "$NAME" != "wromo" ]; then
  rm bin/wromo
  mv share/wromo share/$WROMONAME

  for file in **/wromo*; do
    sed "s/wromo/$WROMONAME/g;s/WROMO_ROOT/$ENVNAME/g" "$file" > $(echo $file | sed "s/wromo/$WROMONAME/")
    rm $file
  done

  for file in libexec/*; do
    chmod a+x $file
  done

  ln -s ../libexec/$WROMONAME bin/$WROMONAME
fi

rm README.md
rm prepare.sh

echo "Done! Enjoy your new wromo! If you're happy with your wromo, run:"
echo
echo "    rm -rf .git"
echo "    git init"
echo "    git add ."
echo "    git commit -m 'Starting off $WROMONAME'"
echo "    ./bin/$WROMONAME init"
echo
echo "Made a mistake? Want to make a different wromo? Run:"
echo
echo "    git add ."
echo "    git checkout -f"
echo
echo "Thanks for making a wromo!"
