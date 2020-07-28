output "cluster_address" {
  value = element(
    coalescelist(
      aws_elasticache_cluster.memcached.*.cluster_address,
      aws_elasticache_replication_group.redis.*.configuration_endpoint_address,
      [""],
    ),
    0,
  )
}

output "cluster_alias" {
  value = element(coalescelist(aws_route53_record.elasticache.*.fqdn, [""]), 0)
}

