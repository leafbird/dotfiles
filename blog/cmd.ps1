#��α� ��ΰ� ��ϵǾ� �ִ��� Ȯ��
$BLOG_PATH = $Env:BLOG_PATH

# ȯ�� ���� ���� ���� Ȯ��
if ($BLOG_PATH.Length -eq 0) {
    "can't find environment variable 'BLOG_PATH'."
    exit
} 

# ��� Ȯ��
"move to blog path : {0}" -f $BLOG_PATH

# ��� ����
cd $BLOG_PATH

# ���â ����
Start-Process "cmd" "/K git status"
