#!/bin/sh -l

echo "kubectl create secret generic $1 --dry-run=client \\" > kubecmd.sh

# if generic secret
if [ ! -z "$3" ]; then
    echo "$3" >> data.txt

    while IFS="" read -r s || [ -n "$s" ]
    do
        name=$(echo $s | cut -d ':' -f 1)
        value=$(echo $s | cut -d ':' -f 2-)
        echo "--from-literal=$name=\"$value\" \\" >> kubecmd.sh
    done < data.txt

    echo "-n $2 -o yaml" >> kubecmd.sh

# if basic auth
elif [ ! -z "$4" ]; then
    username=$(echo $4 | cut -d ':' -f 1)
    password=$(echo $4 | cut -d ':' -f 2-)

    echo "--from-literal=username=\"$username\" \\" >> kubecmd.sh
    echo "--from-literal=password=\"$password\" \\" >> kubecmd.sh

    echo "--type kubernetes.io/basic-auth -n $2 -o yaml" >> kubecmd.sh

# if configmap env
elif [ ! -z "$5" ]; then
    echo "kubectl create configmap $1 --dry-run=client \\" > kubecmd.sh

    echo "$5" >> data.txt

    while IFS="" read -r s || [ -n "$s" ]
    do
        name=$(echo $s | cut -d ':' -f 1)
        value=$(echo $s | cut -d ':' -f 2-)
        echo "--from-literal=$name=\"$value\" \\" >> kubecmd.sh
    done < data.txt

    echo "-n $2 -o yaml" >> kubecmd.sh

else
    echo "Please use one of secrets, basic_auth, or configmap_env"
fi

chmod +x kubecmd.sh

# add any annotations passed in
if [ -z $6 ]; then
    ./kubecmd.sh >> finalresource.yml
else
    ./kubecmd.sh >> resource.yml
    echo "$6" > annotations.yml

    yq '.metadata.annotations = load("annotations.yml")' resource.yml > finalresource.yml
fi

# add any labels passed in
if [ -z $7 ]; then
    ./kubecmd.sh >> finalresource.yml
else
    ./kubecmd.sh >> resource2.yml
    echo "$7" > annotations.yml

    yq '.metadata.annotations = load("annotations.yml")' resource2.yml > finalresource.yml
fi

echo 'out_yaml<<EOF' >> $GITHUB_OUTPUT
cat finalresource.yml >> $GITHUB_OUTPUT
echo "EOF" >> $GITHUB_OUTPUT