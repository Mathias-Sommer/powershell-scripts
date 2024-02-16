#This is a fun one. We had a project in our first school semester. (Explains spaghetti code ;) )
#The assignment was to import a CSV and then write to an SQL database from PowerShell.

#Connection string
$Server = "SQL\SQL"
$Database = "Gartneri"
$username ="LOEVETAND\Administrator"
$password = "YouAreGonnaGuessItArentYou?"

$Connection = New-Object System.Data.SQLClient.SQLConnection
$Connection.ConnectionString = "server='$Server';database='$Database'; User ID = $username; Password = $password;Integrated Security = true;"
$Connection.Open()

$command = New-Object System.Data.SqlClient.SqlCommand
$command.Connection = $Connection

#importere CSV-filer fra mappe
$files = Get-ChildItem -Path "C:\SQL_INDSAET\*.csv"

#Foreach loop til at få alle filer $files
foreach ($file in $files){
    import-csv -Path $file.FullName -Delimiter ";" -Encoding UTF7 | 
        ForEach-Object {
            #Tager alle kolonner i CSV, og lægger i variabler.    
            ($Type = $_.Type), 
            ($MaalerId = $_.MaalerId), 
            ($Tidspunkt = $_.Tidspunkt), 
            ($Maaling = $_.Maaling.Replace(',','.')); #Replace komma med punktum, sådan det kan læses korrekt i SQL.

                #Sætter specifik data ind, efter hvilken type der er defineret i CSV-filen. Fx står der: 1, så skal der stå Temperatur osv.
                if($Type -eq 1){ #Temperatur
                    $command.CommandText = "Insert into dbo.Maaler ([MaalerType],[MaalerNr],[Maalerenhed]) Values (" + 
                                           "'Temperatur'" + ", " + $MaalerId + ", " + "'Celsius'" + ")";
                    $command.ExecuteNonQuery();
                    $command.CommandText;
                    $command.CommandText = "Insert into dbo.Maaling ([Tidspunkt],[MaalVaerdi],[MaalerNR]) Values (" + "convert(datetime2(2),'" + $Tidspunkt + "',103)," + $Maaling + ", " + $MaalerId + ")" ;
                    $command.ExecuteNonQuery();
                }
                ElseIf($type -eq 2){ #Vand
                    $command.CommandText = "Insert into dbo.Maaler ([MaalerType],[MaalerNr],[Maalerenhed]) Values (" + 
                                           "'Vand'" + ", " + $MaalerId + ", " + "'Procent'" + ")";
                    $command.ExecuteNonQuery();
                    $command.CommandText = "Insert into dbo.Maaling ([Tidspunkt],[MaalVaerdi],[MaalerNR]) Values (" + "convert(datetime2(2),'" + $Tidspunkt + "',103)," + $Maaling + ", " + $MaalerId + ")" ;
                    $command.ExecuteNonQuery();
                }
                ElseIf($type -eq 3){ #Gødning
                    $command.CommandText = "Insert into dbo.Maaler ([MaalerType],[MaalerNr],[Maalerenhed]) Values (" + 
                                           "'Gødning'" + ", " + $MaalerId + ", " + "'N/A'" + ")";
                    $command.ExecuteNonQuery();
                    $command.CommandText = "Insert into dbo.Maaling ([Tidspunkt],[MaalVaerdi],[MaalerNR]) Values (" + "convert(datetime2(2),'" + $Tidspunkt + "',103)," + $Maaling + ", " + $MaalerId + ")" ;
                    $command.ExecuteNonQuery();
                }
                ElseIf($type -eq 4){ #Lys
                    $command.CommandText = "Insert into dbo.Maaler ([MaalerType],[MaalerNr],[Maalerenhed]) Values (" + 
                                           "'Lys'" + ", " + $MaalerId + ", " + "'Lux'" + ")";
                    $command.ExecuteNonQuery();
                    $command.CommandText = "Insert into dbo.Maaling ([Tidspunkt],[MaalVaerdi],[MaalerNR]) Values (" + "convert(datetime2(2),'" + $Tidspunkt + "',103)," + $Maaling + ", " + $MaalerId + ")" ;
                    $command.ExecuteNonQuery();
                    }

        #Sætter data ind på drivhus 1 + bord 1, og tæller bord op indtil 4, sætter derefter drivhus til 2 bord 1, osv.
        $command.CommandText = "Insert into dbo.BordMaaler (Drivhus,Bord,MaalerNr) values("+$drivhusnr+","+$bordnr+","+ $MaalerId +")"
        $command.ExecuteNonQuery();
        $bordnr++
        if($bordnr -ge 4)
            {
                $drivhusnr++
                $bordnr = 1
            }
        if($drivhusnr -ge 5)
            {
                $drivhusnr = 1
            }
        }

    #Udskriver i txt fil, hvilke filer der er importeret, samt dato.
    $sidstefil = get-item -Path $file 
    $dato = get-date
    $sidstefil.Name + " Dato: " + $dato | out-file C:\lastCSV.txt -append 
            }
#Lukker forbindelsen til SQL-Server
$Connection.Close()
