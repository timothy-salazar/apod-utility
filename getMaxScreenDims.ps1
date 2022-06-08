# Add-Type -AssemblyName System.Windows.Forms

# [System.Windows.Forms.Screen]::AllScreens |
# 	ForEach-Object{
# 		[pscustomobject]@{
# 			DeviceName=$_.DeviceName.Split('\\')[-1]
# 			Height=$_.bounds.height
# 			Width=$_.bounds.height
# 			BitsPerPixel=$_.BitsPerPixel
# 		}
# 	}
Add-Type -AssemblyName System.Windows.Forms
$Monitors = [System.Windows.Forms.Screen]::AllScreens
$MaxWidth = 0
$MaxHeight = 0
foreach ($Monitor in $Monitors)
{
	$Width = $Monitor.bounds.Width
	$Height = $Monitor.bounds.Height
	if($Width -gt $MaxWidth){
		$MaxWidth = $Width
	}
	if($Height -gt $MaxHeight){
		$MaxHeight = $Height
	}
	
}
Write-Host "$MaxWidth $MaxHeight"