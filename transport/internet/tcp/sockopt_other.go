// +build !linux,!freebsd
// +build !confonly

package tcp

import (
	"github.com/tutacc/tutacc-core/common/net"
	"github.com/tutacc/tutacc-core/transport/internet"
)

func GetOriginalDestination(conn internet.Connection) (net.Destination, error) {
	return net.Destination{}, nil
}
