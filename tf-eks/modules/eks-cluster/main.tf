#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#


variable "cluster-name"{}
variable "aws_sg_demo_node_id"{}
variable "aws_vpc_demo_id"{}
variable "aws_subnet_demo"{}
variable "workstation-external-cidr"{}

resource "aws_iam_role" "demo-cluster" {
  name = "terraform-eks-demo-cluster"

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

resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.demo-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.demo-cluster.name}"
}

resource "aws_security_group" "demo-cluster" {
  name        = "terraform-eks-demo-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${var.aws_vpc_demo_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "terraform-eks-demo"
  }
}
output "aws_sg_demo_cluster_id"{
  value = "${aws_security_group.demo-cluster.id}"
}

resource "aws_security_group_rule" "demo-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.demo-cluster.id}"
  source_security_group_id = "${var.aws_sg_demo_node_id}"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "demo-cluster-ingress-workstation-https" {
  cidr_blocks       = ["${var.workstation-external-cidr}"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.demo-cluster.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "demo" {
  name     = "${var.cluster-name}"
  role_arn = "${aws_iam_role.demo-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.demo-cluster.id}"]
    subnet_ids         = ["${split(",",var.aws_subnet_demo)}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.demo-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.demo-cluster-AmazonEKSServicePolicy",
  ]
}

output "aws_eks_cluster_demo_endpoint"{
  value = "${aws_eks_cluster.demo.endpoint}"
  depends_on = [
    "aws_eks_cluster.demo"
  ]
}

output "aws_eks_cluster_demo_cert_auth_0_data"{
  value = "${aws_eks_cluster.demo.certificate_authority.0.data}"
    depends_on = [
    "aws_eks_cluster.demo"
  ]
}
