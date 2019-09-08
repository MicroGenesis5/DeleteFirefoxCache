# Deletes all the Firefox cache for every user on a Windows computer
# Great way to free up space on Terminal Servers and other computers with multiple Windows users

# Cache is stored on the local computer in the directory C:\Users\%user%\AppData\Local\Mozilla\Firefox\Profiles
# A Windows user can have multiple Firefox profiles; profiles can be found in the above directory or by
# going to 'about:profiles' in a Firefox browser (type that in the address bar, without the single quotes) 


$global:cache_size_total = 0.0

$users = Get-ChildItem "C:\Users"

for ($i=0; $i -lt $users.length; $i++)
{
    $user_str = [string]$users[$i].name
    $path = "C:\Users\$user_str\AppData\Local\Mozilla\Firefox\Profiles"
    
    if (-Not (Test-Path $path))
    {
        Write-Host "Windows User '$user_str' does not have Firefox cache."
        Write-Host ""
    }
    else
    {
        $ff_profile_hash = Get-ChildItem $path
        for ($j=0; $j -lt $ff_profile_hash.length; $j++)
        {
            $ff_profile_hash_str = [string]$ff_profile_hash[$j]
            $path_cache = $path + "\$ff_profile_hash_str" + "\cache2\entries"
            
            $ff_profile_name = $ff_profile_hash_str.Substring($ff_profile_hash_str.IndexOf(".") + 1, `
                $ff_profile_hash_str.length - $ff_profile_hash_str.IndexOf(".") -1) 
            #example: if there's a directory under the Profiles directory named 'prnrrl39.default' then the Firefox profile name is 'default'
            
            if (-Not (Test-Path $path_cache))
            {
                Start-Sleep -s 3
                Write-Host "Windows user '$user_str' does not have cache for their Firefox profile named '$ff_profile_name'"
            }
            else
            {
                $cache_folder = Get-ChildItem $path_cache | Measure-Object
                if ($cache_folder.count -ne 0)
                {
                    Start-Sleep -s 3
                    Write-Host "Deleting Windows user '$user_str' cache for Firefox profile named '$ff_profile_name'" -ForegroundColor Red


                    # source: https://bit.ly/2DYiJZ9
                    $size = "{0:N2} MB" -f ((Get-ChildItem $path_cache -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)
                    $size_decimal = [decimal]$size.Substring(0, $size.length-3)

                    $global:cache_size_total += $size_decimal

                    Remove-Item "$path_cache\*"
                                       
                    Write-Host "   ... $size of cache deleted" -ForegroundColor Green
                }
                else
                {
                    Write-Host "Windows user '$user_str' does not have cache for their Firefox profile named '$ff_profile_name'"
                }
            }
            Write-Host ""
        }
    }
}

Write-Host "Total cache deleted: $global:cache_size_total MB" -ForegroundColor Green

Write-Host ""
cmd /c pause
