### timestamp
---

The tf-eks directory will create a Kubernetes cluster in your AWS instance, and then provision it to run the Reactjs and Golang code included in the src folder. 

Ive also included the docker and minikube functions and file I used to create and test the containerized program. 

To run this yourself you'll first need to compile the binary and containerize it yourself, then push it to your github repo. After that you just need to fill in the name in the `eks-state/main.tf`.

This program depends on having your AWSCLI configured, and AWS-IAM-Authenticator on your $PATH, not to mention the Terraform binary itself. 

```
Once everything is installed you can `terraform init`

followed by `terraform apply --auto-approve`, word of caution, this will cost to run.
```

[You can find more design details on my site](https://anthonylaiuppa.com/one-command/)

This code could make a great bootstrapper for building out your own decoupled architecture or getting practice working with containerized apps.