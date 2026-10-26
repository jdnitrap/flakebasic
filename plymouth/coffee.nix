{ stdenvNoCC, lib, imagemagick }: 

stdenvNoCC.mkDerivation {
  pname = "plymouth-theme-coffee";
  version = "1.0";
  src = ./coffee;

  nativeBuildInputs = [ imagemagick ];

  installPhase = ''
    mkdir -p $out/share/plymouth/themes/coffee
    cp coffee.plymouth coffee.script $out/share/plymouth/themes/coffee/

    base64 -d frame.b64 > /tmp/frame.jpg
    magick /tmp/frame.jpg $out/share/plymouth/themes/coffee/frame.png

    sed -i "s@/usr/share@$out/share@g" $out/share/plymouth/themes/coffee/coffee.plymouth
  '';

  meta = with lib; {
    description = "Coffee tech Plymouth splash";
    platforms = platforms.linux;
  };
}
