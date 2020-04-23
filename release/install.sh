#!/bin/bash

GO_AMD64=https://storage.googleapis.com/golang/go1.11.1.linux-amd64.tar.gz
GO_X86=https://storage.googleapis.com/golang/go1.11.1.linux-386.tar.gz
ARCH=$(uname -m)
GO_CUR=${GO_AMD64}

if [ "$ARCH" == "i686" ] || [ "$ARCH" == "i386" ]; then
  GO_CUR=${GO_X86}
fi

which git > /dev/null || apt-get install git -y

if [ -z "$GOPATH" ]; then
  curl -o go_latest.tar.gz ${GO_CUR}
  tar -C /usr/local -xzf go_latest.tar.gz
  rm go_latest.tar.gz
  export PATH=$PATH:/usr/local/go/bin

  mkdir /tutacc &> /dev/null
  export GOPATH=/tutacc
fi

go get -insecure -u github.com/tutacc/tutacc-core/...
go build -o $GOPATH/bin/tutacc github.com/tutacc/tutacc-core/main
go build -o $GOPATH/bin/tutactl github.com/tutacc/tutacc-core/infra/control/main
