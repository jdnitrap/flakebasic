{ stdenvNoCC, lib, imagemagick }: 

# Frames live as base64 next to this file. Decoded and turned into PNG at build.
stdenvNoCC.mkDerivation {
  pname = "plymouth-theme-coffee";
  version = "1.0";
  src = ./coffee;

  nativeBuildInputs = [ imagemagick ];

  installPhase = ''
    mkdir -p $out/share/plymouth/themes/coffee
    cp coffee.plymouth coffee.script $out/share/plymouth/themes/coffee/

    for i in 1 2 3 4 5 6 7 8; do
      base64 -d frames/frame_$i.b64 > /tmp/frame_$i.jpg
      magick /tmp/frame_$i.jpg $out/share/plymouth/themes/coffee/frame_$i.png
    done

    # Point the theme at the store path NixOS expects.
    sed -i "s@/usr/share@$out/share@g" $out/share/plymouth/themes/coffee/coffee.plymouth
  '';

  meta = with lib; {
    description = "Coffee tech Plymouth splash";
    platforms = platforms.linux;
  };
}
