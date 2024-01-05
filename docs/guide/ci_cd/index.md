# CI/CD

## List of supported CI/CD

* [Github actions](https://github.com/features/actions)

## List of available workflows

| Workflow                | Description                                     |
| ----------------------- | ----------------------------------------------- |
| `ansible-lint.yml`      | Lint Ansible configuration                      |
| `doc.yml`               | Deploy generic configuration used by every VM   |
| `kubernetes-lint.yml`   | Lint Kubernetes configuration                   |
| `octodns.yml`           | Lint Octodns and deploy Octodns configuration   |
| `packer-lint.yml`       | Lint Packer configuration                       |
| `renovatebot-check.yml` | Lint Renovatebot configuration                  |
| `terraform-lint.yml`    | Lint Terraform and Terragrunt configuration     |

## Usage

Configuration is stored in `.github/workflows` folder.

Configure the following repository secrets in `Actions secrets and variables` :

* `SCALEWAY_SECRET_KEY`
