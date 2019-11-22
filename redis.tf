resource "aws_elasticache_parameter_group" "redis" {
  count  = "${var.enable_elasticache && substr(var.elasticache_family, 0, 5) == "redis" ? 1 : 0}"
  name   = "${var.deploy_env}-elasticache-parms-${var.purpose}"
  family = "${var.elasticache_family}"

  parameter {
    name  = "cluster-enabled"
    value = "yes"
  }
}

resource "aws_elasticache_replication_group" "redis" {
  count                         = "${var.enable_elasticache && substr(var.elasticache_family, 0, 5) == "redis" ? 1 : 0}"
  replication_group_id          = "${var.deploy_env}-${var.purpose}"
  replication_group_description = "Replication group"
  node_type                     = "${var.elasticache_instance_type}"
  port                          = 6379
  parameter_group_name          = "${aws_elasticache_parameter_group.redis.name}"
  automatic_failover_enabled    = true
  subnet_group_name             = "${var.subnet_group_name}"
  at_rest_encryption_enabled    = true
  transit_encryption_enabled    = true
  apply_immediately             = true
  auth_token                    = "${var.elasticache_password}"
  notification_topic_arn        = "${var.notification_topic_arn}"
  security_group_ids            = ["${aws_security_group.elasticache.id}"]

  cluster_mode {
    replicas_per_node_group = "${var.redis_replicas_per_node_group}"
    num_node_groups         = "${var.num_elasticache_instances / 2 }"
  }
}
