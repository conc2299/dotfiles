#!/bin/sh

data_file="softwares.data"

# utils
say(){
	printf "$1" >&2
}

get_distro(){
	if ! [ -f /etc/os-release ]; then
		say "No distro info\n"
		exit 1
	fi
	echo $(grep '^NAME=' /etc/os-release | cut -d'=' -f2 | tr -d '"' | sed 's/ /_/g')
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
		"Arch_Linux")
			echo "pacman -Sy"
		;;
		*)
			say "Not support distro: $distro\n"
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
		"Arch_Linux")
			echo "pacman -S --noconfirm"
		;;
		*)
			say "Not support distro: $distro\n"
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
		"Arch_Linux")
			echo "pacman -Si"
		;;
		*)
			say "Not support distro: $distro\n"
			exit 1
		;;
	esac
}
 
get_package_version(){
	local software="$1"
	local distro=$(get_distro)
	local info_prefix=$(distro_info_prefix "$distro")
	case "$distro" in
		*)
			echo $($info_prefix $software | grep Version | cut -d':' -f2 | tr -d ' ')
		;;
	esac
}

# utils for this particular script

# return empty string if not found
get_record_value_when(){
	local file="$1"
	local query_field="$2"
	local when_field="$3"
	local when_value="$4"
	if ! [ -f "$file" ]; then
		say "No data file: $file\n"
		exit 1
	fi
	echo $(awk -F'[[:space:]]+' -v wf="$when_field" -v wv="$when_value" -v qf="$query_field" '
		NR == 1 { 
			for(i=1;i<=NF;i++) {
				if ($i==wf) { when_index=i }
				if ($i==qf) { field_index=i }
			}
			if (!when_index) {exit 1}
			if (!field_index) {exit 1}
			next
		}
		$when_index == wv {
			print $field_index
		}
	' "$file")
}

get_required_version(){
	local software="$1"
	local file="$2"
	echo $(get_record_value_when "$file" "version" "name" "$software")
}

get_required_package_name(){
	local software="$1"
	local file="$2"
	local distro="$3"
	echo $(get_record_value_when "$file" "$distro" "name" "$software")
}

# version compare using SemVer rules
compare_semver() {
  awk -v a="$1" -v b="$2" '
  BEGIN {
    # split into fields by dot
    nA = split(a, A, "\\.")
    nB = split(b, B, "\\.")
    max = (nA > nB ? nA : nB)

    for (i = 1; i <= max; i++) {
      pa = (i in A ? A[i] : "0")
      pb = (i in B ? B[i] : "0")

      # if entirely digits -> numeric value, else treat as 0
      if (pa ~ /^[0-9]+$/) pa_num = pa + 0
      else pa_num = 0

      if (pb ~ /^[0-9]+$/) pb_num = pb + 0
      else pb_num = 0

      if (pa_num < pb_num) { print -1; exit 0 }
      if (pa_num > pb_num) { print 1; exit 0 }
      # otherwise equal, continue
    }
    print 0
  }'
}

check_version_meet_requirement(){
	local current_version="$1"
	local required_version="$2"
	local compare=${required_version%%[0-9]*}
	case "$compare" in
		">=")
			comp=$(compare_semver "$current_version" "${required_version#">="}")
			if [ "$comp" -ge 0 ]; then
				return 0
			fi
			;;
		">")
			comp=$(compare_semver "$current_version" "${required_version#">="}")
			if [ "$comp" -gt 0 ]; then
				return 0
			fi
			;;
		"<=")
			comp=$(compare_semver "$current_version" "${required_version#"<="}")
			if [ "$comp" -le 0 ]; then
				return 0
			fi
			;;
		"<")
			comp=$(compare_semver "$current_version" "${required_version#"<"}")
			if [ "$comp" -lt 0 ]; then
				return 0
			fi
			;;
		"==")
			comp=$(compare_semver "$current_version" "${required_version#"=="}")
			if [ "$comp" -eq 0 ]; then
				return 0
			fi
			;;
		*)
		 	say "Unknown version compare operator: $compare\n"
			exit 1
			;;
	esac
	return 1
}

install_package(){
	local software="$1"
	local package_version=$(get_package_version "$software")
	local required_version=$(get_required_version "$software" "$data_file")
	if [ -z "$required_version" ]; then
		say "No required version for $software, skip version check\n"
		required_version=">=0.0.0"
	fi
	if check_version_meet_requirement "$package_version" "$required_version"; then
		say "$software version $package_version meets requirement $required_version, install from package manager\n"
		distro="$(get_distro)"
		package_name="$(get_required_package_name "$software" "$data_file" "$distro")"
		install_cmd="$(distro_install_prefix "$distro") $package_name"
		say "Running command: $install_cmd\n"
		sudo $install_cmd
	else
		say "$software version $package_version does not meet requirement $required_version, installing from external link\n"
	fi
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

proxy=$(select_proxy_software)
say "Selected proxy: $proxy\n"
install_package "$proxy"
