#!/bin/bash

# This file is accessible as https://install.direct/go.sh
# Original source is located at github.com/tutacc/tutacc-core/release/install-release.sh

# If not specify, default meaning of return value:
# 0: Success
# 1: System error
# 2: Application error
# 3: Network error

# CLI arguments
PROXY=''
HELP=''
FORCE=''
CHECK=''
REMOVE=''
VERSION=''
VSRC_ROOT='/tmp/tutacc'
EXTRACT_ONLY=''
LOCAL=''
LOCAL_INSTALL=''
DIST_SRC='github'
ERROR_IF_UPTODATE=''

CUR_VER=""
NEW_VER=""
VDIS=''
ZIPFILE="/tmp/tutacc/tutacc.zip"
TUTACC_RUNNING=0

CMD_INSTALL=""
CMD_UPDATE=""
SOFTWARE_UPDATED=0

SYSTEMCTL_CMD=$(command -v systemctl 2>/dev/null)
SERVICE_CMD=$(command -v service 2>/dev/null)

#######color code########
RED="31m"      # Error message
GREEN="32m"    # Success message
YELLOW="33m"   # Warning message
BLUE="36m"     # Info message


#########################
while [[ $# > 0 ]]; do
    case "$1" in
        -p|--proxy)
        PROXY="-x ${2}"
        shift # past argument
        ;;
        -h|--help)
        HELP="1"
        ;;
        -f|--force)
        FORCE="1"
        ;;
        -c|--check)
        CHECK="1"
        ;;
        --remove)
        REMOVE="1"
        ;;
        --version)
        VERSION="$2"
        shift
        ;;
        --extract)
        VSRC_ROOT="$2"
        shift
        ;;
        --extractonly)
        EXTRACT_ONLY="1"
        ;;
        -l|--local)
        LOCAL="$2"
        LOCAL_INSTALL="1"
        shift
        ;;
        --source)
        DIST_SRC="$2"
        shift
        ;;
        --errifuptodate)
        ERROR_IF_UPTODATE="1"
        ;;
        *)
                # unknown option
        ;;
    esac
    shift # past argument or value
done

###############################
colorEcho(){
    echo -e "\033[${1}${@:2}\033[0m" 1>& 2
}

archAffix(){
    case "${1:-"$(uname -m)"}" in
        i686|i386)
            echo '32'
        ;;
        x86_64|amd64)
            echo '64'
        ;;
        *armv7*|armv6l)
            echo 'arm'
        ;;
        *armv8*|aarch64)
            echo 'arm64'
        ;;
        *mips64le*)
            echo 'mips64le'
        ;;
        *mips64*)
            echo 'mips64'
        ;;
        *mipsle*)
            echo 'mipsle'
        ;;
        *mips*)
            echo 'mips'
        ;;
        *s390x*)
            echo 's390x'
        ;;
        ppc64le)
            echo 'ppc64le'
        ;;
        ppc64)
            echo 'ppc64'
        ;;
        *)
            return 1
        ;;
    esac

	return 0
}

zipRoot() {
    unzip -lqq "$1" | awk -e '
        NR == 1 {
            prefix = $4;
        }
        NR != 1 {
            prefix_len = length(prefix);
            cur_len = length($4);

            for (len = prefix_len < cur_len ? prefix_len : cur_len; len >= 1; len -= 1) {
                sub_prefix = substr(prefix, 1, len);
                sub_cur = substr($4, 1, len);

                if (sub_prefix == sub_cur) {
                    prefix = sub_prefix;
                    break;
                }
            }

            if (len == 0) {
                prefix = "";
                nextfile;
            }
        }
        END {
            print prefix;
        }
    '
}

downloadTutacc(){
    rm -rf /tmp/tutacc
    mkdir -p /tmp/tutacc
    if [[ "${DIST_SRC}" == "jsdelivr" ]]; then
        DOWNLOAD_LINK="https://cdn.jsdelivr.net/gh/tutacc/dist/tutacc-linux-${VDIS}.zip"
    else
        DOWNLOAD_LINK="https://github.com/tutacc/tutacc-core/releases/download/${NEW_VER}/tutacc-linux-${VDIS}.zip"
    fi
    colorEcho ${BLUE} "Downloading Tutacc: ${DOWNLOAD_LINK}"
    curl ${PROXY} -L -H "Cache-Control: no-cache" -o ${ZIPFILE} ${DOWNLOAD_LINK}
    if [ $? != 0 ];then
        colorEcho ${RED} "Failed to download! Please check your network or try again."
        return 3
    fi
    return 0
}

installSoftware(){
    COMPONENT=$1
    if [[ -n `command -v $COMPONENT` ]]; then
        return 0
    fi

    getPMT
    if [[ $? -eq 1 ]]; then
        colorEcho ${RED} "The system package manager tool isn't APT or YUM, please install ${COMPONENT} manually."
        return 1
    fi
    if [[ $SOFTWARE_UPDATED -eq 0 ]]; then
        colorEcho ${BLUE} "Updating software repo"
        $CMD_UPDATE
        SOFTWARE_UPDATED=1
    fi

    colorEcho ${BLUE} "Installing ${COMPONENT}"
    $CMD_INSTALL $COMPONENT
    if [[ $? -ne 0 ]]; then
        colorEcho ${RED} "Failed to install ${COMPONENT}. Please install it manually."
        return 1
    fi
    return 0
}

# return 1: not apt, yum, or zypper
getPMT(){
    if [[ -n `command -v apt-get` ]];then
        CMD_INSTALL="apt-get -y -qq install"
        CMD_UPDATE="apt-get -qq update"
    elif [[ -n `command -v yum` ]]; then
        CMD_INSTALL="yum -y -q install"
        CMD_UPDATE="yum -q makecache"
    elif [[ -n `command -v zypper` ]]; then
        CMD_INSTALL="zypper -y install"
        CMD_UPDATE="zypper ref"
    else
        return 1
    fi
    return 0
}

normalizeVersion() {
    if [ -n "$1" ]; then
        case "$1" in
            v*)
                echo "$1"
            ;;
            *)
                echo "v$1"
            ;;
        esac
    else
        echo ""
    fi
}

# 1: new Tutacc. 0: no. 2: not installed. 3: check failed. 4: don't check.
getVersion(){
    if [[ -n "$VERSION" ]]; then
        NEW_VER="$(normalizeVersion "$VERSION")"
        return 4
    else
        VER="$(/usr/bin/tutacc/tutacc -version 2>/dev/null)"
        RETVAL=$?
        CUR_VER="$(normalizeVersion "$(echo "$VER" | head -n 1 | cut -d " " -f2)")"
        TAG_URL="https://api.github.com/repos/tutacc/tutacc-core/releases/latest"
        NEW_VER="$(normalizeVersion "$(curl ${PROXY} -H "Accept: application/json" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:74.0) Gecko/20100101 Firefox/74.0" -s "${TAG_URL}" --connect-timeout 10| grep 'tag_name' | cut -d\" -f4)")"

        if [[ $? -ne 0 ]] || [[ $NEW_VER == "" ]]; then
            colorEcho ${RED} "Failed to fetch release information. Please check your network or try again."
            return 3
        elif [[ $RETVAL -ne 0 ]];then
            return 2
        elif [[ $NEW_VER != $CUR_VER ]];then
            return 1
        fi
        return 0
    fi
}

stopTutacc(){
    colorEcho ${BLUE} "Shutting down Tutacc service."
    if [[ -n "${SYSTEMCTL_CMD}" ]] || [[ -f "/lib/systemd/system/tutacc.service" ]] || [[ -f "/etc/systemd/system/tutacc.service" ]]; then
        ${SYSTEMCTL_CMD} stop tutacc
    elif [[ -n "${SERVICE_CMD}" ]] || [[ -f "/etc/init.d/tutacc" ]]; then
        ${SERVICE_CMD} tutacc stop
    fi
    if [[ $? -ne 0 ]]; then
        colorEcho ${YELLOW} "Failed to shutdown Tutacc service."
        return 2
    fi
    return 0
}

startTutacc(){
    if [ -n "${SYSTEMCTL_CMD}" ] && [[ -f "/lib/systemd/system/tutacc.service" || -f "/etc/systemd/system/tutacc.service" ]]; then
        ${SYSTEMCTL_CMD} start tutacc
    elif [ -n "${SERVICE_CMD}" ] && [ -f "/etc/init.d/tutacc" ]; then
        ${SERVICE_CMD} tutacc start
    fi
    if [[ $? -ne 0 ]]; then
        colorEcho ${YELLOW} "Failed to start Tutacc service."
        return 2
    fi
    return 0
}

installTutacc(){
    # Install Tutacc binary to /usr/bin/tutacc
    mkdir -p '/etc/tutacc' '/var/log/tutacc' && \
    unzip -oj "$1" "$2tutacc" "$2tutactl" "$2geoip.dat" "$2geosite.dat" -d '/usr/bin/tutacc' && \
    chmod +x '/usr/bin/tutacc/tutacc' '/usr/bin/tutacc/tutactl' || {
        colorEcho ${RED} "Failed to copy Tutacc binary and resources."
        return 1
    }

    # Install Tutacc server config to /etc/tutacc
    if [ ! -f '/etc/tutacc/config.json' ]; then
        local PORT="$(($RANDOM + 10000))"
        local UUID="$(cat '/proc/sys/kernel/random/uuid')"

        unzip -pq "$1" "$2vpoint_vmess_freedom.json" | \
        sed -e "s/10086/${PORT}/g; s/23ad6b10-8d1a-40f7-8ad0-e3e35cd38297/${UUID}/g;" - > \
        '/etc/tutacc/config.json' || {
            colorEcho ${YELLOW} "Failed to create Tutacc configuration file. Please create it manually."
            return 1
        }

        colorEcho ${BLUE} "PORT:${PORT}"
        colorEcho ${BLUE} "UUID:${UUID}"
    fi
}


installInitScript(){
    if [[ -n "${SYSTEMCTL_CMD}" ]]; then
        if [[ ! -f "/etc/systemd/system/tutacc.service" && ! -f "/lib/systemd/system/tutacc.service" ]]; then
            unzip -oj "$1" "$2systemd/tutacc.service" -d '/etc/systemd/system' && \
            systemctl enable tutacc.service
        fi
    elif [[ -n "${SERVICE_CMD}" ]] && [[ ! -f "/etc/init.d/tutacc" ]]; then
        installSoftware 'daemon' && \
        unzip -oj "$1" "$2systemv/tutacc" -d '/etc/init.d' && \
        chmod +x '/etc/init.d/tutacc' && \
        update-rc.d tutacc defaults
    fi
}

Help(){
  cat - 1>& 2 << EOF
./install-release.sh [-h] [-c] [--remove] [-p proxy] [-f] [--version vx.y.z] [-l file]
  -h, --help            Show help
  -p, --proxy           To download through a proxy server, use -p socks5://127.0.0.1:1080 or -p http://127.0.0.1:3128 etc
  -f, --force           Force install
      --version         Install a particular version, use --version v3.15
  -l, --local           Install from a local file
      --remove          Remove installed Tutacc
  -c, --check           Check for update
EOF
}

remove(){
    if [[ -n "${SYSTEMCTL_CMD}" ]] && [[ -f "/etc/systemd/system/tutacc.service" ]];then
        if pgrep "tutacc" > /dev/null ; then
            stopTutacc
        fi
        systemctl disable tutacc.service
        rm -rf "/usr/bin/tutacc" "/etc/systemd/system/tutacc.service"
        if [[ $? -ne 0 ]]; then
            colorEcho ${RED} "Failed to remove Tutacc."
            return 0
        else
            colorEcho ${GREEN} "Removed Tutacc successfully."
            colorEcho ${BLUE} "If necessary, please remove configuration file and log file manually."
            return 0
        fi
    elif [[ -n "${SYSTEMCTL_CMD}" ]] && [[ -f "/lib/systemd/system/tutacc.service" ]];then
        if pgrep "tutacc" > /dev/null ; then
            stopTutacc
        fi
        systemctl disable tutacc.service
        rm -rf "/usr/bin/tutacc" "/lib/systemd/system/tutacc.service"
        if [[ $? -ne 0 ]]; then
            colorEcho ${RED} "Failed to remove Tutacc."
            return 0
        else
            colorEcho ${GREEN} "Removed Tutacc successfully."
            colorEcho ${BLUE} "If necessary, please remove configuration file and log file manually."
            return 0
        fi
    elif [[ -n "${SERVICE_CMD}" ]] && [[ -f "/etc/init.d/tutacc" ]]; then
        if pgrep "tutacc" > /dev/null ; then
            stopTutacc
        fi
        rm -rf "/usr/bin/tutacc" "/etc/init.d/tutacc"
        if [[ $? -ne 0 ]]; then
            colorEcho ${RED} "Failed to remove Tutacc."
            return 0
        else
            colorEcho ${GREEN} "Removed Tutacc successfully."
            colorEcho ${BLUE} "If necessary, please remove configuration file and log file manually."
            return 0
        fi
    else
        colorEcho ${YELLOW} "Tutacc not found."
        return 0
    fi
}

checkUpdate(){
    echo "Checking for update."
    VERSION=""
    getVersion
    RETVAL="$?"
    if [[ $RETVAL -eq 1 ]]; then
        colorEcho ${BLUE} "Found new version ${NEW_VER} for Tutacc.(Current version:$CUR_VER)"
    elif [[ $RETVAL -eq 0 ]]; then
        colorEcho ${BLUE} "No new version. Current version is ${NEW_VER}."
    elif [[ $RETVAL -eq 2 ]]; then
        colorEcho ${YELLOW} "No Tutacc installed."
        colorEcho ${BLUE} "The newest version for Tutacc is ${NEW_VER}."
    fi
    return 0
}

main(){
    #helping information
    [[ "$HELP" == "1" ]] && Help && return
    [[ "$CHECK" == "1" ]] && checkUpdate && return
    [[ "$REMOVE" == "1" ]] && remove && return

    local ARCH=$(uname -m)
    VDIS="$(archAffix)"

    # extract local file
    if [[ $LOCAL_INSTALL -eq 1 ]]; then
        colorEcho ${YELLOW} "Installing Tutacc via local file. Please make sure the file is a valid Tutacc package, as we are not able to determine that."
        NEW_VER=local
        rm -rf /tmp/tutacc
        ZIPFILE="$LOCAL"
        #FILEVDIS=`ls /tmp/tutacc |grep tutacc-v |cut -d "-" -f4`
        #SYSTEM=`ls /tmp/tutacc |grep tutacc-v |cut -d "-" -f3`
        #if [[ ${SYSTEM} != "linux" ]]; then
        #    colorEcho ${RED} "The local Tutacc can not be installed in linux."
        #    return 1
        #elif [[ ${FILEVDIS} != ${VDIS} ]]; then
        #    colorEcho ${RED} "The local Tutacc can not be installed in ${ARCH} system."
        #    return 1
        #else
        #    NEW_VER=`ls /tmp/tutacc |grep tutacc-v |cut -d "-" -f2`
        #fi
    else
        # download via network and extract
        installSoftware "curl" || return $?
        getVersion
        RETVAL="$?"
        if [[ $RETVAL == 0 ]] && [[ "$FORCE" != "1" ]]; then
            colorEcho ${BLUE} "Latest version ${CUR_VER} is already installed."
            if [ -n "${ERROR_IF_UPTODATE}" ]; then
              return 10
            fi
            return
        elif [[ $RETVAL == 3 ]]; then
            return 3
        else
            colorEcho ${BLUE} "Installing Tutacc ${NEW_VER} on ${ARCH}"
            downloadTutacc || return $?
        fi
    fi

    local ZIPROOT="$(zipRoot "${ZIPFILE}")"
    installSoftware unzip || return $?

    if [ -n "${EXTRACT_ONLY}" ]; then
        colorEcho ${BLUE} "Extracting Tutacc package to ${VSRC_ROOT}."

        if unzip -o "${ZIPFILE}" -d ${VSRC_ROOT}; then
            colorEcho ${GREEN} "Tutacc extracted to ${VSRC_ROOT%/}${ZIPROOT:+/${ZIPROOT%/}}, and exiting..."
            return 0
        else
            colorEcho ${RED} "Failed to extract Tutacc."
            return 2
        fi
    fi

    if pgrep "tutacc" > /dev/null ; then
        TUTACC_RUNNING=1
        stopTutacc
    fi
    installTutacc "${ZIPFILE}" "${ZIPROOT}" || return $?
    installInitScript "${ZIPFILE}" "${ZIPROOT}" || return $?
    if [[ ${TUTACC_RUNNING} -eq 1 ]];then
        colorEcho ${BLUE} "Restarting Tutacc service."
        startTutacc
    fi
    colorEcho ${GREEN} "Tutacc ${NEW_VER} is installed."
    rm -rf /tmp/tutacc
    return 0
}

main
