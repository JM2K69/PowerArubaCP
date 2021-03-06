#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Connect-ArubaCP {

    <#
      .SYNOPSIS
      Connect to an Aruba ClearPass

      .DESCRIPTION
      Connect to an Aruba ClearPass

      .EXAMPLE
      Connect-ArubaCP -Server 192.0.2.1 -token aaaaaaaaaaaaa

      Connect to an Aruba ClearPass with IP 192.0.2.1 using token aaaaaaa

      .EXAMPLE
      Connect-ArubaCP -Server 192.0.2.1 -token aaaaaaaaaaaaa -SkipCertificateCheck

      Connect to an Aruba ClearPass using HTTPS (without check certificate validation) with IP 192.0.2.1 using token aaaaaaa
  #>

    Param(
        [Parameter(Mandatory = $true, position = 1)]
        [String]$Server,
        [Parameter(Mandatory = $false)]
        [String]$token,
        [Parameter(Mandatory = $false)]
        [switch]$SkipCertificateCheck = $false
    )

    Begin {
    }

    Process {

        $connection = @{server = ""; token = ""; invokeParams = ""}
        $invokeParams = @{DisableKeepAlive = $false; UseBasicParsing = $true; SkipCertificateCheck = $SkipCertificateCheck}

        if ("Desktop" -eq $PSVersionTable.PsEdition) {
            #Remove -SkipCertificateCheck from Invoke Parameter (not supported <= PS 5)
            $invokeParams.remove("SkipCertificateCheck")
        } else { #Core Edition
            #Remove -UseBasicParsing (Enable by default with PowerShell 6/Core)
            $invokeParams.remove("UseBasicParsing")
        }

        #for PowerShell (<=) 5 (Desktop), Enable TLS 1.1, 1.2 and Disable SSL chain trust (needed/recommanded by ClearPass)
        if ("Desktop" -eq $PSVersionTable.PsEdition) {
            #Enable TLS 1.1 and 1.2
            Set-ArubaCPCipherSSL
            if ($SkipCertificateCheck) {
                #Disable SSL chain trust...
                Set-ArubaCPuntrustedSSL
            }
        }

        $connection.server = $server
        $connection.token = $token
        $connection.invokeParams = $invokeParams

        set-variable -name DefaultArubaCPConnection -value $connection -scope Global

    }

    End {
    }
}

function Disconnect-ArubaCP {

    <#
        .SYNOPSIS
        Disconnect to a ArubaCP Switches

        .DESCRIPTION
        Disconnect the connection on Aruba ClearPass

        .EXAMPLE
        Disconnect-ArubaCP

        Disconnect the connection

        .EXAMPLE
        Disconnect-ArubaCP -noconfirm

        Disconnect the connection with no confirmation

    #>

    Param(
        [Parameter(Mandatory = $false)]
        [switch]$noconfirm
    )

    Begin {
    }

    Process {

        if ( -not ( $Noconfirm )) {
            $message = "Remove Aruba ClearPass connection."
            $question = "Proceed with removal of Aruba ClearPass connection ?"
            $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

            $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
        }
        else { $decision = 0 }
        if ($decision -eq 0) {
            Write-Progress -activity "Remove Aruba ClearPass connection"
            write-progress -activity "Remove Aruba ClearPass connection" -completed
            if (Get-Variable -Name DefaultArubaCPConnection -scope global ) {
                Remove-Variable -name DefaultArubaCPConnection -scope global
            }
        }

    }

    End {
    }
}
