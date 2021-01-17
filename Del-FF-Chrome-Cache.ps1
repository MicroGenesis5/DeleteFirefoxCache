# Firefox: disable browser from saving cache:
  # 1.) open a Firefox window and in the address bar enter:
    # about: config
    # browser.cache.disk.enable
      # set to: false
    # browser.cache.disk.capacity
      # set to: 0
  # 2.) create a file, C:\Program Files\Mozilla Firefox\mozilla.cfg - contents of mozilla.cfg (do not add '#'):
    # //
    # lockPref("browser.cache.disk.capacity", 0);
    # lockPref("browser.cache.disk.enable", false);  
  # 3.) create a file, C:\Program Files\Mozilla Firefox\defaults\pref\local-settings.js - contents of local-settings.js (do not add '#'):
    # //
    # pref("general.config.filename","mozilla.cfg");
    # pref("general.config.obscure_value",0);

# Chrome: disable browser from saving cache:
  # Menu (vertical 3 dots) > More tools > Developer tools
  # At the top click 'Network' (may need to expand Developer tools window)
  # check 'Disable cache' checkbox

$global:cache_size_total_ff = 0.0
$global:cache_size_total_chrome = 0.0

$users = Get-ChildItem "C:\Users"

# Firefox cache
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
                Write-Host "Windows user '$user_str' does not have cache for his Firefox profile named '$ff_profile_name'"
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

                    $global:cache_size_total_ff += $size_decimal

                    Remove-Item "$path_cache\*"
                                       
                    Write-Host "   ... $size of cache deleted" -ForegroundColor Green
                }
                else
                {
                    Write-Host "Windows user '$user_str' does not have cache for his Firefox profile named '$ff_profile_name'"
                }
            }
            Write-Host ""
        }
    }
}

# Chrome cache
for ($i=0; $i -lt $users.length; $i++)
{
    $user_str = [string]$users[$i].name
    $path_cache = "C:\Users\$user_str\AppData\Local\Google\Chrome\User Data\Default\Cache"

    if (-Not (Test-Path $path_cache))
    {
        Start-Sleep -s 3
        Write-Host "Windows user '$user_str' does not have Chrome cache"
    }
    else
    {
        $cache_folder = Get-ChildItem $path_cache | Measure-Object
        if ($cache_folder.count -ne 0)
        {
            Start-Sleep -s 3
            Write-Host "Deleting Windows user '$user_str' Chrome cache" -ForegroundColor Red

            # source: https://bit.ly/2DYiJZ9
            $size = "{0:N2} MB" -f ((Get-ChildItem $path_cache -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)
            $size_decimal = [decimal]$size.Substring(0, $size.length-3)

            $global:cache_size_total_chrome += $size_decimal

            Remove-Item "$path_cache\*"

            Write-Host "   ... $size of cache deleted" -ForegroundColor Green
        }
        else
        {
            Write-Host "Windows user '$user_str' does not have Chrome cache"
        }
    }
    Write-Host ""
}

Write-Host "Firefox cache deleted: $global:cache_size_total_ff MB" -ForegroundColor Green
Write-Host "Chrome cache deleted: $global:cache_size_total_chrome MB" -ForegroundColor Green
$total_cache = $global:cache_size_total_ff + $global:cache_size_total_chrome
Write-Host "Total cache deleted: $total_cache MB"-ForegroundColor Green 
cmd /c pause



