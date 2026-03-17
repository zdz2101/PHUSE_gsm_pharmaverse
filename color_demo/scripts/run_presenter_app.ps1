param(
  [int]$Port = 3839
)

$env:COLOR_DEMO_PRESENTER_PORT = $Port
$rscript = 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe'
Set-Location 'C:\Users\zhuze\OneDrive - ATorus\Documents\PHUSE_gsm_pharmaverse'
& $rscript 'C:\Users\zhuze\OneDrive - ATorus\Documents\PHUSE_gsm_pharmaverse\color_demo\scripts\run_presenter_app.R'
