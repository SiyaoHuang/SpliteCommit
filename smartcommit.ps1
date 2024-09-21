# 设置工作目录和Git仓库信息
$repoPath = "E:\git\VRTest>"
$maxFileSize = 50MB

# 进入Git仓库目录
Set-Location -Path $repoPath

# 获取所有文件
$files = Get-ChildItem -Path $repoPath -Recurse | Where-Object { -not $_.PSIsContainer }

# 初始化
$currentCommitMessage = "Adding files"
$currentFileSize = 0
$currentFiles = @()

foreach ($file in $files) {
    $fileSize = $file.Length

    if (($currentFileSize + $fileSize) -gt $maxFileSize) {
        # 提交当前文件组
        git add $currentFiles
        git commit -m "$currentCommitMessage $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

        # 重置当前文件组
        $currentFiles = @()
        $currentFileSize = 0
    }

    # 添加文件到当前组
    $currentFiles += $file.FullName
    $currentFileSize += $fileSize
}

# 提交剩余的文件
if ($currentFiles.Count -gt 0) {
    git add $currentFiles
    git commit -m "$currentCommitMessage $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}

Write-Host "Finished committing files in batches."