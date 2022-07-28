#### Function to retrieve value from input object and key ####
function pass-nested-object 
{
    param (
        [Parameter()]
        [string]$input_object_func,
        [Parameter()]
        $input_key_func

    )

    $input_keys = $input_key_func -split "/"

    $jsonObject = $input_object_func | ConvertFrom-Json

    foreach ($ikey in $input_keys)
    {
        $out_value = $jsonObject.$ikey
        $jsonObject = $out_value
    }

    #return $out_value
    Write-Output "Value : $out_value"
}



#### Test Case 1 ####
<#
$input_object = '{"a":{"b":{"c":"d"}}}'
$input_key = "a/b/c"
pass-nested-object $input_object $input_key

## OUTPUT:
PS C:\Users\nidhi.sikka> C:\Users\nidhi.sikka\Desktop\MyDocx\KPMG\pass-nested-object\pass-object-key-get-value.ps1
Value : d

#>

#### Test Case 2 ####
<#
$input_object = '{"x":{"y":{"z":"a"}}}'
$input_key = "x/y/z"
pass-nested-object $input_object $input_key

## OUTPUT:
PS C:\Users\nidhi.sikka> C:\Users\nidhi.sikka\Desktop\MyDocx\KPMG\pass-nested-object\pass-object-key-get-value.ps1
Value : a

#>

#### Test Case 3 ####
<#
$input_object = '{"class1":{"class2":{"class3":"class4"}}}'
$input_key = "class1/class2/class3"
pass-nested-object $input_object $input_key

OUTPUT:
PS C:\Users\nidhi.sikka> C:\Users\nidhi.sikka\Desktop\MyDocx\KPMG\pass-nested-object\pass-object-key-get-value.ps1
Value : class4

#>
