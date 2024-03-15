output "amazon_linux_ami_id" {
  description = "The ID of the most recent Amazon Linux 2 AMI"
  value       = data.aws_ami.amazon_linux_23.id
}
