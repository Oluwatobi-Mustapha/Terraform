// Scenario: You're setting up IAM infrastructure for a new AWS environment. 
// You need to create an IAM user for a service account and implement audit logging using provisioners.

resource "aws_iam_user" "lb"{
    name  = "svc-terraform-automation"


    provisioner "local-exec" {
        command    = "echo '${self.name}, ${timestamp()}, CREATED' >> iam_creation_audit.csv"
    }

    provisioner "local-exec" {
        when       = destroy
        on_failure = continue
    # I used on_failure = continue here because a failed audit log 
    # should not block actual IAM user deletion. Orphaned IAM users 
    # are a bigger security risk than a missing log entry 
        command    = "echo '${self.name}, ${timestamp()}, DESTROYED' >> am_creation_audit.csv"
    }
}

 #The content of the iam_creation_audit.csv would look like this after I run terraform apply follow by terraform destroy:
# svc-terraform-automation,2025-12-22T10:30:00Z,CREATED
# svc-terraform-automation,2025-12-22T10:35:00Z,DELETED