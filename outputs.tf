output "puppet_master" {
  value = "${module.puppet.puppet_master}"
}

output "jenkins_master" {
  value = "${module.puppet.jenkins_master}"
}

output "jenkins_slave" {
  value = "${module.puppet.jenkins_slave}"
}
