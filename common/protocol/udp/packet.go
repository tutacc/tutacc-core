package udp

import (
	"github.com/tutacc/tutacc-core/common/buf"
	"github.com/tutacc/tutacc-core/common/net"
)

// Packet is a UDP packet together with its source and destination address.
type Packet struct {
	Payload *buf.Buffer
	Source  net.Destination
	Target  net.Destination
}
