## Why Lint Terraform Code?

Terraform does a great job for infrastructure-as-code, but it doesn't have any built-in testing capabilities. For example, Terraform won't validate vendor-specific issues. One example is if a VM size type is nonexistent and `terraform plan` or `terraform validate` won't find this issue before you build and run the code.

Because of that, a linter can be used.

## TFLint
TFLint is a Terraform linter that runs on static code before the Terraform code is built or run.

## Installation

For Linux:
```
$ curl --location https://github.com/terraform-linters/tflint/releases/download/v0.20.3/tflint_darwin_amd64.zip --output tflint_darwin_amd64.zip
$ unzip tflint_darwin_amd64.zip
Archive:  tflint_darwin_amd64.zip
  inflating: tflint
$ install tflint /usr/local/bin
$ tflint -v
```

For MacOS
```
brew install tflint
```

For Windows
```
choco install tflint
```

## Using TFLint
To run and use TFLint, simply change directory (`cd`) to the location of the Terraform code and run:
```
tflint
```

Any issues that exist will be printed to the console