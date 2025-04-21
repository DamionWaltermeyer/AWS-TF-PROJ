resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "allow traffic from alb only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "from ALB" #this should be TLS on 443, but 80 for time constraints
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags

}


resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name
  depends_on = [aws_iam_instance_profile.ec2_ssm_profile]
  associate_public_ip_address = false

user_data = <<-EOF
  #!/bin/bash
  yum update-minimal -y --security

  # Install Apache
  yum install -y httpd

  # Enable PostgreSQL 14 client tools
  amazon-linux-extras enable postgresql14
  yum clean metadata
  yum install -y postgresql

  # Create .pgpass for secure passwordless psql
  echo "${var.db_host}:5432:${var.db_name}:${var.db_user}:${var.db_password}" > /root/.pgpass
  chmod 600 /root/.pgpass
  export PGPASSFILE=/root/.pgpass

  # Try to connect and query the DB
  DB_TIME=$(psql -h ${var.db_host} -p 5432 -U ${var.db_user} -d ${var.db_name} -c "SELECT now();" -tA 2>&1)

  # Fallback message if connection fails
  if [[ $? -ne 0 ]]; then
    DB_TIME="Database connection failed: $DB_TIME"
  fi

  # Generate index.html
  cat <<EOT > /var/www/html/index.html
  <html>
    <body>
      <h1>Hello Alloy from Damion's App!</h1>
      <p><strong>Database time:</strong> $DB_TIME</p>
    </body>
  </html>
EOT

  # Remove Apache welcome page
  rm -f /etc/httpd/conf.d/welcome.conf

  # Start web server
  systemctl enable httpd
  systemctl start httpd

  # Log success
  echo "user_data executed successfully" >> /var/log/user-data.log
EOF

  tags = merge(local.common_tags, {
    Name = "damions-app-instance"
  })
}

resource "aws_lb_target_group_attachment" "app_attach" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.app.id
  port             = 80
}

