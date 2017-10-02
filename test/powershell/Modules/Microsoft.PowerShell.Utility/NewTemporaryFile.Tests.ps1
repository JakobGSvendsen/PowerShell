﻿# This is a Pester test suite to validate the New-TemporaryFile cmdlet in the Microsoft.PowerShell.Utility module.
#
# Copyright (c) Microsoft Corporation, 2015
#

<#
    Purpose:
        Verify that New-TemporaryFile creates a temporary file.
        It has an 'Extension' parameter to change the default extension '.tmp'.

    Action:
        Run New-TemporaryFile.

    Expected Result:
        A FileInfo object for the temporary file is returned and the temporary file gets created correctly.
#>

Describe "NewTemporaryFile" -Tags "CI" {

    $defaultExtension = '.tmp'

    AfterEach {
        if ($null -ne $script:tempFile)
        {
            # tempFile variable needs script scope because it gets defined in It block
            Remove-Item $script:tempFile -ErrorAction SilentlyContinue -Force
        }
    }

    It "creates a new temporary file" {
        $script:tempFile = New-TemporaryFile
        $tempFile | Should Exist
        $tempFile | Should BeOfType System.IO.FileInfo
        $tempFile.Extension | Should be $defaultExtension
    }

    It "creates a new temporary file with the Extension parameter being the default" {
        $script:tempFile = New-TemporaryFile -Extension $defaultExtension
        $tempFile | Should Exist
        $tempFile.Extension | Should be $defaultExtension
    }

    if (!$IsWindows)
    {
        It "creates a new temporary file with the Extension parameter being the default but different casing" {
            $defaultExtensionWithUpperCasing = $defaultExtension.ToUpper()
			Write-Host "defaultExtensionWithUpperCasing:$defaultExtensionWithUpperCasing"
            $script:tempFile = New-TemporaryFile  -Extension $defaultExtensionWithUpperCasing
            $tempFile | Should Exist
			Write-Host "FullName: $($tempFile.FullName)"
			Write-Host "TEst-Path: $(TEst-Path ([System.IO.Path]::ChangeExtension($tempFile, $defaultExtension)))"
			Write-Host "uname: $(uname)"
	    if (!(uname -like 'Darwin'))
	    {
	       [System.IO.Path]::ChangeExtension($tempFile, $defaultExtension) | Should Not Exist
	    }
            $tempFile.Extension | Should be $defaultExtensionWithUpperCasing
        }
    }

    It "creates a new temporary file with a specific extension" -TestCases @(
        @{ extension = 'csv' }
        @{ extension = '.csv' }
        @{ extension = '..csv' }
        @{ extension = 'txt.csv' }
        @{ extension = '.txt.csv' }
    ) -Test {
        Param ([string]$extension)
        
        $script:tempFile = New-TemporaryFile -Extension $extension
        $tempFile | Should Exist
        # Because the internal algorithm does renaming it is worthwhile checking that the original file does not get left behind
        [System.IO.Path]::ChangeExtension($tempFile, $defaultExtension) | Should Not Exist
        $tempFile | Should BeOfType System.IO.FileInfo
        $tempFile.FullName.EndsWith($extension) | Should be $true
        $tempFile.Extension | Should be ".csv"
    }

    It "New-TemporaryItem with an an invalid character in the -Extension parameter should throw NewTemporaryInvalidArgument error" {
        $invalidFileNameChars = [System.IO.Path]::GetInvalidFileNameChars()
        foreach($invalidFileNameChar in $invalidFileNameChars)
        {
            { New-TemporaryFile -Extension $invalidFileNameChar -ErrorAction Stop } | ShouldBeErrorId "NewTemporaryInvalidArgument,Microsoft.PowerShell.Commands.NewTemporaryFileCommand"
        }
    }

    It "with WhatIf does not create a file" {
        New-TemporaryFile -WhatIf | Should Be $null
    }

    It "has an OutputType of System.IO.FileInfo" {
        (Get-Command New-TemporaryFile).OutputType | Should Be "System.IO.FileInfo"
    }
}
