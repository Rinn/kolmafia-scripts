#!/bin/bash

ashfiles=
if [ -d "scripts/" ]; then
    cd scripts/
    ashfiles=${ashfiles} $(ls *.ash)
    cd ..
fi

if [ -d "relay/" ]; then
    cd relay/
    ashfiles=${ashfiles} $(ls *.ash)
    cd ..
fi

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

errors=0
for ashfile in ${ashfiles}; do
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
