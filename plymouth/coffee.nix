{ stdenvNoCC, lib }: 

stdenvNoCC.mkDerivation {
  pname = "plymouth-theme-coffee";
  version = "1.0";
  src = ./coffee;

  installPhase = ''
    mkdir -p $out/share/plymouth/themes/coffee
    cp coffee.plymouth coffee.script $out/share/plymouth/themes/coffee/

    for i in 1 2 3 4 5 6 7 8; do
      base64 -d frames/frame_$i.b64 > $out/share/plymouth/themes/coffee/frame_$i.png
    done

    sed -i "s@/usr/share@$out/share@g" $out/share/plymouth/themes/coffee/coffee.plymouth
  '';

  meta = with lib; {
    description = "Spinning circle Plymouth splash";
    platforms = platforms.linux;
  };
}
