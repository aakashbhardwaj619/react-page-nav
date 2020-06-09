#!/bin/bash

# requires jq: https://stedolan.github.io/jq/

packagePath=$packagePath

sites=("https://in8aakbh.sharepoint.com/sites/AppIndex" "https://in8aakbh.sharepoint.com/sites/UHSD1" "https://in8aakbh.sharepoint.com/sites/UHSD2")

echo "Deployment to begin"

for siteUrl in "${sites[@]}"; do
  echo "Site URL: $siteUrl"
  app=$(o365 spo app add --filePath $packagePath --scope sitecollection --appCatalogUrl $siteUrl --overwrite)
  o365 spo app deploy --id $app --scope sitecollection --appCatalogUrl $siteUrl
  echo "Deployed App..."
  appInfo=$(o365 spo app get --id $app --scope sitecollection --appCatalogUrl $siteUrl --output json)
  appVersion=$(echo $appInfo | jq -r '.InstalledVersion')
  appCanUpgrade=$(echo $appInfo | jq -r '.CanUpgrade')

  if [[ "$appCanUpgrade" = "true" ]]; then
    o365 spo app upgrade --id $app --siteUrl $siteUrl --scope sitecollection
    echo "Upgraded App..."
  fi
  if [ -z "$appVersion" ]; then
    o365 spo app install --id $app --siteUrl $siteUrl --scope sitecollection
    echo "Installed app..."
  fi
done

o365 spo mail send --webUrl ${sites[0]} --to 'aakash.bhardwaj@in8aakbh.onmicrosoft.com' --subject "Deployment of $packageName completed" --body "<h2>Deployment Completed</h2> <p>Deployment of $packagePath completed.</p>"
