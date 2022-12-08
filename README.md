# Terraform-practice
The following project uses Amazon Web Services to create the following:
- EC2 Virtual Machine which has read and write permissions to the db and bucket
- MySQL Server with RDS
- S3 bucket hosted for static website hosting
- Network resources needed for the EC2 and RDS db
 
# Test guide
To test the functionality of the RDS connect to the database using SQL Workbench (https://www.mysql.com/products/workbench/)
![db connection](https://user-images.githubusercontent.com/112562759/206443874-a9d27e08-f948-4fef-9d06-c69a57958199.PNG)


In the case of a successful connection you should see the following:
![sql connection - Copy](https://user-images.githubusercontent.com/112562759/206440579-2589dcf3-d798-4a2d-a576-d04e4f69ae57.PNG)

Next you should run the "data2.0.sql" script in the MySQL Workbench.
To test if this was successful run the following SQL query: SELECT * FROM DevOps.Files
The output should look like this :
![sql script output](https://user-images.githubusercontent.com/112562759/206440956-9bf9791a-b131-4f42-9392-1245ace6d803.PNG)

