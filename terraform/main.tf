provider "aws" {
  region = var.aws_region
}

provider "vault" {

  address = var.address
  skip_child_token = true

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id = var.role_id
      secret_id = var.secret_id
    }
  }
}

data "vault_kv_secret_v2" "example" {
  mount = "secret"
  name  = "aws-secret"
}

module "web_server" {
  source        = "./modules/ec2_web_server"
  ami_id        = "ami-03d49b144f3ee2dc4" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = "shr-terra"
}


output "web_server_ip" {
  value = module.web_server.instance_public_ip
}
