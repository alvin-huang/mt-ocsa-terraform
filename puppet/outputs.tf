output "puppet_master" {
  value = "${aws_eip.puppet_master.public_ip}"
}

output "puppet_db" {
  value = "${aws_eip.puppet_db.public_ip}"
}
