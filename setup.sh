#!/bin/sh

# utils
say(){
	printf "$1" >&2
}

get_distro(){
	if ! [ -f /etc/os-release ]; then
		echo "No distro info" >&2
		exit 1
	fi
	echo $(grep '^NAME=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
}

# get_package_manager(){
# 	local distro=$(get_distro)
# 	case "$distro" in
# 		"Ubuntu" | "Debian")
# 			echo apt-get
# 		;;
# 		"Arch Linux")
# 			echo pacman
# 		;;
# 		*)
# 			echo "Not support distro: $distro" >&2
# 			exit 1
# 		;;
# 	esac
# }

distro_update_prefix(){
	local distro="$1"
	case "$distro" in
		"Ubuntu" | "Debian")
			echo "apt-get update"
		;;
		"Arch Linux")
			echo "pacman -Sy"
		;;
		*)
			echo "Not support distro: $distro" >&2
			exit 1
		;;
	esac
}

distro_install_prefix(){
	local distro="$1"
	case "$distro" in
		"Ubuntu" | "Debian")
			echo "apt-get install -y"
		;;
		"Arch Linux")
			echo "pacman -S --noconfirm"
		;;
		*)
			echo "Not support distro: $distro" >&2
			exit 1
		;;
	esac
}

distro_info_prefix(){
	local distro="$1"
	case "$distro" in
		"Ubuntu" | "Debian")
			echo "apt-cache show"
		;;
		"Arch Linux")
			echo "pacman -Si"
		;;
		*)
			echo "Not support distro: $distro" >&2
			exit 1
		;;
	esac
}
 
get_version(){
	local software="$1"
	local distro=$(get_distro)
	local info_prefix=$(distro_info_prefix "$distro")
	case "$distro" in
		*)
			echo $($info_prefix $software | grep Version | cut -d':' -f2 | tr -d ' ')
		;;
	esac
}



# proxy
select_proxy_software(){
	say "Choose proxy:\n1) v2ray\n2) clash\n"
	read -p "Input a number(default 1): " sel
	if [ -z $sel ]; then
		sel=1
	fi;
	case "$sel" in
		1)
			echo v2ray
			;;
		2)
			echo clash
			;;
		*)
			echo Unknown proxy >&2
			exit -1
			;;
	esac
}


# window manager


# 

# install softwares
proxy=$(select_proxy_software)
echo $proxy
get_version v2ray
