# Experience test

## Description

This project is a test I got assigned to do. 
My task was to create a simple server application that will be deployed on GCP in multiple regions.
The app had to be containerized and I also had to build a CI/CD pipeline that will automaticly deploy a new version of the app on GCP.
I also had to follow the principal of IaC.

I choose a python app and google run as the service to run my app. For CI/CD I used GitHub Actions.

In the coming sections I will describe step by step how you can make this project work.

## Prerequisite

You will need a GCP account and you will need to clone this repo to your repository. You will also need to make the repo private when you publish it on GitHub since we will have to use service keys that are confidential.

You will have to publish the repo on GitHub for it to work, since we use GitHub actions for our CI/CD pipeline.

## Steps

### Step 1

Go to you GCP account and create a new project (If you don't know how to create a project go to GCP documentation). When you project is created you will get a `project id` you will need this later so save it somewhere.

### Step 2

In your project go under `IAM & Admin > Service Accounts`. Once you are there click on `create service account`. 
The next step is to give it this roles and then save.


![image](https://user-images.githubusercontent.com/25723597/190426785-9745f6d5-7f38-425d-a9dc-1dd0e86bc248.png)

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

Since I wanted to work as much as possible with the principals of IaC we will use terraform to enable the APIs for services and create a artifacts registry and service account for pushing docker images ( this is in the folder `tf-initial-provisioning`). We will also create a bucket in GCP for storing our terraform state ( this is in the folder `tf-backend`). 

Since we will run this files only in the begining I won't push the state to the bucket. The bucket will be used to keep the state regarding google run.

Now go to folder `tf-initial-provisioning` and first run `terraform init` and the `terraform apply`. 

After that is finished go also in the folder `tf-backend` and run the same commands. If terraform apply fails ( sometimes happens error 403), delete all files inside `tf-backend` execpt for `main.tf` and `variables.tf` and then repeat terraform init and apply. When terraform apply finnishes it will output the bucket name. Copy that name and paste it in `/provision-infrastructure/backend.tf`.

### Step 7

Now we move To Github where we will go under `settings/secrets/actions`. Here we will create 2 repository secrets ( for the code to work please name them the same as I did).

The first is GCP_SERVICE_KEY. here we paste the content from or service_key.json file and then save the secret.

The second is REGISTRY_SERVICE_KEY. Go back to GCP to the `IAM & Admin > Service Accounts`. You will finde a new service account docker pusher that was created with terraform code from the `tf-initial-provisioning` folder ( sometimes the service is not visible so i refreshed the page and it worked, you can also try to re-run terraform init and apply inside `tf-initial-provisioning` if for some reason it didn't work). Like in step 3 generate a key. YOu will paste the content of this key to the secret ( you can also store it in .keys folder for future needs).

![image](https://user-images.githubusercontent.com/25723597/190438376-f4a5f409-92f7-4047-81aa-a9fb6d1f8520.png)


### Step 8

Now go to the folder .github/workflows and edit the yaml file inside. Under env. You vil si a variable PROJECT_ID. Paste your project id as the values. 

![image](https://user-images.githubusercontent.com/25723597/190438531-06aef5fe-6794-40fd-9f64-9c5c61805049.png)


### Step 9

Now if you commit and push to Github it should automaticly trigger the CI/CD pipeline that will build and deploy our app in 3 different cloud run regions ( the workflow trigers when a commit is made in the main branch).
You will also see inside you workflow execution that under the step Terraform apply there will be an IP in the end. Use that IP to access you application.

![image](https://user-images.githubusercontent.com/25723597/190438665-bed1795f-4965-4f21-854b-26bad2bc96b4.png)

## Final thoughts

To tell a little more about the project.

There is a load balancer in front that routes the traffic and I also had to create NEGs because we have multiple cloud run instances.

I used google run for this but you could also use GKE to deploy your container service ( could be another project)

If you have any more questions regarding this project please contact me.


