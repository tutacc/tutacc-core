// +build !confonly

package tcp

import (
	"github.com/tutacc/tutacc-core/common"
	"github.com/tutacc/tutacc-core/transport/internet"
)

const protocolName = "tcp"

func init() {
	common.Must(internet.RegisterProtocolConfigCreator(protocolName, func() interface{} {
		return new(Config)
	}))
}
