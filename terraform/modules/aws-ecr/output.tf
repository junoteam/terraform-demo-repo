output "name" {
  value = aws_ecr_repository.ecr.name
}

output "repository_urls" {
  value = aws_ecr_repository.ecr[*].repository_url
}

output "repository_map" {
  value = zipmap(aws_ecr_repository.ecr[*].name, aws_ecr_repository.ecr[*].repository_url)
}
