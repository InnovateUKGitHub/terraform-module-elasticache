resource "aws_elasticache_parameter_group" "memcached" {
  count  = "${var.enable_elasticache && substr(var.elasticache_family, 0, 5) == "memca" ? 1 : 0}"
  name   = "${var.deploy_env}-elasticache-parms-${var.purpose}"
  family = "${var.elasticache_family}"
}

resource "aws_elasticache_cluster" "memcached" {
  count                  = "${var.enable_elasticache && substr(var.elasticache_family, 0, 5) == "memca" ? 1 : 0}"
  cluster_id             = "${local.ec_name}"
  engine                 = "${var.elasticache_engine}"
  engine_version         = "${var.elasticache_engine_version}"
  node_type              = "${var.elasticache_instance_type}"
  num_cache_nodes        = "${var.num_elasticache_instances}"
  parameter_group_name   = "${aws_elasticache_parameter_group.memcached.name}"
  port                   = "${var.elasticache_port}"
  subnet_group_name      = "${var.subnet_group_name}"
  az_mode                = "${var.elasticache_multi_az ? "cross-az" : "single-az"}"
  notification_topic_arn = "${var.notification_topic_arn}"
  security_group_ids     = ["${aws_security_group.elasticache.id}"]
}
