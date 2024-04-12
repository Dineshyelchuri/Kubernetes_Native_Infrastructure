curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg

curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list

sudo apt update

sudo apt install caddy -y

sudo apt install openjdk-11-jdk -y

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update

sudo apt-get install fontconfig openjdk-11-jre -y

sudo apt-get install jenkins -y

sudo systemctl stop caddy

sudo chown ubuntu:ubuntu /etc/caddy/Caddyfile

cat << EOF > /etc/caddy/Caddyfile
$DOMAIN {
    reverse_proxy localhost:8080
}
EOF

cat /etc/caddy/Caddyfile

sudo systemctl enable caddy

sudo systemctl start caddy

# sudo caddy reverse-proxy --from jenkins.hellodocker.com --to :8080 &

sudo apt update

sudo apt install -y     apt-transport-https     ca-certificates     curl     gnupg     lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io

sudo docker --version

sudo docker buildx version

sudo systemctl enable docker

sudo systemctl start docker

sudo systemctl status docker

sudo usermod -aG docker jenkins

grep docker /etc/group

sudo systemctl restart docker

sudo docker buildx create --name webapplication

sudo docker buildx use webapplication

sudo docker run --rm --privileged multiarch/qemu-user-static --reset -p yes


wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.13/jenkins-plugin-manager-2.12.13.jar


cat << EOF > install_plugins.txt
ws-cleanup:latest
workflow-support:latest
workflow-step-api:latest
workflow-scm-step:latest
workflow-multibranch:latest
workflow-job:latest
workflow-durable-task-step:latest
workflow-cps:latest
workflow-basic-steps:latest
workflow-api:latest
workflow-aggregator:latest
variant:latest
trilead-api:latest
token-macro:latest
timestamper:latest
structs:latest
sshd:latest
ssh-slaves:latest
ssh-credentials:latest
snakeyaml-api:latest
script-security:latest
scm-api:latest
resource-disposer:latest
prism-api:latest
plugin-util-api:latest
plain-credentials:latest
pipeline-stage-view:latest
pipeline-stage-tags-metadata:latest
pipeline-stage-step:latest
pipeline-rest-api:latest
pipeline-model-extensions:latest
pipeline-model-definition:latest
pipeline-model-api:latest
pipeline-milestone-step:latest
pipeline-input-step:latest
pipeline-groovy-lib:latest
pipeline-graph-analysis:latest
pipeline-github-lib:latest
pipeline-build-step:latest
pam-auth:latest
okhttp-api:latest
multibranch-scan-webhook-trigger:latest
mina-sshd-api-core:latest
mina-sshd-api-common:latest
maven-plugin:latest
matrix-project:latest
matrix-auth:latest
mailer:latest
ldap:latest
junit:latest
jsch:latest
jquery3-api:latest
job-dsl:latest
jjwt-api:latest
jdk-tool:latest
jaxb:latest
javax-mail-api:latest
javax-activation-api:latest
javadoc:latest
jakarta-mail-api:latest
jakarta-activation-api:latest
jackson2-api:latest
ionicons-api:latest
instance-identity:latest
gradle:latest
github:latest
github-branch-source:latest
github-api:latest
git:latest
git-client:latest
font-awesome-api:latest
email-ext:latest
echarts-api:latest
durable-task:latest
docker-workflow:latest
docker-plugin:latest
docker-java-api:latest
docker-commons:latest
docker-build-step:latest
display-url-api:latest
credentials:latest
credentials-binding:latest
configuration-as-code:latest
configuration-as-code-groovy:latest
commons-text-api:latest
commons-lang3-api:latest
command-launcher:latest
cloudbees-folder:latest
cloud-stats:latest
checks-api:latest
caffeine-api:latest
build-timeout:latest
branch-api:latest
bouncycastle-api:latest
bootstrap5-api:latest
basic-branch-build-strategies:latest
authentication-tokens:latest
apache-httpcomponents-client-5-api:latest
apache-httpcomponents-client-4-api:latest
antisamy-markup-formatter:latest
ant:latest
golang:1.20
EOF

cat << 'EOF' > install_plugins.sh
#!/bin/bash
while IFS= read -r plugin
do
    echo "Installing plugin: $plugin..."
    sudo java -jar jenkins-plugin-manager-2.12.13.jar --war /usr/share/java/jenkins.war --plugin-download-directory /var/lib/jenkins/plugins --plugins "$plugin"
done < /home/ubuntu/install_plugins.txt
EOF

chmod +x install_plugins.sh

./install_plugins.sh


curl -sL https://deb.nodesource.com/setup_16.x -o /tmp/nodesource_setup.sh

sudo bash /tmp/nodesource_setup.sh

sudo apt install nodejs -y

sudo node -v

sudo npm install -g semantic-release@17.4.4

sudo npm install -g @semantic-release/git@9.0.0

sudo npm install -g @semantic-release/exec@5.0.0

sudo npm install -g conventional-changelog-conventionalcommits

sudo npm install -g npm-cli-login

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm -y

sudo apt-get install make -y

sudo apt-get install kubectl

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

sudo apt-get update && sudo apt-get install -y google-cloud-sdk








