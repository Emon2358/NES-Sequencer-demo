#!/usr/bin/env bash
set -euo pipefail
mkdir -p outputs
TOOLS_BIN="$PWD/tools/bin"
export PATH="$TOOLS_BIN:$PATH"

# check FamiStudio
if ! command -v FamiStudio >/dev/null 2>&1; then
  echo "FamiStudio not found in tools/bin. Aborting."
  exit 1
fi

# iterate inputs
for MID in input/songs/*.mid; do
  [ -e "$MID" ] || continue
  BASENAME=$(basename "$MID" .mid)
  echo "Processing $MID -> $BASENAME"

  # 1) Import MIDI into a temporary FamiStudio project, then export:
  #    - NES ROM (.nes)
  #    - NSF (.nsf)
  #    - famitone2 ASM (.s) for manual assembly
  PROJ="tmp_${BASENAME}.fms"
  ./tools/bin/FamiStudio "$MID" import "$PROJ" || true

  # export ROM (iNES)
  ./tools/bin/FamiStudio "$PROJ" nes-export "outputs/${BASENAME}.nes" -export-songs:0 || \
    echo "nes-export may have issues for this song; continuing"

  # export NSF
  ./tools/bin/FamiStudio "$PROJ" nsf-export "outputs/${BASENAME}.nsf" -export-songs:0 || true

  # export WAV for quick QA
  ./tools/bin/FamiStudio "$PROJ" wav-export "outputs/${BASENAME}.wav" -export-songs:0 -wav-export-rate:44100 || true

  # export FamiTone2 assembler (CA65 format)
  ./tools/bin/FamiStudio "$PROJ" famitone2-export "outputs/${BASENAME}.s" -famitone2-format:ca65 || true

  # Optionally: assemble famitone2 .s into a ROM using cc65/ca65/ld65
  # We supply a minimal template linker.cfg and driver.s in nes/
  if [ -f "outputs/${BASENAME}.s" ]; then
    mkdir -p tmpbuild
    cp outputs/${BASENAME}.s tmpbuild/music.s
    cp nes/linker.cfg tmpbuild/linker.cfg
    cp nes/driver.s tmpbuild/driver.s
    pushd tmpbuild >/dev/null
    # assemble music + driver
    ca65 -o music.o music.s
    ca65 -o driver.o driver.s
    ld65 -C linker.cfg -o "../outputs/${BASENAME}-built.nes" driver.o music.o || echo "ld65 failed (linking)."
    popd >/dev/null
  fi

done

echo "Build finished. Artifacts are in outputs/."
