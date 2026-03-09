# Lobster Legion - Knowledge Base Manager
# 管理每个总龙虾的独立知识库

param(
    [string]$ChiefId,
    [string]$Action,
    [string]$Content,
    [string]$ConfigPath = ".\config.yml"
)

Write-Host "`n📚 [Knowledge Base] Chief: $ChiefId, Action: $Action" -ForegroundColor Cyan

# ==================== 知识库路径解析 ====================

function Get-KnowledgePath {
    param(
        [string]$ChiefId,
        [string]$ConfigPath
    )
    
    # 默认本地知识库路径
    $basePath = ".\knowledge-base"
    
    if (!(Test-Path $basePath)) {
        New-Item -ItemType Directory -Path $basePath | Out-Null
        Write-Host "  Created knowledge base directory: $basePath" -ForegroundColor Green
    }
    
    $chiefPath = Join-Path $basePath $ChiefId
    if (!(Test-Path $chiefPath)) {
        New-Item -ItemType Directory -Path $chiefPath | Out-Null
        Write-Host "  Created chief directory: $chiefPath" -ForegroundColor Green
    }
    
    return $chiefPath
}

# ==================== 保存知识 ====================

function Save-Knowledge {
    param(
        [string]$ChiefId,
        [string]$Content,
        [string]$Category = "general"
    )
    
    $path = Get-KnowledgePath -ChiefId $ChiefId
    
    $categoryPath = Join-Path $path $Category
    if (!(Test-Path $categoryPath)) {
        New-Item -ItemType Directory -Path $categoryPath | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $fileName = "knowledge_$timestamp.md"
    $filePath = Join-Path $categoryPath $fileName
    
    $content | Out-File -FilePath $filePath -Encoding UTF8
    Write-Host "  Saved knowledge to: $filePath" -ForegroundColor Green
    
    return $filePath
}

# ==================== 读取知识 ====================

function Get-Knowledge {
    param(
        [string]$ChiefId,
        [string]$Query,
        [int]$Limit = 5
    )
    
    $path = Get-KnowledgePath -ChiefId $ChiefId
    
    Write-Host "  Searching knowledge for: $Query" -ForegroundColor Yellow
    
    $files = Get-ChildItem -Path $path -Filter "*.md" -Recurse | Select-Object -First $Limit
    
    $results = @()
    foreach ($file in $files) {
        $content = Get-Content $file.FullName -Raw
        $results += @{
            file = $file.FullName
            content = $content
            preview = $content.Substring(0, [Math]::Min(200, $content.Length))
        }
    }
    
    Write-Host "  Found $($results.Count) knowledge files" -ForegroundColor Green
    return $results
}

# ==================== 列出知识 ====================

function List-Knowledge {
    param([string]$ChiefId)
    
    $path = Get-KnowledgePath -ChiefId $ChiefId
    
    Write-Host "`n📋 Knowledge Base for $ChiefId:" -ForegroundColor Cyan
    Write-Host "  Path: $path" -ForegroundColor Gray
    
    $files = Get-ChildItem -Path $path -Filter "*.md" -Recurse
    Write-Host "  Total files: $($files.Count)" -ForegroundColor Yellow
    
    foreach ($file in $files) {
        $relativePath = $file.FullName.Replace($path, "").TrimStart("\")
        Write-Host "    - $relativePath ($($file.Length) bytes)" -ForegroundColor Gray
    }
}

# ==================== 主函数 ====================

function Invoke-KnowledgeBase {
    param(
        [string]$ChiefId,
        [string]$Action,
        [string]$Content = "",
        [string]$ConfigPath = ".\config.yml"
    )
    
    switch ($Action.ToLower()) {
        "save" {
            Save-Knowledge -ChiefId $ChiefId -Content $Content
        }
        "get" {
            Get-Knowledge -ChiefId $ChiefId -Query $Content
        }
        "list" {
            List-Knowledge -ChiefId $ChiefId
        }
        default {
            Write-Host "  Unknown action: $Action" -ForegroundColor Red
            Write-Host "  Available actions: save, get, list" -ForegroundColor Yellow
        }
    }
}

# ==================== 导出函数 ====================

Export-ModuleMember -Function Invoke-KnowledgeBase, Save-Knowledge, Get-Knowledge, List-Knowledge

# ==================== 命令行入口 ====================

if ($MyInvocation.InvocationName -eq $MyInvocation.ScriptName) {
    # Test
    Invoke-KnowledgeBase -ChiefId "chief-code" -Action "save" -Content "# Test Knowledge`n`nThis is a test knowledge base entry."
    Invoke-KnowledgeBase -ChiefId "chief-code" -Action "list"
}
