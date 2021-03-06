#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Connect to a ClearPass (using Token)" {
    BeforeAll {
        #Disconnect "default connection"
        Disconnect-ArubaCP -noconfirm
    }
    It "Connect to ClearPass (using Token) and check global variable" {
        Connect-ArubaCP $ipaddress -Token $token -SkipCertificateCheck
        $DefaultArubaCPConnection | Should Not BeNullOrEmpty
        $DefaultArubaCPConnection.server | Should be $ipaddress
        $DefaultArubaCPConnection.token | Should be $token
    }
    It "Disconnect to ClearPass and check global variable" {
        Disconnect-ArubaCP -noconfirm
        $DefaultArubaCPConnection | Should be $null
    }
    #TODO: Connect using wrong login/password

    #This test only work with PowerShell 6 / Core (-SkipCertificateCheck don't change global variable but only Invoke-WebRequest/RestMethod)
    #This test will be fail, if there is valid certificate...
    It "Throw when try to use Invoke-ArubaCPRestMethod with don't use -SkipCertifiateCheck" -Skip:("Desktop" -eq $PSEdition) {
        Connect-ArubaCP $ipaddress -Token $token
        { Invoke-ArubaCPRestMethod -uri "rest/v4/vlans" } | Should throw "Unable to connect (certificate)"
        Disconnect-ArubaCP -noconfirm
    }
    It "Throw when try to use Invoke-ArubaCPRestMethod and not connected" {
        { Invoke-ArubaCPRestMethod -uri "rest/v4/vlans" } | Should throw "Not Connected. Connect to the ClearPass with Connect-ArubaCP"
    }
}

Describe  "Invoke ArubaCP RestMethod tests" {
    BeforeAll {
        #connect...
        Connect-ArubaCP $ipaddress -Token $token -SkipCertificateCheck
        #Add 26 Network Device (NAS)
        Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW2 -ip_address 192.0.2.2 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW3 -ip_address 192.0.2.3 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW4 -ip_address 192.0.2.4 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW5 -ip_address 192.0.2.5 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW6 -ip_address 192.0.2.6 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW7 -ip_address 192.0.2.7 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW8 -ip_address 192.0.2.8 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW9 -ip_address 192.0.2.9 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW10 -ip_address 192.0.2.10 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW11 -ip_address 192.0.2.11 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW12 -ip_address 192.0.2.12 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW13 -ip_address 192.0.2.13 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW14 -ip_address 192.0.2.14 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW15 -ip_address 192.0.2.15 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW16 -ip_address 192.0.2.16 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW17 -ip_address 192.0.2.17 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW18 -ip_address 192.0.2.18 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW19 -ip_address 192.0.2.19 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW20 -ip_address 192.0.2.20 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW21 -ip_address 192.0.2.21 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW22 -ip_address 192.0.2.22 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW23 -ip_address 192.0.2.23 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW24 -ip_address 192.0.2.24 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW25 -ip_address 192.0.2.25 -radius_secret MySecurePassword -vendor Aruba
        Add-ArubaCPNetworkDevice -name pester_SW26 -ip_address 192.0.2.26 -radius_secret MySecurePassword -vendor Aruba
    }

   It "Use Invoke-ArubaCPRestMethod without limit parameter" {
        #Need to found only less 25 entries...
        $response = Invoke-ArubaCPRestMethod -method "GET" -uri "api/network-device"
        $nad = $response._embedded.items | where-object { $_.name -match "pester_"}
        $nad.count | should -BeLessOrEqual 25
    }

    It "Use Invoke-ArubaCPRestMethod with limit parameter" {
        $response = Invoke-ArubaCPRestMethod -method "GET" -uri "api/network-device" -limit 1000
        $nad = $response._embedded.items | where-object { $_.name -match "pester_"}
        $nad.count | should be 26
    }

    It "Use Invoke-ArubaCPRestMethod with filter parameter (equal)" {
        #Need to found only pester_SW1
        $response = Invoke-ArubaCPRestMethod -method "GET" -uri "api/network-device" -filter @{ "name" = "pester_SW1" }
        $nad = $response._embedded.items
        $nad.count | should -BeLessOrEqual 1
    }

    It "Use Invoke-ArubaCPRestMethod with filter parameter (contains)" {
        #Need to found only pester_SW1[X] (11 entries)
        $response = Invoke-ArubaCPRestMethod -method "GET" -uri "api/network-device" -filter @{ "name" = @{ "`$contains" = "pester_SW1" } }
        $nad = $response._embedded.items
        $nad.count | should -BeLessOrEqual 11
    }

    AfterAll {
        #Remove NAD entries...
        Get-ArubaCPNetworkDevice -name pester_SW1 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW2 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW3 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW4 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW5 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW6 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW7 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW8 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW9 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW10 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW11 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW12 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW13 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW14 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW15 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW16 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW17 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW18 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW19 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW20 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW21 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW22 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW23 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW24 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW25 | Remove-ArubaCPNetworkDevice -noconfirm
        Get-ArubaCPNetworkDevice -name pester_SW26 | Remove-ArubaCPNetworkDevice -noconfirm
        #And disconnect
        Disconnect-ArubaCP -noconfirm
    }
}