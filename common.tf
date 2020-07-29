locals {
  desired_ec_name = join("-", [var.deploy_env, var.purpose])
  ec_name = substr(
    local.desired_ec_name,
    0,
    min(length(local.desired_ec_name), 20),
  )
}

resource "aws_security_group" "elasticache" {
  count       = var.enable_elasticache ? 1 : 0
  name        = "${var.deploy_env}-elasticache-${var.purpose}"
  description = "Elasticache"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.deploy_env}-sg-elasticache"
    Purpose = var.purpose
  }
}

resource "aws_security_group_rule" "elasticache" {
  count = var.enable_elasticache ? length(var.elasticache_clients_sgs) : 0
  type  = "ingress"
  from_port = element(
    coalescelist(
      aws_elasticache_cluster.memcached.*.port,
      aws_elasticache_replication_group.redis.*.port,
    ),
    0,
  )
  to_port = element(
    coalescelist(
      aws_elasticache_cluster.memcached.*.port,
      aws_elasticache_replication_group.redis.*.port,
    ),
    0,
  )
  protocol                 = "tcp"
  security_group_id        = aws_security_group.elasticache[0].id
  source_security_group_id = element(var.elasticache_clients_sgs, count.index)
  description              = "${substr(var.elasticache_family, 0, 5) == "memca" ? "Memcached" : "Redis"} access"
}

resource "aws_route53_record" "elasticache" {
  count   = var.enable_elasticache && length(var.local_dns_domain_zone_id) > 0 ? 1 : 0
  zone_id = var.local_dns_domain_zone_id
  name    = "elasticache-${var.purpose}"
  type    = "CNAME"
  ttl     = var.dns_record_ttl
  records = element(
    coalescelist(
      aws_elasticache_cluster.memcached.*.cluster_address,
      aws_elasticache_replication_group.redis.*.configuration_endpoint_address,
    ),
    0,
  )
}
