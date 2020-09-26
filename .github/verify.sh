#!/bin/bash

scriptsfiles=
if [ -d "scripts/" ]; then
    cd scripts/
    scriptsfiles=$(ls *.ash)
    cd ..
else
    mkdir "scripts/"
fi

relayfiles=
if [ -d "relay/" ]; then
    cd relay/
    relayfiles=$(ls *.ash)
    cd ..
fi

if [[ -f "dependencies.txt" ]]; then
    # Install dependencies
    echo "Installing dependencies..."

    output_file="scripts/_ci_dependencies.ash"
    echo "try {" > "$output_file"
    while read -r line || [ -n "$line" ]; do
        echo "cli_execute('svn checkout ${line}');" >> "$output_file"
    done < "dependencies.txt"
    echo "} finally { cli_execute('exit'); }" >> "$output_file"
    java -DuseCWDasROOT=true -jar ../.github/kolmafia.jar --CLI _ci_dependencies
fi

errors=0
for ashfile in ${scriptsfiles}; do
    # Run the verification
    echo "Verifying ${ashfile}..."

    echo "try { cli_execute('verify ${ashfile}'); } finally { cli_execute('exit'); }" > scripts/_ci_verify.ash
    output=$(java -DuseCWDasROOT=true -jar ../.github/kolmafia.jar --CLI _ci_verify)
    if [[ $output == *"Script verification complete." ]]; then
        echo "Verified ${ashfile}!"
    else
        echo $output
        errors=$((errors+1))
    fi
done

for ashfile in ${relayfiles}; do
    # Run the verification
    echo "Verifying ${ashfile}..."

    echo "try { cli_execute('verify ${ashfile}'); } finally { cli_execute('exit'); }" > scripts/_ci_verify.ash
    output=$(java -DuseCWDasROOT=true -jar ../.github/kolmafia.jar --CLI _ci_verify)
    if [[ $output == *"Script verification complete." ]]; then
        echo "Verified ${ashfile}!"
    else
        echo $output
        ((errors+=1))
    fi
done

exit ${errors}
