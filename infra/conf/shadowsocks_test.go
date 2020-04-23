package conf_test

import (
	"testing"

	"github.com/tutacc/tutacc-core/common/net"
	"github.com/tutacc/tutacc-core/common/protocol"
	"github.com/tutacc/tutacc-core/common/serial"
	. "github.com/tutacc/tutacc-core/infra/conf"
	"github.com/tutacc/tutacc-core/proxy/shadowsocks"
)

func TestShadowsocksServerConfigParsing(t *testing.T) {
	creator := func() Buildable {
		return new(ShadowsocksServerConfig)
	}

	runMultiTestCase(t, []TestCase{
		{
			Input: `{
				"method": "aes-128-cfb",
				"password": "tutacc-password"
			}`,
			Parser: loadJSON(creator),
			Output: &shadowsocks.ServerConfig{
				User: &protocol.User{
					Account: serial.ToTypedMessage(&shadowsocks.Account{
						CipherType: shadowsocks.CipherType_AES_128_CFB,
						Password:   "tutacc-password",
					}),
				},
				Network: []net.Network{net.Network_TCP},
			},
		},
	})
}
