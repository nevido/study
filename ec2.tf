

# provider "aws" {
#     region = "ap-northeast-2"
#     }

# variable 블럭

variable "vpc_id" {
    default = "vpc-0dc6abc1b84b42774"
}

# variable subnet 블럭

variable "subnet_id" {
    default = ["subnet-0389229bb6e5db427", "subnet-0e5be0fe8d0b1d89a"]  #만들어 높은거 사용
    
}

# 최신 ami 찾기 -- 여기부터 

data "aws_ami" "amzn2" {
    most_recent = true  #가장 최근 값 
    filter {
        name = "name"

# Readme.md에서 filter 적색부분 참조 

        values = ["amzn2-ami-hvm-2.0.????????.?-x86_64-gp2"]
    }    
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    
    owners = ["amazon"] 
}  


# Security Group 추가 

resource "aws_security_group" "allow_web" {
    name = "allow_web"
    description = "Allow web inbound traffic"
#    vpc_id = "vpc-0b0d0951a7cf4e52au"        # VPC DASHBOARD에서 해당 ID확인
    vpc_id = var.vpc_id                       # variable vpc_id
    ingress {
        description = "Web from VPC"
        from_port = 0                       # 0 : 모든 포트 
        to_port = 0
        protocol = "-1"                     # -1 : 모든 프로토콜
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = {
        Name = "allow_web"
    }
    
}



# 최신 ami 찾기 --- 여기까지 

resource "aws_instance" "web-2c" {
#    ami = "ami-033a6a056910d1137"   # 일반 이미지 사용시 
    ami = data.aws_ami.amzn2.id      # data를 통해 최신 ami를 찾아서 입력할시
    instance_type = "t2.micro"
    key_name = "tf-key-pair"         #0.key에서 만든 key name 
    
    vpc_security_group_ids = [aws_security_group.allow_web.id]
    
# Availability zone 추가
    availability_zone = "ap-northeast-2c"
    
    subnet_id = var.subnet_id[1]     # var의 subnet이 리스트구조로 둘중 하나 선택
    
    user_data = file("./init-script.sh")
    
# EBS 볼륨 사이즈 추가
    root_block_device {
        volume_size = 30             # GB
        volume_type = "gp2"          # Default: gp2    volume_type을 지정하지 않으면 gp2로 적용됨
    }
    
    tags = {
        Name = "web-2c"
    }
    
}


## 위에 resource :web-2c를 복사해서  web-2a로 변경

resource "aws_instance" "web-2a" {
#    ami = "ami-033a6a056910d1137"   # 일반 이미지 사용시 
    ami = data.aws_ami.amzn2.id      # data를 통해 최신 ami를 찾아서 입력할시
    instance_type = "t2.micro"
    key_name = "tf-key-pair"         #0.key에서 만든 key name 
    
    vpc_security_group_ids = [aws_security_group.allow_web.id]
    
# Availability zone 추가
    availability_zone = "ap-northeast-2a"
    
    subnet_id = var.subnet_id[0]     # var의 subnet이 리스트구조로 둘중 하나 선택
    
    user_data = file("./init-script.sh")
    
# EBS 볼륨 사이즈 추가
    root_block_device {
        volume_size = 30             # GB
        volume_type = "gp2"          # Default: gp2    volume_type을 지정하지 않으면 gp2로 적용됨
    }
    
    tags = {
        Name = "web-2a"
    }
    
}
