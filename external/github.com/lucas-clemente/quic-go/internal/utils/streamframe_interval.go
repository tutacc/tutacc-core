package utils

import "github.com/tutacc/tutacc-core/external/github.com/lucas-clemente/quic-go/internal/protocol"

// ByteInterval is an interval from one ByteCount to the other
type ByteInterval struct {
	Start protocol.ByteCount
	End   protocol.ByteCount
}
