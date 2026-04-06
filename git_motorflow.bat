@echo off
setlocal

title MotorFlow - Git Sync
color 0A

cd /d C:\src\projects\motorflow

echo ==========================================
echo              MOTORFLOW GIT
echo ==========================================
echo.

git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo [ERRO] A pasta nao e um repositorio Git.
    pause
    exit /b 1
)

set /p msg=Digite a mensagem do commit: 

if "%msg%"=="" (
    echo.
    echo [ERRO] A mensagem nao pode ficar vazia.
    pause
    exit /b 1
)

echo.
echo [1/4] Adicionando arquivos...
git add .

echo.
echo [2/4] Criando commit...
git commit -m "%msg%"
if errorlevel 1 (
    echo.
    echo [AVISO] Nenhum commit foi criado. Talvez nao haja alteracoes.
    pause
    exit /b 1
)

echo.
echo [3/4] Enviando para o GitHub...
git push origin main
if errorlevel 1 (
    echo.
    echo [ERRO] Falha ao enviar para o GitHub.
    pause
    exit /b 1
)

echo.
echo [4/4] Processo concluido com sucesso.
pause
endlocal