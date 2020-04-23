package udp

import (
	"github.com/tutacc/tutacc-core/common"
	"github.com/tutacc/tutacc-core/transport/internet"
)

func init() {
	common.Must(internet.RegisterProtocolConfigCreator(protocolName, func() interface{} {
		return new(Config)
	}))
}
