resource "aws_kms_key" "eks" {
  description             = "EKS secrets encryption key"
  enable_key_rotation     = true
  deletion_window_in_days = 10
}

resource "aws_iam_role" "eks-cluster" {
  name = "eks-cluster-${var.cluster_name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "amazon-eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks-cluster.arn
  vpc_config.endpoint_public_access = false

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  vpc_config {
    subnet_ids = [
      aws_subnet.private-us-east-2a.id,
      aws_subnet.private-us-east-2b.id,
      aws_subnet.public-us-east-2a.id,
      aws_subnet.public-us-east-2b.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.amazon-eks-cluster-policy]
}

data "aws_iam_policy_document" "nodes_kms" {
  statement {
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_key.eks.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "nodes_kms" {
  name        = "eks-nodes-kms"
  policy      = data.aws_iam_policy_document.nodes_kms.json
}

resource "aws_iam_role_policy_attachment" "nodes_kms" {
  policy_arn = aws_iam_policy.nodes_kms.arn
  role       = aws_iam_role.nodes.name
}
