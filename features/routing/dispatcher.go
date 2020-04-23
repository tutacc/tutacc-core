package routing

import (
	"context"

	"github.com/tutacc/tutacc-core/common/net"
	"github.com/tutacc/tutacc-core/features"
	"github.com/tutacc/tutacc-core/transport"
)

// Dispatcher is a feature that dispatches inbound requests to outbound handlers based on rules.
// Dispatcher is required to be registered in a Tutacc instance to make Tutacc function properly.
//
// tutacc:api:stable
type Dispatcher interface {
	features.Feature

	// Dispatch returns a Ray for transporting data for the given request.
	Dispatch(ctx context.Context, dest net.Destination) (*transport.Link, error)
}

// DispatcherType returns the type of Dispatcher interface. Can be used to implement common.HasType.
//
// tutacc:api:stable
func DispatcherType() interface{} {
	return (*Dispatcher)(nil)
}
