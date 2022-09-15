# Experience test

## Description

This project is a test I got assigned to do. 
My task was to create a simple server application that will be deployed on GCP in multiple regions.
The app had to be containerized and I also had to build a CI/CD pipeline that will automaticly deploy a new version of the app on GCP.
I also had to follow the principal of IaC.

I choose a python app and google run as the service to run my app. For CI/CD I used GitHub Actions.

In the coming sections I will describe step by step how you can make this project work.

## Prerequisite

You will need a GCP account and you will need to clone this repo to your repository. You will also need to make the repo private since we will have to use service keys that are confidential.

## Steps

### Step 1

Go to you GCP account and create a new project (If you don't know how to create a project go to GCP documentation). When you project is created you will get a `project id` you will need this later so save it somewhere.

### Step 2

In your project go under `IAM & Admin > Service Accounts`. Once you are there click on `create service account`. 
The next step is to give it this roles and then save.


![image](https://user-images.githubusercontent.com/25723597/190396342-a2d5cd12-efbd-4f68-b1e9-36096f8f526f.png)

### Step 3

The next step is now to generate a key file. To do that go back to `IAM & Admin > Service Accounts` and click on the account you created. You should then go under keys and click on crete key (see picture below). Chose the JSON format.

![image](https://user-images.githubusercontent.com/25723597/190396795-abc5f9d3-fd72-466e-9116-55895537bfe8.png)

### Step 4

you will now get into the root directory of the project and crete a folder named `.keys`. Into that folder you will paste the JSON file that was just creted. You will also rename the file to `service_key.json`

### Step 5

If you have looked at the code you will notice 3 folders:

`tf-initial-provisioning`
`tf-backend`
`provision-infrastructure`

in each of this folders you will have a `variables.tf` file. Here we store the variables for our terraform files. In each of this files you will have to change the variable `project_id` to your project id that you got in step 1. If necessery you can also change the value for the variable `region` and `zone`.

### Step 6

Since I wanted to work as much as possible with the principals of IaC we will use terraform to enable the APIs for services and create a artifacts regestry and service account for pushing docker images ( this is in the folder `tf-initial-provisioning`). We will also create a bucket in GCP for storing our terraform state ( this is in the folder `tf-backend`). 

Since we will run this files only in the begining I won't push the state to the bucket. THe bucket will be used to keep the state regarding google run.

Now go to folder `tf-initial-provisioning` and first run `terraform init` and the `terraform apply`. 

After that is finished go also in the folder `tf-backend` and run the same commands. When terraform apply finnishes it will output the bucket name. Copy that name and paste it in `/provision-infrastructure/backend.tf`.

### Step 7


