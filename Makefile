.SILENT:

help:
	{ grep --extended-regexp '^[a-zA-Z_-]+:.*#[[:space:]].*$$' $(MAKEFILE_LIST) || true; } \
	| awk 'BEGIN { FS = ":.*#[[:space:]]*" } { printf "\033[1;32m%-12s\033[0m%s\n", $$1, $$2 }'

dev: # local dev on http://localhost:1313
	./make.sh dev

build: # build static site to ./public
	./make.sh build

upload: # upload to s3
	./make.sh upload


tf-init: # terraform init
	./make.sh tf-init

tf-validate: # terraform validate
	./make.sh tf-validate

tf-apply: # terraform plan + apply
	./make.sh tf-apply

tf-destroy: # terraform destroy
	./make.sh tf-destroy