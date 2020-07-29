# AWS Elasticache Terraform module

Terraform module which creates Elasticache clusters within existing VPC on AWS.

A choice of two types of elasticache backends are supported:

* [Memcached](https://aws.amazon.com/elasticache/memcached/)
* [Redis](https://aws.amazon.com/elasticache/redis/)

The following objects are created by the module:

* [aws_elasticache_parameter_group](https://www.terraform.io/docs/providers/aws/r/aws_elasticache_parameter_group.html)
* [aws_elasticache_cluster](https://www.terraform.io/docs/providers/aws/r/aws_elasticache_cluster.html)
* [aws_elasticache_replication_group](https://www.terraform.io/docs/providers/aws/r/aws_elasticache_replication_group.html)
* [aws_security_group](https://www.terraform.io/docs/providers/aws/r/aws_security_group.html)
* [aws_security_group_rule](https://www.terraform.io/docs/providers/aws/r/aws_security_group_rule.html)
* [aws_route53_record](https://www.terraform.io/docs/providers/aws/r/aws_route53_record.html)

## Terraform versions

Terraform 0.12. Pin module version to `~> v2.0`. Submit pull-requests to `master` branch.

Terraform 0.11. Pin module version to `~> v1.0`. Submit pull-requests to `terraform011` branch.

## Usage

To create a Memcached cluster:

```hcl
module "memcached-nonprod" {
  source                    = "github.com/InnovateUKGitHub/terraform-module-elasticache"
  enable_elasticache        = var.enable_elasticache_nonprod
  deploy_env                = var.deploy_env
  vpc_id                    = data.terraform_remote_state.vpc.vpc_id
  local_dns_domain_zone_id  = aws_route53_zone.local_private.zone_id
  elasticache_clients_sgs   = [aws_security_group.openshift-compute-node.id, aws_security_group.bastion.id]
  subnet_group_name         = data.terraform_remote_state.vpc.elasticache_subnet_group_name
  purpose                   = "nonprod"
  elasticache_multi_az      = true
  notification_topic_arn    = aws_sns_topic.ElastiCache-Events.arn
  elasticache_instance_type = var.elasticache_nonprod_instance_size
  elasticache_family        = "memcached1.4"
  num_elasticache_instances = 2
}

output "elasticache_memcached_nonprod_cluster_address" {
  value = module.memcached-nonprod.cluster_address
}

output "elasticache_memcached_nonprod_cluster_alias" {
  value = module.memcached-nonprod.cluster_alias
}
```

To create a Redis cluster:

```hcl
module "redis-nonprod" {
  source                     = "github.com/InnovateUKGitHub/terraform-module-elasticache"
  enable_elasticache         = var.enable_elasticache_nonprod
  deploy_env                 = var.deploy_env
  vpc_id                     = data.terraform_remote_state.vpc.vpc_id
  local_dns_domain_zone_id   = aws_route53_zone.local_private.zone_id
  elasticache_clients_sgs    = [aws_security_group.openshift-compute-node.id, aws_security_group.bastion.id]
  elasticache_family         = "redis5.0"
  elasticache_engine         = "redis"
  elasticache_engine_version = "5.0.5"
  subnet_group_name          = data.terraform_remote_state.vpc.elasticache_subnet_group_name
  purpose                    = "nonprod-redis"
  elasticache_multi_az       = false
  notification_topic_arn     = aws_sns_topic.ElastiCache-Events.arn
  elasticache_instance_type  = var.elasticache_prod_instance_size
  num_elasticache_instances  = 2
  elasticache_password       = "Password for the service goes here?"
}

output "elasticache_redis_nonprod_cluster_address" {
  value = module.redis-nonprod.cluster_address
}

output "elasticache_redis_nonprod_cluster_alias" {
  value = module.redis-nonprod.cluster_alias
}
```

## Conditional creation

Sometimes you need to have a way to create module resources conditionally but Terraform does not allow to use `count` inside `module` block, so the solution is to specify argument `enable_elasticache`.

```hcl
# This Elasticache will not be created
module "vpc" {
  source = "InnovateUKGitHub/terraform-module-elasticache"

  enable_elasticache = false
  # ... omitted
}
```

## Inputs

| Name                              | Description                                                                        |  Type   |      Default       | Required |
| --------------------------------- | ---------------------------------------------------------------------------------- | :-----: | :----------------: | :------: |
| deploy_env                        | Deployment Environment. Forms part of the unique namespace given to resources      | string  |                    |   yes    |
| vpc\_id                           | ID of the VPC to host the elasticache                                              | string  |                    |   yes    |
| subnet\_group\_name               | Subnet group for elasticache                                                       | string  |                    |   yes    |
| notification\_topic\_arn          | An Amazon Resource Name (ARN) of an SNS topic to send ElastiCache notifications to | string  |                    |   yes    |
| purpose                           | Name to add for uniqueness, eg, prod or nonprod                                    | string  |    `"nonprod"`     |    no    |
| enable\_elasticache               | Boolean flag to enable or disable elasticache deploy                               | boolean |       `true`       |    no    |
| elasticache\_clients\_sgs         | Array of SG ids from which to allow access to Elasticache                          |  list   |        `[]`        |    no    |
| elasticache\_family               | Elasticache family, eg, redis or memcache                                          | string  |  `"memcached1.4"`  |    no    |
| elasticache\_engine               | Which engine to use for elasticache (redis/memcached)                              | string  |   `"memcached"`    |    no    |
| elasticache\_port                 | Which port to use for elasticache (redis/memcached)                                | string  |     `"11211"`      |    no    |
| elasticache\_engine\_version      | Engine version for elasticache                                                     | string  |     `"1.4.34"`     |    no    |
| elasticache\_instance\_type       | Instance type for elasticache                                                      | string  | `"cache.t2.small"` |    no    |
| elasticache_multi_az              | Enable multi AZ                                                                    | boolean |      `false`       |    no    |
| elasticache\_password             | Password for elasticache                                                           | string  |        `""`        |    no    |
| num\_elasticache\_instances       | Number of elasticache instances                                                    | string  |       `"2"`        |    no    |
| redis\_replicas\_per\_node\_group | Redis setting for number of replicas per node group                                | string  |       `"1"`        |    no    |
| dns\_record\_ttl                  | Time To Live for DNS Alias record                                                  | string  |       `"60"`       |    no    |
| local\_dns\_domain\_zone\_id      | ZoneID for Route53 localzone to create record for ealasticache                     | string  |                    |    no    |

## Outputs

| Name             | Description                                                                      |
| ---------------- | -------------------------------------------------------------------------------- |
| cluster\_address | Cluster/Config fqdn address of elasticache                                       |
| cluster\_alias   | Alias to Cluster/Config fqdn address of elasticache created in supplied DNS zone |

## Authors

Module is maintained by [Innovate UK](https://github.com/InnovateUKGitHub).

## License

MIT Licensed. See LICENSE for full details.