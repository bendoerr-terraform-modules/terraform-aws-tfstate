<br/>
<p align="center">
  <a href="https://github.com/bendoerr-terraform-modules/terraform-aws-tfstate">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://github.com/bendoerr-terraform-modules/terraform-aws-tfstate/raw/main/docs/logo-dark.png">
      <img src="https://github.com/bendoerr-terraform-modules/terraform-aws-tfstate/raw/main/docs/logo-light.png" alt="Logo">
    </picture>
  </a>

<h3 align="center">Ben's Terraform AWS Terraform Remote State Module</h3>

  <p align="center">
    This is how I do it.
    <br/>
    <br/>
    <a href="https://github.com/bendoerr-terraform-modules/terraform-aws-tfstate"><strong>Explore the docs »</strong></a>
    <br/>
    <br/>
    <a href="https://github.com/bendoerr-terraform-modules/terraform-aws-tfstate/issues">Report Bug</a>
    .
    <a href="https://github.com/bendoerr-terraform-modules/terraform-aws-tfstate/issues">Request Feature</a>
  </p>
</p>

[<img alt="GitHub contributors" src="https://img.shields.io/github/contributors/bendoerr-terraform-modules/terraform-aws-tfstate?logo=github">](https://github.com/bendoerr-terraform-modules/terraform-aws-tfstate/graphs/contributors)
[<img alt="GitHub issues" src="https://img.shields.io/github/issues/bendoerr-terraform-modules/terraform-aws-tfstate?logo=github">](https://github.com/bendoerr-terraform-modules/terraform-aws-tfstate/issues)
[<img alt="GitHub pull requests" src="https://img.shields.io/github/issues-pr/bendoerr-terraform-modules/terraform-aws-tfstate?logo=github">](https://github.com/bendoerr-terraform-modules/terraform-aws-tfstate/pulls)
[<img alt="GitHub workflow: Terratest" src="https://img.shields.io/github/actions/workflow/status/bendoerr-terraform-modules/terraform-aws-tfstate/test.yml?logo=githubactions&label=terratest">](https://github.com/bendoerr-terraform-modules/terraform-aws-tfstate/actions/workflows/test.yml)
[<img alt="GitHub workflow: Linting" src="https://img.shields.io/github/actions/workflow/status/bendoerr-terraform-modules/terraform-aws-tfstate/lint.yml?logo=githubactions&label=linting">](https://github.com/bendoerr-terraform-modules/terraform-aws-tfstate/actions/workflows/lint.yml)
[<img alt="GitHub tag (with filter)" src="https://img.shields.io/github/v/tag/bendoerr-terraform-modules/terraform-aws-tfstate?filter=v*&label=latest%20tag&logo=terraform">](https://registry.terraform.io/modules/bendoerr-terraform-modules/label/null/latest)
[<img alt="OSSF-Scorecard Score" src="https://img.shields.io/ossf-scorecard/github.com/bendoerr-terraform-modules/terraform-aws-tfstate?logo=securityscorecard&label=ossf%20scorecard&link=https%3A%2F%2Fsecurityscorecards.dev%2Fviewer%2F%3Furi%3Dgithub.com%2Fbendoerr-terraform-modules%2Fterraform-aws-tfstate">](https://securityscorecards.dev/viewer/?uri=github.com/bendoerr-terraform-modules/terraform-aws-tfstate)
[<img alt="GitHub License" src="https://img.shields.io/github/license/bendoerr-terraform-modules/terraform-aws-tfstate?logo=opensourceinitiative">](https://github.com/bendoerr-terraform-modules/terraform-aws-tfstate/blob/main/LICENSE.txt)

## About The Project

Ben's Terraform AWS TFState Remote Backend Module

## Usage

Start with a simple Terraform project looking something similar to the
following. This module will create the S3 bucket and DynamoDB table you need. A
good practice is to keep this Terraform project simple and check the state data
into your source control.

```terraform
module "context" {
  source    = "bendoerr-terraform-modules/context/null"
  version   = "xxx"
  namespace = "bd"
  role      = "production"
  region    = "us-east-1"
  project   = "tfstate"
}

module "tfstate" {
  source  = "bendoerr-terraform-modules/tfstate/aws"
  version = "xxx"
  context = module.context.shared
}

output "store" {
  value = module.tfstate.tfstate_id # -> bd-prod-ue1-tfstate-store
}

output "lock_table" {
  value = module.tfstate.lock_table_name # -> bd-prod-ue1-tfstate-locks
}
```

In future projects your TF state can be centrally maintained.

```terraform
terraform {
  backend "s3" {
    bucket               = "brd-prod-ue1-tfstate-store"
    dynamodb_table       = "brd-prod-ue1-tfstate-locks"
    key                  = "terraform.tfstate"
    kms_key_id           = "alias/aws/s3"
    region               = "us-east-1"
    workspace_key_prefix = "foundryvtt-on-demand"
  }
}
```

### Cost

<a href="https://dashboard.infracost.io/org/bendoerr/repos/8e371a47-5161-427f-a0b9-e8fb9d7bf2a5?tab=settings"><img src="https://img.shields.io/endpoint?url=https://dashboard.api.infracost.io/shields/json/6e706676-64ba-43db-97b9-bd92f9272474/repos/8e371a47-5161-427f-a0b9-e8fb9d7bf2a5/branch/feee4136-0bbb-4a2e-9874-21543ff6b443" alt="infracost"/></a>

```text
Project: 10 Workspaces & 5 Applies Each Per Day
Module path: examples/complete

 Name                                               Monthly Qty  Unit         Monthly Cost

 module.tfstate.aws_dynamodb_table.locks
 ├─ Write request unit (WRU)                              1,500  WRUs                $0.00
 └─ Read request unit (RRU)                               1,500  RRUs                $0.00

 module.tfstate.module.store.aws_s3_bucket.this[0]
 └─ Standard
    ├─ Storage                                             0.02  GB                  $0.00
    ├─ PUT, COPY, POST, LIST requests                       4.5  1k requests         $0.02
    └─ GET, SELECT, and all other requests                    3  1k requests         $0.00

 OVERALL TOTAL                                                                       $0.03
──────────────────────────────────
9 cloud resources were detected:
∙ 2 were estimated, all of which include usage-based costs, see https://infracost.io/usage-file
∙ 7 were free, rerun with --show-skipped to see details

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━┓
┃ Project                                            ┃ Monthly cost ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━┫
┃ 10 Workspaces & 5 Applies Each Per Day             ┃ $0.03        ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━┛
```

<!-- BEGIN_TF_DOCS -->

### Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 5.0  |

### Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 5.0  |

### Modules

| Name                                                                                   | Source                                | Version |
| -------------------------------------------------------------------------------------- | ------------------------------------- | ------- |
| <a name="module_label_dynamodb_rw"></a> [label_dynamodb_rw](#module_label_dynamodb_rw) | bendoerr-terraform-modules/label/null | 0.4.1   |
| <a name="module_label_locks"></a> [label_locks](#module_label_locks)                   | bendoerr-terraform-modules/label/null | 0.4.1   |
| <a name="module_label_s3_rw"></a> [label_s3_rw](#module_label_s3_rw)                   | bendoerr-terraform-modules/label/null | 0.4.1   |
| <a name="module_label_store"></a> [label_store](#module_label_store)                   | bendoerr-terraform-modules/label/null | 0.4.1   |
| <a name="module_store"></a> [store](#module_store)                                     | terraform-aws-modules/s3-bucket/aws   | 3.15.1  |

### Resources

| Name                                                                                                                                      | Type        |
| ----------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_dynamodb_table.locks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table)                    | resource    |
| [aws_iam_policy.s3_rw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                            | resource    |
| [aws_iam_policy.state_dynamodb_rw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                | resource    |
| [aws_iam_policy_document.dynamodb_rw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_rw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)       | data source |
| [aws_kms_alias.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_alias)                              | data source |

### Inputs

| Name                                                   | Description                                      | Type                                                                                                                                                                                                                                                                                                                      | Default | Required |
| ------------------------------------------------------ | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | :------: |
| <a name="input_context"></a> [context](#input_context) | Shared Context from Ben's terraform-null-context | <pre>object({<br> attributes = list(string)<br> dns_namespace = string<br> environment = string<br> instance = string<br> instance_short = string<br> namespace = string<br> region = string<br> region_short = string<br> role = string<br> role_short = string<br> project = string<br> tags = map(string)<br> })</pre> | n/a     |   yes    |

### Outputs

| Name                                                                                      | Description |
| ----------------------------------------------------------------------------------------- | ----------- |
| <a name="output_iam_locks_rw_arn"></a> [iam_locks_rw_arn](#output_iam_locks_rw_arn)       | n/a         |
| <a name="output_iam_locks_rw_id"></a> [iam_locks_rw_id](#output_iam_locks_rw_id)          | n/a         |
| <a name="output_iam_tfstate_rw_arn"></a> [iam_tfstate_rw_arn](#output_iam_tfstate_rw_arn) | n/a         |
| <a name="output_iam_tfstate_rw_id"></a> [iam_tfstate_rw_id](#output_iam_tfstate_rw_id)    | n/a         |
| <a name="output_lock_table_arn"></a> [lock_table_arn](#output_lock_table_arn)             | n/a         |
| <a name="output_lock_table_id"></a> [lock_table_id](#output_lock_table_id)                | n/a         |
| <a name="output_lock_table_name"></a> [lock_table_name](#output_lock_table_name)          | n/a         |
| <a name="output_tfstate_arn"></a> [tfstate_arn](#output_tfstate_arn)                      | n/a         |
| <a name="output_tfstate_id"></a> [tfstate_id](#output_tfstate_id)                         | n/a         |

<!-- END_TF_DOCS -->

## Roadmap

[<img alt="GitHub issues" src="https://img.shields.io/github/issues/bendoerr-terraform-modules/terraform-aws-tfstate?logo=github">](https://github.com/bendoerr-terraform-modules/terraform-aws-tfstate/issues)

See the
[open issues](https://github.com/bendoerr-terraform-modules/terraform-aws-tfstate/issues)
for a list of proposed features (and known issues).

## Contributing

[<img alt="GitHub pull requests" src="https://img.shields.io/github/issues-pr/bendoerr-terraform-modules/terraform-aws-tfstate?logo=github">](https://github.com/bendoerr-terraform-modules/terraform-aws-tfstate/pulls)

Contributions are what make the open source community such an amazing place to
be learn, inspire, and create. Any contributions you make are **greatly
appreciated**.

- If you have suggestions for adding or removing projects, feel free to
  [open an issue](https://github.com/bendoerr-terraform-modules/terraform-aws-tfstate/issues/new)
  to discuss it, or directly create a pull request after you edit the
  _README.md_ file with necessary changes.
- Please make sure you check your spelling and grammar.
- Create individual PR for each suggestion.

### Creating A Pull Request

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

[<img alt="GitHub License" src="https://img.shields.io/github/license/bendoerr-terraform-modules/terraform-aws-tfstate?logo=opensourceinitiative">](https://github.com/bendoerr-terraform-modules/terraform-aws-tfstate/blob/main/LICENSE.txt)

Distributed under the MIT License. See
[LICENSE](https://github.com/bendoerr-terraform-modules/terraform-aws-tfstate/blob/main/LICENSE.txt)
for more information.

## Authors

[<img alt="GitHub contributors" src="https://img.shields.io/github/contributors/bendoerr-terraform-modules/terraform-aws-tfstate?logo=github">](https://github.com/bendoerr-terraform-modules/terraform-aws-tfstate/graphs/contributors)

- **Benjamin R. Doerr** - _Terraformer_ -
  [Benjamin R. Doerr](https://github.com/bendoerr/) - _Built Ben's Terraform
  Modules_

## Supported Versions

Only the latest tagged version is supported.

## Reporting a Vulnerability

See [SECURITY.md](SECURITY.md).

## Acknowledgements

- [ShaanCoding (ReadME Generator)](https://github.com/ShaanCoding/ReadME-Generator)
- [OpenSSF - Helping me follow best practices](https://openssf.org/)
- [StepSecurity - Helping me follow best practices](https://app.stepsecurity.io/)
- [Infracost - Better than AWS Calculator](https://www.infracost.io/)
