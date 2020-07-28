variable "deploy_env" {
  description = "Deployment Environment. Forms part of the unique namespace given to resources"
}

variable "dns_record_ttl" {
  description = "Time To Live for DNS Alias record"
  default     = "60"
}

variable "local_dns_domain_zone_id" {
  description = "ZoneID for Route53 localzone to create record for ealasticache"
  default     = ""
}

variable "elasticache_clients_sgs" {
  description = "Array of SG ids from which to allow access to Elasticache"
  default     = []
}

variable "purpose" {
  description = "Name to add for uniqueness, eg, prod or nonprod"
  default     = "nonprod"
}

variable "elasticache_family" {
  description = "Elasticache family, eg, redis or memcache"
  default     = "memcached1.4"
}

variable "enable_elasticache" {
  description = "Boolean flag to enable or disable elasticache deploy"
  default     = true
}

variable "elasticache_engine" {
  description = "Which engine to use for elasticache (redis/memcached)"
  default     = "memcached"
}

variable "elasticache_port" {
  description = "Which port to use for elasticache (redis/memcached)"
  default     = "11211"
}

variable "elasticache_engine_version" {
  description = "Engine version for elasticache"
  default     = "1.4.34"
}

variable "elasticache_instance_type" {
  description = "Instance type for elasticache"
  default     = "cache.t2.small"
}

variable "num_elasticache_instances" {
  description = "Number of elasticache instances"
  default     = "2"
}

variable "elasticache_multi_az" {
  description = "Enable multi AZ (boolean)"
  default     = false
}

variable "notification_topic_arn" {
  description = "An Amazon Resource Name (ARN) of an SNS topic to send ElastiCache notifications to"
}

variable "vpc_id" {
  description = "ID of the VPC to host the elasticache (string)"
}

variable "elasticache_password" {
  description = "Password for elasticache (string)"
  default     = ""
}

variable "subnet_group_name" {
  description = "Subnet group for elasticache (string)"
}

variable "redis_replicas_per_node_group" {
  description = "Redis setting for number of replicas per node group (string)"
  default     = "1"
}

