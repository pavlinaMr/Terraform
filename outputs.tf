    output "app_asg" {
        value = aws_autoscaling_group.app_asg
}

output "application_sg" {
    value = aws_security_group.application_sg.id
}