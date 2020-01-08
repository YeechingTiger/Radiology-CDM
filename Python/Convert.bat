
for /r %%i in (*.dcm) do (
echo %%~nxi
	dcmdjpeg "%%i" "%%i"
	timeout /t 1
)