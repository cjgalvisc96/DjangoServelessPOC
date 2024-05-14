resource "aws_ecr_repository" "elucid_ecr_repository" {
  name                 = "${var.env}_${var.project_name}_ecr_repository"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name    = "${var.env}_${var.project_name}_ecr_repository"
  }
}