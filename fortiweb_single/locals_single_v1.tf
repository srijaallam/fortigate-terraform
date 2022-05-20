locals {
  resource_groups = {
    (var.resource_group_name) = {
      name     = var.resource_group_name
      location = var.resource_group_location
    }
  }

  public_ips = {
    "pip_fweb" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name              = "pip_fweb"
      allocation_method = "Static"
      sku               = "Standard"
    }
    "pip_linuxvm" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name              = "pip_linuxvm"
      allocation_method = "Static"
      sku               = "Standard"
    }
    "pip_kalilinux" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name              = "pip_kalilinux"
      allocation_method = "Static"
      sku               = "Standard"
    }
  }
    random_ids = {
    "storage_account_random_id" = {
      keepers_resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      byte_length                 = 8
    }
  }
  virtual_networks = {
    (var.virtual_network_name) = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name          = var.virtual_network_name
      address_space = var.virtual_network_address_space
    }
  }

    subnets = {
    "external" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name             = "external"
      vnet_name        = var.virtual_network_name
      address_prefixes = [cidrsubnet(module.module_azurerm_virtual_network[var.virtual_network_name].virtual_network.address_space[0], 8, 0)]
    }
    "internal" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name             = "internal"
      vnet_name        = var.virtual_network_name
      address_prefixes = [cidrsubnet(module.module_azurerm_virtual_network[var.virtual_network_name].virtual_network.address_space[0], 8, 1)]
    }
    "protected" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name             = "protected"
      vnet_name        = var.virtual_network_name
      address_prefixes = [cidrsubnet(module.module_azurerm_virtual_network[var.virtual_network_name].virtual_network.address_space[0], 8, 2)]
    }
  }

    network_interfaces = {
    "nic_fortiweb_1_1" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name                          = "nic_fortiweb_1_1"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["external"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["external"].subnet.address_prefixes[0], 4)
          public_ip_address_id          = module.module_azurerm_public_ip["pip_fweb"].public_ip.id
        }
      ]
    }
    "nic_fortiweb_1_2" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name                          = "nic_fortiweb_1_2"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["internal"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["internal"].subnet.address_prefixes[0], 4)
          public_ip_address_id          = null
        }
      ]
    }
    "nic_linuxvm_1_1" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name                          = "nic_linuxvm_1_1"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["protected"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["protected"].subnet.address_prefixes[0], 4)
          public_ip_address_id          = module.module_azurerm_public_ip["pip_linuxvm"].public_ip.id
        }
      ]
    }
    "nic_kalivm_1_1" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name                          = "nic_kalivm_1_1"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["external"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["external"].subnet.address_prefixes[0], 10)
          public_ip_address_id          = module.module_azurerm_public_ip["pip_kalilinux"].public_ip.id
        }
      ]
    }
  }

  #storage account must be globally unique
  #capital letters, dashes, uderscores, etc. are not allowed in storage account names
  storage_accounts = {
    "stdiag" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name                     = format("stdiag%s", "${random_id.id["storage_account_random_id"].hex}")
      account_replication_type = "LRS"
      account_tier             = "Standard"
    }
  }
  network_security_groups = {
    "nsg_external" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name = "nsg_external"
    }
    "nsg_internal" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name = "nsg_internal"
    }
    #Linux VM NSG
    "nsg_application_vm" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name = "nsg_application_vm"
    }
  }

  network_security_rules = {
    "nsr_external_ingress" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name                        = "nsr_external_ingress"
      priority                    = 1001
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = module.module_azurerm_network_security_group["nsg_external"].network_security_group.name
    },
    "nsr_external_egress" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name                        = "nsr_external_egress"
      priority                    = 1002
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = module.module_azurerm_network_security_group["nsg_external"].network_security_group.name
    },
    "nsr_internal_ingress" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name                        = "nsr_internal_ingress"
      priority                    = 1003
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = module.module_azurerm_network_security_group["nsg_internal"].network_security_group.name
    },
    "nsr_internal_iegress" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name                        = "nsr_internal_iegress"
      priority                    = 1004
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = module.module_azurerm_network_security_group["nsg_internal"].network_security_group.name
    }

    #linux VM
    "nsr_application_vm_ingress" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name                        = "22"
      priority                    = 1004
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = module.module_azurerm_network_security_group["nsg_application_vm"].network_security_group.name
    },
    "nsr_application_vm_egress" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name                        = "nsr_application_vm_egress"
      priority                    = 1005
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = module.module_azurerm_network_security_group["nsg_application_vm"].network_security_group.name
    }
  }
  subnet_network_security_group_associations = {
    "external" = {
      subnet_id                 = module.module_azurerm_subnet["external"].subnet.id
      network_security_group_id = module.module_azurerm_network_security_group["nsg_external"].network_security_group.id
    }
    "internal" = {
      subnet_id                 = module.module_azurerm_subnet["internal"].subnet.id
      network_security_group_id = module.module_azurerm_network_security_group["nsg_internal"].network_security_group.id
    }
    "application" = {
      subnet_id                 = module.module_azurerm_subnet["protected"].subnet.id
      network_security_group_id = module.module_azurerm_network_security_group["nsg_application_vm"].network_security_group.id
    }
  }

  vm_image = {
    "fortinet" = {
      publisher = "fortinet"
      offer     = "fortinet_fortiweb-vm_v5"
      sku       = var.fortiweb_sku
      version   = var.fortiweb_ver
      vm_size   = var.fortiweb_size
    }
  }

  marketplace_agreement = {
      "vm_application" = {
          publishername       = "ntegralinc1586961136942"
          offer               = "ntg_ubuntu_20_04_lts"
          plan                = "ntg_ubuntu_20_04_lts"
    }
  }

  virtual_machines = {
    "vm_fweb" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name              = "vm-fweb"
      identity_identity = "SystemAssigned"

      #availability_set_id or zones can be set but not both. Both can be null
      availability_set_id = null
      zones               = null

      delete_os_disk_on_termination    = true
      delete_data_disks_on_termination = true

      network_interface_ids        = [for nic in ["nic_fortiweb_1_1", "nic_fortiweb_1_2"] : module.module_azurerm_network_interface[nic].network_interface.id]
      primary_network_interface_id = module.module_azurerm_network_interface["nic_fortiweb_1_1"].network_interface.id

      public_ip_address = module.module_azurerm_public_ip["pip_fweb"].public_ip.ip_address

      vm_size = local.vm_image["fortinet"].vm_size

      storage_image_reference_publisher = local.vm_image["fortinet"].publisher
      storage_image_reference_offer     = local.vm_image["fortinet"].offer
      storage_image_reference_sku       = local.vm_image["fortinet"].sku
      storage_image_reference_version   = local.vm_image["fortinet"].version

      plan_publisher = local.vm_image["fortinet"].publisher
      plan_product   = local.vm_image["fortinet"].offer
      plan_name      = local.vm_image["fortinet"].sku

      os_profile_admin_username = "azureuser"
      os_profile_admin_password = "Password123!!"

      os_profile_linux_config_disable_password_authentication = false

      boot_diagnostics_enabled     = true
      boot_diagnostics_storage_uri = module.module_azurerm_storage_account["stdiag"].storage_account.primary_blob_endpoint

      storage_os_disk_name              = "disk_os_fweb"
      storage_os_disk_caching           = "ReadWrite"
      storage_os_disk_managed_disk_type = "Premium_LRS"
      storage_os_disk_create_option     = "FromImage"

      storage_data_disks = [
        {
          name              = "disk_data_fweb"
          managed_disk_type = "Premium_LRS"
          create_option     = "Empty"
          disk_size_gb      = "30"
          lun               = "0"
        }
      ]
    }
  "vm_application" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name              = "juiceshop"
      identity_identity = "SystemAssigned"

      availability_set_id = null
      zones               = null

      delete_os_disk_on_termination    = true
      delete_data_disks_on_termination = true

      network_interface_ids        = [for nic in ["nic_linuxvm_1_1"] : module.module_azurerm_network_interface[nic].network_interface.id]
      primary_network_interface_id = module.module_azurerm_network_interface["nic_linuxvm_1_1"].network_interface.id

      public_ip_address        = null
      vm_size                  = "Standard_DS1_v2"

      storage_os_disk_name              = "disk_os_appvm"
      storage_os_disk_caching           = "ReadWrite"
      storage_os_disk_managed_disk_type = "Premium_LRS"

      storage_image_reference_publisher = "ntegralinc1586961136942"
      storage_image_reference_offer     = "ntg_ubuntu_20_04_lts"
      storage_image_reference_sku       = "ntg_ubuntu_20_04_lts"
      storage_image_reference_version   = "latest"
      storage_os_disk_create_option     = "FromImage"

      plan_name      = "ntg_ubuntu_20_04_lts"
      plan_publisher = "ntegralinc1586961136942"
      plan_product   = "ntg_ubuntu_20_04_lts"

       
      os_profile_admin_username   = "azureuser"
      os_profile_admin_password    = "Password1!"
      os_profile_linux_config_disable_password_authentication = false


      storage_data_disks = [
        {
          name              = "disk_data_application"
          managed_disk_type = "Premium_LRS"
          create_option     = "Empty"
          disk_size_gb      = "30"
          lun               = "0"
        }
      ]
      
      boot_diagnostics_enabled     = true
      boot_diagnostics_storage_uri = module.module_azurerm_storage_account["stdiag"].storage_account.primary_blob_endpoint
    }
    "vm_kali_linux" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name              = "kalilinux"
      identity_identity = "SystemAssigned"

      availability_set_id = null
      zones               = null

      delete_os_disk_on_termination    = true
      delete_data_disks_on_termination = true

      network_interface_ids        = [for nic in ["nic_kalivm_1_1"] : module.module_azurerm_network_interface[nic].network_interface.id]
      primary_network_interface_id = module.module_azurerm_network_interface["nic_kalivm_1_1"].network_interface.id

      public_ip_address        = null
      vm_size                  = "Standard_DS1_v2"

      storage_os_disk_name              = "disk_os_kalivm"
      storage_os_disk_caching           = "ReadWrite"
      storage_os_disk_managed_disk_type = "Premium_LRS"

      storage_image_reference_publisher = "techlatest"
      storage_image_reference_offer     = "desktop-linux-kali"
      storage_image_reference_sku       = "desktop-linux-kali"
      storage_image_reference_version   = "latest"
      storage_os_disk_create_option     = "FromImage"

      plan_name      = "desktop-linux-kali"
      plan_publisher = "techlatest" 
      plan_product   = "desktop-linux-kali"

       
      os_profile_admin_username   = "azureuser"
      os_profile_admin_password    = "Password1!"
      os_profile_linux_config_disable_password_authentication = false


      storage_data_disks = [
        {
          name              = "disk_data_kali"
          managed_disk_type = "Premium_LRS"
          create_option     = "Empty"
          disk_size_gb      = "30"
          lun               = "0"
        }
      ]
      
      boot_diagnostics_enabled     = true
      boot_diagnostics_storage_uri = module.module_azurerm_storage_account["stdiag"].storage_account.primary_blob_endpoint
    }
  }

}

