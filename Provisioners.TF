//Local-exec
resource "aws_instance" "myec2" {
    ami           = "ami-0b20a6f09484773af"
    instance_type = "t2.micro"

    provisioner "local-exec" {
        command = "echo ${self.public_ip} >> public_ips.txt"
    }
    
}

// Remote-exec
resource "aws_security_group" "web_sg" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # NOTE: I will never use cidr_blocks = ["0.0.0.0/0"] in real world use case for security concerns.
  }
} 
resource "aws_instance" "myec2-01" {
    ami                         = "ami-0b20a6f09484773af"
    instance_type               = "t2.micro"
    key_name                    = "terraform-key"
    vpc_security_group_ids      = [aws_security_group.web_sg.id]
    associate_public_ip_address = true
    tags                        = {
      Name                      = "terraformed-ec2"
    }


  # The first step is establishing how terraform will connect to the server

    connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./terraform-key.pem") # create a .pem key name it 'terraform_key, add it to the folder where terraform code is located
    host        = self.public_ip
  }
  # The second step is specifying the command we want to run

    provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install nginx1 -y", # I would have just used the generic: "sudo yum -y install nginx" but since I'm on AL2(Amazon linux 2, the command I used is the right one)
      "sudo systemctl start nginx",
    ]
  }
}

# From the CLI, in the same folder where pem file is present, we will run chmod 400 terraform-key.pem for SSH permission
# terraform validate tto confirm the code
# If there is a troubleshooting error where I can't connecr, I can ssh directly from the terminal where my terraform code is located using 
# ssh -i terraform-key.pem ec2-user@<public-ip>


// Creation-Time Provisioner
resource "aws_iam_user" "ctp" {
  name = "Creation-time-provisioner"

  provisioner "local-exec" {
    command = "echo This is creation time provisioner"
  }

  provisioner "local-exec"{
    command = "echo This is destroy time provisioner"
    when    = destroy
  }
  
  
}
