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

In your project go under `IAM & Admin > Service Accounts`. Once you are there click on `create service account`. Now give it a name and save it.

The next step is to go under `IAM & Admin > IAM` find your create account and give it this roles ![image](https://user-images.githubusercontent.com/25723597/190396342-a2d5cd12-efbd-4f68-b1e9-36096f8f526f.png)


