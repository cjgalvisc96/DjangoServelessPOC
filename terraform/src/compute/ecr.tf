resource "aws_ecr_repository" "elucid_ecr_repository" {
  name                 = "${var.env}_${var.project_name}_ecr_repository"
  image_tag_mutability = var.aws_ecr_repository.image_tag_mutability

  tags = {
    Name    = "${var.env}_${var.project_name}_ecr_repository"
  }
}