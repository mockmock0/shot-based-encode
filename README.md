## 장면 기반 영상 인코딩 프로세스
영상을 장면별로 자른 후 각 장면의 퀄리티 측정 및 재인코딩 작업 수행 <br>


## 필수 라이브러리 
* [FFmpeg](https://www.gyan.dev/ffmpeg/builds/) (환경변수 설정 권장)
* [ab-av1](https://github.com/alexheretic/ab-av1) (환경변수 설정 권장)
* [pySceneDetect](https://www.scenedetect.com/download/) <br>


## 선택 라이브러리
* [RIFE-ncnn-vulkan](https://github.com/TNTwise/rife-ncnn-vulkan) (환경변수 설정 권장) <br>


## 사용법
1. .bat 파일을 동영상 경로로 이동
2. 동영상 경로의 탐색기 주소창에 cmd 입력
3. 아래 명령문을 실행한다.

shot-sw.bat <파일이름> <프레임 보간 배율> <인코더> <프리셋> <VMAF>

예시)
* shot-nvenc.bat "test.mxf" 2 "libsvtav1" 5 95
* shot-sw.bat "foo.mkv" 1 "libx264" fastest 93
* shot-nvenc.bat "ipsum.mp4" 1 "hevc_nvenc" slow 96 <br>
## 코드 설명
[노션 참고](https://www.notion.so/Shot-based-Encoding-a9c6c8c325a64f419093b4399c200de4)

## 유의사항
* 파일 이름과 인코더는 쌍따옴표로 감쌀 것
* RIFE-ncnn-vulkan은 v4.18을 사용하므로, 지원되는지 확인이 필요함
* 인코더와 프리셋 파라미터는 FFmpeg의 규칙에 따를 것
* VMAF 점수는 93~96을 권장함
* 프로세스를 거친 결과물은 VMAF 측정 불가능 <br>
  

## 일반 인코딩 결과물과 비교
[reference video](https://www.youtube.com/watch?v=tbWugSQ7kCk) <br>
하드웨어 : RTX 3060 8GB <br>
일반 인코딩 작업 대비 시간 약 3배 소요

|분류|작업 흐름|영상 포맷|예상 VMAF|용량|작업 시간|
|:---:|:---:|:---:|:---:|:---:|:---:|
|Original (30fps)| - | VP9 | 100 | 64.2MB | - |
|Whole-Encode (60fps)| FlowFrames(프레임 2배 보간)<br/>ab-av1 |HEVC (NVENC)| 95 | <span style="color:red">69.5MB</span> | <span style="color:blue">9분 35초</span> |
|Shot-Based-Encode (60fps)| pySceneDetection<br/>rife-ncnn-vulkan<br/>ab-av1 |HEVC (NVENC)| 95 | <span style="color:blue">37.3MB</span> | <span style="color:red">29분 32초</span> |
