resource "aws_security_group" "allow-traffic" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.name_prefix}-sg"
    }
  )
}
resource "aws_vpc_security_group_ingress_rule" "allow-all" {
  count             = length(var.ports)
  cidr_ipv4         = var.cidr_rt
  security_group_id = aws_security_group.allow-traffic.id
  from_port         = var.ports[count.index]
  ip_protocol       = "tcp"
  to_port           = var.ports[count.index]
}
resource "aws_vpc_security_group_ingress_rule" "allow-SSH" {
  cidr_ipv4         = "104.28.245.3/32"
  security_group_id = aws_security_group.allow-traffic.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}



resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow-traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
