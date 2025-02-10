provider "aws" {
  region = var.aws_region
}

module "web_server" {
  source        = "./modules/ec2_web_server"
  ami_id        = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = "my-key-pair"
}

output "web_server_ip" {
  value = module.web_server.instance_public_ip
}
