package core_test

import (
	"testing"

	proto "github.com/golang/protobuf/proto"
	. "github.com/tutacc/tutacc-core"
	"github.com/tutacc/tutacc-core/app/dispatcher"
	"github.com/tutacc/tutacc-core/app/proxyman"
	"github.com/tutacc/tutacc-core/common"
	"github.com/tutacc/tutacc-core/common/net"
	"github.com/tutacc/tutacc-core/common/protocol"
	"github.com/tutacc/tutacc-core/common/serial"
	"github.com/tutacc/tutacc-core/common/uuid"
	"github.com/tutacc/tutacc-core/features/dns"
	"github.com/tutacc/tutacc-core/features/dns/localdns"
	_ "github.com/tutacc/tutacc-core/main/distro/all"
	"github.com/tutacc/tutacc-core/proxy/dokodemo"
	"github.com/tutacc/tutacc-core/proxy/vmess"
	"github.com/tutacc/tutacc-core/proxy/vmess/outbound"
	"github.com/tutacc/tutacc-core/testing/servers/tcp"
)

func TestTutaccDependency(t *testing.T) {
	instance := new(Instance)

	wait := make(chan bool, 1)
	instance.RequireFeatures(func(d dns.Client) {
		if d == nil {
			t.Error("expected dns client fulfilled, but actually nil")
		}
		wait <- true
	})
	instance.AddFeature(localdns.New())
	<-wait
}

func TestTutaccClose(t *testing.T) {
	port := tcp.PickPort()

	userId := uuid.New()
	config := &Config{
		App: []*serial.TypedMessage{
			serial.ToTypedMessage(&dispatcher.Config{}),
			serial.ToTypedMessage(&proxyman.InboundConfig{}),
			serial.ToTypedMessage(&proxyman.OutboundConfig{}),
		},
		Inbound: []*InboundHandlerConfig{
			{
				ReceiverSettings: serial.ToTypedMessage(&proxyman.ReceiverConfig{
					PortRange: net.SinglePortRange(port),
					Listen:    net.NewIPOrDomain(net.LocalHostIP),
				}),
				ProxySettings: serial.ToTypedMessage(&dokodemo.Config{
					Address: net.NewIPOrDomain(net.LocalHostIP),
					Port:    uint32(0),
					NetworkList: &net.NetworkList{
						Network: []net.Network{net.Network_TCP, net.Network_UDP},
					},
				}),
			},
		},
		Outbound: []*OutboundHandlerConfig{
			{
				ProxySettings: serial.ToTypedMessage(&outbound.Config{
					Receiver: []*protocol.ServerEndpoint{
						{
							Address: net.NewIPOrDomain(net.LocalHostIP),
							Port:    uint32(0),
							User: []*protocol.User{
								{
									Account: serial.ToTypedMessage(&vmess.Account{
										Id: userId.String(),
									}),
								},
							},
						},
					},
				}),
			},
		},
	}

	cfgBytes, err := proto.Marshal(config)
	common.Must(err)

	server, err := StartInstance("protobuf", cfgBytes)
	common.Must(err)
	server.Close()
}
