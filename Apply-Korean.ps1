param([string]$ModDirectory = '')
$ErrorActionPreference = 'Stop'
try {
    if ([string]::IsNullOrWhiteSpace($ModDirectory)) {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.Application]::EnableVisualStyles()
        $dialog = [System.Windows.Forms.OpenFileDialog]::new()
        $dialog.Title = '한글 패치를 적용할 AllialShopkeeper.pck 파일을 선택하세요'
        $dialog.Filter = 'AllialShopkeeper.pck|AllialShopkeeper.pck'
        $dialog.FileName = 'AllialShopkeeper.pck'
        $dialog.CheckFileExists = $true
        $dialog.CheckPathExists = $true
        $dialog.Multiselect = $false
        $dialog.RestoreDirectory = $true
        $dialog.InitialDirectory = $PSScriptRoot
        try {
            if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
                Write-Host '취소했습니다. 파일을 변경하지 않았습니다.'
                exit 0
            }
            $ModDirectory = [System.IO.Path]::GetDirectoryName($dialog.FileName)
        } finally { $dialog.Dispose() }
    }
    $ModDirectory = (Resolve-Path -LiteralPath $ModDirectory).ProviderPath
    $sourcePath = Join-Path $ModDirectory 'AllialShopkeeper.pck'
    $originalHash = '830DA73509C0185092837DAA67E3404DF08713225F2AFF280C8A9DCFB73A01FD'
    $patchedHash = '746C71CBD85C3D20A1CDDD36050D1942548D3F38D30A4839A3DC7A4AB116BBAA'
    $previousPatchHash = '99F425B7983DE4FB33DA8E898C358E9DDD6C3511ACDA9176BDD045A3D93F5788'
    if (!(Test-Path -LiteralPath $sourcePath -PathType Leaf)) { throw "Mod file not found: $sourcePath" }
    $currentHash = (Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash
    if ($currentHash -eq $patchedHash) { Write-Host 'Korean patch is already installed.'; exit 0 }
    $inputPath = $sourcePath
    if ($currentHash -eq $previousPatchHash) {
        $inputPath = $sourcePath + '.original-backup'
        if (!(Test-Path -LiteralPath $inputPath -PathType Leaf)) { throw 'Original backup is required to update the previous patch.' }
        if ((Get-FileHash -LiteralPath $inputPath -Algorithm SHA256).Hash -ne $originalHash) { throw 'Original backup verification failed. No files have been changed.' }
    } elseif ($currentHash -ne $originalHash) { throw 'Unsupported mod version or modified PCK. No files have been changed.' }
    $inputBytes = [System.IO.File]::ReadAllBytes($inputPath)
    $reader = [System.IO.BinaryReader]::new([System.IO.MemoryStream]::new($inputBytes, $false))
    $reader.BaseStream.Position = 24
    $base = $reader.ReadUInt64()
    $directory = $reader.ReadUInt64()
    $reader.BaseStream.Position = $directory
    $count = $reader.ReadUInt32()
    $entries = @{}
    for ($i = 0; $i -lt $count; $i++) {
        $nameLength = $reader.ReadUInt32()
        $name = [System.Text.Encoding]::UTF8.GetString($reader.ReadBytes($nameLength)).TrimEnd([char]0)
        $entries[$name] = [pscustomobject]@{ Name=$name; Offset=$reader.ReadUInt64(); Size=$reader.ReadUInt64(); Hash=$reader.ReadBytes(16); Flags=$reader.ReadUInt32() }
    }
    $reader.Dispose()
    $stream = [System.IO.MemoryStream]::new()
    $writer = [System.IO.BinaryWriter]::new($stream)
    $writer.Write($inputBytes, 0, [int]$directory)
    $md5 = [System.Security.Cryptography.MD5]::Create()
    foreach ($table in @('events', 'merchant_room')) {
        $translation = [System.IO.File]::ReadAllBytes((Join-Path $PSScriptRoot ($table + '.json')))
        foreach ($language in @('zhs', 'kor')) {
            $pad = (16 - ($stream.Position % 16)) % 16
            $writer.Write([byte[]]::new($pad))
            $name = "AllialShopkeeper/localization/$language/$table.json"
            $entries[$name] = [pscustomobject]@{ Name=$name; Offset=($stream.Position-$base); Size=$translation.Length; Hash=$md5.ComputeHash($translation); Flags=0 }
            $writer.Write([byte[]]$translation)
        }
    }
    $md5.Dispose()
    $pad = (16 - ($stream.Position % 16)) % 16
    $writer.Write([byte[]]::new($pad))
    $newDirectory = $stream.Position
    $writer.Write([uint32]$entries.Count)
    [string[]]$names = @($entries.Keys)
    [System.Array]::Sort($names, [System.StringComparer]::Ordinal)
    foreach ($name in $names) {
        $e = $entries[$name]
        $nameBytes = [System.Text.Encoding]::UTF8.GetBytes($name + [char]0)
        $namePad = (4 - ($nameBytes.Length % 4)) % 4
        $writer.Write([uint32]($nameBytes.Length + $namePad))
        $writer.Write([byte[]]$nameBytes)
        $writer.Write([byte[]]::new($namePad))
        $writer.Write([uint64]$e.Offset)
        $writer.Write([uint64]$e.Size)
        $writer.Write([byte[]]$e.Hash)
        $writer.Write([uint32]$e.Flags)
    }
    $stream.Position = 32
    $writer.Write([uint64]$newDirectory)
    $outputBytes = $stream.ToArray()
    $writer.Dispose()
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $outputHash = [System.BitConverter]::ToString($sha.ComputeHash($outputBytes)).Replace('-', '')
    $sha.Dispose()
    if ($outputHash -ne $patchedHash) { throw 'Patch verification failed. No files have been changed.' }
    $backupPath = $sourcePath + '.original-backup'
    if (Test-Path -LiteralPath $backupPath) {
        if ((Get-FileHash -LiteralPath $backupPath -Algorithm SHA256).Hash -ne $originalHash) { throw 'A different backup already exists. No files have been changed.' }
    } else { Copy-Item -LiteralPath $sourcePath -Destination $backupPath }
    $temporaryPath = $sourcePath + '.korean-patch.tmp'
    [System.IO.File]::WriteAllBytes($temporaryPath, $outputBytes)
    Move-Item -LiteralPath $temporaryPath -Destination $sourcePath -Force
    Write-Host 'SUCCESS: 44 Korean dialogue lines installed.'
    Write-Host "Original backup: $backupPath"
    Write-Host 'Start the game with Korean selected.'
} catch {
    Write-Host ('ERROR: ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}

