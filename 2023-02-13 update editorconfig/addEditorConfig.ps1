﻿Set-Location "C:\Users\amoer\source\repos\sioen"

$initpath = get-location
$json_projects = Invoke-Expression "az devops project list --organization https://dev.azure.com/sioen --output json --only-show-errors" | Convertfrom-json

foreach ($project in $json_projects.value) {
    if ($project.name -like ' dont use TFS - *') { continue }
    if ($project.name -like 'James Dewhurst') { continue }
    if ($project.name -like 'Sioen Fashion') { continue }

    Write-Host "-- Project: "$($project.name)" --"

    $json_repos = Invoke-Expression "az repos list --organization https://dev.azure.com/sioen --project ""$($project.name)"" --output json" | ConvertFrom-Json

    foreach ($repo in $json_repos) {     
        if ($project.name -like 'architecture-decision-record') { continue }
        set-location $initpath
        Write-Host "- Project & Repo: $($project.name) \ $($repo.name) -"
        Write-Host "Going to folder: $($project.name)\$($repo.name)"
        set-location "$($project.name)\$($repo.name)"
        git pull
        $gitStatus = git status
        if (-Not $gitStatus -like 'main') {
            git checkout main
            git pull
            $gitStatus = git status
        }

        if (-Not(Test-Path -Path *.sln)) {
            Write-Host "No solution in $($repo.name); skipping" -ForegroundColor Red
            continue
        }

        if (-Not ($gitStatus -like 'nothing to commit, working tree clean')) {
            Write-Host "Working tree not clean, skipping repo! $($repo.name)" -ForegroundColor Red
        }
                
        Copy-Item -Path "C:\Users\amoer\source\repos\personal\Tools\PowerShell Scripts\2023-02-06 use upstream sources in nuget.config\nuget.config" -Destination "."
        Copy-Item -Path "C:\Users\amoer\source\repos\personal\Tools\PowerShell Scripts\2023-02-13 update editorconfig\.editorconfig" -Destination "."
        $gitStatus = git status
        if ($gitStatus -like 'nothing to commit, working tree clean') { 
            Write-Host "Already done, skipping" -ForegroundColor Green
            continue
        }

        $json_policies = Invoke-Expression "az repos policy list --organization https://dev.azure.com/sioen --project ""$($project.name)"" --repository-id ""$($repo.id)"" --branch main --output json" | Convertfrom-json
        
        foreach ($policy in $json_policies) {
            if ($policy.id -eq "-1") { continue }
            Write-Host "Deleting Policy "$($policy.type.displayName) -ForegroundColor Yellow
            az repos policy delete --id $($policy.id)  --organization https://dev.azure.com/sioen --project ""$($project.name)"" --output json --yes
        }
        
        git add --all
        git commit -m "update .editorconfig in repo"
        git push

        az repos policy approver-count create --organization https://dev.azure.com/sioen --project "$($project.name)" --repository-id "$($repo.id)" --branch main --output json --allow-downvotes true --blocking true --creator-vote-counts false --enabled true --minimum-approver-count 1 --reset-on-source-push true

        Write-Host "Done" -ForegroundColor Green
    }
}