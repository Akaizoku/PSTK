function Write-InsertOrUpdate {
  <#
    .SYNOPSIS
    Write INSERT OR UPDATE SQL query

    .DESCRIPTION
    Check if record key exists and insert or update data in a table

    .PARAMETER Table
    The table parameter corresponds to the name of the table in which to insert or update records.

    Remark: It is recommended to use the fully qualified table name.

    .PARAMETER Fields
    The fields parameter corresponds to the list of table columns and their corresponding values.

    .PARAMETER PrimaryKey
    The primary key parameter corresponds to the column constituting the unique key identifier of the record in the specified table.

    .PARAMETER Vendor
    The optional vendor parameter corresponds to the database vendor used to define the syntax to use for the SQL statement.

    The available values are:
    - Oracle:     Oracle database
    - SQLServer:  Microsoft SQL Server database

    The default value is SQLServer because it is fully integrated with PowerShell and for legacy support purposes.

    .PARAMETER Identity
    The identity switch allows identity fields to be modifed.

    .EXAMPLE
    $Fields = [Ordered]@{
      "column1" = "value1"
      "column2" = "value2"
      "column3" = "value3"
      "column4" = "value4"
    }
    Write-InsertOrUpdate -Table "Test" -Fields $Fields -PrimaryKey @("column1", "column2")

    In this example, the function will check the table "Test" to see if the columns "column1" and "column2" contains respectively the values "values1" and "values2". If a record is found, the the returned query will update the values of the columns "columns3" and "columns4". In no corresponding record is found, the returned query will insert a new record with the specified values.

    .NOTES
    File name:      Write-InsertOrUpdate.ps1
    Author:         Florian Carrier
    Creation date:  15/10/2019
    Last modified:  26/02/2020
  #>
  [CmdletBinding (
    SupportsShouldProcess = $true
  )]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Table name"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Table,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "List of fields"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Collections.Specialized.OrderedDictionary]
    $Fields,
    [Parameter (
      Position    = 3,
      Mandatory   = $true,
      HelpMessage = "Primary key to use for the existence check"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("PK")]
    [String[]]
    $PrimaryKey,
    [Parameter (
      Position    = 4,
      Mandatory   = $false,
      HelpMessage = "Database vendor (syntax)"
    )]
    [ValidateSet (
      "Oracle",
      "SQLServer"
    )]
    [Alias ("Syntax")]
    [String]
    $Vendor = "SQLServer",
    [Parameter (
      HelpMessage = "Switch to enable working with identities"
    )]
    [Switch]
    $Identity
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    # Check that values are provided for the primary key
    foreach ($Key in $PrimaryKey) {
      if (Find-Key -Hashtable $Fields -Key $Key) {
        if ($Fields.$Key -eq $null) {
          Write-Log -Type "ERROR" -Object "Missing value for primary key $Key" -ExitCode 1
        }
      } else {
        Write-Log -Type "ERROR" -Object "The primary key $Key is not in the list of fields provided" -ExitCode 1
      }
    }
  }
  Process {
    switch ($Vendor) {
      "Oracle" {
        # Define existence check
        foreach($Key in $PrimaryKey) {
          if ($PrimaryKeyCheck -eq $null) { $PrimaryKeyCheck  = "$Key = $($Fields.$Key)" }
          else                            { $PrimaryKeyCheck += " AND $Key = $($Fields.$Key)"   }
        }
        $Check = [System.String]::Concat("MERGE INTO $Table USING dual ON (", $PrimaryKeyCheck, ")")

        # Loop through fields
        foreach ($Field in $Fields.GetEnumerator()) {
          # Select update values
          if ($Field.Key -NotIn $PrimaryKey) {
            if ($UpdateValues -eq $null)  { $UpdateValues  = "$($Field.Key) = $($Field.Value)"    }
            else                          { $UpdateValues += ", $($Field.Key) = $($Field.Value)"  }
          }
          # Set insert fields
          if ($InsertFields -eq $null)  { $InsertFields  = "$($Field.Key)"                        }
          else                          { $InsertFields += ", $($Field.Key)"                      }
          # Set insert values
          if ($InsertValues -eq $null)  { $InsertValues  = "$($Field.Value)"                      }
          else                          { $InsertValues += ", $($Field.Value)"                    }
        }

        # Construct update query
        $Update = [System.String]::Concat("WHEN MATCHED THEN UPDATE SET ", $UpdateValues)
        # Construct insert query
        $Insert = [System.String]::Concat("WHEN NOT MATCHED THEN INSERT (", $InsertFields, ") VALUES (", $InsertValues, ")")

        # Construct whole SQL query
        $Query =  [System.String]::Concat($Check, "`n", $Update, "`n", $Insert)

        # TODO
      }
      "SQLServer" {
        # Define existence check
        foreach($Key in $PrimaryKey) {
          if ($PrimaryKeyCheck -eq $null) { $PrimaryKeyCheck  = " WHERE $Key = $($Fields.$Key)" }
          else                            { $PrimaryKeyCheck += " AND $Key = $($Fields.$Key)"   }
        }
        $Check = [System.String]::Concat("IF EXISTS (SELECT COUNT(1) FROM " , $Table, $PrimaryKeyCheck, ")")

        # Loop through fields
        foreach ($Field in $Fields.GetEnumerator()) {
          # Select update values
          if ($Field.Key -NotIn $PrimaryKey) {
            if ($UpdateValues -eq $null)  { $UpdateValues  = "$($Field.Key) = $($Field.Value)"    }
            else                          { $UpdateValues += ", $($Field.Key) = $($Field.Value)"  }
          }
          # Set insert fields
          if ($InsertFields -eq $null)  { $InsertFields  = "$($Field.Key)"                        }
          else                          { $InsertFields += ", $($Field.Key)"                      }
          # Set insert values
          if ($InsertValues -eq $null)  { $InsertValues  = "$($Field.Value)"                      }
          else                          { $InsertValues += ", $($Field.Value)"                    }
        }

        # Construct update query
        $Update = [System.String]::Concat("UPDATE ", $Table, " SET ", $UpdateValues, $PrimaryKeyCheck)
        # Construct insert query
        $Insert = [System.String]::Concat("INSERT INTO ", $Table, " (", $InsertFields, ") VALUES (", $InsertValues, ")")

        # Construct whole SQL query
        $Query =  [System.String]::Concat($Check, "`nBEGIN`n`t", $Update, "`nEND`nELSE`nBEGIN`n`t", $Insert, "`nEND")

        # Check identity flag
        if ($PSBoundParameters.ContainsKey["Identity"] -eq $true) {
          # Manage IDENTITY_INSERT
          $EnableIdentityInsert   = "SET IDENTITY_INSERT $Table ON"
          $DisableIdentityInsert  = "SET IDENTITY_INSERT $Table OFF"
          $Query = [System.String]::Concat($EnableIdentityInsert, "`n", $Query, "`n", $DisableIdentityInsert)
        }
      }
      default {
        Write-Log -Type "ERROR" -Object "Unsupported database vendor $Vendor"
        return $null
      }
    }
    # Return query
    Write-Log -Type "DEBUG" -Object $Query
    return $Query
  }
}
