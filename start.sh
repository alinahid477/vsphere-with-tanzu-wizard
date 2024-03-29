name=$1
forcebuild=$2
if [[ $name == "forcebuild" ]]
then
    name=''
    forcebuild='forcebuild'
fi

if [[ -z $name ]]
then
    printf "\nassuming default name is: merlinvspherewithtanzu\n"
    name='merlinvspherewithtanzu'
fi

isexist=$(ls Dockerfile)
if [[ -z $isexist ]]
then
    numberoftarfound=$(find binaries/*tar* -type f -printf "." | wc -c)
    if [[ $numberoftarfound == 1 ]]
    then
        tanzubundlename=$(find binaries/*tar* -printf "%f\n")
    fi
    if [[ $numberoftarfound -gt 1 ]]
    then
        printf "\nfound more than 1 tar files..\n"
        find ./*tar* -printf "%f\n"
        printf "Error: only 1 tar file for tanzu cli is allowed in ~/binaries dir.\n"
        printf "\n\n"
        exit 1
    fi

    if [[ $numberoftarfound -lt 1 ]]
    then
        printf "\n\n\nNo tanzu cli bundle found." 
        printf "\nTanzu cli is needed for installing extension packages (eg: prometheus, cert-manager etc)."
        printf "\nConsider placing the tanzu cli tar file for installing the addons as tanzu extensions in binaries dir"
        printf "\n**You must perform \"./start.sh forcebuild\" if you do so to generate the new image with tanzu cli.**"
        printf "\n\n\n"

        printf "\nThe wizard will continue without the cli"
    fi

    if [[ $tanzubundlename == "tce"* ]]
    then
        printf "\nERROR: tce detected..\ntce tanzu cli is not supported. Please remove the tar file. exit...\n"
        exit 1
    else
        if [[ $tanzubundlename == "tanzu"* ]]
        then
            printf "\ntanzu cli tar file detected..\n"
            cp Dockerfile.tanzucli Dockerfile
        else
            cp Dockerfile.lean Dockerfile
        fi
    fi
fi

isexists=$(docker images | grep "\<$name\>")
if [[ -z $isexists || $forcebuild == "forcebuild" ]]
then
    docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) . -t $name
fi
# -v ${PWD}:/root/
docker run -it --rm -v ${PWD}/shared:/home/shared -v /var/run/docker.sock:/var/run/docker.sock --privileged --add-host kubernetes:127.0.0.1 --name $name $name