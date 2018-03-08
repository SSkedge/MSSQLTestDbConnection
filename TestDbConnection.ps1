function TestDbConnection
{
    param( 
    [Parameter(Position=0, Mandatory=$True, ValueFromPipeline=$True)] [string] $ServerName,
    [Parameter(Position=1, Mandatory=$True)] [string] $SQLDatabaseName,
    [Parameter(Position=2, Mandatory=$True, ParameterSetName="SQLAuth")] [string] $Username,
    [Parameter(Position=3, Mandatory=$True, ParameterSetName="SQLAuth")] [string] $Password,
    [Parameter(Position=2, Mandatory=$True, ParameterSetName="WindowsAuth")] [switch] $UseWindowsAuthentication
    )
 
    process { 
        $dbConnection = New-Object System.Data.SqlClient.SqlConnection
        if (!$UseWindowsAuthentication) {
            $dbConnection.ConnectionString = "Data Source=$ServerName
    ; uid=$Username; pwd=$Password; SQLDatabaseName=$SQLDatabaseName;Integrated Security=False"
            $authentication = "SQL ($Username)"
        }
        else {
            $dbConnection.ConnectionString = "Data Source=$ServerName
    ; SQLDatabaseName=$SQLDatabaseName;Integrated Security=True;"
            $authentication = "Windows ($env:USERNAME)"
        }
        try {
            $connectionTime = measure-command {$dbConnection.Open()}
            $ConnectionResponse = @{
                Connection = "Successful"
                ElapsedTime = $connectionTime.TotalSeconds
                ServerName
         = $ServerName
                SQLDatabaseName = $SQLDatabaseName
                User = $authentication}
        }

        catch {
                $ConnectionResponse = @{
                Connection = "Database connection to: " + $SQLDatabaseName +" Failed"
                ElapsedTime = $connectionTime.TotalSeconds
                ServerName
         = $ServerName
        
                SQLDatabaseName = $SQLDatabaseName
                User = $authentication}
        }
        Finally{
            $dbConnection.Close()
            $outputObject = New-Object -Property $ConnectionResponse -TypeName psobject
            write-output $outputObject 
        }
    }
}