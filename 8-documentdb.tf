# Your VPC
data "aws_vpc" "main" {
  default = true
}

# Your Subnets
resource "aws_subnet" "new_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.128.0/19" # Adjust this CIDR block to your desired value.
  availability_zone = "us-east-2a"     

  tags = {
    Name = "public-us-east-2a"
  }
}

resource "aws_subnet" "new_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.160.0/19" # Adjust this CIDR block to your desired value.
  availability_zone = "us-east-2b"

  tags = {
    Name = "public-us-east-2b"
  }
}

# Your Route Table Associations
resource "aws_route_table_association" "new_subnet_1" {
  subnet_id      = aws_subnet.new_subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "new_subnet_2" {
  subnet_id      = aws_subnet.new_subnet_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_docdb_subnet_group" "subnet_group" {
  name       = "docdb-subnet-group"
  subnet_ids = [aws_subnet.new_subnet_1.id, aws_subnet.new_subnet_2.id]
}

resource "aws_docdb_cluster" "docdb_cluster" {
  cluster_identifier      = "vjddbcl"
  engine                  = "docdb"
  master_username         = jsondecode(data.aws_secretsmanager_secret_version.docdb_secret.secret_string)["username"]
  master_password         = jsondecode(data.aws_secretsmanager_secret_version.docdb_secret.secret_string)["password"]
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = 2
  identifier         = "docdb-cluster-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb_cluster.id
  instance_class     = "db.r5.large"
}

resource "aws_security_group" "docdb_sg" {
  name        = "docdb-security-group"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_docdb_cluster_parameter_group" "parameter_group" {
  name   = "docdb-cluster-parameter-group"
  family = "docdb3.6"

  parameter {
    name  = "tls"
    value = "enabled"
  }
}

resource "aws_secretsmanager_secret" "docdb_secret" {
  name        = "docdb-secret"
  description = "This is the secret for the DocumentDB instance."
}

resource "aws_secretsmanager_secret_version" "docdb_secret" {
  secret_id     = aws_secretsmanager_secret.docdb_secret.id
  secret_string = "{\"username\":\"yourusername\", \"password\":\"yourpassword\"}"
}

data "aws_secretsmanager_secret_version" "docdb_secret" {
  secret_id = aws_secretsmanager_secret.docdb_secret.id
}

