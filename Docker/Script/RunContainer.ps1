<# check if oswithjava image exists, otherwise it is created. Then it will start a new container
    windows: ./RunContainer.ps1 -os win -Jenkins
#>

function Run-Container
{
    Param(
        [ValidateSet('win', 'unix')]
        [string]$os,
        [bool]$FlagCreateImage=$false,
        [string]$DockerfilePath=".",
        [string]$InterfaceName="vEthernet (ExternalVSwitch01)",
        [string]$JenkinsSecret,
        [string]$JenkinsWorkingDir,
        [int16]$JenkinsPort=8080,
        [string]$JenkinsNodeName,
        [string]$specialTag=""
    )

    switch ($os) { 
        'win' {
            $agentPath = 'C:\\agent.jar'
            $virtualSwitch = [regex]::Match($InterfaceName, "\w+ \((\w+)\)").captures.groups[1].value
            $ipaddr = (Get-NetIPAddress -InterfaceAlias $InterfaceName -AddressFamily "IPv4").IPAddress
            $runCommand = "docker run -d --network=$virtualSwitch --name $JenkinsNodeName ${os}withjava:{0} java -jar $agentPath -jnlpUrl http://${ipaddr}:$JenkinsPort/computer/$JenkinsNodeName/slave-agent.jnlp -secret $JenkinsSecret -workDir $JenkinsWorkingDir"
        }
        'unix' {
            $agentPath = '/agent.jar'
            $virtualSwitch = 'bridge'
            $ipaddr = 'host.docker.internal'
            $runCommand = "docker run -d --network=$virtualSwitch --name $JenkinsNodeName ${os}withjava:{0} -jnlpUrl http://${ipaddr}:$JenkinsPort/computer/$JenkinsNodeName/slave-agent.jnlp -secret $JenkinsSecret -workDir $JenkinsWorkingDir"
        }
    }

    if ($FlagCreateImage)
    {
        $containerIds = Get-Containers -Extended 0 | 
            where {$_.Image -like "*${os}withjava*"} | 
            select -ExpandProperty ContainerId

        foreach ($contId in $containerIds) 
        {
            docker container rm -f $contId
        }

        $lastImage = Get-Images |
            where {$_.Repository -eq "${os}withjava"} |
            sort -Property Tag -Descending |
            select -First 1

        try 
        {
            $newTag = (([int] $lastImage.Tag.Substring(0, 5)) + 1).ToString().PadLeft(5, '0')

            docker build -t ${os}withjava:$newTag$specialTag $DockerfilePath
        }
        catch
        {
            exit
        }
    }

    Invoke-Expression $($runCommand -f "$newTag$specialTag")
}

<# Windows
Run-Container -os "win" `
    -JenkinsNodeName "win00" -JenkinsSecret "f00007e71775c570a29ab5f920e113691a21ec1527813900118c25eef6204b27" `
    -JenkinsWorkingDir "C:\\Jenkins" -FlagCreateImage $true -DockerfilePath "D:\\Docker\\Slave_windows"
#>

# Unix
Run-Container -os "unix" `
    -JenkinsNodeName "unix00" -JenkinsSecret "d0bd7d99722192693c2517073520a1192f7a8c33636902560c1fccdb5bb99680" `
    -JenkinsWorkingDir "/home/jenkins" -FlagCreateImage $true -DockerfilePath "D:\\Docker\\Slave_linux" -specialTag "_NTLMconfigured"