REM Usage : auto.bat [fileName] [interpolate] [encoder] [preset] [crf or qp when merging]

@echo off
chcp 65001
setlocal enabledelayedexpansion
set dt=%DATE:~6,4%_%DATE:~3,2%_%DATE:~0,2%__%TIME:~0,2%_%TIME:~3,2%_%TIME:~6,2%
set current_date=%dt: =0%
mkdir %current_date%_splitted_video
ffprobe -v error -select_streams v -of default=noprint_wrappers=1:nokey=1 -show_entries stream=r_frame_rate %1 > fps.txt
for /f "usebackq delims=" %%A in ("fps.txt") do (
    set fr=%%A
    goto :DONE
)
:DONE
for /f "tokens=*" %%A in ('powershell -command "( !fr!*%2 )"') do set tf=%%A
del "fps.txt"
if %2==1 (
    SET /a isInterpolate=0
) else (
    SET /a isInterpolate=1
)
scenedetect -i %1 detect-adaptive -m 1.5 split-video -a "-an -vcodec hevc_nvenc -qp 5 -preset slow" -o %current_date%_splitted_video
echo.
echo Extracting Audio ...
ffmpeg -i %1 -vn -acodec libopus -b:a 96k "%current_date%_splitted_video/%~n1.opus" 2> NUL
echo Done
cd ./%current_date%_splitted_video
SET enc=%3
SET pre=%4
SET /a filecounter=0
SET /a currentfilenum=0
mkdir "input_frames" && mkdir "output_frames"
for %%f in (*.mp4) do (
    SET /a filecounter+=1
)
for %%f in (*.mp4) do (
    SET /a currentfilenum+=1
    echo.
    if %isInterpolate%==1 (
        echo Interpolating Frames: %%f -- !currentfilenum! / !filecounter!
        ffmpeg -i "%%f" -r !fr! -q 0 ./input_frames/%%08d.jpg 2> NUL
        cd input_frames
        SET count=0
        for %%f in (*.jpg) do (
            SET /a count+=1
        )
        SET /a count*=%2
        cd ..
        rife-ncnn-vulkan -i input_frames/ -n !count! -m rife-v4.18 -o output_frames/ 2> NUL
        ffmpeg -r %tf% -i output_frames/%%08d.png -vcodec hevc_nvenc -preset slow -qp %5 -pix_fmt yuv420p10le "%%~nf_new.mp4" 2> NUL
    ) else (
        echo Invalid Interpolation Parameter
	pause
	Exit /b
    )
    del "%%f"
    for /d %%d in ("*") do ( rd /s /q "%%d"	)
    mkdir input_frames && mkdir output_frames
    echo Done
)
for %%f in ( *_new.mkv ) do (
    echo file '%%f' >> list.txt
)
echo Concatenating
ffmpeg -safe 0 -f concat -i list.txt -c copy concat.mp4 2> NUL
cd ..
ffmpeg -i "%current_date%_splitted_video/concat.mp4" -i "%current_date%_splitted_video/%~n1.opus" -c copy "%~n1_final.mp4" 2> NUL
rd /s /q "%current_date%_splitted_video"
echo Finished