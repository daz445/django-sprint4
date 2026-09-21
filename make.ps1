param(
    [Parameter(Position=0)]
    [string]$Command
)

$ErrorActionPreference = "Stop"
$venvPath = ".\venv\Scripts\Activate.ps1"
$env:PYTHONUNBUFFERED = "1"

function Invoke-InVenv {
    param([scriptblock]$ScriptBlock)
    & $venvPath
    & $ScriptBlock
}

function Install-Dependencies {
    Write-Host "Installing dependencies..." -ForegroundColor Green
    python -m venv venv
    & $venvPath
    python -m pip install --upgrade pip
    pip install -r requirements.txt
}

function Invoke-Tests {
    Write-Host "Running tests..." -ForegroundColor Green
    & $venvPath
    python -m pytest tests/ -v
}

function Invoke-Lint {
    Write-Host "Checking PEP8..." -ForegroundColor Green
    & $venvPath
    Set-Location blogicum
    python -m flake8 --max-line-length=79 --ignore=W503,F811,D100,D101,D102,D103,D104,D105,D106,D107,D203,D205,D213,D400,D401,N806,N818,E501 .
    Set-Location ..
}

function Start-Server {
    Write-Host "Starting server at http://127.0.0.1:8000/ ..." -ForegroundColor Green
    & $venvPath
    Set-Location blogicum
    $ErrorActionPreference = "Continue"
    python manage.py runserver 2>&1
    Set-Location ..
}

function Invoke-Migrate {
    Write-Host "Applying migrations..." -ForegroundColor Green
    & $venvPath
    Set-Location blogicum
    python manage.py migrate
    Set-Location ..
}

function New-Migrations {
    Write-Host "Creating migrations..." -ForegroundColor Green
    & $venvPath
    Set-Location blogicum
    python manage.py makemigrations
    Set-Location ..
}

function New-SuperUser {
    Write-Host "Creating superuser..." -ForegroundColor Green
    & $venvPath
    Set-Location blogicum
    python manage.py createsuperuser
    Set-Location ..
}

function Import-Fixtures {
    Write-Host "Loading fixtures..." -ForegroundColor Green
    & $venvPath
    Set-Location blogicum
    python manage.py loaddata ../db.json
    Set-Location ..
}

function Enter-Shell {
    Write-Host "Starting shell..." -ForegroundColor Green
    & $venvPath
    Set-Location blogicum
    python manage.py shell
    Set-Location ..
}

function Invoke-CollectStatic {
    Write-Host "Collecting static..." -ForegroundColor Green
    & $venvPath
    Set-Location blogicum
    python manage.py collectstatic --noinput
    Set-Location ..
}

function Setup-Project {
    Write-Host "Setting up project..." -ForegroundColor Green
    Install-Dependencies
    Invoke-Migrate
}

function Remove-Cache {
    Write-Host "Cleaning cache..." -ForegroundColor Green
    Get-ChildItem -Path . -Directory -Recurse -Filter "__pycache__" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path . -File -Recurse -Filter "*.pyc" | Remove-Item -Force -ErrorAction SilentlyContinue
}

switch ($Command) {
    "install"         { Install-Dependencies }
    "test"            { Invoke-Tests }
    "lint"            { Invoke-Lint }
    "run"             { Start-Server }
    "migrate"         { Invoke-Migrate }
    "makemigrations"  { New-Migrations }
    "createsuperuser" { New-SuperUser }
    "loaddata"        { Import-Fixtures }
    "shell"           { Enter-Shell }
    "collectstatic"   { Invoke-CollectStatic }
    "setup"           { Setup-Project }
    "clean"           { Remove-Cache }
    default {
        Write-Host "Usage: .\make.ps1 <command>" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Available commands:" -ForegroundColor Cyan
        Write-Host "  install         - Install dependencies (creates venv)"
        Write-Host "  test            - Run tests"
        Write-Host "  lint            - Check PEP8"
        Write-Host "  run             - Start dev server"
        Write-Host "  migrate         - Apply migrations"
        Write-Host "  makemigrations  - Create migrations"
        Write-Host "  createsuperuser - Create superuser"
        Write-Host "  loaddata        - Load fixtures from db.json"
        Write-Host "  shell           - Start Django shell"
        Write-Host "  collectstatic   - Collect static files"
        Write-Host "  setup           - Full setup (install + migrate)"
        Write-Host "  clean           - Clean Python cache"
    }
}
