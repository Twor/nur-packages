{ stdenv
, fetchurl
, electron
, lib
, makeWrapper
} @ args:

stdenv.mkDerivation rec {
  pname = "xmcl-launcher";
  version = "0.32.8";
  src = fetchurl {
    url = "https://github.com/Voxelum/x-minecraft-launcher/releases/download/v${version}/xmcl-${version}.deb";
    sha256 = "sha256-InmxVwM3SWCG8Lf1Yz9rkMRCfj1cvP5Sgb0y/I8kCsE=";
  };
  # 解压 DEB 包
  unpackPhase = ''
    ar x ${src}
    tar xf data.tar.xz
  '';

  # makeWrapper 可以自动生成一个调用其它命令的命令（也就是 wrapper），并且可以在原命令上修改参数、环境变量等
  buildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin

    # 替换菜单项目(desktop 文件）中的路径
    cp -r usr/share $out/share
    sed -i "s|Exec=.*|Exec=$out/bin/xmcl|" $out/share/applications/*.desktop

    # 复制出客户端的 Javascript 部分，其它的不要了
    cp -r opt/X\ Minecraft\ Launcher/resources $out/opt

    # 生成 xmcl 命令，运行这个命令时会调用 electron 加载客户端的 Javascript 包（$out/opt/app.asar）
    makeWrapper ${electron}/bin/electron $out/bin/xmcl \
      --argv0 "xmcl" \
      --add-flags "$out/opt/app.asar"
  '';

}
