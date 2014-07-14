#블로그 경로가 등록되어 있는지 확인
$BLOG_PATH = $Env:BLOG_PATH

# 환경 변수 셋팅 여부 확인
if ($BLOG_PATH.Length -eq 0) {
    "can't find environment variable 'BLOG_PATH'."
    exit
} 

# 경로 확인
"move to blog path : {0}" -f $BLOG_PATH

# 경로 변경
cd $BLOG_PATH

# 명령창 실행
Start-Process "cmd" "/K git status"
