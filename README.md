This project is based on an idea and code used in [jenkins packer](https://github.com/GoogleCloudPlatform/kube-jenkins-imager) 
project by [evandbrown](https://github.com/evandbrown) - big thanks for sharing this! I wanted to make it more elastic, self-contained and production ready ("more ready", not "totaly ready").
Nevertheless, this is still entirely based on Google Cloud Platform, Container Service and Container Registry.

The aim of this project is to setup from zero a jenkins swarm, which can build and store in a private repo docker images based on Dockerfiles kept in git repository. After completing the tutorial below, you will be able to run a complete CI/CD platform based on docker, kubernetes and jenkins.

If you didn't read the description of the original project, you should probably [do so now](https://github.com/GoogleCloudPlatform/kube-jenkins-imager). Here's what's different in here:
  - I assumed, that using publicly available, constantly changing docker images for a production deployment is a no-go. Hence, 
    here a private docker repository is easily set up and initial images are created in-house to make sure that they are exactly 
    as you want them and that they won't change without your knowledge
  - [Google Container Registry](https://cloud.google.com/container-registry/) is used as a storage and private repository of your own docker images
  - Jenkins' configuration is backed up using not Google Cloud Storage, but [jenkins SCM plugin](https://wiki.jenkins-ci.org/display/JENKINS/SCM+Sync+configuration+plugin), 
    which keeps configuration files in git - what's better, than auto-versioning and off-site replica of your build enviromenet configuration?
  - there is a "bootstrap" part, which gives you easy to use scripts to setup SSL certificates, SSH keys (security setup is mandatory) and initial docker images needed to create your
    project from zero to working jenkins in a few minutes (or so I hope)
  - jankins master pod is using persistant GCE disk, so it should survive both pod and virtual machine restarts/failures
  - all necessary project-specific information is injected into required templates without a need to modify them by yourself
  - setup and tear down can be made in one step or as a series of controlled sub-steps
  - all security data can be kept outside the project
  - it is easy to add next services in your kubernetes cluster using the examples provided
  - I removed "packer" from the set of tools - I just want to build my images using Dockerfiles

OK, enough of talking, let's go!

# 1. Setup your Google Cloud Platform account #
1. Register and launch for your [GCP account](https://cloud.google.com/). Remember, that if you never did so, you can use [free credits](https://cloud.google.com/free-trial/),
   which are more than enough to test this setup.  
1. Create new project in GCP using the top menu in developers console. Select project name and set project ID under "edit" options (not necessary, but convienient).
1. Enable APIs: in the left side menu go to "APIs & auth", tahn "APIs". Search for "Google Container Engine API", select it and click "Enable API" button on the next page.
   You may also activate "Google Cloud Monitoring API" while you're there - it can be useful in the future.
1. Install "gcloud sdk" on your system, as [described here](https://cloud.google.com/sdk/)
1. Install necessary features for gcloud, run:
```
gcloud components update beta
gcloud components update kubectl
```

# 2. Project setup #
1. Checkout this repository
1. Goto "etc" and copy "config.template" into "config"
   *Warning: you need to make sure that your config file is safe and readable only to authorized people. Consider putting it on an encpryted drive and only
   sym-linking it to the destination when you do the deployment*
1. Edit "etc/config" and be sure to set at least the following settings
     - ```PROJECT=project_name_from_GCP``` - set this the the project's name set in GCP
     - ```GIT_CFG_BACKUP_HOST=bitbucket.org``` and ```GIT_CFG_BACKUP_REPO=git@yourhost\/user:repo.git``` if you want to use auto configuration backup kept in git (this git repository must exist)
     - ```JENKINS_SLAVE_PASSWORD=<PASSWORD>``` - set this to something long and random. You wan't need to remember this password, it will be used by jenkins slaves to connect to the master.
     - ```CLUSTER_NAME=my-cluster``` - this will be your cluster name

# 3. Docker images bootstrap #
Now we will configure, build and push to the private registry necessary docker images for jenkins master and slave.

1. Go to the "bootstrap" folder
1. Create directory named "certs". *Keep the content of this directory secret!* This directory will contain SSL certificates and SSH keys used by your jenkins installation
     - if you wan't to just "test drive" this project, run "00-bootstrap-secrets.sh" and it will generate everything that is needed for you (it takes a while) - or -
     - if you have your own certificates and keys, place them in the certs directory under the names: "jenkins.key", "jenkins.crt" and "dhparam.pem"
1. encode your secrets (however you got them) into kubernetes secret object: ```./01-insert-secrets.sh```
1. Create and push docker images, either:
     - run ```./bootstrap-all.sh``` and all images should be generated - or -
     - run in sequence all scripts starting with "10-13*" prefixes (check theirs code if you want :)
1. Go to your GCP console, select "Compute", "Container Engine", "Container Registry" and check that your fresh docker images are there

# 4. Create the kubernetes/GKE cluster #
1. Go back to the main project directory
1. Create the cluster
  - either do it in one go ```./all-up.sh``` or all run scripts prefixed "00-11*" manualy and in sequence
1. Look for a line that starts "Jenkins SSL proxy available under" and copy the following URL 
1. make sure that the content of "working_files" directory is removed when the deploy finish - it contains passwords, certificates and keys used to deploy the project!

# 5. Jenkins setup #
1. Paste the copied jenkins SSL proxy URL into the browser
1. Go to "Manage Jenkins", "Configure Global Security". Check "Enable security". In "Security Realm" select "Jenkins’ own user database". Make sure that "Allow registration" checkbox below is marked. In "Authorization" select "Anyone can do anything". Click "Save". Return to the main page. In the upper-right corner select "Create account" and fill your user's data. Then login into jenkins using the new account. Again, go to "Manage Jenkins", "Configure Global Security". In "Authorization" select "Matrix-based security", in the text box enter your username and click "Add". Then select all permissions possible for your user. Click "Save". Once again go to the security settings and uncheck the box "Allow registration".
1. Add a user for the slave to aythenticate. Go to "Manage Jenkins", "Manage Users" and create a user named "slave" with password exactly the same as in your config file (this project's config file, you chosen the password in step 2.). Again, go to security and in the permissions matrix add user "slave", then select for it the following permissions: in section "Overall" select "read" and in "Slave" check everything. Click "Save". Now your jenkins is secured and slave should be connected and ready. Enjoy your jenkins!
1. If you want your jenkins to be always in english, even when your browser sends other languages in headers, go to "Manage Jenkins", "ConfigureSystem" and under "Default Language" enter "en_US" and check the checkbox below.

# 6. Build your own docker project! #
OK, jenkins is ready, let's build something!
1. Create a new docker repo for yourself, for example on [bitbucket.org](https://bitbucket.org/). In this repository create a simple file named "Dockerfile", with some simple build steps like:
```
FROM ubuntu:trusty
MAINTAINER anon@no.ne

RUN apt-get update \
	&& apt-get install -y curl \
	&& rm -rf /var/lib/apt/lists/*

RUN touch /tmp/tubylem-tony-halik
```
1. In jenkins select "New Item", then give it a name and select "freestyle project". Click "OK". 
1. Prepare a public/private key pair that allows for git access to the repository with the Dockerfile. Here we will use a jenkins' master private key generated during project setup (and used for keeping the configuration of jenkins in git). You can find that key in "bootstrap/certs/id_rsa". Grab "id_rsa.pub" and add it as am access key for the git repository (on bitbucket.org you may add this key as a [deployment key](https://confluence.atlassian.com/display/BITBUCKET/Use+deployment+keys). If you want to use other key pair, you need to add the private key in jenkins' "Credentials" section.
1. In build settings check "Restrict where this project can be run" and enter "jenkins-dind-slave".
1. In "Source Code Management" select git, enter repo URL and if you want to use existing jenkins' key click Credentials "Add", then select "SSH username with private key", change username to "git" and then select "From the Jenkins master ~/.ssh". Click "add" and select newly created credentials (if they don't show up, click "Save" and reload the configuration page).
1. Under "build" click "Add build step" and select "Execute shell". Enter a script simillar to:
```
#!/bin/bash

cd ubuntu-mono/
PROJECT="<PROJECT>"
IMAGE="docker-image-mono"
REG="eu.gcr.io/<PROJECT>"

GC=${GIT_COMMIT:0:8}
LATEST="${REG}/${IMAGE}:latest"
COMMIT="${REG}/${IMAGE}:master-${GC}"

docker build --pull -t ${LATEST} .
docker tag -f ${LATEST} ${COMMIT}

gcloud docker push ${LATEST}
gcloud docker push ${COMMIT}

docker rmi ${LATEST}
docker rmi ${COMMIT}

```
Save the config. Remember to replace <PROJECT> with your own project name. This script will checkout the repository, build an image according to the Dockerfile, tag it and push into your private docker GCR repository. That's it! Now you can just run the images.
1. Oh, wait. There's just one more cool thing you can setup. If you use the created docker images to run pods on Container Engine, you can setup a post-build script in jenkins to auto roll updates after a new image is build. This way you get a Continous Deployment in a one line long script! Just add something like:
```
kubectl rolling-update rc-my-service --image=eu.gcr.io/<PROJECT>/docker-test-image:latest
```


# 7. Clean up #
Just run ```./all-down.sh``` and cluster and virtual machines will be deleted. *Please note* that this script won't remove your docker images in GCR and jenkins master's persistant GCE disk
