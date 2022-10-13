# Build and Deploy Service to Remote Linux Server


### DONT TOUCH ###############
script_dir="$(dirname ${0})" #
source "${script_dir}/.env"  #
uri="${user}@${host}"        #
tarball="${service}.tar.gz"  #
source_dir="src"             #
bin_dir="bin"                #
build_root="build"           #
##############################

COLOR='\033[1;32m'
NC='\033[0m' # No Color


timestamp() { 
    date +"%Y-%m-%d %H:%M:%S" 
}

log() {
    printf "${COLOR}[$(timestamp)] ${1}${NC}\n"
}

build() {
    # CREATE BUILDROOT
    log "Staging ${build_root}"
    mkdir -p "${build_root}/${service}"
    cp -rv "${source_dir}" "${build_root}/${service}"
    cp -v devops/install.sh "${build_root}/${service}"
    cp -v devops/.env "${build_root}/${service}"

    # PACKAGE TARBALL
    log "Building package ./${bin_dir}/${tarball} from ${build_root}"
    mkdir -pv "${bin_dir}"
    tar -czvf "${bin_dir}/${tarball}" -C "${build_root}" .
}

deploy() {
    log "Deploying ${bin_dir}/${tarball} to ${host}"
    scp "${bin_dir}/${tarball}" "${uri}:~"
}

install() {
    log "Installing ${service} on ${host}"
    ssh -q -t "${uri}" "tar -xf ~/${tarball} && sudo bash ${service}/install.sh"
}

clean() {
    log "Cleaning ${bin_dir} and ${build_root}"
    rm -rfv "${bin_dir}"
    rm -rfv "${build_root}"
}


# PARSE ARGUMENTS
case "${1}" in
    build) build ;;
    deploy) deploy ;;
    install) install ;;
    clean) clean ;;
    *) echo "Unknown argument: ${1}. Try: build, deploy, install, clean" ;;
esac

