Function fileArrange ($sourcePath, $destPath1, $destPath2)
{

  $filteral =  [regex] "^[a-lA-L]"
  $filtermz = [regex] "^[m-zM-Z]"
  $filterNonChar = [regex] "^[^a-zA-Z]"


    $binAl = Get-ChildItem -Path $sourcePath | Where-Object {$_.Name -match $filteral} 
    foreach ($item in $binAl) {Move-Item -Path $item.FullName -Destination $destPath1}

    $binMz = Get-ChildItem -Path $sourcePath  | Where-Object {$_.Name -match $filtermz} 
    foreach ($item in $binMz) {Move-Item -Path $item.FullName -Destination $destPath2}

    $binNonLetter = Get-ChildItem -Path $sourcePath | Where-Object {$_.Name -match $filterNonLetter} 
    foreach ($item in $binNonLetter) {Remove-Item -Path $item.FullName}

    if ($null -eq $binAl -And $null -eq $binMz -And $null -eq $binNonLetter)
    
    {
        $warning = "no files were found for processing"
         Write-Warning $warning
         return $warning
    }
}

#Pester Tests

Describe ":  CREATES A FILESYSTEM IN TEMP DIRECTORY USING PESTER AND RUNS A VARIETY OF TESTS." {
    Setup -Dir "destPath1"
    Setup -Dir "destPath2"
    Setup -Dir "sourcePath"
    $warning = fileArrange "TestDrive:\sourcePath"  "TestDrive:\destPath1" "TestDrive:\destPath2"

    It "Tests to see if warning message is executed if no files are in source folder." {
        $warning | Should -Not -BeNullOrEmpty
    }

    It "Creates 3 text files and tests if they were moved to proper location." {
     
      New-Item -Path 'TestDrive:\sourcePath\apple.txt' -itemType 'File'
      New-Item -Path 'TestDrive:\sourcePath\pear.txt' -itemType 'File'
      New-Item -Path 'TestDrive:\sourcePath\1234.txt' -itemType 'File'
      
      fileArrange "TestDrive:\sourcePath"  "TestDrive:\destPath1" "TestDrive:\destPath2"

      'TestDrive:\destPath1\apple.txt' | Should -Exist 
      'TestDrive:\destPath2\pear.txt' | Should -Exist
      'TestDrive:\sourcePath\1234.txt' | Should -Not -Exist 
      'TestDrive:\destPath1\1234.txt' | Should -Not -Exist
      'TestDrive:\destPath2\1234.txt' | Should -Not -Exist
      
      Remove-Item 'TestDrive:\destPath1\apple.txt'
      Remove-Item 'TestDrive:\destPath2\pear.txt'
      
     }

     It "Runs fileArrange function Twice, checks to see if file locations are correct and if the warning message is executed." {
     
        New-Item -Path 'TestDrive:\sourcePath\apple.txt' -itemType 'File'
        New-Item -Path 'TestDrive:\sourcePath\bobcat.txt' -itemType 'File'
        
        fileArrange "TestDrive:\sourcePath"  "TestDrive:\destPath1" "TestDrive:\destPath2"
  
        'TestDrive:\destPath1\apple.txt' | Should -Exist 
        'TestDrive:\destPath1\bobcat.txt' | Should -Exist

        #run fileArrange function again - no files should be in source folder, they should be in destination folder.
        
        $warning2 = fileArrange "TestDrive:\sourcePath"  "TestDrive:\destPath1" "TestDrive:\destPath2"
        $warning2 | Should -Not -BeNullOrEmpty
        'TestDrive:\destPath1\apple.txt' | Should -Exist 
        'TestDrive:\destPath1\bobcat.txt' | Should -Exist
       }  
}
