resource "aws_instance" "this" {
  count                       = length(var.availability_z)
  ami                         = "ami-09bf9dfeeb1e9adbc"
  associate_public_ip_address = true
  availability_zone           = var.availability_z[count.index]
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[count.index].id
  vpc_security_group_ids      = [aws_security_group.allow-traffic.id]
  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.name_prefix}-EC2"
    }
  )
}
