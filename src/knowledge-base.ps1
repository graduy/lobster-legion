# Lobster Legion - Knowledge Base Manager
# 管理每个总龙虾的独立知识库（支持引用管理）

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

# ==================== 引用管理功能 ====================

function Get-ReferencesPath {
    param([string]$ChiefId)
    
    $path = Get-KnowledgePath -ChiefId $ChiefId
    $refPath = Join-Path $path "references"
    
    if (!(Test-Path $refPath)) {
        New-Item -ItemType Directory -Path $refPath | Out-Null
        Write-Host "  Created references directory: $refPath" -ForegroundColor Green
    }
    
    return $refPath
}

function ConvertTo-BibTeXKey {
    param([string]$Title, [string]$Year)
    
    # 从标题生成 BibTeX key
    $key = $Title.ToLower() -replace '[^a-z0-9]', ''
    $key = $key.Substring(0, [Math]::Min(20, $key.Length))
    
    if ($Year) {
        return "$key$Year"
    }
    return $key
}

function ConvertTo-BibTeX {
    param(
        [hashtable]$Reference,
        [string]$Style = "ACL"
    )
    
    $entryType = $Reference.entryType ?? "misc"
    $citeKey = $Reference.citeKey ?? (ConvertTo-BibTeXKey -Title $Reference.title -Year $Reference.year)
    
    $bibtex = "@$entryType{$citeKey,`n"
    
    if ($Reference.title) { $bibtex += "  title = {$($Reference.title)},`n" }
    if ($Reference.author) { $bibtex += "  author = {$($Reference.author)},`n" }
    if ($Reference.year) { $bibtex += "  year = {$($Reference.year)},`n" }
    if ($Reference.booktitle) { $bibtex += "  booktitle = {$($Reference.booktitle)},`n" }
    if ($Reference.journal) { $bibtex += "  journal = {$($Reference.journal)},`n" }
    if ($Reference.volume) { $bibtex += "  volume = {$($Reference.volume)},`n" }
    if ($Reference.pages) { $bibtex += "  pages = {$($Reference.pages)},`n" }
    if ($Reference.publisher) { $bibtex += "  publisher = {$($Reference.publisher)},`n" }
    if ($Reference.url) { $bibtex += "  url = {$($Reference.url)},`n" }
    if ($Reference.doi) { $bibtex += "  doi = {$($Reference.doi)},`n" }
    if ($Reference.note) { $bibtex += "  note = {$($Reference.note)},`n" }
    
    $bibtex += "}"
    
    return $bibtex
}

function Format-Citation {
    param(
        [hashtable]$Reference,
        [string]$Style = "ACL"
    )
    
    switch ($Style) {
        "ACL" {
            # ACL 风格：(Author et al., Year)
            $authors = $Reference.author -split ' and ' | Select-Object -First 1
            $authors = $authors -replace ',.*', ''
            if (($Reference.author -split ' and ').Count -gt 2) {
                return "($authors et al., $($Reference.year))"
            } elseif (($Reference.author -split ' and ').Count -eq 2) {
                $author2 = ($Reference.author -split ' and ')[1] -replace ',.*', ''
                return "($authors and $author2, $($Reference.year))"
            } else {
                return "($authors, $($Reference.year))"
            }
        }
        "APA" {
            # APA 风格：(Author, Year)
            $authors = $Reference.author -split ' and ' | Select-Object -First 1
            $authors = $authors -replace ',.*', ''
            if (($Reference.author -split ' and ').Count -gt 2) {
                return "($authors et al., $($Reference.year))"
            } else {
                return "($authors, $($Reference.year))"
            }
        }
        "IEEE" {
            # IEEE 风格：[Number]
            return "[$($Reference.number ?? 1)]"
        }
        default {
            return "($($Reference.author), $($Reference.year))"
        }
    }
}

function Save-Reference {
    param(
        [string]$ChiefId,
        [hashtable]$Reference,
        [string]$Style = "ACL"
    )
    
    $path = Get-ReferencesPath -ChiefId $ChiefId
    
    # 自动生成 BibTeX key
    if (!$Reference.citeKey) {
        $Reference.citeKey = ConvertTo-BibTeXKey -Title $Reference.title -Year $Reference.year
    }
    
    # 检查重复
    $bibFile = Join-Path $path "references.bib"
    if (Test-Path $bibFile) {
        $existing = Get-Content $bibFile -Raw
        if ($existing -match "@\w+\{$($Reference.citeKey),") {
            Write-Host "  Warning: Duplicate citation key '$($Reference.citeKey)'" -ForegroundColor Yellow
            return $null
        }
    }
    
    # 转换为 BibTeX 格式
    $bibtex = ConvertTo-BibTeX -Reference $Reference -Style $Style
    
    # 追加到 Bib 文件
    $bibtex | Out-File -FilePath $bibFile -Encoding UTF8 -Append
    Write-Host "  Saved reference: $($Reference.citeKey)" -ForegroundColor Green
    
    return $Reference.citeKey
}

function Get-References {
    param(
        [string]$ChiefId,
        [string]$Query = "",
        [int]$Limit = 10
    )
    
    $path = Get-ReferencesPath -ChiefId $ChiefId
    $bibFile = Join-Path $path "references.bib"
    
    if (!(Test-Path $bibFile)) {
        Write-Host "  No references found" -ForegroundColor Yellow
        return @()
    }
    
    $content = Get-Content $bibFile -Raw
    Write-Host "  Found references file ($($content.Length) bytes)" -ForegroundColor Green
    
    # 解析 BibTeX 条目
    $references = @()
    $matches = [regex]::Matches($content, '@(\w+)\{([^,]+),([\s\S]*?)\}')
    
    foreach ($match in $matches | Select-Object -First $Limit) {
        $entryType = $match.Groups[1].Value
        $citeKey = $match.Groups[2].Value.Trim()
        $fields = $match.Groups[3].Value
        
        $ref = @{
            entryType = $entryType
            citeKey = $citeKey
            raw = $fields
        }
        
        # 提取常见字段
        if ($fields -match 'title\s*=\s*\{([^\}]+)\}') { $ref.title = $matches.Groups[1].Value }
        if ($fields -match 'author\s*=\s*\{([^\}]+)\}') { $ref.author = $matches.Groups[1].Value }
        if ($fields -match 'year\s*=\s*\{([^\}]+)\}') { $ref.year = $matches.Groups[1].Value }
        
        $references += $ref
    }
    
    Write-Host "  Parsed $($references.Count) references" -ForegroundColor Green
    return $references
}

function Export-References {
    param(
        [string]$ChiefId,
        [string]$Style = "ACL",
        [string]$OutputPath = ""
    )
    
    $path = Get-ReferencesPath -ChiefId $ChiefId
    $bibFile = Join-Path $path "references.bib"
    
    if (!(Test-Path $bibFile)) {
        Write-Host "  No references to export" -ForegroundColor Yellow
        return
    }
    
    if (!$OutputPath) {
        $OutputPath = Join-Path $path "references_$Style.bib"
    }
    
    Copy-Item $bibFile -Destination $OutputPath
    Write-Host "  Exported references to: $OutputPath" -ForegroundColor Green
    
    return $OutputPath
}

# ==================== 保存知识 ====================

function Save-Knowledge {
    param(
        [string]$ChiefId,
        [string]$Content,
        [string]$Category = "general"
    )
    
    # 检测是否为引用保存
    if ($ChiefId -eq "chief-paper" -and $Content -match "^\s*@(?:inproceedings|article|book|misc)\{") {
        # BibTeX 格式，保存到引用库
        $bibPath = Get-ReferencesPath -ChiefId $ChiefId
        $bibFile = Join-Path $bibPath "references.bib"
        $Content | Out-File -FilePath $bibFile -Encoding UTF8 -Append
        Write-Host "  Saved BibTeX reference to: $bibFile" -ForegroundColor Green
        return $bibFile
    }
    
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
    Write-Host "  Total knowledge files: $($files.Count)" -ForegroundColor Yellow
    
    foreach ($file in $files) {
        $relativePath = $file.FullName.Replace($path, "").TrimStart("\")
        Write-Host "    - $relativePath ($($file.Length) bytes)" -ForegroundColor Gray
    }
    
    # 显示引用库信息
    if ($ChiefId -eq "chief-paper") {
        $refPath = Get-ReferencesPath -ChiefId $ChiefId
        $bibFile = Join-Path $refPath "references.bib"
        
        if (Test-Path $bibFile) {
            $content = Get-Content $bibFile -Raw
            $count = ([regex]::Matches($content, '@\w+\{')).Count
            Write-Host "`n📚 References: $count entries" -ForegroundColor Cyan
            Write-Host "  Path: $bibFile" -ForegroundColor Gray
        }
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
        "save-ref" {
            # 保存引用（JSON 格式）
            try {
                $ref = $Content | ConvertFrom-Json
                Save-Reference -ChiefId $ChiefId -Reference $ref
            } catch {
                Write-Host "  Error: Invalid JSON format" -ForegroundColor Red
            }
        }
        "get" {
            Get-Knowledge -ChiefId $ChiefId -Query $Content
        }
        "get-refs" {
            Get-References -ChiefId $ChiefId -Query $Content
        }
        "list" {
            List-Knowledge -ChiefId $ChiefId
        }
        "export-refs" {
            Export-References -ChiefId $ChiefId -Style $Content
        }
        "format-citation" {
            try {
                $ref = $Content | ConvertFrom-Json
                Format-Citation -Reference $ref -Style "ACL"
            } catch {
                Write-Host "  Error: Invalid JSON format" -ForegroundColor Red
            }
        }
        default {
            Write-Host "  Unknown action: $Action" -ForegroundColor Red
            Write-Host "  Available actions: save, save-ref, get, get-refs, list, export-refs, format-citation" -ForegroundColor Yellow
        }
    }
}

# ==================== 导出函数 ====================

Export-ModuleMember -Function Invoke-KnowledgeBase, Save-Knowledge, Get-Knowledge, List-Knowledge

# ==================== 命令行入口 ====================

if ($MyInvocation.InvocationName -eq $MyInvocation.ScriptName) {
    # Test - Knowledge Base
    Write-Host "`n=== Testing Knowledge Base ===" -ForegroundColor Cyan
    Invoke-KnowledgeBase -ChiefId "chief-code" -Action "save" -Content "# Test Knowledge`n`nThis is a test knowledge base entry."
    Invoke-KnowledgeBase -ChiefId "chief-code" -Action "list"
    
    # Test - Citation Management
    Write-Host "`n=== Testing Citation Management ===" -ForegroundColor Cyan
    $testRef = @{
        entryType = "inproceedings"
        title = "Attention Is All You Need"
        author = "Vaswani, Ashish and Shazeer, Noam and Parmar, Niki"
        year = "2017"
        booktitle = "NeurIPS"
    } | ConvertTo-Json
    
    Invoke-KnowledgeBase -ChiefId "chief-paper" -Action "save-ref" -Content $testRef
    Invoke-KnowledgeBase -ChiefId "chief-paper" -Action "get-refs"
    Invoke-KnowledgeBase -ChiefId "chief-paper" -Action "list"
}
