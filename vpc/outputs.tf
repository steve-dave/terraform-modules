output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "private_subnet_ids" {
  value = "${zipmap(aws_subnet.private.*.tags.Name, aws_subnet.private.*.id)}"
}

output "public_subnet_ids" {
  value = "${zipmap(aws_subnet.public.*.tags.Name, aws_subnet.public.*.id)}"
}

output "nat_subnet_ids" {
  value = "${zipmap(aws_subnet.nat.*.tags.Name, aws_subnet.nat.*.id)}"
}
