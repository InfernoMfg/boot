SHELL:=/bin/bash
in_cygwin := $(shell which cygpath 1> /dev/null 2> /dev/null;  echo $$?)
home_dir := $(shell echo "$$HOME")
curr_dir := $(shell pwd)
git_ssh_key_file_path := $(shell echo "$(home_dir)/.ssh/id_ed25519")

VS_CODE_SETTING_SNIPPET=`jq --null-input --arg bat_file "$$USERPROFILE\\cygpath-git-vscode.bat" '{"git.path": $$bat_file}'`

ifeq (0, $(in_cygwin))
	platform := "windows"
else
	platform := "unix"
endif

set-up-initial-directories:
	@mkdir -p "$(home_dir)/.ssh"
	@mkdir -p "$(home_dir)/.aws"

configure-bash-profile: check-platform check-github-username check-github-token check-github-token-name
	@cp ./templates/$(platform)/.bash_profile.tpl "$(home_dir)/.bash_profile"
	@sed -i -e "s/GITHUB_USERNAME/$(github-username)/g" "$(home_dir)/.bash_profile"
	@sed -i -e "s/GITHUB_TOKEN_NAME/$(github-token-name)/g" "$(home_dir)/.bash_profile"		
	@sed -i -e "s/GITHUB_TOKEN/$(github-token)/g" "$(home_dir)/.bash_profile"
ifeq ($(platform), "windows")
	@cp ./templates/$(platform)/.bashrc "$(home_dir)/.bashrc"
endif

configure-cygwin: configure-cygwin-home configure-vscode-as-external-git-editor fix-vscode-git-integration fix-cygwin-git-filemode

configure-cygwin-home: check-platform
ifeq ($(platform), "windows")
	@cp ./templates/$(platform)/nsswitch.conf /etc/nsswitch.conf
endif

#TODO - need to refactor so that if you run git set up you don't lose core.editor setting
configure-vscode-as-external-git-editor: check-platform
ifeq ($(platform), "windows")
	@cp ./templates/$(platform)/cygpath-git-editor.sh "$(home_dir)/cygpath-git-editor.sh"
	@chmod +x "$(home_dir)/cygpath-git-editor.sh"
	@git config --global core.editor "$(home_dir)/cygpath-git-editor.sh"
endif

fix-cygwin-git-filemode: check-platform
ifeq ($(platform), "windows")
	@git config --global core.filemode true
endif

fix-vscode-git-integration: check-platform
ifeq ($(platform), "windows")
	@cp ./templates/$(platform)/cygpath-git-vscode.bat "$(home_dir)/cygpath-git-vscode.bat"
	@echo "$(VS_CODE_SETTING_SNIPPET)" >  ~/AppData/Roaming/Code/User/git-path.json
	@cp -f ~/AppData/Roaming/Code/User/settings.json ~/AppData/Roaming/Code/User/settings.json.bak
	@jq -s add  ~/AppData/Roaming/Code/User/settings.json.bak ~/AppData/Roaming/Code/User/git-path.json > ~/AppData/Roaming/Code/User/settings.json
endif

#https://apple.stackexchange.com/questions/254380/why-am-i-getting-an-invalid-active-developer-path-when-attempting-to-use-git-a
install-xcode: check-platform
ifeq ($(platform), "unix")
	xcode-select --install
endif

create-git-ssh-key: check-email set-up-initial-directories prompt-git-create-ssh-key
	ssh-keygen -t ed25519 -C "$(email)" -f $(git_ssh_key_file_path)
	@chmod 700 $(git_ssh_key_file_path)
	@$(MAKE) --no-print-directory prompt-user-to-complete-setup
	
prompt-git-create-ssh-key:
	@echo ">>>> enter a password when prompted (password is required in order for key to be used with github)"

prompt-user-to-complete-setup:
	@echo ">>>> create a new SSH Key in [github](https://github.com/settings/ssh/new)."
	@echo ">>>> use name='$(email)'" 
	@echo ">>>> use key='$(shell cat $(git_ssh_key_file_path).pub)'"

configure-git: check-github-username 
	@cp ./templates/git/.gitignore_global 			"$(home_dir)/.gitignore_global"
	@cp ./templates/git/.gitconfig.tpl				"$(home_dir)/.gitconfig"
	@sed -i -e "s/GITHUB_USERNAME/$(github-username)/g" 	"$(home_dir)/.gitconfig"

configure-aws: check-aws-access-key-id check-aws-secret-access-key check-aws-profile-name set-up-initial-directories
	@cp ./templates/aws/config "$(home_dir)/.aws/config"
	@cp ./templates/aws/credentials "$(home_dir)/.aws/credentials"
	@chmod 600 "$(home_dir)/.aws/credentials"
	@sed -i -e "s/AWS_PROFILE_NAME/$(aws-profile-name)/g" 	"$(home_dir)/.aws/config"
	@sed -i -e "s/AWS_PROFILE_NAME/$(aws-profile-name)/g" 	"$(home_dir)/.aws/credentials"
	@sed -i -e "s/AWS_ACCESS_KEY_ID/$(aws-access-key-id)/g" 		"$(home_dir)/.aws/credentials"
	@sed -i -e "s|AWS_SECRET_ACCESS_KEY|$(aws-secret-access-key)|g" "$(home_dir)/.aws/credentials"

set-up-git: configure-git create-git-ssh-key


check-email:
ifndef email
	$(error email is not defined)
endif

check-github-username:
ifndef github-username
	$(error github-username is not defined)
endif

check-github-token:
ifndef github-token
	$(error github-token is not defined)
endif

check-github-token-name:
ifndef github-token-name
	$(error github-token-name is not defined)
endif
check-aws-access-key-id:
ifndef aws-access-key-id
	$(error aws-access-key-id is not defined)
endif

check-aws-secret-access-key:
ifndef aws-secret-access-key
	$(error aws-secret-access-key is not defined)
endif

check-aws-profile-name:
ifndef aws-profile-name
	$(error aws-profile-name is not defined)
endif

check-platform:
ifndef platform
	$(error platform is not defined)
endif