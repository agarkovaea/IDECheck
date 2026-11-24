# Проверяем наличие среды разработки, установленного языка и GIT, 
# если всё ок - открываем VSCode
$components = @("python", "git", "code")
$missingComponents = @()

foreach ($component in $components) {
    if (Get-Command $component -ErrorAction SilentlyContinue) {
        $version = & $component --version | Select-Object -First 1
        Write-Host "[OK] $component : $version" -ForegroundColor Green
    }
    else {
        $missingComponents += $component
        Write-Host "[MISSING] $component" -ForegroundColor Red
    }
}

if ($missingComponents.Count -eq 0) {
    Write-Host "Все компоненты установлены!" -ForegroundColor Green
    $projectRequest = Read-Host "Создать проект? (y/n)"

    if ($projectRequest -ne "y") {
        exit
    }

    do {
        $projectName = Read-Host "Введите название проекта"

        if ($projectName -match '[\\/:*?"<>|]') {
            Write-Host "Название содержит недопустимые символы!" -ForegroundColor Red
        }
    }
    while ($projectName -match '[\\/:*?"<>|]')

    $projectsRoot = Split-Path -Parent $PSScriptRoot
    $projectPath = Join-Path $projectsRoot $projectName

    if (Test-Path -LiteralPath $projectPath) {
        $answer = Read-Host "Проект с таким названием уже существует! Открыть существующий проект? (y/n)"

        if ($answer -eq "y") {
            code $projectPath
        }
        elseif ($answer -eq "n") {
            exit
        }
        else {
            Write-Host "Некорректное значение ввода" -ForegroundColor Red
            exit
        }
    }
    else {
        Write-Host "Выберите формат файла:"
        Write-Host "[1] Python (.py)"
        Write-Host "[2] PowerShell (.ps1)"
        Write-Host "[3] Bash (.sh)"
        Write-Host "[4] Batch (.bat)"
        Write-Host "[5] YAML (.yaml)"
        Write-Host "[6] JSON (.json)"
        Write-Host "[7] Terraform (.tf)"
        Write-Host "[0] Только каталог"

        do {
            $fileType = Read-Host "Ваш выбор"

            if ($fileType -notin @("0", "1", "2", "3", "4", "5", "6", "7")) {
                Write-Host "Некорректный выбор" -ForegroundColor Red
            }
        }
        while ($fileType -notin @("0", "1", "2", "3", "4", "5", "6", "7"))

        switch ($fileType) {
            "1" { $fileExtension = "py" }
            "2" { $fileExtension = "ps1" }
            "3" { $fileExtension = "sh" }
            "4" { $fileExtension = "bat" }
            "5" { $fileExtension = "yaml" }
            "6" { $fileExtension = "json" }
            "7" { $fileExtension = "tf" }
            "0" { $fileExtension = "" }
        }

        Write-Host "Создаём новый проект"

        New-Item -Path $projectPath -ItemType Directory -ErrorAction Stop

        if ($fileType -ne "0") {
            $fileName = "$projectName.$fileExtension"
            $filePath = Join-Path $projectPath $fileName
            New-Item -Path $filePath -ItemType File -ErrorAction Stop

            Write-Host "Проект успешно создан!" -ForegroundColor Green

            code $projectPath
        }
        else {
            Write-Host "Каталог успешно создан!" -ForegroundColor Green
        }
    }
}
else {
    Write-Host "Для продолжения работы установите недостающие компоненты:
    $($missingComponents -join ', ')" -ForegroundColor Red
}
