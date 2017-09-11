resource "aws_vpc" "main" {
  cidr_block           = "172.18.0.0/19"
  enable_dns_hostnames = true

  tags {
    Name = "ap-southeast-2"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${element(keys(var.private_subnets), count.index)} private"
  }

  count = "${length(var.private_subnets)}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "${aws_vpc.main.tags.Name} public"
  }
}

resource "aws_route_table" "nat" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "${aws_vpc.main.tags.Name} nat"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(values(var.private_subnets), count.index)}"
  availability_zone       = "${replace(element(keys(var.private_subnets), count.index), "/\\..*/", "")}"
  map_public_ip_on_launch = false

  tags {
    Name = "${element(keys(var.private_subnets), count.index)} private"
  }

  count = "${length(var.private_subnets)}"
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(values(var.public_subnets), count.index)}"
  availability_zone       = "${replace(element(keys(var.public_subnets), count.index), "/\\..*/", "")}"
  map_public_ip_on_launch = true

  tags {
    Name = "${element(keys(var.public_subnets), count.index)} public"
  }

  count = "${length(var.public_subnets)}"
}

resource "aws_subnet" "nat" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(values(var.nat_subnets), count.index)}"
  availability_zone       = "${replace(element(keys(var.nat_subnets), count.index), "/\\..*/", "")}"
  map_public_ip_on_launch = true

  tags {
    Name = "${element(keys(var.nat_subnets), count.index)} nat"
  }

  count = "${length(var.nat_subnets)}"
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"

  count = "${length(var.private_subnets)}"
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"

  count = "${length(var.public_subnets)}"
}

resource "aws_route_table_association" "nat" {
  subnet_id      = "${element(aws_subnet.nat.*.id, count.index)}"
  route_table_id = "${aws_route_table.nat.id}"

  count = "${length(var.nat_subnets)}"
}
