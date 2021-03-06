info() {
	local -r bold=$(tput bold)
	local -r normal=$(tput sgr0)
	echo "${bold}I: $*${normal}"
}

error() {
	local -r red=$(tput setaf 1)
	local -r normal=$(tput sgr0)
	echo "${red}E: $*${normal}"
}

fail() {
	error "$*"
	exit 1
}
