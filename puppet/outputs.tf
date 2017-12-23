output "puppet_master" {
  value = "${aws_eip.puppet_master.public_ip}"
}

output "puppet_db" {
  value = "${aws_eip.puppet_db.public_ip}"
}

output "jenkins_master" {
  value = "${aws_eip.jenkins_master.public_ip}"
}

output "jenkins_slave" {
  value = "${aws_eip.jenkins_slave.public_ip}"
}
