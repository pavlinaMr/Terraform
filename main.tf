data "template_file" "app_user_data" {
  template = file("./app_install.tpl")
  vars = {
    region  = var.region
  }
}

resource "aws_launch_configuration" "application_launch_config" {
    name_prefix     = "${var.namespace}-app-config"
    image_id        = "ami-0d5eff06f840b45e9"
//    image_id        = data.aws_ami.app_instance.id
    instance_type   = "t2.micro"
    //security_groups = [var.alb_sg]
    security_groups = [aws_security_group.application_sg.id]
    user_data       = data.template_file.app_user_data.rendered

    iam_instance_profile = var.application_profile
    key_name = "app_instance_keypair"
    lifecycle {
    create_before_destroy = true
    }
}
resource "aws_autoscaling_group" "app_asg" {
    name                        = "${var.namespace}-app-asg"
    min_size                    = "2"
    max_size                    = "2"
    desired_capacity            = "2"
    force_delete                = true 
    launch_configuration        = aws_launch_configuration.application_launch_config.name
    health_check_grace_period   = 540
    health_check_type           = "EC2"

    depends_on                  = [aws_launch_configuration.application_launch_config]

    vpc_zone_identifier         = [var.private_subnet_app1, var.private_subnet_app2]
    target_group_arns           = [var.alb_tg_arn]

    enabled_metrics             = ["GroupDesiredCapacity", "GroupInServiceInstances"]

    tag {
        key = "Environment"
        value = lookup(var.taggings, "environment")
        propagate_at_launch = true
    }
}

resource "aws_security_group" "application_sg" {
    name        = "application_sg"
    description = "Allows http traffic into application instances"
    vpc_id      = var.vpc_id

        tags = {
        Name = "${lookup(var.taggings, "customer")}_app_sg"
        Environment = lookup(var.taggings, "environment")
        Solution    =  lookup(var.taggings, "solution")
    }
}

resource "aws_security_group_rule" "application_sg_ingress" {
        type = "ingress"
        description =   "HTTP from ALB"
        from_port   =   80
        to_port     =   80
        protocol    =   "tcp"
        source_security_group_id = var.alb_sg  
        security_group_id   = aws_security_group.application_sg.id
}
resource "aws_security_group_rule" "application_sg_ingress_all" {
        type = "ingress"
        description =   "all traffic"
        from_port   =   0
        to_port     =   0
        protocol    =   "-1"
    //    source_security_group_id = var.alb_sg  
        cidr_blocks  =   ["0.0.0.0/0"]
        security_group_id   = aws_security_group.application_sg.id
}

resource "aws_security_group_rule" "application_sg_egress" {
        type = "egress"
        description =   "HTTP to ALB"
        from_port   =   0
        to_port     =   0
        protocol    =   "-1"
        cidr_blocks  =   ["0.0.0.0/0"]
        security_group_id = aws_security_group.application_sg.id
}

resource "aws_security_group" "pavlina_prod_byoi_sg_db" {
    name        = "pavlina_prod_byoi_sg_db"
    description = "Allows http traffic to db"
    vpc_id      = var.vpc_id

    ingress {
        description =   "Traffic to db from application"
        from_port   =   3306
        to_port     =   3306
        protocol    =   "tcp"
        security_groups = [aws_security_group.application_sg.id] 
    }

    egress {
        description =   "Traffic from db to application"
        from_port   =   3306
        to_port     =   3306
        protocol    =   "tcp"
        security_groups = [aws_security_group.application_sg.id]
    }

    tags = {
        Name = "${lookup(var.taggings, "customer")}_sg_db"
        Environment = lookup(var.taggings, "environment")
        Solution    =  lookup(var.taggings, "solution")
    }
}

resource "aws_db_subnet_group" "pavlina-prod-db-subnet-group" {
    name    =   "pavlina-prod-db-subnet-group"
    description = "Subnet group for db layer"
    subnet_ids  = [var.private_subnet_db1, var.private_subnet_db2]

    tags = {
        name = "${var.namespace}_db_sg"
    }
}

resource "aws_rds_cluster_parameter_group" "default" {
  name        = "rds-cluster-pg"
  family      = "aurora-mysql5.7"
  description = "RDS default cluster parameter group"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_rds_cluster" "pavlina-prod-byoi-db-cluster" {
    cluster_identifier = "pavlina-prod-byoi-cluster"
    master_username = var.db_admin_username
    master_password = var.db_admin_password

    availability_zones = [ var.availability_zone_A,var.availability_zone_B ]

    vpc_security_group_ids = [ aws_security_group.pavlina_prod_byoi_sg_db.id ]

    db_subnet_group_name            = aws_db_subnet_group.pavlina-prod-db-subnet-group.name
    db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.default.name
    storage_encrypted               = true
    engine                          = "aurora-mysql"
    engine_mode                     = "serverless"
    engine_version                  = "5.7.mysql_aurora.2.03.2"
    backup_retention_period         = 7
    preferred_backup_window         = "06:00-08:00"
    preferred_maintenance_window    = "sat:08:30-sat:09:30"
    database_name                   = "pmProdDB"
    skip_final_snapshot             = true
    copy_tags_to_snapshot           = true
    deletion_protection             = false
    scaling_configuration {
      min_capacity = 1
      max_capacity = 64
    }
}