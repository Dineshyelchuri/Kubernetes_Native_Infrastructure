# CSYE7125 - Advanced Cloud Computing

## ami-jenkins

The packer code in this repository is responsible for building an AMI that downloads Caddy, Java, Jenkins and enables Caddy server to reverse proxy the client requests to Jenkins running on port 8080.

## Setting up Packer

The packer fmt command formats the packer script:
```
packer fmt filename
```

The packer validate command validates the syntax of the packer script:
```
packer validate filename
```

The packer build command builds the AMI:
```
packer build filename
```