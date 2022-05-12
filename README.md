# boot

this repository includes automated scripts for setting up a development environment on Windows or Mac.  these notes were most recently updated March 2022 while configuring a development environment on Windows 11 Pro.

## prerequisites 
- the computer must be a real machine, not a Windows VM.  see [system-specs](./system-specs.md) for example machine set ups.  
- [github](https://github.com/) account
  + personal access token with "repo" permissions
    + github account > settings > developer settings > personal access tokens > generate new token
- [dockerhub](https://hub.docker.com/) account


## credentials
you will need to keep track of several usernames, passwords, tokens, etc.  a secure password manager is highly recommended.  please note the following as you proceed through the instructions:  

- github username, password, ssh key passphrase 
- dockerhub username, password
- AWS username, password, access token, secret access token (request from AWS system admin)


## install initial software

- [Chrome](https://www.google.com/chrome)
- [Visual Studio Code](https://code.visualstudio.com/)  
- [Docker](https://docs.docker.com/get-docker/)  
  + if necessary, install [WSL 2 Linux kernel](https://docs.microsoft.com/en-us/windows/wsl/install-manua) via separate package
    + install Alpine WSL via Microsoft Store app
    + create UNIX username/password (prompt will pop up after first launch)
  + start Docker Desktop after installation and sign in with dockerhub account
- [git](https://git-scm.com/download)
  + override default branch name to "main"
- [cygwin](https://cygwin.com/cygwin-ug-net/setup-net.html#internet-setup) (required for Windows only)
  + root folder: `C:\cygwin`
  + package folder: `C:\cygwin-packages`
  + packages to install: 
    - install the 'make' package `Devel > make`
    - install the 'git' package
    - install the 'jq' package

## set USERPROFILE and HOME environment variables

### Windows
 
Settings > About > Advanced System Settings > Environment Variables  
Add a USERPROFILE environment variable.  It should look something like one of the following:
`USERPROFILE=C:\Users\natan.MY`
or 
`USERPROFILE=C:\Users\natan`

Next, set HOME to the value of USERPROFILE:
```
HOME=%USERPROFILE%
```

### Mac

HOME variable should be set automatically so no action is necessary here


## run auto-setup commands

### Windows  

1. download this repository as zip: https://github.com/InfernoMfg/boot/archive/refs/tags/1.1.0.zip  
2. move zip file to your documents folder and unzip (ex: `C:\Users\natan.MY\Documents`)  
3. open cygwin and navigate to the repository source code:    
    - `cd /cygdrive/c/Users/natan.MY/Documents/boot`
4. run initial set up commands:
    - `make configure-bash-profile github-username=YOUR_GITHUB_USERNAME github-token=XXX github-token-name=NAME_OF_TOKEN_IN_GITHUB`  
    - `make set-up-git github-username=YOUR_GITHUB_USERNAME email=YOUR_EMAIL`
    - `make configure-cygwin`
    - `make configure-aws aws-profile-name=AWS_PROFILE aws-access-key-id=AWS_ACCESS_KEY_ID aws-secret-access-key=AWS_SECRET_ACCESS_KEY` 
5. STOP! do not proceed until you have added your new github ssh key to your github account

### Mac  

1. download this repository as zip:https://github.com/InfernoMfg/boot/archive/refs/tags/1.1.0.zip   
2. move zip file to your documents folder and unzip (ex: `/Users/ntno/Documents`)  
3. open terminal and navigate to the repository source code:  
    - `cd /Users/ntno/Documents/boot`  
4. run initial set up commands:   
    - `make configure-bash-profile github-username=YOUR_GITHUB_USERNAME github-token=XXX github-token-name=NAME_OF_TOKEN_IN_GITHUB`  
    - `make install-xcode`  
    - `make set-up-git github-username=YOUR_GITHUB_USERNAME email=YOUR_EMAIL`  
    - `make configure-aws aws-profile-name=AWS_PROFILE aws-access-key-id=AWS_ACCESS_KEY_ID aws-secret-access-key=AWS_SECRET_ACCESS_KEY` 
5. STOP! do not proceed until you have added your new github ssh key to your github account


## verify initial git set up  

- close current cygwin/terminal window and open a new one
  - enter your ssh key passphrase if prompted
- follow github's [Testing your SSH connection](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/testing-your-ssh-connection) article to verify your git credentials are set up correctly
