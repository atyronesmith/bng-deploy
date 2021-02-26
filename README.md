# bng-deploy

yum install vim wget git
yum install epel-release
yum install ansible
yum install OpenIPMI ipmitool
yum groupinstall "Virtualization Platform"
yum install fuse -y
yum install qemu-kvm libvirt libvirt-python libguestfs-tools virt-install
yum groupinstall "X Window System"
yum install tcpdump dig bind-utils jq
yum install podman

virt-host-validate
vi /etc/default/grub
grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg

virsh pool-define-as --name default --type dir --target /home/libvirt
virsh pool-autostart default

## firewall

firewall-cmd --zone internal --change-interface=br-ctrlplane
firewall-cmd --zone=internal --permanent --add-port=67/udp
firewall-cmd --zone=internal --permanent --add-port=53/udp
firewall-cmd --zone=internal --permanent --add-port=67/tcp
firewall-cmd --zone=internal --permanent --add-port=53/tcp
firewall-cmd --zone=internal --add-masquerade --permanent
firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -o p3p2 -j MASQUERADE
firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -i br-ctrlplane -o p3p2 -j ACCEPT
firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -i p3p2 -o br-ctrlplane -m state --state RELATED,ESTABLISHED -j ACCEPT
firewall-cmd --reload
