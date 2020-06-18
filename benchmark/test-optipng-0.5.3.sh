python3 -m tclib download https://github.com/TianyiChen/PL-assets/releases/download/main/PngSuite.zip ../pngsuite.zip f9b919cbc2dbca6284941c50adbe23294e3d6fb1d005a06ef5686835c7d2de60
unzip ../pngsuite.zip
src/optipng *.png ||true
