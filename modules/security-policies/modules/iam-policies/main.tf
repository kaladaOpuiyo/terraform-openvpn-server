resource "aws_iam_instance_profile" "openvpn" {
  name_prefix = var.resource_name
  role        = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name               = var.resource_name
  path               = "/"
  assume_role_policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }
EOF

}

data "aws_iam_policy_document" "associate_ec2_policy_doc" {
  statement {
    effect    = "Allow"
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = [format("arn:aws:route53:::hostedzone/%s", var.vpn_host_zone_id)]
  }
}

resource "aws_iam_policy" "associate_ec2_policy" {
  name   = "associate_address"
  policy = data.aws_iam_policy_document.associate_ec2_policy_doc.json
}


resource "aws_iam_role_policy_attachment" "associate_ec2" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.associate_ec2_policy.arn
}

