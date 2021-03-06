#!/bin/bash

anylink_env_load(){

	tmp_dir=/tmp/anylink_tmp
	mkdir -p ${tmp_dir}
	program_version=(0)
	soft_name=anylink
	url='https://github.com/bjdgyc/anylink'
	select_version
	online_version
	install_dir_set
}

anylink_set(){
	vi ${workdir}/config/anylink/anylink.conf
	. ${workdir}/config/anylink/anylink.conf
}

anylink_down(){
	
	down_url="${url}/releases/download/v${detail_version_number}/anylink-deploy-v${detail_version_number}.tar.gz"
	online_down_file
}

anylink_install(){
	home_dir=${install_dir}/anylink
	mkdir -p ${home_dir}
	unpacking_file ${tmp_dir}/anylink-deploy-v${detail_version_number}.tar.gz ${tmp_dir}
	cp -rp ${tar_dir}/* ${home_dir}
	chmod -R +x ${home_dir}/bin
}

anylink_config(){
	cd ${home_dir}/conf
	#自签证书
	#openssl genrsa -des3 -out vpn.key 2048
	#openssl rsa -in vpn.key -out vpn.key
	#openssl req -utf8 -x509 -new -nodes -key vpn.key -sha256 -days 36500 -out vpn.pem
	#openssl pkcs12 -export -in vpn.pem -inkey vpn.key -out vpn.p12
	admin_pass=`${home_dir}/bin/anylink -passwd ${admin_passwd} | awk -F : '{print $2}'`
	jwt_secret=`${home_dir}/bin/anylink -secret | awk -F : '{print $2}'`
	sed -i "s/issuer =.*/issuer = ${vpn_name}/" server.toml
	sed -i "s/link_addr =.*/link_addr = \"${link_addr}\"/" server.toml
	sed -i "s/server_addr =.*/server_addr = \"${server_addr}\"/" server.toml
	sed -i "s/admin_addr =.*/admin_addr = \"${admin_addr}\"/" server.toml
	sed -i "s/admin_pass =.*/admin_pass = \"${admin_pass}\"/" server.toml
	sed -i "s/jwt_secret =.*/jwt_secret = \"${jwt_secret}\"/" server.toml
	ip_forward=$(cat /etc/sysctl.conf | grep 'net.ipv4.ip_forward = 1')
	if [[ -z ${ip_forward} ]];then
		echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
		sysctl -p > /dev/null
	fi
}

add_anylink_service(){
	WorkingDirectory="${home_dir}/anylink"
	ExecStart="${home_dir}/anylink"
	conf_system_service	${home_dir}/anylink.service
	add_system_service anylink ${home_dir}/anylink.service
	service_control anylink y

}


anylink_install_ctl(){
	anylink_env_check
	anylink_env_load
	anylink_set
	anylink_down
	anylink_install
	anylink_config
	add_anylink_service
}


