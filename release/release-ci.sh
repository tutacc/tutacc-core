#!/bin/bash

set -x

apt-get update
apt-get -y install \
    jq `# for parsing Github API` \
    git `# for go get` \
    file `# for Github upload` \
    pkg-config zip g++ zlib1g-dev unzip python `# for Bazel` \
    openssl `# for binary digest` \


function getattr() {
  curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/$2/attributes/$1
}

GITHUB_TOKEN=$(getattr "github_token" "project")
RELEASE_TAG=$(getattr "release_tag" "instance")
PRERELEASE=$(getattr "prerelease" "instance")
DOCKER_HUB_KEY=$(getattr "docker_hub_key" "project")
SIGN_KEY_PATH=$(getattr "sign_key_path" "project")
SIGN_KEY_PASS=$(getattr "sign_key_pass" "project")
VUSER=$(getattr "b_user" "project")

mkdir -p /v2/build

pushd /v2/build
BAZEL_VER=0.23.0
curl -L -O https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VER}/bazel-${BAZEL_VER}-installer-linux-x86_64.sh
chmod +x bazel-${BAZEL_VER}-installer-linux-x86_64.sh
./bazel-${BAZEL_VER}-installer-linux-x86_64.sh
popd

gsutil cp ${SIGN_KEY_PATH} /v2/build/sign_key.asc
echo ${SIGN_KEY_PASS} | gpg --passphrase-fd 0 --batch --import /v2/build/sign_key.asc

curl -L -o /v2/build/releases https://api.github.com/repos/tutacc/tutacc-core/releases

GO_INSTALL=golang.tar.gz
curl -L -o ${GO_INSTALL} https://storage.googleapis.com/golang/go1.11.5.linux-amd64.tar.gz
tar -C /usr/local -xzf ${GO_INSTALL}
export PATH=$PATH:/usr/local/go/bin

mkdir -p /v2/src
export GOPATH=/v2

# Download all source code
go get -insecure -t github.com/tutacc/tutacc-core/...
go get -insecure -t v2fly.org/ext/...

pushd $GOPATH/src/github.com/tutacc/tutacc-core/
git checkout tags/${RELEASE_TAG}

VERN=${RELEASE_TAG:1}
BUILDN=`date +%Y%m%d`
sed -i "s/\(version *= *\"\).*\(\"\)/\1$VERN\2/g" core.go
sed -i "s/\(build *= *\"\).*\(\"\)/\1$BUILDN\2/g" core.go
popd

pushd $GOPATH/src/github.com/tutacc/tutacc-core/
# Update geoip.dat
curl -L -o release/config/geoip.dat "https://github.com/tutacc/geoip/raw/release/geoip.dat"
sleep 1

# Update geosite.dat
curl -L -o release/config/geosite.dat "https://github.com/tutacc/domain-list-community/raw/release/dlc.dat"
sleep 1
popd

# Take a snapshot of all required source code
pushd $GOPATH/src

# Create zip file for all sources
zip -9 -r /v2/build/src_all.zip * -x '*.git*'
popd

pushd $GOPATH/src/github.com/tutacc/tutacc-core/
bazel build --action_env=GOPATH=$GOPATH --action_env=PATH=$PATH --action_env=GPG_PASS=${SIGN_KEY_PASS} //release:all
popd

RELBODY="https://www.v2fly.org/chapter_00/01_versions.html"
JSON_DATA=$(echo "{}" | jq -c ".tag_name=\"${RELEASE_TAG}\"")
JSON_DATA=$(echo ${JSON_DATA} | jq -c ".prerelease=${PRERELEASE}")
JSON_DATA=$(echo ${JSON_DATA} | jq -c ".body=\"${RELBODY}\"")
RELEASE_ID=$(curl --data "${JSON_DATA}" -H "Authorization: token ${GITHUB_TOKEN}" -X POST https://api.github.com/repos/tutacc/tutacc-core/releases | jq ".id")

function uploadfile() {
  FILE=$1
  CTYPE=$(file -b --mime-type $FILE)

  sleep 1
  curl -H "Authorization: token ${GITHUB_TOKEN}" -H "Content-Type: ${CTYPE}" --data-binary @$FILE "https://uploads.github.com/repos/tutacc/tutacc-core/releases/${RELEASE_ID}/assets?name=$(basename $FILE)"
  sleep 1
}

function upload() {
  FILE=$1
  DGST=$1.dgst
  openssl dgst -md5 $FILE | sed 's/([^)]*)//g' >> $DGST
  openssl dgst -sha1 $FILE | sed 's/([^)]*)//g' >> $DGST
  openssl dgst -sha256 $FILE | sed 's/([^)]*)//g' >> $DGST
  openssl dgst -sha512 $FILE | sed 's/([^)]*)//g' >> $DGST
  uploadfile $FILE
  uploadfile $DGST
}

ART_ROOT=$GOPATH/src/github.com/tutacc/tutacc-core/bazel-bin/release

upload ${ART_ROOT}/tutacc-macos.zip
upload ${ART_ROOT}/tutacc-windows-64.zip
upload ${ART_ROOT}/tutacc-windows-32.zip
upload ${ART_ROOT}/tutacc-linux-64.zip
upload ${ART_ROOT}/tutacc-linux-32.zip
upload ${ART_ROOT}/tutacc-linux-arm.zip
upload ${ART_ROOT}/tutacc-linux-arm64.zip
upload ${ART_ROOT}/tutacc-linux-mips64.zip
upload ${ART_ROOT}/tutacc-linux-mips64le.zip
upload ${ART_ROOT}/tutacc-linux-mips.zip
upload ${ART_ROOT}/tutacc-linux-mipsle.zip
upload ${ART_ROOT}/tutacc-linux-ppc64.zip
upload ${ART_ROOT}/tutacc-linux-ppc64le.zip
upload ${ART_ROOT}/tutacc-linux-s390x.zip
upload ${ART_ROOT}/tutacc-freebsd-64.zip
upload ${ART_ROOT}/tutacc-freebsd-32.zip
upload ${ART_ROOT}/tutacc-openbsd-64.zip
upload ${ART_ROOT}/tutacc-openbsd-32.zip
upload ${ART_ROOT}/tutacc-dragonfly-64.zip
upload /v2/build/src_all.zip

if [[ "${PRERELEASE}" == "false" ]]; then

DOCKER_HUB_API=https://cloud.docker.com/api/build/v1/source/62bfa37d-18ef-4b66-8f1a-35f9f3d4438b/trigger/65027872-e73e-4177-8c6c-6448d2f00d5b/call/
curl -H "Content-Type: application/json" --data '{"build": true}' -X POST "${DOCKER_HUB_API}"

# Update homebrew
pushd ${ART_ROOT}
V_HASH256=$(sha256sum tutacc-macos.zip | cut  -d ' ' -f 1)
popd

echo "SHA256: ${V_HASH256}"
echo "Version: ${VERN}"

DOWNLOAD_URL="https://github.com/tutacc/tutacc-core/releases/download/v${VERN}/tutacc-macos.zip"

cd $GOPATH/src/v2fly.org/
git clone https://github.com/tutacc/homebrew-tutacc.git

echo "Updating config"

cd homebrew-tutacc

sed -i "s#^\s*url.*#  url \"$DOWNLOAD_URL\"#g" Formula/tutacc-core.rb
sed -i "s#^\s*sha256.*#  sha256 \"$V_HASH256\"#g" Formula/tutacc-core.rb
sed -i "s#^\s*version.*#  version \"$VERN\"#g" Formula/tutacc-core.rb

echo "Updating repo"

git config user.name "Darien Raymond"
git config user.email "admin@v2fly.org"

git commit -am "update to version $VERN"
git push  --quiet "https://${GITHUB_TOKEN}@github.com/tutacc/homebrew-tutacc" master:master

echo "Updating dist"

cd $GOPATH/src/v2fly.org/
mkdir dist
cd dist

git init
git config user.name "Darien Raymond"
git config user.email "admin@v2fly.org"

cp ${ART_ROOT}/tutacc-macos.zip .
cp ${ART_ROOT}/tutacc-windows-64.zip .
cp ${ART_ROOT}/tutacc-windows-32.zip .
cp ${ART_ROOT}/tutacc-linux-64.zip .
cp ${ART_ROOT}/tutacc-linux-32.zip .
cp ${ART_ROOT}/tutacc-linux-arm.zip .
cp ${ART_ROOT}/tutacc-linux-arm64.zip .
cp ${ART_ROOT}/tutacc-linux-mips64.zip .
cp ${ART_ROOT}/tutacc-linux-mips64le.zip .
cp ${ART_ROOT}/tutacc-linux-mips.zip .
cp ${ART_ROOT}/tutacc-linux-mipsle.zip .
cp ${ART_ROOT}/tutacc-linux-ppc64.zip .
cp ${ART_ROOT}/tutacc-linux-ppc64le.zip .
cp ${ART_ROOT}/tutacc-linux-s390x.zip .
cp ${ART_ROOT}/tutacc-freebsd-64.zip .
cp ${ART_ROOT}/tutacc-freebsd-32.zip .
cp ${ART_ROOT}/tutacc-openbsd-64.zip .
cp ${ART_ROOT}/tutacc-openbsd-32.zip .
cp ${ART_ROOT}/tutacc-dragonfly-64.zip .
cp /v2/build/src_all.zip .
cp "$GOPATH/src/github.com/tutacc/tutacc-core/release/install-release.sh" ./install.sh

sed -i "s/^NEW_VER=\"\"$/NEW_VER=\"${RELEASE_TAG}\"/" install.sh
sed -i 's/^DIST_SRC=".*"$/DIST_SRC="jsdelivr"/' install.sh

git add .
git commit -m "Version ${RELEASE_TAG}"
git tag -a "${RELEASE_TAG}" -m "Version ${RELEASE_TAG}"
git remote add origin "https://${GITHUB_TOKEN}@github.com/tutacc/dist"
git push -u --force --follow-tags origin master

fi

