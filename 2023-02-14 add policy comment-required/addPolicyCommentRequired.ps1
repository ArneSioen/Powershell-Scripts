Set-Location "C:\Users\amoer\source\repos\sioen"

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

        az repos policy comment-required create --organization https://dev.azure.com/sioen --project "$($project.name)" --repository-id "$($repo.id)" --branch main --output json --allow-downvotes true --blocking true --creator-vote-counts false --enabled true --minimum-approver-count 1 --reset-on-source-push true

        Write-Host "Done" -ForegroundColor Green
    }
}
