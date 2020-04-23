package dns

import (
	"github.com/tutacc/tutacc-core/common/errors"
	"github.com/tutacc/tutacc-core/common/net"
	"github.com/tutacc/tutacc-core/common/serial"
	"github.com/tutacc/tutacc-core/features"
)

// Client is a Tutacc feature for querying DNS information.
//
// tutacc:api:stable
type Client interface {
	features.Feature

	// LookupIP returns IP address for the given domain. IPs may contain IPv4 and/or IPv6 addresses.
	LookupIP(domain string) ([]net.IP, error)
}

// IPv4Lookup is an optional feature for querying IPv4 addresses only.
//
// tutacc:api:beta
type IPv4Lookup interface {
	LookupIPv4(domain string) ([]net.IP, error)
}

// IPv6Lookup is an optional feature for querying IPv6 addresses only.
//
// tutacc:api:beta
type IPv6Lookup interface {
	LookupIPv6(domain string) ([]net.IP, error)
}

// ClientType returns the type of Client interface. Can be used for implementing common.HasType.
//
// tutacc:api:beta
func ClientType() interface{} {
	return (*Client)(nil)
}

// ErrEmptyResponse indicates that DNS query succeeded but no answer was returned.
var ErrEmptyResponse = errors.New("empty response")

type RCodeError uint16

func (e RCodeError) Error() string {
	return serial.Concat("rcode: ", uint16(e))
}

func RCodeFromError(err error) uint16 {
	if err == nil {
		return 0
	}
	cause := errors.Cause(err)
	if r, ok := cause.(RCodeError); ok {
		return uint16(r)
	}
	return 0
}
