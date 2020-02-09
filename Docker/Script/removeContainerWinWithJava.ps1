$containerIds = @(docker container ls -a) | 
    Where-Object {$_ -like "*unixwithjava*"} | 
    Select-Object @{Name='ContId'; Expression={$_.SubString(0, 12)}} |
    Select-object -ExpandProperty ContId

foreach ($contId in $containerIds) {
    docker container stop $contId
    docker container rm $contId
}

#docker image rm winwithjava
