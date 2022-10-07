resource "aws_alb" "pavlina_prod_byoi_alb" {
    name        =   "pavlina-prod-byoi-alb"
    internal    =   false
    load_balancer_type = "application"
    subnets     =  [var.public_subnet1, var.public_subnet2]
    security_groups = [aws_security_group.alb_sg.id]

    tags = {
        Name = "pavlina_prod_byoi_alb"
        Environment = lookup(var.taggings, "environment")
        Solution    = lookup(var.taggings, "solution")
    }
}

resource "aws_alb_target_group" "pavlina-prod-byoi-tg" {
  name     = "pavlina-prod-byoi-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    port = 80
    matcher = "302"
    path = "/wordpress/index.php"

  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_alb.pavlina_prod_byoi_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.pavlina-prod-byoi-tg.arn
  }
}

resource "aws_security_group" "alb_sg" {
    name        = "alb_sg"
    description = "Allows http traffic to alb"
    vpc_id      = var.vpc_id

    tags = {
        Name = "${lookup(var.taggings, "customer")}_alb_sg"
        Environment = lookup(var.taggings, "environment")
        Solution    =  lookup(var.taggings, "solution")
    }
}

resource "aws_security_group_rule" "alb_sg_ingress" {
        type        =   "ingress" 
        description =   "HTTP to ALB"
        from_port   =   80
        to_port     =   80
        protocol    =   "tcp"
        #cidr_blocks  =   ["0.0.0.0/0"]    
        source_security_group_id = var.application_sg
        security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "alb_sg_ingress_all" {
        type = "ingress"
        description =   "all traffic"
        from_port   =   0
        to_port     =   0
        protocol    =   "-1"
        cidr_blocks  =   ["0.0.0.0/0"]
        security_group_id   = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "alb_sg_egress" {
        type        =   "egress" 
        description =   "HTTP traffic from ALB to application instances"
        from_port   =   80
        to_port     =   80
        protocol    =   "tcp"
        source_security_group_id = var.application_sg
        security_group_id = aws_security_group.alb_sg.id
}