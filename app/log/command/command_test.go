package command_test

import (
	"context"
	"testing"

	"github.com/tutacc/tutacc-core"
	"github.com/tutacc/tutacc-core/app/dispatcher"
	"github.com/tutacc/tutacc-core/app/log"
	. "github.com/tutacc/tutacc-core/app/log/command"
	"github.com/tutacc/tutacc-core/app/proxyman"
	_ "github.com/tutacc/tutacc-core/app/proxyman/inbound"
	_ "github.com/tutacc/tutacc-core/app/proxyman/outbound"
	"github.com/tutacc/tutacc-core/common"
	"github.com/tutacc/tutacc-core/common/serial"
)

func TestLoggerRestart(t *testing.T) {
	v, err := core.New(&core.Config{
		App: []*serial.TypedMessage{
			serial.ToTypedMessage(&log.Config{}),
			serial.ToTypedMessage(&dispatcher.Config{}),
			serial.ToTypedMessage(&proxyman.InboundConfig{}),
			serial.ToTypedMessage(&proxyman.OutboundConfig{}),
		},
	})
	common.Must(err)
	common.Must(v.Start())

	server := &LoggerServer{
		V: v,
	}
	common.Must2(server.RestartLogger(context.Background(), &RestartLoggerRequest{}))
}
