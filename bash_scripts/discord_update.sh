#!/bin/bash
calculate_new_version() {
    new_version=$(sed -n "/version/s/^.* \"\(.*\)\"/\1/p" $1 | 
        awk '{
            split ($0, arr, ".");
            arr[3]++; 
            res=arr[1]; 
            for (i=2; i < length(arr) + 1; i++) 
                res = res "." arr[i]; 
            print res
        }')
}

test_mode=2

if (($test_mode == 1)) 
then
    cat /opt/discord/resources/build_info.json > example.j
    calculate_new_version example.j
    sed -in "/version/s/\:\s*\".*\"/\: \"$new_version\"/" example.j   
    cat example.j
    rm example.j
else 
    cd $(file $(which discord) | 
        sed 's/^.*link to \(\/.*\)\/[a-zA-Z]*$/\1\/resources/')
    calculate_new_version build_info.json
    sudo sed -in "/version/s/\:\s*\".*\"/\: \"$new_version\"/" build_info.json
fi

