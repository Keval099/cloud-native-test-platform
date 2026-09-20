resource "aws_cloudwatch_dashboard" "eks_observability" {
  dashboard_name = "cloud-native-test-platform"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "EKS Node CPU Utilization"
          region = "ap-south-1"
          period = 300
          stat   = "Average"

          metrics = [
            [
              "ContainerInsights",
              "node_cpu_utilization",
              "ClusterName",
              "cloud-native-test-platform"
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "EKS Pod CPU Utilization"
          region = "ap-south-1"
          period = 300
          stat   = "Average"

          metrics = [
            [
              "ContainerInsights",
              "pod_cpu_utilization",
              "ClusterName",
              "cloud-native-test-platform"
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "EKS Pod Memory Utilization"
          region = "ap-south-1"
          period = 300
          stat   = "Average"

          metrics = [
            [
              "ContainerInsights",
              "pod_memory_utilization",
              "ClusterName",
              "cloud-native-test-platform"
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "EKS Failed Nodes"
          region = "ap-south-1"
          period = 300
          stat   = "Maximum"

          metrics = [
            [
              "ContainerInsights",
              "cluster_failed_node_count",
              "ClusterName",
              "cloud-native-test-platform"
            ]
          ]
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "eks_failed_nodes" {
  alarm_name        = "cloud-native-test-platform-failed-nodes"
  alarm_description = "Triggers when an EKS worker node is reported as failed."
  namespace         = "ContainerInsights"
  metric_name       = "cluster_failed_node_count"
  dimensions = {
    ClusterName = "cloud-native-test-platform"
  }

  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "eks_node_cpu" {
  alarm_name        = "cloud-native-test-platform-node-cpu"
  alarm_description = "Triggers when average EKS node CPU exceeds 80%."
  namespace         = "ContainerInsights"
  metric_name       = "node_cpu_utilization"

  dimensions = {
    ClusterName = "cloud-native-test-platform"
  }

  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 80
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"
}