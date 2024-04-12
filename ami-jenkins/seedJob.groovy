pipelineJob('webapp_docker_build') {
    description('webapp docker and semantic release job')
  
    logRotator {
      daysToKeep(30)
      numToKeep(20)
    }
      definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/cyse7125-fall2023-group06/webapp.git')
                        credentials('jenkinaccesstoken')
                    }
                    branches('*/main')
                }
                scriptPath('Jenkinsfile')
            }
        }
    }
    triggers {
        githubPush()
    } 
}

pipelineJob('webapp_db_docker_build') {
    description('webapp_db repo docker build job')

    logRotator {
        daysToKeep(30)
        numToKeep(20)
    }
    
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/cyse7125-fall2023-group06/webapp-db.git')
                        credentials('jenkinaccesstoken')
                    }
                    branches('*/main')
                }
                scriptPath('Jenkinsfile')
            }
        }
    }

    triggers {
        githubPush()
    }
}

pipelineJob('helm_chart_semantic_release') {
    description('Helm chart semantic release build job')

    logRotator {
        daysToKeep(30)
        numToKeep(20)
    }
    
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/cyse7125-fall2023-group06/webapp-helm-chart.git')
                        credentials('jenkinaccesstoken')
                    }
                    branches('*/main')
                }
                scriptPath('Jenkinsfile')
            }
        }
    }

    triggers {
        githubPush()
    }
}

pipelineJob('kafka_producer') {
    description('Kafka producer build job')

    logRotator {
        daysToKeep(30)
        numToKeep(20)
    }
    
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/cyse7125-fall2023-group06/kafka-producer.git')
                        credentials('jenkinaccesstoken')
                    }
                    branches('*/main')
                }
                scriptPath('Jenkinsfile')
            }
        }
    }

    triggers {
        githubPush()
    }
}

pipelineJob('kafka_consumer') {
    description('Kafka consumer build job')

    logRotator {
        daysToKeep(30)
        numToKeep(20)
    }
    
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('git@github.com:cyse7125-fall2023-group06/kafka-consumer.git')
                        credentials('jenkinaccesstoken')
                    }
                    branches('*/main')
                }
                scriptPath('Jenkinsfile')
            }
        }
    }

    triggers {
        githubPush()
    }
}

pipelineJob('kube_operator') {
    description('Kube operator build job')

    logRotator {
        daysToKeep(30)
        numToKeep(20)
    }
    
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('git@github.com:cyse7125-fall2023-group06/kube-operator.git')
                        credentials('jenkinaccesstoken')
                    }
                    branches('*/main')
                }
                scriptPath('Jenkinsfile')
            }
        }
    }

    triggers {
        githubPush()
    }
}


pipelineJob('kafka_helm_chart') {
    description('Kafka helm chart build job')

    logRotator {
        daysToKeep(30)
        numToKeep(20)
    }
    
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('git@github.com:cyse7125-fall2023-group06/kafka-helm-chart.git')
                        credentials('jenkinaccesstoken')
                    }
                    branches('*/main')
                }
                scriptPath('Jenkinsfile')
            }
        }
    }

    triggers {
        githubPush()
    }
}