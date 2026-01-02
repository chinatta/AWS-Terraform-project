resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "dev-nat-eip"
    Environment = "dev"
  }
}


resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_az1.id

  tags = {
    Name        = "dev-nat-gateway"
    Environment = "dev"
  }

  depends_on = [aws_internet_gateway.igw]
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name        = "dev-private-rt"
    Environment = "dev"
  }
}

resource "aws_route_table_association" "private_az1" {
  subnet_id      = aws_subnet.private_az1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_az2" {
  subnet_id      = aws_subnet.private_az2.id
  route_table_id = aws_route_table.private.id
}
