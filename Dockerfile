FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8 AS runtime

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
RUN choco install iisexpress -y
RUN choco install urlrewrite -y
RUN choco install iis-arr -y

RUN & 'C:\\Windows\\System32\\inetsrv\\appcmd.exe' set config  -section:system.webServer/proxy '/enabled:"True"'  /commit:apphost
RUN & 'C:\\Windows\\System32\\inetsrv\\appcmd.exe' set config  -section:webFarms '/+"[name=''myServerFarm'']"' /commit:apphost
RUN & 'C:\\Windows\\System32\\inetsrv\\appcmd.exe' set config  -section:webFarms '/+"[name=''myServerFarm''].[address=''localhost'']"' /commit:apphost
RUN & 'C:\\Windows\\System32\\inetsrv\\appcmd.exe' set config  -section:webFarms '/[name=''myServerFarm''].applicationRequestRouting.protocol.timeout:"00:10:00"' /commit:apphost
RUN & 'C:\\Windows\\System32\\inetsrv\\appcmd.exe' set config  -section:system.webServer/rewrite/globalRules '/+"[name=''ARR_myServerFarm_loadbalance'', patternSyntax=''Wildcard'',stopProcessing=''True'']"' /commit:apphost
RUN & 'C:\\Windows\\System32\\inetsrv\\appcmd.exe' set config  -section:system.webServer/rewrite/globalRules '/[name=''ARR_myServerFarm_loadbalance'',patternSyntax=''Wildcard'',stopProcessing=''True''].match.url:"*"' /commit:apphost
RUN & 'C:\\Windows\\System32\\inetsrv\\appcmd.exe' set config  -section:system.webServer/rewrite/globalRules '/[name=''ARR_myServerFarm_loadbalance'',patternSyntax=''Wildcard'',stopProcessing=''True''].action.type:"Rewrite"' '/[name=''ARR_myServerFarm_loadbalance'',patternSyntax=''Wildcard'',stopProcessing=''True''].action.url:"http://localhost:8000/{R:0}"' /commit:apphost
RUN & 'C:\\Windows\\System32\\inetsrv\\appcmd.exe' set config  -section:system.webServer/rewrite/globalRules '/+"[name=''ARR_myServerFarm_loadbalance'',patternSyntax=''Wildcard'',stopProcessing=''True''].serverVariables.[name=''HTTP_ACCEPT_ENCODING'',value='''']"' /commit:apphost
RUN & 'C:\\Windows\\System32\\inetsrv\\appcmd.exe' set config  -section:system.webServer/rewrite/allowedServerVariables '/+"[name=''HTTP_ACCEPT_ENCODING'']"' /commit:apphost

RUN mkdir /app
COPY /app /app

COPY run.ps1 /run.ps1
ENTRYPOINT ["powershell", "/run.ps1"]