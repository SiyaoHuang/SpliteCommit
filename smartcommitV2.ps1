$repoPath = "E:\git\VRTest"
Set-Location -Path $repoPath

# 定义每个提交的大小限制（以字节为单位）
$maxSize = 50MB

# 初始化跟踪变量
$currentSize = 0
$filesToAdd = @()
$commitCount = 0
$maxCommits = 30

# 获取未提交和未跟踪的文件列表
$files = git status --porcelain | ForEach-Object { $_.Substring(3).Trim() }

foreach ($file in $files) {
    # 确保文件路径中的引号被移除
    $filePath = $file -replace '"', ''
    
    # 检查文件是否存在且是文件
    if (Test-Path $filePath -PathType Leaf) {
        $fileSize = (Get-Item $filePath).Length
        Write-Host "Processing file: $filePath ($fileSize bytes)"

        if (($currentSize + $fileSize) -gt $maxSize) {
            # 执行 Git 添加和提交
            if ($filesToAdd.Count -gt 0) {
                git add $filesToAdd
                git commit -m "Add files up to 50MB batch"
                $commitCount++

                # 检查提交次数
                if ($commitCount -ge $maxCommits) {
                    Write-Host "Reached maximum number of commits ($maxCommits). Stopping."
                    break
                }

                # 重置变量
                $filesToAdd = @()
                $currentSize = 0
            }
        }

        # 添加文件到当前批次
        $filesToAdd += $filePath
        $currentSize += $fileSize
    } elseif (Test-Path $filePath -PathType Container) {
        # 递归获取目录中的文件
        $subFiles = Get-ChildItem -Recurse -File $filePath | ForEach-Object { $_.FullName }

        foreach ($subFile in $subFiles) {
            $fileSize = (Get-Item $subFile).Length
            Write-Host "Processing file: $subFile ($fileSize bytes)"

            if (($currentSize + $fileSize) -gt $maxSize) {
                # 执行 Git 添加和提交
                if ($filesToAdd.Count -gt 0) {
                    git add $filesToAdd
                    git commit -m "Add files up to 50MB batch"
                    $commitCount++

                    # 检查提交次数
                    if ($commitCount -ge $maxCommits) {
                        Write-Host "Reached maximum number of commits ($maxCommits). Stopping."
                        break
                    }

                    # 重置变量
                    $filesToAdd = @()
                    $currentSize = 0
                }
            }

            # 添加文件到当前批次
            $filesToAdd += $subFile
            $currentSize += $fileSize
        }
    }
}

Write-Host "file to add $filesToAdd"
Write-Host "current size $currentSize"
# 提交剩余文件（如果未达到最大提交数）
if ($filesToAdd.Count -gt 0 -and $commitCount -lt $maxCommits) {
    git add $filesToAdd
    git commit -m "Add remaining files up to 50MB batch"
}

# git push
