{ stdenvNoCC, lib, imagemagick }: 

stdenvNoCC.mkDerivation {
  pname = "plymouth-theme-coffee";
  version = "1.0";
  src = ./coffee;

  nativeBuildInputs = [ imagemagick ];

  installPhase = ''
    mkdir -p $out/share/plymouth/themes/coffee
    cp coffee.plymouth coffee.script $out/share/plymouth/themes/coffee/

    # Draw the spinning arc at build time. No frame files needed.
    for i in 0 1 2 3 4 5 6 7; do
      ang=$((i * 45))
      ang2=$((ang + 100))
      ang3=$((ang + 180))
      ang4=$((ang + 210))
      magick -size 256x256 xc:#0a0a0c \
        -stroke '#e3924a' -strokewidth 14 -fill none \
        -draw "arc 40,40 216,216 $ang,$ang2" \
        -stroke '#3dcc9a' \
        -draw "arc 40,40 216,216 $ang3,$ang4" \
        $out/share/plymouth/themes/coffee/frame_$((i + 1)).png
    done

    sed -i "s@/usr/share@$out/share@g" $out/share/plymouth/themes/coffee/coffee.plymouth
  '';

  meta = with lib; {
    description = "Spinning circle Plymouth splash";
    platforms = platforms.linux;
  };
}
