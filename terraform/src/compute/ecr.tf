resource "aws_ecr_repository" "elucid_backend_repository" {
  name                 = "${var.resource_prefix}-ecr-repository"
  image_tag_mutability = var.elucid_backend_repository.image_tag_mutability

  tags = {
    Name    = "${var.resource_prefix}-ecr-repository"
  }
}