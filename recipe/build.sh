#!/bin/bash -euo

find . -maxdepth 1 \
       -type d \
       -not \( -name '.' -or -name 'fonts' -or -name 'demo' \) \
       -exec sh -c "mkdir $PREFIX/$(basename {}); mv $(basename {})/* $PREFIX/$(basename {})/" \;

if [ -f "DISCLAIMER" ]; then
    mv DISCLAIMER $INSTALL_DIR/DISCLAIMER
fi

if [[ "$target_platform" == linux* ]]; then
  # Include dejavu fonts to allow java to work even on minimal cloud
  # images where these fonts are missing (thanks to @chapmanb)
  mkdir -p $PREFIX/lib/fonts
  mv $SRC_DIR/fonts/ttf/* $PREFIX/lib/fonts/

  # Have libjvm.so show up in the right place
  ln -s $PREFIX/lib/server/libjvm.so $PREFIX/lib/libjvm.so
fi

find $PREFIX -name "*.debuginfo" -exec rm -rf {} \;

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
