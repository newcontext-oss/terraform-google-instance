# Google compute instance Terraform module

Terraform module which creates a Google compute instance within
the default networking of an existing project.

## Features

Deploys a Google compute instance to the existing networking of
an existing Google cloud project.

## Usage

Call it as a module and deploy the instance.

```hcl
module "terraform-google-instance" {
  source = "git@github.com:newcontext-oss/terraform-google-instance.git"
}
```

## Authors

Module managed by [Nick Willever](https://github.com/nictrix).

## License

Apache 2 Licensed. See LICENSE for full details.
