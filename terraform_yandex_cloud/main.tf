# main.tf

# Локальные переменные (константы), которые легко переиспользовать
locals {
  # Актуальный ID образа Ubuntu 22.04 LTS (Cloud Image)
  # Этот ID универсален для YC
  ubuntu_image_id = "fd800c7s2p483i648ifv" 
  # Имя пользователя, которое будет создано на VM (стандарт для Ubuntu)
  ssh_user = "ubuntu"
}

# 1. Ресурс: Создание экземпляра (VM)
resource "yandex_compute_instance" "ansible_target_vm" {
  name = "budget-tracker-test-vm"
  
  # Настройки зоны (должна соответствовать зоне в providers.tf)
  zone = "ru-central1-a"

  # Конфигурация ресурсов (минимальный рекомендуемый размер для Docker/Ansible)
  platform_id = "standard-v3"
  resources {
    cores  = 2
    memory = 4
    core_fraction = 20 # Гарантированная доля ядра (20% - экономит грант)
  }

  # Диск: 10 GB SSD
  boot_disk {
    initialize_params {
      size = 10
      type = "network-ssd"
      image_id = local.ubuntu_image_id
    }
  }

  # Сетевой интерфейс
  network_interface {
    # ВАЖНО: Замените на ID вашей подсети! 
    # (Получите его из раздела VPC/Сети в Консоли YC)
    subnet_id = "e9bb0hueqlfi1h4fh242" 
    nat = true # Дать публичный IP-адрес для доступа извне
  }
  
  # Добавление SSH-ключа (ВАЖНО! Systemd создаст пользователя 'ubuntu')
  # Terraform прочитает ваш публичный ключ из файла и добавит его в метаданные VM
  metadata = {
    ssh-keys = "${local.ssh_user}:${file(join("/", [var.home_dir_path, ".ssh/id_rsa.pub"]))}"
  }
}

# 2. Вывод: Публичный IP-адрес для подключения
output "target_vm_ip" {
  value = yandex_compute_instance.ansible_target_vm.network_interface.0.nat_ip_address
}
