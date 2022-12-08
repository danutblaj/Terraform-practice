# Terraform-practice
The following project uses Amazon Web Services to create the following:
- EC2 Virtual Machine which has read and write permissions to the db and bucket
- MySQL Server with RDS
- S3 bucket hosted for static website hosting
- Network resources needed for the EC2 and RDS db
 
I also provided a Go API to run HTTP requests on the EC2
# DB test 
To test the functionality of the RDS connect to the database using SQL Workbench (https://www.mysql.com/products/workbench/)
![db connection](https://user-images.githubusercontent.com/112562759/206443874-a9d27e08-f948-4fef-9d06-c69a57958199.PNG)


In the case of a successful connection you should see the following:
![sql connection - Copy](https://user-images.githubusercontent.com/112562759/206440579-2589dcf3-d798-4a2d-a576-d04e4f69ae57.PNG)

Next you should run the "data2.0.sql" script in the MySQL Workbench.
To test if this was successful run the following SQL query: SELECT * FROM DevOps.Files
The output should look like this :
![sql script output](https://user-images.githubusercontent.com/112562759/206440956-9bf9791a-b131-4f42-9392-1245ace6d803.PNG)

# API test
The first step for testing the API would be building and tagging the Dockerfile to a container registry then running the docker compose, pulling from 
the registry you used. You will have to enter your RDS endpoint in the docker compose yaml.

You can test this locally to check the api using the 'curl localhost' commannd. The output should be {"message":"okay"}

First you need to copy your docker compose into the EC2 instance using the scp -i VM-key.pem.pem docker-compose.yml <insert ec2 public ipv4 dns here>:~/.

To test the API on the EC2 instance you need to SSH into the instance using the private key 

The command should look like this : ssh -i "VM-key.pem" <insert ec2 public ipv4 dns here>"

Next you should run the following command: docker compose up  -d to run the docker compose in dettached mode

To test the API you should curl <insert EC2 IPv4> which should output {"message":"okay"} and also curl <insert EC2 IPv4>\file\test1.txt which should output
{"id": 1, "filename": "test1.txt", "keyword": "test1", "substitute": "replaced1" }



