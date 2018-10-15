# ------------------------------------------------------------------------------
# Convert Word to PDF
# ------------------------------------------------------------------------------
function ConvertTo-PDF {
  <#
    .SYNOPSIS
    Convert Word document to PDF

    .DESCRIPTION
    Convert documents in a Word format to a Portable Document Format (PDF) with-
    out having to open Microsoft Word.

    .PARAMETER Path
    The path parameter corresponds to the path of the directory containing the
    Microsoft Word documents to convert to PDF. It can point to a single file.

    .EXAMPLE
    ConvertTo-PDF -Path ".\doc"
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Directory containing the files to convert"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("Directory")]
    [String]
    $Path
  )
  Begin {
    $Output = $false
    $Count  = 0
  }
  Process {
    if (Test-Path -Path $Path) {
      # Initialise MS Word application and identify document
      $MSWord = New-Object -ComObject Word.Application
      $Files  = Get-Object -Path $Path -Filter "*.doc?"
      if ($Files.Count -gt 0) {
        foreach ($File in $Files) {
          try {
            # Generate PDF
            $Document = $MSWord.Documents.Open($File.FullName)
            $PDFName  = "$($File.BaseName).pdf"
            $PDF      = "$($File.DirectoryName)\$PDFName"
            Write-Log -Type "INFO" -Message "Converting ""$($File.Name)"" to PDF"
            $Document.SaveAs([Ref] $PDF, [Ref] 17)
            $Document.Close()
            $Count += 1
          } catch [System.Management.Automation.RuntimeException] {
            Write-Log -Type "WARN" -Message "An error occured while generating $PDFName"
          }
          Write-Log -Type "CHECK" -Message """$PDFName"" successfully generated"
        }
        if ($Count -gt 0) {
          $Output = $true
        }
        Write-Log -Type "CHECK" -Message "$Count Word documents were converted to PDF"
      } else {
        Write-Log -Type "ERROR" -Message "No Microsoft Word documents were found in $Path."
      }
    } else {
      Write-Log -Type "ERROR" -Message "$Path does not exists."
      Stop-Script 1
    }
    return $Output
  }
  End {
    $MSWord.Quit()
  }
}
