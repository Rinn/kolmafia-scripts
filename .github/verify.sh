#!/bin/bash

cd scripts/
ashfiles=$(ls *.ash)
cd ..

if [[ -f "dependencies.txt" ]]; then
    # Install dependencies
    echo "Installing dependencies..."

    output_file="scripts/_ci_dependencies.ash"
    while read -r line || [ -n "$line" ]; do
        echo "cli_execute('svn checkout ${line}');" >> "$output_file"
    done < "dependencies.txt"
    echo "cli_execute('exit');" >> "$output_file"
    java -DuseCWDasROOT=true -jar ../.github/kolmafia.jar --CLI _ci_dependencies
fi

for ashfile in ${ashfiles}; do
    # Run the verification
    echo "Verifying ${ashfile}..."

    echo "try { cli_execute('verify ${ashfile}'); } finally { cli_execute('exit'); }" > scripts/_ci_verify.ash
    output=$(java -DuseCWDasROOT=true -jar ../.github/kolmafia.jar --CLI _ci_verify)
    if [[ $output == *"Script verification complete." ]]; then
        echo "Verified ${ashfile}!"
        exit 0
    else
        echo $output
        exit 1
    fi
done
