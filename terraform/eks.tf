resource "aws_eks_cluster" "main" {
  name     = "cloud-native-test-platform"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.36"

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids = [
      aws_subnet.app_a.id,
      aws_subnet.app_b.id
    ]

    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name      = "cloud-native-test-platform"
    ManagedBy = "Terraform"
  }
}

resource "aws_eks_node_group" "app" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "cloud-native-app-nodes"
  node_role_arn   = aws_iam_role.eks_node.arn

  subnet_ids = [
    aws_subnet.app_a.id,
    aws_subnet.app_b.id
  ]

  instance_types = ["t3.medium"]

  disk_size = 20

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.ecr_pull_policy
  ]

  tags = {
    Name      = "cloud-native-app-nodes"
    ManagedBy = "Terraform"
  }
}

resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = "arn:aws:iam::825765413460:role/GitHubActions-EKS-CloudNativeTestPlatform"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_actions" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_eks_access_entry.github_actions.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type = "namespace"
    namespaces = [
      "default"
    ]
  }
}