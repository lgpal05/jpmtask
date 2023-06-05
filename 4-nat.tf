resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "viddemonat"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-us-east-2a.id

  tags = {
    Name = "viddemonat"
  }

  depends_on = [aws_internet_gateway.igw]
}