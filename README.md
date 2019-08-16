# packer-aws-es

Packer based project for provisioning an "Elasticsearch" image using Ansible remote, 
and Serverspc, for AWS, or Virtualbox, with Elastic monitoring.

## Requirements

To use this project, you must have installed:
- [Packer](https://www.packer.io/downloads.html)
- [Ansible](http://docs.ansible.com/ansible/latest/intro_installation.html)
- [Serverspec](http://serverspec.org/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
- [jq](https://stedolan.github.io/jq/)

(Optional)
- [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
- [Vagrant](https://www.vagrantup.com/downloads.html)



## Install
```shell
git clone --recurse-submodules https://github.com/apolloclark/packer-es
cd ./packer-es

# update submodules
git submodule update --recursive --remote
```



## Deploy to Docker
```shell
# build both the Ubuntu 16.04 and Centos 7.6 images
./build_packer_docker_all.sh



# clean up ALL previous builds
./clean_packer_docker.sh

# Gradle, clean up previous builds, from today
gradle clean --parallel --project-dir gradle-build

# Gradle, build all images, in parallel
gradle test --rerun-tasks --parallel --project-dir gradle-build

# Gradle, build only specific OS images
gradle ubuntu18.04:test --project-dir gradle-build --rerun-tasks
gradle ubuntu16.04:test --project-dir gradle-build --rerun-tasks
gradle debian10:test    --project-dir gradle-build --rerun-tasks
gradle debian9:test     --project-dir gradle-build --rerun-tasks

gradle rhel8:test     --project-dir gradle-build --rerun-tasks
gradle rhel7:test     --project-dir gradle-build --rerun-tasks
gradle centos7:test   --project-dir gradle-build --rerun-tasks
gradle amzlinux2:test   --project-dir gradle-build --rerun-tasks

gradle test --parallel --max-workers 4 --project-dir gradle-build

# Gradle, publish images
gradle push --parallel --max-workers 4 --project-dir gradle-build

# Gradle, list tasks, and dependency graph
gradle tasks --project-dir gradle-build
gradle tasks --all --project-dir gradle-build
gradle test taskTree --project-dir gradle-build

# Gradle, debug
gradle properties
gradle ubuntu16.04:info --project-dir gradle-build
gradle ubuntu16.04:test --project-dir gradle-build --info --rerun-tasks
rm -rf ~/.gradle
```



## Deploy to AWS, with Packer
```shell
git clone https://github.com/apolloclark/packer-aws-es
cd ./packer-aws-es/config
# create a keypair named "packer" or change lines 26, 27 in build_packer_aws.sh
./build_packer_aws.sh
```



## Deploy to Virtualbox, with Vagrant
```shell
git clone https://github.com/apolloclark/packer-aws-es
cd ./packer-aws-es/config
vagrant up
vagrant ssh
```

## Ansible

Ansible Roles:
- [geerlingguy.firewall](https://github.com/geerlingguy/ansible-role-firewall)
- [apolloclark.elasticsearch](https://github.com/apolloclark/ansible-role-elasticsearch)
<br/><br/><br/>



## Log Files

*Elasticsearch*
```
# Elasticsearch 5.x cheat sheet
# https://gist.github.com/apolloclark/c9eb0c1a01798ac2e48492ceeb367a4f

service elasticsearch status
/usr/share/elasticsearch/bin/elasticsearch --version
/usr/share/elasticsearch/bin/elasticsearch-plugin -h
/usr/share/elasticsearch/bin/elasticsearch-plugin install ingest-geoip -b
nano /etc/elasticsearch/elasticsearch.yml
nano /var/log/elasticsearch/elasticsearch.log
tail -f /var/log/elasticsearch/elasticsearch.log

# list indices
curl -s -XGET 'http://127.0.0.1:9200/_cat/indices?v'

# list documents in a given index
curl -s -XGET 'http://127.0.0.1:9200/filebeat-*/_search?q=system.syslog.message:*&size=10000'

# list documents in a given index, parse results
curl -s -XGET 'http://127.0.0.1:9200/filebeat-*/_search?q=source:\/var\/log\/auth.log&size=10000' | \
  jq '.hits.hits[]._source | select (.!=null)'
  
# delete index
curl -s -XDELETE 'http://127.0.0.1:9200/auditbeat-*/'
```
