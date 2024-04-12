variable "region" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "private_subnets" {
  type = number
}

variable "credentials" {
  type = string
}

variable "first_project" {
  type = string
}

variable "org_id" {
  type = string
}

variable "billing_id" {
  type = string
}

variable "ssh_username" {
  type = string
}

variable "ssh_key_path" {
  type = string
}

variable "k8s_pod_range" {
  type = string
}

variable "k8s_service_range" {
  type = string
}

variable "master_ipv4_cidr_block" {
  type = string
}

variable "jenkins_cidr_block" {
  type = string
}

variable "ssh_private_key" {
  type = string
}

variable "node_machine_type" {
  type = string
}

variable "min_node_count" {
  type = number
}

variable "max_node_count" {
  type = number
}