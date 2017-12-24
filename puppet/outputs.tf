output "puppet_01" {
  value = "${aws_eip.puppet_01.public_ip}"
}

output "jenkins_01" {
  value = "${aws_eip.jenkins_01.public_ip}"
}

output "jenkins_slave_01" {
  value = "${aws_eip.jenkins_slave_01.public_ip}"
}
