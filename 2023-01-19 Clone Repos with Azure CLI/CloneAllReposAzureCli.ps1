
$initpath = get-location
$json_projects = Invoke-Expression "az devops project list --organization https://dev.azure.com/sioen/ --output json --only-show-errors" | Convertfrom-json

foreach ($project in $json_projects.value){
    if($project.name -like ' dont use TFS - *'){ continue }

    $project_name = $project.name
    Write-Host "-- Project: "$project_name" --"
    
    $repos_in_project = Invoke-Expression "az repos list --organization https://dev.azure.com/sioen/ --project ""$project_name"" --output json" | Convertfrom-json
    foreach ($repo in $repos_in_project){
        
        $name = $project_name + "\" + $repo.name

        if (!(Test-Path -Path $name)) {
            Write-Host "- Cloning: "$repo.name
            git clone $repo.remoteUrl $name
            Write-Host "- Done Cloning: "$repo.name
        }
        else {
            Write-Host "- Pulling: "$repo.name
            set-location $name
            git pull
            set-location $initpath
            Write-Host "- Done Pulling: "$repo.name
        }    
    }
}
