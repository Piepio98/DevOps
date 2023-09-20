module "ec2_schedule" {
  source   = "./modules/ec2_schedule"
  aws_region = var.aws_region
}