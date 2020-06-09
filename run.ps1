Start-Job { & 'C:\Program Files\IIS Express\iisexpress.exe' '/path:c:\app' '/port:8000' '/systray:false' }

& 'C:\ServiceMonitor.exe' 'w3svc'