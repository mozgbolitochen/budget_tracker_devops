# providers.tf (изменение)

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.13"
    }
  }
}

provider "yandex" {
  service_account_key_file = "sa_key.json"
  folder_id = "b1g8vqmo5usau8afdhap"
  zone = "ru-central1-a"
}
