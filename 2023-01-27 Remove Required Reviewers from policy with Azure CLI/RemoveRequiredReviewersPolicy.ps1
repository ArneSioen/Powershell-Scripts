
$json_projects = Invoke-Expression "az devops project list --organization https://dev.azure.com/sioen --output json --only-show-errors" | Convertfrom-json

foreach ($project in $json_projects.value) {
    if ($project.name -like ' dont use TFS - *') { continue }

    Write-Host "-- Project: "$($project.name)" --"
    
    $json_repos = Invoke-Expression "az repos list --organization https://dev.azure.com/sioen --project ""$($project.name)"" --output json" | Convertfrom-json
    #Write-Host "ran: az repos list --organization https://dev.azure.com/sioen --project ""$($project.name)"" --output json"

    foreach ($repo in $json_repos) {        
        Write-Host "- Project & Repo: $($project.name) \ $($repo.name) -"
        
        $json_policies = Invoke-Expression "az repos policy list --organization https://dev.azure.com/sioen --project ""$($project.name)"" --repository-id ""$($repo.id)"" --branch main --output json" | Convertfrom-json                
        #Write-Host "ran: az repos policy list --organization https://dev.azure.com/sioen --project ""$($project.name)"" --repository-id ""$($repo.id)"" --branch main --output json"
        
        foreach ($policy in $json_policies) {
            if ($($policy.type.displayName) -eq "Required reviewers") {

                Write-Host "running: az repos policy delete --id $($policy.id)  --organization https://dev.azure.com/sioen --project ""$($project.name)"" --output json" -ForegroundColor Yellow
                az repos policy delete --id $($policy.id)  --organization https://dev.azure.com/sioen --project ""$($project.name)"" --output json --yes
            }
        }        
    }
}