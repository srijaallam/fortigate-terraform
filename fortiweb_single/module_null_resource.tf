resource "null_resource" "juiceshop_deploy" {
triggers = {
    vm_application_id = module.module_azurerm_virtual_machine["vm_application"].virtual_machine.id
}

connection {
    type = "ssh"
    user = "azureuser"
    password = "Password1!"
    host = module.module_azurerm_public_ip["pip_linuxvm"].public_ip.ip_address
    
}
provisioner "remote-exec" {
  inline = [
    "sudo apt-get update",
    "sudo apt-get install git",
    "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
    "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable'",
    "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin",
    "git clone https://github.com/srijaallam/juiceshop.git",
    "cd juiceshop",
    "chmod +x run-container.sh",
    "sudo ./run-container.sh",
    "exit"
  ]
}
}