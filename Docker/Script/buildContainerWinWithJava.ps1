cd D:\Docker\Jenkins_windows

docker build -t winwithjava:latest .
docker run -it --network=ExternalVSwitch01 --name win00 winwithjava powershell