output "alb_sg" {
  value = aws_security_group.alb_sg.id
}

output "alb_tg_arn" {
  value = aws_alb_target_group.pavlina-prod-byoi-tg.arn
}