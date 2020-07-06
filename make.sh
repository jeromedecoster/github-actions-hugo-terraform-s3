#!/bin/bash

#
# variables
#

# AWS variables
AWS_PROFILE=default
AWS_REGION=eu-west-3
# apex domain name
APEX_DOMAIN=jeromedecoster.net
# terraform
export TF_VAR_project_name=$PROJECT_NAME
export TF_VAR_region=$AWS_REGION
export TF_VAR_profile=$AWS_PROFILE
export TF_VAR_apex_domain=$APEX_DOMAIN

# the directory containing the script file
dir="$(cd "$(dirname "$0")"; pwd)"
cd "$dir"


log()   { echo -e "\e[30;47m ${1^^} \e[0m ${@:2}"; }        # $1 uppercase background white
info()  { echo -e "\e[48;5;28m ${1^^} \e[0m ${@:2}"; }      # $1 uppercase background green
warn()  { echo -e "\e[48;5;202m ${1^^} \e[0m ${@:2}" >&2; } # $1 uppercase background orange
error() { echo -e "\e[48;5;196m ${1^^} \e[0m ${@:2}" >&2; } # $1 uppercase background red


# log $1 in underline then $@ then a newline
under() {
    local arg=$1
    shift
    echo -e "\033[0;4m${arg}\033[0m ${@}"
    echo
}

usage() {
    under usage 'call the Makefile directly: make dev
      or invoke this file directly: ./make.sh dev'
}

# local dev on http://localhost:1313
dev() {
    hugo server \
		--buildDrafts \
		--disableFastRender
}

# build static site to ./public
build() {
    rm public \
		--force \
		--recursive
	hugo
}

upload() {
    cd "$dir/public"
    aws s3 sync --acl public-read . s3://www.jeromedecoster.net
}

tf-init() {
    cd "$dir/infra"
    terraform init
}

tf-validate() {
    cd "$dir/infra"
    terraform fmt -recursive
	terraform validate
}

tf-apply() {
    cd "$dir/infra"
    terraform plan \
        -out=terraform.plan

    terraform apply \
        -auto-approve \
        terraform.plan
}

tf-scale-up() {
    export TF_VAR_desired_count=3
    tf-apply
}

tf-scale-down() {
    export TF_VAR_desired_count=2
    tf-apply
}

tf-destroy() {
    cd "$dir/infra"
    terraform destroy \
        -auto-approve
}

# if `$1` is a function, execute it. Otherwise, print usage
# compgen -A 'function' list all declared functions
# https://stackoverflow.com/a/2627461
FUNC=$(compgen -A 'function' | grep $1)
[[ -n $FUNC ]] && { info execute $1; eval $1; } || usage;
exit 0
