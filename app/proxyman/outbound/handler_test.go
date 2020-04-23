package outbound_test

import (
	"testing"

	. "github.com/tutacc/tutacc-core/app/proxyman/outbound"
	"github.com/tutacc/tutacc-core/features/outbound"
)

func TestInterfaces(t *testing.T) {
	_ = (outbound.Handler)(new(Handler))
	_ = (outbound.Manager)(new(Manager))
}
