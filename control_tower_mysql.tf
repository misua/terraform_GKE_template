provider "aws" {
    region = "us-east-1"
  
}

//create a user in control tower

resource "aws_controltower_user" "user" {
    name = "my-user"
    email = "my-user@gmail.com"
  
}

//assign that user access to the mysql db 

resource  "aws_controltower_access_assignment" "access_assignment"{
    user = aws_controltower_user.user.id
    principal = "arn:aws:iam:123456789012:user/myuser"
    resource = "arn:aws:rds:us-east-1:123456789012:db:my-db"
    permissions = ["SELECT","UPDATE"]
  
}

//create a topic to notify when a specific user logs to the db
resource "aws_sns_topic" "topic" {
    name = "my-topic"
  
}

resource "aws_sns_subscription" "subscription" {
    topic_arn = aws_sns_topic.topic.arn
    endpoint = aws_controltower_user.user.email
    protocol = "email"
  
}
