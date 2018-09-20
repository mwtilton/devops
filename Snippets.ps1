#Fatal Error Handling
Try{

}
Catch{
    $_ | fl * -force
    $_.InvocationInfo.BoundParameters | fl * -force
    $_.Exception
}
