function error_exit
{
    echo "$1" 1>&2
    exit 1
}

function load_config
{
   if [ ! -f 'etc/config' ]; then
       error_exit "No config file found, please copy etc/config.template to etc/config and adjust options"
   fi 
   source "etc/config"
}

function deploy
{
   kubectl create -f $1 >/dev/null || error_exit "Error deploying ${1}"
}

function delete
{
        kubectl delete -f $1 >/dev/null || echo "Error deleteing ${1}, continuing"
}

