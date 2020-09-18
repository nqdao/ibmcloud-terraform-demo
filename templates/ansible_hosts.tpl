[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=${private_key_file}
ansible_python_interpreter=/usr/bin/python3

[servers]
%{ for host in hosts ~}
${host}
%{ endfor ~}
