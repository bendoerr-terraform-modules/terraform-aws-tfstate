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
[<img alt="GitHub tag (with filter)" src="https://img.shields.io/github/v/tag/bendoerr-terraform-modules/terraform-aws-tfstate?filter=v*&label=latest%20tag&logo=terraform">](https://github.com/bendoerr-terraform-modules/terraform-aws-tfstate/tags)
[<img alt="OSSF-Scorecard Score" src="https://img.shields.io/ossf-scorecard/github.com/bendoerr-terraform-modules/terraform-aws-tfstate?logo=securityscorecard&label=ossf%20scorecard&link=https%3A%2F%2Fsecurityscorecards.dev%2Fviewer%2F%3Furi%3Dgithub.com%2Fbendoerr-terraform-modules%2Fterraform-aws-tfstate">](https://securityscorecards.dev/viewer/?uri=github.com/bendoerr-terraform-modules/terraform-aws-tfstate)
[<img alt="GitHub License" src="https://img.shields.io/github/license/bendoerr-terraform-modules/terraform-aws-tfstate?logo=opensourceinitiative">](https://github.com/bendoerr-terraform-modules/terraform-aws-tfstate/blob/main/LICENSE.txt)

## About The Project

Ben's Terraform AWS TFState Remote Backend Module

## Usage

Start with a basic Terraform project that looks similar to the following. This
module creates the S3 bucket your remote state lives in. Locking is handled by
the S3 backend's native lockfile mechanism (Terraform v1.10+, GA in v1.11,
via `use_lockfile = true`); this module provisions no DynamoDB table. A
good practice is to keep this Terraform project minimal and check the Terraform
configuration into your source control.

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
  value = module.tfstate.bucket_id # -> bd-prod-ue1-tfstate-store
}
```

In future projects your TF state can be centrally maintained.

```terraform
terraform {
  backend "s3" {
    bucket               = "brd-prod-ue1-tfstate-store"
    key                  = "terraform.tfstate"
    kms_key_id           = "alias/aws/s3"
    region               = "us-east-1"
    use_lockfile         = true
    workspace_key_prefix = "foundryvtt-on-demand"
  }
}
```

### Locking strategy

This module uses S3 native state locking. Terraform writes a
`<state-key>.tflock` object next to the state object in the same bucket, using
S3 conditional writes for mutual exclusion, and deletes it on unlock. No
DynamoDB table is involved. Consumers set `use_lockfile = true` in their
`backend "s3"` block. Terraform v1.10 introduced it and v1.11 made it
generally available, so v1.11 or later is recommended.

The identity your backend uses needs `s3:GetObject`, `s3:PutObject` and
`s3:DeleteObject` on the `.tflock` object. The `iam_store_rw_*` policy this
module creates already grants all three.

### Upgrading to v2.0.0

v2.0.0 **removes** the legacy DynamoDB locking path: the lock table, its IAM
policy, the `enable_legacy_dynamodb_locking` and `dynamodb_kms_key_arn` inputs,
and the `lock_table_*` and `iam_locks_rw_*` outputs.

**First, find out whether your state holds the lock table.** Don't go by
whether you ever set a flag: in v0.x the table was created unconditionally and
the flag did not exist.

```shell
terraform state list > state.txt || echo "state list FAILED - fix that first; no answer yet"
grep -E 'aws_dynamodb_table\.locks|aws_iam_policy\.locks_rw' state.txt
```

Check that the first command succeeded. A failed `state list` (for example in
an uninitialised directory) leaves an empty file, which reads exactly like
"No matches".

**No matches** (v1.x with the legacy flag off):

1. Remove `enable_legacy_dynamodb_locking` and `dynamodb_kms_key_arn` from your
   `module` block if you set them at all, even to `false` or `null`. v2 rejects
   them as unexpected arguments.
1. Remove every reference to the removed outputs, including null-tolerant
   ones such as `try(module.tfstate.lock_table_arn, null)`. v2 rejects them as
   unsupported attributes.
1. Upgrade, plan, and expect no changes from this module.

**Matches** (v0.x, or v1.x with the legacy flag on): upgrading drops the table
and its policy from your configuration, which Terraform plans as a **destroy**.
Before you upgrade:

1. Move every backend that uses the table to S3 native locking, in two steps,
   so nothing ever runs with only one of the two locks:

   1. Add `use_lockfile = true` **alongside** the existing `dynamodb_table`,
      and run `terraform init -reconfigure` everywhere that configuration runs
      (CI runners and every teammate's checkout).
   1. Once all of them are on that config, remove `dynamodb_table` and run
      `terraform init -reconfigure` again everywhere.

1. Remove the two inputs and every reference to the removed outputs, as above.

1. Either retire the table on purpose, or keep it out of Terraform's hands
   with `removed` blocks (Terraform v1.7+) so the upgrade forgets it without
   destroying it. Set each `from` to the address the `grep` above printed,
   minus any `[0]`. The example uses `module.tfstate`; yours is whatever you
   named the module. A `from` that matches nothing does nothing, and the
   destroy goes ahead.

   ```terraform
   removed {
     from = module.tfstate.aws_dynamodb_table.locks
     lifecycle {
       destroy = false
     }
   }

   removed {
     from = module.tfstate.aws_iam_policy.locks_rw
     lifecycle {
       destroy = false
     }
   }
   ```

   Both blocks are needed when both resources exist: with only the first, the
   plan still shows `1 to destroy` for the policy. If you would rather delete
   the policy, drop the second block and first detach it from anything that
   uses it (another configuration attaching `iam_locks_rw_arn` makes the delete
   fail with `DeleteConflict`).

1. Plan and confirm **0 to destroy** before you apply.

Until then, stay on `~> 1.0`. See
<https://developer.hashicorp.com/terraform/language/backend/s3> for the
upstream docs.

### Cost

<a href="https://dashboard.infracost.io/org/bendoerr/repos/8e371a47-5161-427f-a0b9-e8fb9d7bf2a5?tab=settings"><img src="https://img.shields.io/endpoint?url=https://dashboard.api.infracost.io/shields/json/6e706676-64ba-43db-97b9-bd92f9272474/repos/8e371a47-5161-427f-a0b9-e8fb9d7bf2a5/branch/feee4136-0bbb-4a2e-9874-21543ff6b443" alt="infracost"/></a>

Abridged from a v1.x run: the DynamoDB lock-table lines (which cost $0.00)
and the resource-count footer are removed, so the totals are unchanged.

```text
Project: 10 Workspaces & 5 Applies Each Per Day
Module path: examples/complete

 Name                                               Monthly Qty  Unit         Monthly Cost

 module.tfstate.module.store.aws_s3_bucket.this[0]
 └─ Standard
    ├─ Storage                                             0.02  GB                  $0.00
    ├─ PUT, COPY, POST, LIST requests                       4.5  1k requests         $0.02
    └─ GET, SELECT, and all other requests                    3  1k requests         $0.00

 OVERALL TOTAL                                                                       $0.03

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━┓
┃ Project                                            ┃ Monthly cost ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━┫
┃ 10 Workspaces & 5 Applies Each Per Day             ┃ $0.03        ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━┛
```

## Version Constraints

This module uses **pessimistic version constraints** (`~>`) for its providers to
ensure predictable behavior across deployments:

```hcl
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 6.0" # Allows 6.x, prevents 7.0
  }
}
```

**Why pessimistic constraints?**

- Prevents unexpected breaking changes from major provider updates
- Ensures consistent behavior across environments
- Makes upgrade impact predictable and controllable

When AWS provider v7.0 releases, this module will require an update to support it.
That is intentional — we prefer explicit, tested upgrades over automatic major
version bumps.

For consuming this module, you can use any AWS provider version that satisfies both
your requirements and this module's constraints. Terraform's dependency resolver
will find a compatible version automatically.

<!-- BEGIN_TF_DOCS -->

### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.10.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | ~> 6.0 |

### Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 6.0 |

### Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_label_store"></a> [label_store](#module_label_store) | bendoerr-terraform-modules/label/null | 1.0.1 |
| <a name="module_label_store_rw"></a> [label_store_rw](#module_label_store_rw) | bendoerr-terraform-modules/label/null | 1.0.1 |
| <a name="module_store"></a> [store](#module_store) | terraform-aws-modules/s3-bucket/aws | 5.16.1 |

### Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_policy.store_rw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_document.store_rw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_context"></a> [context](#input_context) | Shared Context from Ben's terraform-null-context | <pre>object({<br/>    attributes     = list(string)<br/>    dns_namespace  = string<br/>    environment    = string<br/>    instance       = string<br/>    instance_short = string<br/>    namespace      = string<br/>    region         = string<br/>    region_short   = string<br/>    role           = string<br/>    role_short     = string<br/>    project        = string<br/>    tags           = map(string)<br/>  })</pre> | n/a | yes |
| <a name="input_s3_kms_key_arn"></a> [s3_kms_key_arn](#input_s3_kms_key_arn) | The ARN of a customer-managed AWS KMS key to use for server-side encryption of the S3 Terraform state bucket. When null, the AWS-managed S3 default key (aws/s3) is used. | `string` | `null` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_bucket_arn"></a> [bucket_arn](#output_bucket_arn) | The S3 bucket ARN where the state will be stored. |
| <a name="output_bucket_id"></a> [bucket_id](#output_bucket_id) | The S3 bucket ID where the state will be stored. |
| <a name="output_iam_store_rw_arn"></a> [iam_store_rw_arn](#output_iam_store_rw_arn) | The ARN of the IAM policy granting read/write access to the Terraform state S3 bucket. |
| <a name="output_iam_store_rw_id"></a> [iam_store_rw_id](#output_iam_store_rw_id) | The ID of the IAM policy granting read/write access to the Terraform state S3 bucket. |

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
1. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
1. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
1. Push to the Branch (`git push origin feature/AmazingFeature`)
1. Open a Pull Request

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
