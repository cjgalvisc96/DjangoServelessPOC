output "tracetech_traces_aurora_cluster_instance_urls" {
  value = [
    for idx in range(length(aws_rds_cluster_instance.tracetech_traces_rds_cluster_instances)) : 
      format(
        "%s:%s",
        aws_rds_cluster_instance.tracetech_traces_rds_cluster_instances[idx].endpoint,
        aws_rds_cluster_instance.tracetech_traces_rds_cluster_instances[idx].port
      )
  ]
}