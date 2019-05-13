resource "null_resource" remoteExecProvisionerWFolder {
  depends_on = ["google_sql_database_instance.instance"]
  count      = 1

  connection {
    host        = "${google_compute_instance.jenkins.*.network_interface.0.access_config.0.nat_ip}"
    type        = "ssh"
    user        = "centos"
    private_key = "${file("${var.private_key_path}")}"
    agent       = "false"
  }

  provisioner "file" {
    source      = "${var.private_key_path}"
    destination = "/home/centos/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = ["sudo chmod 600 /home/centos/.ssh/id_rsa"]
  }

  provisioner "remote-exec" {
    inline = ["rm -rf /tmp/ansible"]
  }

  provisioner "file" {
    source      = "ansible"
    destination = "/tmp/ansible"
  }

  provisioner "file" {
    source      = "ansible/Dockerfile"
    destination = "/home/centos/Dockerfile"
  }

  provisioner "file" {
    source      = "ansible/Dockerfile1"
    destination = "/home/centos/Dockerfile1"
  }

  provisioner "file" {
    source      = "k8s"
    destination = "/home/centos/k8s"
  }

  provisioner "file" {
    content     = "${data.template_file.jenkins_conf.rendered}"
    destination = "/tmp/ansible/files/jenkins.plugins.publish_over_ssh.BapSshPublisherPlugin.xml"
  }

  provisioner "file" {
    content     = "${data.template_file.app_conf.rendered}"
    destination = "/tmp/ansible/files/application.properties"
  }

  provisioner "file" {
    content     = "${data.template_file.job_frontend.rendered}"
    destination = "/tmp/ansible/files/job_frontend.xml"
  }

  provisioner "file" {
    content     = "${data.template_file.service.rendered}"
    destination = "/home/centos/k8s/service.yml"
  }

  provisioner "file" {
    content     = "${data.template_file.service_frontend.rendered}"
    destination = "/home/centos/k8s/service_frontend.yml"
  }
}

resource "null_resource" "ansibleProvision" {
  depends_on = ["null_resource.remoteExecProvisionerWFolder"]
  count      = 1

  connection {
    host        = "${google_compute_instance.jenkins.*.network_interface.0.access_config.0.nat_ip}"
    type        = "ssh"
    user        = "centos"
    private_key = "${file("${var.private_key_path}")}"
    agent       = "false"
  }

  provisioner "remote-exec" {
    inline = ["sudo sed -i -e 's+#host_key_checking+host_key_checking+g' /etc/ansible/ansible.cfg"]
  }

  provisioner "remote-exec" {
    inline = ["ansible-playbook -i /tmp/ansible/hosts.txt /tmp/ansible/main.yml"]
  }
}
